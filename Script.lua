-- Modern AutoSuicide Panel
-- by RafaczxHUB

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Vars
local running = false
local suicidesLeft = 0
local delayTime = 2

-- Kill function
local function killOnce()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    else
        char:BreakJoints()
    end
end

-- Loop function
local function startSuicide()
    running = true
    task.spawn(function()
        while running and (suicidesLeft > 0 or suicidesLeft == -1) do
            if not player.Character then
                player.CharacterAdded:Wait()
            end
            killOnce()
            player.CharacterAdded:Wait()
            if delayTime > 0 then task.wait(delayTime) end
            if suicidesLeft > 0 then
                suicidesLeft -= 1
            end
        end
        running = false
    end)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false

-- Tombol awal (Launch)
local launchBtn = Instance.new("TextButton", ScreenGui)
launchBtn.Size = UDim2.new(0,150,0,50)
launchBtn.Position = UDim2.new(0.5,-75,0.5,-25) -- tengah
launchBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
launchBtn.TextColor3 = Color3.fromRGB(30,30,30)
launchBtn.Font = Enum.Font.GothamBold
launchBtn.TextSize = 18
launchBtn.Text = "Open Panel"
launchBtn.AutoButtonColor = true
launchBtn.Visible = true
launchBtn.Active = true

-- Panel utama
local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(240,240,240)
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.05
frame.ClipsDescendants = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "☠ AutoSuicide Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(50,50,50)

-- Input jumlah
local repsBox = Instance.new("TextBox", frame)
repsBox.PlaceholderText = "Jumlah (0 = Infinite)"
repsBox.Size = UDim2.new(0.9,0,0,30)
repsBox.Position = UDim2.new(0.05,0,0.25,0)
repsBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
repsBox.TextColor3 = Color3.fromRGB(30,30,30)
repsBox.Text = ""
repsBox.Font = Enum.Font.Gotham
repsBox.TextSize = 14

-- Input delay
local delayBox = repsBox:Clone()
delayBox.Parent = frame
delayBox.PlaceholderText = "Delay antar suicide (detik)"
delayBox.Position = UDim2.new(0.05,0,0.45,0)

-- Tombol start
local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0.4,0,0,30)
startBtn.Position = UDim2.new(0.05,0,0.75,0)
startBtn.Text = "Start"
startBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14

-- Tombol stop
local stopBtn = startBtn:Clone()
stopBtn.Parent = frame
stopBtn.Position = UDim2.new(0.55,0,0.75,0)
stopBtn.Text = "Stop"
stopBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)

-- Events
launchBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    launchBtn.Visible = false
end)

startBtn.MouseButton1Click:Connect(function()
    local n = tonumber(repsBox.Text)
    local d = tonumber(delayBox.Text)
    suicidesLeft = (n and n > 0) and n or -1
    delayTime = (d and d >= 0) and d or 2
    if not running then
        startSuicide()
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
end)