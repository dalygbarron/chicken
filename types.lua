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
    end
end

--- Base function for creating an actor by filling all it's fields. Actually it
-- just sets health as 0 but there is really no need to set health here. An
-- actor is something that flies around under it's own free will in the game.
-- @param img is the image to render the actor with.
-- @param x   is the starting x position
-- @param y   is the starting y position
-- @param vx  is the starting x velocity.
-- @param vy  is the starting y velocity.
function types.actor(img, x, y, vx, vy)
    return {
        img = img,
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        health = 0
    }
end

--- Creates a prototypal bullet that actual bullets are mere copies of.
-- @param img is the bullet image which provides the radius and stuff
-- @return the protobullet
function protobullet(img)
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
-- @param vx    is the starting x velocity of the bullet.
-- @param vy    is the starting y velocity of the bullet.
-- @param gx    is the x acceleration of the bullet.
-- @param gy    is the y acceleration of the bullet.
-- @return the bullet.
function types.bullet(proto, owner, x, y, vx, vy, gx, gy)
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

--- Creates a bullet that has velocity set by an angle and speed, and it's
-- starting position is that of it's owner.
-- @param proto is the prototype this bullet is based on.
-- @param owner is the shooter of the bullet.
-- @param angle is the angle to shoot it in.
-- @param speed is the speed with which to shoot it.
-- @param img   is the image to render the bullet with.
function types.aimedBullet(proto, owner, angle, speed)
    return types.bullet(
        proto,
        owner,
        owner.x,
        owner.y,
        math.sin(angle) * speed,
        math.cos(angle) * speed,
        0,
        0
    )
end

return types
