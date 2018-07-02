/////////////// MAPPED - 4th col
// stuff that's mapped via processing thingy
// spirals from patz? maybe only as filter?
// spreading rings?
// wandering circles
// horizontal and vertical lines that wander accros the plane
// Artbot-Images

// 4th column, snths 3, 7, 11, 15

(
SynthDef(\light_3, {
	// var in = { |n| In.kr(~lsengine.clrbuses[n], 3) }!~lsengine.clrbuses.size
	// in = in.flatten;
	var ge = EnvGen.kr(Env.asr(0, 1, 0.3), \gate.kr, doneAction: 2);
	var pp = 1 - \p.kr(0).linlin(0, 0.31, 0, 1).lag(1);
	~replaceOutBuses.size.do({ |n|
		var sig = LinSelectX.kr(pp,
			[In.kr(~replaceOutBuses[n], 3) * In.kr(~lsengine.filterBuses[n], 3),
			In.kr(~replaceOutBuses[n], 3)]
		);
		// var sig = In.kr(bus, 3);
		// var sig = In.kr(~lsengine.filterBuses[n], 3);
		// var sig = Silence.kr()!3 + 0.5;
		ReplaceOut.kr(~replaceOutBuses[n], sig);
	});
}).add;

SynthDef(\light_7, {
	var col = Select.kr((\clr0.kr < 1), [
		In.kr(\clr0.kr, 3),
		Hsv2rgb.kr(0, 0, 1)
	]);
	var ge = EnvGen.kr(Env.asr(0, 1, 0.3), \gate.kr, doneAction: 2);
	var pp = 1 - \p.kr(0).linlin(0, 0.31, 0, 1).lag(1);
	~replaceOutBuses.size.do({ |n|
		var sig = LinSelectX.kr(pp,
			[In.kr(~replaceOutBuses[n], 3) * In.kr(~lsengine.filterBuses[n], 3),
			In.kr(~replaceOutBuses[n], 3)]
		);
		ReplaceOut.kr(~replaceOutBuses[n], sig);
	});
}).add;

SynthDef(\light_11, {

}).add;


SynthDef(\light_15, {

}).add;

)