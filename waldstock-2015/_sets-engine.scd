

// SETS!
/*

> Store 'combos' of lighting fixtures as sets which act as a single fixture
> When a set is selected (bhoreal or lpd), the lsengine sends the fx only to the specific set
> each set has a .free function to clear all running nodes on this set (in combination with lsengine)
> That's basically it!


 */

~sets = ();

// contains basically combinations of groups of devices
~sets.sets = ();

// contains groups with additional data (x/y, name for actual patcher group)
~sets.groups = List();

// check server options stuff
// ServerOptions

// define: groups/sets (max 8 or so?), define pixels, implement "mapping" for each output group in each synthdef with an own "gate", define on startup of synth via sets engine


/*
a b  // superdinger
d e  // mitteldinger
f g  // billig
i    // sunstripes
moving // movings...
*/

(
~sets.sets[\all] = (
	\button: 0,
	\groups: [\a, \b, \d, \e, \f, \g, \i, \moving]
);
~sets.sets[\back] = (
	\button: 1,
	\groups: [\a, \b]
);
~sets.sets[\dach] = (
	\button: 2,
	\groups: [\d, \e, \f, \g, \i, \moving]
);
~sets.sets[\dachohnemoving] = (
	\button: 3,
	\groups: [\d, \e, \f, \g, \i]
);
~sets.sets[\gutebars] = (
	\button: 4,
	\groups: [\d, \e]
);
~sets.sets[\doofebars] = (
	\button: 5,
	\groups: [\f, \g]
);
~sets.sets[\sunstripe] = (
	\button: 6,
	\groups: [\i]
);
~sets.sets[\wackler] = (
	\button: 7,
	\groups: [\moving]
);
~sets.sets[\dachundbackohnewackler] = (
	\button: 8,
	\groups: [\a, \b, \d, \e, \f, \g, \i]
)
);



~sets.addGroup = { |self, grp|
	self.groups.add(grp);
};

~sets.setSynthGroupGates = { |self, synth|
	self.groups.do({|group, i|
		synth.set("groupgate_"++group.name, 0);
	});
	self.sets[self.activeSet][\groups].do({|group, i|
		synth.set("groupgate_"++group, 1);
	});
};

~sets.setActiveSet = { |self, set, update|
	self.activeSet = set;
	set.postln;
	if(update.notNil, {
		var syn;
		syn = ~lsengine.getCurrentSynth();
		if(syn.notNil, {
			self.setSynthGroupGates(syn);
		});
	});
};

// triggered by midi (bhoreal...)
~sets.setByBtn = { |self, num|
	// first col sets with update, second col only selects (for next interaction)
	// ...and so on
	var btnnum = nil;
	if((num/8).floor%2 == 0, {
		// ~sets.setActiveSet()
		btnnum = ((num/16).floor * 8 + (num%16));
		~sets.setActiveSet(~sets.findSetByBtn(btnnum), true);
	}, {
		btnnum = ((num/16).floor * 8 + (num%16) - 8);
		~sets.setActiveSet(~sets.findSetByBtn(btnnum));
	});
};
~sets.findSetByBtn = { |self, num|
	var setname = nil;
	~sets.sets.keysValuesDo({ |key, val, n|
		if(val.button == num, {
			setname = key;
		});
	});
	setname;
}





