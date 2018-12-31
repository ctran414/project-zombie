

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
	self:handleCollision(Entity.ents)
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

function GamePlayer:animUpdate(dt)
	if self.temp ~= self.pos then
		self.angle = math.atan2(self.pos.y - self.temp.y, self.pos.x - self.temp.x)/math.pi*180 + 180;
		self.temp = self.pos
	end
	if self.angle >= 45 and self.angle <= 135 and self.dir ~= 'up' then
		self.img = anim8.newAnimation(gmain('1-3',3), 0.2)
		self.dir = 'up'
	elseif self.angle > 135 and self.angle < 225 and self.dir ~= 'right' then
		self.img = anim8.newAnimation(gmain('1-3',2), 0.2)
		self.dir = 'right'
	elseif self.angle >= 225 and self.angle <= 315 and self.dir ~= 'down' then
		self.img = anim8.newAnimation(gmain('1-3',1), 0.2)
		self.dir = 'down'
	elseif (self.angle > 315 or self.angle < 45) and self.dir ~= 'left' then
		self.img = anim8.newAnimation(gmain('1-3',4), 0.2)
		self.dir = 'left'
	end
end