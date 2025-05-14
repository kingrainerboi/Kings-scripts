-- tp script


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
-- SETTINGS
local MAX_DASH_SPEED = 150
local RAY_DISTANCE = 1000
local COOLDOWN = 1.8
local RAY_ANGLE_OFFSET = 5 -- degrees
local STOP_DISTANCE = 3
local TELEPORT_DISTANCE = 1
-- VARIABLES
local currentTarget = nil
local highlight = nil
local teleportCooldown = false
local crosshair = nil
local waypoint = nil
local teleportEnabled = false
local teleportEnabled_2 = false
-- GUI BUTTO
local function createTeleportGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "tp"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 160, 0, 30)
	button.Position = UDim2.new(1, -170, 1, 50)
	button.AnchorPoint = Vector2.new(0, 1)
	button.Text = "etp"
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = gui

	button.MouseButton1Click:Connect(function()
		teleportEnabled = not teleportEnabled
		if teleportEnabled then
			button.Text = "Tp: ON"
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			button.Text = "Tp: OFF"
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end
	end)
end

local function createFlightGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "tp"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 160, 0, 30)
	button.Position = UDim2.new(1, -170, 1, 50)
	button.AnchorPoint = Vector2.new(0, 1)
	button.Text = "efly"
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = gui

	button.MouseButton1Click:Connect(function()
		teleportEnabled_2 = not teleportEnabled_2
		if teleportEnabled then
			button.Text = "fly: ON"
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			button.Text = "fly: OFF"
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end
	end)
end

-- CROSSHAIR
local function createCrosshair()
local gui = Instance.new("ScreenGui")
gui.Name = "DashCrosshair"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.Size = UDim2.new(0, 8, 0, 8)
cross.Position = UDim2.new(0.5, 0, 0.5, 0)
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.BackgroundColor3 = Color3.new(1, 1, 1)
cross.BackgroundTransparency = 0.6
cross.BorderSizePixel = 0
cross.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = cross
crosshair = gui
end
local function removeCrosshair()
if crosshair then
crosshair:Destroy()
crosshair = nil
end
end
-- OUTLINE
local function createOutline(targetChar)
if not targetChar then return end
if highlight then highlight:Destroy() end
highlight = Instance.new("Highlight")
highlight.Adornee = targetChar
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
highlight.OutlineTransparency = 0
highlight.Parent = targetChar
end
local function removeOutline()
if highlight then
highlight:Destroy()
highlight = nil
end
end
-- DEGREE TO RADIAN
local function degToRad(deg)
return deg * math.pi / 180
end
local function getRayDirections()
local baseDir = Camera.CFrame.LookVector
local rightVec = Camera.CFrame.RightVector
local upVec = Camera.CFrame.UpVector
return {
baseDir,
(baseDir + (rightVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,
(baseDir - (rightVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,
(baseDir + (upVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,
(baseDir - (upVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,
}
end
-- RAYCAST
local function updateRaycast()
if teleportEnabled then 
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local origin = Camera.CFrame.Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character}
	rayParams.IgnoreWater = true
	for _, direction in ipairs(getRayDirections()) do
	local result = workspace:Raycast(origin, direction * RAY_DISTANCE, rayParams)
	if result and result.Instance then
	local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
	local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
	if hitPlayer and hitPlayer ~= player then if currentTarget ~= hitCharacter then currentTarget = hitCharacter createOutline(currentTarget) end return end 
	end
	end
	currentTarget = nil
	removeOutline()
	end
end
-- TELEPORT
function teleportToTarget()
if teleportEnabled then 
	teleportCooldown = true
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end
	local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local targetLookVector = targetHRP.CFrame.LookVector
	local targetPositionBehind = targetHRP.Position - targetLookVector * TELEPORT_DISTANCE
	if waypoint then
	waypoint:Destroy()
	end
	waypoint = Instance.new("Part")
	waypoint.Size = Vector3.new(1, 1, 1)
	waypoint.Position = targetPositionBehind
	waypoint.Anchored = true
	waypoint.CanCollide = false
	waypoint.Material = Enum.Material.Neon
	waypoint.Color = Color3.fromRGB(255, 0, 0)
	waypoint.Parent = workspace
	hrp.CFrame = CFrame.new(targetPositionBehind, targetHRP.Position)
	humanoid.AutoRotate = false
	task.wait(COOLDOWN)
	teleportCooldown = false
	humanoid.AutoRotate = true
	end
end

-- DASH TO TARGET
local function dashToTarget()
	if teleportEnabled_2 and dashCooldown or not currentTarget then return end
	dashCooldown = true
	
	local character = player.Character  
	if not character then return end  
	local hrp = character:FindFirstChild("HumanoidRootPart")  
	local humanoid = character:FindFirstChildOfClass("Humanoid")  
	if not hrp or not humanoid then return end  
	
	local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")  
	if not targetHRP then return end  
	
	humanoid.AutoRotate = false  
	hrp.CFrame = CFrame.new(hrp.Position, targetHRP.Position)  
	
	local direction = (targetHRP.Position - hrp.Position)  
	local distance = direction.Magnitude  
	local normalizedDir = direction.Unit  
	
	local bv = Instance.new("BodyVelocity")  
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e5  
	bv.Velocity = normalizedDir * MAX_DASH_SPEED  
	bv.Parent = hrp  
	
	local startTime = tick()  
	local timeout = distance / MAX_DASH_SPEED + 0.1  
	
	while tick() - startTime < timeout do  
		if not currentTarget or not targetHRP or not character or not hrp then break end  
		local dist = (targetHRP.Position - hrp.Position).Magnitude  
		if dist <= STOP_DISTANCE then break end  
		RunService.Heartbeat:Wait()  
	end  
	
	bv:Destroy()  
	humanoid.AutoRotate = true  
	
	task.wait(COOLDOWN)  
	dashCooldown = false
	
	end

-- STARTUP
createCrosshair()
createTeleportGui()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
-- Make GUI persist across deaths
player.CharacterAdded:Connect(function()
createCrosshair()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
end)


-- Touch input for mobile
UIS.TouchTap:Connect
(
	function(touchPositions, processed)
		if processed then
			if teleportEnabled then
				teleportToTarget()
			end
			if teleportEnabled_2 then
				dashToTarget()
			end
		end
	end
)