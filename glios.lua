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

-- [Player & Settings]
local player = Players.LocalPlayer
local MAX_DASH_SPEED = 150
local RAY_DISTANCE = 1000
local COOLDOWN = 1.8
local RAY_ANGLE_OFFSET = 5
local STOP_DISTANCE = 3
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
local lockOnTarget = nil  
local lastTouchPosition = nil  
-- [Flight Variables]
local speed = 50
local bodyGyro, bodyVelocity


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
	button.Position = UDim2.new(1, -170, 1, -80)  
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
	button.Position = UDim2.new(1, -170, 1, -130)  
	button.AnchorPoint = Vector2.new(0, 1)  
	button.Text = "efly"  
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
	button.TextColor3 = Color3.new(1, 1, 1)  
	button.TextScaled = true  
	button.Parent = gui  

	button.MouseButton1Click:Connect(function()  
		if not flightdash then
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
	button.Position = UDim2.new(1, -170, 1, -180)  
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

-- [Crosshair]
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

-- [Highlight]
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
	if highlight then highlight:Destroy() highlight = nil end
end

-- [Ray Directions]
local function degToRad(deg)
	return deg * math.pi / 180
end

local function getRayDirections()
	local baseDir = Camera.CFrame.LookVector
	local rightVec = Camera.CFrame.RightVector
	local upVec = Camera.CFrame.UpVector
	local offset = math.tan(degToRad(RAY_ANGLE_OFFSET))
	return {
		baseDir,
		(baseDir + rightVec * offset).Unit,
		(baseDir - rightVec * offset).Unit,
		(baseDir + upVec * offset).Unit,
		(baseDir - upVec * offset).Unit,
	}
end

-- [Target Detection]
-- Update raycast for target detection
local function updateRaycast()
    if teleportEnabled or dashEnabled_2 then
        local origin = Camera.CFrame.Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {character}
        rayParams.IgnoreWater = true
        
        -- Raycasting in multiple directions for better target detection
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
end

-- Update the camera position smoothly to follow the locked target
local function updateCamera()
    if lockOnTarget then
        -- Get the position of the target's humanoid root part
        local targetPosition = lockOnTarget:FindFirstChild("HumanoidRootPart").Position
        
        -- Set the camera's CFrame to follow the target with some offset
        local desiredCFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 20)) -- 20 studs behind target, adjust as needed
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition) * desiredCFrame - desiredCFrame.Position
        
        -- Smooth movement (optional)
        local smoothSpeed = 10
        Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, smoothSpeed * RunService.Heartbeat:Wait())
    end
end

-- Lock onto the target
local function lockOn(character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        lockOnTarget = character
        updateCamera()
    end
end

-- Unlock from the target
local function unlock()
    lockOnTarget = nil
end

-- Handle touch movement for rotating the camera
local function onTouchMoved(touch)
    if not lockOnTarget then return end

    if lastTouchPosition then
        -- Calculate the change in touch position to rotate the camera
        local delta = touch.Position - lastTouchPosition
        local rotationSpeed = 0.5

        -- Update the camera's rotation based on touch movement
        local cameraRotation = CFrame.Angles(0, -delta.X * rotationSpeed, 0) -- Rotate around the Y-axis (horizontal)
        Camera.CFrame = Camera.CFrame * cameraRotation
    end

    lastTouchPosition = touch.Position
end

-- Reset touch position on touch end
local function onTouchEnded(touch)
    lastTouchPosition = nil
end

-- Handle touch input for locking onto a target
UIS.TouchTap:Connect(function(_, position)
    -- Example: Lock onto the target when tapping on a character
    local target = workspace:FindPartOnRayWithWhitelist(Camera:ScreenPointToRay(position.X, position.Y), {workspace})
    local character = target and target.Parent
    if character then
        lockOn(character)
    end
end)

-- Unlock from the target when tapping the screen with two fingers (example)
UIS.TouchTap:Connect(function(_, position)
    if UIS.TouchCount > 1 then
        unlock()
    end
end)

-- Run the camera update and target detection
RunService.RenderStepped:Connect(function()
    if lockOnTarget then
        updateCamera()
    end
    updateRaycast()
end)




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
		local newTargetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
		local newDirection = (newTargetHRP.Position - hrp.Position)
		bv.Velocity = newDirection.Unit * MAX_DASH_SPEED

		if newDirection.Magnitude <= STOP_DISTANCE then break end
		RunService.Heartbeat:Wait()
	end

	bv:Destroy()
	humanoid.AutoRotate = true

	task.wait(0.1)
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
-- Movement logic
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

-- [Startup]
createCrosshair()
createTeleportGui()
createFlightGui()
createDashGui()
RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)

player.CharacterAdded:Connect(function()
	createCrosshair()
	RunService:BindToRenderStep("TargetRaycast", Enum.RenderPriority.Input.Value, updateRaycast)
end)

-- [Touch Input Fix]
UIS.TouchTap:Connect(function(touchPositions, processed)
	if not processed then

		


		if teleportEnabled and dashEnabled_2 then
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
	if flightEnabled_3 and dashEnabled_2  then
		flightdash = true
		Dash2()
	else 
		flightdash = false
	end

	
end)

-- flight
