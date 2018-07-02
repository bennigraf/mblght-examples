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
	Out.kr(Patcher.default.busesForGroupMethod(\haze, \dim)[0], 5/255);
	Out.kr(Patcher.default.busesForGroupMethod(\haze, \dim)[1], \val.kr.linlin(0, 1, 0, 0.5));
}).add;

// 2nd stage
SynthDef(\barlight_3, {
	var ge = EnvGen.kr(Env.asr(0, 1, 5.3), \gate.kr, doneAction: 2);
	Patcher.default.busesForGroupMethod(\second, \dim).do({ |bus, n|
		Out.kr(bus, \val.kr.lag2(3));
	});
}).add;


)