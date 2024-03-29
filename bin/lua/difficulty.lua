function DoomRL.load_difficulty()

	register_difficulty	"ITYTD" 
	{
		name        = "I'm Too Young To Die!",
		description = "A basic, more stripped down difficulty for those unfamiliar with traditional roguelikes.",
		code        = "@GE",
		tohitbonus  = -1,
		expfactor   = 1.4,
		scorefactor = 0.5,
		ammofactor  = 2,
		powerfactor = 2,
		challenge   = false,
	}

	register_difficulty	"HNTR" 
	{
		name        = "Hey, Not Too Rough",
		id          = "HNTR",
		description = "A moderate difficulty for those familiar with traditional roguelikes.",
		code        = "@BM",
		expfactor   = 1.2,
	}

	register_difficulty	"HMP" 
	{
		name        = "Hurt Me Plenty",
		description = "A harder difficulty for those closely familiar with DRL's mechanics.",
		code        = "@RH",
		scorefactor = 1.5,
		ammofactor  = 1.25,
	}

	register_difficulty	"UV" 
	{
		name        = "Ultra-Violence",
		description = "A very difficult setting for self-professed experts of DRL.",
		code        = "@yU",
		tohitbonus  = 2,
		scorefactor = 2,
		ammofactor  = 1.5,
		req_skill   = 2,
	}

	register_difficulty	"N!" 
	{
		name        = "Nightmare!",
		description = "Do not go gentle into that good night. Rage, rage against the dying of the light!",
		code        = "@rN",
		tohitbonus  = 2,
		expfactor   = 1.2,
		scorefactor = 4,
		ammofactor  = 2,
		powerfactor = 2,
		powerbonus  = 1.25,
		respawn     = true,
		req_skill   = 4,
		speed       = 1.5,
	}

end
