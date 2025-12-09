-- DoomSense UI Library
-- Version: 1.0.1

local DoomSense = {}
DoomSense.__index = DoomSense

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local DEFAULT_SETTINGS = {
	Theme = "Dark",
	AccentColor = Color3.fromRGB(255, 65, 65),
	BackgroundColor = Color3.fromRGB(25, 25, 25),
	TextColor = Color3.fromRGB(240, 240, 240),
	SecondaryColor = Color3.fromRGB(45, 45, 45),
	BorderColor = Color3.fromRGB(60, 60, 60)
}

local LIGHT_THEME = {
	BackgroundColor = Color3.fromRGB(245, 245, 245),
	TextColor = Color3.fromRGB(25, 25, 25),
	SecondaryColor = Color3.fromRGB(225, 225, 225),
	BorderColor = Color3.fromRGB(200, 200, 200)
}

-- Utility functions
local function Create(class, props)
	local obj = Instance.new(class)
	for prop, value in pairs(props) do
		if prop == "Parent" then
			obj.Parent = value
		else
			obj[prop] = value
		end
	end
	return obj
end

local function Tween(obj, props, duration, style)
	local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

-- Main UI Class
function DoomSense.new(config)
	config = config or {}
	
	local self = setmetatable({}, DoomSense)
	
	-- Configuration
	self.Config = {
		Name = config.Name or "DOOMSENSE",
		AccentColor = config.AccentColor or DEFAULT_SETTINGS.AccentColor,
		DefaultTheme = config.DefaultTheme or "Dark",
		Size = config.Size or UDim2.new(0, 500, 0, 400),
		Position = config.Position or UDim2.new(0.5, -250, 0.5, -200),
		ShowSearch = config.ShowSearch ~= false,
		Draggable = config.Draggable ~= false,
		MinimalMode = config.MinimalMode or false
	}
	
	-- State
	self.Theme = self.Config.DefaultTheme
	self.CurrentTab = nil
	self.Elements = {}
	self.Tabs = {}
	self.Categories = {}
	self.Binds = {}
	
	-- UI References
	self.ScreenGui = nil
	self.MainFrame = nil
	self.DragFrame = nil
	self.SearchBox = nil
	
	-- Colors
	self.Colors = DEFAULT_SETTINGS
	
	-- Initialize
	self:_CreateUI()
	self:_ApplyTheme()
	
	return self
end

-- UI Creation Methods
function DoomSense:_CreateUI()
	-- ScreenGui
	self.ScreenGui = Create("ScreenGui", {
		Name = "DoomSenseUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global
	})
	
	if gethui then
		self.ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(self.ScreenGui)
		self.ScreenGui.Parent = game.CoreGui
	elseif get_hidden_ui then
		self.ScreenGui.Parent = get_hidden_ui()
	else
		self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	-- Main Container
	self.MainFrame = Create("Frame", {
		Parent = self.ScreenGui,
		Name = "MainFrame",
		Size = self.Config.Size,
		Position = self.Config.Position,
		BackgroundColor3 = self.Colors.BackgroundColor,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	
	-- Drop Shadow
	local shadow = Create("ImageLabel", {
		Parent = self.MainFrame,
		Name = "Shadow",
		Size = UDim2.new(1, 10, 1, 10),
		Position = UDim2.new(0, -5, 0, -5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5554236805",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(23, 23, 277, 277),
		ZIndex = 0
	})
	
	-- Title Bar
	local titleBar = Create("Frame", {
		Parent = self.MainFrame,
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderSizePixel = 0
	})
	
	-- Drag Frame (if draggable)
	if self.Config.Draggable then
		self.DragFrame = Create("TextButton", {
			Parent = titleBar,
			Name = "DragFrame",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false
		})
		
		self:_MakeDraggable(self.DragFrame, self.MainFrame)
	end
	
	-- Title Text
	local titleText = Create("TextLabel", {
		Parent = titleBar,
		Name = "Title",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Config.Name,
		TextColor3 = self.Config.AccentColor,
		TextSize = 18,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Close Button
	local closeButton = Create("TextButton", {
		Parent = titleBar,
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0.5, -15),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = self.Colors.BorderColor,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = self.Colors.TextColor,
		TextSize = 24,
		Font = Enum.Font.GothamBold
	})
	
	closeButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	-- Main Content Area
	local contentArea = Create("Frame", {
		Parent = self.MainFrame,
		Name = "ContentArea",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundTransparency = 1
	})
	
	-- Left Panel (Categories)
	self.LeftPanel = Create("Frame", {
		Parent = contentArea,
		Name = "LeftPanel",
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderSizePixel = 0
	})
	
	-- Right Panel (Content)
	self.RightPanel = Create("Frame", {
		Parent = contentArea,
		Name = "RightPanel",
		Size = UDim2.new(1, -150, 1, 0),
		Position = UDim2.new(0, 150, 0, 0),
		BackgroundTransparency = 1
	})
	
	-- Search Box
	if self.Config.ShowSearch then
		self.SearchBox = Create("TextBox", {
			Parent = self.RightPanel,
			Name = "SearchBox",
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = self.Colors.SecondaryColor,
			BorderColor3 = self.Colors.BorderColor,
			BorderSizePixel = 1,
			PlaceholderText = "Search...",
			PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
			TextColor3 = self.Colors.TextColor,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false
		})
		
		local searchPadding = Create("UIPadding", {
			Parent = self.SearchBox,
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		})
		
		self.SearchBox.Changed:Connect(function(property)
			if property == "Text" then
				self:_UpdateSearch()
			end
		end)
	end
	
	-- Content Scrolling Frame
	self.ContentFrame = Create("ScrollingFrame", {
		Parent = self.RightPanel,
		Name = "ContentFrame",
		Size = UDim2.new(1, 0, 1, self.Config.ShowSearch and -50 or -10),
		Position = UDim2.new(0, 0, 0, self.Config.ShowSearch and 50 or 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self.Colors.BorderColor,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	local contentPadding = Create("UIPadding", {
		Parent = self.ContentFrame,
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10)
	})
	
	local contentLayout = Create("UIListLayout", {
		Parent = self.ContentFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	})
	
	-- Categories Scrolling Frame
	self.CategoriesFrame = Create("ScrollingFrame", {
		Parent = self.LeftPanel,
		Name = "CategoriesFrame",
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.new(0, 0, 0, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	local categoriesPadding = Create("UIPadding", {
		Parent = self.CategoriesFrame,
		PaddingTop = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5)
	})
	
	local categoriesLayout = Create("UIListLayout", {
		Parent = self.CategoriesFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
end

function DoomSense:_MakeDraggable(dragFrame, mainFrame)
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	
	dragFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
end

function DoomSense:_ApplyTheme()
	if self.Theme == "Light" then
		for key, value in pairs(LIGHT_THEME) do
			self.Colors[key] = value
		end
	else
		for key, value in pairs(DEFAULT_SETTINGS) do
			self.Colors[key] = value
		end
	end
	
	-- Update all UI elements
	if self.MainFrame then
		self.MainFrame.BackgroundColor3 = self.Colors.BackgroundColor
		
		-- Update title bar
		local titleBar = self.MainFrame:FindFirstChild("TitleBar")
		if titleBar then
			titleBar.BackgroundColor3 = self.Colors.SecondaryColor
		end
		
		-- Update left panel
		if self.LeftPanel then
			self.LeftPanel.BackgroundColor3 = self.Colors.SecondaryColor
		end
		
		-- Update text colors
		local function updateTextColors(obj)
			if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
				if obj.Name ~= "Title" then -- Don't change title color
					obj.TextColor3 = self.Colors.TextColor
				end
				if obj:IsA("TextBox") then
					obj.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
				end
			end
			
			for _, child in pairs(obj:GetChildren()) do
				updateTextColors(child)
			end
		end
		
		updateTextColors(self.MainFrame)
	end
end

-- Public Methods
function DoomSense:Toggle()
	if self.MainFrame then
		self.MainFrame.Visible = not self.MainFrame.Visible
	end
end

function DoomSense:Show()
	if self.MainFrame then
		self.MainFrame.Visible = true
	end
end

function DoomSense:Hide()
	if self.MainFrame then
		self.MainFrame.Visible = false
	end
end

function DoomSense:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

function DoomSense:SetTheme(theme)
	if theme == "Dark" or theme == "Light" then
		self.Theme = theme
		self:_ApplyTheme()
	end
end

function DoomSense:AddTab(name, icon)
	local tabId = #self.Tabs + 1
	
	local tabButton = Create("TextButton", {
		Parent = self.CategoriesFrame,
		Name = name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderColor3 = self.Colors.BorderColor,
		BorderSizePixel = 1,
		Text = name,
		TextColor3 = self.Colors.TextColor,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		AutoButtonColor = false
	})
	
	local tab = {
		Id = tabId,
		Name = name,
		Icon = icon,
		Button = tabButton,
		Elements = {},
		Visible = false
	}
	
	table.insert(self.Tabs, tab)
	
	if #self.Tabs == 1 then
		self:SwitchTab(tabId)
	end
	
	tabButton.MouseButton1Click:Connect(function()
		self:SwitchTab(tabId)
	end)
	
	return tabId
end

function DoomSense:SwitchTab(tabId)
	if tabId < 1 or tabId > #self.Tabs then return end
	
	-- Hide current tab
	if self.CurrentTab then
		for _, element in pairs(self.Tabs[self.CurrentTab].Elements) do
			if element.Instance then
				element.Instance.Visible = false
			end
		end
		
		if self.Tabs[self.CurrentTab].Button then
			self.Tabs[self.CurrentTab].Button.BackgroundColor3 = self.Colors.SecondaryColor
		end
	end
	
	-- Show new tab
	self.CurrentTab = tabId
	
	for _, element in pairs(self.Tabs[tabId].Elements) do
		if element.Instance then
			element.Instance.Visible = true
		end
	end
	
	if self.Tabs[tabId].Button then
		self.Tabs[tabId].Button.BackgroundColor3 = self.Config.AccentColor
	end
end

function DoomSense:AddLabel(text, tabId)
	if not self.CurrentTab and tabId then
		self:SwitchTab(tabId)
	elseif not tabId then
		tabId = self.CurrentTab
	end
	
	if not tabId then return end
	
	local label = Create("TextLabel", {
		Parent = self.ContentFrame,
		Name = "Label_" .. text,
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = self.Colors.TextColor,
		TextSize = 16,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = tabId == self.CurrentTab
	})
	
	table.insert(self.Tabs[tabId].Elements, {
		Type = "Label",
		Text = text,
		Instance = label
	})
	
	return label
end

function DoomSense:AddButton(text, callback, tabId)
	if not self.CurrentTab and tabId then
		self:SwitchTab(tabId)
	elseif not tabId then
		tabId = self.CurrentTab
	end
	
	if not tabId then return end
	
	local button = Create("TextButton", {
		Parent = self.ContentFrame,
		Name = "Button_" .. text,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderColor3 = self.Colors.BorderColor,
		BorderSizePixel = 1,
		Text = text,
		TextColor3 = self.Colors.TextColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		Visible = tabId == self.CurrentTab
	})
	
	button.MouseEnter:Connect(function()
		Tween(button, {BackgroundColor3 = self.Colors.BorderColor}, 0.1)
	end)
	
	button.MouseLeave:Connect(function()
		Tween(button, {BackgroundColor3 = self.Colors.SecondaryColor}, 0.1)
	end)
	
	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
	
	table.insert(self.Tabs[tabId].Elements, {
		Type = "Button",
		Text = text,
		Callback = callback,
		Instance = button
	})
	
	return button
end

function DoomSense:AddCheckbox(text, bind, bindType, default, callback, tabId)
	if not self.CurrentTab and tabId then
		self:SwitchTab(tabId)
	elseif not tabId then
		tabId = self.CurrentTab
	end
	
	if not tabId then return end
	
	local state = default or false
	bindType = bindType or "toggle"
	
	local checkboxFrame = Create("Frame", {
		Parent = self.ContentFrame,
		Name = "Checkbox_" .. text,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Visible = tabId == self.CurrentTab
	})
	
	local checkboxButton = Create("TextButton", {
		Parent = checkboxFrame,
		Name = "CheckboxButton",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 0, 0.5, -10),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderColor3 = self.Colors.BorderColor,
		BorderSizePixel = 1,
		Text = "",
		AutoButtonColor = false
	})
	
	local checkmark = Create("Frame", {
		Parent = checkboxButton,
		Name = "Checkmark",
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.new(0, 2, 0, 2),
		BackgroundColor3 = self.Config.AccentColor,
		BorderSizePixel = 0,
		Visible = state
	})
	
	local label = Create("TextLabel", {
		Parent = checkboxFrame,
		Name = "Label",
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 25, 0, 0),
		BackgroundTransparency = 1,
		Text = text .. (bind and (" [" .. tostring(bind):upper() .. "]") or ""),
		TextColor3 = self.Colors.TextColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local function setState(newState)
		state = newState
		checkmark.Visible = state
		
		if callback then
			callback(state)
		end
	end
	
	checkboxButton.MouseButton1Click:Connect(function()
		setState(not state)
	end)
	
	-- Bind handling
	if bind then
		self.Binds[tostring(bind)] = {
			Type = "Checkbox",
			Element = checkboxFrame,
			BindType = bindType,
			State = state,
			SetState = setState,
			Callback = callback
		}
		
		if bindType == "press" then
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and input.KeyCode == bind then
					setState(true)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if not gameProcessed and input.KeyCode == bind then
					setState(false)
				end
			end)
		elseif bindType == "toggle" then
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and input.KeyCode == bind then
					setState(not state)
				end
			end)
		end
	end
	
	table.insert(self.Tabs[tabId].Elements, {
		Type = "Checkbox",
		Text = text,
		Bind = bind,
		State = state,
		Instance = checkboxFrame
	})
	
	return {
		SetState = setState,
		GetState = function() return state end,
		Toggle = function() setState(not state) end
	}
end

function DoomSense:AddSlider(text, min, max, default, callback, decimal, tabId)
	if not self.CurrentTab and tabId then
		self:SwitchTab(tabId)
	elseif not tabId then
		tabId = self.CurrentTab
	end
	
	if not tabId then return end
	
	local value = default or min
	decimal = decimal or 0
	
	local sliderFrame = Create("Frame", {
		Parent = self.ContentFrame,
		Name = "Slider_" .. text,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Visible = tabId == self.CurrentTab
	})
	
	local label = Create("TextLabel", {
		Parent = sliderFrame,
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text .. ": " .. string.format(decimal == 0 and "%d" or "%.1f", value),
		TextColor3 = self.Colors.TextColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local track = Create("Frame", {
		Parent = sliderFrame,
		Name = "Track",
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = self.Colors.SecondaryColor,
		BorderSizePixel = 0
	})
	
	local fill = Create("Frame", {
		Parent = track,
		Name = "Fill",
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = self.Config.AccentColor,
		BorderSizePixel = 0
	})
	
	local thumb = Create("Frame", {
		Parent = track,
		Name = "Thumb",
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	
	local dragging = false
	
	local function setValue(newValue)
		newValue = math.clamp(newValue, min, max)
		if decimal == 0 then
			newValue = math.floor(newValue)
		else
			newValue = math.floor(newValue * (10 ^ decimal)) / (10 ^ decimal)
		end
		
		if value ~= newValue then
			value = newValue
			
			local percent = (value - min) / (max - min)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			thumb.Position = UDim2.new(percent, -6, 0.5, -6)
			
			label.Text = text .. ": " .. string.format(decimal == 0 and "%d" or "%." .. decimal .. "f", value)
			
			if callback then
				callback(value)
			end
		end
	end
	
	local function updateFromMouse()
		if not dragging then return end
		
		local mouse = game:GetService("Players").LocalPlayer:GetMouse()
		local trackAbsPos = track.AbsolutePosition
		local trackAbsSize = track.AbsoluteSize
		
		local relativeX = (mouse.X - trackAbsPos.X) / trackAbsSize.X
		relativeX = math.clamp(relativeX, 0, 1)
		
		local newValue = min + (relativeX * (max - min))
		setValue(newValue)
	end
	
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromMouse()
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromMouse()
		end
	end)
	
	setValue(value)
	
	table.insert(self.Tabs[tabId].Elements, {
		Type = "Slider",
		Text = text,
		Value = value,
		Min = min,
		Max = max,
		Instance = sliderFrame
	})
	
	return {
		SetValue = setValue,
		GetValue = function() return value end
	}
end

function DoomSense:AddColorPicker(text, defaultColor, callback, tabId)
	if not self.CurrentTab and tabId then
		self:SwitchTab(tabId)
	elseif not tabId then
		tabId = self.CurrentTab
	end
	
	if not tabId then return end
	
	local color = defaultColor or Color3.fromRGB(255, 255, 255)
	
	local colorFrame = Create("Frame", {
		Parent = self.ContentFrame,
		Name = "ColorPicker_" .. text,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Visible = tabId == self.CurrentTab
	})
	
	local label = Create("TextLabel", {
		Parent = colorFrame,
		Name = "Label",
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = self.Colors.TextColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local colorButton = Create("TextButton", {
		Parent = colorFrame,
		Name = "ColorButton",
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		BackgroundColor3 = color,
		BorderColor3 = self.Colors.BorderColor,
		BorderSizePixel = 1,
		Text = "",
		AutoButtonColor = false
	})
	
	colorButton.MouseButton1Click:Connect(function()
		-- Здесь можно добавить полноценный пикер цвета
		-- Для простоты используем случайный цвет
		local newColor = Color3.fromHSV(math.random(), 1, 1)
		colorButton.BackgroundColor3 = newColor
		color = newColor
		
		if callback then
			callback(newColor)
		end
	end)
	
	table.insert(self.Tabs[tabId].Elements, {
		Type = "ColorPicker",
		Text = text,
		Color = color,
		Instance = colorFrame
	})
	
	return {
		SetColor = function(newColor)
			colorButton.BackgroundColor3 = newColor
			color = newColor
			if callback then
				callback(newColor)
			end
		end,
		GetColor = function() return color end
	}
end

function DoomSense:_UpdateSearch()
	if not self.SearchBox or not self.CurrentTab then return end
	
	local searchText = string.lower(self.SearchBox.Text)
	
	for _, element in pairs(self.Tabs[self.CurrentTab].Elements) do
		if element.Instance then
			if searchText == "" or string.find(string.lower(element.Text or ""), searchText, 1, true) then
				element.Instance.Visible = true
			else
				element.Instance.Visible = false
			end
		end
	end
end

-- Export
return DoomSense
