-- util --

local getBomb = function()
	return math.random(6) == 1
end

local posExists = function(x, y, gridSize)
	return x > 0 and y > 0 and x < gridSize+1 and y < gridSize+1
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

-- cell class --

local cell = {}
cell.__index = cell

function cell:new(pos, initialImage, size)
	local o = { 
		position = pos,
		hidden = true,
		image = initialImage,
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

function cell:updateImage(images, grid)
	if self.flag then
		self.image = images.flag
	elseif self.unknown then
		self.image = images.unknown
	elseif self.hidden then
		self.image = images.hidden
	elseif self.bomb then
		self.image = images.bomb_clicked
	elseif not self.hidden then
		self:reveal(images, grid, #grid)
	end
end

function cell:reveal(images, grid)
	local neighbours = self:getNeighbours(grid, #grid)
	local count = getBombCount(neighbours)
	if count == 0 then
		self.image = images.blank
		for i, n in ipairs(neighbours) do
			if n.hidden and not n.flag and not n.unknown then
				n.hidden = false
				n:updateImage(images, grid, #grid)
			end
		end
	else
		self.image = images[tostring(count)]
	end
end

local offsets = {
	{-1,0},
	{1,0},
	{0,1},
	{0,-1},
	{1,1}, 
	{-1,1}, 
	{1,-1}, 
	{-1,-1},
}

function cell:getNeighbours(grid)
	local neighbours = {}
	for i, offset in ipairs(offsets) do
		local checkX, checkY = self.position[1] + offset[1], self.position[2] + offset[2]
		if posExists(checkX, checkY, #grid) then
			table.insert(neighbours, grid[checkX][checkY])
		end
	end
	return neighbours
end

return cell
