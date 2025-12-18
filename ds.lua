-- UI Library Source
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomRobloxUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Основное окно
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 320)
    Main.Position = UDim2.new(0.5, -250, 0.5, -160)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Main

    -- Плавный Drag (Перетаскивание)
    local dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            TweenService:Create(Main, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    -- Боковое меню
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = Sidebar
    SidebarLayout.Padding = UDim.new(0, 2)

    -- Контентная часть
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -150, 1, -50)
    PageContainer.Position = UDim2.new(0, 145, 0, 45)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    -- Хедер и Поиск
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.Parent = Main

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Поиск..."
    SearchBox.Size = UDim2.new(0, 120, 0, 25)
    SearchBox.Position = UDim2.new(1, -130, 0.5, -12)
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SearchBox.TextColor3 = Color3.new(1,1,1)
    SearchBox.Parent = Header
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    local Tabs = {}
    
    function Tabs:CreateTab(name)
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = Sidebar

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
            Page.Visible = true
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end)

        local Elements = {}

        -- Toggle
        function Elements:AddToggle(text, callback)
            local Tgl = Instance.new("TextButton")
            Tgl.Name = text
            Tgl.Size = UDim2.new(1, -10, 0, 35)
            Tgl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Tgl.Text = "  " .. text
            Tgl.TextColor3 = Color3.new(1,1,1)
            Tgl.TextXAlignment = Enum.TextXAlignment.Left
            Tgl.Parent = Page
            Instance.new("UICorner", Tgl)

            local Check = Instance.new("Frame")
            Check.Size = UDim2.new(0, 16, 0, 16)
            Check.Position = UDim2.new(1, -25, 0.5, -8)
            Check.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Check.Parent = Tgl
            Instance.new("UICorner", Check).CornerRadius = UDim.new(1, 0)

            local active = false
            Tgl.MouseButton1Click:Connect(function()
                active = not active
                callback(active)
                TweenService:Create(Check, TweenInfo.new(0.2), {
                    BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
                }):Play()
            end)
        end

        -- Slider
        function Elements:AddSlider(text, min, max, callback)
            local Sld = Instance.new("Frame")
            Sld.Name = text
            Sld.Size = UDim2.new(1, -10, 0, 45)
            Sld.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Sld.Parent = Page
            Instance.new("UICorner", Sld)

            local Label = Instance.new("TextLabel")
            Label.Text = "  " .. text
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.new(1,1,1)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Sld

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -20, 0, 4)
            Bar.Position = UDim2.new(0, 10, 0, 30)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Bar.Parent = Sld

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            Fill.Parent = Bar

            local function UpdateSlider()
                local percent = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                callback(math.floor(min + (max - min) * percent))
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move
                    move = RunService.RenderStepped:Connect(UpdateSlider)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end
                    end)
                end
            end)
        end

        return Elements
    end

    -- Логика поиска
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local input = SearchBox.Text:lower()
        for _, page in pairs(PageContainer:GetChildren()) do
            for _, el in pairs(page:GetChildren()) do
                if el:IsA("TextButton") or el:IsA("Frame") then
                    el.Visible = el.Name:lower():find(input) and true or false
                end
            end
        end
    end)

    return Tabs
end

return Library
