-- =====================================
-- AIMLOCK (ersätter det gamla dåliga)
-- =====================================
local aimFOV = 20 -- FOV för aimlock
local aimRange = 500
local aimKey = Enum.UserInputType.MouseButton2
local aimEnabled = false
local aiming = false
local currentTarget = nil

-- Funktion för att hitta spelaren närmast crosshair
local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if plr ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
            local head = char:FindFirstChild("Head")
            if head then
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
        pcall(function() mousemoverel(delta.X * sensitivity, delta.Y * sensitivity) end)
    end
end

-- Input-events för aimlock
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

-- Main loop för aimlock
RunService.RenderStepped:Connect(function()
    if aimEnabled and aiming then
        currentTarget = currentTarget and currentTarget.Parent and currentTarget or getClosestTarget()
        if currentTarget then
            aimAtHead(currentTarget)
        end
    end
end)
