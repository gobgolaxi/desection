-- roblox-ui-lib.lua (исправленная версия с Fly и правильным порядком)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local ui = {}
local window = nil
local categories = {}
local currentCategory = nil
local buttons = {}
local elements = {} -- таблица для хранения всех элементов

local WINDOW_SIZE = Vector2.new(520, 380)
local TOPBAR_HEIGHT = 40
local CATEGORY_WIDTH = 140
local CORNER_RADIUS = 6

-- Вспомогательная функция для создания закругленных углов
local function applyCornerRadius(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or CORNER_RADIUS)
    corner.Parent = instance
    return corner
end

-- вспомогательная плавная анимация цвета
local function tweenColor(inst, prop, targetColor, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(inst, tweenInfo, {[prop] = targetColor})
    tween:Play()
    return tween
end

-- Создание окна
function ui.createWindow(title)
    WINDOW_TITLE = title or "UI Window"

    if window then window:Destroy() end

    window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = UDim2.new(0, WINDOW_SIZE.X, 0, WINDOW_SIZE.Y)
    window.Position = UDim2.new(0.5, -WINDOW_SIZE.X/2, 0.5, -WINDOW_SIZE.Y/2)
    window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    window.BorderSizePixel = 0
    window.Active = true
    window.Draggable = true
    window.Parent = screenGui
    
    -- Закругление окна
    applyCornerRadius(window, 8)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT)
    topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    topBar.BorderSizePixel = 0
    topBar.Parent = window
    
    -- Закругления только сверху
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = WINDOW_TITLE
    titleText.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 16
    titleText.Parent = topBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -TOPBAR_HEIGHT)
    contentFrame.Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    local categoryList = Instance.new("ScrollingFrame")
    categoryList.Name = "CategoryList"
    categoryList.Size = UDim2.new(0, CATEGORY_WIDTH, 1, 0)
    categoryList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    categoryList.BorderSizePixel = 0
    categoryList.ScrollBarThickness = 4
    categoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    categoryList.Parent = contentFrame
    
    applyCornerRadius(categoryList, 4)

    local categoryLayout = Instance.new("UIListLayout")
    categoryLayout.Padding = UDim.new(0, 6)
    categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
    categoryLayout.Parent = categoryList

    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -CATEGORY_WIDTH, 1, 0)
    contentArea.Position = UDim2.new(0, CATEGORY_WIDTH, 0, 0)
    contentArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 6
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentArea.Parent = contentFrame
    
    applyCornerRadius(contentArea, 4)

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentArea

    -- Сохраняем для внутреннего доступа
    ui._categoryList = categoryList
    ui._contentArea = contentArea
    ui._contentLayout = contentLayout

    currentCategory = nil
    categories = {}
    buttons = {}
    elements = {}
end

-- Добавить категорию
function ui.addCategory(name)
    if not window then ui.createWindow() end

    local categoryList = ui._categoryList

    local categoryButton = Instance.new("TextButton")
    categoryButton.Name = "Category_" .. HttpService:GenerateGUID(false)
    categoryButton.Size = UDim2.new(1, -10, 0, 36)
    categoryButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    categoryButton.BorderSizePixel = 0
    categoryButton.Text = name
    categoryButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    categoryButton.Font = Enum.Font.GothamSemibold
    categoryButton.TextSize = 15
    categoryButton.AutoButtonColor = false
    categoryButton.LayoutOrder = #categories + 1
    categoryButton.Parent = categoryList
    
    applyCornerRadius(categoryButton)

    local function setActive(isActive)
        if isActive then
            tweenColor(categoryButton, "BackgroundColor3", Color3.fromRGB(90, 90, 90))
            categoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tweenColor(categoryButton, "BackgroundColor3", Color3.fromRGB(55, 55, 55))
            categoryButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    categoryButton.MouseEnter:Connect(function()
        if currentCategory ~= name then
            tweenColor(categoryButton, "BackgroundColor3", Color3.fromRGB(75, 75, 75))
        end
    end)
    categoryButton.MouseLeave:Connect(function()
        if currentCategory ~= name then
            tweenColor(categoryButton, "BackgroundColor3", Color3.fromRGB(55, 55, 55))
        end
    end)

    categoryButton.MouseButton1Click:Connect(function()
        if currentCategory == name then return end
        currentCategory = name

        for _, cat in pairs(categories) do
            setActive(cat.name == name)
        end

        -- показать кнопки выбранной категории
        for btnId, data in pairs(buttons) do
            local btn = ui._contentArea:FindFirstChild(btnId)
            if btn then
                btn.Visible = (data.category == name)
            end
        end
    end)

    table.insert(categories, {name = name, button = categoryButton})

    -- Если первая категория — активируем
    if #categories == 1 then
        currentCategory = name
        setActive(true)
    else
        setActive(false)
    end
end

-- Функция для управления видимостью элементов
function ui.setVisible(elementName, isVisible)
    local element = elements[elementName]
    if element then
        element.Visible = isVisible
    end
end

-- Добавить кнопку
function ui.addButton(categoryName, buttonLabel, callback)
    if not window then ui.createWindow() end

    local contentArea = ui._contentArea

    local buttonId = "Button_" .. HttpService:GenerateGUID(false)

    local uiButton = Instance.new("TextButton")
    uiButton.Name = buttonId
    uiButton.Size = UDim2.new(1, 0, 0, 40)
    uiButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    uiButton.BorderSizePixel = 0
    uiButton.Text = buttonLabel
    uiButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    uiButton.Font = Enum.Font.Gotham
    uiButton.TextSize = 15
    uiButton.AutoButtonColor = false
    -- Изменяем LayoutOrder чтобы новые элементы появлялись снизу
    uiButton.LayoutOrder = 10000 + #buttons
    uiButton.Parent = contentArea
    uiButton.Visible = categoryName == currentCategory
    
    applyCornerRadius(uiButton)

    uiButton.MouseEnter:Connect(function()
        tweenColor(uiButton, "BackgroundColor3", Color3.fromRGB(85, 85, 85))
    end)
    uiButton.MouseLeave:Connect(function()
        tweenColor(uiButton, "BackgroundColor3", Color3.fromRGB(65, 65, 65))
    end)
    uiButton.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    buttons[buttonId] = {
        category = categoryName,
        label = buttonLabel,
        callback = callback
    }
    
    elements[buttonLabel] = uiButton
end

-- Добавить чекбокс
function ui.addCheckbox(categoryName, checkboxLabel, defaultValue, callback)
    if not window then ui.createWindow() end

    local contentArea = ui._contentArea
    local checkboxId = "Checkbox_" .. HttpService:GenerateGUID(false)

    local container = Instance.new("Frame")
    container.Name = checkboxId
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    -- Изменяем LayoutOrder чтобы новые элементы появлялись снизу
    container.LayoutOrder = 10000 + #buttons
    container.Parent = contentArea
    container.Visible = categoryName == currentCategory

    local checkBox = Instance.new("TextButton")
    checkBox.Name = "CheckBoxButton"
    checkBox.Size = UDim2.new(1, 0, 1, 0)
    checkBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    checkBox.BorderSizePixel = 0
    checkBox.Text = ""
    checkBox.AutoButtonColor = false
    checkBox.Parent = container
    
    applyCornerRadius(checkBox)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0.1, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = checkboxLabel
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkBox

    local isChecked = defaultValue or false
    local checkMark = Instance.new("Frame")
    checkMark.Size = UDim2.new(0, 20, 0, 20)
    checkMark.Position = UDim2.new(0.85, -10, 0.5, -10)
    checkMark.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    checkMark.BorderSizePixel = 0
    checkMark.Parent = checkBox
    
    applyCornerRadius(checkMark, 4)

    local checkIcon = Instance.new("TextLabel")
    checkIcon.Size = UDim2.new(1, 0, 1, 0)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = "✓"
    checkIcon.TextColor3 = Color3.fromRGB(150, 150, 255)
    checkIcon.Font = Enum.Font.SourceSansBold
    checkIcon.TextSize = 16
    checkIcon.Visible = isChecked
    checkIcon.Parent = checkMark

    local function updateVisual()
        if isChecked then
            checkBox.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
            checkIcon.Visible = true
        else
            checkBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            checkIcon.Visible = false
        end
    end

    checkBox.MouseEnter:Connect(function()
        tweenColor(checkBox, "BackgroundColor3", Color3.fromRGB(75, 75, 95))
    end)
    checkBox.MouseLeave:Connect(function()
        local col = isChecked and Color3.fromRGB(80, 80, 110) or Color3.fromRGB(65, 65, 65)
        tweenColor(checkBox, "BackgroundColor3", col)
    end)

    checkBox.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        updateVisual()
        if callback then
            pcall(callback, isChecked)
        end
    end)

    updateVisual()

    buttons[checkboxId] = {
        category = categoryName,
        label = checkboxLabel,
        callback = callback,
        value = isChecked,
        type = "checkbox"
    }
    
    elements[checkboxLabel] = container
    
    return {
        setValue = function(value)
            isChecked = value
            updateVisual()
            if callback then
                pcall(callback, isChecked)
            end
        end,
        getValue = function()
            return isChecked
        end
    }
end

-- Добавить слайдер
function ui.addSlider(categoryName, sliderLabel, minValue, maxValue, defaultValue, callback)
    if not window then ui.createWindow() end

    local contentArea = ui._contentArea
    local sliderId = "Slider_" .. HttpService:GenerateGUID(false)

    local container = Instance.new("Frame")
    container.Name = sliderId
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    -- Изменяем LayoutOrder чтобы новые элементы появлялись снизу
    container.LayoutOrder = 10000 + #buttons
    container.Parent = contentArea
    container.Visible = categoryName == currentCategory

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = sliderLabel
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "SliderBar"
    sliderBar.Size = UDim2.new(0.55, 0, 0, 16)
    sliderBar.Position = UDim2.new(0.44, 0, 0.5, -8)
    sliderBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container
    
    applyCornerRadius(sliderBar, 8)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    applyCornerRadius(sliderFill, 8)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.1, 0, 1, 0)
    valueLabel.Position = UDim2.new(1, 6, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14
    valueLabel.Parent = container

    local minV, maxV = minValue or 0, maxValue or 100
    local val = (defaultValue and math.clamp(defaultValue, minV, maxV)) or minV

    local function updateUI(value)
        local clamped = math.clamp(value, minV, maxV)
        val = clamped
        local percent = (clamped - minV) / (maxV - minV)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = string.format("%.2f", clamped)
        if callback then
            pcall(callback, clamped)
        end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mouse = player:GetMouse()
                local relativeX = math.clamp(mouse.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                local value = minV + (relativeX/sliderBar.AbsoluteSize.X)*(maxV-minV)
                updateUI(value)
            end)
            
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)

    updateUI(val)

    buttons[sliderId] = {
        category = categoryName,
        label = sliderLabel,
        callback = callback,
        value = val,
        type = "slider"
    }
    
    elements[sliderLabel] = container
    
    return {
        setValue = function(value)
            updateUI(value)
        end,
        getValue = function()
            return val
        end
    }
end

return ui
