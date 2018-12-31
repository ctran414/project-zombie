menu = {}

function menu:init()
	menuFont = love.graphics.newFont("texts/caracura.ttf", 50)
	normalFont = love.graphics.newFont("texts/ZOMBIFIED.ttf", 20)
	mainFont = love.graphics.newFont("texts/ZOMBIFIED.ttf", 50)
end

function menu:enter()
	love.graphics.setBackgroundColor(0, 0, 0, 0)
	intro:pause()
	local survbut = false
	local basebut = false
	local opbut = false
	local simbut = false
	local plybut = false
end

function menu:draw()
	local x, y = love.mouse.getPosition()
	love.graphics.setFont(menuFont)
	if survbut == true or (x < 135 and y < 40) then
		love.graphics.setColor(0.862, 0.035, 0.058)
		love.graphics.print('SURVIVORS', 5, -20)
	else
		love.graphics.setColor(.5,0,.5)
		love.graphics.print('SURVIVORS', 5, -10)
	end
	if basebut == true or (x >= 160 and x <= 220 and y < 50) then
		love.graphics.setColor(0.862, 0.035, 0.058)
		love.graphics.print('BASE', 160, -20)
	else
		love.graphics.setColor(.5,0,.5)
		love.graphics.print('BASE', 160, -10)
	end
	if simbut == true or (x >= 240 and x <= 362 and y < 50) then
		love.graphics.setColor(0.862, 0.035, 0.058)
		love.graphics.print('SIMULATE', 240, -20)
	else
		love.graphics.setColor(.5,0,.5)
		love.graphics.print('SIMULATE', 240, -10)
	end
	if plybut == true or (x >= 372 and x <= 495 and y < 50) then
		love.graphics.setColor(0.862, 0.035, 0.058)
		love.graphics.print('SCAVENGE', 372, -20)
	else
		love.graphics.setColor(.5,0,.5)
		love.graphics.print('SCAVENGE', 372, -10)
	end
	if opbut == true or (x > 1175 and y < 50) then
		love.graphics.setColor(0.862, 0.035, 0.058)
		love.graphics.print('OPTIONS', 1175, -20)
	else
		love.graphics.setColor(.5,0,.5)
		love.graphics.print('OPTIONS', 1175, -10)
	end
	if survbut == true then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(normalFont)
		love.graphics.print(game.player.name, 5, 50)
		for i,names in pairs(game.survivors) do
			love.graphics.print(game.survivors[i].name, 5, 50 + i * 20)
			game.survivors[i].pos = vector(5, 50 + i * 20)
		end
		local x, y = love.mouse.getPosition()
		local xwidth = 10 * string.len(game.player.name)
		if y > 50 and y < 70 and x < xwidth then
			love.graphics.setFont(mainFont)
			love.graphics.print("Name: " .. game.player.name .. "\nSex: " .. game.player.sex .. 
				"\nAge: " .. game.player.age .. "\nHealth: " .. game.player.health .. 
				"\nHunger: " .. game.player.hunger .. "\nExp: " .. game.player.experience, 385, 220)
		end
		for i,survivor in pairs(game.survivors) do
			local xwidth = 10 * string.len(survivor.name)
			if y > survivor.pos.y and y < survivor.pos.y + 20 and x < xwidth then
				love.graphics.setFont(mainFont)
				love.graphics.print("Name: " .. survivor.name .. "\nSex: " .. survivor.sex .. 
					"\nAge: " .. survivor.age .. "\nHealth: " .. survivor.health .. 
					"\nHunger: " .. survivor.hunger .. "\nExp: " .. survivor.experience, 385, 220)
			end
		end
	end
	if basebut == true then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(normalFont)
		love.graphics.print("Food " .. game.food, 150, 50)
		love.graphics.print("Size " .. game.size, 150, 70)
	end
	if opbut == true then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(normalFont)
		love.graphics.print("Save", 1180, 50)
		love.graphics.print("Load", 1180, 70)
		love.graphics.print("Quit", 1180, 90)
	end
end

function menu:mousepressed(x, y, button)
	--Survivors tab
	if button == 1 and x < 135 and y < 50 and not survbut then
		beep:stop()
		beep:play()
		survbut = true
	else
		survbut = false
	end
	--Base tab
	if button == 1 and x >= 160 and x <= 220 and y < 50 and not basebut then
		beep:stop()
		beep:play()
		basebut = true
	else
		basebut = false
	end
  --Sim tab
	if button == 1 and x >= 240 and x <= 362 and y < 50 then
		beep:stop()
		beep:play()
		Gamestate.switch(sim)
	end
  --Play tab
	if button == 1 and x >= 372 and x <= 495 and y < 50 then
		beep:stop()
		beep:play()
		Gamestate.switch(play)
	end
	--Options tab
	if button == 1 and x > 1175 and y < 50 and not opbut then
		beep:stop()
		beep:play()
		opbut = true
	elseif button == 1 and x >= 1180 and x <= 1220 and y >= 52 and y <= 70 and opbut then
		love.filesystem.write("save.lua", Tserial.pack(game))
		beep:stop()
		beep:play()
		opbut = false
	else
		opbut = false
	end
end