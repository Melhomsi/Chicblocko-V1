-- PlayerESP.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local playerBillboards = {}

local function createESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    if playerBillboards[plr] then playerBillboards[plr]:Destroy() end

    local gui = Instance.new("BillboardGui", hrp)
    gui.Name = "PlayerESP"
    gui.Size = UDim2.new(0, 100, 0, 30)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    playerBillboards[plr] = gui
end

-- Init för befintliga spelare
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createESP(plr)
        plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            createESP(plr)
        end)
    end
end

-- Event för nya spelare
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            createESP(plr)
        end)
    end
end)

-- Uppdatera text i realtid
game:GetService("RunService").RenderStepped:Connect(function()
    for plr, gui in pairs(playerBillboards) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude)
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = plr.Name .. " | " .. dist .. " studs"
            end
        else
            if gui then gui:Destroy() end
            playerBillboards[plr] = nil
        end
    end
end)
