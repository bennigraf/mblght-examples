////////// lalalalala
NetAddr.langPort

(
OSCdef(\test, { |msg|
	// msg.postln;
	n.sendMsg(*msg);

}, '/barData')
)

n = NetAddr.new("192.168.178.33", 5005);
n.sendRaw('/barData');

s.sendMsg("/n_free", 1004)

(
// generates output mapping for pixelcontroller software
24.do({ |i|
	8.do({|j|
		(j * 24 + i).post;
		",".post;
	});
});
)

///////////////////////// pxls test
(
Server.default = Server.internal;
s.options.memSize_(8192 * 64); // 512mb
s.options.numControlBusChannels_(10000);

p = Patcher.new(\grid, {
	var addBars;
	Patcher.all().at(\grid).makeDefault;

	~osc1 = OlaOsc.new(0);
	~osc2 = OlaOsc.new(1);

	~buf = DmxBuffer.new(2);
	~buf.addDevice(~osc1, 0);
	~buf.addDevice(~osc2, 1);
/*
	~gosc1 = GenOsc.new('/dmx/0');
	~gosc2 = GenOsc.new('/dmx/1'); */
	~buf.addDevice(GenOsc.new('/dmx/0'), 0);
	~buf.addDevice(GenOsc.new('/dmx/1'), 1);

	// ~buf.addDevice(OlaOsc.new(2), 0);
	// ~buf.addDevice(OlaOsc.new(3), 1);

	Patcher.default.addBuffer(~buf);
	"booted".postln;

	// adding pxl devices
	addBars = { |barnum|
		var bar = barnum;
		var startaddr = bar * 8 * 3 * 3;
		(8*3).do({|n|
			var addr = startaddr + (n * 3 + 1);
			p.addDevice(Device.new(\smplrgb, addr), \tri);
		});
	};
	[6, 3, 2, 4, 1, 5, 0].do({ |n|
		addBars.value(n);
	});
	// bars unterm schlagzeug
	8.do({ |n|
		var addr = 514 + 100 + (n * 3);
		p.addDevice(Device.new(\smplrgb, addr), \substage);
	});
	8.do({ |n|
		var addr = 514 + 125 + (n * 3);
		p.addDevice(Device.new(\smplrgb, addr), \substage);
	});

	p.addDevice(Device.new(\waldblitz, 513));
	p.addDevice(Device.new(\dim, 522), \blinder);
	p.addDevice(Device.new(\dim, 523), \blinder);
	p.addDevice(Device.new(\dim, 530), \blinder);
	p.addDevice(Device.new(\dim, 531), \blinder);
	p.addDevice(Device.new(\dim, 524), \stage);
	p.addDevice(Device.new(\dim, 525), \stage);
	p.addDevice(Device.new(\dim, 527), \stage);
	p.addDevice(Device.new(\dim, 533), \second);

	p.addDevice(Device.new(\waldpar, 542), \stage);
	p.addDevice(Device.new(\waldpar, 552), \stage);
	p.addDevice(Device.new(\waldpar, 562), \stage);
	p.addDevice(Device.new(\waldpar, 572), \stage);
	p.addDevice(Device.new(\waldpar, 582), \stage);
	p.addDevice(Device.new(\waldpar, 592), \stage);

	p.addDevice(Device.new(\waldfog, 515));

	{10.do({|n|
		// "do".postln;
		p.message((method: \dim, group: \second, data: 1));
		p.message((method: \dim, group: \stage, data: 0.4));
		0.2.wait;
	})}.fork;

})
)


p.message((method: \fog, data: 0));
p.message((method: \color, data: {1.0.rand}!3))
p.message((method: \color, group: \substage, data: [1, 0, 0]))
p.message((method: \color, group: \stage, data: [0, 1, 0.4]))
p.message((method: \dim, group: \stage, data: 0.55))
p.message((method: \dim, group: \blinder, data: 0.1))
p.message((method: \dim, group: \second, data: 0))
p.message((method: \color, group: \tri, data: [1, 0, 1], device: (0..23)+(6*3*8)))

p.message((method: \color, data: [0, 0.2, 1]))
p.message((method: \color, group: \tri, data: [1, 0, 1]))

// bars
// 0: 6
// 1: 4
// 2: 2
// 3: 1
// 4: 3
// 5: 5
// 6: 0
0 * 3 + 1

(
Tdef(\test, {
	inf.do({ |n|
		var dev = (n * 8) % (8*3*7);
		dev = (dev..(dev+7));
		dev.postln;
		p.message((method: \color, data: {1.0.rand}!3, device: dev));
		0.48.wait;
	});
});
)
Tdef(\test).play;
Tdef(\test).stop;

(
// delta!
p.message(( method: \color, data:[0, 0, 0]));
z = ({ |n| n.collect({|i| ((i*8)..(i+1*8-1)) }) }.value([0, 1, 2, 3, 5, 6, 7, 9, 10, 13, 14])).flatten;
p.message((
	method: \color,
	data:[0, 0.9, 1],
	device: z
));
)
z = ({ |n| n.collect({|i| ((i*8)..(i+1*8-1)) }) }.value([0, 2])).flatten
// get delta buses
l = z.collect({ |i| p.busesForMethod(\color)[i] })


(
x.free;
x = SynthDef(\test, {
	var color = SinOsc.kr({0.1.rand}!3 + 0.05, {pi.rand}!3, mul: 0.5, add: 0.5);
	// var mcol = SinOsc.kr({1/(2+3.0.rand)}!3).range(0, 1);
	var mcol = [1, 1, 1];
	p.busesForGroupMethod(\a, \color).do({ |bus, i|
	// l.do({|bus, i|
		Out.kr(bus, (color - (0.013121 * i)).fold(0, 1) * mcol ** 8 * (1 - (Decay.kr(Dust.kr(8.3), 3.1).clip(0, 1).lag2ud(0, 1) * (SinOsc.kr(1/48).range(0.031, 1)**2.4))));
		// Out.kr(bus, (color - (0.1 * i)).fold(0, 1) * Decay.kr(Dust.kr(3.3), 0.3).clip(0, 1) ** 1.3);
		// Out.kr(bus, { SinOsc.kr(1/4, pi * 2 / 192 * i).linlin(-1, 1, 0, 1) ** 3 }!3);
	});
	// testing colors
	// p.busesForGroupMethod(\tri, \color).do({ |bus, i|
	// Out.kr(bus, In.kr(~clr.buses[i%3], 3));
	// });
	p.busesForGroupMethod(\b, \color).do({ |bus, i|
		var c = Hsv2rgb.kr(2/3, 1, 1);
		c = c * Decay.kr(Dust.kr(1), 5.3);
		// Out.kr(bus, c);
	});
	p.busesForGroupMethod(\i, \dim).do({ |b|
		Out.kr(b, LFDNoise3.kr(1/9).range(0.03, 0.383));
	});
}).play;
)


List