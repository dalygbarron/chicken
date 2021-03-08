--- Point of this file is to give definitive forms of the different types like
-- bullet and messages etc, plus some functions for different ways of
-- constructing them that are convenient.

local util = require 'util'

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
    for i, v in ipairs({...}) do
        if string.len(v) == 0 then
            text = text..'\n'
        elseif not util.white(text:sub(-1, -1), v:sub(0, 0)) then
            text = text..' '..v
        else
            text = text..v
        end
    end
    return types.message(img, name, text, processor)
end

--- Creates a backgroundlayer object.
-- @param img   is the image to draw this layer with.
-- @param ratio is the ratio of the current overall background movement rate to
--              the rate at which this layer moves.
function types.backgroundLayer(quad, ratio)
    if ratio == nil then
        ratio = 1
    end
    return {
        quad = quad,
        ratio = ratio
    }
end

--- Creates an actor by taking a table containing whatever actor values you
-- actually want to set, and setting the rest to default values. The fields
-- that will be set in the final product are rotate boolean, img (which is
-- mandatory), x, y, vx, vy, health, radius, radiusSquared (which will always
-- equal radius^2). In order for the actor to actually work you also need to
-- add a control coroutine but this is not added by default because it needs
-- the actor object to operate on, you can also add a draw function if you
-- want, but again it needs to be a closure with access to the actor object if
-- it is to do anything useful.
-- @param args is the table containing all you want to set. By the way if you
--             add random shiet that is not actor related it will keep that
--             too.
-- @return the actor object with fields defaulted.
function types.actor(args)
    if not args.health then args.health = 1 end
    if not args.radius then
        args.radius = args.img:getWidth() * 0.4
    end
    args.radiusSquared = args.radius * args.radius
    if not args.x then args.x = 0 end
    if not args.y then args.y = 0 end
    if not args.vx then args.vx = 0 end
    if not args.vy then args.vy = 0 end
    if not args.rotate then args.rotate = false end
    return args
end

--- Creates a prototypal bullet that actual bullets are mere copies of.
-- @param img   is the bullet image which provides the radius and stuff
-- @param sound is the sound effect to play when the bullet is fired. It can be
--              nil tho.
-- @return the protobullet
function types.protobullet(img, sound)
    local radius = img:getWidth() * 0.4
    return {
        img = img,
        radiusSquared = radius * radius,
        sound = sound
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
