ScoreState = Class{__includes = BaseState}

local bronze_img = love.graphics.newImage('assets/image/bronze_medal.png') 
local silver_img = love.graphics.newImage('assets/image/silver_medal.png') 
local gold_img = love.graphics.newImage('assets/image/gold_medal.png') 


function ScoreState:enter(params)
    self.score = params.score
    if self.score > BEST_SCORE then
        BEST_SCORE = self.score
    end
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('title')
    end
end

function ScoreState:render()
    love.graphics.setFont(font)
    if BEST_SCORE >= 10 then
        love.graphics.draw(bronze_img, VIRTUAL_WIDTH/3 + 20, 50, 0, 0.1, 0.1)
        love.graphics.print('10 SCORES', VIRTUAL_WIDTH/3 + 13, 80)
    end
    if BEST_SCORE >= 50 then
        love.graphics.draw(silver_img, VIRTUAL_WIDTH/3 + 70, 50, 0, 0.1, 0.1)
        love.graphics.print('50 SCORES', VIRTUAL_WIDTH/3 + 63, 80)
    end
    if BEST_SCORE >= 100 then
        love.graphics.draw(gold_img, VIRTUAL_WIDTH/3 + 120, 50, 0, 0.1, 0.1)
        love.graphics.print('100 SCORES', VIRTUAL_WIDTH/3 + 113, 80)
    end

    love.graphics.setFont(smallFont)
    love.graphics.printf('YOU LOSED', 0, VIRTUAL_HEIGHT/2 - 30 , VIRTUAL_WIDTH, 'center')
    love.graphics.printf('BEST SCORE: '.. tostring(BEST_SCORE), 10, 10, VIRTUAL_WIDTH, 'left')
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: '.. tostring(self.score), 0, VIRTUAL_HEIGHT/2 - 10, VIRTUAL_WIDTH, 'center')
end