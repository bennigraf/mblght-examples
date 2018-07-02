////////////////// Synths that are controlled via the Bar controllers
// basically basic stuff like stage lighting, 2nd stage, dauer-nebel, etc...



(

// main stage light
SynthDef(\barlight_0, {
	var ge = EnvGen.kr(Env.asr(0, 1, 4.3), \gate.kr, doneAction: 2);
	Patcher.default.busesForGroupMethod(\stage, \dim).do({ |bus, n|
		Out.kr(bus, \val.kr.lag2(3));
	});
}).add;

// blinder lights
SynthDef(\barlight_1, {
	var ge = EnvGen.kr(Env.asr(0, 1, 4.3), \gate.kr, doneAction: 2);
	Patcher.default.busesForGroupMethod(\blinder, \dim).do({ |bus, n|
		Out.kr(bus, \val.kr.lag2(3)).poll;
	});
}).add;

// auto-runs fog machine / benni stin kt
SynthDef(\barlight_2, {
	var ge = EnvGen.kr(Env.asr(0, 1, 0.3), \gate.kr, doneAction: 2);
	Patcher.default.busesForMethod(\fog).do({ |bus|
		Out.kr(bus, (LFPulse.kr(1/3, 0, \val.kr)*\val.kr));
	});
}).add;

// 2nd stage
SynthDef(\barlight_3, {
	var ge = EnvGen.kr(Env.asr(0, 1, 5.3), \gate.kr, doneAction: 2);
	Patcher.default.busesForGroupMethod(\second, \dim).do({ |bus, n|
		Out.kr(bus, \val.kr.lag2(3));
	});
}).add;


)