-- THE VAULTS -----------------------------------------------------------

register_level "the_vaults"
{
	name  = "The Vaults",
	entry = "On level @1 he entered the Vaults.",
	welcome = "You enter the Vaults. There's a presence here...",
	level = 19,

	canGenerate = function ()
		return DIFFICULTY > 1
	end,

	OnRegister = function ()

		register_badge "vaults1"
		{
			name  = "Scavenger Bronze Badge",
			desc  = "Find The Vaults",
			level = 1,
		}

		register_badge "vaults2"
		{
			name  = "Scavenger Silver Badge",
			desc  = "Scavenge The Vaults",
			level = 2,
		}

		register_badge "vaults3"
		{
			name  = "Scavenger Gold Badge",
			desc  = "Clear The Vaults",
			level = 3,
		}

		register_badge "vaults4"
		{
			name  = "Scavenger Platinum Badge",
			desc  = "Clear The Vaults by luck",
			level = 4,
		}

		register_badge "vaults5"
		{
			name  = "Scavenger Diamond Badge",
			desc  = "Clear The Vaults by luck on UV+",
			level = 5,
		}
		
	end,

	Create = function ()
		level.style = 3
		generator.fill( "rwall", area.FULL )

		local vault_weapon = { level = 20, type = ITEMTYPE_RANGED, unique_mod = 5 }
		local vault_armor  = { level = 20, type = {ITEMTYPE_ARMOR,ITEMTYPE_BOOTS}, unique_mod = 5 }

		local translation = {
			['.'] = "floorb",
			['#'] = { "rwall", flags = { LFPERMANENT } },
			['X'] = { "rwall", flags = { LFPERMANENT, LFBLOOD } },
			['%'] = "rwall",
			['='] = "lava",
			['>'] = "stairs",

			['|'] = { "floorb", item = "cell" },
			['-'] = { "floorb", item = "rocket" },
			['['] = { "floorb", item = "pshell" },
			[']'] = { "floorb", item = "pammo" },

			['A'] = { "floorb", being = core.bydiff{ "baron", "baron", "mancubus", "arch" } },
			['B'] = { "floorb", being = core.bydiff{ "arachno", "arachno", "revenant" } },

			['a'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['b'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['c'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['d'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['e'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['f'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['g'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['h'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['i'] = { "floorb", item = level:roll_item( vault_weapon ) },
			['j'] = { "floorb", item = level:roll_item( vault_weapon ) },

			['1'] = { "floorb", item = level:roll_item( vault_armor ) },
			['2'] = { "floorb", item = level:roll_item( vault_armor ) },
			['3'] = { "floorb", item = level:roll_item( vault_armor ) },
			['4'] = { "floorb", item = level:roll_item( vault_armor ) },
			['5'] = { "floorb", item = level:roll_item( vault_armor ) },
			['6'] = { "floorb", item = level:roll_item( vault_armor ) },
			['7'] = { "floorb", item = level:roll_item( vault_armor ) },
			['8'] = { "floorb", item = level:roll_item( vault_armor ) },
			['9'] = { "floorb", item = level:roll_item( vault_armor ) },
			['0'] = { "floorb", item = level:roll_item( vault_armor ) },

			['*'] = { "floorb", item = { "teleport", target = coord.new(4,11) } },
		}

		local map = [[
############################################################################
#########...........==========................==========...........#########
########...##XXXX##..========..####XXXXXX####..========..##XXXX##...########
#######...####XX####..##==##..######XXXX######..##==##..####XX####...#######
######...###|.A..|###..####..###7-...AB...-0###..####..###-..B.-###...######
#####...###........###..##..###|............|###..##..%##........###...#####
####...###|........|###....###......a..1......###....##%-........-###...####
###...X##....e..j....##X..X##-.....[#==#].....-##X..X##....f..h....##X...###
##.>..XX|.....##.....AXX..XXA.....3######c.....AXX..XXB.....=#.....-XX....##
##....XXA.....#=.....|XX..XXB.....d##**##4.....BXX..XX-.....##.....BXX....##
###...X##....g..5....##X..X##|......#==#......|##X..X##....i..6....##X...###
####...###|........|###....###......2..b......###....###-........-###...####
#####...###........#%#..##..###-............-###..##..###........###...#####
######...###|..A.|###..####..###9|...AB...|8###..####..###-.B..-###...######
#######...####XX####..######..######XXXX######..##==##..####XX####...#######
########...##XXXX##..========..####XXXXXX####..========..##XXXX##...########
#########...........==========................==========...........#########
############################################################################
]]

		generator.place_tile( translation, map, 2, 2 )

		level:player(4,11)
		level.status = 0
	end,

	OnKillAll = function ()
		if level.status == 1 then
			level.status = 2
			ui.msg("You would think there would be an easier way in. At least I got the loot!")
		else
			level.status = 4
			ui.msg("Well, they sure opened up. Now to see if there's anything left worth taking...")
		end
	end,

	OnKill = function ()
		if level.status == 0 then
			level.status = 1
		end
	end,

	OnExit = function ()
		local result = level.status
		player:add_badge("vaults1")
		if result == 0 then
			ui.msg("All these treasure left behind...")
			player:add_history("He came, he saw, but he left.")
		elseif result == 1 or result == 3 then
			ui.msg("At least I got something!")
			player:add_history("He managed to scavenge a part of the Vaults' treasures.")
			player:add_badge("vaults2")
		elseif result == 2 or result == 4 then
			ui.msg("Eternal death awaits any who would seek to steal the treasures secured within the Vaults...")
			if result == 2 then
				player:add_history("He managed to clear the Vaults completely!")
			else
				player:add_history("He cracked the Vaults and cleared them out!")
			end
			player:add_badge("vaults2")
			if not level.flags[ LF_NUKED ] then
				player:add_badge("vaults3")
				if result ~= 4 then
					player:add_badge("vaults4")
					if DIFFICULTY >= DIFF_VERYHARD then
						player:add_badge("vaults5")
					end
				end
			end
		end
	end,
}
