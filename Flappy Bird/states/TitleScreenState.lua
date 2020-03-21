TitleScreenState = Class{__includes = BaseState} --inheritance

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function TitleScreenState:render()
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Flappy Bird - CS50', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter to start...', 0, 100, VIRTUAL_WIDTH, 'center')
end