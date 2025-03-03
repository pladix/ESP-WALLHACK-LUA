local ESPManager = {}

ESPManager.Settings = {
    Enabled = true,
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowWeapon = true,
    MaxRenderDistance = 500,
    TeamCheck = true
}

ESPManager.Styles = {
    BoxColor = {
        Friendly = Color3.fromRGB(0, 255, 0),
        Enemy = Color3.fromRGB(255, 0, 0),
        Neutral = Color3.fromRGB(255, 255, 0)
    },
    TextColor = Color3.new(1, 1, 1)
}

function ESPManager.CreatePlayerESP(player)
    local espComponents = {}
    local character = player.Character
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.Adornee = character
    highlight.FillTransparency = 0.7
    
    -- Nome
    local nameTag = Instance.new("BillboardGui")
    nameTag.Parent = character.HumanoidRootPart
    nameTag.Size = UDim2.new(0, 100, 0, 50)
    nameTag.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = nameTag
    nameLabel.Text = player.Name
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = ESPManager.Styles.TextColor
    
    -- Barra de Vida
    local healthBar = Instance.new("BillboardGui")
    healthBar.Parent = character.HumanoidRootPart
    healthBar.Size = UDim2.new(0, 100, 0, 10)
    
    local healthFrame = Instance.new("Frame")
    healthFrame.Parent = healthBar
    healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Atualização dinâmica
    local function UpdateESP()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Atualizar barra de vida
            healthFrame.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            
            -- Definir cor do highlight
            local teamColor = player.Team == game.Players.LocalPlayer.Team 
                and ESPManager.Styles.BoxColor.Friendly 
                or ESPManager.Styles.BoxColor.Enemy
            
            highlight.FillColor = teamColor
        end
    end
    
    -- Conectar atualização
    character.Humanoid.HealthChanged:Connect(UpdateESP)
    
    return {
        highlight = highlight,
        nameTag = nameTag,
        healthBar = healthBar,
        update = UpdateESP
    }
end

function ESPManager.Initialize()
    local activeESPs = {}
    
    -- Adicionar ESP para jogadores existentes
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            activeESPs[player] = ESPManager.CreatePlayerESP(player)
        end
    end
    
    -- Adicionar novos jogadores
    game.Players.PlayerAdded:Connect(function(player)
        activeESPs[player] = ESPManager.CreatePlayerESP(player)
    end)
    
    -- Remover ESP de jogadores que saírem
    game.Players.PlayerRemoving:Connect(function(player)
        if activeESPs[player] then
            for _, component in pairs(activeESPs[player]) do
                if typeof(component) == "Instance" then
                    component:Destroy()
                end
            end
            activeESPs[player] = nil
        end
    end)
end

ESPManager.Initialize()
return ESPManager
