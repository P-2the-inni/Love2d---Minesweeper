local cell = {}
cell.__index = cell

local getBomb = function()
	return math.random(6) == 1
end

local getBombCount = function(cellList)
	local count = 0
	for i, n in ipairs(cellList) do
		if n.bomb then
			count = count + 1
		end
	end
	return count
end

function cell:new(pos, image, size)
	local o = { 
		position = pos,
		hidden = true,
		image = image,
		size = size,
		flag = false,
		unknown = false,
		bomb = getBomb(),
	}
	return setmetatable(o, self)
end

function cell:draw()
	love.graphics.draw(self.image, (self.position[1]-1)*self.size, (self.position[2]-1)*self.size, 0, (self.size/16)/2, (self.size/16)/2)
end

function cell:updateImage()
	if self.flag then
		self.image = images.flag
	elseif self.unknown then
		self.image = images.unknown
	elseif self.hidden then
		self.image = images.hidden
	elseif self.bomb then
		self.image = images.bomb_clicked
	elseif not self.hidden then
		self:updateCell()
	end
end

function cell:updateCell()
	local neighbours = getNeighbours(self.position[1], self.position[2])
	local count = getBombCount(neighbours)
	if count == 0 then
		self.image = images.blank
		for i, n in ipairs(neighbours) do
			if n.hidden and not n.flag and not n.unknown then
				n.hidden = false
				n:updateImage(images)
			end
		end
	else
		self.image = images[tostring(count)]
	end
end

return cell
