local types = require 'types'
local util = require 'util'

function createCredits(ass)
    local times = 0
    return types.message(
        ass:getPic('dany.png'),
        'Dany Burton',
        'AGame by Dabny BARGON press h seven times to return',
        function (self, key)
            if key == 'h' then
                times = times + 1
                ass:getSound('spk.wav'):play()
                if times > 6 then
                    return createMainMenu(ass)
                end
            end
            return self
        end
    )
end

function createMainMenu(ass)
    return types.message(
        ass:getPic('idiot.png'),
        'Brexit Gunner',
        'Welcome to Brexit Gunner, press z to play, press p to read the credits',
        function (self, key)
            if key == 'z' then return nil
            elseif key == 'p' then return createCredits(ass)
            else return self
            end
        end
    )
end

function createNong(game, angle)
    local x, y = util.polar(angle, 9999)
    x = util.closer(x, 0, game.width - 0.0001)
    y = util.closer(y, 0, game.height - 0.0001)
    local nong = types.actor{
        img = game.assets:getPic('jap.png'),
        x = x,
        y = y,
        vx, vy = util.polar(
            math.atan2(game.player.y - y, game.player.x - x),
            60
        ),
        rotate = true
    }
    nong.control = coroutine.create(function ()
        while nong.health do
            local delta = util.wait(0.2)
            print(delta)
            local gx, gy = util.polar(
                math.atan2(game.player.y - nong.y, game.player.x - nong.x),
                50
            )
            nong.vx = nong.vx + gx * delta
            nong.vy = nong.vy + gy * delta
        end
    end)
    return nong
end

return function (game)
    game.assets:getSong('ging.ogg'):play()
    util.wait(1)
    game:setMessage(createMainMenu(game.assets))
    util.wait(2)
    for i=1, 20 do
        table.insert(game.actors, createNong(game, math.pi / 2.5 * i))
        util.wait(1.5)
    end
    util.wait(2)
end
