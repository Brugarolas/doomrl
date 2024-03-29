function DoomRL.load_events()

	register_event "ice_event"
	{
		min_dlevel = 16,
		weight     = 2,
		history    = "On level @1, hell froze over!",
		message    = "The seemingly impossible has happened, and hell has been coverred in a sheet of ice.",
		
		setup      = function()
			generator.wall_to_ice[ generator.styles[ level.style ].wall ] = "iwall"

			for c in area.FULL:coords() do
				local cell = generator.wall_to_ice[ cells[generator.get_cell( c )].id ]
				if cell then
					generator.set_cell( c, cell )
				end
			end
		end,
	}

	register_event "perma_event"
	{
		history    = "Level @1 was nigh-indestructable!",
		message    = "The walls here seem a lot sturdier than normal...",
		min_dlevel = 8,
		weight     = 4,
		
		setup      = function()
			generator.set_permanence( area.FULL )
		end,
	}

	register_event "alarm_event"
	{
		history    = "An alarm was tripped on level @1!",
		message    = "As you enter the area, you immediately hear a quiet beep as you trip something, followed by blaring klaxons and flashing lights.",
		min_dlevel = 8,
		weight     = 2,

		setup      = function()
			for b in level:beings() do b.flags[ BF_HUNTING ] = true end
		end,
	}

	register_event "deadly_air_event"
	{
		history    = "Level @1 was thick with a deadly atmosphere!",
		message    = "As you enter, you immediately notice a disgusting, acrid taste to the air, and a sickly haze hangs from the ceiling.",
		min_dlevel = 16,
		min_diff   = 2,
		weight     = 2,

		setup      = function()
			generator.setup_deadly_air_event( 100 - DIFFICULTY * 5 )
		end,
	}

	register_event "nuke_event"
	{
		history    = "Level @1 contained an armed nuke!",
		min_dlevel = 16,
		min_diff   = 2,
		weight     = 2,

		setup      = function()
			local minutes = 10 - DIFFICULTY
			ui.msg_feel("As you reach the bottom of the stairs, you immediately spot a familiar object, and your heart skips a beat.")
			ui.msg_feel("\"Warhead armed. T-minus "..minutes.." until detonation.\"")
			player:nuke( minutes*60*10 )
		end,
	}

	register_event "flood_acid_event"
	{
		message    = "You hear the rumbling of a flash flood, and smell the putrid stench of acid, and both grow stronger by the second. RUN!",
		history    = "Level @1 began flooding with acid!" ,
		min_dlevel = 8,
		weight     = 1,

		setup      = function()
			local direction = (math.random(2)*2)-3
			local step      = math.max( 200 - level.danger_level - DIFFICULTY * 5, 60 )

			generator.setup_flood_event( direction, step, "acid" )

			local left  = generator.safe_empty_coord( area.new(2,2,20,19) )
			local right = generator.safe_empty_coord( area.new(60,2,78,19) )

			for c in generator.each("stairs") do
				level.map[ c ] = generator.styles[ level.style ].floor
			end

			if direction == 1 then left, right = right, left end
			player:displace( right )
			level.map[ left ] = "stairs"
		end,
	}

	register_event "flood_lava_event"
	{
		message    = "This floor is getting hotter by the second, and you can hear a loud rumbling grow closer. RUN!",
		history    = "Level @1 began flooding with lava!" ,
		weight     = 4,
		min_dlevel = 17,
		min_diff   = 3,

		setup      = function()
			local direction = (math.random(2)*2)-3
			local step      = math.max( 200 - level.danger_level - DIFFICULTY * 5, 40 )
			
			if level.danger_level > 20 and math.random(5) == 1 then
				step = 25
			end

			generator.setup_flood_event( direction, step, "lava" )

			local left  = generator.safe_empty_coord( area.new(2,2,20,19) )
			local right = generator.safe_empty_coord( area.new(60,2,78,19) )

			for c in generator.each("stairs") do
				level.map[ c ] = generator.styles[ level.style ].floor
			end

			if direction == 1 then left, right = right, left end
			player:displace( right )
			level.map[ left ] = "stairs"
		end,

	}

	register_event "targeted_event"
	{
		message    = "You feel an uncomfortably uncanny sense that you have a target painted on your back, and SOMETHING is tracking you.",
		history    = "Level @1 was the lair of a hunter tasked with extermination!" ,
		weight     = 2,
		min_dlevel = 17,
		min_diff   = 3,

		setup      = function()
			generator.setup_targeted_event( math.max( 100 - DIFFICULTY * 10, 50 ) )
		end,
	}

	register_event "explosion_event"
	{
		message    = "In the distance, you hear the thumping of mortar fire, and the screaming sounds of incoming shells!",
		history    = "Level @1 was shelled!" ,
		weight     = 1,
		min_dlevel = 18,
		min_diff   = 2,

		setup      = function()
			local damage = math.min( math.max( math.ceil( (level.danger_level + 2*DIFFICULTY) / 10 ), 2 ), 5 )
			generator.setup_explosion_event( math.max( 100 - DIFFICULTY * 10, 50 ), 2, damage )
		end,
	}

	register_event "explosion_lava_event"
	{
		message    = "In the distance, you hear the loud banging of heavy artillery, and the screaming sounds of massive incoming shells!",
		history    = "Level @1 was shelled with Hell's biggest guns!" ,
		weight     = 1,
		min_dlevel = 25,
		min_diff   = 3,

		setup      = function()
			local damage = math.min( math.max( math.ceil( (level.danger_level + 5*DIFFICULTY) / 25 ), 3 ), 6 )
			generator.setup_explosion_event( math.max( 100 - DIFFICULTY * 10, 50 ), {2,3}, damage, "lava" )
		end,
	}

  register_event "darkness_event"
  {
    message    = "This floor seems to have no lights in sight, leaving you immersed in darkness.",
    history    = "Level @1 was pitch-black!",
    weight     = 2,
    min_dlevel = 9,
    min_diff   = 2,

    setup      = function ()
      local dark_event = {}
      dark_event.old_stairsense = player.flags[ BF_STAIRSENSE ]
      dark_event.old_darkness = player.flags[ BF_DARKNESS ]
      player.vision = player.vision - 2
      player.flags[ BF_DARKNESS ] = true
      player.flags[ BF_STAIRSENSE ] = false

      generator.OnExit = function ()
        player.flags[ BF_DARKNESS ] = dark_event.old_darkness
        player.flags[ BF_STAIRSENSE ] = dark_event.old_stairsense
        player.vision = player.vision + 2
      end

    end,
  }

end

function generator.setup_targeted_event( step )
	local timer = 0

	generator.OnTick = function()
		timer = timer + 1
		if timer == step then
			timer = 0
			local list = {}
			local cp = player.position
			for b in level:beings() do
				if not b:is_player() and cp:distance( b.position ) > 9 then
					table.insert( list, b )
				end
			end
			if #list == 0 then return end
			local near_area = area.around( cp, 8 )
			local c 
			local count = 0
			repeat
				if count > 50 then return end
				c = generator.random_empty_coord( { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, near_area )
				if c == nil then return end -- If the random coordinate selector didn't find a space, just dump.  No need to call it 50 times.
				count = count + 1
			until c:distance( cp ) > 2 and level:eye_contact( c, cp )
			local b = table.random_pick( list )
			-- TODO We need a better way to deal with articles.  Removing this one for now.
			ui.msg( "Suddenly, "..b.name.." reveals itself nearby!" )
			b:relocate( c )
			b:play_sound("soldier.phase")
			b.scount = b.scount - math.max( 1000 - DIFFICULTY * 50, 500 )
			level:explosion( b.position, 1, 50, 0, 0, LIGHTBLUE )
			end
	end
end

function generator.setup_explosion_event( step, size, dice, content )
	local enext = step
	local hstep = math.ceil( step / 2 )

	generator.OnTick = function()
		enext = enext - 1
		if enext == 0 then
			enext = hstep + math.random( hstep * 2 )
			local c = generator.random_empty_coord( { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK } )
			if not c then return end
			local range = size
			if type( size ) == "table" then
				range = math.random( size[1], size[2] )
			end
			level:explosion( c, range, 50, dice, 6, LIGHTRED, "barrel.explode", DAMAGE_FIRE, nil, { EFRANDOMCONTENT }, content )
		end
	end
end

function generator.setup_deadly_air_event( step )
	local timer = 0

	generator.OnTick = function()
		local function chill( b )
			if b.hp > b.hpmax / 4 and not b.flags[BF_INV] then
				if not b:is_player() or not b:is_affect("enviro") then
					b:msg( "You feel a sharp chill as the air rapidly grows frigid!" )
					b.hp = b.hp - 1
				end
			end
		end
		timer = timer + 1
		if timer == step then
			timer = 0
			for b in level:beings() do
				chill(b)
			end
			chill(player)
		end
	end
end

function generator.setup_flood_event( direction, step, cell, pure )
	local flood_min   = 0
	if direction == -1 then
		flood_min = 80
	else
		direction = 1
	end

	local timer = 0

	local flood_tile = function( pos )
		if area.FULL:is_edge( pos ) then
			generator.set_cell( pos, generator.fluid_to_perm[ cell ] )
		else
			local cell_data = cells[ generator.get_cell( pos ) ]
			if not cell_data.flags[ CF_CRITICAL ] then
				generator.set_cell( pos, cell )
			end
			if cell_data.OnDestroy then cell_data.OnDestroy(pos) end
			level:try_destroy_item( pos )
		end
	end

	generator.OnTick = function()
		timer = timer + 1
		if timer == step then
			timer = 0
			flood_min = flood_min + direction
			if flood_min >= 1 and flood_min <= MAXX then
				for y = 1,MAXY do
					flood_tile( coord.new( flood_min, y ) )
				end
			end
			if flood_min + direction >= 1 and flood_min + direction  <= MAXX then
				local switch = false
				for y = 1,MAXY do
					if switch then
						flood_tile( coord.new( flood_min + direction, y ) )
					end
					if math.random(4) == 1 then switch = not switch end
				end
			end
		end
		level:recalc_fluids()
	end
end

