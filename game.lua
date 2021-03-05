--- This module when required returns you a big table with some methods that
-- basically consist of the game's state. It's methods should all pertain to
-- the logic of the game rather than it's content if you catch my drift.
-- Implementing code that tells the game how to render the screen each frame is
-- cool, whereas adding code telling the game what the main menu should say or
-- whatever probably is not cool.

local util = require 'util'
local assets = require 'assets'
local types = require 'types'

local game = {
    -- constants
    frameTime = 0.02,
    debug = true,
    playerShotCooldown = 0.1,
    playerSpeed = 250,
    messageTime = 0.6,
    -- game globals
    frameTimer = 0,
    bgr = 0,
    bgg = 0.1,
    bgb = 0.01,
    assets = assets('assets/'),
    script = nil,
    message = nil,
    music = nil,
    bullets = {},
    actors = {},
    playerBulletPrototype = nil,
    player = nil,
    playerCooldown = 0,
    gunCycle = 0,
    messageCycle = 0,
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

--- Creates the pause menu message object.
-- @param self is the game object.
-- @return the pause menu message.
function game.createPauseMenu(self)
    return types.message(
        self.assets:getPic('idiot.png'),
        'Pause Menu',
        'Press Z to keep vibing. Press t to quit?',
        function (self, key)
            if key == 'z' then return nil
            elseif key == 't' then love.event.push('quit')
            end
            return self
        end
    )
end

--- Creates the player's actor. TODO: probably remove.
-- also sets it as the player.
-- @param self is the game object.
-- @return the player actor.
function game.createPlayer(self)
    local cooldown = 0
    local gunCycle = 0
    self.player = types.actor(game.assets:getPic('plane.png'), 200, 600)
    self.player.health = 10
    self.player.control = coroutine.create(function ()
        while self.player.health > 0 do
            local delta = coroutine.yield()
            self.player.vx = 0
            self.player.vy = 0
            if love.keyboard.isDown('up') then
                self.player.vy =  -self.playerSpeed
            elseif love.keyboard.isDown('down') then
                self.player.vy = self.playerSpeed
            end
            if love.keyboard.isDown('left') then
                self.player.vx = -self.playerSpeed
            elseif love.keyboard.isDown('right') then
                self.player.vx = self.playerSpeed
            end
            -- shooting
            cooldown = cooldown - delta
            if love.keyboard.isDown('z') then
                gunCycle = self.gunCycle + delta
                if cooldown <= 0 then
                    table.insert(
                        self.bullets,
                        types.bullet(
                            self.playerProtobullet,
                            self.player,
                            util.polar(
                                math.pi + math.sin(gunCycle * 9) * 0.09,
                                500
                            )
                        )
                    )
                    cooldown = self.playerShotCooldown
                end
            end
        end
    end)
    return self.player
end

--- Sets the current gui message on the screen and plays and nice sound effect
-- and starts the animation of it.
-- @param self    is the game.
-- @param message is what the message is.
function game.setMessage(self, message)
    self.message = message
    self.messageCycle = 0
    self.assets:getSound('beep.wav'):play()
end

--- Sets the game's script and starts it up and handles errors.
-- @param self is the game.
-- @param func is the game's script.
function game.setScript(self, func)
    self.script = coroutine.create(func)
    local code, err = coroutine.resume(self.script, self)
    if not code then print(err) end
end

--- Updates the bullets that are in the game right now.
-- @param self  is the game.
-- @param delta is the timestep to use. This is allowed to change but should
--              not do so while the player is actually doing stuff.
function game.bulletUpdate(self, delta)
    for i, bullet in ipairs(self.bullets) do
        bullet.x = util.wrap(
            bullet.x + bullet.vx * delta,
            0,
            love.graphics.getWidth()
        )
        bullet.y = bullet.y + bullet.vy * delta
        bullet.vx = bullet.vx + bullet.gx * delta
        bullet.vy = bullet.vy + bullet.gy * delta
        if bullet.y < 0 or bullet.y >= love.graphics.getHeight() then
            table.remove(self.bullets, i)
        end
        for u, actor in ipairs(self.actors) do
            if bullet.owner ~= actor then
                local dSqr = util.distanceSquared(
                    actor.x,
                    actor.y,
                    bullet.x,
                    bullet.y
                )
                if dSqr < actor.radiusSquared + bullet.proto.radiusSquared then
                    -- TODO: maybe use a function for this so we can get a pain
                    --       sound effect for the player.
                    actor.health = actor.health - 1
                    table.remove(self.bullets, i)
                    break
                end
            end
        end
    end
end

--- Does the normal gameplay update when there is not a gui message appearing.
-- Everything in here should be able to assume that delta will equal
-- game.frameTime. If you wonder why we still pass delta is because it is nice
-- and some functions can also work with unfixed framerates, it's only within
-- this function that we can assume that will not happen.
-- @param self  is the game object.
-- @param delta is the time since last frame.
-- @return trye normally and false if the game should end.
function game.normalUpdate(self, delta)
    if love.keyboard.isDown('escape') then
        self:setMessage(self:createPauseMenu())
    end
    if self.script ~= nil and coroutine.status(self.script) ~= 'dead' then
        assert(coroutine.resume(self.script, delta))
    else
        return false
    end
    for i, actor in ipairs(self.actors) do
        if coroutine.status(actor.control) ~= 'dead' then
            assert(coroutine.resume(actor.control, delta))
        end
        actor.x = util.wrap(
            actor.x + actor.vx * delta,
            0,
            love.graphics.getWidth()
        )
        actor.y = actor.y + actor.vy * delta
    end
    self:bulletUpdate(delta)
    return true
end

--- Updates the game.
-- @param self  is the game object itself.
-- @param delta is the amount of time that has passed since last time. This
--              function actually forces some other functions to use a fixed
--              time step so the game is more predictable but here you just
--              pass the legit delta value.
-- @return true normally and false if the game should end now.
function game.update(self, delta)
    self.frameTimer = self.frameTimer + delta
    if self.message == nil then
        while self.frameTimer > self.frameTime do
            self.frameTimer = self.frameTimer - self.frameTime
            local result = self:normalUpdate(self.frameTime)
            if not result then return result end
        end
    else
        self.messageCycle = self.messageCycle + delta
        self:bulletUpdate(delta)
    end
    return true
end

--- Renders the current message if there is one. Only call this if there is one
-- because it assumes that there is one for brevity's sake.
-- @param self is the game object obviously.
function game.messageDraw(self)
    boost = math.random()
    love.graphics.setColor(
        boost * boost,
        math.random() / math.random(),
        boost * boost,
        boost
    )
    love.graphics.setLineWidth(4)
    local scale = math.min(1, self.messageCycle / self.messageTime)
    local width = self.message.img:getWidth() * scale
    local height = self.message.img:getHeight()
    local left = (love.graphics.getWidth() - width) / 2
    love.graphics.draw(self.message.img, left, 0, 0, scale, 1)
    love.graphics.rectangle('line', left, 0, width, height)
    if self.messageCycle >= self.messageTime then
        love.graphics.printf(
            self.message.name,
            left,
            0,
            width
        )
        love.graphics.printf(
            self.message.text,
            0,
            height,
            love.graphics.getWidth()
        )
    end
end

--- Draws the current state of the game.
-- @param self is the game object obviously.
function game.draw(self)
    love.graphics.clear(self.bgr, self.bgg, self.bgb)
    love.graphics.setColor(1, 1, 1)
    for i, actor in ipairs(self.actors) do
        util.drawCentered(actor.img, actor.x, actor.y)
    end
    for i, bullet in ipairs(self.bullets) do
        util.drawCentered(bullet.proto.img, bullet.x, bullet.y)
    end
    if self.message ~= nil then self:messageDraw() end
end

return game
