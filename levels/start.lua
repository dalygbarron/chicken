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

return function (game)
    game.assets:getSong('ging.ogg'):play()
    util.wait(1)
    game:setMessage(createMainMenu(game.assets))
    util.wait(5)
    local wavers = {}
    for i=1, 5 do
            
    end
end
