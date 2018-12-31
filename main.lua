Class = require "class"
vector = require "vector"
Gamestate = require "gamestate"
require "names"
require "Tserial"
require "scripts/newgame"
require "scripts/menu"
require "scripts/sim"
require "scripts/play"

title = {}

Player = Class{
    init = function(self)
		self.sex = ""
		self.age = ""
		self.name = ""
		self.health = 100
		self.mental = 100
		self.hunger = 0
		self.energy = 100
		self.experience = 0
    end,
}

Survivor = Class{
    init = function(self)
		self.sex = generateSex()
		self.age = math.random(16, 65)
		self.name = generateName(self.sex)
		self.health = 100
		self.mental = 100
		self.hunger = 0
		self.energy = 100
		self.experience = math.random(500)
		self.pos = vector(0, 0)
    end,
}

Game = Class{
    init = function(self)
		self.player = Player()
		self.size = 4000
		self.numSvr = 0
		self.survivors = {}
		self.food = 1000
		self.hour = 0
		self.day = 0
    end,
}

function generateSex()
  --math.randomseed(os.clock())
	local rand = math.random(2)
	if rand == 1 then
		return "male"
	else
		return "female"
	end
end

function generateName(sex)
  --math.randomseed(os.clock())
	local rand = math.random(100)
	local name
	if sex == "male" then
		name = male_names[rand]
	else
		name = female_names[rand]
	end
	rand = math.random(100)
	return name .. " " .. surnames[rand]
end

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
	beep = love.audio.newSource("sounds/beep.mp3", "static") 
	beep:setVolume(.5)
	intro = love.audio.newSource("sounds/bg.mp3", "static") 
	debugFont = love.graphics.newFont(10);
	Gamestate.registerEvents()
	Gamestate.switch(title)
	debugs = 0;
  text = ""
end
 
function love.textinput(t)
    text = text .. t
end
 
function love.draw()
	local x, y = love.mouse.getPosition()
	love.graphics.setFont(debugFont)
	love.graphics.print('Coords: ' .. x .. ", " .. y, 5, 780)
	love.graphics.print('debugs: ' .. debugs, 5, 760)
end

function title:init()
	newbut = false
	titleFont = love.graphics.newFont("texts/ZOMBIFIED.ttf", 100);
	normalFont = love.graphics.newFont("texts/ZOMBIFIED.ttf", 30);
	--intro:play()
	intro:setVolume(.25)
end

function title:draw()
	local x, y = love.mouse.getPosition()
	love.graphics.setFont(titleFont)
	love.graphics.setColor(.717,0,1)
	love.graphics.print("Project Zombie", 420, 200)
	love.graphics.setFont(normalFont)
	if x >= 560 and x <= 680 and y >= 325 and y <= 350 then
		love.graphics.setColor(1,0,0)
		love.graphics.print("New Game", 560, 320)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print("New Game", 560, 320)
	end
	if x >= 560 and x <= 686 and y >= 355 and y <= 380 then
		love.graphics.setColor(1,0,0)
		love.graphics.print("Load Game", 560, 350)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print("Load Game", 560, 350)
	end
	if x >= 560 and x <= 654 and y >= 387 and y <= 411 then
		love.graphics.setColor(1,0,0)
		love.graphics.print("Credits", 560, 380)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print("Credits", 560, 380)
	end
	if x >= 560 and x <= 612 and y >= 416 and y <= 440 then
		love.graphics.setColor(1,0,0)
		love.graphics.print("Quit", 560, 410)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print("Quit", 560, 410)
	end
end

function title:mousepressed(x, y, button)
	--new game
	if button == 1 and x >= 560 and x <= 680 and y >= 325 and y <= 350 then
		beep:play()
		Gamestate.switch(newGame)
	end
	--load game
	if button == 1 and x >= 560 and x <= 686 and y >= 355 and y <= 380 then
		game = Tserial.unpack(love.filesystem.read("save.lua"))
		beep:play()
		Gamestate.switch(menu)
	end
	--quit
	if button == 1 and x >= 560 and x <= 612 and y >= 416 and y <= 440 then
		love.event.quit()
	end
end
