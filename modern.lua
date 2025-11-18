-- Modern UI Library for Roblox Studio
-- Author: Assistant
-- Version: 1.2

local ModernUILibrary = {}
ModernUILibrary.__index = ModernUILibrary

-- Цветовые схемы
ModernUILibrary.Themes = {
	Dark = {
		Background = Color3.fromRGB(30, 30, 30),
		Secondary = Color3.fromRGB(45, 45, 45),
		Accent = Color3.fromRGB(0, 120, 215),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(60, 60, 60)
	},
	Light = {
		Background = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(245, 245, 245),
		Accent = Color3.fromRGB(0, 120, 215),
		Text = Color3.fromRGB(0, 0, 0),
		Border = Color3.fromRGB(220, 220, 220)
	}
}

function ModernUILibrary.new(options)
	options = options or {}
	local self = setmetatable({}, ModernUILibrary)
	
	-- Настройки по умолчанию
	self.WindowTitle = options.Title or "Modern UI"
	self.WindowSize = options.Size or UDim2.new(0, 400, 0, 500)
	self.Theme = options.Theme or "Dark"
	self.CornerRadius = options.CornerRadius or 8
	self.IsMinimized = false
	self.CurrentCategory = nil
	self.CurrentSize = options.Size or UDim2.new(0, 400, 0, 500) -- Сохраняем текущий размер
	
	-- Создаем основной экран
	self:CreateScreenGui()
	self:CreateMainWindow()
	self:CreateTopBar()
	self:CreateCategories()
	self:CreateResizeHandle()
	
	return self
end

function ModernUILibrary:CreateScreenGui()
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "ModernUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

function ModernUILibrary:CreateMainWindow()
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = self.WindowSize
	self.MainFrame.Position = UDim2.new(0.5, -self.WindowSize.X.Offset/2, 0.5, -self.WindowSize.Y.Offset/2)
	self.MainFrame.BackgroundColor3 = self.Themes[self.Theme].Background
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.ClipsDescendants = true
	self.MainFrame.Parent = self.ScreenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, self.CornerRadius)
	corner.Parent = self.MainFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Themes[self.Theme].Border
	stroke.Thickness = 1
	stroke.Parent = self.MainFrame
end

function ModernUILibrary:CreateTopBar()
	-- Старый топ-бар (как в оригинале)
	self.TopBar = Instance.new("Frame")
	self.TopBar.Name = "TopBar"
	self.TopBar.Size = UDim2.new(1, 0, 0, 40)
	self.TopBar.Position = UDim2.new(0, 0, 0, 0)
	self.TopBar.BackgroundColor3 = self.Themes[self.Theme].Secondary
	self.TopBar.BorderSizePixel = 0
	self.TopBar.Parent = self.MainFrame
	
	-- Закругление для всего топ-бара
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, self.CornerRadius)
	topBarCorner.Parent = self.TopBar
	
	-- Маска чтобы убрать нижние закругления
	local topBarMask = Instance.new("Frame")
	topBarMask.Name = "TopBarMask"
	topBarMask.Size = UDim2.new(1, 0, 1, self.CornerRadius)
	topBarMask.Position = UDim2.new(0, 0, 0, 0)
	topBarMask.BackgroundColor3 = self.Themes[self.Theme].Secondary
	topBarMask.BorderSizePixel = 0
	topBarMask.ZIndex = 2
	topBarMask.Parent = self.TopBar
	
	-- Заголовок окна
	self.TitleLabel = Instance.new("TextLabel")
	self.TitleLabel.Name = "TitleLabel"
	self.TitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
	self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Text = self.WindowTitle
	self.TitleLabel.TextColor3 = self.Themes[self.Theme].Text
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Font = Enum.Font.Gotham
	self.TitleLabel.TextSize = 14
	self.TitleLabel.ZIndex = 3
	self.TitleLabel.Parent = self.TopBar
	
	-- Кнопка переключения темы
	self.ThemeButton = Instance.new("TextButton")
	self.ThemeButton.Name = "ThemeButton"
	self.ThemeButton.Size = UDim2.new(0, 30, 0, 30)
	self.ThemeButton.Position = UDim2.new(1, -105, 0.5, -15)
	self.ThemeButton.BackgroundColor3 = self.Themes[self.Theme].Accent
	self.ThemeButton.Text = "🌓"
	self.ThemeButton.TextColor3 = Color3.new(1, 1, 1)
	self.ThemeButton.Font = Enum.Font.GothamBold
	self.ThemeButton.TextSize = 14
	self.ThemeButton.ZIndex = 3
	self.ThemeButton.Parent = self.TopBar
	
	local themeCorner = Instance.new("UICorner")
	themeCorner.CornerRadius = UDim.new(0, 4)
	themeCorner.Parent = self.ThemeButton
	
	-- Кнопка сворачивания
	self.MinimizeButton = Instance.new("TextButton")
	self.MinimizeButton.Name = "MinimizeButton"
	self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
	self.MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
	self.MinimizeButton.BackgroundColor3 = self.Themes[self.Theme].Accent
	self.MinimizeButton.Text = "_"
	self.MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
	self.MinimizeButton.Font = Enum.Font.GothamBold
	self.MinimizeButton.TextSize = 16
	self.MinimizeButton.ZIndex = 3
	self.MinimizeButton.Parent = self.TopBar
	
	local minimizeCorner = Instance.new("UICorner")
	minimizeCorner.CornerRadius = UDim.new(0, 4)
	minimizeCorner.Parent = self.MinimizeButton
	
	-- Кнопка закрытия
	self.CloseButton = Instance.new("TextButton")
	self.CloseButton.Name = "CloseButton"
	self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
	self.CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
	self.CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
	self.CloseButton.Text = "X"
	self.CloseButton.TextColor3 = Color3.new(1, 1, 1)
	self.CloseButton.Font = Enum.Font.GothamBold
	self.CloseButton.TextSize = 14
	self.CloseButton.ZIndex = 3
	self.CloseButton.Parent = self.TopBar
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 4)
	closeCorner.Parent = self.CloseButton
	
	-- Функционал драггинга
	self:Dragify(self.TopBar)
	
	-- Обработчики событий
	self.ThemeButton.MouseButton1Click:Connect(function()
		self:ToggleTheme()
	end)
	
	self.MinimizeButton.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)
	
	self.CloseButton.MouseButton1Click:Connect(function()
		self:Close()
	end)
end

function ModernUILibrary:CreateCategories()
	-- Левая панель категорий
	self.CategoriesFrame = Instance.new("Frame")
	self.CategoriesFrame.Name = "CategoriesFrame"
	self.CategoriesFrame.Size = UDim2.new(0, 120, 1, -40)
	self.CategoriesFrame.Position = UDim2.new(0, 0, 0, 40)
	self.CategoriesFrame.BackgroundColor3 = self.Themes[self.Theme].Secondary
	self.CategoriesFrame.BorderSizePixel = 0
	self.CategoriesFrame.Parent = self.MainFrame
	
	-- Контейнер для контента
	self.ContentFrame = Instance.new("Frame")
	self.ContentFrame.Name = "ContentFrame"
	self.ContentFrame.Size = UDim2.new(1, -120, 1, -40)
	self.ContentFrame.Position = UDim2.new(0, 120, 0, 40)
	self.ContentFrame.BackgroundTransparency = 1
	self.ContentFrame.ClipsDescendants = true
	self.ContentFrame.Parent = self.MainFrame
	
	self.Categories = {}
	self.CategoryButtons = {}
end

function ModernUILibrary:CreateResizeHandle()
	self.ResizeHandle = Instance.new("Frame")
	self.ResizeHandle.Name = "ResizeHandle"
	self.ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
	self.ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
	self.ResizeHandle.BackgroundTransparency = 0.5
	self.ResizeHandle.BackgroundColor3 = self.Themes[self.Theme].Accent
	self.ResizeHandle.BorderSizePixel = 0
	self.ResizeHandle.ZIndex = 10
	self.ResizeHandle.Parent = self.MainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = self.ResizeHandle
	
	-- Иконка треугольника (улучшенная)
	local triangle = Instance.new("ImageLabel")
	triangle.Name = "Triangle"
	triangle.Size = UDim2.new(0, 12, 0, 12)
	triangle.Position = UDim2.new(0.5, -6, 0.5, -6)
	triangle.BackgroundTransparency = 1
	triangle.Image = "rbxassetid://6031094678" -- Более четкий треугольник
	triangle.ImageColor3 = Color3.new(1, 1, 1)
	triangle.Rotation = 45
	triangle.Parent = self.ResizeHandle
	
	self:MakeResizable()
end

function ModernUILibrary:Dragify(frame)
	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil
	
	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
		self.MainFrame.Position = position
	end
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragToggle = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
			
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
					connection:Disconnect()
				end
			end)
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragToggle then
				updateInput(input)
			end
		end
	end)
end

function ModernUILibrary:MakeResizable()
	local resizing = false
	local startPos = nil
	local startSize = nil
	
	self.ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startPos = input.Position
			startSize = self.MainFrame.Size
			
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					connection:Disconnect()
				end
			end)
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if resizing then
				local delta = input.Position - startPos
				local newSize = UDim2.new(
					startSize.X.Scale,
					math.max(300, startSize.X.Offset + delta.X),
					startSize.Y.Scale,
					math.max(200, startSize.Y.Offset + delta.Y)
				)
				self.MainFrame.Size = newSize
				-- Сохраняем текущий размер
				self.CurrentSize = newSize
			end
		end
	end)
end

function ModernUILibrary:ToggleTheme()
	-- Переключение между темами
	if self.Theme == "Dark" then
		self.Theme = "Light"
	else
		self.Theme = "Dark"
	end
	
	-- Обновляем цвета интерфейса
	self:UpdateTheme()
end

function ModernUILibrary:UpdateTheme()
	local theme = self.Themes[self.Theme]
	
	-- Обновляем основные цвета
	self.MainFrame.BackgroundColor3 = theme.Background
	self.TopBar.BackgroundColor3 = theme.Secondary
	self.TopBar:FindFirstChild("TopBarMask").BackgroundColor3 = theme.Secondary
	self.TitleLabel.TextColor3 = theme.Text
	
	-- Обновляем кнопки
	self.ThemeButton.BackgroundColor3 = theme.Accent
	self.MinimizeButton.BackgroundColor3 = theme.Accent
	
	-- Обновляем обводку
	self.MainFrame.UIStroke.Color = theme.Border
	
	-- Обновляем категории
	self.CategoriesFrame.BackgroundColor3 = theme.Secondary
	
	-- Обновляем кнопки категорий
	for name, button in pairs(self.CategoryButtons) do
		if name == self.CurrentCategory then
			button.BackgroundColor3 = theme.Accent
		else
			button.BackgroundColor3 = theme.Background
		end
		button.TextColor3 = theme.Text
	end
	
	-- Обновляем элементы в категориях
	for _, categoryFrame in pairs(self.Categories) do
		self:UpdateCategoryTheme(categoryFrame, theme)
	end
end

function ModernUILibrary:UpdateCategoryTheme(categoryFrame, theme)
	for _, child in ipairs(categoryFrame:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
			if child.Name == "Checkbox" or child.Name == "DropdownButton" or child.Name == "TextBox" then
				child.BackgroundColor3 = theme.Secondary
				child.TextColor3 = theme.Text
				if child:FindFirstChild("UIStroke") then
					child.UIStroke.Color = theme.Border
				end
			elseif child.BackgroundTransparency == 1 then
				child.TextColor3 = theme.Text
			end
		elseif child:IsA("Frame") then
			if child.Name == "Track" then
				child.BackgroundColor3 = theme.Secondary
			elseif child.Name == "Fill" then
				child.BackgroundColor3 = theme.Accent
			end
		end
	end
end

function ModernUILibrary:ToggleMinimize()
	self.IsMinimized = not self.IsMinimized
	
	if self.IsMinimized then
		-- Анимация сворачивания - сохраняем ширину, меняем только высоту
		local currentWidth = self.MainFrame.Size.X.Offset
		local targetSize = UDim2.new(0, currentWidth, 0, 40)
		
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(self.MainFrame, tweenInfo, {
			Size = targetSize
		})
		tween:Play()
		
		-- Показываем полное закругление у топбара при сворачивании
		self.TopBar.UICorner.CornerRadius = UDim.new(0, self.CornerRadius)
	else
		-- Анимация разворачивания - используем сохраненный размер
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(self.MainFrame, tweenInfo, {
			Size = self.CurrentSize
		})
		tween:Play()
		
		-- Убираем нижние закругления у топбара при разворачивании
		-- Для этого используем маску, поэтому оставляем закругление
		self.TopBar.UICorner.CornerRadius = UDim.new(0, self.CornerRadius)
	end
end

function ModernUILibrary:Close()
	self.ScreenGui:Destroy()
end

function ModernUILibrary:AddCategory(name)
	local categoryButton = Instance.new("TextButton")
	categoryButton.Name = name .. "Button"
	categoryButton.Size = UDim2.new(1, -10, 0, 35)
	categoryButton.Position = UDim2.new(0, 5, 0, #self.CategoryButtons * 40 + 5)
	categoryButton.BackgroundColor3 = self.Themes[self.Theme].Background
	categoryButton.Text = name
	categoryButton.TextColor3 = self.Themes[self.Theme].Text
	categoryButton.Font = Enum.Font.Gotham
	categoryButton.TextSize = 12
	categoryButton.Parent = self.CategoriesFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = categoryButton
	
	local categoryFrame = Instance.new("ScrollingFrame")
	categoryFrame.Name = name .. "Frame"
	categoryFrame.Size = UDim2.new(1, 0, 1, 0)
	categoryFrame.Position = UDim2.new(0, 0, 0, 0)
	categoryFrame.BackgroundTransparency = 1
	categoryFrame.ScrollBarThickness = 3
	categoryFrame.ScrollBarImageColor3 = self.Themes[self.Theme].Border
	categoryFrame.Visible = false
	categoryFrame.Parent = self.ContentFrame
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = categoryFrame
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 5)
	padding.Parent = categoryFrame
	
	self.Categories[name] = categoryFrame
	self.CategoryButtons[name] = categoryButton
	
	categoryButton.MouseButton1Click:Connect(function()
		self:SwitchCategory(name)
	end)
	
	if not self.CurrentCategory then
		self:SwitchCategory(name)
	end
	
	return categoryFrame
end

function ModernUILibrary:SwitchCategory(name)
	if self.CurrentCategory then
		self.Categories[self.CurrentCategory].Visible = false
		self.CategoryButtons[self.CurrentCategory].BackgroundColor3 = self.Themes[self.Theme].Background
	end
	
	self.CurrentCategory = name
	self.Categories[name].Visible = true
	self.CategoryButtons[name].BackgroundColor3 = self.Themes[self.Theme].Accent
end

-- Элементы интерфейса (остаются без изменений, как в предыдущей версии)
function ModernUILibrary:CreateLabel(parent, text, size)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = size or UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Themes[self.Theme].Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = parent
	
	return label
end

function ModernUILibrary:CreateButton(parent, text, callback, size)
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = size or UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 0, 0)
	button.BackgroundColor3 = self.Themes[self.Theme].Accent
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button
	
	button.MouseButton1Click:Connect(callback)
	
	return button
end

function ModernUILibrary:CreateCheckbox(parent, text, default, callback)
	local container = Instance.new("Frame")
	container.Name = "CheckboxContainer"
	container.Size = UDim2.new(1, -20, 0, 25)
	container.Position = UDim2.new(0, 10, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local checkbox = Instance.new("TextButton")
	checkbox.Name = "Checkbox"
	checkbox.Size = UDim2.new(0, 20, 0, 20)
	checkbox.Position = UDim2.new(0, 5, 0, 0) -- Сдвиг на 5 пикселей вправо
	checkbox.BackgroundColor3 = self.Themes[self.Theme].Secondary
	checkbox.Text = ""
	checkbox.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = checkbox
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Themes[self.Theme].Border
	stroke.Thickness = 1
	stroke.Parent = checkbox
	
	local checkmark = Instance.new("ImageLabel")
	checkmark.Name = "Checkmark"
	checkmark.Size = UDim2.new(0, 14, 0, 14)
	checkmark.Position = UDim2.new(0.5, -7, 0.5, -7)
	checkmark.BackgroundTransparency = 1
	checkmark.Image = "rbxassetid://6031068421"
	checkmark.ImageColor3 = self.Themes[self.Theme].Accent
	checkmark.Visible = default or false
	checkmark.Parent = checkbox
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 30, 0, 0) -- Сдвиг на 5 пикселей вправо
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Themes[self.Theme].Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = container
	
	local isChecked = default or false
	
	checkbox.MouseButton1Click:Connect(function()
		isChecked = not isChecked
		checkmark.Visible = isChecked
		if callback then
			callback(isChecked)
		end
	end)
	
	return {
		SetValue = function(value)
			isChecked = value
			checkmark.Visible = value
		end,
		GetValue = function()
			return isChecked
		end
	}
end

function ModernUILibrary:CreateSlider(parent, text, min, max, default, callback)
	local container = Instance.new("Frame")
	container.Name = "SliderContainer"
	container.Size = UDim2.new(1, -20, 0, 60)
	container.Position = UDim2.new(0, 10, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 5, 0, 0) -- Сдвиг на 5 пикселей вправо
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(default or min)
	label.TextColor3 = self.Themes[self.Theme].Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = container
	
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -10, 0, 6) -- Учитываем сдвиг
	track.Position = UDim2.new(0, 5, 0, 30) -- Сдвиг на 5 пикселей вправо
	track.BackgroundColor3 = self.Themes[self.Theme].Secondary
	track.Parent = container
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((default or min) / max, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = self.Themes[self.Theme].Accent
	fill.Parent = track
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	
	local thumb = Instance.new("TextButton")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.Position = UDim2.new((default or min) / max, -8, 0.5, -8)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.Text = ""
	thumb.Parent = track
	
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = thumb
	
	local dragging = false
	
	local function updateValue(value)
		local clamped = math.clamp(value, min, max)
		fill.Size = UDim2.new(clamped / max, 0, 1, 0)
		thumb.Position = UDim2.new(clamped / max, -8, 0.5, -8)
		label.Text = text .. ": " .. string.format("%.2f", clamped)
		if callback then
			callback(clamped)
		end
	end
	
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
				end
			end)
		end
	end)
	
	thumb.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging then
				local relativeX = input.Position.X - track.AbsolutePosition.X
				local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
				updateValue(percentage * max)
			end
		end
	end)
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local relativeX = input.Position.X - track.AbsolutePosition.X
			local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
			updateValue(percentage * max)
		end
	end)
	
	return {
		SetValue = updateValue,
		GetValue = function()
			return tonumber(string.match(label.Text, "([%d.]+)$")) or min
		end
	}
end

function ModernUILibrary:CreateTextField(parent, text, placeholder, callback, size)
	local container = Instance.new("Frame")
	container.Name = "TextFieldContainer"
	container.Size = size or UDim2.new(1, -20, 0, 50)
	container.Position = UDim2.new(0, 10, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 5, 0, 0) -- Сдвиг на 5 пикселей вправо
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Themes[self.Theme].Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = container
	
	local textBox = Instance.new("TextBox")
	textBox.Name = "TextBox"
	textBox.Size = UDim2.new(1, -10, 0, 30) -- Учитываем сдвиг
	textBox.Position = UDim2.new(0, 5, 0, 25) -- Сдвиг на 5 пикселей вправо
	textBox.BackgroundColor3 = self.Themes[self.Theme].Secondary
	textBox.TextColor3 = self.Themes[self.Theme].Text
	textBox.PlaceholderText = placeholder or ""
	textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 14
	textBox.Text = ""
	textBox.ClearTextOnFocus = false
	textBox.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = textBox
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Themes[self.Theme].Border
	stroke.Thickness = 1
	stroke.Parent = textBox
	
	textBox.FocusLost:Connect(function()
		if callback then
			callback(textBox.Text)
		end
	end)
	
	return {
		SetText = function(value)
			textBox.Text = value
		end,
		GetText = function()
			return textBox.Text
		end
	}
end

function ModernUILibrary:CreateDropdown(parent, text, options, default, callback)
	local container = Instance.new("Frame")
	container.Name = "DropdownContainer"
	container.Size = UDim2.new(1, -20, 0, 70)
	container.Position = UDim2.new(0, 10, 0, 0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 5, 0, 0) -- Сдвиг на 5 пикселей вправо
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Themes[self.Theme].Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = container
	
	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Name = "DropdownButton"
	dropdownButton.Size = UDim2.new(1, -10, 0, 30) -- Учитываем сдвиг
	dropdownButton.Position = UDim2.new(0, 5, 0, 25) -- Сдвиг на 5 пикселей вправо
	dropdownButton.BackgroundColor3 = self.Themes[self.Theme].Secondary
	dropdownButton.Text = options[default or 1] or "Select..."
	dropdownButton.TextColor3 = self.Themes[self.Theme].Text
	dropdownButton.Font = Enum.Font.Gotham
	dropdownButton.TextSize = 14
	dropdownButton.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = dropdownButton
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Themes[self.Theme].Border
	stroke.Thickness = 1
	stroke.Parent = dropdownButton
	
	local dropdownFrame = Instance.new("ScrollingFrame")
	dropdownFrame.Name = "DropdownFrame"
	dropdownFrame.Size = UDim2.new(1, -10, 0, 0) -- Учитываем сдвиг
	dropdownFrame.Position = UDim2.new(0, 5, 0, 55) -- Сдвиг на 5 пикселей вправо
	dropdownFrame.BackgroundColor3 = self.Themes[self.Theme].Secondary
	dropdownFrame.ScrollBarThickness = 3
	dropdownFrame.ScrollBarImageColor3 = self.Themes[self.Theme].Border
	dropdownFrame.Visible = false
	dropdownFrame.Parent = container
	
	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 4)
	dropdownCorner.Parent = dropdownFrame
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 1)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = dropdownFrame
	
	local isOpen = false
	local selectedOption = options[default or 1]
	
	local function toggleDropdown()
		isOpen = not isOpen
		if isOpen then
			dropdownFrame.Visible = true
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = game:GetService("TweenService"):Create(dropdownFrame, tweenInfo, {
				Size = UDim2.new(1, -10, 0, math.min(#options * 30, 120))
			})
			tween:Play()
		else
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = game:GetService("TweenService"):Create(dropdownFrame, tweenInfo, {
				Size = UDim2.new(1, -10, 0, 0)
			})
			tween:Play()
			tween.Completed:Connect(function()
				dropdownFrame.Visible = false
			end)
		end
	end
	
	dropdownButton.MouseButton1Click:Connect(toggleDropdown)
	
	-- Создаем кнопки для опций
	for i, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = "Option_" .. option
		optionButton.Size = UDim2.new(1, 0, 0, 30)
		optionButton.BackgroundColor3 = self.Themes[self.Theme].Background
		optionButton.Text = option
		optionButton.TextColor3 = self.Themes[self.Theme].Text
		optionButton.Font = Enum.Font.Gotham
		optionButton.TextSize = 14
		optionButton.LayoutOrder = i
		optionButton.Parent = dropdownFrame
		
		optionButton.MouseButton1Click:Connect(function()
			selectedOption = option
			dropdownButton.Text = option
			toggleDropdown()
			if callback then
				callback(option)
			end
		end)
	end
	
	return {
		SetValue = function(value)
			if table.find(options, value) then
				selectedOption = value
				dropdownButton.Text = value
			end
		end,
		GetValue = function()
			return selectedOption
		end
	}
end

return ModernUILibrary
