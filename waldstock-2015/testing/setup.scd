

Server.default = Server.internal;
s.options.memSize_(8192 * 64); // 512mb
s.options.numControlBusChannels_(10000);


(
p = Patcher.new(\test, {
	var addBars;
	Patcher.all().at(\test).makeDefault;

	~osc1 = OlaOsc.new(0);
	~osc2 = OlaOsc.new(1);
	~osc3 = OlaOsc.new(2);
	~osc4 = OlaOsc.new(3);

	~buf = DmxBuffer.new(4);
	~buf.addDevice(~osc1, 0);
	~buf.addDevice(~osc2, 1);
	~buf.addDevice(~osc3, 2);
	~buf.addDevice(~osc4, 3);
/*
	~gosc1 = GenOsc.new('/dmx/0');
	~gosc2 = GenOsc.new('/dmx/1'); */
	// ~buf.addDevice(GenOsc.new('/dmx/0'), 0);
	// ~buf.addDevice(GenOsc.new('/dmx/1'), 1);

	// ~buf.addDevice(OlaOsc.new(2), 0);
	// ~buf.addDevice(OlaOsc.new(3), 1);

	Patcher.default.addBuffer(~buf);
	"booted".postln;

	// p.addDevice(Device.new(\waldblitz, 513));
	// p.addDevice(Device.new(\dim, 522), \blinder);

	// 6.do({ |n|
		// p.addDevice(Device.new(\platWashZFXProBasicMode, 1 + (20 * n)));
		// p.addDevice(Device.new(\platWashZFXProBasicMode, 1 + (20 * n)), \test);
	// });
	// p.devices

	/////////////////////////////// UNIVERSE 0
	// Max:
	//// superbars: 16 * rgbw
	// 2x 4 bars als gruppe
	// kanäle 0 bis 511
	(4 * 16).do({ |n|
		p.addDevice(Device.new(\smplrgbw, 1 + (4 * n)), \a);
	});
	(4 * 16).do({ |n|
		p.addDevice(Device.new(\smplrgbw, 1 + (4 * 16 * 4) + (4 * n)), \b);
	});

	/////////////////////////////// UNIVERSE 1 (channel 512..1023
	//// mini-pars in 4er-Gruppen (4x4 'matrix' wenn's geht)
	// same as \waldfuck (master, r, g, b, makro, strobe)
	(4*4).do({ |n|
		p.addDevice(Device.new(\waldfuck, 1 + 512 + (6 * n)), \c);
	});
	// 4*4*6+512 = 608 (which is the new starting channel)

	//// LED Moving Wash Lights
	// lightmaxx easy wash quad 7x10: \lmaxxeasywash, 12 channel mode
	// maybe uses 13 channels (see manual), so just to be sure use 13 here...
	6.do({ |n|
		p.addDevice(Device.new(\lmaxxeasywash, 1 + 608 + (13 * n)), \moving);
	});
	// 608 + 6 * 13 = 686

	//// LDT-Bars: ADJ Ultra - 18 channel mode (6*rgb), 2x4 stk
	(4 * 6).do({ |n|
		p.addDevice(Device.new(\smplrgb, 1 + 686 + (3 * n)), \d);
	});
	(4 * 6).do({ |n|
		p.addDevice(Device.new(\smplrgb, 1 + 686 + 4 * 6 * 3 + (3 * n)), \e);
	});
	// 686 + 8 * 6 * 3 = 830

	//// LDT-Bars: showtec led light bar 8 - 8 * rgb + dim/strob, 3x4 stk
	(4*8).do({|n|
		p.addDevice(Device.new(\smplrgb, 1 + 830 + (3 * n)), \f);
	});
	// 830+4*8*3 = 926
	(4*8).do({|n|
		p.addDevice(Device.new(\smplrgb, 1 + 926 + (3 * n)), \g);
	});
	// 926 + 4*8*3 = 1022!
	/////////////////////////////// UNIVERSE 2 (channel 1024..1536)
	(4*8).do({|n|
		p.addDevice(Device.new(\smplrgb, 1 + 1024 + (3 * n)), \h);
	});
	// 1024 + 4*8*3 = 1120

	//// Blinder Bars (4 x 10ch)
	(4*10).do({|n|
		p.addDevice(Device.new(\dim, 1 + 1120 + n), \i);
	});


/*	{10.do({|n|
		// "do".postln;
		p.message((method: \dim, group: \second, data: 1));
		p.message((method: \dim, group: \stage, data: 0.4));
		0.2.wait;
	})}.fork;*/

	{
		1.wait;
		p.message((method: \color, data: [1, 0, 0]))
	}.fork;

})
)
Patcher
p.message((method: \color, data: [1, 1, 1]))
p.message((method: \pos, data: [0.5, 0.35]))



