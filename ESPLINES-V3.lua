local ESPManager = {}

-- Configurações padrão
ESPManager.Config = {
    Enabled = true,
    Features = {
        Box = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 2
        },
        Highlight = {
            Enabled = true,
            FillTransparency = 0.7,
            TeamColors = {
                Friendly = Color3.fromRGB(0, 255, 0),
                Enemy = Color3.fromRGB(255, 0, 0),
                Neutral = Color3.fromRGB(255, 255, 0)
            }
        },
        Name = {
            Enabled = true,
            Color = Color3.new(1, 1, 1),
            Size = 14
        },
        Health = {
            Enabled = true,
            ShowText = true,
            BarColor = Color3.fromRGB(0, 255, 0)
        },
        Distance = {
            Enabled = true,
            Color = Color3.new(1, 1, 1),
            Size = 12
        },
        Weapon = {
            Enabled = true,
            Color = Color3.new(1, 1, 1),
            Size = 12
        }
    },
    
    -- Configurações gerais
    MaxRenderDistance = 500,
    TeamCheck = true
}

-- Função para criar componentes de ESP
function ESPManager.CreateESPComponents(player)
    local character = player.Character
    if not character then return nil end

    local espComponents = {}

    -- Função para verificar se o recurso está ativado
    local function isFeatureEnabled(featureName)
        return ESPManager.Config.Enabled and 
               ESPManager.Config.Features[featureName].Enabled
    end

    -- Highlight
    if isFeatureEnabled("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.Adornee = character
        highlight.FillTransparency = ESPManager.Config.Features.Highlight.FillTransparency
        
        local teamColor = player.Team == game.Players.LocalPlayer.Team 
            and ESPManager.Config.Features.Highlight.TeamColors.Friendly
            or ESPManager.Config.Features.Highlight.TeamColors.Enemy
        
        highlight.FillColor = teamColor
        espComponents.Highlight = highlight
    end

    -- Nome
    if isFeatureEnabled("Name") then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Parent = character.HumanoidRootPart
        nameTag.Size = UDim2.new(0, 100, 0, 50)
        nameTag.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = nameTag
        nameLabel.Text = player.Name
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = ESPManager.Config.Features.Name.Color
        nameLabel.TextSize = ESPManager.Config.Features.Name.Size
        
        espComponents.NameTag = nameTag
    end

    -- Barra de Vida
    if isFeatureEnabled("Health") then
        local healthBar = Instance.new("BillboardGui")
        healthBar.Parent = character.HumanoidRootPart
        healthBar.Size = UDim2.new(0, 100, 0, 10)
        
        local healthFrame = Instance.new("Frame")
        healthFrame.Parent = healthBar
        healthFrame.BackgroundColor3 = ESPManager.Config.Features.Health.BarColor
        
        espComponents.HealthBar = {
            Billboard = healthBar,
            Frame = healthFrame
        }
    end

    -- Função de atualização
    local function UpdateESP()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and espComponents.HealthBar then
            espComponents.HealthBar.Frame.Size = UDim2.new(
                humanoid.Health / humanoid.MaxHealth, 0, 1, 0
            )
        end
    end

    -- Conectar atualização
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.HealthChanged:Connect(UpdateESP)
    end

    return espComponents
end

-- Função de inicialização
function ESPManager.Initialize()
    local activeESPs = {}
    
    -- Adicionar ESP para jogadores existentes
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and 
           (not ESPManager.Config.TeamCheck or 
            player.Team ~= game.Players.LocalPlayer.Team) then
            activeESPs[player] = ESPManager.CreateESPComponents(player)
        end
    end
    
    -- Adicionar novos jogadores
    game.Players.PlayerAdded:Connect(function(player)
        if not ESPManager.Config.TeamCheck or 
           player.Team ~= game.Players.LocalPlayer.Team then
            activeESPs[player] = ESPManager.CreateESPComponents(player)
        end
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

-- Função para modificar configurações
function ESPManager.SetFeature(featureName, enabled)
    if ESPManager.Config.Features[featureName] then
        ESPManager.Config.Features[featureName].Enabled = enabled
    end
end

-- Inicializar
ESPManager.Initialize()

return ESPManager

-- Exemplos de uso:
-- ESPManager.SetFeature("Name", false)  -- Desativar nomes
-- ESPManager.SetFeature("Health", false)  -- Desativar barra de vida
-- ESPManager.Config.TeamCheck = false  -- Desativar verificação de time
