~q = ();

// ~q.midiId = 1341032007; // id of QUNEO in MIDI-Space
~q.midiId = -867692283;

~q.boot = { |self|

	// try to connect to quneo, throws error if it doesn't find it
	if(MIDIClient.sources.isNil, {
		// init MIDIClient
		MIDIClient.init;
		try({
			// MIDIIn.connectByUID(0, self.midiId); // quneo

			MIDIIn.connectAll();
			self.out = MIDIOut.newByName("QUNEO", "QUNEO").latency_(0);
		}, {
			"Could not connect to QUNEO!".error;
		});
	}, {
		"MIDI already connected...".postln;
		self.out = MIDIOut.newByName("QUNEO", "QUNEO").latency_(0);
	});

	self.makeMidiDefs();
};

~q.makeMidiDefs = { |self|
	/////////////////////////////////////
	// catch stuff for nodes on pads
	MIDIdef.noteOn(\padsOn, { |val, num|
		// id is id of synth and pad, 0 to 15
		var id = num;
		~lsengine.on(id)
	}, (0..15), 1, self.midiId);
	MIDIdef.cc(\padsCC, { |val, num|
		// id is padnum (0..15)
		var id = (num/3).floor;
		// ctrlName is press/x/y control
		// assuming they are sequentially numbered after press/x/y starting on pad 0 with cc 0 for press etc.
		var ctrlName = [\p, \x, \y].at(num % 3);
		~lsengine.cc(id, ctrlName, val);
	}, (0..47), 1, self.midiId);
	MIDIdef.noteOff(\padsOff, { |val, num|
		// args.postln;
		var id = num;
		~lsengine.off(id);
	}, (0..15), 1, self.midiId);

	///////////////////////////////////// set colors to use with transport buttons (24..26)
	MIDIdef.noteOn(\clrSelectors, { |val, num|
		// id is id of synth and pad, 0 to 15
		var id = num - 24;
		~lsengine.colorToggle(id);
	}, (24..26), 0, self.midiId);

	///////////////////////////////////// misc other stuff
	// control slider-args of currently selected node (does this stay?)
	MIDIdef.cc(\argslider, { |val, num|
		// set an arg of the selected conti node
		~lsengine.setArg(num, val);
	}, (0..3), 0, self.midiId);

	// hold args of currently selected node
	MIDIdef.noteOn(\holdargs, {
		~lsengine.hold();
	}, 5, 0, self.midiId);
	MIDIdef.noteOff(\unholdargs, {
		~lsengine.unhold();
	}, 5, 0, self.midiId);

	// select node without starting it via pad
	MIDIdef.noteOn(\selector, {
		~lsengine.selectMode();
		"selecti".postln;
	}, 4, 0, self.midiId);
	MIDIdef.noteOff(\selectorOff, {
		~lsengine.selectMode(false);
		"selectout".postln;
	}, 4, 0, self.midiId);

	/////////////////////////////////// the basic bars on the lower left
	MIDIdef.cc(\barNods, { |val, num|
		var id = num - 6;
		~lsengine.setBarNode(id, val)
	}, (6..9), 0, self.midiId);


	// TODO:
	//	Beautiful synths!!
};


~q.boot;

MIDIFunc.trace(true);
MIDIFunc.trace(false)