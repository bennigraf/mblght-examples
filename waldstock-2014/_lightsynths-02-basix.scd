
/////////////// BASIX - 2nd col
// basic effects - stage light, 2nd stage, blinder, strobe, fog
// and some cheap buntes stuff
// (some of it may reside on those 4 faders on the right)

// nooooooooooooooo something else, let's see...

(
// blitziges buntes licht, 1 oder 2 farben
// p: freq of blitzing and brightness
// TODO: Fade between amount of each color in mix/propability of those? maybe with (WhiteNoise.kr > n)?
SynthDef(\light_1, {
	var w = [1, 1, 1] + Silence.kr();
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3), w
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3), w
	]);
	var cols = [col1, col2];
	var dustfreq = \p.kr.lincurve(0, 1, 1, 11, 4).lag2ud(1, 3);
	var nv = EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
	var amp = nv * \p.kr.lag2ud(0.1, 0.4);
	~replaceOutBuses.do({|b, n|
		var trig = Dust.kr(dustfreq);
		var colndx = TIRand.kr(0, (\clr1.kr > 0), trig);
		var col = Select.kr(colndx, cols) * Trig1.kr(trig, 0.03) * amp;
		Out.kr(b, col);
	});
}).add;

SynthDef(\light_5, {

}).add;

// strobo
// waldblitz takes two arguments for method bliitz which are freq and intensity
SynthDef(\light_9, {
	Patcher.default.busesForMethod(\bliitz).do({ |bus|
		Out.kr(bus, [\y.kr, \p.kr]);
	});
	EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
}).add;

// blinder
// p: brightness
// y: add "noise"
SynthDef(\light_13, {
	Patcher.default.busesForGroupMethod(\blinder, \dim).do({ |bus|
		var noise = 1 - (Decay2.kr(Dust.kr(3)) * \y.kr(0));
		Out.kr(bus, \p.kr(0) * noise);
	});
	EnvGen.kr(Env.asr(0, 1, 3), \gate.kr, doneAction: 2);
}).add;
)
