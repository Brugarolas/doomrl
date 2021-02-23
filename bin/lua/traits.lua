function DoomRL.load_traits()

	register_trait "ironman"
	{
		name   = "Ironman",
		desc   = "Increases hitpoints by 20% starting HP/lv.",
		quote  = "\"It's gonna take a hell of a lot more than THAT to put ME down.\"",
		full   = "You're as tough a bastard as they come, or maybe just a hardcore masochist. Either way, you can take some punishment, and require a lot more effort to kill. Every level of this trait increases your health by 20% of your starting HP.",
		abbr   = "Iro",

		OnPick = function (being)
			local inc = math.floor(0.2 * being.hpnom)
			being.hpmax = being.hpmax + inc
			being.hp    = being.hp + inc
		end,
	}

	register_trait "finesse"
	{
		name   = "Finesse",
		desc   = "Attack time by -15%/lv.",
		quote  = "\"The rangemaster always said to take things slow and steady. But FUCK him.\"",
		full   = "You were never one for trigger discipline, and a combination of forearm strength and an itchy trigger finger mean you can fire a lot faster than most of your peers would consider reasonable. Each level of this trait allows you to fire 15% faster.",
		abbr   = "Fin",

		OnPick = function (being)
			being.firetime = being.firetime - 15
		end,
	}

	register_trait "hellrunner"
	{
		name   = "Hellrunner",
		desc   = "Movecost -15%/lv, Dodge chance +15%/lv.",
		quote  = "\"Don't stop me now, I'm having such a good time!\"",
		full   = "Runner's high and adrenaline are an ideal pairing for your situation, and moving targets are a lot harder to hit. Each level of this trait allows you to move 15% faster, and dodge projectiles 15% more often.",
		abbr = "HR",

		OnPick = function (being)
			being.movetime = being.movetime - 15
			being.dodgebonus = being.dodgebonus + 15
		end,
	}

	register_trait "nails"
	{
		name   = "Tough as nails",
		desc   = "Increases body armor by 1/lv.",
		quote  = "\"Oh come on, I barely felt that!\"",
		full   = "Your skin walks the line between 'callused' and 'a chitinous shell,' and takes more effort to break. Each level of this trait reduces all damage taken by one point.",
		abbr   = "TaN",

		OnPick = function (being)
			being.armor = being.armor + 1
		end,
	}

	register_trait "bitch"
	{
		name   = "Son of a bitch",
		desc   = "Increases damage by 1/lv.",
		quote  = "\"We can't expect God to do all the work.\"",
		full   = "You've been a budding weapon enthusiast for as long as you can remember, and know how to maximize the effectiveness of every single one. Each level of this trait increases all damage dealt by one point.",
		abbr   = "SoB",

		OnPick = function (being)
			being.todamall = being.todamall + 1
		end,
	}

	register_trait "gun"
	{
		name   = "Son of a gun",
		desc   = "Pistol: firing time -20%/lv, Dmg+1/lv.",
		quote  = "\"Six shots. More than enough to kill anything that moves.\"",
		full   = "The other Marines tended to underappreciate handguns. But you, you love your sidearms, and maintain and tweak them to operate at peak performance. Each level of this trait increases pistol firing speed by 20%, and damage by one point.",
		abbr   = "SoG",

		OnPick = function (being)
			being.pistolbonus = being.pistolbonus + 1
		end,
	}

	register_trait "reloader"
	{
		name   = "Reloader",
		desc   = "Each level reduces reload time by 20%.",
		quote  = "\"Firing a gun is easy. It's reloading that's dangerous.\"",
		full   = "On your downtime, you always liked practicing speed-loading so you would never get caught with your pants down. Now, that muscle memory is more valuable than ever. Each level of this trait increases base reload speed by 20%.",
		abbr   = "Rel",

		OnPick = function (being)
			being.reloadtime = being.reloadtime - 20
		end,
	}

	register_trait "eagle"
	{
		name   = "Eagle Eye",
		desc   = "Each level increases to-hit chance by 2.",
		quote  = "\"One in the heart and one in the head, and don't you hesitate.\"",
		full   = "You've got a hand so steady, it might as well be mechanical. Plus, those breathing techniques help keep it steady in spite of the stress. Each level of this trait increases your to-hit chance by 2.",
		abbr   = "EE",

		OnPick = function (being)
			being.tohit = being.tohit + 2
		end,
	}

	register_trait "brute"
	{
		name   = "Brute",
		desc   = "Increases melee damage by +3/lv and to-hit by +2/lv.",
		quote  = "\"How about a quick nosejob-dental combo procedure?\"",
		full   = "Sure, guns are nice and all, but you work best up close and personal, brawling, stabbing, or however else you can bring the fight directly to them. Each level of this trait increases melee damage by 3 points, and melee to-hit by 2 points.",
		abbr   = "Bru",

		OnPick = function (being)
			being.todam = being.todam + 3
			being.tohitmelee = being.tohitmelee + 2
		end,
	}

	register_trait "juggler"
	{
		name   = "Juggler",
		desc   = "Uses melee weapon if prepared.",
		quote  = "\"Everything within arm's reach.\"",
		full   = "You've memorized every pocket, holster, and sling on your equipment rig so well, you could swap weapons in your sleep without so much as a fumble. This trait lets you instantly swap between hotkeyed weapons, and instantly pull your knife in close quarters.",
		abbr   = "Jug",

		OnPick = function (being)
			being.flags[ BF_QUICKSWAP ] = true
		end,
	}

	register_trait "berserker"
	{
		name   = "Berserker",
		desc   = "Gives chance of berserking in melee.",
		quote  = "\"Curse, bless, me now with your fierce tears, I pray.\"",
		full   = "Years of therapy helped you get such a keen handle on your aggression, but now, now is time to let that all vanish until this whole mess is sorted. Until you're safe, your temper's one of the only tools you can count on. This trait adds a chance of entering a berserk state on landing melee strikes, or when taking damage.",
		abbr   = "Ber",

		OnPick = function (being)
			being.flags[ BF_BERSERKER ] = true
		end,
	}

	register_trait "dualgunner"
	{
		name   = "Dualgunner",
		desc   = "Allows dual pistol firing.",
		quote  = "\"Dodge this.\"",
		full   = "When you find yourself with the cocktail mix of ambidexterity, finesse, and recklessness that you have, what possible thing could you do with it? Dual-wield handguns, that's what.",
		abbr   = "DG",

		OnPick = function (being)
			being.flags[ BF_DUALGUN ] = true
		end,
	}

	register_trait "dodgemaster"
	{
		name   = "Dodgemaster",
		desc   = "First dodge in turn always succeeds.",
		quote  = "\"Flow like water.\"",
		full   = "They can't kill what they can't hit, and nobody knows this better than you. Your keen reflexes and honed muscle memory make you a slippery target to pin down. This trait makes the first dodge attempt after a movement automatically succeed.",
		author = "Kornel",
		abbr   = "DM",

		OnPick = function (being)
			being.flags[ BF_MASTERDODGE ] = true
		end,
	}

	register_trait "intuition"
	{
		name   = "Intuition",
		desc   = "Provides additional sense.",
		quote  = "\"Never miss a single detail, lest it bite you in the ass later.\"",
		full   = "You've always kept an eye on every little bit of your environment, and can often get a good idea of what's going on. Where others march blindly ahead, you watch for every hint you can find. The first level of this trait lets you evaluate levers and reveal powerup locations, the second level reveals monster locations.",
		author = "Derek",
		abbr   = "Int",

		OnPick = function (being,level)
			if level == 1 then
				being.flags[ BF_LEVERSENSE1 ] = true
				being.flags[ BF_POWERSENSE  ] = true
			elseif level == 2 then
				being.flags[ BF_LEVERSENSE2 ] = true
				being.flags[ BF_BEINGSENSE  ] = true
			end
		end,
	}

	register_trait "whizkid"
	{
		name   = "Whizkid",
		desc   = "Increases maximum amount of mod slots",
		quote  = "\"If that don't work, use more gun.\"",
		full   = "You never settle for stock, and always find ways to maximize an object's potential through whatever technical means you've got. Each level of this trait increases the maximum mod slots for weapons by 2, and 1 for armor and boots.",
		author = "Kornel",
		abbr   = "WK",

		OnPick = function (being)
			being.techbonus = being.techbonus + 1
		end,
	}

	register_trait "badass"
	{
		name   = "Badass",
		desc   = "Knockback resistence +1/lv and health decay limit +50%/lv",
		quote  = "\"I'm a bad bitch, you can't kill me!\"",
		full   = "You're the roughest, toughest, meanest son of a bitch out there, and whether through adrenaline, luck, or sheer force of will, you can hold your ground and keep pushing in the face of anything. Each level of this trait reduces knockback taken by one square, and increases maximum health before decay by 50%.",
		author = "Malek",
		abbr   = "Bad",

		OnPick = function (being)
			being.bodybonus  = being.bodybonus + 1
			being.hpdecaymax = being.hpdecaymax + 50
		end,
	}

	register_trait "shottyman"
	{
		name   = "Shottyman",
		desc   = "Allows shotgun reloading on the move.",
		quote  = "\"Never stop moving! NEVER!\"",
		full   = "You've mastered the fine art of not dropping small objects while jogging, and that skill couldn't be more useful in your current situation. This trait allows you to reload all shotguns and rocket launchers while moving.",
		author = "Malek",
		abbr   = "SM",

		OnPick = function (being)
			being.flags[ BF_SHOTTYMAN ] = true
			being.flags[ BF_ROCKETMAN ] = true
		end,
	}

	register_trait "triggerhappy"
	{
		name   = "Triggerhappy",
		desc   = "+1/lv rapid weapon shots per weapon.",
		quote  = "\"TODO - Ooh, I like it! The sugar-sweet kiss of heavy ordinance!\"",
		full   = "TODO - \"Shoot first and shoot fast\" has always been your motto. And nobody shoots faster than you. With each weapon you get an extra rapid shot per level of this trait. (note to self: figure out what the fuck that means)",
		author = "Kornel",
		abbr   = "TH",

		OnPick = function (being)
			being.rapidbonus = being.rapidbonus + 1
		end,
	}

	register_trait "blademaster"
	{
		name   = "Blademaster",
		desc   = "Free action after melee kill.",
		quote  = "\"Never get in a knife fight with a chef.\"",
		full   = "You've become a master at the art of melee combat. Actually, ALL the arts of melee combat. Your stance and balance is perfect, no matter the weapon you wield. This trait grants a free action immediately after a melee kill.",
		author = "Kornel",
		abbr   = "MBm",
		master = true,

		OnPick = function (being)
			being.flags[ BF_CLEAVE ] = true
		end,
	}

	register_trait "vampyre"
	{
		name   = "Vampyre",
		desc   = "+10% target MaxHP added to HP after melee kill.",
		quote  = "\"What a convenient night to have a curse...\"",
		full   = "It turns out your pale skin wasn't just a Vitamin D deficiency after all! Unfortunately, the 'immortality' thing doesn't seem to come with the package, but you'll take what you can get. This trait enables the ability to heal for 10% of your target's maximum HP after killing them.",
		author = "Kornel",
		abbr   = "MVm",
		master = true,

		OnPick = function (being)
			being.flags[ BF_VAMPYRE ] = true
		end,
	}

	register_trait "malicious"
	{
		name   = "Malicious Blades",
		desc   = "Allows dual-wielding knives, with defense bonuses from off-hand knife.",
		quote  = "\"Never bring a knife to a gunfight. But what about TWO knives??\"",
		full   = "It turns out a knife in each hand isn't as absurd and impractical as doing it with guns! This trait enables dual-wielding knives. Additionally, an off-hand blade will negate 75% of incoming melee damage, and 50% of incoming bullet, shrapnel, and fire damage.",
		abbr   = "MMB",
		master = true,

		OnPick = function (being)
			being.flags[ BF_DUALBLADE ] = true
			being.flags[ BF_BLADEDEFEND ] = true
		end,
	}

	register_trait "bulletdance"
	{
		name   = "Bullet Dance",
		desc   = "Allows triggerhappy to work on pistols",
		quote  = "\"TODO - Righteousness -- and superior firepower -- has triumphed!\"",
		full   = "TODO - Pistols are your game -- you can squeeze an additional shot from each of your pistols for each level of Triggerhappy at half the time cost! (note to self: figure out how triggerhappy works lmao)",
		abbr   = "MBD",
		master = true,

		OnPick = function (being)
			being.flags[ BF_BULLETDANCE ] = true
		end,
	}

	register_trait "gunkata"
	{
		name   = "Gun Kata",
		desc   = "Free pistol shot after dodge, and instant reload after kill.",
		quote  = "\"It means nothing, but it sure SOUNDS cool.\"",
		full   = "Nothing is more familiar to you in combat than your pistols, and you've learned to control them better than anything else. This trait allows you to fire a pistol instantly after dodging, and will reload it for free after a kill with them.",
		author = "Kornel",
		abbr   = "MGK",
		master = true,

		OnPick = function (being)
			being.flags[ BF_GUNKATA ] = true
		end,
	}

	register_trait "sharpshooter"
	{
		name   = "Sharpshooter",
		desc   = "Pistol shots always deal max damage",
		quote  = "\"Boom...headshot.\"",
		full   = "You've finally overridden the reflexes from training that taught you to sensibly aim for center of mass, and managed the far more difficult feat: reflexively aiming for the head! This trait makes every pistol shot that hits deal maximum damage.",
		abbr   = "MSs",
		master = true,

		OnPick = function (being)
			being.flags[ BF_PISTOLMAX ] = true
		end,
	}

--[[
	register_trait "regenerator"
	{
		name   = "Regenerator",
		desc   = "Regenerate up to 20 Hp.",
		quote  = "",
		full   = "Your skin has unnatural healing abilities. You regenerate up to 10 HP at a rate of +1 per turn.",
		author = "Kornel",
		abbr   = "MRg",
		master = true,

		OnPick = function (being)
			being.flags[ BF_REGENERATE ] = true
		end
	}
--]]

	register_trait "armydead"
	{
		name   = "Army of the Dead",
		desc   = "Shotguns ignore armor.",
		quote  = "\"The best scalpels are breach-loaded.\"",
		full   = "Nobody knows what you're packing into your shells, but whatever it is cleaves through armor like it's a wet paper towel, and not even Hell's most well-equipped armies can stop you now! This trait allows shotguns to ignore an enemy's armor.",
		author = "Kornel",
		abbr   = "MAD",
		master = true,

		OnPick = function (being)
			being.flags[ BF_ARMYDEAD ] = true
		end,
	}

	register_trait "shottyhead"
	{
		name   = "Shottyhead",
		desc   = "Shotguns fire 66% faster.",
		quote  = "\"Groovy.\"",
		full   = "You've become the fastest gun in the West, or more specifically, the fastest shotgun in the West! You know shotguns better than whatever dude invented them by now. This trait reduces shotgun firing speed to a third of its default.",
		abbr   = "MSh",
		master = true,

		OnPick = function (being)
			being.flags[ BF_SHOTTYHEAD ] = true
		end,
	}

	register_trait "fireangel"
	{
		name   = "Fireangel",
		desc   = "Grants explosive splash damage immunity.",
		quote  = "\"Can't take the heat? Get outta the kitchen!\"",
		full   = "What's a little flash burn when you've had your barracks AC unit fail on Mars? It's nothing, that's what! This trait makes you immune to explosive splash damage, only direct hits can still harm you.",
		author = "Kornel",
		abbr   = "MFa",
		master = true,

		OnPick = function (being)
			being.flags[ BF_FIREANGEL ] = true
		end,
	}

	register_trait "ammochain"
	{
		name   = "Ammochain",
		desc   = "Rapid-fire shots take 1 ammo per volley.",
		quote  = "\"Don't think about it too hard.\"",
		full   = "You've managed to cheat the very laws of physics with your belt-fed firearms! The very implications of this ability are ground-shaking, but this is all you can really think to use it for. This trait makes all firing volleys from chainguns consume only one bullet.",
		author = "Kornel",
		abbr   = "MAc",
		master = true,

		OnPick = function (being)
			being.flags[ BF_AMMOCHAIN ] = true
		end,
	}

	register_trait "cateye"
	{
		name   = "Cateye",
		desc   = "Increases sight range by 2.",
		quote  = "\"Nya~\"",
		full   = "As a kid, you heard carrots were good for your eyes. So, you haven't stopped eating them since, and look at you now! This trait increases your view radius by two.",
		abbr   = "MCe",
		master = true,

		OnPick = function (being)
			being.vision = being.vision + 2
		end,
	}

	register_trait "entrenchment"
	{
		name   = "Entrenchment",
		desc   = "30% bonus to all resistences while chainfiring.",
		quote  = "\"I AM THE BLIND SCALES OF JUSTICE!!\"",
		full   = "In order to go about staying in one place while unloading an absurd amount of lead with an enormous weapon, you have to clench about every muscle in your body. As it turns out, that makes you a fair bit tougher in the process. This trait grants a 30% bonus to all resistences while chainfiring.",
		abbr   = "MEn",
		master = true,

		OnPick = function (being)
			being.flags[ BF_ENTRENCHMENT ] = true
		end,
	}

	register_trait "survivalist"
	{
		name   = "Survivalist",
		desc   = "No minimum damage taken, medpacks heal over 100%",
		quote  = "\"Improvise. Adapt. Overcome.\"",
		full   = "You're about as sturdy as they come, with skin thicker than a Cyberdemon's ass. This trait removes minimum damage, preventing low-damage hits from being rounded up, and negating them entirely. In addition, medpacks overcharge health.",
		abbr   = "MSv",
		master = true,

		OnPick = function (being)
			being.flags[ BF_MEDPLUS ] = true
			being.flags[ BF_HARDY ] = true
		end,
	}

	register_trait "running"
	{
		name   = "Running Man",
		desc   = "Running time doubled, no to hit penalty",
		quote  = "\"Movin' right along.\"",
		full   = "Cardio is your middle name, you could outpace your squad in a marathon, even without all the adrenaline! Your mastery of breathing techniques even lets you keep your hands steady, too! This trait doubles how long you can sprint, and removes the to-hit penalty.",
		abbr   = "MRM",
		master = true,

		OnPick = function (being)
			being.runningtime = being.runningtime * 2
			being.flags[ BF_NORUNPENALTY ] = true
		end,
	}

	register_trait "gunrunner"
	{
		name   = "Gunrunner",
		desc   = "Running time +50%, free non-rapid shot while running",
		quote  = "\"Movin' right along.\"",
		full   = "You're a machine built on muscle memory, and with nothing but target-rich environments ahead of you, you barely need to think! This trait increases your sprinting time by 50%, and any enemy in range will be automatically shot at with the weapon in hand.",
		abbr   = "MGr",
		master = true,

		OnPick = function (being)
			being.runningtime = math.floor( being.runningtime * 1.5 )
			being.flags[ BF_GUNRUNNER ] = true
		end,
	}

	register_trait "scavenger"
	{
		name   = "Scavenger",
		desc   = "Allows dissasembling weapons into mods.",
		quote  = "\"Nothing's worthless when you have a multitool!\"",
		full   = "You've always had a knack for taking things apart. Putting them back together is still a work in progress skillset, but salvaging parts from whatever guns you can get ahold of is a cakewalk for you. This trait enables you to turn any weapon into a mod pack by pressing 'unload' on an already unlaoded weapon.",
		abbr   = "MSc",
		master = true,

		OnPick = function (being)
			being.flags[ BF_SCAVENGER ] = true
		end,
	}

end
