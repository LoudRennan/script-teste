--[[
    Script Basico: Fly, Noclip, Speed + UI
    Como usar: coloque como LocalScript dentro de StarterPlayerScripts
    (ou execute via um executor, se for para uso proprio/teste)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ===== ESTADOS =====
local flying = false
local noclipping = false
local speedOn = false

local flySpeed = 50
local walkSpeedValue = 16
local fastSpeedValue = 60

local flyConnection = nil
local noclipConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- Recarrega referencias quando o personagem renasce
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    flying = false
    noclipping = false
    speedOn = false
end)

-- ===== FUNCAO: FLY =====
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

local function toggleFly(state)
    flying = state
    if flying then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1,1,1) * math.huge
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = rootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1,1,1) * math.huge
        bodyGyro.P = 10000
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)

            if flyKeys.W then moveDir += cam.CFrame.LookVector end
            if flyKeys.S then moveDir -= cam.CFrame.LookVector end
            if flyKeys.A then moveDir -= cam.CFrame.RightVector end
            if flyKeys.D then moveDir += cam.CFrame.RightVector end
            if flyKeys.Space then moveDir += Vector3.new(0,1,0) end
            if flyKeys.Shift then moveDir -= Vector3.new(0,1,0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * flySpeed
            end

            bodyVelocity.Velocity = moveDir
            bodyGyro.CFrame = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
end)

-- ===== FUNCAO: NOCLIP =====
local function toggleNoclip(state)
    noclipping = state
    if noclipping then
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ===== FUNCAO: SPEED =====
local function toggleSpeed(state)
    speedOn = state
    humanoid.WalkSpeed = speedOn and fastSpeedValue or walkSpeedValue
end

-- ================= UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "MenuBasico"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Paleta de azul celeste
local corFundo = Color3.fromRGB(235, 247, 255)
local corPrimaria = Color3.fromRGB(56, 176, 255)
local corPrimariaEscura = Color3.fromRGB(30, 144, 235)
local corTexto = Color3.fromRGB(20, 40, 60)
local corToggleOff = Color3.fromRGB(210, 230, 245)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 260)
mainFrame.Position = UDim2.new(0, 20, 0.5, -130)
mainFrame.BackgroundColor3 = corFundo
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = corPrimaria
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Sombra leve (usando outro frame atras)
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 8, 1, 8)
shadow.Position = UDim2.new(0, -4, 0, -4)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.88
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowCorner.Parent = shadow

-- Cabecalho
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = corPrimaria
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = corPrimaria
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Menu Basico"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Botao de minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -36, 0, 8)
minimizeBtn.Parent = header

-- Arrastar a janela
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Container dos toggles
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -24, 1, -60)
content.Position = UDim2.new(0, 12, 0, 54)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = content

-- Funcao para criar cada linha de toggle
local function criarToggle(nome, ordem, callback)
    local row = Instance.new("Frame")
    row.Name = nome
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.LayoutOrder = ordem
    row.Parent = content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(220, 235, 248)
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Text = nome
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextColor3 = corTexto
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -76, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 48, 0, 26)
    toggleBg.Position = UDim2.new(1, -62, 0.5, -13)
    toggleBg.BackgroundColor3 = corToggleOff
    toggleBg.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickBtn = Instance.new("TextButton")
    clickBtn.Text = ""
    clickBtn.BackgroundTransparency = 1
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Parent = toggleBg

    local state = false
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)

        local corAlvo = state and corPrimariaEscura or corToggleOff
        local posAlvo = state and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)

        TweenService:Create(toggleBg, TweenInfo.new(0.18), {BackgroundColor3 = corAlvo}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {Position = posAlvo}):Play()
    end)

    return row
end

criarToggle("Fly", 1, function(state) toggleFly(state) end)
criarToggle("Noclip", 2, function(state) toggleNoclip(state) end)
criarToggle("Speed", 3, function(state) toggleSpeed(state) end)

-- Minimizar/expandir
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local altura = minimized and 46 or 260
    TweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 260, 0, altura)}):Play()
    content.Visible = not minimized
end)
