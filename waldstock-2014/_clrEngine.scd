

~clrngn = ();

// receives control data from ipad per osc, generates .kr buses with color values
// (3x hsv, "amp" (brightness or value), lag)


~clrngn.buses = List();
~clrngn.snths = List();
~clrngn.oscDefs = List();
~clrngn.responder = nil;

~clrngn.makeBuses = { |self|
	4.do({
		self.buses.add(Bus.control(s, 3));
	});
};

~clrngn.makeSynths = { |self|
	// 3x Hsv2rgb mit parametern von osc
	// + lag + "amp" oder so
	// + "phantom" default color synth/bus TODO
	3.do({ |n|
		var syn;
		syn = {
			var lag = \lag.kr(0).lincurve(0, 1, 0, 14, 3.1);
			var x = \x.kr(0);
			var y = \y.kr(0);
			// x and y are exchanged because the ipad is oriented horzontically
			var h = y; // 0 to 1 for one 'cylce'
			// saturation and value are set from \y.kr in a way that makes the
			// color black at the bottom of the xy control and white on top,
			// in the middle there's maximum saturation/full color
			var s = x.linlin(0.5, 1, 1, 0); // this works because linlin clips by default
			var v = x.linlin(0, 0.5, 0, 1);
			var rgb = Hsv2rgb.kr(VarLag.kr(h, lag), VarLag.kr(s, lag), VarLag.kr(v, lag));
			var laggedvals = [n, VarLag.kr(x, lag), VarLag.kr(y, lag)];
			// SendReply.kr(TDelay.kr(Changed.kr(rgb.sum), 0.1), '/clrReply', laggedvals);
			SendReply.kr(Changed.kr(Latch.kr(rgb.sum, Impulse.kr(12))), '/clrReply', laggedvals);
			Out.kr(self.buses[n], rgb * \amp.kr(0));
			0;
		}.play;
		self.snths.add(syn);
	});
};

~clrngn.makeOscDefs = { |self|
	var rep = OSCFunc({ |msg| // getting values from synths for representatino on ipad
		// msg.postln;
		// [("/color/"++(msg[3]+1)).asSymbol, msg[4], msg[5]].postln;
		var n, x, y;
		n = msg[3];
		x = msg[5].linlin(0, 1, 82, 515);
		if(n == 0, { y = msg[4].linlin(0, 1, 218, 19); });
		if(n == 1, { y = msg[4].linlin(0, 1, 458, 264); });
		if(n == 2, { y = msg[4].linlin(0, 1, 678, 508); });
		self.responder.sendMsg(("/colorresp/"++(n+1)++"/position/x").asSymbol, x);
		self.responder.sendMsg(("/colorresp/"++(n+1)++"/position/y").asSymbol, y);
	}, '/clrReply');
	self.oscDefs.add(rep);
	3.do({ |n|
		var odc = OSCFunc({ |msg| // basic color, push xy to clr-synth
			self.snths[n].set(\x, msg[1], \y, msg[2]);
		}, ("/color/"++(n+1)).asSymbol.postln);
		var oda = OSCFunc({ |msg| // amp for value
			self.snths[n].set(\amp, msg[1]);
		}, ("/coloramp/"++(n+1)).asSymbol);
		var odl = OSCFunc({ |msg| // lag for lag
			self.snths[n].set(\lag, msg[1]);
		}, ("/colorlag/"++(n+1)).asSymbol);
		self.oscDefs.add(odc);
		self.oscDefs.add(oda);
		self.oscDefs.add(odl);
	});

};

~clrngn.boot = { |self|
	self.responder = NetAddr.new("padrick.local", 5001);
	s.waitForBoot({
		self.makeBuses();
		self.makeSynths();
		self.makeOscDefs();
	});

};

~clrngn.boot();

OSCFunc.trace(false);