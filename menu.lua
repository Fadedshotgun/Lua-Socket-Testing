local menu = {}

menu.buttons = {}

local font

local function newButton(text, func)
    table.insert(menu.buttons,
        {
            text = text,
            func = func
        })
end

function menu.load()
    font = love.graphics.newFont(32)

    newButton("Create", function()
        ChangeGameState(GameStates.Server)
    end)
    newButton("Join", function()
        ChangeGameState(GameStates.Client)
    end)
end

function menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    for _, button in pairs(menu.buttons) do
        if button.hovered then
            button.clicked = true
        end
    end
end

function menu.mousereleased(x, y, button)
    if button ~= 1 then return end

    for _, button in pairs(menu.buttons) do
        if button.clicked then
            if button.hovered then
                button.func()
            end
            button.clicked = false
        end
    end
end

function menu.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local buttonWidth = w * (1 / 3)
    local buttonHeight = h * (1 / 10)
    local margin = 10

    local totalHeight = (buttonHeight + margin) * #menu.buttons
    local currentY = 0

    local mouseX, mouseY = love.mouse.getPosition()

    for index, button in ipairs(menu.buttons) do
        local buttonX = (w / 2) - (buttonWidth / 2)
        local buttonY = (h / 2) - (totalHeight / 2) + currentY

        button.hovered = mouseX > buttonX and mouseX < buttonX + buttonWidth and mouseY > buttonY and
            mouseY < buttonY + buttonHeight

        if button.clicked and button.hovered then
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
        elseif button.hovered then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
        end

        love.graphics.rectangle("fill",
            buttonX,
            buttonY,
            buttonWidth,
            buttonHeight
        )

        local textWidth = font:getWidth(button.text)
        local textHeight = font:getHeight(button.text)

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(
            button.text,
            font,
            (w / 2) - textWidth / 2,
            buttonY + textHeight / 3
        )

        currentY = currentY + (buttonHeight + margin)
    end
end

return menu
