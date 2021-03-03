local util = require 'util'
local types = require 'types'

-- constants
debug = true
playerShotCooldown = 0.1
playerSpeed = 250

-- global state
message = nil
music = nil
danyImg = nil
idiotImg = nil
bulletImg = nil
bullets = {}
player = nil

function createPlayer(img)
    img = img
    cooldown = 0
    gunCycle = 0
    return types.actor(
        200,
        600,
        function (self, delta)
            -- movement
            if love.keyboard.isDown('up') then
                self.y = self.y - (playerSpeed * delta)
            elseif love.keyboard.isDown('down') then
                self.y = self.y + (playerSpeed * delta)
            end
            if love.keyboard.isDown('left') then
                self.x = self.x - (playerSpeed * delta)
            elseif love.keyboard.isDown('right') then
                self.x = self.x + (playerSpeed * delta)
            end
            -- shooting
            cooldown = cooldown - delta
            if love.keyboard.isDown('z') then
                gunCycle = gunCycle + delta
                if cooldown <= 0 then
                    table.insert(
                        bullets,
                        types.aimedBullet(
                            self,
                            math.pi + math.sin(gunCycle * 9) * 0.09,
                            500,
                            bulletImg
                        )
                    )
                    cooldown = playerShotCooldown
                end
            end
        end,
        function (self)
            util.drawCentered(img, self.x, self.y)
        end
    )
end

function createPauseMenu()
    return types.message(
        idiotImg,
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

function createCredits()
    times = 0
    return types.message(
        danyImg,
        'Dany Burton',
        'AGame by Dabny BARGON press h seven times to return',
        function (self, key)
            if key == 'h' then
                times = times + 1
                if times > 6 then
                    return createMainMenu()
                end
            end
            return self
        end
    )
end

function createMainMenu()
    return types.message(
        idiotImg,
        'Brexit Gunner',
        'Welcome to Brexit Gunner, press z to play, press p to read the credits',
        function (self, key)
            if key == 'z' then
                -- TODO: set up the first level
                return nil
            elseif key == 'p' then return createCredits()
            else return self
            end
        end
    )
end

function start()
    music:play()
    message = createMainMenu()
end

function bulletUpdate(delta)
    for i, bullet in ipairs(bullets) do
        bullet.x = util.wrap(
            bullet.x + bullet.vx * delta,
            0,
            love.graphics.getWidth()
        )
        bullet.y = bullet.y + bullet.vy * delta
        bullet.vx = bullet.vx + bullet.gx * delta
        bullet.vy = bullet.vy + bullet.gy * delta
        if bullet.y < 0 or bullet.y >= love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end
end

function normalUpdate(delta)
    if love.keyboard.isDown('escape') then
        message = createPauseMenu()
    end
    if player ~= nil then
        player:update(delta)
        player.x = util.wrap(player.x, 0, love.graphics.getWidth())
        player.y = util.clamp(player.y, 0, love.graphics.getHeight())
    end
    bulletUpdate(delta)
end

function messageUpdate(delta)
    bulletUpdate(delta)
end

function love.load()
    love.graphics.setNewFont(20)
    music = love.audio.newSource('assets/ging.ogg', 'stream')
    idiotImg = love.graphics.newImage('assets/idiot.png')
    bulletImg = love.graphics.newImage('assets/playerBullet.png')
    danyImg = love.graphics.newImage('assets/dany.png')
    player = createPlayer(love.graphics.newImage('assets/plane.png'))
    start()
end

function love.keypressed(key)
    if message ~= nil then
        message = message:processor(key)
    end
end

function love.update(delta)
    if message == nil then normalUpdate(delta)
    else messageUpdate(delta)
    end
end

function love.draw(delta)
    --love.graphics.clear(251/255, 182/255, 3/255)
    love.graphics.setColor(1, 1, 1)
    -- Draw the player
    if player ~= nil then
        player:render()
    end
    -- Draw the bullets
    for i, bullet in ipairs(bullets) do
        util.drawCentered(bullet.img, bullet.x, bullet.y)
    end
    -- Draw the message if there is one.
    if message ~= nil then
        boost = math.random()
        love.graphics.setColor(
            boost * boost,
            math.random() / math.random(),
            boost * boost,
            boost
        )
        love.graphics.setLineWidth(4)
        love.graphics.draw(
            message.img,
            (love.graphics.getWidth() - message.img:getWidth()) / 2,
            0
        )
        love.graphics.rectangle(
            'line',
            (love.graphics.getWidth() - message.img:getWidth()) / 2,
            0,
            message.img:getWidth(),
            message.img:getHeight()
        )
        love.graphics.printf(
            message.name,
            (love.graphics.getWidth() - message.img:getWidth()) / 2,
            0,
            message.img:getWidth()
        )
        love.graphics.printf(
            message.text,
            0,
            message.img:getHeight(),
            love.graphics.getWidth()
        )
    end
end
