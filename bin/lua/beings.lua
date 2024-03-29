function DoomRL.loadnpcs()

	register_being "former"
	{
		name         = "former human",
		ascii        = "h",
		color        = LIGHTGRAY,
		sprite       = SPRITE_FORMER,
		todam        = -1,
		tohit        = -4,
		speed        = 90,
		min_lev      = 0,
		max_lev      = 12,
		corpse       = true,
		danger       = 1,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Former soldiers that have been corrupted and overtaken by demonic influence, leaving an empty, merciless, violent husk. Don't let their familiar faces decieve you, hesitation will only give them a better chance to kill you. Putting them down is their only way out.",

		OnCreate = function (self)
			self.eq.weapon = "pistol"
			self.inv:add( "ammo" )
		end
	}

	register_being "sergeant"
	{
		name         = "former sergeant",
		ascii        = "h",
		color        = DARKGRAY,
		sprite       = SPRITE_SERGEANT,
		todam        = -1,
		tohit        = -2,
		speed        = 70,
		min_lev      = 2,
		max_lev      = 15,
		corpse       = true,
		danger       = 2,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Former humans like the rest, these posessed soldiers are shotgun-toting sergeants. The nastiness and propensity for violence required to climb the UAC's ranks have made these bastards noticeably tougher and nastier.",
		kill_desc       = "was shot by a former sergeant",
		kill_desc_melee = "was beaten by a former sergeant",

		OnCreate = function (self)
			self.eq.weapon = "shotgun"
			self.inv:add( "shell", { ammo = 30 } )
		end
	}

	register_being "captain"
	{
		name         = "former captain",
		ascii        = "h",
		color        = LIGHTRED,
		sprite       = SPRITE_CAPTAIN,
		speed        = 80,
		min_lev      = 5,
		max_lev      = 15,
		corpse       = true,
		danger       = 3,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Posessed commanding officers of the UAC ranks, these former marines were among the deadliest of the human troops, ready to give orders and dish out indiscriminate violence at a moment's notice. Little has changed with their demonic corruption, and they remain eager to shred anything in range.",
		kill_desc       = "was shredded by a former captain",
		kill_desc_melee = "was beaten by a former captain",

		OnCreate = function (self)
			self.eq.weapon = "chaingun"
			self.inv:add( "ammo", { ammo = 100 } )
		end
	}

	register_being "imp"
	{
		name         = "imp",
		ascii        = "i",
		color        = BROWN,
		sprite       = SPRITE_IMP,
		hp           = 12,
		attackchance = 40,
		todam        = 2,
		tohit        = 3,
		speed        = 105,
		min_lev      = 0,
		max_lev      = 17,
		corpse       = true,
		danger       = 2,
		weight       = 8,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "melee_ranged_ai",

		resist = { fire = 25 },

		desc            = "Common humanoid monsters from Hell itself. These leather-skinned beasts can conjure balls of fire, and pitch them like fastballs. Up close, they easily slash their prey to ribbons with razor-sharp claws. Sturdy, fast, and dangerous, but easy to outwit.",
		kill_desc       = "was scorched by an imp",
		kill_desc_melee = "was clawed by an imp",

		weapon = {
			damage     = "2d5",
			damagetype = DAMAGE_FIRE,
			radius     = 1,
			missile = {
				sound_id   = "imp",
				ascii      = "*",
				color      = LIGHTRED,
				sprite     = SPRITE_FIREBALL,
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 5,
				expl_delay = 40,
				expl_color = RED,
			},
		},
	}

	register_being "demon"
	{
		name         = "demon",
		ascii        = "c",
		color        = LIGHTMAGENTA,
		sprite       = SPRITE_DEMON,
		hp           = 25,
		armor        = 2,
		todam        = 5,
		tohit        = 3,
		speed        = 130,
		vision       = -2,
		min_lev      = 4,
		max_lev      = 20,
		corpse       = true,
		danger       = 4,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "demon_ai",

		desc            = "Massive, deadly creatures native to Hell. These monsters are as fast as they are vicious, and if you're close enough to see their eyes, it's already bitten your torso off.",
		kill_desc_melee = "was devoured by a demon",
	}

	register_being "lostsoul"
	{
		name         = "lost soul",
		ascii        = "s",
		color        = YELLOW,
		sprite       = SPRITE_LOSTSOUL,
		attackchance = 60,
		todam        = 4,
		tohit        = 12,
		speed        = 100,
		vision       = 0,
		min_lev      = 6,
		max_lev      = 16,
		danger       = 3,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_ENVIROSAFE },
		ai_type      = "lostsoul_ai",

		resist = { fire = 75, bullet = 50 },

		desc            = "Lost Souls are the miserable, wandering spirits of those condemned to Hell without a body of their own. They eagerly fling themselves towards threats, seeking to either find a body to posess, or death. Shattering them like clay pidgeons is equal parts self-defense and mercy.",
		kill_desc_melee = "was overwhelmed by a lost soul",
	}

	register_being "cacodemon"
	{
		name         = "cacodemon",
		ascii        = "O",
		color        = RED,
		sprite       = SPRITE_CACODEMON,
		hp           = 40,
		armor        = 1,
		attackchance = 40,
		todam        = 6,
		tohit        = 4,
		min_lev      = 10,
		max_lev      = 50,
		corpse       = true,
		danger       = 6,
		weight       = 6,
		flags        = { BF_ENVIROSAFE },
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "Massive, fleshy, one-eyed flying monstrosities. They can hurl balls of plasma at their targets, or take massive bites out of anything unlucky enough to get close. One of Hell's nastiest creatures, their bizarre appearance is not to be underestimated.",
		kill_desc       = "was immolated by a cacodemon",
		kill_desc_melee = "was devoured by a cacodemon",

		weapon = {
			damage     = "2d6",
			damagetype = DAMAGE_PLASMA,
			radius     = 1,
			missile = {
				sound_id   = "cacodemon",
				ascii      = "*",
				color      = LIGHTMAGENTA,
				sprite     = SPRITE_PLASMABALL,
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 4,
				expl_delay = 40,
				expl_color = MAGENTA,
			},
		},
	}

	register_being "knight"
	{
		name         = "hell knight",
		ascii        = "B",
		color        = BROWN,
		sprite       = SPRITE_KNIGHT,
		hp           = 50,
		armor        = 1,
		attackchance = 40,
		todam        = 6,
		tohit        = 6,
		speed        = 110,
		min_lev      = 9,
		max_lev      = 15,
		corpse       = true,
		danger       = 6,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "baron_ai",

		resist = { acid = 50 },

		desc            = "Towering humanoid monstrosities, these intimidating beasts command the frontlines of the forces of Hell. They can conjure and pitch balls of plasma, and are more than capable of beating anything in reach to a pulp.",
		kill_desc       = "was immolated by a hell knight",
		kill_desc_melee = "was crushed by a hell knight",

		weapon = {
			damage     = "2d6",
			damagetype = DAMAGE_PLASMA,
			radius     = 1,
			missile = {
				sound_id   = "knight",
				ascii      = "*",
				color      = LIGHTMAGENTA,
				sprite     = SPRITE_ACIDSHOT,
				coscolor   = { 1.0, 0.0, 1.0, 1.0 },
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 5,
				expl_delay = 40,
				expl_color = MAGENTA,
			},
		},
	}

	register_being "baron"
	{
		name         = "baron of hell",
		name_plural  = "barons of hell",
		ascii        = "B",
		color        = LIGHTMAGENTA,
		sprite       = SPRITE_BARON,
		hp           = 60,
		armor        = 2,
		attackchance = 40,
		todam        = 8,
		tohit        = 5,
		min_lev      = 12,
		corpse       = true,
		danger       = 10,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "baron_ai",

		resist = { acid = 50 },

		desc            = "Among the highest ranks of Hell's armies, the Barons are a force to be reckoned with. Despite their positions as commanders of the cannon fodder, they are as deadly a foe as you're likely to find. Their highly acidic projectiles could melt plasteel, and their strength is more than enough to tear you in half.",
		kill_desc       = "was melted by a baron of hell",
		kill_desc_melee = "was eviscerated by a baron of hell",

		weapon = {
			damage     = "4d5",
			damagetype = DAMAGE_ACID,
			radius     = 2,
			missile = {
				sound_id   = "baron",
				ascii      = "*",
				color      = LIGHTGREEN,
				sprite     = SPRITE_ACIDSHOT,
				coscolor   = { 0.0, 1.0, 0.0, 1.0 },
				delay      = 35,
				miss_base  = 50,
				miss_dist  = 3,
				expl_delay = 40,
				expl_color = GREEN,
			},
		},
	}

	register_being "arachno"
	{
		name         = "arachnotron",
		ascii        = "A",
		color        = YELLOW,
		sprite       = SPRITE_ARACHNO,
		hp           = 50,
		armor        = 2,
		attackchance = 60,
		todam        = 2,
		tohit        = 3,
		speed        = 130,
		min_lev      = 13,
		max_lev      = 50,
		corpse       = true,
		danger       = 9,
		weight       = 4,
		bulk         = 100,
		ai_type      = "ranged_ai",

		resist = { melee = -100 },

		desc            = "A fleshy, brain-like monstrosity made mobile and dangerous by a four-legged frame. The plasma repeater mounted to its metal chassis is as fast as it is powerful, ready to fill a room with superheated projectiles. Thankfully, that brain is mighty vulernable to an up-close beating.",
		kill_desc       = "was blasted by an arachnotron",

		weapon = {
			damage     = "1d5",
			damagetype = DAMAGE_PLASMA,
			shots      = 5,
			missile = {
				sound_id   = "arachno",
				ascii      = "*",
				color      = MULTIYELLOW,
				sprite     = SPRITE_PLASMASHOT,
				delay      = 7,
				miss_base  = 20,
				miss_dist  = 4,
			},
		},

		OnCreate = function (self)
			self.inv:add( item.new("cell") )
		end
	}

	register_being "commando"
	{
		name         = "former commando",
		ascii        = "h",
		color        = LIGHTBLUE,
		sprite       = SPRITE_COMMANDO,
		hp           = 20,
		armor        = 2,
		todam        = 2,
		tohit        = 1,
		min_lev      = 12,
		max_lev      = 17,
		corpse       = true,
		danger       = 7,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "The UAC's most dangerous, bloodthirsty, unfeeling soldiers have barely changed in their demonic posession. Their plasma weaponry, advanced armor, and ruthless lust for killing makes them one of Hell's most brutal fighters.",
		kill_desc       = "was immolated by a former commando",
		kill_desc_melee = "was beaten by a former commando",

		OnCreate = function (self)
			self.eq.weapon = "plasma"
		end
	}

	register_being "pain"
	{
		name         = "pain elemental",
		ascii        = "O",
		color        = BROWN,
		sprite       = SPRITE_PAIN,
		hp           = 40,
		armor        = 1,
		todam        = 6,
		tohit        = 2,
		min_lev      = 10,
		max_lev      = 20,
		danger       = 6,
		weight       = 4,
		bulk         = 100,
		flags        = { BF_ENVIROSAFE },
		ai_type      = "spawnonly_ai",

		desc            = "One of Hell's cruelest monsters, these creatures trap Lost Souls within them to feed off their torment. But, the pain of the living is far more enticing, and they will weaponize the Souls trapped within to get it.",

		OnDie = function (self,overkill)
			if not overkill then
				for c=1,3 do self:spawn("lostsoul") end
			end
		end,
	}

	register_being "revenant"
	{
		name         = "revenant",
		ascii        = "R",
		color        = WHITE,
		sprite       = SPRITE_REVENANT,
		hp           = 30,
		armor        = 2,
		attackchance = 50,
		todam        = 6,
		tohit        = 4,
		speed        = 120,
		min_lev      = 13,
		corpse       = true,
		danger       = 12,
		weight       = 5,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "ranged_ai",

		resist = { fire = 25, bullet = 50 },

		desc            = "A horrifyingly disfigured human body, augmented and weaponized by God knows what. The rocket launchers on their shoulders can blast anything unlucky enough to get in the way. And, in spite of their frail appearence, they pack a significant punch up close. Put these bastards down, and hope you don't see them again.",
		kill_desc       = "was blown to bits by a revenant",
		kill_desc_melee = "was beaten by a revenant",

		weapon = {
			damage     = "5d5",
			damagetype = DAMAGE_FIRE,
			radius     = 1,
			missile = {
				sound_id   = "bazooka",
				color      = YELLOW,
				sprite     = SPRITE_ROCKETSHOT,
				delay      = 30,
				miss_base  = 30,
				miss_dist  = 6,
				flags = { MF_EXACT },
				expl_delay = 40,
				expl_color = RED,
			},
		},

		OnCreate = function (self)
			self.inv:add( "rocket" )
		end
	}

	register_being "mancubus"
	{
		name         = "mancubus",
		name_plural  = "mancubi",
		ascii        = "M",
		color        = BROWN,
		sprite       = SPRITE_MANCUBUS,
		hp           = 60,
		armor        = 2,
		attackchance = 50,
		todam        = 8,
		tohit        = 3,
		speed        = 80,
		min_lev      = 15,
		corpse       = true,
		danger       = 12,
		weight       = 7,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "sequential_ai",

		desc            = "An enourmous mass of flesh, these hulking monstrosities have had a pair of massive rocket launchers mounted where you're pretty sure arms should go. While they're an obvious threat at a distance, those hunks of steel can smash whatever gets too close.",
		kill_desc       = "was blasted to bits by a mancubus",
		kill_desc_melee = "was smashed by a mancubus",

		weapon = {
			damage     = "4d6",
			damagetype = DAMAGE_FIRE,
			radius     = 2,
			flags      = { IF_SPREAD },
			missile = {
				sound_id   = "mancubus",
				ascii      = "*",
				color      = LIGHTRED,
				sprite     = SPRITE_ROCKETSHOT,
				delay      = 20,
				miss_base  = 1,
				miss_dist  = 3,
				expl_delay = 40,
				expl_color = RED,
			},
		},

		OnCreate = function (self)
			self.inv:add( "rocket" )
		end
	}

	register_being "arch"
	{
		name         = "arch-vile",
		ascii        = "V",
		color        = YELLOW,
		sprite       = SPRITE_ARCHVILE,
		todam        = 6,
		hp           = 70,
		armor        = 2,
		attackchance = 50,
		tohit        = 2,
		speed        = 160,
		min_lev      = 16,
		corpse       = "corpse",
		danger       = 14,
		weight       = 4,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_SELFIMMUNE },
		ai_type      = "archvile_ai",

		desc            = "A being from Hell far more powerful than anything you have seen before. Using unknowable forces, it can set you ablaze from afar, and even bring your foes back from the dead. They're the biggest problems you can run into, and considering the stiff competition, that's saying a lot.",
		kill_desc       = "was cremated by an arch-vile",

		weapon = {
			damage     = "20d1",
			damagetype = DAMAGE_FIRE,
			radius     = 1,
			flags      = { IF_AUTOHIT },
			missile = {
				sound_id   = "arch",
				color      = YELLOW,
				sprite     = 0,
				delay      = 0,
				miss_base  = 10,
				miss_dist  = 10,
				hitdesc    = "You are engulfed in flames!",
				flags      = { MF_EXACT, MF_IMMIDATE },
				expl_delay = 50,
				expl_color = YELLOW,
				expl_flags = { EFNOKNOCK, EFSELFSAFE },
			},
		},
	}

	 -- NIGHTMARE LEVEL MONSTERS --

	register_being "nimp"
	{
		name         = "nightmare imp",
		ascii        = "i",
		color        = LIGHTBLUE,
		sprite       = SPRITE_IMP,
		overlay      = { 0.2, 0.2, 1.0, 0.8 },
		hp           = 35,
		attackchance = 50,
		todam        = 4,
		tohit        = 4,
		speed        = 115,
		min_lev      = 30,
		max_lev      = 60,
		corpse       = true,
		danger       = 6,
		weight       = 8,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "melee_ranged_ai",

		resist = { fire = 50 },

		desc            = "Imps like you've never seen, they can hurl more powerful projectiles, and take a hell of a lot more punishment to bring down.",
		kill_desc       = "was immolated by a nightmare imp",
		kill_desc_melee = "was slashed to ribbons by a nightmare imp",

		weapon = {
			damage     = "2d6",
			damagetype = DAMAGE_PLASMA,
			radius     = 1,
			missile = {
				sound_id   = "imp",
				ascii      = "*",
				color      = LIGHTMAGENTA,
				sprite     = SPRITE_FIREBALL,
				delay      = 15,
				miss_base  = 30,
				miss_dist  = 4,
				expl_delay = 40,
				expl_color = MAGENTA,
			},
		}
	}

	register_being "ncacodemon"
	{
		name         = "nightmare cacodemon",
		ascii        = "O",
		color        = LIGHTBLUE,
		sprite       = SPRITE_CACODEMON,
		overlay      = { 0.2, 0.2, 1.0, 0.8 },
		hp           = 80,
		armor        = 2,
		attackchance = 50,
		todam        = 8,
		tohit        = 6,
		speed        = 120,
		min_lev      = 51,
		corpse       = true,
		danger       = 10,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_ENVIROSAFE },
		ai_type      = "ranged_ai",

		desc            = "Those nightmarish meatballs seem to be getting rougher, tougher, and a Hell of a lot meaner.",
		kill_desc       = "was immolated by a nightmare cacodemon",
		kill_desc_melee = "was devoured by a nightmare cacodemon",

		weapon = {
			damage     = "2d7",
			damagetype = DAMAGE_PLASMA,
			radius     = 1,
			missile = {
				sound_id   = "cacodemon",
				ascii      = "*",
				color      = LIGHTMAGENTA,
				sprite     = SPRITE_PLASMABALL,
				delay      = 30,
				miss_base  = 30,
				miss_dist  = 4,
				expl_delay = 40,
				expl_color = MAGENTA,
			},
		},
	}

	register_being "ndemon"
	{
		name         = "nightmare demon",
		ascii        = "c",
		color        = LIGHTBLUE,
		sprite       = SPRITE_DEMON,
		overlay      = { 0.2, 0.2, 1.0, 0.8 },
		hp           = 80,
		armor        = 3,
		todam        = 10,
		tohit        = 5,
		speed        = 140,
		min_lev      = 40,
		corpse       = true,
		danger       = 7,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "demon_ai",

		desc            = "Just when you thought those pink monsters were getting manageable, now they hit like TWO trucks.",
		kill_desc_melee = "was devoured by a nightmare demon",

	}

	register_being "narachno"
	{
		name         = "nightmare arachnotron",
		ascii        = "A",
		color        = LIGHTBLUE,
		sprite       = SPRITE_ARACHNO,
		overlay      = { 0.2, 0.2, 1.0, 0.8 },
		hp           = 80,
		armor        = 2 ,
		attackchance = 60,
		todam        = 3,
		tohit        = 4,
		speed        = 150,
		min_lev      = 50,
		corpse       = true,
		danger       = 12,
		weight       = 4,
		bulk         = 100,
		ai_type      = "sequential_ai",

		desc            = "Those spider monsters were bad enough already, but now they're even more like those things you saw during that bad LSD trip you tried to forget.",
		kill_desc       = "was blasted by a nightmare arachnotron",

		weapon = {
			damage     = "1d6",
			damagetype = DAMAGE_PLASMA,
			shots      = 6,
			missile = {
				sound_id   = "arachno",
				ascii      = "*",
				color      = LIGHTBLUE,
				sprite     = SPRITE_PLASMASHOT,
				delay      = 10,
				miss_base  = 20,
				miss_dist  = 4,
			},
		},

		OnCreate = function (self)
			self.inv:add( "cell", { ammo = 20 } )
		end
	}

	register_being "narch"
	{
		name         = "nightmare arch-vile",
		ascii        = "V",
		color        = LIGHTBLUE,
		sprite       = SPRITE_ARCHVILE,
		overlay      = { 0.2, 0.2, 1.0, 0.8 },
		hp           = 150,
		armor        = 3,
		attackchance = 60,
		todam        = 8,
		tohit        = 4,
		speed        = 180,
		min_lev      = 90,
		corpse       = "corpse",
		danger       = 20,
		weight       = 3,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_SELFIMMUNE },
		ai_type      = "archvile_ai",

		desc            = "Hell's mightiest magic-wielding, dead-raising, flame-casting monsters are even tougher than before. Might as well kiss your ass goodbye.",
		kill_desc       = "was cremated nightmare arch-vile",

		weapon = {
			damage     = "25d1",
			damagetype = DAMAGE_FIRE,
			radius     = 1,
			flags      = { IF_AUTOHIT },
			missile = {
				sound_id   = "arch",
				color      = LIGHTBLUE,
				sprite     = 0,
				delay      = 0,
				miss_base  = 10,
				miss_dist  = 10,
				hitdesc    = "You are engulfed in flames!",
				flags      = { MF_EXACT, MF_IMMIDATE },
				expl_delay = 50,
				expl_color = BLUE,
				expl_flags = { EFNOKNOCK, EFSELFSAFE },
			},
		},

	}

	register_being "eformer"
	{
		name         = "elite former human",
		sound_id     = "former",
		ascii        = "h",
		color        = BROWN,
		sprite       = SPRITE_FORMER,
		glow         = { 0.0, 0.0, 1.0, 1.0 },
		todam        = 1,
		tohit        = -2,
		speed        = 100,
		hp           = 20,
		armor        = 2,
		min_lev      = 40,
		max_lev      = 80,
		corpse       = false,
		danger       = 7,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc         = "Elite infantry entrusted with powerful, high-tech weapons. Unfortunately, these weapons were designed to never fall into enemy hands, and due to recent events, that means you.",
		-- Added to make sure we use the right article
		kill_desc       = "was shot by an elite former human",
		kill_desc_melee = "was beaten by an elite former human",

		OnCreate = function (self)
			self.eq.weapon = "ucpistol"
			self.eq.weapon.flags[ IF_NODROP ] = true
			self.eq.armor = "garmor"
			self.inv:add( "ammo", { ammo = 48 } )
			self.inv:add( "ammo" )
		end
	}

	register_being "esergeant"
	{
		name         = "elite former sergeant",
		sound_id     = "sergeant",
		ascii        = "h",
		color        = YELLOW,
		sprite       = SPRITE_SERGEANT,
		glow         = { 0.0, 0.0, 1.0, 1.0 },
		todam        = 1,
		speed        = 100,
		hp           = 25,
		armor        = 2,
		min_lev      = 60,
		max_lev      = 90,
		corpse       = false,
		danger       = 10,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Particularly ruthless former sergeants, trained for and entrusted with experimental weaponry. Unfortunately, these weapons were designed to never fall into enemy hands, and due to recent events, that means you.",
		kill_desc       = "was shot by an elite sergeant",
		kill_desc_melee = "was beaten by an elite sergeant",

		OnCreate = function (self)
			local wpammo = table.random_pick{
				{"upshotgun", "cell"},
				{"udshotgun", "shell"},
				{"uashotgun", "shell"}
			}
			self.eq.weapon = wpammo[1]
			self.inv:add( wpammo[2], { ammo = 60 } )
			self.eq.weapon.flags[ IF_NODROP ] = true
			self.eq.armor = "garmor"
		end
	}

	register_being "ecaptain"
	{
		name         = "elite former captain",
		sound_id     = "captain",
		ascii        = "h",
		color        = LIGHTMAGENTA,
		sprite       = SPRITE_CAPTAIN,
		glow         = { 0.0, 0.0, 1.0, 1.0 },
		tohit        = 1,
		speed        = 90,
		hp           = 25,
		armor        = 2,
		min_lev      = 70,
		corpse       = false,
		danger       = 12,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Among the commanding officers of the UAC's ranks were those deemed exemplary, and trusted with the shiniest, deadliest variants to their chainguns the UAC weapons development department had to offer. Unfortunately, these weapons were designed to never fall into enemy hands, and due to recent events, that means you.",
		kill_desc       = "was shredded by an elite captain",
		kill_desc_melee = "was beaten by an elite captain",

		OnCreate = function (self)
			local wpammo = table.random_pick{
				{"uminigun", "ammo", 200 },
				{"ulaser",  "cell", 50 },
			}
			self.eq.weapon = wpammo[1]
			self.inv:add( wpammo[2], { ammo = wpammo[3] } )
			self.eq.weapon.flags[ IF_NODROP ] = true
			self.eq.armor = "barmor"
		end
	}

	register_being "ecommando"
	{
		name         = "elite former commando",
		sound_id     = "commando",
		ascii        = "h",
		color        = LIGHTCYAN,
		sprite       = SPRITE_COMMANDO,
		glow         = { 0.0, 0.0, 1.0, 1.0 },
		hp           = 40,
		armor        = 3,
		todam        = 3,
		tohit        = 3,
		min_lev      = 80,
		corpse       = false,
		danger       = 14,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_ENVIROSAFE },
		ai_type      = "former_ai",

		desc            = "Among the commandos, the elites were the strongest of the strong, brutalest of the brutal, deadliest of the deadly, and toughest of the tough. Given the best kit the UAC had to offer to further push their killing power, they are the worst former humans you can run into. Unfortunately, these weapons were designed to never fall into enemy hands, and due to recent events, that means you.",
		kill_desc       = "was obliterated by an elite commando",
		kill_desc_melee = "was beaten by an elite commando",

		OnCreate = function (self)
			local wpammo = table.random_pick{
				{"utristar",  "cell", 60 },
				{"umbazooka", "rocket", 20 },
				{"unapalm",  "rocket", 12 },
			}
			self.eq.weapon = wpammo[1]
			self.inv:add( wpammo[2], { ammo = wpammo[3] } )
			self.eq.weapon.flags[ IF_NODROP ] = true
			self.eq.armor = "barmor"
		end
	}

	  -- SPECIAL MONSTERS --

	register_being "bruiser"
	{
		name         = "bruiser brother",
		name_plural  = "bruiser brothers",
		ascii        = "B",
		color        = LIGHTRED,
		sprite       = SPRITE_BRUISER,
		hp           = 60,
		armor        = 2,
		attackchance = 40,
		todam        = 8,
		tohit        = 5,
		min_lev      = 50,
		corpse       = true,
		danger       = 14,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_ENVIROSAFE, BF_HUNTING},
		ai_type      = "baron_ai",

		resist = { acid = 50 },

		desc            = "A pair of Hell's mightiest Barons, they work together like matches and lighter fluid. Split your focus between the two, and you might just be able to dodge their balls of acid.",
		kill_desc       = "was melted by a bruiser brother",
		kill_desc_melee = "was flattened by a bruiser brother",

		weapon = {
			damage     = "4d5",
			damagetype = DAMAGE_ACID,
			radius     = 2,
			missile = {
				sound_id   = "baron",
				ascii      = "*",
				color      = LIGHTGREEN,
				sprite     = SPRITE_ACIDSHOT,
				coscolor   = { 0.0, 1.0, 0.0, 1.0 },
				delay      = 35,
				miss_base  = 40,
				miss_dist  = 3,
				expl_delay = 40,
				expl_color = GREEN,
			},
		},

		OnCreate = function (self)
	 		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax
		end
	}

	register_being "shambler"
	{
		name         = "shambler",
		name_plural  = "shamblers",
		ascii        = "B",
		color        = WHITE,
		sprite       = SPRITE_SHAMBLER,
		hp           = 80,
		armor        = 3,
		attackchance = 75,
		todam        = 8,
		tohit        = 4,
		min_lev      = 80,
		corpse       = true,
		danger       = 14,
		weight       = 3,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_ENVIROSAFE, BF_HUNTING },
		ai_type      = "teleboss_ai",

		desc            = "REWRITE TODO  Even other monsters fear him, so expect a clobbering. He shrugs off explosions. Good luck.",
		kill_desc       = "was electrocuted by a shambler",
		kill_desc_melee = "was consumed by a shambler",

		weapon = {
			damage     = "4d5",
			damagetype = DAMAGE_PLASMA,
			missile = {
				sound_id  = "baron",
				color     = WHITE,
				sprite    = SPRITE_SHOT,
				delay     = 35,
				miss_base = 10,
				miss_dist = 3,
				flags     = { MF_RAY },
			},
		},

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 5
			self.hp = self.hpmax
			self:add_property("telechance",6)
			self:add_property("teleradius",8)
		end,

		OnAction = function (self)
			if not core.is_playing() then return end
			if self.hp < self.hpmax then
				self.hp = self.hp + 1
			end
			--old explosion was LIGHTBLUE
			if math.random(10) == 1 then
				self:play_sound{"shambler.act","baron.act"}
			end
		end,

		OnDie = function (self)
			self:play_sound{"shambler.die","arachno.die"}
		end,
	}

	register_being "lava_elemental"
	{
		name         = "lava elemental",
		name_plural  = "lava elemental",
		ascii        = "E",
		color        = YELLOW,
		sprite       = SPRITE_LAVAELEM,
		--overlay      = { 0.4, 0.4, 1.0 },
		hp           = 80,
		armor        = 5,
		attackchance = 30,
		todam        = 8,
		tohit        = 4,
		min_lev      = 70,
		danger       = 16,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_ENVIROSAFE },
		ai_type      = "teleboss_ai",

		resist = { fire = 100 },

		desc            = "REWRITE TODO  Big ball of fire...",
		kill_desc       = "was burned by a lava elemental",
		kill_desc_melee = "was burned by a lava elemental",

		weapon = {
			damage     = "5d4",
			damagetype = DAMAGE_FIRE,
			radius     = 2,
			missile = {
				sound_id   = "cacodemon",
				ascii      = "*",
				color      = LIGHTRED,
				sprite     = SPRITE_EXPLOSION,
				delay      = 50,
				miss_base  = 30,
				miss_dist  = 4,
				flags      = { MF_EXACT },
				expl_delay = 40,
				expl_color = RED,
				expl_flags = { EFRANDOMCONTENT },
				content    = "lava",
			},
		},

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 5
			self.hp = self.hpmax
			self:add_property("telechance",20)
			self:add_property("teleradius",5)
		end,

		OnAction = function (self)
			if not core.is_playing() then return end
			if self.hp < self.hpmax then
				self.hp = self.hp + 1
			end
			--old explosion was RED
		end,

		OnDie = function (self)
			self:play_sound{"lava_elemental.die","arch.die"}
		end,
	}

	register_being "agony"
	{
		name         = "agony elemental",
		ascii        = "O",
		color        = LIGHTMAGENTA,
		sprite       = SPRITE_AGONY,
		hp           = 150,
		armor        = 4,
		todam        = 6,
		tohit        = 2,
		min_lev      = 80,
		danger       = 20,
		weight       = 1,
		bulk         = 100,
		flags        = { BF_ENVIROSAFE },
		ai_type      = "spawnonly_ai",

		desc            = "REWRITE TODO  Seems like the pain elementals' big momma!",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 5
			self.hp = self.hpmax
			self:add_property("spawnchance",4)
			--sets up what can spawn: each have equal probability
			self:add_property("spawnlist",{
				{name = "lostsoul", amt = 3},
				{name = "pain",     amt = 1},
			})
		end,

		OnDie = function (self,overkill)
			if not overkill then
				for c=1,2 do self:spawn("pain") end
				for c=1,6 do self:spawn("lostsoul") end
			end
		end,
	}

	register_being "angel"
	{
		name         = "Angel of Death",
		name_plural  = "Angels of Death",
		ascii        = "A",
		color        = RED,
		sprite       = SPRITE_ANGEL,
		hp           = 250,
		armor        = 10,
		todam        = 15,
		tohit        = 8,
		speed        = 150,
		min_lev      = 200,
		danger       = 40,
		weight       = 0,
		xp           = 1000,
		bulk         = 100,
		flags        = { BF_CHARGE, BF_ENVIROSAFE ,BF_HUNTING },
		ai_type      = "melee_seek_ai",

		desc            = "REWRITE TODO  Why doesn't a BFG work when you really need it? As if from a half-forgotten nightmare, you encounter the harbinger of death...",
		kill_desc_melee = "was ripped apart by the Angel of Death",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
			self.hp = self.hpmax
		end,
	}

	register_medal "cyberdemon1"
	{
		name = "Cyberdemon's Head",
		desc = "Killing the Cyberdemon w/o taking damage",
	}

	register_being "cyberdemon"
	{
		name         = "Cyberdemon",
		ascii        = "C",
		color        = BROWN,
		sprite       = SPRITE_CYBERDEMON,
		hp           = 200,
		armor        = 4,
		todam        = 15,
		tohit        = 8,
		speed        = 110,
		vision       = 1,
		min_lev      = 80,
		danger       = 30,
		weight       = 1,
		bulk         = 300,
		flags        = { F_LARGE, BF_OPENDOORS, BF_ENVIROSAFE, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
		ai_type      = "cyberdemon_ai",

		desc            = "An enormous giant of flesh and steel, this beastly behemouth is well equipped to take down a whole platoon of UAC Marines. This towering monstrosity is going to take every ounce of firepower you have to bring down.",
		kill_desc       = "was blown to bits by a Cyberdemon",
		kill_desc_melee = "was splattered by a Cyberdemon",

		OnCreate = function (self)
			self.eq.weapon = "bazooka"
			for i=1,4 do
				self.inv:add( "rocket", { ammo = 10 } )
			end
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
			self.hp = self.hpmax
		end,

		OnDie = function (self)
			if level.id == "tower_of_babel" then
				level:explosion( self.position, 17, 40, 0, 0, RED, "barrel.explode")
				ui.msg_enter("The Cyberdemon is dead!")
				if not level.flags[ LF_NUKED ] and statistics.damage_on_level == 0 then
					player:add_medal("cyberdemon1")
				end
			end
		end,
	}

	register_medal "mastermind1"
	{
		name = "Mastermind's Brain",
		desc = "Killing the Mastermind w/o taking damage",
	}

	register_being "mastermind"
	{
		name         = "Spider Mastermind",
		ascii        = "M",
		color        = WHITE,
		sprite       = SPRITE_MASTERMIND,
		hp           = 250,
		armor        = 2 ,
		attackchance = 60,
		todam        = 15,
		tohit        = 4,
		speed        = 150,
		min_lev      = 200,
		corpse       = true,
		danger       = 50,
		weight       = 0,
		bulk         = 100,
		flags        = { F_LARGE, BF_ENVIROSAFE, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
		ai_type      = "mastermind_ai",

		desc            = "Much like the smaller, more manageable arachnotrons, this cabin-sized creature is just as capable of turning you into minced meat as it is of coordinating the lesser demons.",
		kill_desc       = "was shredded by the spider mastermind",

		weapon = {
			damage     = "1d6",
			damagetype = DAMAGE_PLASMA,
			shots      = 6,
			flags      = { IF_DESTRUCTIVE },
			missile = {
				sound_id   = "chaingun",
				ascii      = "-",
				color      = YELLOW,
				sprite     = SPRITE_SHOT,
				delay      = 20,
				miss_base  = 20,
				miss_dist  = 4,
			},
		},

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
			self.hp = self.hpmax
		end,

		OnDie = function (self)
			if self.flags[ BF_BOSS ] then
				level:explosion( self.position, 17, 40, 0, 0, RED, "barrel.explode")
				ui.msg_enter("Congratulations! You defeated the Spider Mastermind!")
				self.expvalue = 0
				if not level.flags[ LF_NUKED ] and statistics.damage_on_level == 0 then
					player:add_medal("mastermind1")
				end
			end
		end,
	}

	register_being "jc"
	{
		name         = "John Carmack",
		name_plural  = "FINAL EVIL",
		ascii        = "@",
		color        = LIGHTBLUE,
		sprite       = SPRITE_JC,
		hp           = 250,
		armor        = 5,
		todam        = 15,
		tohit        = 8,
		vision       = 1,
		min_lev      = 200,
		danger       = 50,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
		ai_type      = "jc_ai",

		desc            = "REWRITE TODO  You knew it. This is the true EVIL behind the invasion! This is the true mastermind of Hell! Kill him for he knows not the meaning of mercy! Kill him!! Kill him NOW!!!",
		kill_desc       = "was pwned by John Carmack",

		OnCreate = function (self)
			self.eq.weapon = "bazooka"
			for i=1,3 do
				self.inv:add( "rocket", { ammo = 10 } )
			end

			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
			self.hp = self.hpmax
		end,

		OnDie = function (self)
			if self.flags[BF_BOSS] then
				level:explosion( self.position, 17, 40, 0, 0, BLUE, "barrel.explode")
				for b in level:beings() do
					if not ( b:is_player() ) and b.id ~= "jc" then
						b:kill()
					end
				end
				ui.msg_enter("Congratulations! You defeated John Carmack!")
			end
		end,
	  }

 -- GROUPS --

	register_being_group
	{
		min_lev = 7,
		max_lev = 16,
		weight  = 10,
		beings = {
			{ being = "sergeant" },
			{ being = "former", amount = {2,6} }
		}
	}

	register_being_group
	{
		min_lev = 5,
		max_lev = 8,
		weight  = 10,
		beings = {
			{ being = "imp", amount = {3,4} }
		}
	}

	register_being_group
	{
		min_lev = 9,
		max_lev = 12,
		weight  = 10,
		beings = {
			{ being = "knight" },
			{ being = "imp", amount = {2,6} }
		}
	}

	register_being_group
	{
		min_lev = 13,
		max_lev = 21,
		weight  = 10,
		beings = {
			{ being = "baron" },
			{ being = "imp", amount = {4,9} }
		}
	}

	register_being_group
	{
		min_lev = 15,
		max_lev = 21,
		weight  = 10,
		beings = {
			{ being = "commando" },
			{ being = "sergeant", amount = {2,6} }
		}
	}

	register_being_group
	{
		min_lev = 13,
		max_lev = 21,
		weight  = 8,
		beings = {
			{ being = "pain" },
			{ being = "lostsoul", amount = {3,8} }
		}
	}

	register_being_group
	{
		min_lev = 10,
		max_lev = 22,
		weight  = 4,
		beings = {
			{ being = "demon", amount = {4,9} }
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 4,
		beings = {
			{ being = "baron" },
			{ being = "knight", amount = {2,4} }
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 3,
		beings = {
			{ being = "arachno", amount = {3,6} }
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 2,
		beings = {
			{ being = "arch",     amount = 2 },
			{ being = "captain",  amount = 4 },
			{ being = "sergeant", amount = 4 },
			{ being = "former",   amount = {3,6} }
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 5,
		beings = {
			{ being = "baron",    amount = 2 },
			{ being = "captain",  amount = {2,3} },
			{ being = "sergeant", amount = {2,3} }
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 4,
		beings = {
			{ being = "arch",     amount = 2 },
			{ being = "mancubus", amount = {2,5} },
		}
	}

	register_being_group
	{
		min_lev = 20,
		weight  = 4,
		beings = {
			{ being = "arch",     amount = 2 },
			{ being = "revenant", amount = {2,5} },
		}
	}

	register_being_group
	{
		min_lev = 25,
		weight  = 4,
		beings = {
			{ being = "arch",     amount = 2 },
			{ being = "baron",    amount = {3,9} }
		}
	}

	register_being_group  -- Mancubi For Added Fun (MFAF, tm by Malek)
	{
		min_lev = 25,
		weight  = 2,
		beings = {
			{ being = "arch",     amount = 2 },
			{ being = "captain",  amount = {2,8} },
			{ being = "mancubus", amount = {2,3} },
		}
	}

end

function DoomRL.load_doom_npcs()

	register_medal "dragonslayer2"
	{
		name = "Apostle Insignia",
		desc = "Awarded for killing the Apostle",
		hidden = true,
	}

	register_being "apostle"
	{
		name         = "Apostle",
		ascii        = "@",
		color        = YELLOW,
		sprite       = SPRITE_MASTER,
		hp           = 255,
		armor        = 30,
		vision       = 2,
		attackchance = 60,
		todam        = 12,
		tohit        = 2,
		speed        = 160,
		min_lev      = 200,
		corpse       = "corpse",
		danger       = 0,
		weight       = 0,
		bulk         = 100,
		flags        = { BF_OPENDOORS, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
		ai_type      = "archvile_ai",

		desc            = "REWRITE TODO  This seems so unreal, as though from another story...",
		kill_desc       = "was killed by the Apostle",

		weapon = {
			damage     = "40d1",
			damagetype = DAMAGE_PLASMA,
			radius     = 3,
			flags      = { IF_AUTOHIT },
			missile = {
				sound_id   = "arch",
				hitdesc    = "You are engulfed in flames!",
				color      = YELLOW,
				sprite     = 0,
				delay      = 0,
				miss_base  = 10,
				miss_dist  = 10,
				flags      = { MF_EXACT, MF_IMMIDATE },
				expl_delay = 50,
				expl_color = YELLOW,
				expl_flags = { EFNOKNOCK, EFSELFSAFE },
			},
		},

		OnCreate = function (self)
			level.flags[ LF_NONUKE ] = true
		end,

		OnAction = function (self)
			if not core.is_playing() then return end
			if self.hp < self.hpmax then
				self.hp = self.hp + 1
			end
			if math.random(20) == 1 then
				self:play_sound{"apostle.phase", "soldier.phase"}
				level:explosion( self.position, 1, 50, 0, 0, LIGHTBLUE )
				self:phase()
				level:explosion( self.position, 1, 50, 0, 0, LIGHTBLUE )
			end
			if math.random(10) == 1 then
				self:play_sound{"apostle.act", "arch.act"}
			end
		end,

		OnDie = function (self)
			self:play_sound{"apostle.die", "arch.die"}
			player:add_medal("dragonslayer2")
			if CHALLENGE == "challenge_a100" then
				level.map[ self.position ] = "stairs"
			elseif self.flags[BF_BOSS] then
				level:explosion( self.position, 17, 40, 0, 0, RED, "barrel.explode")
				for b in level:beings() do
					if not ( b:is_player() ) and b.id ~= "apostle" then
						b:kill()
					end
				end
				ui.msg_enter("Congratulations! You defeated the Apostle!")
			end
		end,
	}

end
