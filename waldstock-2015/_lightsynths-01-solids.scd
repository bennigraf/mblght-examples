/////////////// SOLIDS - 1st col - solid colors of some sort

(
// farbiges licht
// mit keiner farbe: random
// mit einer farbe: ebendiese
// mit zwei farben: Verläufe bar außen - mitte - außen
SynthDef(\light_0, {
	// var clr = In.kr(\clr0.kr, 3);
	var amp = \p.kr.lag(0.5).lag2ud(0.1, 2.3);
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);
	var mode = ((\clr0.kr>0) + (\clr1.kr>0) - 1).clip(0, 1); // mode -1 and 0 behave the same...

	~sets.groups.do({ |grp, n|
		// Patcher.default.busesForGroupMethod(grp.name, \color).do({|bus, i|
		~proxybus.giveMeSomeBuses(grp.name, \color).do({ |bus, i|
			var ndxamp = (i % 8 / 8 * pi).sin ** 2; // 0..1..0
			var sig = Select.kr(mode, [
				col1,
				(col1 * (1-ndxamp)) + (col2 * ndxamp)
			]);
			sig = sig * amp * ("groupgate_"++grp.name).asSymbol.kr(1, 1);
			// sig = sig * amp;
			Out.kr(bus, sig);
		});
	});

	EnvGen.kr(Env.asr(0, 1, 3), \gate.kr, doneAction: 2);
}).add;


// unruhige farbe
// x: unruhefaktor
// TODO: 2nd color, evtl wie light_1?
SynthDef(\light_4, {
	var amp = \p.kr.lag(0.5).lag2ud(0.1, 0.3);
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var dustfreq = \p.kr.lincurve(0, 1, 1, 6.3, 4).lag2ud(1, 3);

	~sets.groups.do({ |grp, n|
		// Patcher.default.busesForGroupMethod(grp.name, \color).do({|bus, i|
		var buses = ~proxybus.giveMeSomeBuses(grp.name, \color);
		if(grp.method == \dim, {
			buses = Patcher.default.busesForGroupMethod(grp.name, \dim);
		});
		buses.do({ |bus, i|
			var mod = Trig1.kr(Dust.kr(dustfreq), 1/40).lag2ud(0.3, 0.31);
			var asig = LinSelectX.kr(\x.kr, [col1, col1 * mod]);
			if(grp.method == \dim, {
				asig = asig.sum;
			});
			Out.kr(bus, asig * amp * ("groupgate_"++grp.name).asSymbol.kr(1,1));
		});
	});

	EnvGen.kr(Env.asr(0, 1, 2), \gate.kr, doneAction: 2);
}).add;


// 2 colors slowly fading sinusoidal and moving along the line
// controls:
// * obviously amp
// * \x: speed (and direction) of movement
// * \y?: width of sines (how many pxls one wave spans)
// * \arg0: width of gap (blacks between lights, ctrld by exp)
// TODO: smooth out span a whole bunch!
SynthDef(\light_8, {
	var col1 = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(Dust.kr(1/9.3).lag2(12), Dust.kr(1/13).lag2(12) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		Silence.kr()!3
	]);
	var amp = VarLag.kr(\p.kr(0), 0.3);
	var mov = \x.kr(0.5).linlin(0, 1, -1, 1) ** 1.3;
	var span = \y.kr(0).lincurve(0, 1, 1, 39, 6).lag(8);
	var gap = \arg0.kr(0).lincurve(0, 1, 1, 18, 5.5);

	~sets.groups.do({ |grp, n|
		var num = Patcher.default.busesForGroupMethod(grp.name, \color).size();
		// Patcher.default.busesForGroupMethod(grp.name, \color).do({|bus, i|
		~proxybus.giveMeSomeBuses(grp.name, \color).do({ |bus, i|
			var sig1 = col1 * SinOsc.kr(mov, (2pi / num * n * span).wrap(0, 2pi)).linlin(-1, 1, 0, 1) ** gap;
			var sig2 = col2 * SinOsc.kr(mov, (2pi / num * n * span).wrap(0, 2pi)).linlin(-1, 1, 1, 0) ** gap;
			Out.kr(bus, (sig1 + sig2) * amp * ("groupgate_"++grp.name).asSymbol.kr(1, 1));
		});
	});

	EnvGen.kr(Env.asr(0, 1, 1), \gate.kr, doneAction: 2);
}).add;

// standard sine-based plasma thingy, very colorful
// x: speed
// y: pointy-ness
SynthDef(\light_12, {
	var color = SinOsc.kr({0.1.rand}!3 + 0.0003 + \x.kr.linlin(0, 1, 0, 0.14), {Rand(0, pi)}!3, mul: 0.5, add: 0.5);

	~sets.groups.do({ |grp, n|
		var num = Patcher.default.busesForGroupMethod(grp.name, \color).size();
		// Patcher.default.busesForGroupMethod(grp.name, \color).do({|bus, i|
		var buses = ~proxybus.giveMeSomeBuses(grp.name, \color);
		if(grp.method == \dim, {
			buses = Patcher.default.busesForGroupMethod(grp.name, \dim);
		});
		buses.do({ |bus, i|
			var sig = (color - (0.013121 * i)).fold(0, 1) ** \y.kr(0).lincurve(0, 1, 1, 33, 6) * \p.kr.lag(1, 6);
			// color compressor
			sig = sig ** (sig.sum.linlin(2.5, 3, 1, 5));
			sig = sig.clip(0, 1);
			if(grp.method == \dim, {
				sig = sig.sum / 4;
			});
			Out.kr(bus, sig * ("groupgate_"++grp.name).asSymbol.kr(1, 1));
		});
	});

	EnvGen.kr(Env.asr(0, 1, 3), \gate.kr, doneAction: 2);
}).add;

)
/*
(
~lsengine.on(0)
~lsengine.cc(0, \p, 100)
~lsengine.cc(8, \p, 1)
~lsengine.cc(8, \y, 122)
~lsengine.cc(0, \x, 90)
~lsengine.setArg(0, 110)
~lsengine.off(0)
~lsengine.colorToggle(1)

~clrngn.snths[1].set(\amp, 1)
~clrngn.snths[1].set(\x, 0.51)
~clrngn.snths[1].set(\y, 0.5)
)
*/

/*
s.queryAllNodes
(
~masterGroup.isNil.if({
	~masterGroup = Group.new(s, \addToTail);
});
~supermastersynth.free;
~supermastersynth = {
	// var sigs = Patcher.default.busesForMethod(\color).collect({ |bus|
	var sigs = ~replaceOutBuses.collect({ |bus|
		In.kr(bus, 3);
	});

	sigs = sigs.clip(0, 1);
	// sigs = sigs;

	Patcher.default.busesForMethod(\color).do({ |bus, n|
		ReplaceOut.kr(bus, sigs[n]);
	});
	0;
}.play(~masterGroup, addAction: \addToTail);
);
 */

/*
s.freeAll;
s.sendMsg("/n_free", 1043)

*/