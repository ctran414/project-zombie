require 'middleclass'
Stateful = require 'stateful'
local anim8 = require 'anim8'

BULLET_SPEED = 5

play = {}

local scale = 50
local scwidth, scheight = 1280, 800
local lg = love.graphics
local lt = love.timer
local floor = math.floor

local balls = {} -- table containing all of the balls
local mb = {}

local bwidth = 10 --width of the screen in buckets
local cellsize = scwidth/bwidth
local bnum = bwidth *bwidth

local buckets = {}

local showlines = true

for i = 0, bnum,1 do
	buckets[i] = {}
end


local drawList = {}
local background = {}

GameManager = {}
GameManager.bullets = {}
GameManager.zombies = {}
GameManager.survivors = {}

Entity = class('Entity')
Entity.static.ents = {}
function Entity:initialize(pos)
	self.pos = pos
	self.vel = vector(0, 0)
	self.temp = pos
	self.id = #(Entity.ents)
	self.timer = 0
	table.insert(Entity.ents, self)
end

function Entity:animUpdate(dt)
	if self.pos.x >= 1260 + scale then
		self.pos.x = 1260 + scale
	elseif self.pos.x <= 20 + scale then
		self.pos.x = 20 + scale
	end
	if self.pos.y >= 780 + scale then
		self.pos.y = 780 + scale
	elseif self.pos.y <= 20 + scale then
		self.pos.y = 20 + scale
	end
	self.timer = self.timer + dt
	if self.timer > .1 then
		if self.temp ~= self.pos then
			self.angle = math.atan2(self.temp.y - self.pos.y, self.temp.x - self.pos.x)/math.pi*180 + 180;
			self.temp = self.pos
		end
		if self.angle >= 75 and self.angle <= 105 and self.dir ~= 'down' then
			self.img = anim8.newAnimation(gmain('1-3',1), 0.2)
			self.dir = 'down'
		elseif self.angle > 150 and self.angle < 210 and self.dir ~= 'left' then
			self.img = anim8.newAnimation(gmain('1-3',4), 0.2)
			self.dir = 'left'
		elseif self.angle >= 240 and self.angle <= 300 and self.dir ~= 'up' then
			self.img = anim8.newAnimation(gmain('1-3',3), 0.2)
			self.dir = 'up'
		elseif (self.angle > 330 or self.angle < 30) and self.dir ~= 'right' then
			self.img = anim8.newAnimation(gmain('1-3',2), 0.2)
			self.dir = 'right'
		end
		self.timer = 0
	end
end

function Entity:Seek(them)
	local minDist = 200
	local closest = nil;
	for k,ent in pairs(them) do
		local distance = self.pos:dist(ent.pos)
		if distance < minDist then
			minDist = distance
			closest = ent
		end
	end
	return closest
end

GamePlayer = class('GamePlayer', Entity)
function GamePlayer:initialize(clone, pos)
	Entity.initialize(self,pos)
	self.health = clone.health
	self.img = anim8.newAnimation(gmain(1,1), 0.2)
	self.speed = 2
	self.angle = 0
	self.radius = 15
	self.temp = pos
	table.insert(GameManager.survivors, self)
end

function GamePlayer:update(dt)
	self:animUpdate(dt)
	self.img:update(dt)
	if love.keyboard.isDown("left") and love.keyboard.isDown("up") then
		self.pos = self.pos + vector(-math.sin(45), -math.sin(45)) * self.speed	
	elseif love.keyboard.isDown("right") and love.keyboard.isDown("up") then
		self.pos = self.pos + vector(math.sin(45), -math.sin(45)) * self.speed	
	elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") then
		self.pos = self.pos + vector(math.sin(45), math.sin(45)) * self.speed	
	elseif love.keyboard.isDown("left") and love.keyboard.isDown("down") then
		self.pos = self.pos + vector(-math.sin(45), math.sin(45)) * self.speed
	elseif love.keyboard.isDown("left") then
		self.pos = self.pos + vector(-1,0) * self.speed
	elseif love.keyboard.isDown("right") then
		self.pos = self.pos + vector(1,0) * self.speed
	elseif love.keyboard.isDown("up") then	
		self.pos = self.pos + vector(0, -1) * self.speed
	elseif love.keyboard.isDown("down") then	
		self.pos = self.pos + vector(0, 1) * self.speed
	end
end

function GamePlayer:draw()
	self.img:draw(main, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
end

function GamePlayer:mousepressed(x, y, button)
	if button == 1 then
		local mspos = vector(x + scale, y + scale)
		local msangle = math.atan2(mspos.y - myplayer.pos.y, mspos.x - myplayer.pos.x) -- math.rad(180)
		local xv = BULLET_SPEED * math.cos(msangle)
		local yv = BULLET_SPEED * math.sin(msangle)
		local xp = 16 * math.cos(msangle)
		local yp = 16 * math.sin(msangle)
		local b = Bullet:new(vector(myplayer.pos.x + xp, myplayer.pos.y + yp), vector(xv,yv))
	end
end

GameNPC = class('GameNPC', Entity)
GameNPC:include(Stateful)
function GameNPC:initialize(pos)
	Entity.initialize(self,pos)
	self.health = 100
	self.animID = math.random(5)
	self.img = anim8.newAnimation(gmain(1,1), 0.2)
	self.speed = 120
	self.angle = 0
	self.radius = 15
	self.dir = 'down'
	self.guntimer = 0
	table.insert(GameManager.survivors, self)
end

Follow = GameNPC:addState('Follow')
function Follow:enteredState()
end

function Follow:update(dt)
	self:animUpdate(dt)
	self.img:update(dt)
	local distance = self.pos:dist(myplayer.pos)
	if distance < 70 then
		self:gotoState('Stop')
	else
		local direction = self.pos - myplayer.pos
		self.pos = self.pos - direction:normalized() * self.speed * dt
	end	
	self:shoot(dt)
end

Stop = GameNPC:addState('Stop')
function Stop:enteredState()
end

function Stop:update(dt)
	self.img:update(dt)
	local distance = self.pos:dist(myplayer.pos)
	if distance > 100 then
		self:gotoState('Follow')
	end
	self:shoot(dt)
end

function GameNPC:shoot(dt)
	self.guntimer = self.guntimer + dt
	if self.guntimer > .2 then
		local closest = self:Seek(GameManager.zombies)
		if closest ~= nil then
			local msangle = math.atan2(closest.pos.y - self.pos.y, closest.pos.x - self.pos.x)
			local xv = BULLET_SPEED * math.cos(msangle)
			local yv = BULLET_SPEED * math.sin(msangle)
			local xp = 16 * math.cos(msangle)
			local yp = 16 * math.sin(msangle)
			local b = Bullet:new(vector(self.pos.x + xp, self.pos.y + yp), vector(xv,yv))
		end
		self.guntimer = 0
	end
end

function GameNPC:draw()
	if self.animID == 1 then
		self.img:draw(npc1, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 2 then
		self.img:draw(npc2, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 3 then
		self.img:draw(npc3, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 4 then
		self.img:draw(npc4, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 5 then
		self.img:draw(npc5, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	end
end

Zombie = class('Zombie', Entity)
Zombie:include(Stateful)
function Zombie:initialize(pos)
	Entity.initialize(self,pos)
	self.health = 100
	self.pos = pos
	self.animID = math.random(6)
	self.img = anim8.newAnimation(gmain('1-3',1), 0.2)
	self.speed = 50
	self.angle = 0
	self.radius = 15
	self.dead = false
	self.wander = 0
	self.col = false
	GameManager.zombies[#(GameManager.zombies)+1] = self
end

function Zombie:draw()
	if self.dead then
		love.graphics.draw(blood, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 1 then
		self.img:draw(zomb1, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 2 then
		self.img:draw(zomb2, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 	
	elseif self.animID == 3 then
		self.img:draw(zomb3, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 4 then
		self.img:draw(zomb4, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 5 then
		self.img:draw(zomb5, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	elseif self.animID == 6 then
		self.img:draw(zomb6, self.pos.x, self.pos.y, 0, 1, 1, 20, 20) 
	end
end

Idle = Zombie:addState('Idle')
function Idle:enteredState()
	self.speed = 10
	self.direction = self.pos - self.pos + vector(math.random(-10, 10), math.random(-10, 10))
end

function Idle:update(dt)
	self:animUpdate(dt)
	self.img:update(dt)
	local closest = self:Seek(GameManager.survivors)
	if closest then
		self:gotoState('Chase')
	else
		self.wander = self.wander + dt
		if self.wander > 4 then
			self.direction = self.pos - self.pos + vector(math.random(-10, 10), math.random(-10, 10))
			self.wander = 0
		else
			self.pos = self.pos - self.direction:normalized() * self.speed * dt
		end
	end
	if self.col == true then
		self:gotoState('Death')
	end
end

Chase = Zombie:addState('Chase')
function Chase:enteredState()
	self.speed = 50
end

function Chase:update(dt)
	self:animUpdate(dt)
	self.img:update(dt)
	local closest = self:Seek(GameManager.survivors)
	if closest then	
		local direction = self.pos - closest.pos
		self.pos = self.pos - direction:normalized() * self.speed * dt
	else
		self:gotoState('Idle')
	end
	if self.col == true then
		self:gotoState('Death')
	end
	--[[local distance = self.pos:dist(myplayer.pos)
	if distance < 40 then
		self:gotoState('Attack')
	elseif distance < 200 then
		local direction = self.pos - myplayer.pos
		self.pos = self.pos - direction:normalized() * self.speed * dt
	else
		self:gotoState('Idle')
	end]]
end

Attack = Zombie:addState('Attack')
function Attack:enteredState()
end

function Attack:update(dt)
	self:animUpdate()
	self.img:update(dt)
	local distance = self.pos:dist(myplayer.pos)
	if distance > 70 then
		self:gotoState('Chase')
	end
	if self.col == true then
		self:gotoState('Death')
	end
end

Death = Zombie:addState('Death')
function Death:enteredState()
	self.dead = true
end

function Death:update()
end

Bullet = class('Bullet')
function Bullet:initialize(pos, vel)
	self.pos = pos
	self.vel = vel
	self.radius = 2
	self.col = false
	GameManager.bullets[#(GameManager.bullets)+1] = self
end

function Bullet:update(dt)
	self.pos = self.pos + self.vel	
end

function Bullet:draw()
	love.graphics.circle("fill", self.pos.x, self.pos.y, 2, 100)
end

function play:init()
	main = love.graphics.newImage("images/Main.png")
	npc1 = love.graphics.newImage("images/NPC1.png")
	npc2 = love.graphics.newImage("images/NPC2.png")
	npc3 = love.graphics.newImage("images/NPC3.png")
	npc4 = love.graphics.newImage("images/NPC4.png")
	npc5 = love.graphics.newImage("images/NPC5.png")
	zomb1 = love.graphics.newImage("images/Z1.png")
	zomb2 = love.graphics.newImage("images/Z2.png")
	zomb3 = love.graphics.newImage("images/Z3.png")
	zomb4 = love.graphics.newImage("images/Z4.png")
	zomb5 = love.graphics.newImage("images/Z5.png")
	zomb6 = love.graphics.newImage("images/Z6.png")
	blood = love.graphics.newImage("images/blood.png")
	gmain = anim8.newGrid(40, 40, main:getWidth(), main:getHeight())
end

function play:enter()
	love.graphics.setBackgroundColor(0, .75, 0)
	love.graphics.setColor(1,1,1)
	local numZs = 300
	for i = 1,numZs do
		local target = Zombie:new(vector(math.random(20 + scale, 1260 + scale), math.random(20 + scale, 780 + scale)))
		target:gotoState('Idle')
	end
	local numNPCs = 2
	for i = 1,numNPCs do
		local npc = GameNPC:new(vector(math.random(500 + scale, 700 + scale), math.random(700 + scale, 800 + scale)))
		npc:gotoState('Stop')
	end
	myplayer = GamePlayer:new(game.player, vector(600 + scale, 750 + scale))
	for i, v in pairs(GameManager.zombies) do
		table.insert(drawList, v)
	end
	for i, v in pairs(GameManager.survivors) do
		table.insert(drawList, v)
	end
end

local function SortAndAssign()
	local ent
	local loc
	for i = 0, bnum,1 do
		buckets[i] = {} --clear the buckets
	end
	for i = 1, #GameManager.zombies do
		ent = GameManager.zombies[i]
		ent.col = false
		for x = ent.pos.x - ent.radius, ent.pos.x + ent.radius, ent.radius * 2 do
			for y = ent.pos.y - ent.radius, ent.pos.y + ent.radius, ent.radius * 2 do
				loc = floor(x / cellsize) + floor(y / cellsize) * bwidth
				buckets[loc][ent] = ent
			end
		end
	end
	for i = 1, #GameManager.survivors do
		ent = GameManager.survivors[i]
		ent.col = false
		for x = ent.pos.x - ent.radius, ent.pos.x + ent.radius, ent.radius * 2 do
			for y = ent.pos.y - ent.radius, ent.pos.y + ent.radius, ent.radius * 2 do
				loc = floor(x / cellsize) + floor(y / cellsize) * bwidth
				buckets[loc][ent] = ent
			end
		end
	end
	for i = 1, #GameManager.bullets do
		ent = GameManager.bullets[i]
		ent.col = false
		for x = ent.pos.x - ent.radius, ent.pos.x + ent.radius, ent.radius * 2 do
			for y = ent.pos.y - ent.radius, ent.pos.y + ent.radius, ent.radius * 2 do
				loc = floor(x / cellsize) + floor(y / cellsize) * bwidth
				buckets[loc][ent] = ent
			end
		end
	end
	for i = 0, bnum,1 do
		for ent in pairs(buckets[i]) do
			for other in pairs(buckets[i]) do --check each other 
				local d = ent.pos - other.pos
				if d:len() < (ent.radius + other.radius) then
					ent.pos = ent.pos + d:normalized()
					if instanceOf(Zombie, ent) and instanceOf(Bullet, other) then
						other.col = true
						if math.random(5) == 1 then
							ent.col = true
						end
					end
				end
			end
		end
	end
end

function play:update(dt)
	for i, v in pairs(drawList) do
		if v.dead then
			table.remove(drawList, i)
			table.insert(background, v)
		end
	end
	for i,ent in pairs(GameManager.bullets) do
		if ent.pos.x >= 1280 + scale or ent.pos.x <= 0 + scale or
			ent.pos.y >= 800 + scale or ent.pos.y <= 0 + scale then
			table.remove(GameManager.bullets,i)
		end
		if ent.col then
			table.remove(GameManager.bullets,i)
		end
		ent:update(dt)
	end
	for i,ent in pairs(GameManager.zombies) do
		if ent.col then
			table.remove(GameManager.zombies,i)
		end
		ent:update(dt)
	end
	for i,ent in pairs(GameManager.survivors) do
		ent:update(dt)
	end
	SortAndAssign()
end

local function drawSort(a,b) 
	return a.pos.y < b.pos.y 
end

function play:draw()
	love.graphics.translate(-scale, -scale)
	for i=1,#background do
		background[i]:draw()
	end
	table.sort(drawList, drawSort)
	for i=1,#drawList do
		drawList[i]:draw()
	end
	for i,ent in pairs(GameManager.bullets) do
		ent:draw()
	end
	love.graphics.print("FPS: "..love.timer.getFPS(), 10 + scale, 10 + scale)
	love.graphics.print("zombies: "..#GameManager.zombies, 10  + scale, 20 + scale)
	love.graphics.print("survivors: "..#GameManager.survivors, 10 + scale, 30 + scale)
	love.graphics.print("bullets: "..#GameManager.bullets, 10 + scale, 40 + scale)
end

function play:keypressed(key)
	if key == "escape" then
		for i,ent in pairs(drawList) do
			drawList[i] = nil
		end
		for i,ent in pairs(background) do
			background[i] = nil
		end
		for i,ent in pairs(GameManager.zombies) do
			GameManager.zombies[i] = nil
		end
		for i,ent in pairs(GameManager.survivors) do
			GameManager.survivors[i] = nil
		end
		for i,ent in pairs(GameManager.bullets) do
			GameManager.bullets[i] = nil
		end
		for i,ent in pairs(Entity.ents) do
			Entity.ents[i] = nil
		end
		Gamestate.switch(menu)
	end
end

function play:mousepressed(x, y, button)
	myplayer:mousepressed(x, y, button)
end