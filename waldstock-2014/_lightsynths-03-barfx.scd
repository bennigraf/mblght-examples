/////////////// BARFX - 3rd col
// make effects which handle bars individually bzw. in groups of 3
// i.e. treat them as 8 big par lamps that, like, do stuff
// or do patterns on bars which repeat on those bars

// 3rd column

(
// 3-packs oszilating
SynthDef(\light_2, {
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);
	var cols = [col1, col2] * \p.kr;
	var numCols = ((\clr0.kr>0) + (\clr1.kr>0) - 1).clip(0, 1); // mode -1 and 0 behave the same...
	var numBars = Patcher.default.busesForGroupMethod(\tri, \color).size / 8;
	var numTris = (numBars / 3).floor;
	var speed = \y.kr.linlin(0, 1, 1/9, 3);
	numTris.do({ |n|
		var ph = LinSelectX.kr(\x.kr, [0, LFDNoise3.kr(1/7) * pi]);
		var o = SinOsc.kr(speed, ph, 0.5, 0.5);
		var t = Trig1.kr(o < 0.01, 0.01);
		var c = Select.kr(TIRand.kr(0, numCols, t), cols);
		var sig = c * o;
		(8*3).do({ |i|
			Out.kr(~replaceOutBuses[n * 3 * 8 + i], sig);
		});
	});
	EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
}).add;

SynthDef(\light_6, {

	EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
}).add;


// dinger laufen auf bar hin und her
// y: speed
// x: breite
SynthDef(\light_10, {
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	// var col2 = Select.kr((\clr1.kr < 1), [
	// 	In.kr(\clr1.kr, 3),
	// 	[0, 0, 0]
	// ]);
	var amp = \p.kr.lag(0.5).lag2ud(0.1, 1.3);
	var numBars = Patcher.default.busesForGroupMethod(\tri, \color).size / 8;
	var numTris = (numBars / 3).floor;
	var bars = 0!8!numBars;
	var buses = Patcher.default.busesForGroupMethod(\tri, \color);

	var spd = \y.kr.linlin(0, 1, 4.5, 0.3);
	var width = \x.kr.linlin(0, 1, 1, 7);
	numBars.do({ |n|
		bars[n] = PanAz.kr(8, amp, SinOsc.kr((0.1 + 0.3.rand)/spd).range(0, 2), 1, width);
	});
	bars.size.postln;
	~replaceOutBuses.do({ |bus, n|
		var i = (n / 8).floor;
		var j = (n % 8);
		if(n < 168, {
			Out.kr(bus, bars[i][j] * col1);
		});
	});
	EnvGen.kr(Env.asr(0, 1, 2), \gate.kr, doneAction: 2);
}).add;
)
// strobo über dreiecke
// y: speed
// x: decay
SynthDef(\light_14, {
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);
	var cols = [col1, col2] * \p.kr.lag2(2);
	var numCols = ((\clr0.kr>0) + (\clr1.kr>0) - 1).clip(0, 1); // mode -1 and 0 behave the same...
	var trigSpeed = \y.kr.linlin(0, 1, 1, 14);
	var decay = \x.kr.linlin(0, 1, 3.98, 1/3);
	var numBars = Patcher.default.busesForGroupMethod(\tri, \color).size / 8;
	var numTris = (numBars / 3).floor;
	var oBar = TIRand.kr(0, numTris - 1, Impulse.kr(trigSpeed));
	var trigs = { |n| (Impulse.kr(trigSpeed) * (1-(oBar > n)) * (1-(oBar < n)))}!numTris;
	// Trig1.kr(trigs.poll, 1);
	// [numBars, numTris, trigs.size].postln;
	numTris.do({ |n|
		var c = Select.kr(TIRand.kr(0, numCols, trigs[n]), cols);
		var sig = c * Decay.kr(trigs[n], decay).clip(0, 1);
		(8*3).do({ |i|
			Out.kr(~replaceOutBuses[n * 3 * 8 + i], sig);
		});
	});
	EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
}).add;
)
