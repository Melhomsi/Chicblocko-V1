-- PlayerESP.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local playerESPEnabled = true
local playerBillboards = {}

local function createPlayerESP(plr)
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
    label.Text = plr.Name

    playerBillboards[plr] = gui
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart",5)
        if playerESPEnabled then createPlayerESP(plr) end
    end)
    if plr.Character and playerESPEnabled then createPlayerESP(plr) end
end)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and playerESPEnabled then createPlayerESP(plr) end
end
