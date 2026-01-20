require "cell"

local images = {}
local gridSize = 25;
local grid = {}
local cellSize = 16
local dead = false
local bombCount = 0;
local flagCount = 0;

function love.load( )
	math.randomseed(os.time())
	-- window init
	love.window.setMode( gridSize*cellSize, gridSize*cellSize, { resizable = false, vsync = false } )
    love.window.setTitle( "Minesweeper in Lua!" )
	-- images init
	images.hidden = love.graphics.newImage( "hidden.png" );
	images.flag = love.graphics.newImage( "flag.png" );
	images.blank = love.graphics.newImage( "blank.png" );
	images.bomb_clicked = love.graphics.newImage( "bomb_clicked.png" );
	images.bomb_unclicked = love.graphics.newImage( "bomb_unclicked.png" );
	images.bomb_wrong = love.graphics.newImage( "bomb_wrong.png" );
	images["1"] = love.graphics.newImage( "1.png" );
	images["2"] = love.graphics.newImage( "2.png" );
	images["3"] = love.graphics.newImage( "3.png" );
	images["4"] = love.graphics.newImage( "4.png" );
	images["5"] = love.graphics.newImage( "5.png" );
	images["6"] = love.graphics.newImage( "6.png" );
	images["7"] = love.graphics.newImage( "7.png" );
	images["8"] = love.graphics.newImage( "8.png" );
	-- grid init
	for x = 1, gridSize do
		table.insert( grid, {} )
		for y = 1, gridSize do
			grid[x][y] = cell:new( {x,y}, images.hidden, cellSize )
		end
	end
	for x = 1, gridSize do
		for y = 1, gridSize do
			if grid[x][y].bomb then
				bombCount = bombCount + 1
			end
		end
	end
	love.window.setTitle( string.format( "%s bombs, %s flags", bombCount, flagCount ) )
end

function love.update( dt )

end

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

function getNeighbours(x, y)
	local offsets = {
		{ -- left
			x = -1,
			y = 0,
		},
		{ -- right
			x = 1,
			y = 0,
		},
		{ -- up
			x = 0,
			y = 1,
		},
		{ -- down
			x = 0,
			y = -1,
		},
		{ -- up right
			x = 1,
			y = 1,
		},
		{ -- up left
			x = -1,
			y = 1,
		},
		{ -- down right
			x = 1,
			y = -1,
		},
		{ -- down left
			x = -1,
			y = -1,
		},
	}
	local neighbours = {}
	for i, offset in ipairs(offsets) do
		if posExists(x + offset.x, y + offset.y) then
			table.insert(neighbours, grid[x + offset.x][y + offset.y])
			grid[x + offset.x][y + offset.y].color = 0
		end
	end
	return neighbours
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