push = require 'push'
Class = require 'class'


require 'Bird'
require 'Tower'
require 'TowerPair'

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/CountdownState'
require 'states/ScoreState'
require 'states/TitleScreenState'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- images we load into memory from files to later draw onto the screen
local skyBackground = love.graphics.newImage('assets/image/background1.png') --sky
local mountainBackground = love.graphics.newImage('assets/image/background2.png') --mountain
local forestBackground = love.graphics.newImage('assets/image/background3.png') --forest
local cloudBackground = love.graphics.newImage('assets/image/background4.png') --cloud
local buildingBackground = love.graphics.newImage('assets/image/background5.png') --buildings
local skyScroll = 0
local mountainScroll1 = 0
local mountainScroll2 = 0
local forestScroll1 = 0
local forestScroll2 = 0
local cloudScroll1 = 0
local cloudScroll2 = 0
local buildingScroll = 0

local ground = love.graphics.newImage('assets/image/ground.png')
local groundScroll = 0

local SKY_BG_SPEED = 10
local MOUNTAIN_BG_SPEED = 20
local FOREST_BG_SPEED = 50
local CLOUD_BG_SPEED = 30
local BUILDING_BG_SPEED = 100
local GROUND_SPEED = 200

local SKY_LOOPING_POINT = 124
local MOUNTAIN_LOOPING_POINT = 191.5
local FOREST_LOOPING_POINT = 127.6
local CLOUD_LOOPING_POINT = 1395
local BUILDING_LOOPING_POINT = 512

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- app window title
    love.window.setTitle('Flappy Bird - CS50')

    --
    font = love.graphics.newFont('assets/font/font.ttf', 8)
    smallFont = love.graphics.newFont('assets/font/flappy.ttf', 14)
    mediumFont = love.graphics.newFont('assets/font/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('assets/font/flappy.ttf', 56)
    love.graphics.setFont(mediumFont)

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    sounds = {
        ['jump'] = love.audio.newSource('assets/sound/jump.wav','static'),
        ['countdown'] = love.audio.newSource('assets/sound/countdown.wav','static'),
        ['hit'] = love.audio.newSource('assets/sound/hit.wav','static'),
        ['lose'] = love.audio.newSource('assets/sound/lose.wav','static'),
        
        --https://freesound.org/people/DirtyJewbs/sounds/137227/
        ['theme'] = love.audio.newSource('assets/sound/theme.mp3','static')
    }
    
    sounds['theme']:setLooping(true)
    sounds['theme']:play()
    
    BEST_SCORE = 0
    --initialize
    gStateMachine = StateMachine{   --name convention -g prefix for global variable
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,

    }
    gStateMachine:change('title')

    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.isDown(key)
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    --background update
    skyScroll = (skyScroll + SKY_BG_SPEED * dt) % SKY_LOOPING_POINT
    mountainScroll1 = (mountainScroll1 + MOUNTAIN_BG_SPEED * dt) % MOUNTAIN_LOOPING_POINT
    mountainScroll2 = (mountainScroll2 + (MOUNTAIN_BG_SPEED +5) * dt) % MOUNTAIN_LOOPING_POINT
    forestScroll1 = (forestScroll1 + FOREST_BG_SPEED * dt) % FOREST_LOOPING_POINT
    forestScroll2 = (forestScroll2 + (FOREST_BG_SPEED + 5) * dt) % FOREST_LOOPING_POINT
    cloudScroll1 = (cloudScroll1 + CLOUD_BG_SPEED * dt) % CLOUD_LOOPING_POINT
    cloudScroll2 = (cloudScroll2 + (CLOUD_BG_SPEED + 30) * dt) % CLOUD_LOOPING_POINT
    buildingScroll = (buildingScroll + BUILDING_BG_SPEED * dt) % BUILDING_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SPEED * dt) % 1024

    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    
    -- draw the background starting at top left (0, 0)
    love.graphics.draw(skyBackground, -skyScroll, 0)
    --mountain
    love.graphics.draw(mountainBackground, -mountainScroll1, 70) --mountain1
    love.graphics.draw(mountainBackground, -mountainScroll2, 80) -- mountain2
    --forest
    love.graphics.draw(forestBackground, -forestScroll1, 200) --forest1
    love.graphics.draw(forestBackground, -forestScroll2 + 20, 210) --forest2
    --cloud
    love.graphics.draw(cloudBackground, -cloudScroll1, -VIRTUAL_HEIGHT/3) --cloud1
    love.graphics.draw(cloudBackground, -cloudScroll2 , -VIRTUAL_HEIGHT/2) -- cloud2
    love.graphics.draw(buildingBackground, -buildingScroll, VIRTUAL_HEIGHT - 75)
    
    gStateMachine:render()
    
    -- draw the ground on top of the background, toward the bottom of the screen
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
    
    push:finish()
end 


