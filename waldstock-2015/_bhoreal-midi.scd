~b = ();


~b.midiId = 1259519671; // the bhoreal, otherwise known as "USB-MIDI-Gerät"
~b.srcId = 1293721814; // not really sure which one counts...

~b.boot = { |self|

	// try to connect to bhoreal, throws error if it doesn't find it
	if(MIDIClient.sources.isNil, {
		// init MIDIClient
		MIDIClient.init;
		try({
			var destid = nil;

			// use all inputs...
			MIDIIn.connectAll();

			// now find output port
			MIDIClient.destinations.do({|d, i|
				if(d.uid == self.midiId, {
					destid = i;
				});
			});
			destid.notNil.if({
				self.out = MIDIOut(destid).latency_(0);
			});
		}, {
			"Could not connect to bhoreal!".error;
		});
	}, {
		var destid = nil;
		"MIDI already connected...".postln;
		MIDIClient.destinations.do({|d, i|
			if(d.uid == self.midiId, {
				destid = i;
			});
		});
		destid.notNil.if({
			self.out = MIDIOut(destid).latency_(0);
		}, {
			"No bhoreal found, maybe reconnect?".postln;
		});
	});

	self.makeMidiDefs();
};

~b.makeMidiDefs = { |self|
	MIDIdef.noteOn(\btns, { |val, num|
		// convert button numbers to make the connector the top left position and count downwards
		// from there...
		num = ((num / 8).floor * 8 + (7 - (num % 8)));
		// send to sets
		~sets.setByBtn(num);
		self.activateBtn(num);
	}, nil, 0, self.srcId);
};

~b.clearBtns = { |self|
	64.do({ |i| self.out.noteOff(0, i, 0); });
};
~b.enableBtn = { |self, num|
	num = (num/8).floor * 8 + (7-(num%8));
	self.out.noteOn(0, num, 67);
};
~b.updateBtns = { |self|
	self.clearBtns();
	~sets.sets.do({ |set|
		var n = (set.button % 8) + ((set.button / 8).floor * 16);
		self.enableBtn(n);
		self.enableBtn(n + 8);
	});
};
~b.activateBtn = { |self, num|
	self.updateBtns();
	num = (num/8).floor * 8 + (7-(num%8));
	self.out.noteOn(0, num, 25);
};


~b.boot();

/*
~b.clearBtns()
~b.enableBtn(15)
~b.updateBtns()

~b.makeMidiDefs()


*/