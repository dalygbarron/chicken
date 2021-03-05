--- This file is the start point of the game and is just for setting up the
-- game and implementing love's callback functions and hooking them up to our
-- stuff.

local util = require 'util'
local types = require 'types'
local game = require 'game'

function love.load()
    love.graphics.setNewFont(20)
    game.playerProtobullet = types.protobullet(
        game.assets:getPic('playerBullet.png')
    )
    table.insert(game.actors, game:createPlayer())
    game:setScript(require 'levels.start')
end

function love.keypressed(key)
    if game.message ~= nil then
        local message = game.message:processor(key)
        if message == nil then
            game.message = nil
        elseif message ~= game.message then
            game:setMessage(message)
        end
    end
end

function love.update(delta)
    if not game:update(delta) then
        love.event.push('quit')
    end
end

function love.draw(delta)
    game:draw()
end
