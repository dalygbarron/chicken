--- This module just contains useful functions that almost feel like the kind
-- of shit a standard library might provide except they were not provided so
-- I made them.

local util = {}

--- Takes a number and wraps it between a maximum value and 0.
-- @param value is the value to wrap
-- @param max   is the value at which it wraps back to 0.
-- @return the wrapped version.
function util.wrapAroundZero(value, max)
    if value < 0 then
        return max - math.abs(math.fmod(value, max))
    else
        return math.fmod(value, max)
    end
end

--- Takes a number and wraps it between two other numbers. Wrapping is
-- inclusive of min, but exclusive of max if you catch my drift.
-- @param value is the value to wrap.
-- @param min   is the value before which it wraps back to max.
-- @param max   is the value at which it wraps back to min.
-- @return the wrapped version.
function util.wrap(value, min, max)
    return min + util.wrapAroundZero(value - min, max - min)
end

--- Takes a value and stops it from leaving a certain bound by making it hit
-- a wall.
-- @param value is the value to clamp.
-- @param min   is the lowest possible value we can return.
-- @param max   is the highest possible value we can return.
-- @return the version of the value whose wings have been clipped in accordance
--         with min and max.
function util.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

--- Draws a love image thingy by passing the middle point instead of the top
-- left corner.
-- @param img is the image to draw.
-- @param x   is the x position to draw.
-- @param y   is the y position to draw.
function util.drawCentered(img, x, y)
    love.graphics.draw(
        img,
        x - img:getWidth() / 2,
        y - img:getHeight() / 2
    )
end

--- Hot waits in a coroutine that expects to receive a delta value each time it
-- yields.
-- @param time is the time to wait for
function util.wait(time)
    while time > 0 do
        time = time - coroutine.yield()
    end
end

return util

--assert((wrap(5, 4, 6)) == 5)
--assert((wrap(6, 4, 6)) == 4)
--assert((wrap(-1.5, 1, 6)) == 3.5)
