local ESP = {}

ESP.Config = {
    Enabled = true,
    TeamColors = {
        [Enum.Team.Blue] = Color3.fromRGB(0, 100, 255),
        [Enum.Team.Red] = Color3.fromRGB(255, 50, 50),
        Default = Color3.fromRGB(255, 255, 0)
    }
}

function ESP.CreateHighlight(player)
    local character = player.Character
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.Adornee = character
    
    -- Definir cor do highlight baseado no time
    local teamColor = ESP.Config.TeamColors[player.Team] or ESP.Config.TeamColors.Default
    highlight.FillColor = teamColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    
    return highlight
end

function ESP.Initialize()
    local highlights = {}

    -- Adicionar ESP para jogadores existentes
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            highlights[player] = ESP.CreateHighlight(player)
        end
    end

    -- Adicionar ESP para novos jogadores
    game.Players.PlayerAdded:Connect(function(player)
        highlights[player] = ESP.CreateHighlight(player)
    end)

    -- Remover ESP de jogadores que sairem
    game.Players.PlayerRemoving:Connect(function(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end)
end

ESP.Initialize()
return ESP
