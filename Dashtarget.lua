
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- SETTINGS
local MAX_DASH_SPEED = 150
local RAY_DISTANCE = 1000
local COOLDOWN = 1
local RAY_ANGLE_OFFSET = 5 -- degrees
local STOP_DISTANCE = 3

-- TOOL CREATION
local dashTool = Instance.new("Tool")
dashTool.Name = "TargetDash"
dashTool.RequiresHandle = false
dashTool.CanBeDropped = false
dashTool.Parent = backpack

-- VARIABLES
local currentTarget = nil
local highlight = nil
local dashCooldown = false
local crosshair = nil

-- CREATE CROSSHAIR WITHOUT IMAGE ASSET
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

-- OUTLINE LOGIC
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

-- GET RAY DIRECTIONS IN A CONE
local function getRayDirections()
local baseDir = Camera.CFrame.LookVector
local rightVec = Camera.CFrame.RightVector
local upVec = Camera.CFrame.UpVector

local directions = {  
	baseDir,  
	(baseDir + (rightVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,  
	(baseDir - (rightVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,  
	(baseDir + (upVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,  
	(baseDir - (upVec * math.tan(degToRad(RAY_ANGLE_OFFSET)))).Unit,  
}  

return directions

end

-- RAYCAST DETECTION
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

		if hitPlayer and hitPlayer ~= player then  
			if currentTarget ~= hitCharacter then  
				currentTarget = hitCharacter  
				createOutline(currentTarget)  
			end  
			return  
		end  
	end  
end  

currentTarget = nil  
removeOutline()

end

-- DASH TO TARGET
local function dashToTarget()
if dashCooldown or not currentTarget then return end
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

-- HANDLE INPUT
local function bindInput()
UIS.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dashToTarget()
end
end)
end

-- TOOL EVENTS
dashTool.Equipped:Connect(function()
bindInput()
createCrosshair()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
end)

dashTool.Unequipped:Connect(function()
RunService:UnbindFromRenderStep("TargetRaycast")
removeOutline()
removeCrosshair()
currentTarget = nil
end)

