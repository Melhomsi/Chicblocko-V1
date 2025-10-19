-- Aimlock med muspekare
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local aiming = false
local aimEnabled = false
local currentTarget = nil
local aimFOV = 20
local aimKey = Enum.UserInputType.MouseButton2

-- Input
UserInputService.InputBegan:Connect(function(input)
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

-- Hitta närmsta spelarhuvud
local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
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

-- AimAtHead med muspekare
local function aimAtHead(targetHead)
    if not targetHead then return end

    local headPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
    if onScreen then
        local mouse = UserInputService:GetMouseLocation()
        local deltaX = headPos.X - mouse.X
        local deltaY = headPos.Y - mouse.Y
        -- Om delta är väldigt stort, dela upp det i mindre steg för att inte tappa målet
        local steps = math.max(1, math.floor((Vector2.new(deltaX, deltaY).Magnitude) / 10))
        for i = 1, steps do
            pcall(function()
                mousemoverel(deltaX/steps, deltaY/steps)
            end)
        end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if aimEnabled and aiming then
        currentTarget = currentTarget and currentTarget.Parent and currentTarget or getClosestTarget()
        if currentTarget then
            aimAtHead(currentTarget)
        end
    end
end)

-- Funktion som togglar aimlock
return function(Value)
    aimEnabled = Value
end
