local ESP = {}

ESP.Config = {
    Enabled = true,
    MaxDistance = 500,
    TeamCheck = true,
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ShowWeapon = true
}

ESP.Styles = {
    BoxColor = {
        Friendly = Color3.fromRGB(0, 255, 0),
        Enemy = Color3.fromRGB(255, 0, 0)
    }
}

function ESP.CreateBox(character, player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Styles.BoxColor.Enemy
    box.Thickness = 2
    box.Filled = false

    local function UpdateBox()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            local size = character:GetExtentsSize()
            local scale = character:GetScale()
            
            box.Size = Vector2.new(size.X * scale, size.Y * scale)
            box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
            box.Visible = true
        else
            box.Visible = false
        end
    end

    return {box = box, update = UpdateBox}
end

function ESP.CreateNameTag(character, player)
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.new(1, 1, 1)
    nameTag.Text = player.Name
    nameTag.Size = 16
    nameTag.Center = true

    local function UpdateNameTag()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            nameTag.Position = Vector2.new(vector.X, vector.Y - 20)
            nameTag.Visible = true
        else
            nameTag.Visible = false
        end
    end

    return {tag = nameTag, update = UpdateNameTag}
end

function ESP.TrackPlayer(player)
    local character = player.Character
    if not character then return nil end

    local espElements = {
        box = ESP.CreateBox(character, player),
        nameTag = ESP.CreateNameTag(character, player)
    }

    return espElements
end

function ESP.Initialize()
    local trackedPlayers = {}

    game:GetService("RunService").RenderStepped:Connect(function()
        if not ESP.Config.Enabled then return end

        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if ESP.Config.TeamCheck and player.Team == game.Players.LocalPlayer.Team then
                    continue
                end

                local playerESP = trackedPlayers[player]
                
                if not playerESP then
                    trackedPlayers[player] = ESP.TrackPlayer(player)
                else
                    if playerESP.box then playerESP.box.update() end
                    if playerESP.nameTag then playerESP.nameTag.update() end
                end
            end
        end
    end)
end

ESP.Initialize()
return ESP
