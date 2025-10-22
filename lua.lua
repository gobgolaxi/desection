local ui = {}

local UIS = game:GetService("UserInputService")

function ui.createwindow(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(0, 400, 0, 40)
    topBar.Position = UDim2.new(0.5, -200, 0.2, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    topBar.Parent = screenGui
    topBar.Name = "TopBar"

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 22
    titleLabel.Parent = topBar

    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 120, 1, -40)
    leftPanel.Position = UDim2.new(0, 0, 0, 40)
    leftPanel.BackgroundColor3 = Color3.fromRGB(35,35,35)
    leftPanel.Parent = topBar.Parent

    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0, 280, 1, -40)
    mainPanel.Position = UDim2.new(0, 120, 0, 40)
    mainPanel.BackgroundColor3 = Color3.fromRGB(55,55,55)
    mainPanel.Parent = topBar.Parent

    local categories = {}

    -- Drag logic
    local dragging = false
    local offset
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = topBar.Position - UDim2.new(0, UIS:GetMouseLocation().X, 0, UIS:GetMouseLocation().Y)
        end
    end)
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UIS:GetMouseLocation()
            topBar.Position = UDim2.new(0, mouse.X, 0, mouse.Y) + offset
            leftPanel.Position = UDim2.new(0, 0, 0, 40) + UDim2.new(0, topBar.Position.X.Offset, 0, topBar.Position.Y.Offset)
            mainPanel.Position = UDim2.new(0, 120, 0, 40) + UDim2.new(0, topBar.Position.X.Offset, 0, topBar.Position.Y.Offset)
        end
    end)

    return {
        _gui = screenGui,
        _categories = categories,
        _mainPanel = mainPanel,
        _leftPanel = leftPanel,
        addcategory = function(self, name)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
            btn.Text = name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.fromRGB(180,180,180)
            btn.Parent = self._leftPanel

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -10, 1, 0)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = self._mainPanel
            container.Visible = false

            self._categories[name] = container

            btn.MouseButton1Click:Connect(function()
                for _, c in pairs(self._mainPanel:GetChildren()) do
                    if c:IsA("Frame") then c.Visible = false end
                end
                container.Visible = true
            end)

            if #self._leftPanel:GetChildren() == 1 then
                container.Visible = true -- автоселект первой категории
            end
        end,

        addbutton = function(self, category, btn_name, callback)
            local cont = self._categories[category]
            if not cont then error("Category not found: " .. category) end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(75,75,75)
            btn.Text = btn_name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.fromRGB(200,200,200)
            btn.Parent = cont

            btn.MouseButton1Click:Connect(callback)
        end,
    }
end

return ui
