-- Aimlock.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimEnabled = false
local aiming = false
local currentTarget = nil
local aimFOV = 20
local aimKey = Enum.UserInputType.MouseButton2

local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if plr ~= LocalPlayer and char and char:FindFirstChild("Head") then
            local head = char.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if dist < aimFOV and dist < shortestDist then
                    closest = head
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

local function aimAtHead(target)
    if not target then return end
    local headPos, onScreen = Camera:WorldToViewportPoint(target.Position)
    if onScreen then
        local mouse = UserInputService:GetMouseLocation()
        local delta = Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)
        pcall(function()
            mousemoverel(delta.X, delta.Y)
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == aimKey or input.KeyCode == aimKey then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimKey or input.KeyCode == aimKey then
        aiming = false
        currentTarget = nil
    end
end)

local conn
return function(Value)
    aimEnabled = Value
    if conn then conn:Disconnect() end
    if aimEnabled then
        conn = RunService.RenderStepped:Connect(function()
            if aiming then
                currentTarget = currentTarget and currentTarget.Parent and currentTarget or getClosestTarget()
                if currentTarget then
                    aimAtHead(currentTarget)
                end
            end
        end)
    end
end
