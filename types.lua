--- Point of this file is to give definitive forms of the different types like
-- bullet and messages etc, plus some functions for different ways of
-- constructing them that are convenient.

local types = {}

--- Base function for creating a message object, which takes all it's
-- parameters. A message object represents a thingy that appears on the screen
-- and takes focus from the gameplay, showing a portrait of some character or
-- something, and some text, telling you what to do.
-- @param img       is the image to put with the message.
-- @param name      is a name to show on the image.
-- @param text      is the text of the message.
-- @param processor is a function which takes itself and a keycode and returns
--                  a new message to replace this one (or itself).
-- @return the new message you have created.
function types.message(img, name, text, processor)
    return {
        img = img,
        name = name,
        text = text,
        processor = processor
    }
end

--- Creates a message with any number of text lines which are appended
-- together. The way the texts are appended is that normally there is a space
-- between them if there wasn't already one anyway, and a newline is added when
-- you pass in an empty string.
-- @param img       is the message's image.
-- @param name      is the name.
-- @param processor is the message's processor function.
-- @param ...       is all the lines of text to append together.
-- @return the new message you have created.
function types.writeMessage(img, name, processor, ...)
    local text = ''
    for i, v in ipairs(arg) do
        -- TODO: everything
    end
end

--- Base function for creating an actor by filling all it's fields. Actually it
-- just sets health as 0 but there is really no need to set health here. An
-- actor is something that flies around under it's own free will in the game.
-- @param img    is the image to render the actor with.
-- @param x      is the starting x position
-- @param y      is the starting y position
-- @param health is the actor's starting health which defaults to 1.
-- @param radius is the actor's collision radius. If you omit this argument it
--               will use half the image width.
function types.actor(img, x, y, health, radius)
    if radius == nil then radius = img:getWidth() / 2 * 0.8 end
    if health == nil then health = 1 end
    return {
        control = nil,
        img = img,
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        health = health,
        radiusSquared = radius * radius
    }
end

--- Creates a prototypal bullet that actual bullets are mere copies of.
-- @param img is the bullet image which provides the radius and stuff
-- @return the protobullet
function types.protobullet(img)
    local radius = img:getWidth() / 2
    return {
        img = img,
        radiusSquared = radius * radius
    }
end

--- Base function for creating a bullet by filling all it's fields. A bullet is
-- obviously the little objects actors shoot at each other.
-- @param proto is the prototype this bullet is based on.
-- @param owner is the actor shooting the bullet.
-- @param x     is the starting x position of the bullet.
-- @param y     is the starting y position of the bullet.
-- @param vx    is the starting x velocity of the bullet. defaults to 0.
-- @param vy    is the starting y velocity of the bullet. defaults to 0.
-- @param gx    is the x acceleration of the bullet. defaults to 0.
-- @param gy    is the y acceleration of the bullet. defaults to 0.
-- @return the bullet.
function types.bullet(proto, owner, x, y, vx, vy, gx, gy)
    if vx == nil then vx = 0 end
    if vy == nil then vy = 0 end
    if gx == nil then gx = 0 end
    if gy == nil then gy = 0 end
    return {
        proto = proto,
        owner = owner,
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        gx = gx,
        gy = gy
    }
end

return types
