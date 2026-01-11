-- NeverloseUI Library
-- Version 1.0

local NeverloseUI = {}
NeverloseUI.__index = NeverloseUI

-- Служебные функции
local function createBaseFrame()
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	frame.BorderSizePixel = 0
	return frame
end

local function createTextLabel(text, size)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = size or 14
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end

local function createTextBox(placeholder)
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder or ""
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	box.BorderSizePixel = 0
	return box
end

-- Цветовые темы
NeverloseUI.Themes = {
	Dark = {
		Background = Color3.fromRGB(20, 20, 25),
		Secondary = Color3.fromRGB(30, 30, 40),
		Accent = Color3.fromRGB(80, 120, 255),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 180)
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 245),
		Secondary = Color3.fromRGB(220, 220, 230),
		Accent = Color3.fromRGB(60, 100, 255),
		Text = Color3.fromRGB(30, 30, 35),
		TextSecondary = Color3.fromRGB(100, 100, 110)
	}
}

function NeverloseUI.new(title, size, position)
	local self = setmetatable({}, NeverloseUI)
	
	self.Title = title or "Neverlose UI"
	self.Size = size or UDim2.new(0, 400, 0, 500)
	self.Position = position or UDim2.new(0.5, -200, 0.5, -250)
	
	-- Основное окно
	self.Main = Instance.new("ScreenGui")
	self.Main.Name = "NeverloseUI"
	self.Main.ResetOnSpawn = false
	self.Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Контейнер окна
	self.Container = createBaseFrame()
	self.Container.Size = self.Size
	self.Container.Position = self.Position
	self.Container.Parent = self.Main
	
	-- Заголовок
	self.Header = createBaseFrame()
	self.Header.Size = UDim2.new(1, 0, 0, 40)
	self.Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	self.Header.Parent = self.Container
	
	local titleLabel = createTextLabel(self.Title, 18)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Parent = self.Header
	
	-- Кнопка закрытия
	self.CloseButton = Instance.new("TextButton")
	self.CloseButton.Text = "×"
	self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.CloseButton.Font = Enum.Font.GothamBold
	self.CloseButton.TextSize = 24
	self.CloseButton.BackgroundTransparency = 1
	self.CloseButton.Size = UDim2.new(0, 40, 1, 0)
	self.CloseButton.Position = UDim2.new(1, -40, 0, 0)
	self.CloseButton.Parent = self.Header
	self.CloseButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	-- Контейнер для вкладок
	self.TabContainer = createBaseFrame()
	self.TabContainer.Size = UDim2.new(0, 120, 1, -40)
	self.TabContainer.Position = UDim2.new(0, 0, 0, 40)
	self.TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	self.TabContainer.Parent = self.Container
	
	-- Контейнер для контента
	self.ContentContainer = createBaseFrame()
	self.ContentContainer.Size = UDim2.new(1, -120, 1, -40)
	self.ContentContainer.Position = UDim2.new(0, 120, 0, 40)
	self.ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	self.ContentContainer.Parent = self.Container
	self.ContentContainer.ClipsDescendants = true
	
	-- Списки
	self.Tabs = {}
	self.CurrentTab = nil
	self.Visible = true
	
	-- Drag functionality
	local dragging = false
	local dragStart, startPos
	
	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Container.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	self.Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			self.Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
											   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	return self
end

function NeverloseUI:Toggle()
	self.Visible = not self.Visible
	self.Container.Visible = self.Visible
end

function NeverloseUI:Show()
	self.Visible = true
	self.Container.Visible = true
end

function NeverloseUI:Hide()
	self.Visible = false
	self.Container.Visible = false
end

function NeverloseUI:Destroy()
	self.Main:Destroy()
end

function NeverloseUI:AddTab(name, icon)
	local tab = {}
	tab.Name = name
	tab.Icon = icon
	
	-- Кнопка вкладки
	tab.Button = Instance.new("TextButton")
	tab.Button.Text = "  " .. name
	tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
	tab.Button.Font = Enum.Font.GothamSemibold
	tab.Button.TextSize = 14
	tab.Button.TextXAlignment = Enum.TextXAlignment.Left
	tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	tab.Button.Size = UDim2.new(1, 0, 0, 40)
	tab.Button.Position = UDim2.new(0, 0, 0, #self.Tabs * 40)
	tab.Button.Parent = self.TabContainer
	tab.Button.BorderSizePixel = 0
	
	-- Контейнер контента вкладки
	tab.Content = Instance.new("ScrollingFrame")
	tab.Content.Size = UDim2.new(1, 0, 1, 0)
	tab.Content.Position = UDim2.new(0, 0, 0, 0)
	tab.Content.BackgroundTransparency = 1
	tab.Content.ScrollBarThickness = 3
	tab.Content.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
	tab.Content.Visible = false
	tab.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
	tab.Content.Parent = self.ContentContainer
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.Parent = tab.Content
	
	-- Иконка если есть
	if icon then
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Text = icon
		iconLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.TextSize = 16
		iconLabel.BackgroundTransparency = 1
		iconLabel.Size = UDim2.new(0, 20, 1, 0)
		iconLabel.Position = UDim2.new(0, 10, 0, 0)
		iconLabel.Parent = tab.Button
	end
	
	tab.Button.MouseButton1Click:Connect(function()
		self:SwitchTab(name)
	end)
	
	-- Анимация наведения
	tab.Button.MouseEnter:Connect(function()
		if self.CurrentTab ~= name then
			game:GetService("TweenService"):Create(
				tab.Button,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(35, 35, 40)}
			):Play()
		end
	end)
	
	tab.Button.MouseLeave:Connect(function()
		if self.CurrentTab ~= name then
			game:GetService("TweenService"):Create(
				tab.Button,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(25, 25, 30)}
			):Play()
		end
	end)
	
	table.insert(self.Tabs, tab)
	
	-- Если это первая вкладка, сделать её активной
	if #self.Tabs == 1 then
		self:SwitchTab(name)
	end
	
	return tab.Content
end

function NeverloseUI:SwitchTab(tabName)
	for _, tab in ipairs(self.Tabs) do
		if tab.Name == tabName then
			tab.Content.Visible = true
			tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			
			-- Анимация
			game:GetService("TweenService"):Create(
				tab.Button,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(35, 35, 40)}
			):Play()
		else
			tab.Content.Visible = false
			tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
	end
	self.CurrentTab = tabName
end

-- Создание секции
function NeverloseUI:CreateSection(parent, title)
	local section = {}
	
	section.Frame = createBaseFrame()
	section.Frame.Size = UDim2.new(1, -20, 0, 40)
	section.Frame.Position = UDim2.new(0, 10, 0, 0)
	section.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	section.Frame.Parent = parent
	
	section.Title = createTextLabel(title, 16)
	section.Title.Size = UDim2.new(1, -20, 1, 0)
	section.Title.Position = UDim2.new(0, 10, 0, 0)
	section.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	section.Title.Parent = section.Frame
	
	-- Контейнер для элементов
	section.Content = Instance.new("Frame")
	section.Content.Size = UDim2.new(1, 0, 0, 0)
	section.Content.Position = UDim2.new(0, 0, 0, 40)
	section.Content.BackgroundTransparency = 1
	section.Content.Parent = section.Frame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = section.Content
	
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		section.Content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
		section.Frame.Size = UDim2.new(1, -20, 0, 40 + listLayout.AbsoluteContentSize.Y + 5)
	end)
	
	return section.Content
end

-- Элементы интерфейса

function NeverloseUI:CreateBooleanSetting(parent, name, defaultValue, callback)
	local setting = {}
	setting.Value = defaultValue or false
	
	setting.Frame = createBaseFrame()
	setting.Frame.Size = UDim2.new(1, 0, 0, 30)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	setting.Frame.Parent = parent
	
	setting.Label = createTextLabel(name, 14)
	setting.Label.Size = UDim2.new(0.7, -10, 1, 0)
	setting.Label.Position = UDim2.new(0, 10, 0, 0)
	setting.Label.Parent = setting.Frame
	
	-- Toggle button
	setting.Toggle = Instance.new("Frame")
	setting.Toggle.Size = UDim2.new(0, 40, 0, 20)
	setting.Toggle.Position = UDim2.new(1, -50, 0.5, -10)
	setting.Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	setting.Toggle.Parent = setting.Frame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 10)
	toggleCorner.Parent = setting.Toggle
	
	setting.ToggleCircle = Instance.new("Frame")
	setting.ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
	setting.ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
	setting.ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	setting.ToggleCircle.Parent = setting.Toggle
	
	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(0, 8)
	circleCorner.Parent = setting.ToggleCircle
	
	-- Click detector
	setting.Click = Instance.new("TextButton")
	setting.Click.Text = ""
	setting.Click.BackgroundTransparency = 1
	setting.Click.Size = UDim2.new(1, 0, 1, 0)
	setting.Click.Parent = setting.Toggle
	
	setting.Click.MouseButton1Click:Connect(function()
		setting:Toggle()
		if callback then
			callback(setting.Value)
		end
	end)
	
	function setting:Toggle()
		self.Value = not self.Value
		
		local tweenInfo = TweenInfo.new(0.2)
		local tweenService = game:GetService("TweenService")
		
		if self.Value then
			tweenService:Create(self.Toggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(80, 120, 255)}):Play()
			tweenService:Create(self.ToggleCircle, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
		else
			tweenService:Create(self.Toggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
			tweenService:Create(self.ToggleCircle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
		end
	end
	
	-- Установить начальное значение
	if defaultValue then
		setting:Toggle()
	end
	
	return setting
end

function NeverloseUI:CreateSliderSetting(parent, name, min, max, defaultValue, callback)
	local setting = {}
	setting.Value = defaultValue or min
	setting.Min = min
	setting.Max = max
	
	setting.Frame = createBaseFrame()
	setting.Frame.Size = UDim2.new(1, 0, 0, 50)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	setting.Frame.Parent = parent
	
	setting.Label = createTextLabel(name, 14)
	setting.Label.Size = UDim2.new(1, -20, 0, 20)
	setting.Label.Position = UDim2.new(0, 10, 0, 5)
	setting.Label.Parent = setting.Frame
	
	setting.ValueLabel = createTextLabel(tostring(defaultValue), 12)
	setting.ValueLabel.Size = UDim2.new(0, 40, 0, 20)
	setting.ValueLabel.Position = UDim2.new(1, -50, 0, 5)
	setting.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	setting.ValueLabel.Parent = setting.Frame
	
	-- Slider track
	setting.Track = Instance.new("Frame")
	setting.Track.Size = UDim2.new(1, -20, 0, 4)
	setting.Track.Position = UDim2.new(0, 10, 1, -15)
	setting.Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	setting.Track.Parent = setting.Frame
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 2)
	trackCorner.Parent = setting.Track
	
	-- Slider fill
	setting.Fill = Instance.new("Frame")
	setting.Fill.Size = UDim2.new(0, 0, 1, 0)
	setting.Fill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
	setting.Fill.Parent = setting.Track
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = setting.Fill
	
	-- Slider thumb
	setting.Thumb = Instance.new("Frame")
	setting.Thumb.Size = UDim2.new(0, 12, 0, 12)
	setting.Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	setting.Thumb.Position = UDim2.new(0, -6, 0.5, -6)
	setting.Thumb.Parent = setting.Track
	
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(0, 6)
	thumbCorner.Parent = setting.Thumb
	
	-- Click detector
	setting.Click = Instance.new("TextButton")
	setting.Click.Text = ""
	setting.Click.BackgroundTransparency = 1
	setting.Click.Size = UDim2.new(1, 0, 0, 30)
	setting.Click.Position = UDim2.new(0, 0, 0.5, -15)
	setting.Click.Parent = setting.Track
	
	local dragging = false
	
	setting.Click.MouseButton1Down:Connect(function()
		dragging = true
	end)
	
	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	setting.Click.MouseMoved:Connect(function()
		if dragging then
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local relativeX = math.clamp(mouse.X - setting.Track.AbsolutePosition.X, 0, setting.Track.AbsoluteSize.X)
			local percentage = relativeX / setting.Track.AbsoluteSize.X
			
			setting.Value = math.floor((setting.Min + (setting.Max - setting.Min) * percentage) * 100) / 100
			setting.ValueLabel.Text = tostring(setting.Value)
			
			setting.Fill.Size = UDim2.new(percentage, 0, 1, 0)
			setting.Thumb.Position = UDim2.new(percentage, -6, 0.5, -6)
			
			if callback then
				callback(setting.Value)
			end
		end
	end)
	
	-- Установить начальное значение
	if defaultValue then
		local percentage = (defaultValue - min) / (max - min)
		setting.Fill.Size = UDim2.new(percentage, 0, 1, 0)
		setting.Thumb.Position = UDim2.new(percentage, -6, 0.5, -6)
	end
	
	return setting
end

function NeverloseUI:CreateListSetting(parent, name, options, defaultValue, callback)
	local setting = {}
	setting.Value = defaultValue or options[1]
	setting.Options = options
	
	setting.Frame = createBaseFrame()
	setting.Frame.Size = UDim2.new(1, 0, 0, 30)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	setting.Frame.Parent = parent
	
	setting.Label = createTextLabel(name, 14)
	setting.Label.Size = UDim2.new(0.7, -10, 1, 0)
	setting.Label.Position = UDim2.new(0, 10, 0, 0)
	setting.Label.Parent = setting.Frame
	
	-- Dropdown button
	setting.Button = Instance.new("TextButton")
	setting.Button.Text = setting.Value
	setting.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	setting.Button.Font = Enum.Font.Gotham
	setting.Button.TextSize = 14
	setting.Button.Size = UDim2.new(0.3, -10, 0.7, 0)
	setting.Button.Position = UDim2.new(0.7, 0, 0.15, 0)
	setting.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	setting.Button.Parent = setting.Frame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = setting.Button
	
	-- Dropdown options
	setting.OptionsFrame = createBaseFrame()
	setting.OptionsFrame.Size = UDim2.new(0.3, -10, 0, 0)
	setting.OptionsFrame.Position = UDim2.new(0.7, 0, 1, 5)
	setting.OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	setting.OptionsFrame.Visible = false
	setting.OptionsFrame.Parent = setting.Frame
	setting.OptionsFrame.ClipsDescendants = true
	
	local optionsList = Instance.new("UIListLayout")
	optionsList.Parent = setting.OptionsFrame
	
	setting.Open = false
	
	setting.Button.MouseButton1Click:Connect(function()
		setting.Open = not setting.Open
		setting.OptionsFrame.Visible = setting.Open
		
		if setting.Open then
			-- Clear old options
			for _, child in ipairs(setting.OptionsFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			
			-- Create new options
			for i, option in ipairs(options) do
				local optionButton = Instance.new("TextButton")
				optionButton.Text = option
				optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				optionButton.Font = Enum.Font.Gotham
				optionButton.TextSize = 14
				optionButton.Size = UDim2.new(1, 0, 0, 30)
				optionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
				optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				optionButton.Parent = setting.OptionsFrame
				
				optionButton.MouseButton1Click:Connect(function()
					setting.Value = option
					setting.Button.Text = option
					setting.Open = false
					setting.OptionsFrame.Visible = false
					
					if callback then
						callback(setting.Value)
					end
				end)
				
				-- Hover effects
				optionButton.MouseEnter:Connect(function()
					optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
				end)
				
				optionButton.MouseLeave:Connect(function()
					optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				end)
			end
			
			setting.OptionsFrame.Size = UDim2.new(0.3, -10, 0, #options * 30)
		end
	end)
	
	-- Закрыть dropdown при клике вне его
	game:GetService("UserInputService").InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and setting.Open then
			local mousePos = game:GetService("Players").LocalPlayer:GetMouse()
			if not setting.OptionsFrame.AbsolutePosition:Clamp(setting.OptionsFrame.AbsoluteSize, mousePos) then
				setting.Open = false
				setting.OptionsFrame.Visible = false
			end
		end
	end)
	
	return setting
end

function NeverloseUI:CreateColorSetting(parent, name, defaultValue, callback)
	local setting = {}
	setting.Value = defaultValue or Color3.fromRGB(255, 255, 255)
	
	setting.Frame = createBaseFrame()
	setting.Frame.Size = UDim2.new(1, 0, 0, 30)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	setting.Frame.Parent = parent
	
	setting.Label = createTextLabel(name, 14)
	setting.Label.Size = UDim2.new(0.7, -10, 1, 0)
	setting.Label.Position = UDim2.new(0, 10, 0, 0)
	setting.Label.Parent = setting.Frame
	
	-- Color preview
	setting.Preview = Instance.new("Frame")
	setting.Preview.Size = UDim2.new(0, 40, 0, 20)
	setting.Preview.Position = UDim2.new(1, -50, 0.5, -10)
	setting.Preview.BackgroundColor3 = setting.Value
	setting.Preview.Parent = setting.Frame
	
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 4)
	previewCorner.Parent = setting.Preview
	
	-- Color picker (упрощенный)
	setting.Picker = Instance.new("TextButton")
	setting.Picker.Text = "Pick"
	setting.Picker.TextColor3 = Color3.fromRGB(255, 255, 255)
	setting.Picker.Font = Enum.Font.Gotham
	setting.Picker.TextSize = 12
	setting.Picker.Size = UDim2.new(0, 40, 0, 20)
	setting.Picker.Position = UDim2.new(1, -100, 0.5, -10)
	setting.Picker.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	setting.Picker.Parent = setting.Frame
	
	local pickerCorner = Instance.new("UICorner")
	pickerCorner.CornerRadius = UDim.new(0, 4)
	pickerCorner.Parent = setting.Picker
	
	setting.Picker.MouseButton1Click:Connect(function()
		-- В реальной реализации здесь можно добавить полноценный color picker
		-- Для упрощения используем стандартный Color3.new
		local r = math.random()
		local g = math.random()
		local b = math.random()
		
		setting.Value = Color3.new(r, g, b)
		setting.Preview.BackgroundColor3 = setting.Value
		
		if callback then
			callback(setting.Value)
		end
	end)
	
	return setting
end

function NeverloseUI:CreateButton(parent, name, callback)
	local button = {}
	
	button.Frame = Instance.new("TextButton")
	button.Frame.Text = name
	button.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Frame.Font = Enum.Font.GothamSemibold
	button.Frame.TextSize = 14
	button.Frame.Size = UDim2.new(1, 0, 0, 35)
	button.Frame.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
	button.Frame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button.Frame
	
	button.Frame.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
	
	-- Hover effects
	button.Frame.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(
			button.Frame,
			TweenInfo.new(0.2),
			{BackgroundColor3 = Color3.fromRGB(100, 140, 255)}
		):Play()
	end)
	
	button.Frame.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(
			button.Frame,
			TweenInfo.new(0.2),
			{BackgroundColor3 = Color3.fromRGB(80, 120, 255)}
		):Play()
	end)
	
	return button
end

function NeverloseUI:CreateLabel(parent, text, size)
	local label = createTextLabel(text, size or 14)
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextColor3 = Color3.fromRGB(180, 180, 180)
	label.Parent = parent
	
	return label
end

function NeverloseUI:CreateTextBox(parent, placeholder, callback)
	local textbox = {}
	
	textbox.Frame = createBaseFrame()
	textbox.Frame.Size = UDim2.new(1, 0, 0, 30)
	textbox.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	textbox.Frame.Parent = parent
	
	textbox.Box = createTextBox(placeholder)
	textbox.Box.Size = UDim2.new(1, -20, 0.8, 0)
	textbox.Box.Position = UDim2.new(0, 10, 0.1, 0)
	textbox.Box.Parent = textbox.Frame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = textbox.Box
	
	textbox.Box.FocusLost:Connect(function(enterPressed)
		if enterPressed and callback then
			callback(textbox.Box.Text)
		end
	end)
	
	return textbox
end

return NeverloseUI
