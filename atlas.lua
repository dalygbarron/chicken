--- This module returns the constructor for a texture atlas class that actually
-- generates it's atlas when you run the game!!! bing bing bing. Yeah so when
-- you run the atlas it searches for the output files and if they are already
-- there then it does nothing, but if they are not present it generates them.

local lineFormat = '>zJJJJ'

function generate(outFile, outImg, inFolder)
    local files = love.filesystem.getDirectoryItems(inFolder)
    local text = ''
    for i, v in ipairs(files) do
        text = text..'\n'..love.data.pack('string', lineFormat, v, 1, 2, 3, 4)
    end
    assert(love.filesystem.write(outFile, text))
    return true
end

function loadQuads(file, img)
    local quads = {}
    for line in love.filesystem.lines(outFile) do
        local name, x, y, w, h = love.data.unpack('string', lineFormat, line)
        quads[name] = love.graphics.newQuad(x, y, w, h, img)
    end
end

return function (outFile, outImg, inFolder)
    local check = love.filesystem.getInfo
    if not check(outFile) or not check(outImg) then
        assert(generate(outFile, outImg, inFolder))
    end
    local img = love.graphics.newImage(outImg)
    local spriteBatch = love.graphics.newSpriteBatch(outImg, 1500)
    local quads = loadQuads(outFile, img)
    assert(quads)
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
