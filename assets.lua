--- This module contains an asset repository type of thing. Basically whenever
-- you want an asset you ask for it, and the first time it is loaded from the
-- filesystem, from then on it is stored and when you ask for it again it just
-- gives it to you. There is probably some small amount of overhead so if you
-- are going to use the same asset 1000 times a frame maybe store a reference
-- to it locally. If it was needed I could add a feature to free assets that
-- are not going to be needed again for a while but I don't think it's needed
-- so who cares.

local loaders = {
    pic = function (fullName)
        return love.graphics.newImage(fullName)
    end,
    song = function (fullName)
        return love.audio.newSource(fullName, 'stream')
    end,
    sound = function (fullName)
        return love.audio.newSource(fullName, 'static')
    end
}

--- The structure of this module is of one big constructor function that
-- returns the assets object. The reason for this approach is it means I can
-- treat the actual assets list as a private variable which is cute.
-- @param prefix is the string to prepend to all filenames passed to the assets
--               manager.
return function (prefix)
    local items = {}
    return {
        get = function (name, kind)
            if not items[name] then
                items[name] = loaders[kind](prefix..name)
            end
            return items[name]
        end,
        getPic = function (self, name)
            return self.get(name, 'pic')
        end,
        getSong = function (self, name)
            return self.get(name, 'song')
        end,
        getSound = function (self, name)
            return self.get(name, 'sound')
        end
    }
end
