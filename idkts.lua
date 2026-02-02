--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// Shared variables used by your main aimbot script
bodyAimbotEnabled = false
velocityAimbotEnabled = false
VELOCITY_AIMBOT_RANGE = 30

--// ===== RANGE CIRCLE =====

local singleRangeDisc
local singleRangeConn

local function neonCompensatedBlue()
	local factor = 0.55
	return Color3.new(0/255 * factor, 150/255 * factor, 255/255 * factor)
end

local function createSingleRangeDisc()
	if singleRangeDisc then return end

	singleRangeDisc = Instance.new("Part")
	singleRangeDisc.Name = "SharedAimbotRange"
	singleRangeDisc.Anchored = true
	singleRangeDisc.CanCollide = false
	singleRangeDisc.CanTouch = false
	singleRangeDisc.CanQuery = false
	singleRangeDisc.Transparency = 0.6
	singleRangeDisc.Material = Enum.Material.Neon
	singleRangeDisc.Color = neonCompensatedBlue()
	singleRangeDisc.Size = Vector3.new(1, 1, 1)

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = Vector3.new(VELOCITY_AIMBOT_RANGE * 2, 0.15, VELOCITY_AIMBOT_RANGE * 2)
	mesh.Parent = singleRangeDisc

	singleRangeDisc.Parent = workspace.CurrentCamera
end

local function updateSingleRangeDisc()
	if singleRangeDisc then
		local mesh = singleRangeDisc:FindFirstChildOfClass("SpecialMesh")
		if mesh then
			mesh.Scale = Vector3.new(VELOCITY_AIMBOT_RANGE * 2, 0.15, VELOCITY_AIMBOT_RANGE * 2)
		end
	end
end

local function startSingleRangeDisc()
	createSingleRangeDisc()

	if singleRangeConn then singleRangeConn:Disconnect() end
	singleRangeConn = RunService.RenderStepped:Connect(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and singleRangeDisc then
			singleRangeDisc.Position = hrp.Position - Vector3.new(0, 2.8, 0)
		end
	end)
end

local function stopSingleRangeDisc()
	if singleRangeConn then
		singleRangeConn:Disconnect()
		singleRangeConn = nil
	end
	if singleRangeDisc then
		singleRangeDisc:Destroy()
		singleRangeDisc = nil
	end
end

--// ===== UI =====

local gui = Instance.new("ScreenGui")
gui.Name = "BatAimbotUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.4, 0.28)
main.Position = UDim2.fromScale(0.05, 0.6)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 14)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Center
layout.VerticalAlignment = Top
layout.Parent = main

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = main

--// Toggle creator
local function createToggle(text, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 40)
	holder.BackgroundTransparency = 1
	holder.Parent = main

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Left
	label.Parent = holder

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.22, 0, 0.7, 0)
	button.Position = UDim2.new(0.75, 0, 0.15, 0)
	button.Text = ""
	button.BackgroundColor3 = Color3.fromRGB(60,60,60)
	button.AutoButtonColor = false
	button.Parent = holder

	local bc = Instance.new("UICorner", button)
	bc.CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0.45, 0, 0.8, 0)
	knob.Position = UDim2.new(0.05, 0, 0.1, 0)
	knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
	knob.Parent = button

	local kc = Instance.new("UICorner", knob)
	kc.CornerRadius = UDim.new(1,0)

	local state = false

	local function refresh()
		if state then
			button.BackgroundColor3 = Color3.fromRGB(0,170,255)
			knob.Position = UDim2.new(0.5, 0, 0.1, 0)
		else
			button.BackgroundColor3 = Color3.fromRGB(60,60,60)
			knob.Position = UDim2.new(0.05, 0, 0.1, 0)
		end
	end

	button.MouseButton1Click:Connect(function()
		state = not state
		refresh()
		callback(state)
	end)

	refresh()
end

--// Toggles
createToggle("Bat Aimbot/AI", function(on)
	bodyAimbotEnabled = on
end)

createToggle("Bat Aimbot & Autolock", function(on)
	velocityAimbotEnabled = on
	if on then
		startSingleRangeDisc()
	else
		stopSingleRangeDisc()
	end
end)

--// ===== SLIDER =====

local sliderHolder = Instance.new("Frame")
sliderHolder.Size = UDim2.new(1, 0, 0, 50)
sliderHolder.BackgroundTransparency = 1
sliderHolder.Parent = main

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0.4, 0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Range: 30"
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.TextScaled = true
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextXAlignment = Left
sliderLabel.Parent = sliderHolder

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0.25, 0)
bar.Position = UDim2.new(0, 0, 0.6, 0)
bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
bar.BorderSizePixel = 0
bar.Parent = sliderHolder

local bc2 = Instance.new("UICorner", bar)
bc2.CornerRadius = UDim.new(1,0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
fill.BorderSizePixel = 0
fill.Parent = bar

local fc = Instance.new("UICorner", fill)
fc.CornerRadius = UDim.new(1,0)

local dragging = false
local MIN_RANGE = 5
local MAX_RANGE = 100

local function setFromX(x)
	local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
	fill.Size = UDim2.new(rel, 0, 1, 0)

	local value = math.floor(MIN_RANGE + (MAX_RANGE - MIN_RANGE) * rel)
	VELOCITY_AIMBOT_RANGE = value
	sliderLabel.Text = "Range: " .. tostring(value)

	updateSingleRangeDisc()
end

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		setFromX(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		setFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Init
updateSingleRangeDisc()
