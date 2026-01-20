require "cell"

-- global
images = {}

-- local
local gridSize = 25
local grid = {}
local cellSize = 16
local dead = false
local bombCount = 0
local flagCount = 0

local imagesList = {
	"hidden",
	"flag",
	"blank",
	"bomb_clicked",
	"bomb_unclicked",
	"bomb_wrong",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
}

function love.load( )
	
	-- window init
	local seed = os.time()
	math.randomseed(seed)
	print("Seed:", seed)
	
	love.window.setMode(gridSize*cellSize, gridSize*cellSize, { resizable = false, vsync = false })
	
	-- images init
	for _, v in ipairs(imagesList) do
		images[v] = love.graphics.newImage(v .. ".png")
	end
	
	-- grid init
	for x = 1, gridSize do
		table.insert(grid, {})
		for y = 1, gridSize do
			grid[x][y] = cell:new({x,y}, images.hidden, cellSize)
		end
	end
	for x = 1, gridSize do
		for y = 1, gridSize do
			if grid[x][y].bomb then
				bombCount = bombCount + 1
			end
		end
	end
	
	love.window.setTitle(string.format("%s bombs, %s flags", bombCount, flagCount))
	print("Generated map with " .. tostring(bombCount) .. " number of bombs")
end

function love.update( dt ) end

function love.draw( )
	love.graphics.setColor( 1, 1, 1 )
	for x = 1, gridSize do
		for y = 1, gridSize do
			grid[x][y]:draw()
		end
	end	
end

function love.mousepressed(x, y, button)
	if not dead then
		if button == 1 then
			local gridX, gridY = getGridPos(x, y)
			local thisGrid = grid[gridX][gridY]
			if thisGrid.flag then
				return;
			end
			grid[gridX][gridY].hidden = false
			grid[gridX][gridY]:updateImage(images)
			if grid[gridX][gridY].bomb then
				dead = true
				love.window.setTitle( "GAME OVER" )
				print("Game over, " .. flagCount .. " flags placed")
				for x = 1, gridSize do
					for y = 1, gridSize do
						local c = grid[x][y]
						if c.flag and not c.bomb then
							c.image = images.bomb_wrong
						elseif c.bomb and not c.flag and c.hidden then
							c.image = images.bomb_unclicked
						end
					end
				end	
			end
		elseif button == 2 then
			local gridX, gridY = getGridPos(x, y)
			if grid[gridX][gridY].hidden then
				grid[gridX][gridY].flag = not grid[gridX][gridY].flag
				grid[gridX][gridY]:updateImage(images)
				if grid[gridX][gridY].flag then
					flagCount = flagCount + 1
				else
					flagCount = flagCount - 1
				end
				love.window.setTitle( string.format( "%s bombs, %s flags", bombCount, flagCount ) )
			end
		end
	end
end

function getGridPos(x, y)
	local gridX, gridY = (x+cellSize)/cellSize, (y+cellSize)/cellSize;
	return math.floor(gridX), math.floor(gridY)
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

function getNeighbours(x, y)
	local neighbours = {}
	for i, offset in ipairs(offsets) do
		if posExists(x + offset[1], y + offset[2]) then
			table.insert(neighbours, grid[x + offset[1]][y + offset[2]])
			grid[x + offset[1]][y + offset[2]].color = 0
		end
	end
	return neighbours
end

function getBombCount(neighbours)
	local count = 0
	for i, n in ipairs(neighbours) do
		if n.bomb then
			count = count + 1
		end
	end
	return count
end

function posExists(x, y)
	return x > 0 and y > 0 and x < gridSize+1 and y < gridSize+1
end
