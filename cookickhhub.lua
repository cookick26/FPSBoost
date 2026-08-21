local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

-- 실시간 설정 변수
local Settings = {
    FOV = 100,
    MULTIPLIER = 5,
    Enabled = true,
    ESPEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2,
    ToggleKey = Enum.KeyCode.Equals,
    TargetPart = "Head",
    ESPDistance = 400,
    AimbotDistance = 400,
    ShowESPName = true,
    ShowESPBox = true,
    ShowESPHealth = true,
    ShowESPDistance = true,
    -- 히트박스 설정
    HitboxSize = 5,
    HitboxTransparency = 0,
    HitboxColor = Color3.fromRGB(255, 255, 255),
    HitboxEnabled = false,
    -- 에임봇 모드
    AimbotMode = "HOLD" -- "HOLD" 또는 "TOGGLE"
}

local UiVisible = true
local WaitingForKeyPress = false
local AimbotActive = false

----------------------------------------------------------------                
-- 1. FOV 시각화 원(Drawing) 설정
----------------------------------------------------------------
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(105, 12, 12)
FovCircle.Thickness = 3
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Transparency = 0.5
FovCircle.Visible = UiVisible

----------------------------------------------------------------                
-- 2. GUI 생성 (Cookick Hub)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimSettingsUI"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 700)
Frame.AnchorPoint = Vector2.new(0.5, 0.5) 
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true 
Frame.Visible = UiVisible
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = " Cookick Hub "
Title.TextColor3 = Color3.fromRGB(105, 12, 12)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- 공통 슬라이더 생성 함수
local function createSlider(text, min, max, default, posY, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Text = text .. " : " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(105, 12, 12)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = Frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 0, posY + 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = Frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 16, 0, 16)
    sliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderBtn.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBg

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = sliderBtn

    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and UiVisible then
            local mouseX = UserInputService:GetMouseLocation().X
            local relativeX = mouseX - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
            sliderBtn.Position = UDim2.new(percent, 0, 0.5, 0)
            
            local value = math.floor(min + (percent * (max - min)))
            label.Text = text .. " : " .. tostring(value)
            callback(value)
        end
    end)
end

-- 체크박스 생성 함수
local function createCheckbox(text, default, posY, callback)
    local checkboxContainer = Instance.new("Frame")
    checkboxContainer.Size = UDim2.new(1, -20, 0, 28)
    checkboxContainer.Position = UDim2.new(0, 10, 0, posY)
    checkboxContainer.BackgroundTransparency = 1
    checkboxContainer.Parent = Frame

    local checkbox = Instance.new("Frame")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = default and Color3.fromRGB(105, 12, 12) or Color3.fromRGB(60, 60, 60)
    checkbox.BorderSizePixel = 0
    checkbox.Parent = checkboxContainer

    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 3)
    checkboxCorner.Parent = checkbox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 0, 20)
    label.Position = UDim2.new(0, 30, 0.5, -10)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Parent = checkboxContainer

    local isChecked = default

    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = checkboxContainer

    clickButton.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        
        if isChecked then
            checkbox.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        
        callback(isChecked)
    end)
end

-- 1. FOV 슬라이더
createSlider("FOV SIZE", 10, 500, Settings.FOV, 35, function(val)
    Settings.FOV = val
end)

-- 2. 스무스 슬라이더
createSlider("SMOOTHING", 1, 15, Settings.MULTIPLIER, 85, function(val)
    Settings.MULTIPLIER = val
end)

-- 3. ESP 거리 제한 슬라이더
createSlider("ESP DISTANCE", 10, 5000, Settings.ESPDistance, 135, function(val)
    Settings.ESPDistance = val
end)

-- 4. 에임봇 거리 제한 슬라이더
createSlider("AIMBOT DISTANCE", 100, 5000, Settings.AimbotDistance, 185, function(val)
    Settings.AimbotDistance = val
end)

-- 5. 히트박스 크기 슬라이더
createSlider("HITBOX SIZE", 1, 100, Settings.HitboxSize, 235, function(val)
    Settings.HitboxSize = val
end)

-- 6. 히트박스 투명도 토글 버튼
local TransLabel = Instance.new("TextLabel")
TransLabel.Size = UDim2.new(1, -20, 0, 20)
TransLabel.Position = UDim2.new(0, 10, 0, 285)
TransLabel.Text = "HITBOX TRANS : " .. tostring(Settings.HitboxTransparency)
TransLabel.TextColor3 = Color3.fromRGB(105, 12, 12)
TransLabel.BackgroundTransparency = 1
TransLabel.TextXAlignment = Enum.TextXAlignment.Left
TransLabel.Font = Enum.Font.SourceSans
TransLabel.TextSize = 16
TransLabel.Parent = Frame

local TransToggleButton = Instance.new("TextButton")
TransToggleButton.Size = UDim2.new(1, -20, 0, 22)
TransToggleButton.Position = UDim2.new(0, 10, 0, 307)
TransToggleButton.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
TransToggleButton.Text = "TOGGLE TRANSPARENCY"
TransToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TransToggleButton.Font = Enum.Font.SourceSansBold
TransToggleButton.TextSize = 13
TransToggleButton.Parent = Frame

local TransButtonCorner = Instance.new("UICorner")
TransButtonCorner.CornerRadius = UDim.new(0, 5)
TransButtonCorner.Parent = TransToggleButton

TransToggleButton.MouseButton1Click:Connect(function()
    if Settings.HitboxTransparency == 0 then
        Settings.HitboxTransparency = 1
        TransLabel.Text = "HITBOX TRANS : 1"
    else
        Settings.HitboxTransparency = 0
        TransLabel.Text = "HITBOX TRANS : 0"
    end
end)

-- 7. AIM KEY 설정 버튼
local AimKeyLabel = Instance.new("TextLabel")
AimKeyLabel.Size = UDim2.new(1, -20, 0, 20)
AimKeyLabel.Position = UDim2.new(0, 10, 0, 340)
AimKeyLabel.Text = "AIM KEY : RMB"
AimKeyLabel.TextColor3 = Color3.fromRGB(105, 12, 12)
AimKeyLabel.BackgroundTransparency = 1
AimKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
AimKeyLabel.Font = Enum.Font.SourceSans
AimKeyLabel.TextSize = 16
AimKeyLabel.Parent = Frame

local AimKeyButton = Instance.new("TextButton")
AimKeyButton.Size = UDim2.new(1, -20, 0, 22)
AimKeyButton.Position = UDim2.new(0, 10, 0, 362)
AimKeyButton.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
AimKeyButton.Text = "PRESS TO SET KEY"
AimKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimKeyButton.Font = Enum.Font.SourceSansBold
AimKeyButton.TextSize = 13
AimKeyButton.Parent = Frame

local AimKeyButtonCorner = Instance.new("UICorner")
AimKeyButtonCorner.CornerRadius = UDim.new(0, 5)
AimKeyButtonCorner.Parent = AimKeyButton

-- 8. AIMBOT MODE 토글 버튼
local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, -20, 0, 20)
ModeLabel.Position = UDim2.new(0, 10, 0, 395)
ModeLabel.Text = "AIMBOT MODE : " .. Settings.AimbotMode
ModeLabel.TextColor3 = Color3.fromRGB(105, 12, 12)
ModeLabel.BackgroundTransparency = 1
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Font = Enum.Font.SourceSans
ModeLabel.TextSize = 16
ModeLabel.Parent = Frame

local ModeButton = Instance.new("TextButton")
ModeButton.Size = UDim2.new(1, -20, 0, 22)
ModeButton.Position = UDim2.new(0, 10, 0, 417)
ModeButton.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
ModeButton.Text = "SWITCH TO TOGGLE"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.Font = Enum.Font.SourceSansBold
ModeButton.TextSize = 13
ModeButton.Parent = Frame

local ModeButtonCorner = Instance.new("UICorner")
ModeButtonCorner.CornerRadius = UDim.new(0, 5)
ModeButtonCorner.Parent = ModeButton

ModeButton.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "HOLD" then
        Settings.AimbotMode = "TOGGLE"
        ModeLabel.Text = "AIMBOT MODE : TOGGLE"
        ModeButton.Text = "SWITCH TO HOLD"
        AimbotActive = false
    else
        Settings.AimbotMode = "HOLD"
        ModeLabel.Text = "AIMBOT MODE : HOLD"
        ModeButton.Text = "SWITCH TO TOGGLE"
        AimbotActive = false
    end
end)

-- 키 이름 변환 함수
local function getKeyName(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        return "LMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        return "RMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        return "MMB"
    elseif input.KeyCode then
        return input.KeyCode.Name
    end
    return "UNKNOWN"
end

AimKeyButton.MouseButton1Click:Connect(function()
    WaitingForKeyPress = true
    AimKeyButton.Text = "WAITING FOR INPUT..."
    AimKeyButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if WaitingForKeyPress and not gameProcessed then
        Settings.AimKey = input.UserInputType
        if input.KeyCode then
            Settings.AimKey = input.KeyCode
        end
        
        local keyName = getKeyName(input)
        AimKeyLabel.Text = "AIM KEY : " .. keyName
        AimKeyButton.Text = "PRESS TO SET KEY"
        AimKeyButton.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
        WaitingForKeyPress = false
    end
    
    if not gameProcessed and input.KeyCode == Settings.ToggleKey then
        UiVisible = not UiVisible
        Frame.Visible = UiVisible       
        FovCircle.Visible = UiVisible   
    end

    -- 토글 모드에서 키 입력 감지
    if Settings.AimbotMode == "TOGGLE" and not gameProcessed and not WaitingForKeyPress then
        local isAimKey = false
        if typeof(Settings.AimKey) == "EnumItem" and Settings.AimKey.EnumType == Enum.KeyCode then
            isAimKey = (input.KeyCode == Settings.AimKey)
        elseif typeof(Settings.AimKey) == "EnumItem" and Settings.AimKey.EnumType == Enum.UserInputType then
            isAimKey = (input.UserInputType == Settings.AimKey)
        end
        
        if isAimKey then
            AimbotActive = not AimbotActive
        end
    end
end)

-- 9. AIM PART 선택 버튼
local PartLabel = Instance.new("TextLabel")
PartLabel.Size = UDim2.new(1, -20, 0, 20)
PartLabel.Position = UDim2.new(0, 10, 0, 450)
PartLabel.Text = "AIM PART : " .. tostring(Settings.TargetPart)
PartLabel.TextColor3 = Color3.fromRGB(105, 12, 12)
PartLabel.BackgroundTransparency = 1
PartLabel.TextXAlignment = Enum.TextXAlignment.Left
PartLabel.Font = Enum.Font.SourceSans
PartLabel.TextSize = 16
PartLabel.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 22)
ToggleButton.Position = UDim2.new(0, 10, 0, 472)
ToggleButton.BackgroundColor3 = Color3.fromRGB(105, 12, 12)
ToggleButton.Text = "SWITCH TO BODY"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 13
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    if Settings.TargetPart == "Head" then
        Settings.TargetPart = "Body"
        PartLabel.Text = "AIM PART : BODY"
        ToggleButton.Text = "SWITCH TO HEAD"
    else
        Settings.TargetPart = "Head"
        PartLabel.Text = "AIM PART : HEAD"
        ToggleButton.Text = "SWITCH TO BODY"
    end
end)

-- 체크박스들
createCheckbox("Show Name", Settings.ShowESPName, 505, function(val)
    Settings.ShowESPName = val
end)

createCheckbox("Show Box", Settings.ShowESPBox, 543, function(val)
    Settings.ShowESPBox = val
end)

createCheckbox("Show Health", Settings.ShowESPHealth, 581, function(val)
    Settings.ShowESPHealth = val
end)

createCheckbox("Show Distance", Settings.ShowESPDistance, 619, function(val)
    Settings.ShowESPDistance = val
end)

createCheckbox("Hitbox Enabled", Settings.HitboxEnabled, 657, function(val)
    Settings.HitboxEnabled = val
end)

----------------------------------------------------------------                
-- 3. ESP 로직 (거리 표시만)
----------------------------------------------------------------
local function ESP(player)
    local DrawObject = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthOutline = Drawing.new("Line")
    }

    RunService.RenderStepped:Connect(function()
        local Character = player.Character

        if Settings.ESPEnabled and Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local LocalHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if HumanoidRootPart and Humanoid and Humanoid.Health > 0 and LocalHRP then
                local distance = (HumanoidRootPart.Position - LocalHRP.Position).Magnitude
                
                if distance <= Settings.ESPDistance then
                    local Position, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                    if OnScreen and Position.Z > 0 then
                        local scale = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                        local width, height = math.floor(4.5 * scale), math.floor(6 * scale)
                        local x, y = math.floor(Position.X), math.floor(Position.Y)
                        local xPosition, yPosition = math.floor(x - width * 0.5), math.floor((y - height * 0.5) + (0.5 * scale))

                        if Settings.ShowESPBox then
                            DrawObject.Box.Size = Vector2.new(width, height)
                            DrawObject.Box.Position = Vector2.new(xPosition, yPosition)
                            DrawObject.Box.Visible = true
                            DrawObject.Box.Color = Color3.fromRGB(255, 255, 255)
                            DrawObject.Box.Thickness = 1

                            DrawObject.BoxOutline.Size = Vector2.new(width, height)
                            DrawObject.BoxOutline.Position = Vector2.new(xPosition, yPosition)
                            DrawObject.BoxOutline.Visible = true
                            DrawObject.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
                            DrawObject.BoxOutline.Thickness = 2
                            DrawObject.BoxOutline.ZIndex = 1
                            DrawObject.Box.ZIndex = 2
                        else
                            DrawObject.Box.Visible = false
                            DrawObject.BoxOutline.Visible = false
                        end

                        -- 거리 표시 (닉 위에)
                        if Settings.ShowESPName and Settings.ShowESPDistance then
                            DrawObject.Distance.Text = "Dis : " .. math.floor(distance)
                            DrawObject.Distance.Size = 14
                            DrawObject.Distance.Center = true
                            DrawObject.Distance.Outline = true
                            DrawObject.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
                            DrawObject.Distance.Color = Color3.fromRGB(255, 255, 255)
                            DrawObject.Distance.Position = Vector2.new(xPosition + (width / 2), yPosition - 30)
                            DrawObject.Distance.Visible = true
                            DrawObject.Distance.ZIndex = 3
                        else
                            DrawObject.Distance.Visible = false
                        end

                        if Settings.ShowESPName then
                            DrawObject.Name.Text = player.Name
                            DrawObject.Name.Size = 14
                            DrawObject.Name.Center = true
                            DrawObject.Name.Outline = true
                            DrawObject.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                            DrawObject.Name.Color = Color3.fromRGB(255, 255, 255)
                            DrawObject.Name.Position = Vector2.new(xPosition + (width / 2), yPosition - 16)
                            DrawObject.Name.Visible = true
                            DrawObject.Name.ZIndex = 3
                        else
                            DrawObject.Name.Visible = false
                        end

                        if Settings.ShowESPHealth then
                            local healthPercent = 100 / (Humanoid.MaxHealth / Humanoid.Health)
                            
                            DrawObject.HealthOutline.From = Vector2.new(xPosition - 3, yPosition)
                            DrawObject.HealthOutline.To = Vector2.new(xPosition - 3, yPosition + height)
                            DrawObject.Health.From = Vector2.new(xPosition - 3, (yPosition + height) - 1)
                            DrawObject.Health.To = Vector2.new(xPosition - 3, ((DrawObject.Health.From.Y - ((height / 100) * healthPercent))) + 2)
                            
                            DrawObject.Health.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), healthPercent * 0.01)
                            DrawObject.HealthOutline.Color = Color3.new(0,0,0)
                            
                            DrawObject.Health.Thickness = 3
                            DrawObject.HealthOutline.Thickness = 2
                            
                            DrawObject.Health.ZIndex = 2
                            DrawObject.HealthOutline.ZIndex = 1
                            
                            DrawObject.Health.Visible = true
                            DrawObject.HealthOutline.Visible = true
                        else
                            DrawObject.Health.Visible = false
                            DrawObject.HealthOutline.Visible = false
                        end
                        return
                    end
                end
            end
        end

        DrawObject.Box.Visible = false
        DrawObject.BoxOutline.Visible = false
        DrawObject.Distance.Visible = false
        DrawObject.Name.Visible = false
        DrawObject.Health.Visible = false
        DrawObject.HealthOutline.Visible = false
    end)
end

for _, v in pairs(PlayerService:GetPlayers()) do
    if v ~= LocalPlayer then
        ESP(v)
    end
end

PlayerService.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        ESP(v)
    end
end)

----------------------------------------------------------------                
-- 4. 에임봇 로직 (홀드/토글 모드)
----------------------------------------------------------------
local function getClosest()
    local target = nil
    local shortestDist = Settings.FOV 
    local mousePos = UserInputService:GetMouseLocation()
    local LocalHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, p in pairs(PlayerService:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            local aimPart = nil
            if Settings.TargetPart == "Head" then
                aimPart = p.Character:FindFirstChild("Head")
            else
                aimPart = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            end
            
            if aimPart and hum and hum.Health > 0 and LocalHRP then
                local distance = (aimPart.Position - LocalHRP.Position).Magnitude
                
                if distance <= Settings.AimbotDistance then
                    local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            target = pos
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    FovCircle.Position = mousePos
    FovCircle.Radius = Settings.FOV
    
    local isAimKeyPressed = false
    
    if Settings.AimbotMode == "HOLD" then
        -- 홀드 모드
        if typeof(Settings.AimKey) == "EnumItem" and Settings.AimKey.EnumType == Enum.KeyCode then
            isAimKeyPressed = UserInputService:IsKeyDown(Settings.AimKey)
        elseif typeof(Settings.AimKey) == "EnumItem" and Settings.AimKey.EnumType == Enum.UserInputType then
            isAimKeyPressed = UserInputService:IsMouseButtonPressed(Settings.AimKey)
        end
    else
        -- 토글 모드
        isAimKeyPressed = AimbotActive
    end
    
    if isAimKeyPressed then
        local targetPos = getClosest()
        if targetPos then
            local diffX = targetPos.X - mousePos.X
            local diffY = targetPos.Y - mousePos.Y
            
            local finalDiffX = (diffX * Settings.MULTIPLIER)
            local finalDiffY = (diffY * Settings.MULTIPLIER)
            
            mousemoverel(finalDiffX, finalDiffY)
        end
    end
end)

----------------------------------------------------------------                
-- 5. 히트박스 로직 (체크박스 활성화 시에만 작동)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    for _, v in pairs(PlayerService:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local targetPart = v.Character:FindFirstChild(Settings.TargetPart)
            
            if targetPart then
                pcall(function()
                    if Settings.HitboxEnabled then
                        -- 히트박스 활성화 시
                        targetPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        targetPart.Transparency = Settings.HitboxTransparency
                        targetPart.Color = Settings.HitboxColor
                        targetPart.Material = Enum.Material.Neon
                        targetPart.CanCollide = false
                        targetPart.Massless = true
                        
                        if Settings.TargetPart == "Head" then
                            local face = targetPart:FindFirstChild("face") or targetPart:FindFirstChild("Face")
                            if face and face:IsA("Decal") then
                                face.Transparency = Settings.HitboxTransparency
                            end
                        end
                    else
                        -- 히트박스 비활성화 시 원래 크기로 복원
                        targetPart.Size = Vector3.new(1, 1, 1)
                        targetPart.Transparency = 0
                        targetPart.Material = Enum.Material.SmoothPlastic
                        targetPart.CanCollide = true
                        targetPart.Massless = false
                        
                        if Settings.TargetPart == "Head" then
                            local face = targetPart:FindFirstChild("face") or targetPart:FindFirstChild("Face")
                            if face and face:IsA("Decal") then
                                face.Transparency = 0
                            end
                        end
                    end
                end)
            end
        end
    end
end)
