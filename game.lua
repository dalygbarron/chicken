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
    debug = true,
    playerShotCooldown = 0.1,
    playerSpeed = 250,
    messageTime = 0.6,
    -- game globals
    bgr = 0,
    bgg = 0.1,
    bgb = 0.01,
    assets = assets('assets/'),
    script = nil,
    message = nil,
    music = nil,
    bullets = {},
    actors = {},
    player = nil,
    playerCooldown = 0,
    gunCycle = 0,
    messageCycle = 0
}

function game.createPauseMenu(self)
    return types.message(
        self.idiotImg,
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

function game.setMessage(self, message)
    self.message = message
    self.messageCycle = 0
    self.assets:getSound('beep.wav'):play()
end

function game.setScript(self, func)
    self.script = coroutine.create(func)
    local code, err = coroutine.resume(self.script, self)
    if not code then print(err) end
end

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
    end
end

function game.playerUpdate(self, delta)
    -- movement
    if love.keyboard.isDown('up') then
        self.player.y = self.player.y - (self.playerSpeed * delta)
    elseif love.keyboard.isDown('down') then
        self.player.y = self.player.y + (self.playerSpeed * delta)
    end
    if love.keyboard.isDown('left') then
        self.player.x = self.player.x - (self.playerSpeed * delta)
    elseif love.keyboard.isDown('right') then
        self.player.x = self.player.x + (self.playerSpeed * delta)
    end
    -- shooting
    self.playerCooldown = self.playerCooldown - delta
    if love.keyboard.isDown('z') then
        self.gunCycle = self.gunCycle + delta
        if self.playerCooldown <= 0 then
            table.insert(
                self.bullets,
                types.aimedBullet(
                    self.player,
                    math.pi + math.sin(self.gunCycle * 9) * 0.09,
                    500,
                    self.assets:getPic('playerBullet.png')
                )
            )
            self.playerCooldown = self.playerShotCooldown
        end
    end
end

function game.normalUpdate(self, delta)
    if love.keyboard.isDown('escape') then
        self:setMessage(self:createPauseMenu())
    end
    if self.player ~= nil then
        self:playerUpdate(delta)
        self.player.x = util.wrap(self.player.x, 0, love.graphics.getWidth())
        self.player.y = util.clamp(self.player.y, 0, love.graphics.getHeight())
    end
    if self.script ~= nil and coroutine.status(self.script) ~= 'dead' then
        local code, err = coroutine.resume(self.script, delta)
        if not code then print(err) end
    else
        return false
    end
    self:bulletUpdate(delta)
    return true
end

function game.update(self, delta)
    if self.message == nil then
        return self:normalUpdate(delta)
    else
        self.messageCycle = self.messageCycle + delta
        self:bulletUpdate(delta)
    end
    return true
end

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
    local left = (love.graphics.getWidth() - width) / 2
    love.graphics.draw(self.message.img, left, 0, 0, scale, 1)
    love.graphics.rectangle(
        'line',
        left,
        0,
        width,
        self.message.img:getHeight()
    )
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
            self.message.img:getHeight(),
            love.graphics.getWidth()
        )
    end
end

function game.draw(self)
    love.graphics.clear(self.bgr, self.bgg, self.bgb)
    love.graphics.setColor(1, 1, 1)
    -- Draw the player
    if self.player ~= nil then
        util.drawCentered(self.player.img, self.player.x, self.player.y)
    end
    -- Draw the bullets
    for i, bullet in ipairs(self.bullets) do
        util.drawCentered(bullet.img, bullet.x, bullet.y)
    end
    -- Draw the message if there is one.
    if self.message ~= nil then self:messageDraw() end
end

return game
