local util = require 'util'
local types = require 'types'

local game = {
    -- constants
    debug = true,
    playerShotCooldown = 0.1,
    playerSpeed = 250,
    -- game globals
    message = nil,
    music = nil,
    danyImg = nil,
    idiotImg = nil,
    bulletImg = nil,
    bullets = {},
    actors = {},
    player = nil,
    playerCooldown = 0,
    gunCycle = 0
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

function game.createCredits(self)
    times = 0
    return types.message(
        self.danyImg,
        'Dany Burton',
        'AGame by Dabny BARGON press h seven times to return',
        function (s, key)
            if key == 'h' then
                times = times + 1
                if times > 6 then
                    return self:createMainMenu()
                end
            end
            return s
        end
    )
end

function game.createMainMenu(self)
    return types.message(
        self.idiotImg,
        'Brexit Gunner',
        'Welcome to Brexit Gunner, press z to play, press p to read the credits',
        function (s, key)
            if key == 'z' then
                -- TODO: set up the first level
                return nil
            elseif key == 'p' then return self:createCredits()
            else return s
            end
        end
    )
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
                    self.bulletImg
                )
            )
            self.playerCooldown = self.playerShotCooldown
        end
    end
end

function game.normalUpdate(self, delta)
    if love.keyboard.isDown('escape') then
        self.message = self:createPauseMenu()
    end
    if self.player ~= nil then
        self:playerUpdate(delta)
        self.player.x = util.wrap(self.player.x, 0, love.graphics.getWidth())
        self.player.y = util.clamp(self.player.y, 0, love.graphics.getHeight())
    end
    self:bulletUpdate(delta)
end

function game.update(self, delta)
    if self.message == nil then self:normalUpdate(delta)
    else
        self:bulletUpdate(delta)
    end
end

function game.draw(self)
    --love.graphics.clear(251/255, 182/255, 3/255)
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
    if self.message ~= nil then
        boost = math.random()
        love.graphics.setColor(
            boost * boost,
            math.random() / math.random(),
            boost * boost,
            boost
        )
        love.graphics.setLineWidth(4)
        love.graphics.draw(
            self.message.img,
            (love.graphics.getWidth() - self.message.img:getWidth()) / 2,
            0
        )
        love.graphics.rectangle(
            'line',
            (love.graphics.getWidth() - self.message.img:getWidth()) / 2,
            0,
            self.message.img:getWidth(),
            self.message.img:getHeight()
        )
        love.graphics.printf(
            self.message.name,
            (love.graphics.getWidth() - self.message.img:getWidth()) / 2,
            0,
            self.message.img:getWidth()
        )
        love.graphics.printf(
            self.message.text,
            0,
            self.message.img:getHeight(),
            love.graphics.getWidth()
        )
    end
end

return game
