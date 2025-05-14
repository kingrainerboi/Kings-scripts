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
-- GUI BUTTON
local function createTeleportGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Instant Transmission"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 160, 0, 30)
	button.Position = UDim2.new(1, -170, 1, -40)
	button.AnchorPoint = Vector2.new(0, 1)
	button.Text = "Enable Transmission"
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = gui

	button.MouseButton1Click:Connect(function()
		teleportEnabled = not teleportEnabled
		if teleportEnabled then
			button.Text = "Transmission: ON"
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			button.Text = "Transmission: OFF"
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
-- TELEPORT
function teleportToTarget()
if teleportCooldown or not teleportEnabled or not currentTarget then return end
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
-- STARTUP
createCrosshair()
createTeleportGui()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
-- Make GUI persist across deaths
player.CharacterAdded:Connect(function()
createCrosshair()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
end)
