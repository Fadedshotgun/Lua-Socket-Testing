GameStates = { Menu = 1, Server = 2, Client = 3 }
GameState = GameStates.Menu

local lastState

local menu = require("menu")
local client = require("client")
local server = require("server")

function ChangeGameState(to)
    if to == GameStates.Client then
        local message = client.attemptConnection()
        if message == "Timeout" then return end
        love.window.setTitle("Client")
        GameState = to
    end
    if to == GameStates.Server then
        local message = server.startServer()
        love.window.setTitle("Host Server")
        GameState = to
    end
end

function Split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function love.load()
    menu.load()
end

function love.update(deltaTime)
    lastState = GameState

    if GameState == GameStates.Client then
        client.update(deltaTime)
    elseif GameState == GameStates.Server then
        server.update(deltaTime)
    end
end

function love.mousepressed(x, y, button)
    if GameState == GameStates.Menu then
        menu.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if GameState == GameStates.Client and key == "r" then
        client.restartConnection()
    end
end

function love.mousereleased(x, y, button)
    if GameState == GameStates.Menu then
        menu.mousereleased(x, y, button)
    end
end

function love.draw()
    if GameState == GameStates.Menu then
        menu.draw()
    elseif GameState == GameStates.Client then
        client.draw()
    elseif GameState == GameStates.Server then
        server.draw()
    end
end
