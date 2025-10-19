-- Aimlock.lua
-- Fungerar med Rayfield Toggle (håll högerklick)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== INSTÄLLNINGAR =====
local aimEnabled = true          -- Toggle via Rayfield
local aimFOV = 200               -- Max distans från crosshair
local aimKey = Enum.UserInputType.MouseButton2 -- Högerklick

-- ===== INTERNT =====
local aiming = false
local currentTarget = nil

-- Hitta närmaste spelarens huvud till crosshair
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
                if dist < shortestDist and dist < aimFOV then
                    shortestDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

-- Fokusera kameran på target
local function aimAt(targetHead)
    if targetHead then
        local headPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
        if onScreen then
            local mouse = UserInputService:GetMouseLocation()
            local delta = Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)
            pcall(function()
                mousemoverel(delta.X, delta.Y)
            end)
        end
    end
end

-- ===== INPUT EVENTS =====
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == aimKey then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimKey then
        aiming = false
        currentTarget = nil
    end
end)

-- ===== RUNSERVICE LOOP =====
RunService.RenderStepped:Connect(function()
    if aimEnabled and aiming then
        if not currentTarget or not currentTarget.Parent then
            currentTarget = getClosestTarget()
        end
        if currentTarget then
            aimAt(currentTarget)
        end
    end
end)
