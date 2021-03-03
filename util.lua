local util = {}

function util.wrapAroundZero(value, max)
    if value < 0 then
        return max - math.abs(math.fmod(value, max))
    else
        return math.fmod(value, max)
    end
end

function util.wrap(value, min, max)
    return min + util.wrapAroundZero(value - min, max - min)
end

function util.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function util.drawCentered(img, x, y)
    love.graphics.draw(
        img,
        x - img:getWidth() / 2,
        y - img:getHeight() / 2
    )
end

return util

--assert((wrap(5, 4, 6)) == 5)
--assert((wrap(6, 4, 6)) == 4)
--assert((wrap(-1.5, 1, 6)) == 3.5)
