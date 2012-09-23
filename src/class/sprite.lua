--[[
	SPRITE
	Handles animation and stuff. Probably the base for all sprite-based entities.
]]

class "sprite" {
	__init__ = function(self, spriteset, posX, posY)
		self.spriteset = type(spriteset) == "string" and cache.spriteset(spriteset) or spriteset
		self.animation = self.spriteset.animation or {stand = {{1, 0}}, run = {{2, 0.10}, {3, 0.10}, {4, 0.10}}, jump = {{5, 0}}, screw = {{6, 0.05}, {7, 0.05}, {8, 0.05}, {9, 0.05}}} --default animations for testing
		self.currentAnimation = "stand" --has to be done if ultimately sprites can be created in other poses
		self:setAnim("stand")
		self.animCount = 1
		self.posX = posX or 0 --world location
		self.posY = posY or 0
		self.time = love.timer.getTime()
		self.currentFrame = 1
		self.color = {255, 255, 255, 255}
		self.drawX = posX or 0 --screen location
		self.drawY = posY or 0
		self.offsetX = 0
		self.offsetY = 0
		self.offsetY2 = 0
		self.direction = "right"
		self.afterImage = {}
		self.afterImage.pos = {}
		self.afterImage.fade = 500
		self.afterImage.alpha = 255
		self.afterImage.count = 0.1
		self.afterImage.time = love.timer.getTime()
		self.enableAfterImages = true
	end,
	
	update = function(self, dt, t, offsetX, offsetY)
		--check for special animation commands (such as stop or change)
		if type(self.currentAnimation[self.animCount][2]) == "string" then
			if self.currentAnimation[self.animCount][2] == "stop" then
				self.animCount = self.animCount - 1
			else
				self:setAnim(self.currentAnimation[self.animCount][2])
				self.time = t
			end
		end
		--increase frame after the specified amount of time has passed
		local velocity = 0
		if self.velX and self.velY and not self.staticAnimation then
			velocity = (math.sqrt(self.velX ^ 2 + self.velY ^ 2) * dt) / 100
		end
		
		if t - self.time + velocity > self.currentAnimation[self.animCount][2] then
			self.time = t
			self.animCount = self.animCount + 1 <= # self.currentAnimation and self.animCount + 1 or 1
		end
		self.currentFrame = self.currentAnimation[self.animCount][1]
		--work out where to draw the sprite
		local x, y, w, h = self.spriteset.sprite[self.currentFrame]:getViewport()
		self.offsetX = offsetX or self.offsetX
		self.offsetY = offsetY or self.offsetY
		self.offsetY2 = (h % (self.height or 16)) / 2
		self.drawX = self.posX - w / 2 + self.offsetX
		self.drawY = self.posY - h / 2 + self.offsetY - self.offsetY2
		
		--flip left/right sprites if needed
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
		
		--update after images
		if self.afterImage then
			if self.enableAfterImages then
				--insert new image
				if t - self.afterImage.time >= self.afterImage.count then
					local afterImage = {posX = self.posX - w / 2, posY = self.posY - h / 2 - self.offsetY2, alpha = self.afterImage.alpha, frame = self.afterImage.frame or self.currentFrame, scaleX = self.scaleX, scaleY = self.scaleY, originX = self.originX, originY = self.originY}
					table.insert(self.afterImage.pos, afterImage)
					self.afterImage.time = t
				end
			end
			
			--update images
			for k = # self.afterImage.pos, 1, -1 do
				local afterImage = self.afterImage.pos[k]
				afterImage.drawX = afterImage.posX + offsetX
				afterImage.drawY = afterImage.posY + offsetY
				afterImage.alpha = afterImage.alpha - self.afterImage.fade * dt
				if afterImage.alpha <= 0 then table.remove(self.afterImage.pos, k) end
			end
		end

	end,
	
	draw = function(self)
		--draw after images
		love.graphics.setBlendMode("additive")
		for k, afterImage in ipairs(self.afterImage.pos) do
			love.graphics.setColor(self.color[1], self.color[2], self.color[3], afterImage.alpha)
			love.graphics.drawq(self.spriteset.img, self.spriteset.sprite[afterImage.frame], afterImage.drawX, afterImage.drawY, 0, afterImage.scaleX, afterImage.scaleY, afterImage.originX, afterImage.originY)
		end
		love.graphics.setBlendMode("alpha")
		--draw quad
		love.graphics.setColor(self.color)
		love.graphics.drawq(self.spriteset.img, self.spriteset.sprite[self.currentFrame], self.drawX, self.drawY, 0, self.scaleX, self.scaleY, self.originX, self.originY)
	end,
	
	setAnim = function(self, newAnimation)
		self.animCount = self.animation[newAnimation] == self.currentAnimation and self.animCount or 1 --reset to first frame if new animation is given
		self.currentAnimation = self.animation[newAnimation] or self.currentAnimation
	end
}