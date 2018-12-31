local utf8 = require("utf8")

newGame = {}

local msg = {}
msg.age = 0
msg.timer = 0

function newGame:init()
	font = love.graphics.newFont("texts/ZOMBIFIED.ttf", 30);
	game = Game()
	game.numSvr = 10
	for i = 1, game.numSvr do
		game.survivors[i] = Survivor()
	end
	local nameDone = false
	local ageDone = false
  text = ""
end

function newGame:draw()
	local x, y = love.mouse.getPosition()
	love.graphics.setFont(font)
	love.graphics.setColor(1,1,1)
	love.graphics.print("Enter your name:", 410, 220)
  love.graphics.setColor(.717,0,.109)
	if not nameDone then
    love.graphics.print(text, 630, 220)
  else
    love.graphics.print(game.player.name, 630, 220)
  end
	if nameDone then
    love.graphics.setColor(1,1,1)
		love.graphics.print("Enter your age:" , 410, 250)
		love.graphics.setColor(.717,0,.109)	
    if not ageDone then
      love.graphics.print(text, 630, 250)
    else
      love.graphics.print(game.player.age, 630, 250)
    end
	end
	if ageDone then
    love.graphics.setColor(1,1,1)
		love.graphics.print("Select gender:", 410, 280)
		if x >= 598 and x <= 665 and y >= 288 and y <= 310 then
			love.graphics.setColor(.717,0,.109)
			love.graphics.print("Male", 598, 280)
		else
			love.graphics.setColor(1,1,1)
			love.graphics.print("Male", 598, 280)
		end
		if x >= 667 and x <= 747 and y >= 288 and y <= 310 then
			love.graphics.setColor(.717,0,.109)
			love.graphics.print("Female", 668, 280)
		else
			love.graphics.setColor(1,1,1)
			love.graphics.print("Female", 668, 280)
		end
	end
	popup()
end

function popup()
	if not msg.age then
		if love.timer.getTime() - msg.timer < 3 then
			love.graphics.setColor(1,1,1)
			love.graphics.print("Only Ages 18-65 valid", 565, 300)
		end
	end
end

function newGame:keypressed(key, scancode)		
  beep:stop()
  beep:play()
	if key == "backspace" then
    local byteoffset = utf8.offset(text, -1)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        text = string.sub(text, 1, byteoffset - 1)
    end
	elseif key == "return" then
		if not nameDone and string.len(text) > 0 then
      game.player.name = text
			nameDone = true
      text = ""
		elseif not ageDone then
			if string.len(text) > 0 then
				if tonumber(text) and tonumber(text) >= 18 and tonumber(text) <= 65 then
          game.player.age = text
					ageDone = true
				else
					msg.age = false
					msg.timer = love.timer.getTime() 
				end
			end
		end
	end
end

function newGame:mousepressed(x, y, button)
	if ageDone == true and button == 1 and x >= 598 and x <= 665 and y >= 288 and y <= 310 then
		beep:play()
		game.player.sex = "Male"
		Gamestate.switch(menu)
	end
	if ageDone == true and button == 1 and x >= 667 and x <= 747 and y >= 288 and y <= 310 then
		beep:play()
		game.player.sex = "Female"
		Gamestate.switch(menu)
	end
end