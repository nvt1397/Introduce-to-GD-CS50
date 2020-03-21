Tower = Class{}

--reference rather than allocate many building image in memory
local TOWER_IMAGE = love.graphics.newImage('assets/image/tower.png')
TOWER_SPEED = 60

--globally accessible
TOWER_HEIGHT = TOWER_IMAGE:getHeight()
TOWER_WIDTH = TOWER_IMAGE:getWidth()


function Tower:init(orientation, y)
    self.x = VIRTUAL_WIDTH
    self.y = y

    self.width = TOWER_WIDTH
    self.height = TOWER_HEIGHT
    self.orientation = orientation
end

function Tower:update(dt)

end

function Tower:render()
    love.graphics.draw(
        TOWER_IMAGE, 
        self.x, 
        (self.orientation == 'top' and self.y + TOWER_HEIGHT or self.y), 
        0, --roration
        1, --xScale
        self.orientation == 'top' and -1 or 1 --yScale
    )
end