local client = {}

local socket = require("socket")

local character = {}
character.x = 0
character.y = 0

local restart, t = false, 2

function client.attemptConnection()
    local address, port = "localhost", 12345
    UDP = socket.udp()
    UDP:setpeername(address, port)
    UDP:settimeout(0)

    local a = UDP:send("CONNECT TO SERVER")
    client.connected = true
end

function client.restartConnection()
    print("RESTART")
    local address, port = "localhost", 12345
    UDP = nil
    UDP = socket.udp()
    UDP:setpeername(address, port)
    UDP:settimeout(0)
    restart = true
    t = 2
end

local playerSpeed = 100
local currentCharacterData = {}

local lastSentData

function client.update(deltaTime)
    if restart and t > 0 then
        t = t - deltaTime
    elseif restart then
        restart = false
    end

    if love.keyboard.isDown("w") then
        character.y = character.y - (playerSpeed * deltaTime)
    end
    if love.keyboard.isDown("s") then
        character.y = character.y + (playerSpeed * deltaTime)
    end
    if love.keyboard.isDown("d") then
        character.x = character.x + (playerSpeed * deltaTime)
    end
    if love.keyboard.isDown("a") then
        character.x = character.x - (playerSpeed * deltaTime)
    end

    if client.connected then
        local dataToSend = "M" .. character.x .. ":" .. character.y
        if dataToSend ~= lastSentData then
            UDP:send(dataToSend)
            lastSentData = dataToSend
        end

        local data, msg = UDP:receive()
        if data then
            currentCharacterData = {}
            for key, table in string.gmatch(data, "(%w+)=({%w+,%w+})") do
                local tableWithoutBraces = string.sub(table, 2, string.len(table) - 1)
                local split = Split(tableWithoutBraces, ",")
                local cx, cy = split[1], split[2]

                currentCharacterData[key] = { x = tonumber(cx), y = tonumber(cy) }
            end
        end

        socket.sleep(1 / 60)
    end
end

function client.draw()
    if restart then
        love.graphics.setColor(0, 1, 0, 1)
    else
        love.graphics.setColor(1, 0, 0, 1)
    end
    love.graphics.circle("fill", character.x, character.y, 20)
    if currentCharacterData then
        for key, c in pairs(currentCharacterData) do
            love.graphics.setColor(1, 1, 1, 1)
            if key ~= "self" then
                love.graphics.circle("fill", c.x, c.y, 20)
            end
        end
    end
end

return client
