cell = {}
cell.mt = {
	__index = {
		draw = function(self)
			love.graphics.draw( self.image, (self.position[1]-1)*self.size, (self.position[2]-1)*self.size, 0, (self.size/16)/2, (self.size/16)/2 )
		end,
		updateImage = function(self, img)
			if self.flag then
				self.image = img.flag
			elseif self.hidden then
				self.image = img.hidden
			elseif self.bomb then
				self.image = img.bomb_clicked
			elseif not hidden then
				updateCell(self)
			end
		end
	}
}

cell.getBomb = function()
	return math.random(6) == 1
end

function cell:new( pos, image, size )
	local o = { 
		position = pos,
		hidden = true,
		image = image,
		size = size,
		flag = false,
		bomb = self.getBomb(),
		color = 1
	}
	return setmetatable( o, self.mt )
end