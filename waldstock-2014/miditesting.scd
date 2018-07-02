
MIDIClient.init;
MIDIIn.connectAll

(
// lpd8?
~l_xxx = -1101621857; // probably...
try({
	MIDIIn.connectByUID(0, ~l_xxx); // LPD8
	~l_mout = MIDIOut.newByName("LPD8", "LPD8").latency_(0);
}, {
	"Could not connect to LPD!".error;
});
)

(
// quneo
MIDIIn.findPort("QUNEO", "QUNEO")
(
MIDIdef.cc(\test, { |...args|
	// args.postln;
}, nil, nil, nil);
MIDIdef.noteOn(\test2, { |...args|
	args.postln;
}, nil, nil, 1341032007);
)


MIDIdef.cc(\test4, {arg ...args; args.postln}); // match any noteOn
