--- This module returns the constructor for a texture atlas class that actually
-- generates it's atlas when you run the game!!! bing bing bing. Yeah so when
-- you run the atlas it searches for the output files and if they are already
-- there then it does nothing, but if they are not present it generates them.

local util = require 'util'

local csvFormat = '([^,]+)'

function loadQuads(file, img)
    local quads = {}
    for line in love.filesystem.lines(file) do
        local bits = util.flatten(string.gmatch(line, csvFormat))
        local name = bits[1]
        x = assert(tonumber(bits[2]))
        y = assert(tonumber(bits[3]))
        w = assert(tonumber(bits[4]))
        h = assert(tonumber(bits[5]))
        print(name, x, y, w, h)
        quads[name] = love.graphics.newQuad(x, y, w, h, img)
    end
    return quads
end

return function (txtFile, imgFile)
    local img = love.graphics.newImage(imgFile)
    local spriteBatch = love.graphics.newSpriteBatch(img, 1500)
    local quads = assert(loadQuads(txtFile, img))
    return {
        getQuad = function (name)
            return quads[name]
        end,
        drawQuad = function (quad)

        end,
        draw = function ()

        end
    }
end
