-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Script Active",
    Text = "By Mr KR - Works only for Skinwalkers",
    Duration = 5
})

-- Player Info
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")

-- Remotes
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shoot")
local SniperShotRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SniperShot")

-- Settings
local SCAN_RADIUS = 150
local SHOOT_COOLDOWN = 0.5
local AIM_THRESHOLD = 0.99
local lastShotTime = 0
local SNIPER_RANGE = 100
local MAX_SHOOT_DISTANCE = 300

-- Helper Functions
local function getTargetPart(npc)
    return npc:FindFirstChild("UpperTorso") or npc:FindFirstChild("Head") or npc:FindFirstChild("HumanoidRootPart")
end

local function getClosestSkinwalker()
    local closestPart = nil
    local closestDist = SCAN_RADIUS

    for _, npc in pairs(workspace.Runners.Skinwalkers:GetChildren()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        local part = getTargetPart(npc)

        if humanoid and humanoid.Health > 0 and part then
            local dist = (HRP.Position - part.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = part
            end
        end
    end

    return closestPart
end

local function rotateCameraToward(targetPos)
    local camCF = camera.CFrame
    local lookVector = (targetPos - camCF.Position).Unit
    local newCF = CFrame.new(camCF.Position, camCF.Position + lookVector)
    camera.CFrame = camCF:Lerp(newCF, 0.2)
end

local function isCameraAimedAt(targetPos)
    local camLook = camera.CFrame.LookVector.Unit
    local toTarget = (targetPos - camera.CFrame.Position).Unit
    local dot = camLook:Dot(toTarget)
    return dot >= AIM_THRESHOLD
end

-- Outline Utility
local currentHighlight
local function applyOutline(target)
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end

    if target then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = target.Parent
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = target
        currentHighlight = highlight
    end
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    local targetPart = getClosestSkinwalker()
    applyOutline(targetPart)
    if not targetPart then return end

    rotateCameraToward(targetPart.Position)

    if tick() - lastShotTime >= SHOOT_COOLDOWN and isCameraAimedAt(targetPart.Position) then
        lastShotTime = tick()

        local origin = camera.CFrame.Position
        local toTarget = targetPart.Position - origin
        local direction = toTarget.Unit
        local dist = toTarget.Magnitude
        local shootDistance = math.min(dist, MAX_SHOOT_DISTANCE)
        local finalTargetPos = origin + direction * shootDistance

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist

        local raycastResult = workspace:Raycast(origin, direction * shootDistance, rayParams)

        if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            if dist > SNIPER_RANGE then
                local args = {
                    [1] = origin,
                    [2] = targetPart.Position,
                    [3] = targetPart
                }
                SniperShotRemote:FireServer(unpack(args))
            else
                local args = {
                    [1] = origin,
                    [2] = direction,
                    [3] = {}
                }
                ShootRemote:FireServer(unpack(args))
            end
        end
    end
end)