OSCdef.trace(false)

(
~xx = 0.5;
~yy = 0.5;
OSCdef(\acc, { |msg|
	// msg.postln;
	// old shabby iphone sends acceleration in values 0..1
	// msg[1] = msg[1] * 10;
	// msg[2] = msg[2] * 10;

	~xx = msg[2].linlin(-5, 5, 1, 0);
	~yy = msg[1].linlin(-5, 5, 1, 0);
	x.set(\xx, ~xx);
	x.set(\yy, ~yy);
}, '/accxyz')

)
OSCdef(\acc).free
OSCdef.freeAll




// lamp position for testing
~lx = 1/8 * 6 / 2; // same distance as ~ly when mapped to stage
~ly = 0.5;

// target position on stage
// 0/0 is left back (left/top from above)
// ~tx = 0;
// ~ty = 0;


// stage dimensions to scale correctly (angle depends on ratio between height and width/depth)
~sh = 4; // 4m high
~sw = 8; // 8m wide
~sd = 6; // 6m deep


// lamp positions for 6 light setup
// x, y, dirtyhacktoggle
// the dirty hack is used to allow optimized positioning of the lamps
// with the "front" (aka center of rotation axis) points backwards
// (default is pointing front). Therefore, the position of the lamp is
// "mirrored" to the other side of the stage and the target position
// values are inversed, too.

(
~lamps = [
/*	[2.5, 6],
	[3.25, 6],
	[4, 6],*/


	[5.5, 0, 1],
	[4.75, 0, 1],
	[4, 0, 1],
	[5.5, 0, 0],
	[6.25, 0, 0],
	[7, 0, 0]

/*
	[1, 4, 0],
	[1.5, 4, 0],
	[2, 4, 0],
	[2, 4, 1],
	[1.5, 4, 1],
	[1, 4, 1]
	*/
];
// scale to 0..1
~lamps = ~lamps.collect({|l| l / [~sw, ~sd, 1]});
)

// a) rotation angle
// * calculate difference between target point and lamp position
// * calculate angle in that triangle
// * calculate vorzeichen of angle depending on offset
// * scale to lamp data (usually 540 degrees rotation...)

// b) tilt angle
// * calculate distance between target and lamp (pythagoras...)
// * use triangle lamp/target/point on stage below lamp to get angle
(
x.free;
x = {
	// mouse control
	var mx, my, tx, ty;

	// this stuff is for the rotation
	var dx, dy, rot;
	var lh, lv, rv, rh; // vorzeichen-checker

	// this stuff is for the tilt
	var distance, distx, disty;
	var tilt;


	// mx = MouseX.kr(0, 1);
	// my = MouseY.kr(0, 1);
	mx = \xx.kr(0.5, 0.63);
	my = \yy.kr(0.5, 0.63);

	// limit values to 95% of area
	mx = mx.max(0.05).min(0.95);
	my = my.max(0.05).min(0.95);

	mx = LPF.kr(mx, 2);
	my = LPF.kr(my, 2);

	// tx = 1 - tx;
	// ty = 1 - ty;

	// do all this for each lamp position defined above
	~lamps.do({ |l, n|

		// hack to allow optimized lamp positioning, see above for details
		// (basically invert target positions here...).
		tx = (l[2] - mx).abs;
		ty = (l[2] - my).abs;

		///////////////// ROTATION (um die hochachse)

		// difference
		dx = (l[0] - tx).abs;
		dy = (l[1] - ty).abs;

		// scale to real world
		dx = dx * ~sw;
		dy = dy * ~sd;

		// tan alpha = gegenkathete / ankathete
		rot = (dx / dy).atan;
		// ang to deg, weil's leichter zu rechnen ist in meinem kopf
		rot = rot / pi * 180;

		// position target relativ zur lampe
		// lh/lv/rv/rh ist 1 wenn wahr
		// (links hinten, links vorne, ...)
		lh = ((l[0] - tx) > 0) & ((l[1] - ty) > 0);
		lv = ((l[0] - tx) > 0) & ((l[1] - ty) < 0);
		rv = ((l[0] - tx) < 0) & ((l[1] - ty) < 0);
		rh = ((l[0] - tx) < 0) & ((l[1] - ty) > 0);

		// berechne winkel entsprechend. wenn bspw. lh = 0 entspricht
		// die zeile für lh 'ang = ang'.
		// geht bestimmt auch einfacher, but well...
		rot = (1 - lh * rot) + (lh * (90 + (90-rot)));
		rot = (1 - lv * rot) + (lv * rot);
		rot = (1 - rv * rot) + (rv * (rot * -1));
		rot = (1 - rh * rot) + (rh * (90 + (90 - rot)) * -1);

		//////////////// NEIGEN (um die querachse)

		// get distance the pythagorean way
		distx = (l[0] * ~sw) - (tx * ~sw);
		disty = (l[1] * ~sd) - (ty * ~sd);
		distance = (distx.squared + disty.squared).sqrt;

		// get tilt: tan(tilt) = distance/height
		tilt = (distance / ~sh).atan;
		// to deg
		tilt = tilt / pi * 180;


		// [rot, tilt].poll;
		//////////////// scale stuff and output
		// rot: map full rotation angles to lighting values (0..1)
		rot = rot.linlin(-270, 270, 0, 1);

		// assume fixture gets 0.5..1 for movement between straight down to
		// all the way up (which is 265/2deg for the \platWashZFXProBasicMode)
		// tilt is an actual angle (0..x deg)
		// map accordingly!

		// supercheapo-thingys: 0..1 is -90..+90
		tilt = tilt.linlin(-90, 90, 1, 0);

		Out.kr(p.busesForMethod(\pos)[n], [rot, tilt]);
		// Out.kr(p.busesForMethod(\color)[n], [0, mx, 1-my]);

	});

	0;
}.play
);







