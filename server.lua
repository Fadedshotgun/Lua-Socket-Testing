local server = {}

local connectedClients = {}
local characters = {}

local CLIENT_TIMEOUT = 5
local socket = require('socket')

local function createNewCharacter(key)
    local newCharacter = {}
    newCharacter.x = 0
    newCharacter.y = 0

    characters[key] = newCharacter
end

local function createNewClient(data, ip, port)
    local clientKey = ip .. ":" .. port

    local newCharacterKey
    repeat
        newCharacterKey = math.random(0, 99999)
    until characters[newCharacterKey] == nil

    local newClient = {
        ip = ip,
        port = port,
        lastSeen = love.timer.getTime(),
        characterKey = newCharacterKey
    }

    characters[newCharacterKey] = { x = 0, y = 0 }

    connectedClients[clientKey] = newClient
end

local function handleNewClient(data, ip, port)
    local clientKey = ip .. ":" .. port
    if connectedClients[clientKey] == nil then
        createNewClient(data, ip, port)
        return true
    else
        connectedClients[clientKey].lastSeen = love.timer.getTime()
        return false
    end
end

local function cleanupOldClients()
    for clientKey, clientData in pairs(connectedClients) do
        if love.timer.getTime() - clientData.lastSeen > CLIENT_TIMEOUT then
            connectedClients[clientKey] = nil
        end
    end
end

function server.startServer()
    server.udp = socket.udp()
    server.udp:setsockname('*', 12345)
    server.udp:settimeout(0)

    createNewCharacter("Host")

    return true
end

local playerSpeed = 100

local function sendCharacterData(client)
    local packet = ""
    for key, character in pairs(characters) do
        local KeyToSend = tostring(key)
        if key == client.characterKey then
            KeyToSend = "self"
        end
        packet = packet .. KeyToSend .. "={" .. math.floor(character.x) .. "," .. math.floor(character.y) .. "}"
        packet = packet .. " "
    end

    server.udp:sendto(packet, client.ip, client.port)
end

local function manageHostCharacter(deltaTime)
    local character = characters.Host
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
end

function server.update(deltaTime)
    manageHostCharacter(deltaTime)

    local data, ip, port = server.udp:receivefrom()
    if data then
        local isNew = handleNewClient(data, ip, port)
        if isNew then
            print("NEW CLIENT")
            server.udp:sendto("CONNECTED SUCCESSFULLY", ip, port)
        end
        if data ~= "CONNECT TO SERVER" then
            local action = string.sub(data, 1, 1)
            if action == "M" then
                data = string.sub(data, 2, string.len(data))

                local clientKey = ip .. ":" .. port
                local client = connectedClients[clientKey]
                local character = characters[client.characterKey]

                local splitData = Split(data, ":")
                local x, y = tonumber(splitData[1]), tonumber(splitData[2])
                if type(x) == "number" and type(y) == "number" then
                    character.x, character.y = x, y
                end
            end
        end
    end
    --cleanupOldClients()

    for key, client in pairs(connectedClients) do
        sendCharacterData(client)
    end

    socket.sleep(1 / 60)
end

local function drawCharacters()
    for key, character in pairs(characters) do
        if key == "Host" then
            love.graphics.setColor(1, 0, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.circle("fill", character.x, character.y, 20)
    end
end

function server.draw()
    drawCharacters()
end

return server
