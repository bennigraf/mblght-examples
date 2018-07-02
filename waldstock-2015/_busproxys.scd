



// Proxybusses
// audio-busse für jeden farb-bus, weil die sich sonst doof mischen

~proxybus = ();

~proxybus.groups = [\a, \b, \d, \e, \f, \g];

~proxybus.makeBuses = { |self|

	var replaceOutBuses;
	if(self.bus.notNil, {
		self.clrbuses.do({|b| b.free; });
		self.bus.do({|g|
			g.do({|b| b.free });
		});
	});

	self.bus = ();

	self.groups.do({ |g|
		var replaceOutBuses = Patcher.default.busesForGroupMethod(g, \color).collect({ |bus, i|
			Bus.control(s, bus.numChannels());
		});
		self.bus[g] = (\color: replaceOutBuses);
	});

};
// ~proxybus.giveMeSomeBuses(grp.name, \color).do({


~proxybus.giveMeSomeBuses = { |self, group, method|
	var buses = [ ];
	if(self.bus[group].notNil, {
		if(self.bus[group][method].notNil, {
			buses = self.bus[group][method];
		});
	});
	buses;
};
~proxybus.makePlayer = { |self|
	if(self.player.notNil, {
		self.player.free;
		self.player = nil;
	});
	self.player = {
		~sets.groups.do({ |grp, n|
			var outBuses = Patcher.default.busesForGroupMethod(grp.name, \color);
			var mltply = grp.mltply;
			mltply.isNil.if({ mltply = 1 });
			~proxybus.giveMeSomeBuses(grp.name, \color).do({ |bus, i|
				Out.kr(outBuses[i], (In.kr(bus, 3) * mltply).clip(0, 1));
			});
		});
		0;
	}.play;
};

~proxybus.boot = { |self|
	~proxybus.makeBuses();
	~proxybus.makePlayer();
};

~proxybus.boot();

// ~sets.groups[7]
// ~sets.groups[7][\mltply] = 0.3
// 4.do({|n|~sets.groups[2+n][\mltply] = 4})


