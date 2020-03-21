PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.bird = Bird()
    self.towerPairs = {}
    self.timer = 0
    self.lastY = -TOWER_HEIGHT + math.random(20, 100)
    self.score = 0
    self.pause = false
end

function PlayState:update(dt)
    --instantiate new tower and add it to table
    if love.keyboard.wasPressed('p') then
        if self.pause == false then
            self.pause = true
        else
            self.pause = false
        end
    end

    if self.pause == false then
        self.timer = self.timer + dt * 10
        if self.timer > 30 then
            local y = math.max(-TOWER_HEIGHT + 10, math.min(self.lastY + math.random(-90,90), VIRTUAL_HEIGHT - 90 - TOWER_HEIGHT))
            self.lastY = y
            table.insert(self.towerPairs, TowerPair(y))
            self.timer = math.random(0,5)
        end

        --game update
        self.bird:update(dt)
        --check score condition
        for k, pair in pairs(self.towerPairs) do
            if not pair.scored then
                if pair.x + TOWER_WIDTH < self.bird.x then
                    sounds['hit']:play()
                    self.score = self.score + 1
                    pair.scored = true
                end
            end
            pair:update(dt)
        end

        for k, pair in pairs(self.towerPairs) do
            if pair.remove then
                table.remove(self.towerPairs, k)
            end

        end

        --check collide
        for k, pair in pairs(self.towerPairs) do
            for l, tower in pairs(pair.towers) do
                if self.bird:collide(tower) then
                    gStateMachine:change('score', {score = self.score})
                    sounds['lose']:play()
                end
            end
        end
 
        if self.bird.y > VIRTUAL_HEIGHT - 15 or self.bird.y < -15 then
            gStateMachine:change('score', {score = self.score})
            sounds['lose']:play()
        end
    end    
end

function PlayState:render()
    --draw tower
    if self.pause == false then
        for k, pair in pairs(self.towerPairs) do
            pair:render() 
        end

        love.graphics.setFont(smallFont)
        love.graphics.print('Score: '.. tostring(self.score), 10, 10)

        self.bird:render()
    else
        love.graphics.setFont(hugeFont)
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
    end
end