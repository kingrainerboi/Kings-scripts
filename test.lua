local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")
local flightEnabled = false

local speed = 50
local bodyGyro, bodyVelocity

-- Create the GUI (toggle only flightEnabled)
local function createFlightGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FlightGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 160, 0, 30)
	button.Position = UDim2.new(1, -170, 1, -90)
	button.AnchorPoint = Vector2.new(0, 1)
	button.Text = "Fly: OFF"
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = gui

	button.MouseButton1Click:Connect(function()
		flightEnabled = not flightEnabled
		if flightEnabled then
			button.Text = "Fly: ON"
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			startFlight()
		else
			button.Text = "Fly: OFF"
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			stopFlight()
		end
	end)
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

-- Movement logic
runService:BindToRenderStep("FlightControl", Enum.RenderPriority.Character.Value + 1, function()
	if not flightEnabled or not bodyVelocity or not bodyGyro then return end

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

-- Initialize GUI
createFlightGui()