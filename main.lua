local util = require 'util'
local types = require 'types'
local game = require 'game'

function start()
    game.music:play()
    game.message = game:createMainMenu()
end

function messageUpdate(delta)
    bulletUpdate(delta)
end

function love.load()
    love.graphics.setNewFont(20)
    game.music = love.audio.newSource('assets/ging.ogg', 'stream')
    game.idiotImg = love.graphics.newImage('assets/idiot.png')
    game.bulletImg = love.graphics.newImage('assets/playerBullet.png')
    game.danyImg = love.graphics.newImage('assets/dany.png')
    game.player = types.actor(
        love.graphics.newImage('assets/plane.png'),
        200,
        600,
        0,
        0
    )
    start()
end

function love.keypressed(key)
    if game.message ~= nil then
        game.message = game.message:processor(key)
    end
end

function love.update(delta)
    game:update(delta)
end

function love.draw(delta)
    game:draw()
end
