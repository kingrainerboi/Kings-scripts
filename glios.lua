-- [Services]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local flightEnabled = false
local PlayerC = game.Players.LocalPlayer
local character = PlayerC.Character or PlayerC.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")


local player = game.Players.LocalPlayer

local cameraLockEnabled = false
local CAMERA_LOCK_NAME = "SoftCameraLock"

local ASSIST_STRENGTH = 0.35 -- 0.05 is soft, 1 is instant snap

-- [Player & Settings]
local player = Players.LocalPlayer
local MAX_DASH_SPEED = 180
local RAY_DISTANCE = 1000
local COOLDOWN = 0.6
local RAY_ANGLE_OFFSET = 5
local STOP_DISTANCE = 5
local TELEPORT_DISTANCE = 1


-- [State]
local currentTarget = nil
local highlight = nil
local crosshair = nil
local waypoint = nil
local teleportCooldown = false
local dashCooldown = false
local teleportEnabled = false
local dashEnabled_2 = false
local flightEnabled_3 = false
local flightdash = false
local returnReached = false
local ult = false
local lockOnTarget = nil  
local lastTouchPosition = nil  
local kelerEnabled = false

-- [Flight Variables]
local speed = 60
local bodyGyro, bodyVelocity

-- LocalScript in StarterPlayerScripts

local TextChatService = game:GetService("TextChatService")
local generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")





-- Modular sound play function
local function playSFX(id, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(id)
	sound.Volume = volume or 1
	sound.Parent = game:GetService("SoundService")
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end
	
	



-- [GUI Creation]
local function createTeleportGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TeleportGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")  
	button.Size = UDim2.new(0, 160, 0, 30)  
	button.Position = UDim2.new(1, -170, 1, -110)  
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
	gui.Name = "FlightGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")  
	button.Size = UDim2.new(0, 160, 0, 30)  
	button.Position = UDim2.new(1, -170, 1, -160)  
	button.AnchorPoint = Vector2.new(0, 1)  
	button.Text = "efly"  
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
	button.TextColor3 = Color3.new(1, 1, 1)  
	button.TextScaled = true  
	button.Parent = gui  

	button.MouseButton1Click:Connect(function()  
		if not ult then
			if not flightdash  then
				flightEnabled_3 = not flightEnabled_3  
				if flightEnabled_3 then  
					button.Text = "Fly: ON"  
					button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  
					startFlight()
				else  
					button.Text = "Fly: OFF"  
					button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
					stopFlight()
				end  
			end
		end
	end)
end

local function createDashGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "dashGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")  
	button.Size = UDim2.new(0, 160, 0, 30)  
	button.Position = UDim2.new(1, -170, 1, -210)  
	button.AnchorPoint = Vector2.new(0, 1)  
	button.Text = "edash"  
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
	button.TextColor3 = Color3.new(1, 1, 1)  
	button.TextScaled = true  
	button.Parent = gui  

	button.MouseButton1Click:Connect(function()  
		dashEnabled_2 = not dashEnabled_2  
		if dashEnabled_2 then  
			button.Text = "Dash: ON"  
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  
		else  
			button.Text = "Dash: OFF"  
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
		end  
	end)
end

local function keler()
	local gui = Instance.new("ScreenGui")
	gui.Name = "kelerGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")  
	button.Name = "keler"
	button.Size = UDim2.new(0, 140, 0, 25)  -- slightly smaller
	button.Position = UDim2.new(1, -150, 1, -250)  
	button.AnchorPoint = Vector2.new(0, 1)  
	button.Text = "keler"  
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
	button.TextColor3 = Color3.new(1, 1, 1)  
	button.TextScaled = true  
	button.Parent = gui  

	button.MouseButton1Click:Connect(function()  
		kelerEnabled = not kelerEnabled  
		if kelerEnabled then  
			button.Text = "Keler: ON"  
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  
			
		else  
			button.Text = "Keler: OFF"  
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
			
		end  
	end)
end

-- [Crosshair]
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
	


		





	local function sendChatMessage(message)
		if typeof(message) == "string" and message ~= "" and currentTarget then
			generalChannel:SendAsync(message)
			wait(0.2)

			local targetPlayer = Players:GetPlayerFromCharacter(currentTarget)
			if targetPlayer then
				generalChannel:SendAsync("Target name: " .. targetPlayer.Name)
			else
				generalChannel:SendAsync("Target player not found.")
			end
		end
	end


	local function softLockCamera()
		if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then
			RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME)
			cameraLockEnabled = false
			return
		end
	
		local camCF = Camera.CFrame
		local camPos = camCF.Position
		local targetPos = currentTarget.HumanoidRootPart.Position
	
		local desiredLook = (targetPos - camPos).Unit
		local smoothedLook = camCF.LookVector:Lerp(desiredLook, ASSIST_STRENGTH)
	
		-- Only adjust the camera rotation (not position)
		Camera.CFrame = CFrame.new(camPos, camPos + smoothedLook)
	end

	local function enableCameraLock()
		if not cameraLockEnabled then
			RunService:BindToRenderStep(CAMERA_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, softLockCamera)
			cameraLockEnabled = true
		end
	end
	
	local function disableCameraLock()
		RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME)
		cameraLockEnabled = false
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
					enableCameraLock()
				end  
				return  
			end  
		end  
	end  
	
	currentTarget = nil  
	removeOutline()
	disableCameraLock()
	
	end
	
	local Players = game:GetService("Players")

	local function playRandomSFX(...)
		local soundData = {...}
		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart")
	
		if #soundData > 0 then
			local randomEntry = soundData[math.random(1, #soundData)]
			
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. tostring(randomEntry.SoundId)
			sound.Parent = hrp
			sound.Volume = 3
			sound:Play()
	
			-- If there is an action, run it now (or you can run it at sound end)
			if randomEntry.Action and typeof(randomEntry.Action) == "function" then
				randomEntry.Action()
			end
	
			sound.Ended:Connect(function()
				sound:Destroy()
			end)
		end
	end
	
	-- Example usage:
	
	

	
	
-- [Teleport Function]
function teleportToTarget()
	if teleportCooldown or not teleportEnabled or not currentTarget then return end
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	local targetLookVector = targetHRP.CFrame.LookVector
	local targetPos = targetHRP.Position - targetLookVector * TELEPORT_DISTANCE

	if waypoint then waypoint:Destroy() end
	waypoint = Instance.new("Part")
	waypoint.Size = Vector3.new(1, 1, 1)
	waypoint.Position = targetPos
	waypoint.Anchored = true
	waypoint.CanCollide = false
	waypoint.Material = Enum.Material.Neon
	waypoint.Color = Color3.fromRGB(255, 0, 0)
	waypoint.Parent = workspace

	playSFX(5066021887,0.8)
	hrp.CFrame = CFrame.new(targetPos, targetHRP.Position)
	humanoid.AutoRotate = false
	teleportCooldown = true
	task.wait(COOLDOWN)
	teleportCooldown = false
	humanoid.AutoRotate = true
end

-- [Dash Function]
local function dashToTarget()
	if not dashEnabled_2 or dashCooldown or not currentTarget then return end
	dashCooldown = true

	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then dashCooldown = false return end

	
	playSFX(3084314259, 2)
	

	local target = currentTarget -- Lock the target to prevent changes mid-dash
	local targetHRP = target:FindFirstChild("HumanoidRootPart")
	if not targetHRP then dashCooldown = false return end

	local direction = (targetHRP.Position - hrp.Position)
	local distance = direction.Magnitude
	local normalizedDir = direction.Unit

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bv.Velocity = normalizedDir * MAX_DASH_SPEED
	bv.Parent = hrp

	humanoid.AutoRotate = false
	local timeout = distance / MAX_DASH_SPEED + 0.1
	local start = tick()

	while tick() - start < timeout do
		if not character or not hrp or not targetHRP then break end
		if (targetHRP.Position - hrp.Position).Magnitude <= STOP_DISTANCE then break end
		RunService.Heartbeat:Wait()
	end

	bv:Destroy()
	humanoid.AutoRotate = true
	task.wait(COOLDOWN)
	dashCooldown = false
end

local function tpAndDash()
	if not dashEnabled_2 or dashCooldown or not currentTarget then return end
	dashCooldown = true

	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then dashCooldown = false return end

	local lockedTarget = currentTarget -- << Lock the target
	local targetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
	if not targetHRP then dashCooldown = false return end

	local startPosition = hrp.Position -- Save current position

	-- Calculate initial dash direction
	local direction = (targetHRP.Position - hrp.Position)
	local distance = direction.Magnitude
	local normalizedDir = direction.Unit

	-- Dash setup
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bv.Velocity = normalizedDir * MAX_DASH_SPEED
	bv.Parent = hrp

	humanoid.AutoRotate = false
	local timeout = distance / MAX_DASH_SPEED + 0.2
	local start = tick()

	-- Follow locked target position, even if it moves
	while tick() - start < timeout do
		if not lockedTarget or not lockedTarget:FindFirstChild("HumanoidRootPart") then break end
		playSFX(3084314259, 0.8)

		local newTargetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
		local newDirection = (newTargetHRP.Position - hrp.Position)
		bv.Velocity = newDirection.Unit * MAX_DASH_SPEED

		if newDirection.Magnitude <= STOP_DISTANCE then break end
		RunService.Heartbeat:Wait()
	end

	bv:Destroy()
	humanoid.AutoRotate = true

	task.wait(0.1)
	playSFX(5066021887,0.8)
	hrp.CFrame = CFrame.new(startPosition) -- Teleport back

	task.wait(COOLDOWN)
	dashCooldown = false
end


-- Start flight: create physics
function startFlight()
    if bodyGyro or bodyVelocity then return end -- Prevent duplicates

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = humanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart
end
-- Stop flight: remove physics
function stopFlight()
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end
local function refreshFlightButton()
	if not player:FindFirstChild("PlayerGui") then return end
	local gui = player.PlayerGui:FindFirstChild("FlightGui")
	if gui then
		local button = gui:FindFirstChildWhichIsA("TextButton")
		if button then
			if flightEnabled_3 then
				button.Text = "Fly: ON"
				button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			else
				button.Text = "Fly: OFF"
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			end
		end
	end
end
-- Movement logic using RunService:BindToRenderStep
RunService:BindToRenderStep("FlightControl", Enum.RenderPriority.Character.Value + 1, function()
    if not flightEnabled_3 or not bodyVelocity or not bodyGyro then return end

    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0 then
        local cameraCF = workspace.CurrentCamera.CFrame
        local cameraLook = cameraCF.LookVector
        local cameraRight = cameraCF.RightVector

        local forward = moveDir:Dot(cameraLook)
        local sideways = moveDir:Dot(cameraRight)
        local moveVec = (cameraLook * forward) + (cameraRight * sideways)

        bodyVelocity.Velocity = moveVec.Unit * speed
    else
        bodyVelocity.Velocity = Vector3.zero
    end

    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
end)

-- Function to reset the flight system on respawn
local function setupFlightSystem(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- Start flight or perform any other setup here
    if flightEnabled_3 then
        startFlight()  -- Start flight when character respawns
    end
end

-- Connect to the player's respawn event
player.CharacterAdded:Connect(function(character)
    -- Reset the flight system when the player respawns
    stopFlight()  -- Ensure flight is stopped before respawn
    setupFlightSystem(character)  -- Re-apply flight system after respawn
end)

-- If the player already has a character when the script starts, set it up immediately
if player.Character then
    setupFlightSystem(player.Character)
end

local function Dash2()
	if not dashEnabled_2 or dashCooldown or not currentTarget then return end
	dashCooldown = true

	local flightWasOn = flightEnabled_3
	if flightWasOn then
		flightEnabled_3 = false -- Update the actual state
		stopFlight()
		
	end

	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		dashCooldown = false
		if flightWasOn then
			flightEnabled_3 = true
			startFlight()
		end
		return
	end
	playSFX(6128977275, 0.8)
	local lockedTarget = currentTarget
	local targetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
	if not targetHRP then
		dashCooldown = false
		if flightWasOn then
			flightEnabled_3 = true
			startFlight()
		end
		return
	end

	local startPosition = hrp.Position
	local direction = (targetHRP.Position - hrp.Position)
	local distance = direction.Magnitude
	local normalizedDir = direction.Unit

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bv.Velocity = normalizedDir * MAX_DASH_SPEED
	bv.Parent = hrp

	humanoid.AutoRotate = false
	local timeout = distance / MAX_DASH_SPEED + 0.2
	local start = tick()

	while tick() - start < timeout do
		if not lockedTarget or not lockedTarget:FindFirstChild("HumanoidRootPart") then break end
		local newTargetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
		local newDirection = (newTargetHRP.Position - hrp.Position)
		bv.Velocity = newDirection.Unit * MAX_DASH_SPEED

		-- Optional: Only stop if the dash reaches the max distance or timeout
		if tick() - start > timeout then break end
		RunService.Heartbeat:Wait()
	end

	bv:Destroy()

	-- Return to start position
	local returnBV = Instance.new("BodyVelocity")
	returnBV.MaxForce = Vector3.new(1, 1, 1) * 1e5
	returnBV.Velocity = Vector3.zero
	returnBV.Parent = hrp

	returnReached = false
	while not returnReached do
		local currentPos = hrp.Position
		local toStart = (startPosition - currentPos)
		local dist = toStart.Magnitude

		if dist <= STOP_DISTANCE then
			returnReached = true
			break
		end

		returnBV.Velocity = toStart.Unit * MAX_DASH_SPEED
		RunService.Heartbeat:Wait()
	end

	returnBV:Destroy()
	humanoid.AutoRotate = true

	if flightWasOn then
		flightEnabled_3 = true
		startFlight()
	end

	task.wait(COOLDOWN)
	dashCooldown = false
end
local function Ult()
	if not currentTarget or ultCooldown then return end
	ultCooldown = true
	
	playRandomSFX(
		{SoundId = 103552223389683, Action = function() sendChatMessage("ENOUGH") end},
		{SoundId = 89672861377061, Action = function() sendChatMessage("NOTHING BUT SCRAP") end}
	)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then ultCooldown = false return end

	local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")
	if not targetHRP then ultCooldown = false return end

	local startPosition = hrp.Position -- store original position

	local duration -- seconds
	local dashSpeed -- Faster dash
	local radius  --radius around the target to teleport to

	if kelerEnabled then
		duration = 7
		radius = 5.5
		dashSpeed = MAX_DASH_SPEED * 2
	else
		dashSpeed = MAX_DASH_SPEED * 2
		duration = 3.5
		radius = 6
	end
	
	local startTime = tick()
	
	humanoid.AutoRotate = false

	while tick() - startTime < duration do
		-- Random teleport around the target
		local angle = math.rad(math.random(0, 360))
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
		local teleportPos = targetHRP.Position + offset + Vector3.new(0, 2, 0) -- slightly above ground
		playSFX(5066021887,0.8)
		hrp.CFrame = CFrame.new(teleportPos, targetHRP.Position)

		-- Dash to target
		stopFlight() -- Ensure flight is stopped before dashing
		local direction = (targetHRP.Position - hrp.Position).Unit
		local bv = Instance.new("BodyVelocity")
		
		bv.MaxForce = Vector3.new(1, 1, 1) * 1e6
		bv.Velocity = direction * dashSpeed
		bv.Parent = hrp

		local dashStart = tick()
		while tick() - dashStart < 0.2 do -- short fast dash
			playSFX(6128977275, 0.8)
			if (targetHRP.Position - hrp.Position).Magnitude <= STOP_DISTANCE then 
				break
			end
			RunService.Heartbeat:Wait()
		end

		bv:Destroy()
		task.wait(0.1) -- short pause between tele-dashes
		
		-- Ensure startFlight() is called after the dash
		startFlight()
	end
	
	-- Now, teleport back to the original position after the ult duration
	hrp.CFrame = CFrame.new(startPosition) -- Teleport back to original position

	humanoid.AutoRotate = true
	task.wait(COOLDOWN)
	ultCooldown = false
end
-- [Startup]
createCrosshair()
createTeleportGui()
createFlightGui()
createDashGui()
keler()

RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)

player.CharacterAdded:Connect(function()
	createCrosshair()
	RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
end)

local joystickSize = Vector2.new(250, 250)

local function isInJoystickRegion(pos)
	local screenSize = Camera.ViewportSize
	local bottomLeft = Vector2.new(0, screenSize.Y - joystickSize.Y)
	local topRight = bottomLeft + joystickSize

	return pos.X >= bottomLeft.X and pos.X <= topRight.X
	   and pos.Y >= bottomLeft.Y and pos.Y <= topRight.Y
end

UIS.TouchStarted:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.Touch then
		local touchPos = input.Position
		if isInJoystickRegion(touchPos) then return end

		if ult then
			Ult()
		elseif flightdash then
			Dash2()
		elseif teleportEnabled and dashEnabled_2 then
			tpAndDash()
		else
			if teleportEnabled then
				teleportToTarget()
			end
			if dashEnabled_2 then
				dashToTarget()
				
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()

	
	if flightEnabled_3 and dashEnabled_2 and teleportEnabled then
		ult = true 
	else
	
		if flightEnabled_3 and dashEnabled_2  then
			flightdash = true
			
		else 
			flightdash = false
		end
		ult = false
	end
	
end)

-- flight
