push = require 'push'
Class = require 'class'

require 'random'
require 'paddle'
require 'ball'

math.randomseed(os.time())

--set window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 384

--paddle speed - multiplied by dt in updates
PADDLE_SPEED = 150

function love.resize(w, h)
    push:resize(w, h)
end

--override love functions
function love.load()
    love.window.setTitle('Pong - CS50')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    --font
    font = love.graphics.newFont('consola.ttf', 12)
    bigfont = love.graphics.newFont('consola.ttf', 20)
    scorefont = love.graphics.newFont('consola.ttf', 50)
    --sound --index by this table --example sounds['select'] or sounds.select (wont work with string that have whitespace)
    sounds = {
        ['select'] = love.audio.newSource('sounds/select.wav','static'),
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
        ['scored'] = love.audio.newSource('sounds/scored.wav','static')
    }
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    ------------------------------------------
    --seed
    math.randomseed(os.time())
    --pop some random number for better random
    math.random()
    math.random()
    math.random()
    ------------------------------------------

    --tracking score
    player1_score = 0
    player2_score = 0

    --player
    player1 = Paddle(10, VIRTUAL_HEIGHT/2 - 50, 5, 40)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT/2 + 50, 5, 40)

    --ball
    ball = Ball(VIRTUAL_WIDTH / 2 - 6, VIRTUAL_HEIGHT / 2 - 6, 6, 6)
    winner = 0
    --serving player 1 or 2
    servingPlayer = 1
    --GAME STATE --start --chooseMode --side --serve -play --over 
    gameState = 'start'
    mode = 1
    botState = 'wait'
    maxScore = 10
end

function displayFPS()
    love.graphics.setFont(font)
    love.graphics.setColor(0.3, 0.3, 1, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 10)
    --for test
    --love.graphics.setColor(1, 0, 0, 1)
    --love.graphics.print(botState, VIRTUAL_WIDTH - 60, 10)
end

function displayScore()
    --score
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(scorefont)
        --p1 score
    love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH/2 - 100, VIRTUAL_HEIGHT/3)
        --p2 score
    love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH/2 + 80, VIRTUAL_HEIGHT/3)
end

function gameReset()
    player1_score = 0
    player2_score = 0
    if winner == 1 then
        servingPlayer = 2
    elseif winner == 2 then
        servingPlayer = 1
    end    
    winner = 0
    mode = 1
    botState = 'wait'
    maxScore = 10
end

function displaySelectMode()
    --choose mode
    love.graphics.setFont(font)
    love.graphics.printf("CHOOSE MODE", VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6 - 20, VIRTUAL_WIDTH, 'left')
    love.graphics.printf("ONE PLAYER", VIRTUAL_WIDTH/3 + 20 , VIRTUAL_HEIGHT/6, VIRTUAL_WIDTH, 'left')
    love.graphics.printf("TWO PLAYERS", VIRTUAL_WIDTH/3 + 20 , VIRTUAL_HEIGHT/6 + 20, VIRTUAL_WIDTH, 'left')
    love.graphics.printf("PRESS UP/DOWN TO CHOOSE MODE", VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'left')
    love.graphics.printf("PRESS 1/2/3 TO CHOOSE NUMBER OF ROUNDS", VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'left')
    if mode == 1 then
        love.graphics.polygon('fill', VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6, VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6 + 10, VIRTUAL_WIDTH/3 + 10, VIRTUAL_HEIGHT/6 + 5)
    else    
        love.graphics.polygon('fill', VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6 + 20, VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6 + 30, VIRTUAL_WIDTH/3 + 10, VIRTUAL_HEIGHT/6 + 25)
    end
    love.graphics.printf("NUMBER OF ROUNDS: ", VIRTUAL_WIDTH/3, VIRTUAL_HEIGHT/6 + 40, VIRTUAL_WIDTH, 'left')
    if maxScore == 10 then
        love.graphics.printf("10", VIRTUAL_WIDTH/3 + 140 , VIRTUAL_HEIGHT/6 + 40, VIRTUAL_WIDTH, 'left')
    elseif maxScore == 20 then
        love.graphics.printf("20", VIRTUAL_WIDTH/3 + 140 , VIRTUAL_HEIGHT/6 + 40, VIRTUAL_WIDTH, 'left')
    else 
        love.graphics.printf("30", VIRTUAL_WIDTH/3 + 140 , VIRTUAL_HEIGHT/6 + 40, VIRTUAL_WIDTH, 'left')
    end
end
function love.keypressed(key)
    if key == 'escape' then
        gameState ='start'
        ball:reset()
        gameReset()
    elseif key == 'return' or key == 'enter' then
        if gameState == 'start' then                  
            gameState = 'chooseMode'
        elseif gameState == 'chooseMode' then 
            gameState = 'serve'     
        elseif gameState == 'serve' then 
            gameState = 'play'
        elseif gameState == 'over' then
            gameState = 'start'
            ball:reset()
            gameReset()    
        end        
    end
    if gameState == 'chooseMode' then
        if mode == 1 and key == 'down' then
            mode = 2
        elseif mode == 2 and key == 'up' then
            mode = 1
        end
        if key == '1' then
            maxScore = 10
        elseif key == '2' then
            maxScore = 20
        elseif key == '3' then
            maxScore = 30
        end
    end
end   

function controller(up, down, paddle)
    if love.keyboard.isDown(up) then
       paddle.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown(down) then
        paddle.dy = PADDLE_SPEED
    else
        paddle.dy = 0
    end
end


function p2AI()
    ---TODO: implement simple pong AI for right side
    prob = -1
    align = 0
    err = 0
    --change game state
    if gameState == 'serve' then
        botState = 'wait'
    elseif gameState == 'play' then 
        if ball.dx < 0 then
            if botState == 'wait' then
                botState = 'ready'
            elseif botState == 'ready' then
                prob = math.random(0,100)
                align = math.random(-15, 35)
                err = math.random(-50,50)
                -- random behaviour
                if prob > 30 then
                    botState = 'wander'
                elseif prob >= 0 and prob < 30 then
                    botState = 'mimic'
                end
            elseif botState == 'predict' then
                botState = 'ready'
            end
        else
            botState = 'predict'
        end
    end
    --move
    if botState == 'wait' then
        player2.dy = 0
    elseif botState == 'wander' then --move to random position near center
        if player2.y < VIRTUAL_HEIGHT/2 + 30 + align then
            player2.dy = PADDLE_SPEED
        elseif player2.y > VIRTUAL_HEIGHT/2 + 30 + align then
            player2.dy = -PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif botState == 'mimic' then --move to random position near player
        if player2.y < player1.y + player1.height/2 + align then
            player2.dy = PADDLE_SPEED
        elseif player2.y > player1.y + player1.height/2 + align then
            player2.dy = -PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif botState == 'predict' then --predict ball position and move
        --TODO:
        if math.abs(ball.y - (player2.y + player2.height / 2) )  < 30 then
            --Dont have to move
            player2.dy = 0;
        end

        if ball.y < player2.y + (player2.height / 2) + err then
            player2.dy = - PADDLE_SPEED;
        else
            player2.dy = PADDLE_SPEED;
        end
    end
end

function math.clamp(n, low, high) return math.min(math.max(n, low), high) end

function love.update(dt)
    if mode == 1 then
        controller('w', 's', player1)
        p2AI()
    elseif mode == 2 then
        controller('w', 's', player1)
        controller('up','down', player2)
    end
    --ball movement
    if gameState == 'serve' then
        --initialize ball's velocity based on player who last scored
        ball.dy = math.random(-75,75)
        if servingPlayer == 1 then
           ball.dx = math.random(180,230)
        else
            ball.dx = -math.random(180,230)
        end

    elseif gameState == 'play' then
        --check collision
        ball.dx = math.clamp(ball.dx,-500, 500)

        if ball:collides(player1) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.06
            ball.x = player1.x + 5 --bouncing effect - avoid double collision check in next frame; 5 = paddle width
            if ball.dy < 0 then
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.06
            ball.x = player2.x - 6 -- avoid double collision check but 6 = ball width
            if ball.dy < 0 then
                ball.dy = - math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end
        --wall collision
        if ball.y <= 0 then
            sounds['wall_hit']:play()
            ball.y = 0
            ball.dy = - ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 6 then
            sounds['wall_hit']:play()
            ball.y = VIRTUAL_HEIGHT - 6
            ball.dy = - ball.dy
        end

        if ball.x < 0 then
            sounds['scored']:play()
            servingPlayer = 1
            player2_score = player2_score + 1
            if player2_score == maxScore then
                winner = 2
                gameState = 'over'
            else    
                ball:reset()
                gameState = 'serve'
            end    
        elseif ball.x > VIRTUAL_WIDTH - 6 then
            sounds['scored']:play()
            servingPlayer = 2
            player1_score = player1_score + 1
            if player1_score == maxScore then
                winner = 1
                gameState = 'over'
            else    
                ball:reset()
                gameState = 'serve'
            end
        end

        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end
--draw text which player will serve
function drawServePlayer()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(bigfont)
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",  0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(font)
    love.graphics.printf('Press Enter to serve!', 0, 40, VIRTUAL_WIDTH, 'center')
end
--draw middle line
function drawMiddleLine()
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle('line', VIRTUAL_WIDTH/2 - 3, 0, 0.5, VIRTUAL_HEIGHT)
end
--draw game over screen
function drawGameOver()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(bigfont)
    love.graphics.printf('The winner is player ' .. tostring(winner), 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(font)
    love.graphics.printf('Press Enter to restart!', 0, 40, VIRTUAL_WIDTH, 'center')
end

function love.draw()
    push:apply('start')
    --background
    --love.graphics.clear(0.16, 0.18, 0.2, 1)
    love.graphics.clear(rand(),rand(),rand(),0.3)
    --title
    if gameState == 'start' then
        love.graphics.setFont(bigfont)
        love.graphics.printf("CS50: Lession 1 - Pong", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(font)
        love.graphics.printf("Press Enter to start ...", 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'chooseMode' then
        love.graphics.printf("CS50: Lession 1 - Pong", 0, 6, VIRTUAL_WIDTH, 'center')
        displaySelectMode()
    elseif gameState == 'serve' then
        drawMiddleLine()
        drawServePlayer()
        displayScore()
    elseif gameState == 'play' then
        drawMiddleLine()
        displayScore()
        -- no UI messages to display in play
    elseif gameState == 'over' then
        drawGameOver()
    end

    displayFPS()

    --draw paddles and ball
    love.graphics.setColor(1, 1, 1, 1)
    if gameState == 'start' or gameState == 'chooseMode' or gameState == 'over' then
    else
        --paddle 1
        player1:render()
        --paddle 2
        player2:render()
        --ball
        love.graphics.setColor(0, 1, 0.1, 1)
        ball:render()
    end
    push:apply('end')
end