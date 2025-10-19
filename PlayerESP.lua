-- PlayerESP.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local playerBillboards = {}
local conn = nil

local function createESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if playerBillboards[plr] then playerBillboards[plr]:Destroy() end

    local gui = Instance.new("BillboardGui", plr.Character.HumanoidRootPart)
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

local function removeAllESP()
    for _, gui in pairs(playerBillboards) do
        gui:Destroy()
    end
    playerBillboards = {}
end

local function updateESP()
    for plr, gui in pairs(playerBillboards) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
        if hrp and humanoid and humanoid.Health>0 then
            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then label.Text = plr.Name.."\n"..dist.." studs" end
        else
            gui:Destroy()
            playerBillboards[plr] = nil
        end
    end
end

return function(active)
    removeAllESP()
    if conn then conn:Disconnect() conn=nil end
    if active then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then createESP(plr) end
        end
        conn = RunService.RenderStepped:Connect(updateESP)
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if active then createESP(plr) end
            end)
        end)
    end
end
