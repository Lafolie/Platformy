--[[
	SPRITE
	Handles animation and stuff. Probably the base for all sprite-based entities.
]]

class "sprite" {
	__init__ = function(self, spriteset, animation, posX, posY)
		self.spriteset = spriteset
		self.animation = animation or {["stand"] = {{1, 0}}, ["run"] = {{2, 0.10}, {3, 0.10}, {4, 0.10}}, ["jump"] = {{5, 0}}, ["screw"] = {{6, 0.05}, {7, 0.05}, {8, 0.05}, {9, 0.05}}} --default animations for testing
		self.currentAnimation = "stand" --has to be done if ultimately sprites can be created in other poses
		self:setAnim("stand")
		self.animCount = 1
		self.posX = posX or 0 --world location
		self.posY = posY or 0
		self.time = love.timer.getTime()
		self.currentFrame = 1
		self.color = {255, 255, 255, 255}
		self.drawX = 0 --screen location
		self.drawY = 0
		self.offsetX = 0
		self.offsetY = 0
		self.direction = "right"
	end,
	
	update = function(self, dt, t, offsetX, offsetY)
		if t - self.time > self.currentAnimation[self.animCount][2] then
			self.currentFrame = self.currentAnimation[self.animCount][1]
			self.time = love.timer.getTime()
			self.animCount = self.animCount + 1 <= # self.currentAnimation and self.animCount + 1 or 1
		end
		local x, y, w, h = self.spriteset.sprite[self.currentFrame]:getViewport()
		self.offsetX = offsetX or self.offsetX
		self.offsetY = offsetY or self.offsetY
		self.drawX = self.posX - w / 2 + self.offsetX
		self.drawY = self.posY - h / 2 + self.offsetY
		
		if self.direction == "right" then
			self.scaleX = 1
			self.scaleY = 1
			self.originX = 0
			self.originY = 0
		elseif self.direction == "left" then
			self.scaleX = -1
			self.scaleY = 1
			self.originX = w
			self.originY = 0
		end

	end,
	
	draw = function(self)
		love.graphics.setColor(self.color)
		love.graphics.drawq(self.spriteset.img, self.spriteset.sprite[self.currentFrame], self.drawX, self.drawY, 0, self.scaleX, self.scaleY, self.originX, self.originY)
		--debug stuff--------------------------------------
		if debugMode then
			love.graphics.setLineStyle("rough")
			love.graphics.setColor(255, 100, 25, 150)
			love.graphics.line(self.posX, 0, self.posX, love.graphics.getHeight())
			love.graphics.line(0, self.posY, love.graphics.getWidth(), self.posY)
			love.graphics.setColor(255, 255, 25, 150)
			love.graphics.line(self.drawX, 0, self.drawX, love.graphics.getHeight())
			love.graphics.line(0, self.drawY, love.graphics.getWidth(), self.drawY)
		end
	end,
	
	setAnim = function(self, newAnimation)
		self.animCount = self.animation[newAnimation] == self.currentAnimation and self.animCount or 1 --reset to first frame if new animation is given
		self.currentAnimation = self.animation[newAnimation] or self.currentAnimation
	end
}