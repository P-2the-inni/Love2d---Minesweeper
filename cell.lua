cell = {}
cell.mt = {
	__index = {
		draw = function(self)
			love.graphics.draw(self.image, (self.position[1]-1)*self.size, (self.position[2]-1)*self.size, 0, (self.size/16)/2, (self.size/16)/2)
		end,
		updateImage = function(self, img)
			if self.flag then
				self.image = img.flag
			elseif self.hidden then
				self.image = img.hidden
			elseif self.bomb then
				self.image = img.bomb_clicked
			elseif not self.hidden then
				updateCell(self)
			end
		end
	}
}

cell.getBomb = function()
	return math.random(6) == 1
end

function cell:new(pos, image, size)
	local o = { 
		position = pos,
		hidden = true,
		image = image,
		size = size,
		flag = false,
		unknown = false,
		bomb = self.getBomb(),
		color = 1
	}
	return setmetatable(o, self.mt)
end

function updateCell(c)
	local neighbours = getNeighbours(c.position[1], c.position[2])
	local count = getBombCount(neighbours)
	if count == 0 then
		c.image = images.blank
		for i, n in ipairs(neighbours) do
			if n.hidden then
				n.hidden = false
				n:updateImage(images)
			end
		end
	else
		c.image = images[tostring(count)]
	end
end

