-- NeverloseUI Library v2.0
-- Исправленная и улучшенная версия

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local NeverloseUI = {}
NeverloseUI.__index = NeverloseUI

-- Безопасное создание экземпляров
local function safeCreate(className, parent)
	local success, instance = pcall(function()
		return Instance.new(className)
	end)
	
	if success and instance then
		if parent then
			pcall(function()
				instance.Parent = parent
			end)
		end
		return instance
	end
	return nil
end

-- Создание базовых элементов с обработкой ошибок
local function createBaseFrame()
	local frame = safeCreate("Frame")
	if frame then
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		frame.BorderSizePixel = 0
	end
	return frame
end

local function createTextLabel(text, size)
	local label = safeCreate("TextLabel")
	if label then
		label.Text = text or ""
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = size or 14
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
	end
	return label
end

function NeverloseUI.new(title, size, position)
	local self = setmetatable({}, NeverloseUI)
	
	self.Title = title or "Neverlose UI"
	self.Size = size or UDim2.new(0, 450, 0, 550)
	self.Position = position or UDim2.new(0.5, -225, 0.5, -275)
	
	-- Основное окно
	self.Main = safeCreate("ScreenGui")
	if not self.Main then return nil end
	
	self.Main.Name = "NeverloseUIV2"
	self.Main.ResetOnSpawn = false
	self.Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Main.IgnoreGuiInset = true
	
	-- Проверка на наличие CoreGui
	pcall(function()
		if game:GetService("CoreGui") then
			self.Main.Parent = game:GetService("CoreGui")
		else
			self.Main.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		end
	end)
	
	-- Контейнер окна
	self.Container = createBaseFrame()
	if not self.Container then return nil end
	
	self.Container.Size = self.Size
	self.Container.Position = self.Position
	self.Container.Parent = self.Main
	
	-- Заголовок
	self.Header = createBaseFrame()
	if self.Header then
		self.Header.Size = UDim2.new(1, 0, 0, 45)
		self.Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		self.Header.Parent = self.Container
		
		-- Текст заголовка
		local titleLabel = createTextLabel(self.Title, 18)
		if titleLabel then
			titleLabel.Size = UDim2.new(1, -50, 1, 0)
			titleLabel.Position = UDim2.new(0, 15, 0, 0)
			titleLabel.TextColor3 = Color3.fromRGB(80, 120, 255)
			titleLabel.Parent = self.Header
		end
		
		-- Кнопка закрытия
		self.CloseButton = safeCreate("TextButton")
		if self.CloseButton then
			self.CloseButton.Text = "×"
			self.CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
			self.CloseButton.Font = Enum.Font.GothamBold
			self.CloseButton.TextSize = 24
			self.CloseButton.BackgroundTransparency = 1
			self.CloseButton.Size = UDim2.new(0, 40, 1, 0)
			self.CloseButton.Position = UDim2.new(1, -40, 0, 0)
			self.CloseButton.Parent = self.Header
			self.CloseButton.MouseButton1Click:Connect(function()
				self:Toggle()
			end)
		end
	end
	
	-- Контейнер для вкладок
	self.TabContainer = createBaseFrame()
	if self.TabContainer then
		self.TabContainer.Size = UDim2.new(0, 130, 1, -45)
		self.TabContainer.Position = UDim2.new(0, 0, 0, 45)
		self.TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		self.TabContainer.Parent = self.Container
	end
	
	-- Контейнер для контента
	self.ContentContainer = createBaseFrame()
	if self.ContentContainer then
		self.ContentContainer.Size = UDim2.new(1, -130, 1, -45)
		self.ContentContainer.Position = UDim2.new(0, 130, 0, 45)
		self.ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		self.ContentContainer.Parent = self.Container
		self.ContentContainer.ClipsDescendants = true
	end
	
	-- Списки
	self.Tabs = {}
	self.CurrentTab = nil
	self.Visible = true
	self.Elements = {}
	
	-- Drag functionality с улучшенной обработкой
	local dragging = false
	local dragStart, startPos
	local connection1, connection2
	
	local function startDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Container.Position
		end
	end
	
	local function endDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end
	
	local function updateDrag(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local newX = startPos.X.Offset + delta.X
			local newY = startPos.Y.Offset + delta.Y
			
			-- Ограничение перемещения в пределах экрана
			newX = math.clamp(newX, 0, workspace.CurrentCamera.ViewportSize.X - self.Container.AbsoluteSize.X)
			newY = math.clamp(newY, 0, workspace.CurrentCamera.ViewportSize.Y - self.Container.AbsoluteSize.Y)
			
			self.Container.Position = UDim2.new(0, newX, 0, newY)
		end
	end
	
	if self.Header then
		connection1 = self.Header.InputBegan:Connect(startDrag)
		connection2 = self.Header.InputChanged:Connect(updateDrag)
		UserInputService.InputEnded:Connect(endDrag)
	end
	
	-- Сохраняем соединения для очистки
	self.Connections = {connection1, connection2}
	
	return self
end

function NeverloseUI:Toggle()
	self.Visible = not self.Visible
	if self.Container then
		self.Container.Visible = self.Visible
	end
end

function NeverloseUI:Show()
	self.Visible = true
	if self.Container then
		self.Container.Visible = true
	end
end

function NeverloseUI:Hide()
	self.Visible = false
	if self.Container then
		self.Container.Visible = false
	end
end

function NeverloseUI:Destroy()
	-- Очистка соединений
	if self.Connections then
		for _, connection in ipairs(self.Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
	
	-- Очистка элементов
	if self.Elements then
		for _, element in ipairs(self.Elements) do
			if element and element.Destroy then
				pcall(function() element:Destroy() end)
			end
		end
	end
	
	-- Удаление GUI
	if self.Main then
		pcall(function() self.Main:Destroy() end)
	end
end

function NeverloseUI:AddTab(name, icon)
	local tab = {}
	tab.Name = name
	tab.Icon = icon
	
	-- Кнопка вкладки
	tab.Button = safeCreate("TextButton")
	if not tab.Button then return nil end
	
	tab.Button.Text = icon and (icon .. "  " .. name) or ("  " .. name)
	tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
	tab.Button.Font = Enum.Font.GothamSemibold
	tab.Button.TextSize = 14
	tab.Button.TextXAlignment = Enum.TextXAlignment.Left
	tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	tab.Button.Size = UDim2.new(1, 0, 0, 45)
	tab.Button.Position = UDim2.new(0, 0, 0, #self.Tabs * 45)
	tab.Button.Parent = self.TabContainer
	tab.Button.BorderSizePixel = 0
	
	-- Контейнер контента вкладки
	tab.Content = safeCreate("ScrollingFrame")
	if tab.Content then
		tab.Content.Size = UDim2.new(1, 0, 1, 0)
		tab.Content.Position = UDim2.new(0, 0, 0, 0)
		tab.Content.BackgroundTransparency = 1
		tab.Content.ScrollBarThickness = 4
		tab.Content.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
		tab.Content.ScrollBarImageTransparency = 0.5
		tab.Content.Visible = false
		tab.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
		tab.Content.ScrollingDirection = Enum.ScrollingDirection.Y
		tab.Content.Parent = self.ContentContainer
		
		local uiListLayout = safeCreate("UIListLayout")
		if uiListLayout then
			uiListLayout.Padding = UDim.new(0, 8)
			uiListLayout.Parent = tab.Content
		end
		
		local padding = safeCreate("UIPadding")
		if padding then
			padding.PaddingTop = UDim.new(0, 10)
			padding.PaddingLeft = UDim.new(0, 10)
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = tab.Content
		end
	end
	
	tab.Button.MouseButton1Click:Connect(function()
		self:SwitchTab(name)
	end)
	
	-- Анимация наведения
	tab.Button.MouseEnter:Connect(function()
		if self.CurrentTab ~= name then
			TweenService:Create(
				tab.Button,
				TweenInfo.new(0.15),
				{BackgroundColor3 = Color3.fromRGB(35, 35, 45)}
			):Play()
		end
	end)
	
	tab.Button.MouseLeave:Connect(function()
		if self.CurrentTab ~= name then
			TweenService:Create(
				tab.Button,
				TweenInfo.new(0.15),
				{BackgroundColor3 = Color3.fromRGB(25, 25, 35)}
			):Play()
		end
	end)
	
	table.insert(self.Tabs, tab)
	
	-- Если это первая вкладка, сделать её активной
	if #self.Tabs == 1 then
		task.wait(0.1) -- Небольшая задержка для стабильности
		self:SwitchTab(name)
	end
	
	return tab.Content
end

function NeverloseUI:SwitchTab(tabName)
	for _, tab in ipairs(self.Tabs) do
		if tab.Name == tabName then
			tab.Content.Visible = true
			tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			tab.Button.TextColor3 = Color3.fromRGB(80, 120, 255)
			
			TweenService:Create(
				tab.Button,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(35, 35, 45)}
			):Play()
		else
			tab.Content.Visible = false
			tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
			tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
	end
	self.CurrentTab = tabName
end

-- Создание секции с улучшенным дизайном
function NeverloseUI:CreateSection(parent, title)
	local section = {}
	
	section.Frame = createBaseFrame()
	if not section.Frame then return nil end
	
	section.Frame.Size = UDim2.new(1, -20, 0, 45)
	section.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	section.Frame.Parent = parent
	
	local corner = safeCreate("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = section.Frame
	end
	
	-- Верхняя линия акцента
	local accentLine = safeCreate("Frame")
	if accentLine then
		accentLine.Size = UDim2.new(1, 0, 0, 2)
		accentLine.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		accentLine.BorderSizePixel = 0
		accentLine.Parent = section.Frame
		
		local lineCorner = safeCreate("UICorner")
		if lineCorner then
			lineCorner.CornerRadius = UDim.new(0, 1)
			lineCorner.Parent = accentLine
		end
	end
	
	section.Title = createTextLabel(title, 16)
	if section.Title then
		section.Title.Size = UDim2.new(1, -20, 0, 25)
		section.Title.Position = UDim2.new(0, 15, 0, 10)
		section.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		section.Title.Parent = section.Frame
	end
	
	-- Контейнер для элементов
	section.Content = safeCreate("Frame")
	if section.Content then
		section.Content.Size = UDim2.new(1, 0, 0, 0)
		section.Content.Position = UDim2.new(0, 0, 0, 45)
		section.Content.BackgroundTransparency = 1
		section.Content.Parent = section.Frame
		
		local listLayout = safeCreate("UIListLayout")
		if listLayout then
			listLayout.Padding = UDim.new(0, 6)
			listLayout.Parent = section.Content
		end
		
		local padding = safeCreate("UIPadding")
		if padding then
			padding.PaddingTop = UDim.new(0, 10)
			padding.PaddingLeft = UDim.new(0, 10)
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = section.Content
		end
		
		-- Авторазмер
		if listLayout then
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				section.Content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
				section.Frame.Size = UDim2.new(1, -20, 0, 45 + listLayout.AbsoluteContentSize.Y + 15)
			end)
		end
	end
	
	table.insert(self.Elements, section)
	
	return section.Content
end

-- Улучшенный BooleanSetting
function NeverloseUI:CreateBooleanSetting(parent, name, defaultValue, callback)
	local setting = {}
	setting.Value = defaultValue or false
	
	setting.Frame = createBaseFrame()
	if not setting.Frame then return nil end
	
	setting.Frame.Size = UDim2.new(1, 0, 0, 35)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	setting.Frame.Parent = parent
	
	local corner = safeCreate("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = setting.Frame
	end
	
	setting.Label = createTextLabel(name, 14)
	if setting.Label then
		setting.Label.Size = UDim2.new(0.7, -10, 1, 0)
		setting.Label.Position = UDim2.new(0, 15, 0, 0)
		setting.Label.TextColor3 = Color3.fromRGB(240, 240, 240)
		setting.Label.Parent = setting.Frame
	end
	
	-- Toggle button
	setting.Toggle = safeCreate("Frame")
	if setting.Toggle then
		setting.Toggle.Size = UDim2.new(0, 50, 0, 24)
		setting.Toggle.Position = UDim2.new(1, -60, 0.5, -12)
		setting.Toggle.BackgroundColor3 = setting.Value and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(60, 60, 75)
		setting.Toggle.Parent = setting.Frame
		
		local toggleCorner = safeCreate("UICorner")
		if toggleCorner then
			toggleCorner.CornerRadius = UDim.new(0, 12)
			toggleCorner.Parent = setting.Toggle
		end
		
		setting.ToggleCircle = safeCreate("Frame")
		if setting.ToggleCircle then
			setting.ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
			setting.ToggleCircle.Position = setting.Value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
			setting.ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			setting.ToggleCircle.Parent = setting.Toggle
			
			local circleCorner = safeCreate("UICorner")
			if circleCorner then
				circleCorner.CornerRadius = UDim.new(0, 10)
				circleCorner.Parent = setting.ToggleCircle
			end
		end
	end
	
	-- Click detector
	setting.Click = safeCreate("TextButton")
	if setting.Click then
		setting.Click.Text = ""
		setting.Click.BackgroundTransparency = 1
		setting.Click.Size = UDim2.new(1, 0, 1, 0)
		setting.Click.Parent = setting.Frame
		
		setting.Click.MouseButton1Click:Connect(function()
			setting:Toggle()
			if callback then
				pcall(callback, setting.Value)
			end
		end)
	end
	
	function setting:Toggle()
		self.Value = not self.Value
		
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		if self.Value then
			TweenService:Create(self.Toggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(80, 120, 255)}):Play()
			TweenService:Create(self.ToggleCircle, tweenInfo, {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
		else
			TweenService:Create(self.Toggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
			TweenService:Create(self.ToggleCircle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
		end
	end
	
	function setting:SetValue(value)
		if self.Value ~= value then
			self:Toggle()
		end
	end
	
	function setting:Destroy()
		if self.Frame then
			pcall(function() self.Frame:Destroy() end)
		end
	end
	
	table.insert(self.Elements, setting)
	
	return setting
end

-- Keybind setting (новая функция)
function NeverloseUI:CreateKeybindSetting(parent, name, defaultKey, callback)
	local setting = {}
	setting.Value = defaultKey or Enum.KeyCode.Unknown
	
	setting.Frame = createBaseFrame()
	if not setting.Frame then return nil end
	
	setting.Frame.Size = UDim2.new(1, 0, 0, 35)
	setting.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	setting.Frame.Parent = parent
	
	local corner = safeCreate("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = setting.Frame
	end
	
	setting.Label = createTextLabel(name, 14)
	if setting.Label then
		setting.Label.Size = UDim2.new(0.7, -10, 1, 0)
		setting.Label.Position = UDim2.new(0, 15, 0, 0)
		setting.Label.Parent = setting.Frame
	end
	
	-- Key display
	setting.KeyButton = safeCreate("TextButton")
	if setting.KeyButton then
		setting.KeyButton.Text = tostring(setting.Value.Name):gsub("^%l", string.upper)
		setting.KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		setting.KeyButton.Font = Enum.Font.GothamSemibold
		setting.KeyButton.TextSize = 13
		setting.KeyButton.Size = UDim2.new(0.3, -10, 0.7, 0)
		setting.KeyButton.Position = UDim2.new(0.7, 0, 0.15, 0)
		setting.KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
		setting.KeyButton.Parent = setting.Frame
		
		local buttonCorner = safeCreate("UICorner")
		if buttonCorner then
			buttonCorner.CornerRadius = UDim.new(0, 4)
			buttonCorner.Parent = setting.KeyButton
		end
	end
	
	setting.Listening = false
	
	function setting:StartListening()
		self.Listening = true
		setting.KeyButton.Text = "..."
		setting.KeyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		
		local connection
		connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				self.Value = input.KeyCode
				setting.KeyButton.Text = tostring(input.KeyCode.Name):gsub("^%l", string.upper)
				self.Listening = false
				setting.KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
				
				if callback then
					pcall(callback, self.Value)
				end
				
				if connection then
					connection:Disconnect()
				end
			end
		end)
	end
	
	if setting.KeyButton then
		setting.KeyButton.MouseButton1Click:Connect(function()
			setting:StartListening()
		end)
	end
	
	function setting:SetKey(keyCode)
		self.Value = keyCode
		if setting.KeyButton then
			setting.KeyButton.Text = tostring(keyCode.Name):gsub("^%l", string.upper)
		end
	end
	
	function setting:Destroy()
		if self.Frame then
			pcall(function() self.Frame:Destroy() end)
		end
	end
	
	table.insert(self.Elements, setting)
	
	return setting
end

-- Безопасный вызов функции
local function safeCallback(callback, ...)
	if callback then
		pcall(callback, ...)
	end
end

-- Пример использования с обработкой ошибок
local function exampleUsage()
	-- Создание интерфейса с обработкой ошибок
	local success, UI = pcall(function()
		return NeverloseUI.new("Neverlose V2", UDim2.new(0, 500, 0, 600))
	end)
	
	if not success or not UI then
		warn("Failed to create Neverlose UI")
		return
	end
	
	-- Создание вкладок
	local aimTab = UI:AddTab("Aimbot", "🎯")
	local visTab = UI:AddTab("Visuals", "👁")
	local miscTab = UI:AddTab("Misc", "⚙")
	local settingsTab = UI:AddTab("Settings", "⚙")
	
	-- Создание секций
	if aimTab then
		local aimSection = UI:CreateSection(aimTab, "Aimbot Settings")
		
		-- Boolean настройка
		local aimToggle = UI:CreateBooleanSetting(aimSection, "Enable Aimbot", false, function(value)
			print("Aimbot:", value)
		end)
		
		-- Keybind настройка
		local aimKey = UI:CreateKeybindSetting(aimSection, "Aimbot Key", Enum.KeyCode.LeftAlt, function(key)
			print("Aimbot key set to:", key)
		end)
	end
	
	-- Корректное удаление при необходимости
	game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
		-- Автоматическое обновление UI при респавне
		if UI then
			UI:Destroy()
		end
	end)
	
	return UI
end

-- Экспорт библиотеки
return {
	new = function(...)
		return NeverloseUI.new(...)
	end,
	
	-- Быстрое создание UI
	create = function()
		return exampleUsage()
	end,
	
	-- Вспомогательные функции
	createBoolean = function(parent, ...)
		return NeverloseUI.CreateBooleanSetting(parent, ...)
	end,
	
	createKeybind = function(parent, ...)
		return NeverloseUI.CreateKeybindSetting(parent, ...)
	end,
	
	createSection = function(parent, ...)
		return NeverloseUI.CreateSection(parent, ...)
	end
}
