Bird = Class{}

local GRAVITY = 20
--only one bird so we can init
function Bird:init()
    self.image = love.graphics.newImage('assets/image/bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.x = VIRTUAL_WIDTH/2  - self.width/2
    self.y = VIRTUAL_HEIGHT/2 - self.height/2
    self.dy = 0
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt 

    if love.keyboard.wasPressed('q') then
        self.dy = -5
        sounds['jump']:play()
    end
    self.y = self.y + self.dy
    
end

function Bird:collide(tower)
    --check upper
    if tower.x + tower.width < self.x or self.x + self.width - 2 < tower.x then
        return false
    end
    if tower.y + tower.height < self.y + 5 or self.y + self.height < tower.y then
        return false
    end

    return true
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end

