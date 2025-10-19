-- Aimlock.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local aimEnabled = true
local aiming = false
local currentTarget = nil
local aimFOV = 20
local aimKey = Enum.UserInputType.MouseButton2
local connections = {}

-- Hitta närmaste spelaren
local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if plr ~= LocalPlayer and char and char:FindFirstChild("Head") then
            local head = char.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                if dist < aimFOV and dist < shortestDist then
                    closest = head
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

local function aimAtHead(targetHead)
    if not targetHead then return end
    local headPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
    if onScreen then
        local mouse = UserInputService:GetMouseLocation()
        local delta = Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)
        local sensitivity = 1
        pcall(function()
            mousemoverel(delta.X * sensitivity, delta.Y * sensitivity)
        end)
    end
end

-- Input events
table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == aimKey or input.KeyCode == aimKey then aiming = true end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimKey or input.KeyCode == aimKey then
        aiming = false
        currentTarget = nil
    end
end))

-- RenderStepped
local loopConn
loopConn = RunService.RenderStepped:Connect(function()
    if not aimEnabled then
        loopConn:Disconnect()
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        return
    end
    if aiming then
        currentTarget = currentTarget and currentTarget.Parent and currentTarget or getClosestTarget()
        if currentTarget then
            aimAtHead(currentTarget)
        end
    end
end)

-- Toggle-funktion
return function(toggle)
    aimEnabled = toggle
end
