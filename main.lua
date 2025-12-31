--[[
    FE Client Control Panel Framework (v1.0)
    Target: Client Side (LocalScript)
    Author: Gemini
    
    [説明]
    このスクリプトはクライアントサイド専用のフレームワークです。
    FE環境下では、ここでの視覚的な変更（パーツ生成など）は
    他プレイヤーには見えませんが、自分の画面での演出や
    ローカルな挙動のテストに使用できます。
    
    [拡張方法]
    "CustomFunctions" エリアに新しい機能を追加することで
    行数を無制限に増やしていくことができます。
]]

--------------------------------------------------------------------------------
-- 1. SERVICES & VARIABLES
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--------------------------------------------------------------------------------
-- 2. UI LIBRARY (CORE SYSTEM)
-- ここがスクリプトの核となり、行数の多くを占める部分です。
--------------------------------------------------------------------------------
local UILib = {}
UILib.__index = UILib

-- 画面保護（CoreGuiに配置できる場合）
local function GetScreen()
    if RunService:IsStudio() then
        return LocalPlayer:WaitForChild("PlayerGui")
    else
        -- Executor等で実行する場合、CoreGuiを使用するとリセット時も消えない
        -- ※通常のLocalScriptの場合はPlayerGuiを使用してください
        local success, result = pcall(function() return CoreGui end)
        if success then return result else return LocalPlayer:WaitForChild("PlayerGui") end
    end
end

function UILib.new(title)
    local self = setmetatable({}, UILib)
    
    -- ScreenGui作成
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FE_ControlPanel_" .. math.random(1000,9999)
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = GetScreen()
    
    -- メインフレーム
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true -- ドラッグ可能にする
    self.MainFrame.Parent = self.ScreenGui
    
    -- 角丸
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = self.MainFrame
    
    -- タイトルバー
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 40)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 18
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.MainFrame
    
    -- 閉じるボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.Parent = self.MainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- コンテナ（スクロール可能領域）
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Size = UDim2.new(1, -20, 1, -50)
    self.Container.Position = UDim2.new(0, 10, 0, 45)
    self.Container.BackgroundTransparency = 1
    self.Container.ScrollBarThickness = 6
    self.Container.Parent = self.MainFrame
    
    -- レイアウト
    self.UIListLayout = Instance.new("UIListLayout")
    self.UIListLayout.Padding = UDim.new(0, 8)
    self.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.UIListLayout.Parent = self.Container
    
    self.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, self.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    return self
end

-- ボタン作成関数
function UILib:CreateButton(text, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -10, 0, 40)
    btnFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btnFrame.Parent = self.Container
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 4)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = btnFrame
    
    btn.MouseButton1Click:Connect(function()
        -- クリックアニメーション
        local goal = {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        local tween = TweenService:Create(btnFrame, TweenInfo.new(0.1), goal)
        tween:Play()
        task.wait(0.1)
        TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        
        -- コールバック実行
        if callback then callback() end
    end)
    
    return btn
end

-- トグルスイッチ作成関数
function UILib:CreateToggle(text, default, callback)
    local toggled = default or false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = self.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 24, 0, 24)
    indicator.Position = UDim2.new(1, -34, 0.5, -12)
    indicator.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(80, 80, 80)
    indicator.Parent = frame
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 4)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        local goalColor = toggled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(80, 80, 80)
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
        if callback then callback(toggled) end
    end)
end

-- スライダー作成関数
function UILib:CreateSlider(text, min, max, default, callback)
    local value = default or min
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = self.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(value)
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)
    
    local trigger = Instance.new("TextButton")
    trigger.Size = UDim2.new(1, 0, 1, 0)
    trigger.BackgroundTransparency = 1
    trigger.Text = ""
    trigger.Parent = sliderBg
    
    local dragging = false
    
    trigger.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = mousePos - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relPos / sliderBg.AbsoluteSize.X, 0, 1)
            
            value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. tostring(value)
            
            TweenService:Create(sliderFill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            if callback then callback(value) end
        end
    end)
end

--------------------------------------------------------------------------------
-- 3. VFX MODULE (VISUAL EFFECTS)
-- クライアントサイドでのみ見えるエフェクト管理
--------------------------------------------------------------------------------
local VFXManager = {}
VFXManager.ActiveEffects = {}

function VFXManager.CreateAura(player, color)
    -- 既存のオーラを削除
    if VFXManager.ActiveEffects["Aura"] then
        VFXManager.ActiveEffects["Aura"]:Destroy()
        VFXManager.ActiveEffects["Aura"] = nil
    end
    
    local char = player.Character
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart")
    
    local auraFolder = Instance.new("Folder")
    auraFolder.Name = "ClientAura"
    auraFolder.Parent = workspace
    
    VFXManager.ActiveEffects["Aura"] = auraFolder
    
    -- 回転パーツ生成ループ
    local numParts = 6
    local radius = 5
    
    task.spawn(function()
        local parts = {}
        for i = 1, numParts do
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            p.Shape = Enum.PartType.Ball
            p.Material = Enum.Material.Neon
            p.Color = color or Color3.fromRGB(0, 255, 255)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 0.3
            p.Parent = auraFolder
            table.insert(parts, p)
            
            -- PointLight追加
            local light = Instance.new("PointLight")
            light.Color = p.Color
            light.Range = 8
            light.Brightness = 2
            light.Parent = p
        end
        
        local angle = 0
        while auraFolder.Parent and char.Parent do
            angle = angle + 2
            for i, p in ipairs(parts) do
                local currentAngle = math.rad(angle + (360 / numParts) * i)
                local offsetX = math.cos(currentAngle) * radius
                local offsetZ = math.sin(currentAngle) * radius
                local bobY = math.sin(time() * 5 + i) * 1.5
                
                -- 目標位置へTweenではなく直接セット（パフォーマンス重視）
                p.CFrame = root.CFrame * CFrame.new(offsetX, bobY, offsetZ)
            end
            RunService.Heartbeat:Wait()
        end
        
        -- クリーンアップ
        for _, p in pairs(parts) do p:Destroy() end
        auraFolder:Destroy()
    end)
end

function VFXManager.ClearAll()
    for key, obj in pairs(VFXManager.ActiveEffects) do
        if obj then obj:Destroy() end
    end
    VFXManager.ActiveEffects = {}
end

--------------------------------------------------------------------------------
-- 4. MAIN IMPLEMENTATION
-- UIと機能の結合
--------------------------------------------------------------------------------

local Window = UILib.new("GEMINI FE CONTROL PANEL")

-- === タブ: キャラクター操作 ===

Window:CreateButton("Reset Character (Respawn)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

Window:CreateSlider("WalkSpeed", 16, 200, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

Window:CreateSlider("JumpPower", 50, 500, 50, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

Window:CreateToggle("Low Gravity", false, function(state)
    if state then
        workspace.Gravity = 50
    else
        workspace.Gravity = 196.2
    end
end)

-- === タブ: ビジュアル ===

Window:CreateToggle("Active Aura (Cyan)", false, function(state)
    if state then
        VFXManager.CreateAura(LocalPlayer, Color3.fromRGB(0, 255, 255))
    else
        VFXManager.ClearAll()
    end
end)

Window:CreateToggle("Active Aura (Red)", false, function(state)
    if state then
        VFXManager.CreateAura(LocalPlayer, Color3.fromRGB(255, 50, 50))
    else
        VFXManager.ClearAll()
    end
end)

Window:CreateSlider("FOV (Field of View)", 70, 120, 70, function(val)
    Camera.FieldOfView = val
end)

-- === タブ: ワールド設定 (ローカルのみ) ===

Window:CreateButton("Time: Day", function()
    Lighting.TimeOfDay = "14:00:00"
end)

Window:CreateButton("Time: Night", function()
    Lighting.TimeOfDay = "00:00:00"
end)

Window:CreateToggle("FullBright (No Shadows)", false, function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        -- 元に戻す処理は厳密には初期値を保存する必要がありますが、簡易的にリセット
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

-- === その他機能 (ここをコピーして増やす) ===
-- 例: テレポート機能（クライアントサイドのテレポートは一部のゲームで対策されています）
Window:CreateButton("Teleport to (0, 100, 0)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
    end
end)

-- ログ出力
print("FE Control Panel Loaded successfully.")
