/////////////// MAPPED - 4th col
// einzelne Bars blinken lassen
// gruppen zusammen blinken lassen

// irgendwas für sunstripe

// 4th column, snths 3, 7, 11, 15

(
// einzelne Bars blinken lassen
SynthDef(\light_3, {
	var ge = EnvGen.kr(Env.asr(0, 1, 2.3), \gate.kr, doneAction: 2);

	var amp = \p.kr.lag(0.5).lag2ud(0.1, 0.6);
	var col = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);

	~sets.groups.do({ |grp, n|
		var buses = ~proxybus.giveMeSomeBuses(grp.name, \color);
		if(grp.method == \dim, {
			buses = Patcher.default.busesForGroupMethod(grp.name, \dim);
		});
		// grp.rows
		grp.cols.do({ |n|
			var sig = 0;
			sig = EnvGen.kr(Env.asr(0, 1, 0.25, 4), Dust.kr(\y.kr.linlin(0, 1, 2, 12)));
			sig = sig * amp * ("groupgate_"++grp.name).asSymbol.kr(1, 1);
			if(grp.method == \color, {
				sig = sig * col;
			});

			grp.rows.do({ |m|
				buses[m + (n * grp.rows)].notNil.if({
					Out.kr(buses[m + (n * grp.rows)], sig);
				});
			});
		});
	});
}).add;

SynthDef(\light_7, {
	var ge = EnvGen.kr(Env.asr(0, 1, 2.3), \gate.kr, doneAction: 2);

	var amp = \p.kr.lag(0.5).lag2ud(0.1, 0.6);
	var col = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);

	~sets.groups.do({ |grp, n|
		var buses = ~proxybus.giveMeSomeBuses(grp.name, \color);
		// grp.rows
		var sig = 0;
		if(grp.method == \dim, {
			buses = Patcher.default.busesForGroupMethod(grp.name, \dim);
		});
		sig = EnvGen.kr(Env.asr(1/15, 1, \x.kr.linlin(0, 1, 0.1, 0.3), 4), Trig1.kr(Dust.kr(\y.kr.linlin(0, 1, 2, 12))));
		sig = sig * amp * ("groupgate_"++grp.name).asSymbol.kr(1, 1);
		if(grp.method == \color, {
			sig = sig * col;
		});

		grp.cols.do({ |n|
			grp.rows.do({ |m|
				buses[m + (n * grp.rows)].notNil.if({
					Out.kr(buses[m + (n * grp.rows)], sig);
				});
			});
		});
	});
}).add;


// lauflichter über die bars
SynthDef(\light_11, {
	var ge = EnvGen.kr(Env.asr(0, 1, 2.3), \gate.kr, doneAction: 2);

	var amp = \p.kr.lag(0.5).lag2ud(0.1, 0.6);
	var col = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(LFDNoise1.kr(1/18.3), LFDNoise1.kr(1/13) / 5 + 0.8, 1);
	]);
	var col2 = Select.kr((\clr1.kr < 1), [
		In.kr(\clr1.kr, 3),
		[0, 0, 0]
	]);

	~sets.groups.do({ |grp, n|
		var buses;
		var sig = 1;

		if(grp.method == \color, {
			buses = ~proxybus.giveMeSomeBuses(grp.name, \color);
		});
		if(grp.method == \dim, {
			buses = Patcher.default.busesForGroupMethod(grp.name, \dim);
		});

		amp = amp * ("groupgate_"++grp.name).asSymbol.kr(1, 1);

		grp.cols.do({ |n|
			sig = EnvGen.kr(Env.asr(1/15, 1, \x.kr.linlin(0, 1, 0.1, 0.3), 4), Trig1.kr(Dust.kr(\y.kr.linlin(0, 1, 0.5, 2))));
			grp.rows.do({ |m|
				sig = DelayL.kr(sig, 0.2, 0.1) * amp;

				buses[m + (n * grp.rows)].notNil.if({
					if(grp.method == \color, {
						sig = sig * col;
					}, {
							// sig = sig;
					});
					Out.kr(buses[m + (n * grp.rows)], sig);
				});
			});
		});
	});

}).add;


SynthDef(\light_15, {
	var ge = EnvGen.kr(Env.asr(0, 1, 2.3), \gate.kr, doneAction: 2);

}).add;

)