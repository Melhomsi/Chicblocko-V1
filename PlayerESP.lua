-- PlayerESP.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = true
local playerBillboards = {}
local connections = {}

local function createESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    if playerBillboards[plr] then playerBillboards[plr]:Destroy() end

    local gui = Instance.new("BillboardGui", hrp)
    gui.Name = "PlayerESP"
    gui.Size = UDim2.new(0,100,0,30)
    gui.StudsOffset = Vector3.new(0,3,0)
    gui.AlwaysOnTop = true

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    playerBillboards[plr] = gui
end

local function removeAllESP()
    for _, gui in pairs(playerBillboards) do
        if gui then gui:Destroy() end
    end
    playerBillboards = {}
    for _, conn in pairs(connections) do conn:Disconnect() end
    connections = {}
end

-- Init
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createESP(plr)
        local conn = plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            createESP(plr)
        end)
        table.insert(connections, conn)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        local conn = plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            createESP(plr)
        end)
        table.insert(connections, conn)
    end
end))

local loopConn
loopConn = RunService.RenderStepped:Connect(function()
    if not ESPEnabled then
        loopConn:Disconnect()
        removeAllESP()
        return
    end
    for plr, gui in pairs(playerBillboards) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then label.Text = plr.Name .. " | " .. dist .. " studs" end
        else
            gui:Destroy()
            playerBillboards[plr] = nil
        end
    end
end)

return function(toggle)
    ESPEnabled = toggle
    if not toggle then removeAllESP() end
end
