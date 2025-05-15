-- LocalScript in StarterPlayerScripts

-- Function to delete all current sounds
local function deleteAllSounds()
	for _, sound in pairs(game:GetDescendants()) do
		if sound:IsA("Sound") then
			sound:Destroy()
		end
	end
end

-- Step 1: Delete all sounds
deleteAllSounds()

-- Step 2: Prevent new sounds from being added during the block
local blocked = true

-- Temporary connection to block sound creation
local connection = game.DescendantAdded:Connect(function(descendant)
	if blocked and descendant:IsA("Sound") then
		descendant:Destroy()
	end
end)

-- Step 3: Wait 1 second
task.wait(1)

-- Step 4: Unblock sound creation
blocked = false
connection:Disconnect()