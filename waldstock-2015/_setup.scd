

(
Server.default = Server.internal;
s.options.memSize_(8192 * 128); // 1gb
s.options.numControlBusChannels_(10000);
s.options.numAudioBusChannels_(10000);
)


"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_sets-engine.scd".load
// -> patcher

"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_quneo-midi.scd".load
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-engine.scd".load
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_bhoreal-midi.scd".load
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_clrEngine.scd".load;
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_oscctrl.scd".load;

"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_busproxys.scd".load;

"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-05-bars.scd".load;
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-01-solids.scd".load;
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-02-basix.scd".load;
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-03-barfx.scd".load;
"/Users/bennigraf/Documents/Hacking/waldstock2015/mblght/_lightsynths-04-kram.scd".load;

(
p = Patcher.new(\waldstock2015, {
	Patcher.all().at(\waldstock2015).makeDefault;

	~osc1 = OlaOsc.new(0);
	~osc2 = OlaOsc.new(1);
	~osc3 = OlaOsc.new(2);
	~osc4 = OlaOsc.new(3);

	~buf = DmxBuffer.new(4);
	~buf.addDevice(~osc1, 0);
	~buf.addDevice(~osc2, 1);
	~buf.addDevice(~osc3, 2);
	~buf.addDevice(~osc4, 3);

	Patcher.default.addBuffer(~buf);
	"booted".postln;

	// p.addDevice(Device.new(\waldblitz, 513));
	// p.addDevice(Device.new(\dim, 522), \blinder);

	/////////////////////////////// UNIVERSE 3
	// Max:
	//// superbars: 16 * rgbw
	// 2x 4 bars als gruppe
	// kanäle 0 bis 511
	(4 * 16).do({ |n|
		p.addDevice(Device.new(\smplrgbw, 1 + (4 * n) + 1024), \a);
	});
	~sets.addGroup((\name: \a, \cols: 4, \rows: 16, \method: \color, \mltply: 1));
	(4 * 16).do({ |n|
		p.addDevice(Device.new(\smplrgbw, 1 + (4 * 16 * 4) + (4 * n) + 1024), \b);
	});
	~sets.addGroup((\name: \b, \cols: 4, \rows: 16, \method: \color, \mltply: 1));

	/////////////////////////////// UNIVERSE 1 (channel 513..1024

	//// LED Moving Wash Lights
	// lightmaxx easy wash quad 7x10: \lmaxxeasywash, 12 channel mode
	// maybe uses 13 channels (see manual), so just to be sure use 13 here...
	6.do({ |n|
		// p.addDevice(Device.new(\lmaxxeasywash, 1 + 512 + (13 * n)), \moving);
	});
	~sets.addGroup((\name: \moving, \cols: 3, \rows: 2, \method: \color, \mltply: 1));

	// Strobo, Dimmer, ... noch
	p.addDevice(Device.new(\waldblitz, 512 + 128), \strobo);
	6.do({|n|
		p.addDevice(Device.new(\dim, 512 + 256 + n), \blinder);
	});
	p.addDevice(Device.new(\dim, 511 + 256 + 7), \stage); // center
	p.addDevice(Device.new(\dim, 511 + 256 + 9), \stage); // left
	p.addDevice(Device.new(\dim, 511 + 256 + 11), \stage); // right

	p.addDevice(Device.new(\dim, 511 + 256 + 8), \second);


	/////////////////////////////// UNIVERSE 0 (channel 1..512)

	//// LDT-Bars: ADJ Ultra - 18 channel mode (6*rgb), 2x4 stk
	(4 * 6).do({ |n|
		p.addDevice(Device.new(\smplrgb, 1 + (3 * n)), \d);
	});
	~sets.addGroup((\name: \d, \cols: 4, \rows: 6, \method: \color, \mltply: 3));
	(4 * 6).do({ |n|
		p.addDevice(Device.new(\smplrgb, 1 + (4 * 6 * 3) + (3 * n)), \e);
	});
	~sets.addGroup((\name: \e, \cols: 4, \rows: 6, \method: \color, \mltply: 3));
	// 1 + 8 * 6 * 3 = 145

	//// LDT-Bars: showtec led light bar 8 - 8 * rgb + dim/strob, 1x4 stk
	(3*8).do({|n|
		p.addDevice(Device.new(\smplrgb, 145 + (3 * n) + ((n/8).floor * 2)), \f);
	});
	3.do({ |n|
		// p.addDevice(Device.new(\showtecLLB8init, 145 + (26 * n)));
		p.addDevice(Device.new(\dim, 145 + (26 * n) + 25), \initshit);
	});
	~sets.addGroup((\name: \f, \cols: 4, \rows: 8, \method: \color, \mltply: 3));
	(4*8).do({|n|
		p.addDevice(Device.new(\smplrgb, 223 + (3 * n) + ((n/8).floor * 2)), \g);
	});
	4.do({ |n|
		p.addDevice(Device.new(\dim, 223 + (26 * n) + 25), \initshit);
	});
	~sets.addGroup((\name: \g, \cols: 4, \rows: 8, \method: \color, \mltply: 3));


	//// Blinder Bars (4 x 10ch) (reingeschummelt)
	(4*10).do({|n|
		p.addDevice(Device.new(\dim, 350 + n), \i);
	});
	~sets.addGroup((\name: \i, \cols: 4, \rows: 10, \method: \dim, \mltply: 1));



	// Hazer
	p.addDevice(Device.new(\dim, 500), \haze);
	p.addDevice(Device.new(\dim, 501), \haze);
	// bubbles
	p.addDevice(Device.new(\dim, 502), \bubblz);

	// fog second stage
	p.addDevice(Device.new(\dim, 498), \fogsecond);


	{
		1.wait;
		p.message((method:\dim, data: [1], group: \initshit));

		// p.message((method: \color, data: [0.5, 0.5, 0.15] * 0.5));
		// p.message((method: \color, data: [1, 0, 0] * 0.3));
		p.message((method: \pos, data: [0.5, 0.5]));
		p.message((method: \dim, data: [0.7], group: \stage));
		// p.message((method: \dim, data: [0]));

	}.fork;

})
)

p.message((method: \color, data: [1, 0, 0] * 0.1))
p.message((method: \pos, data: [0.3, 0.1]))
p.message((method: \pos, data: [0.52, 0.021], \group: \moving, device: [0, 1, 2]))
p.message((method: \color, data: [0, 0.5, 1], \group: \moving, device: [0, 1, 2]))
p.message((method: \dim, data: [0.3], group: \i));

p.message((method: \dim, data: [0.55], group: \stage));
p.message((method: \dim, data: [0.8], group: \second));
p.message((method: \dim, data: [0.8], group: \stage));
p.message((method: \dim, data: [0], group: \blinder));

p.message((method: \dim, data: [0], group: \haze, device: 0)); // pump
p.message((method: \dim, data: [0], group: \haze, device: 1)); // fan
p.message((method: \dim, data: [1], group: \bubblz));
p.busesForGroupMethod(\haze, \dim)

p.message((method: \dim, data: [0], group: \fogsecond));


p.message((method: \blitz, data: [0]))
p.message((method:\dim, data: [1], group: \initshit))



p.message((method: \pos, data: [0.5, 0]))
p.message((method: \pos, data: [0.5, 0.5]))


p.message((method: \dim, data: [0.5], group: \stage));
p.message((method: \dim, data: [0.5], group: \stage, device: [0]));
p.message((method: \dim, data: [0.55], group: \stage, device: [1, 2]));

p.message((method: \dim, data: [0.01], group: \blinder));


p.message((method: \pos, data: [0.515, 0.021], \group: \moving, device: [0, 1, 2]))
p.message((method: \color, data: [0.5, 0.5, 0.5]/5, \group: \moving, device: [0, 1, 2]))
p.message((method: \color, data: [0, 0.3, 0.4] * 0.8, \group: \moving, device: [1]))
p.message((method: \color, data: [0, 0, 0], \group: \moving, device: [2]))


p.message((method: \color, data: 1!3, \group: \moving));
p.message((method: \color, data: [0, 0, 0], \group: \moving));

s.queryAllNodes
s.sendMsg('/n_free', 1001)
OSCdef.trace(false)


s.queryAllNodes


(
Tdef(\maul, {
	inf.do({
		20.do({
			p.message((method: \dim, data: [1], group: \fogsecond));
			0.05.wait;
		});
		(0.1 + 1.8.rand).wait;
		20.do({
			p.message((method: \dim, data: [0], group: \fogsecond));
			0.05.wait;
		});
		(4.1 + 5.2.rand).wait;
	});
});
Tdef(\maul).play
)





(
x.free;
x = SynthDef(\test, {
	var color = SinOsc.kr({0.0041.rand}!3 + 0.05, {pi.rand}!3, mul: 0.5, add: 0.5);
	// var mcol = SinOsc.kr({1/(2+3.0.rand)}!3).range(0, 1);
	var mcol = [1, 1, 1];

	var buses = p.busesForGroupMethod(\a, \color) ++ p.busesForGroupMethod(\b, \color) ++ p.busesForGroupMethod(\d, \color) ++ p.busesForGroupMethod(\e, \color) ++ p.busesForGroupMethod(\f, \color) ++ p.busesForGroupMethod(\g, \color);

	buses.do({ |bus, i|
	// l.do({|bus, i|
		var s = (color - (0.013121 * i)).fold(0, 1) * mcol ** 0.5 * (1 - (Decay.kr(Dust.kr(18.3), 3.1).clip(0, 1).lag2ud(0, 1) * (SinOsc.kr(1/48).range(0.51, 1)**1.1)));
		var mod = (1 - (LagUD.kr(Trig1.kr(Dust.kr(3)), 0.05, 1) * SinOsc.kr(1/66, (pi/4).rand, 0.5, 0.5)));
		Out.kr(bus, s * \amp.kr(1).lag(3) * mod);
	});

	p.busesForGroupMethod(\i, \dim).do({ |bus, i|
		var s = SinOsc.kr(0.1.rand + 0.05, pi.rand, mul: 0.5, add: 0.5);
		Out.kr(bus, (s - (0.013121 * i)).fold(0, 1) ** 2 * (1 - (Decay.kr(Dust.kr(18.3), 3.1).clip(0, 1).lag2ud(0, 1) * (SinOsc.kr(1/48).range(0.51, 1)**1.4))) * 0.97 * \amp.kr(1).lag(3));
	});

}).play;
)