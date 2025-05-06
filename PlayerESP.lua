local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    -- Skapa en ny GUI för ESP
    local espBox = Instance.new("BillboardGui")
    espBox.Parent = player.Character
    espBox.Adornee = player.Character:WaitForChild("Head")
    espBox.Size = UDim2.new(0, 100, 0, 100)
    espBox.StudsOffset = Vector3.new(0, 2, 0)
    espBox.AlwaysOnTop = true
    espBox.LightInfluence = 1
    espBox.MaxDistance = 1000

    -- Skapa en text etikett för att visa spelarens namn
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = espBox
    textLabel.Text = player.Name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 14
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
end

local function removeESP(player)
    -- Ta bort ESP när spelaren försvinner
    if player.Character and player.Character:FindFirstChild("Head") then
        local espBox = player.Character:FindFirstChildOfClass("BillboardGui")
        if espBox then
            espBox:Destroy()
        end
    end
end

-- Lyssna på när en spelare läggs till
Players.PlayerAdded:Connect(function(player)
    -- Vänta på att spelarens karaktär ska laddas
    player.CharacterAdded:Connect(function(character)
        -- Vänta tills "Head" finns för att skapa ESP
        character:WaitForChild("Head")
        createESP(player)

        -- Ta bort ESP när spelaren försvinner
        player.CharacterRemoving:Connect(function()
            removeESP(player)
        end)
    end)
end)

-- Skapa ESP för alla redan närvarande spelare
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character and player.Character:FindFirstChild("Head") then
        createESP(player)
    end
end

-- Uppdatera ESP varje renderstepp för att hålla positionerna rätt
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local espBox = player.Character
