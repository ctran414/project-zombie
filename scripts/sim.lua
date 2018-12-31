sim = {}

function sim:enter()
	intro:play()
	font = love.graphics.newFont("texts/ZOMBIFIED.ttf", 50)
	timer = 0
end

function sim:draw()
	love.graphics.setFont(font)
	love.graphics.print('Day: ' .. game.day .. "\nHour: " .. game.hour .. "\nFood: " .. game.food, 300, 300)
end

function sim:update(dt)
	timer = timer + dt
	if timer > 1 then
		game.hour = game.hour + 1
		for i,survivor in pairs(game.survivors) do
			local starve = math.random(3)
			survivor.hunger = survivor.hunger + starve
			if survivor.hunger > 100 then
				table.remove(game.survivors, i)
			end
			if game.food > 0 then
				if survivor.hunger > 75 then
					local consumed = math.random(50, 75)
					if consumed > game.food then
						survivor.hunger = survivor.hunger - game.food
						game.food = 0
					else
						survivor.hunger = survivor.hunger - consumed
						game.food = game.food - consumed
					end
				elseif survivor.hunger > 50 then
					if math.random(2) == 1 then
						local consumed = math.random(25,50)
						if consumed > game.food then
							survivor.hunger = survivor.hunger - game.food
							game.food = 0
						else
							survivor.hunger = survivor.hunger - consumed
						game.food = game.food - consumed
						end
					end
				elseif survivor.hunger > 25 then
					if math.random(3) == 1 then
						local consumed = math.random(2,25)
						if consumed > game.food then
							survivor.hunger = survivor.hunger - game.food
							game.food = 0
						else
							survivor.hunger = survivor.hunger - consumed
							game.food = game.food - consumed
						end
					end
				end
			end
		end
		timer = 0
	end
	if game.hour > 23 then
		game.day = game.day + 1
		game.hour = 0
	end
	
end

function sim:keypressed(key)
	if key == "escape" then
		Gamestate.switch(menu)
	end
end