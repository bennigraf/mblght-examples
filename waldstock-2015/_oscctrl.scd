(
OSCdef.new(\center, { |msg|
	p.message((method: \dim, data: [msg[1]], group: \stage, device: [0]));
}, '/1/fader1');
OSCdef.new(\sides, { |msg|
	p.message((method: \dim, data: [msg[1]], group: \stage, device: [1, 2]));
}, '/1/fader2');
OSCdef.new(\blinder, { |msg|
	p.message((method: \dim, data: [msg[1]], group: \blinder));
}, '/1/fader3');
OSCdef.new(\something, { |msg|
	x.set(\amp, msg[1]);
}, '/1/fader4');
OSCdef.new(\level, { |msg|
	var v = (msg[1] ** 1.5);
	6.do({|n|
		var val = v.linlin(1/6 * n, 1/6 * (n+1), 0, 1);
		// p.message((method: \dim, data: [v]/2.2, group: \blinder, \device: [n]));
	});
}, '/1/fader5');
OSCdef(\bubblz, { |msg|
	p.message((method: \dim, data: [msg[1]], group: \bubblz));
}, '/1/toggle1');
OSCdef(\secondstagefog, { |msg|
	p.message((method: \dim, data: [msg[1]], group: \fogsecond));
}, '/1/toggle2');
)