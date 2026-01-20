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
local running = true
local winner = false
local failTimer = 1
local startTime = 0
local endTime = 0

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
	"unknown",
}

function love.load( )
	
	-- window init
	local seed = os.time()
	math.randomseed(seed)
	print("Seed:", seed)
	
	love.window.setMode(gridSize*cellSize, gridSize*cellSize)
	
	-- images init
	for _, v in ipairs(imagesList) do
		images[v] = love.graphics.newImage(v .. ".png")
		print("Loaded: " .. v .. ".png")
	end
	
	-- grid init
	createGrid()
	
end

function createGrid()
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
	print(("Generated %sx%s minefield with %s bombs"):format(gridSize, gridSize, bombCount))
	startTime = os.clock()
end

function love.update( dt ) end

function love.draw( )
	love.graphics.setColor( 1, 1, 1 )
	for x = 1, gridSize do
		for y = 1, gridSize do
			grid[x][y]:draw()
		end
	end	
	if not running then
		failTimer = math.max(0, failTimer-(1/60)/2)
		love.graphics.setColor( 0, 0, 0, 0.75-failTimer*0.75 )
		love.graphics.rectangle("fill", 0, 0, gridSize*cellSize, gridSize*cellSize)
		if failTimer <= 0 then
			love.graphics.setColor( 1, 1, 1 )
			local text = "YOU LOSE!!!"
			if success then
				text = "YOU WIN!!!"
			end
			local dist = gridSize*cellSize
			love.graphics.print(text, (dist/2)-25, dist/2 - dist*0.1)
			love.graphics.print("Time: " .. tostring(endTime) .. "s", (dist/2)-30, dist/2)
			love.graphics.print("Press space to play again", (dist/2)-70, dist/2 + dist*0.1)
		end
	end
end

function endGame(win)
	running = false
	success = win
	failTimer = 1
	endTime = os.clock()-startTime
	print("Game over, won: " .. tostring(win).. ", time: " .. tostring(endTime))
end

function love.keypressed(key)
    if failTimer <= 0 and not running then 
		if key == "space" then
			grid = {}
			dead = false
			bombCount = 0
			flagCount = 0
			running = true
			winner = false
			failTimer = 1
			startTime = 0
			endTime = 0
			createGrid()
		end
	end
end

function love.mousepressed(x, y, button)
	if not dead then
		if button == 1 then
			local gridX, gridY = getGridPos(x, y)
			local thisGrid = grid[gridX][gridY]
			if thisGrid.flag or thisGrid.unknown then
				return;
			end
			grid[gridX][gridY].hidden = false
			grid[gridX][gridY]:updateImage(images)
			if grid[gridX][gridY].bomb then
				dead = true
				love.window.setTitle( "GAME OVER" )
				endGame(false)
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
			if getHiddenCount() == bombCount then
				endGame(true)
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
		elseif button == 3 then
			local gridX, gridY = getGridPos(x, y)
			if grid[gridX][gridY].hidden then
				grid[gridX][gridY].unknown = not grid[gridX][gridY].unknown
				grid[gridX][gridY]:updateImage(images)
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

function getHiddenCount()
	local count = 0
	for x = 1, gridSize do
		for y = 1, gridSize do
			if grid[x][y].hidden then
				count = count + 1
			end
		end
	end	
	return count
end

function posExists(x, y)
	return x > 0 and y > 0 and x < gridSize+1 and y < gridSize+1
end
