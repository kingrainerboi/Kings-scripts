local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- SETTINGS
local BASE_SPEED = 16
local BASE_RADIUS = 20
local isActive = false
local highlights = {}

-- STATE
local lastChatTime = 0
local chaseTarget = nil
local currentSpeed = BASE_SPEED

-- REFERENCES
local character, humanoid, hrp

local function updateCharacter()
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
hrp = character:WaitForChild("HumanoidRootPart")
currentSpeed = BASE_SPEED
end

updateCharacter()
player.CharacterAdded:Connect(function()
task.wait(1)
updateCharacter()
end)

-- GUI
local function createToggleGui()
local gui = Instance.new("ScreenGui")
gui.Name = "HungryGuyGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 140, 0, 30)
button.Position = UDim2.new(1, -150, 1, -40)
button.AnchorPoint = Vector2.new(0, 1)
button.Text = "Hungry Guy: OFF"
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Parent = gui

button.MouseButton1Click:Connect(function()
isActive = not isActive
button.Text = "Hungry Guy: " .. (isActive and "ON" or "OFF")
if not isActive then
for _, h in pairs(highlights) do h:Destroy() end
highlights = {}
chaseTarget = nil
humanoid.WalkSpeed = BASE_SPEED
end
end)

end

-- HIGHLIGHT
local function addHighlight(model)
if highlights[model] then return end
local h = Instance.new("Highlight")
h.FillTransparency = 1
h.OutlineColor = Color3.fromRGB(255, 0, 0)
h.OutlineTransparency = 0
h.Adornee = model
h.Parent = model
highlights[model] = h
end

local function removeAllHighlights()
for model, h in pairs(highlights) do
if h then h:Destroy() end
end
highlights = {}
end

-- GET TARGETS
local function getTargets(radius)
local visibleTargets = {}

for _, p in pairs(Players:GetPlayers()) do
if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
local targetHRP = p.Character.HumanoidRootPart
local dist = (targetHRP.Position - hrp.Position).Magnitude

if dist <= radius then    
        local dir = (targetHRP.Position - hrp.Position).Unit    
        local dot = hrp.CFrame.LookVector:Dot(dir)    
        local angle = math.deg(math.acos(dot))    

        -- LOS check    
        local rayParams = RaycastParams.new()    
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist    
        rayParams.FilterDescendantsInstances = {character}    
        local result = workspace:Raycast(hrp.Position, dir * dist, rayParams)    

        if result and result.Instance:IsDescendantOf(p.Character) then    
            table.insert(visibleTargets, {player = p, distance = dist, angle = angle})    
            addHighlight(p.Character)    
        end    
    end    
end

end

-- Clean up removed highlights
for model in pairs(highlights) do
local stillVisible = false
for _, t in ipairs(visibleTargets) do
if t.player.Character == model then
stillVisible = true
break
end
end
if not stillVisible then
if highlights[model] then highlights[model]:Destroy() end
highlights[model] = nil
end
end

return visibleTargets

end

-- MAIN LOOP
RunService.Heartbeat:Connect(function(dt)
if not isActive or not humanoid or humanoid.Health <= 0 then return end

local hpPercent = humanoid.Health / humanoid.MaxHealth
local speedBoost = (1 - hpPercent) * 10
local radiusBoost = (1 - hpPercent) * 15

local baseSpeed = BASE_SPEED + speedBoost
local radius = BASE_RADIUS + radiusBoost

local targets = getTargets(radius)
table.sort(targets, function(a, b)
if math.abs(a.angle - b.angle) < 5 then
return a.distance < b.distance
else
return a.angle < b.angle
end
end)

if #targets > 0 then
local chosen = targets[1]

-- Say "stay away..." once every 10 seconds    
if tick() - lastChatTime >= 10 then    
    lastChatTime = tick()    
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("stay away...", "All")    
end    

-- Gradual speed up    
if chaseTarget == chosen.player then    
    currentSpeed = math.min(currentSpeed + dt * 5, baseSpeed + 10)    
else    
    chaseTarget = chosen.player    
    currentSpeed = baseSpeed    
end    

humanoid.WalkSpeed = currentSpeed    
humanoid:MoveTo(chosen.player.Character.HumanoidRootPart.Position)

else
-- No target - slow back down
chaseTarget = nil
currentSpeed = math.max(currentSpeed - dt * 8, BASE_SPEED)
humanoid.WalkSpeed = currentSpeed
end

end)

-- INIT
createToggleGui()

