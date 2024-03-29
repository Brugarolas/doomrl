function DoomRL.loadaffects()
	
	register_affect "berserk"
	{
		name           = "brk",
		color          = LIGHTRED,
		color_expire   = RED,
		message_init   = "A fire surges through your veins, overwhelming you with strength and rage!",
		message_ending = "Your burning rage begins to fade...",
		message_done   = "The abnormal rage has burned out, and your strength returns to normal.",
		status_effect  = STATUSRED,
		status_strength= 5,

		OnAdd          = function(being)
			being.flags[ BF_BERSERK ] = true
			being.speed = being.speed + 50
			being.resist.bullet = (being.resist.bullet or 0) + 60
			being.resist.melee = (being.resist.melee or 0) + 60
			being.resist.shrapnel = (being.resist.shrapnel or 0) + 60
			being.resist.acid = (being.resist.acid or 0) + 60
			being.resist.fire = (being.resist.fire or 0) + 60
			being.resist.plasma = (being.resist.plasma or 0) + 60
		end,
		OnTick         = function(being)
			ui.msg("Your bloody rage burns!")
		end,
		OnRemove       = function(being)
			being.flags[ BF_BERSERK ] = false
			being.speed = being.speed - 50
			being.resist.bullet = (being.resist.bullet or 0) - 60
			being.resist.melee = (being.resist.melee or 0) - 60
			being.resist.shrapnel = (being.resist.shrapnel or 0) - 60
			being.resist.acid = (being.resist.acid or 0) - 60
			being.resist.fire = (being.resist.fire or 0) - 60
			being.resist.plasma = (being.resist.plasma or 0) - 60
		end,
	}

	register_affect "inv"
	{
		name           = "inv",
		color          = WHITE,
		color_expire   = DARKGRAY,
		message_init   = "An unnatural shine coats your body, shielding you from harm!",
		message_ending = "The protective shimmer begins to fade...",
		message_done   = "Your protection has vanished, leaving you vulnerbale again.",
		status_effect  = STATUSINVERT,
		status_strength= 10,

		OnAdd          = function(being)
			being.flags[ BF_INV ] = true
		end,
		OnTick         = function(being)
			if being.hp < being.hpmax and not being.flags[ BF_NOHEAL ] then
				being.hp = being.hpmax
			end
		end,
		OnRemove       = function(being)
			being.flags[ BF_INV ] = false
		end,
	}

	register_affect "enviro"
	{
		name           = "env",
		color          = LIGHTGREEN,
		color_expire   = GREEN,
		message_init   = "The environmental protection shield flickers on!",
		message_ending = "The enviro shield beeps and flickers, soon to die.",
		message_done   = "The environmental protection shield beeps loudly before abruptly powering down.",
		status_effect  = STATUSGREEN,
		status_strength= 1,

		OnAdd          = function(being)
			being.resist.acid = (being.resist.acid or 0) + 25
			being.resist.fire = (being.resist.fire or 0) + 25
		end,

		OnRemove       = function(being)
			being.resist.acid = (being.resist.acid or 0) - 25
			being.resist.fire = (being.resist.fire or 0) - 25
		end,
	}

	register_affect "light"
	{
		name           = "lit",
		color          = YELLOW,
		color_expire   = BROWN,
		message_init   = "The light-amplification visor snaps onto your helmet, and powers on.",
		message_ending = "A warning light indicates your light-amp visor will soon die.",
		message_done   = "The light-amp visor loses power, and you discard it.",

		OnAdd          = function(being)
			being.vision = being.vision + 4
		end,

		OnRemove       = function(being)
			being.vision = being.vision - 4
		end,
	}

end
