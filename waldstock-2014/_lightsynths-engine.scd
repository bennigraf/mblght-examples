// The engine basically reacts to quneo midi data.
// Every pad (4x4) gets a synth that's started on touch, controlled on hold and
// released/freed on release.

~lsengine = ();

~lsengine.nodes = Dictionary();

~lsengine.activeNode = 0; // latest used/changed/modified node id
~lsengine.onhold = false; // used to hold values of pads
~lsengine.onselect = false; // used to select node without activating it (i.e. for setting args/color)

// use this to store cc values which are sent before noteon starts the synth
~lsengine.padlatch = Dictionary();
// stores color selectors which stay active after ending the synth
~lsengine.colSelectors = Dictionary();
// stores args for synths which also stay active and are applied to the next synth started
~lsengine.extraArgs = Dictionary();

// extra buses used for mixing of light synths which is kind of broken otherwise
~lsengine.clrbuses = nil;

~lsengine.makeClrBuses = { |self|
	var replaceOutBuses;
	if(self.clrbuses.notNil, {
		self.clrbuses.do({|b| b.free; });
	});
	replaceOutBuses = Patcher.default.busesForMethod(\color).collect({ |bus, i|
		Bus.control(s, bus.numChannels());
	});
	~replaceOutBuses = replaceOutBuses;
	self.clrbuses = replaceOutBuses;
};

// those buses are used for "alpha" filtering... they get pixel data from
// processing (waldstockBarWarp.pde)
~lsengine.filterBuses = nil;
~lsengine.makeFilterBuses = { |self|
	var fbuses;
	if(self.filterBuses.notNil, {
		self.clrbuses.do({|b| b.free; });
	});
	fbuses = Patcher.default.busesForMethod(\color).collect({ |bus, i|
		Bus.control(s, bus.numChannels());
	});
	self.filterBuses = fbuses;
	~lsengine.filterBuses = fbuses;
	"made those filter buses".postln;
	fbuses.postln;
};

/*
~lsengine.makeFilterOSCdef();
~lsengine.filterBuses.size
*/
// ~lsengine.boot()
~lsengine.makeFilterOSCdef = { |self|
	OSCdef(\barMappingFilter, { |msg|
		// msg.postln;
		if(self.filterBuses.size >= (msg[1] - 1 * 8 + 8), {
			var busoffset = (msg[1] - 1) * 8;
			8.do({ |n|
				var m = msg[(n * 3 + 2)..].keep(3)/255.0;
				// [busoffset + n, m].postln;
				self.filterBuses[busoffset + n].setnSynchronous(m);
			});

		});
	}, '/mappedBarData');
};

// set the active node (that's to be controlled...)
~lsengine.setActiveNode = { |self, id|
	self.activeNode = id;

	// set color selector midi notes
	// first turn all off
	3.do({ |n| ~q.out.noteOff(0, 33 + n, 0); });
	// turn the right ones back on
	if(self.colSelectors[id].notNil, {
		self.colSelectors[id].keysValuesDo({ |k, v|
			~q.out.noteOn(0, 33 + v, 127);
		});
	});

	// set extra arg values, midi cc's 11 to 8
	if(self.extraArgs[id].notNil, {
		4.do({ |n|
			~q.out.control(0, 11 - n, self.extraArgs[id][("arg"++n).asSymbol] * 127);
		});
	}, {
		4.do({ |n| ~q.out.control(0, 11 - n, 0) });
	});
};


~lsengine.on = { |self, id|
	self.setActiveNode(id);
	// check if node is already there (happens when using hold)
	if(self.onselect.not && self.nodes[id].isNil, {
		// create the node by creating the corresponding synth, "map" it in .nodes[]
		// id is 0 to 15 (representing the pads 1 to 16)
		var syn = Synth(("light_"++id).asSymbol).set(\gate, 1);
		// store synth + hold-values (p, x, y, arg0..3) in syn-object that goes
		// to dictionary
		var synobj = (
			\synth: syn,
			\lastvals: (\x: 0, \y: 0, \p: 0),
			\holds: (\x: false, \y: false, \p: false),
			\onhold: false
		);
		// if p/x/y values were recorded before this node was started, set them here
		// (quneo sends cc's before the first noteon, this is a workaround...)
		if(self.padlatch[id].notNil, {
			[\p, \x, \y].do({ |k|
				if(self.padlatch[id][k].notNil, {
					syn.set(k, self.padlatch[id][k]/127);
					self.visu.sendMsg('/liveData', id.asFloat, k, self.padlatch[id][k]);
					synobj[\lastvals][k] = self.padlatch[id][k];
				});
			});
		});
		// if additional args were set before for this slot, set them again
		if(self.extraArgs[id].notNil, {
			4.do({ |n|
				syn.set(("arg"++n).asSymbol, self.extraArgs[id][("arg"++n).asSymbol]);
			});
		});

		// if color was set before, set it here again
		if(self.colSelectors[id].notNil, {
			3.do({ |n|
				if(self.colSelectors[id][n].notNil, {
					syn.set(("clr"++n).asSymbol, ~clrngn.buses[self.colSelectors[id][n]]);
				});
			});
		});

		self.nodes.put(id, synobj);
		"booting synth node".postln;
	});
	if(self.onselect.not && self.nodes[id].notNil, {
		// if the node is there, it probably was on hold
		// I remove object hold here, values are still on hold though!
		self.nodes[id].onhold= false;
	});
};

~lsengine.cc = { |self, id, ctrl, val|
	if(self.onselect.not && self.nodes[id].notNil, {
		if(self.nodes[id].onhold.not, {
			// check for each value if it was on hold
			// if so, compare current with last value
			// if not, set directly
			if(self.nodes[id].holds[ctrl].not, {
				self.nodes[id][\synth].set(ctrl, val/127);
				self.nodes[id][\lastvals][ctrl] = val;
				self.visu.sendMsg('/liveData', id, ctrl, val);
			}, {
				// compare values, set if close enough
				if((self.nodes[id].lastvals[ctrl] - val).abs < 5, {
					// self.nodes[id][\synth].set(ctrl, val/127);
					self.nodes[id].holds[ctrl] = false;
				});
				self.visu.sendMsg('/offData', id, ctrl, val);
			});
		});
	});
	if(self.onselect.not && self.nodes[id].isNil, {
		// this happens when the pad is initially pressed because cc is sent before noteOn.
		// So we set the cc value to padlatch which is loaded on synth creation
		if(self.padlatch[id].isNil, {
			self.padlatch[id] = Dictionary();
		});
		self.padlatch[id][ctrl] = val;
	});
};

~lsengine.off = { |self, id|
	if(self.nodes[id].notNil, {
		if(self.onselect.not && self.nodes[id].onhold.not, {
			// release node - set \gate (or something) to 0 to allow for fadeout
			self.nodes[id][\synth].set(\gate, 0);
			self.nodes[id][\synth].set(\p, 0);
			// for debugging, free manually:
			// self.nodes[id][\synth].free;
			"ending synth node".postln;
			self.nodes.removeAt(id);
			self.padlatch.removeAt(id);
		});
	});
};


~lsengine.setArg = { |self, num, val|
	// set arg 0 to 3, represented by the faders on the left of the pads
	// By design: don't pick up midi values for those faders, as there's optical
	// feedback for current values!
	if(self.nodes[self.activeNode].notNil, {
		self.nodes[self.activeNode][\synth].set(("arg"++num).asSymbol, val/127);
	});
	if(self.extraArgs[self.activeNode].isNil, {
		self.extraArgs.put(self.activeNode, (\arg0: 0, \arg1: 0, \arg2: 0, \arg3: 0));
	});
	self.extraArgs[self.activeNode][("arg"++num).asSymbol] = val/127;
};

// sets color toggles to use with last used synth/pad
// There are three buses. The one that's selected first goes to
// \col1.kr in the synth, the one selected second to \col2.kr etc.
// They also stay on this position if a previous bus is "freed" until
// they are newly selected.
~lsengine.colorToggle = { |self, tglid|
	var id = self.activeNode;
	var found = false; // used later

	if(self.colSelectors[id].isNil, {
		self.colSelectors[id] = Dictionary();
	});

	// check if color is used already, remove if entry is found
	self.colSelectors[id].keysValuesDo({ |k, v|
		if(v == tglid, {
			self.colSelectors[id].removeAt(k);
			found = true;
		});
	});

	// add entry if it was unset (aka off)
	if(found.not, {
		var wasset = false;
		3.do({ |n|
			if(wasset.not && self.colSelectors[id][n].isNil, {
				self.colSelectors[id].put(n, tglid);
				wasset = true;
			});
		});
	});

	// set color buses accordingly
	if(self.nodes[id].notNil, {
		self.colSelectors[id].keysValuesDo({ |k, v|
			self.nodes[id][\synth].set(("clr"++k).asSymbol, ~clrngn.buses[v]);
		});
		3.do({ |n|
			if(self.colSelectors[id][n].notNil, {
				self.nodes[id][\synth].set(("clr"++n).asSymbol, ~clrngn.buses[self.colSelectors[id][n]]);
			}, {
				// "unset" bus
				self.nodes[id][\synth].set(("clr"++n).asSymbol, 0);
			});
		});
	});

	// use this to reset colors etc on quneo
	self.setActiveNode(self.activeNode);
};


// hold the engine; controls aren't forwarded to nodes anymore
~lsengine.hold = { |self|
	"hold!".postln;
	self.onhold = true;
	self.nodes.do({ |n|
		// all active nodes must be on hold now...
		n.onhold = true;
		n.holds.keysValuesDo({ |k|
			n.holds[k] = true;
		});
	});
};
~lsengine.unhold = { |self|
	"leaving hold".postln;
	self.onhold = false;
};

~lsengine.selectMode = { |self, active = true|
	self.onselect = active || false; // this allows only bool values
};

// controls the nodes via the faders on the bottom left
// they have only one controllable argument (val).
~lsengine.barSynths = Dictionary();
~lsengine.setBarNode = { |self, nodeid, val|
	if(val > 0, {
		self.barSynths[nodeid].isNil.if({
			var syn = Synth(("barlight_"++nodeid).asSymbol).set(\gate, 1);
			syn.set(\val, val/127);
			self.barSynths.put(nodeid, syn);
		});
		self.barSynths[nodeid].notNil.if({
			self.barSynths[nodeid].set(\val, val/127);
		});
	});
	if(val == 0, {
		// val is 0 -> kill node
		self.barSynths[nodeid].notNil.if({
			self.barSynths[nodeid].set(\gate, 0);
			self.barSynths[nodeid].set(\val, 0);
			self.barSynths.removeAt(nodeid);
		});
	});

};
// ~lsengine.barSynths.removeAt(1)

// boot engine; load all the synthdefs (but don't start them yet)
~lsengine.boot = { |self|
	self.visu = NetAddr.new("localhost", 13334);
	"waiting for boot".postln;
	s.waitForBoot({
		self.makeClrBuses();
		self.makeFilterBuses();
		self.makeFilterOSCdef();
	});
};

~lsengine.boot();