getgenv().Config = {
    Key = "cuahangrandom",
    Team = "Pirates",
    Farm = { AutoFarm=true, TweenSpeed=300, ReachDistance=30, EnemyGomDistance=120 },
    Kaitun = { AutoKaitun=true, UseSword=false, UseGun=false },
    Fruits = { AutoRandomFruit=true, CandyLimit=100, AutoPick=true, AutoStore=true, RareFruits={"Dragon","Leopard","Dough","Spirit","Kitsune"} },
    Items = { AutoPick=true, RareItemsPriority={"CursedDualKatana","SoulGuitar","Mirror","MirrorPiece","Tiki","Hat","Saber"} },
    Stats = { AutoAdd=true, MaxMelee=1200, MaxDefense=800, MaxSpeed=200, MaxSword=1200 },
    System = { AutoFly=true, FlyHeight=25, BlackScreen=false, FPSBoost=true, AntiAFK=true, AutoHop=true, HopDelay=3600 }
}

local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "DRKeyGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,150)
Frame.Position = UDim2.new(0.5,-150,0.5,-75)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true

local Text = Instance.new("TextLabel", Frame)
Text.Size = UDim2.new(1,0,0,50)
Text.Position = UDim2.new(0,0,0,10)
Text.BackgroundTransparency = 1
Text.Text = "Nhập Key để chạy script"
Text.TextColor3 = Color3.fromRGB(0,255,170)
Text.Font = Enum.Font.GothamBold
Text.TextSize = 16

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1,-20,0,35)
TextBox.Position = UDim2.new(0,10,0,60)
TextBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
TextBox.TextColor3 = Color3.fromRGB(255,255,255)
TextBox.ClearTextOnFocus = false
TextBox.Text = ""

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1,-20,0,35)
Button.Position = UDim2.new(0,10,0,105)
Button.BackgroundColor3 = Color3.fromRGB(0,170,255)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Text = "Xác nhận Key"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14

local function StartScript()
    ScreenGui:Destroy()
    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local TS = game:GetService("TweenService")
    local TP = game:GetService("TeleportService")
    local VU = game:GetService("VirtualUser")
    local RunService = game:GetService("RunService")
    local P = Players.LocalPlayer
    repeat task.wait() until P.Character
    local C = P.Character
    local HRP = C:WaitForChild("HumanoidRootPart")

    pcall(function() RS.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Config.Team) end)

    if getgenv().Config.System.FPSBoost then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Transparency = 0.5
            end
        end
        game.Lighting.GlobalShadows = false
    end

    if getgenv().Config.System.AntiAFK then
        P.Idled:Connect(function()
            VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end

    local function TweenTo(cf)
        local d = (HRP.Position - cf.Position).Magnitude
        if d > 3 then
            local target = cf
            if getgenv().Config.System.AutoFly then
                target = CFrame.new(cf.Position.X, cf.Position.Y + getgenv().Config.System.FlyHeight, cf.Position.Z)
            end
            local t = TS:Create(HRP, TweenInfo.new(d/getgenv().Config.Farm.TweenSpeed, Enum.EasingStyle.Linear), {CFrame=target})
            t:Play()
            t.Completed:Wait()
        end
    end

    task.spawn(function()
        while getgenv().Config.Stats.AutoAdd do
            pcall(function()
                local stats = P.leaderstats
                if stats.Melee.Value < getgenv().Config.Stats.MaxMelee then
                    RS.Remotes.CommF_:InvokeServer("AddPoint","Melee")
                elseif stats.Defense.Value < getgenv().Config.Stats.MaxDefense then
                    RS.Remotes.CommF_:InvokeServer("AddPoint","Defense")
                elseif stats.Speed.Value < getgenv().Config.Stats.MaxSpeed then
                    RS.Remotes.CommF_:InvokeServer("AddPoint","Speed")
                elseif stats.Sword.Value < getgenv().Config.Stats.MaxSword then
                    RS.Remotes.CommF_:InvokeServer("AddPoint","Sword")
                end
            end)
            task.wait(1)
        end
    end)

    task.spawn(function()
        while getgenv().Config.Fruits.AutoRandomFruit do
            pcall(function()
                local candy = P.leaderstats:FindFirstChild("Candy")
                if candy and candy.Value >= getgenv().Config.Fruits.CandyLimit then
                    RS.Remotes.CommF_:InvokeServer("Candies","Buy","RandomFruit")
                    task.wait(1)
                    for _,f in pairs(workspace:GetChildren()) do
                        if f:IsA("Tool") and table.find(getgenv().Config.Fruits.RareFruits,f.Name) and f:FindFirstChild("Handle") then
                            TweenTo(f.Handle.CFrame)
                            RS.Remotes.CommF_:InvokeServer("StoreFruit",f.Name,f)
                        end
                    end
                end
            end)
            task.wait(10)
        end
    end)

    task.spawn(function()
        while getgenv().Config.Items.AutoPick do
            pcall(function()
                for _,obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") and table.find(getgenv().Config.Items.RareItemsPriority,obj.Name) and obj:FindFirstChild("Handle") then
                        TweenTo(obj.Handle.CFrame)
                        RS.Remotes.CommF_:InvokeServer("StoreFruit",obj.Name,obj)
                    end
                end
            end)
            task.wait(2)
        end
    end)

    task.spawn(function()
        while getgenv().Config.Farm.AutoFarm do
            pcall(function()
                local lv = P.leaderstats.Level.Value
                if lv < 700 then
                    RS.Remotes.CommF_:InvokeServer("StartQuest","MarineQuestLv1")
                elseif lv < 1500 then
                    RS.Remotes.CommF_:InvokeServer("StartQuest","DressrosaQuest")
                else
                    RS.Remotes.CommF_:InvokeServer("StartQuest","ZouQuest")
                end
            end)
            task.wait(5)
        end
    end)

    task.spawn(function()
        while getgenv().Config.System.AutoHop do
            task.wait(getgenv().Config.System.HopDelay)
            TP:Teleport(game.PlaceId,P)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if getgenv().Config.Farm.AutoFarm and getgenv().Config.Kaitun.AutoKaitun then
            local EnemiesNearby = {}
            for _,m in pairs(workspace.Enemies:GetChildren()) do
                if m:FindFirstChild("HumanoidRootPart") and m.Humanoid.Health > 0 then
                    local dist = (HRP.Position - m.HumanoidRootPart.Position).Magnitude
                    if dist <= getgenv().Config.Farm.EnemyGomDistance then
                        table.insert(EnemiesNearby, m)
                    end
                end
            end
            if #EnemiesNearby > 0 then
                local center = Vector3.new(0,0,0)
                for _,e in pairs(EnemiesNearby) do
                    center = center + e.HumanoidRootPart.Position
                end
                center = center / #EnemiesNearby
                TS:Create(HRP, TweenInfo.new((HRP.Position - center).Magnitude/getgenv().Config.Farm.TweenSpeed, Enum.EasingStyle.Linear), {CFrame=CFrame.new(center + Vector3.new(0,0,6))}):Play()
                for _,e in pairs(EnemiesNearby) do
                    RS.Remotes.CommF_:InvokeServer("Attack", e)
                end
            end
        end
    end)
end

Button.MouseButton1Click:Connect(function()
    if TextBox.Text == getgenv().Config.Key then
        StartScript()
    else
        Text.Text = "Key sai!"
        Text.TextColor3 = Color3.fromRGB(255,50,50)
    end
end)