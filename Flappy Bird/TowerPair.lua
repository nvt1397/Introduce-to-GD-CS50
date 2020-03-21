TowerPair = Class{}

--TODO:
--local GAP_HEIGHT = 90

function TowerPair:init(y)
    self.x = VIRTUAL_WIDTH
    self.y = y
    self.towers = {
        ['upper'] = Tower('top', self.y),
        ['lower'] = Tower('bottom', self.y + TOWER_HEIGHT + math.random(85,85))
    }
    self.remove = false
    self.scored = false
end

function TowerPair:update(dt)
    if self.x > -TOWER_WIDTH then
        self.x = self.x - TOWER_SPEED * dt
        self.towers['lower'].x = self.x
        self.towers['upper'].x = self.x
    else
        self.remove = true
    end
end

function TowerPair:render()
    for k, tower in pairs(self.towers) do
        tower:render()
    end
end