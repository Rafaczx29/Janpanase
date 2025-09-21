-- MENU UI Executor-Friendly
-- Paste ke Delta / executor lain (client). Auto-detect parent: gethui -> CoreGui -> PlayerGui.
-- Contains: left menu, right content panel, Auto Suicide controls (Start/Stop, jumlah, interval).
-- Drag window by header, minimize, and menu switching.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- safe parent detection
local function getSafeParent()
    local ok, g = pcall(function() return gethui() end)
    if ok and g then return g end
    if game:FindFirstChild("CoreGui") then return game.CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local parent = getSafeParent()

-- cleanup old
if parent:FindFirstChild("MenuUI_v1") then
    pcall(function() parent.MenuUI_v1:Destroy() end)
end

-- ---------- helper create ----------
local function new(inst, props)
    local o = Instance.new(inst)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then o.Parent = v else pcall(function() o[k] = v end) end
        end
    end
    return o
end

-- ---------- UI ----------
local ScreenGui = new("ScreenGui", {Name = "MenuUI_v1", Parent = parent, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

local Window = new("Frame", {
    Name = "Window",
    Parent = ScreenGui,
    Size = UDim2.new(0, 760, 0, 420),
    Position = UDim2.new(0.5, -380, 0.5, -210),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(28,28,30),
    BorderSizePixel = 0
})
new("UICorner", {Parent = Window, CornerRadius = UDim.new(0,12)})

-- Header (drag & minimize)
local Header = new("Frame", {Parent = Window, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Color3.fromRGB(36,36,38)})
new("UICorner", {Parent = Header, CornerRadius = UDim.new(0,12)})
local Title = new("TextLabel", {
    Parent = Header, Text = "Launcher Menu", TextSize = 18, Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(240,240,240), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,0), Size = UDim2.new(0.6,0,1,0), TextXAlignment = Enum.TextXAlignment.Left
})
local MinBtn = new("TextButton", {Parent = Header, Text = "–", Size = UDim2.new(0,34,1,0), Position = UDim2.new(1,-48,0,0), BackgroundColor3 = Color3.fromRGB(60,60,60), TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.GothamBold, TextSize = 20, BorderSizePixel = 0})
local CloseBtn = new("TextButton", {Parent = Header, Text = "✕", Size = UDim2.new(0,34,1,0), Position = UDim2.new(1,-16,0,0), BackgroundColor3 = Color3.fromRGB(60,60,60), TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0})

-- Body
local Body = new("Frame", {Parent = Window, Size = UDim2.new(1,0,1,-42), Position = UDim2.new(0,0,0,42), BackgroundTransparency = 1})

-- Left menu
local Menu = new("Frame", {Parent = Body, Size = UDim2.new(0,220,1,0), BackgroundColor3 = Color3.fromRGB(32,32,34)})
new("UICorner", {Parent = Menu, CornerRadius = UDim.new(0,10)})

local function makeMenuBtn(text, posY)
    local btn = new("TextButton", {
        Parent = Menu, Text = text, Size = UDim2.new(1,0,0,46), Position = UDim2.new(0,0,0,posY),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 16, BorderSizePixel = 0
    })
    local leftBar = new("Frame", {Parent = btn, Size = UDim2.new(0,6,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(0,0,0)})
    return btn, leftBar
end

local btnDash, barDash = makeMenuBtn("Dashboard", 12)
local btnAuto, barAuto = makeMenuBtn("Auto Suicide", 12 + 46 + 6)
local btnSet, barSet = makeMenuBtn("Settings", 12 + (46+6)*2)
local btnAbout, barAbout = makeMenuBtn("About", 12 + (46+6)*3)

-- Right content area
local Content = new("Frame", {Parent = Body, Size = UDim2.new(1, -220, 1, 0), Position = UDim2.new(0,220,0,0), BackgroundColor3 = Color3.fromRGB(25,25,27)})
new("UICorner", {Parent = Content, CornerRadius = UDim.new(0,10)})

-- helper to clear content
local function clearContent()
    for _,c in pairs(Content:GetChildren()) do
        if not (c:IsA("UIGridStyleLayout") or c.Name == "Padding") then
            c:Destroy()
        end
    end
end

-- ---------- Dashboard page ----------
local function openDashboard()
    clearContent()
    local lbl = new("TextLabel", {Parent = Content, Text = "Welcome to Dashboard", TextSize = 20, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240,240,240), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,16)})
    local info = new("TextLabel", {Parent = Content, Text = "Use the left menu to open features.\nThis UI is executor-friendly (tries gethui -> CoreGui -> PlayerGui).", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,56)})
end

-- ---------- Auto Suicide page ----------
local suicideState = {running = false, counter = 0}
local function openAuto()
    clearContent()
    -- title
    new("TextLabel", {Parent = Content, Text = "Auto Suicide", TextSize = 20, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240,240,240), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,16)})
    -- description
    new("TextLabel", {Parent = Content, Text = "Kill & respawn automatically. Use only for testing.", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,48)})
    -- input jumlah
    new("TextLabel", {Parent = Content, Text = "Jumlah (0 = infinite):", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,90)})
    local boxAmount = new("TextBox", {Parent = Content, Text = "0", PlaceholderText = "0", Size = UDim2.new(0,220,0,30), Position = UDim2.new(0,16,0,116), BackgroundColor3 = Color3.fromRGB(36,36,38), TextColor3 = Color3.fromRGB(240,240,240), ClearTextOnFocus = false, BorderSizePixel = 0})
    new("UICorner", {Parent = boxAmount, CornerRadius = UDim.new(0,6)})
    -- input interval
    new("TextLabel", {Parent = Content, Text = "Interval (detik):", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Position = UDim2.new(0,260,0,90)})
    local boxInterval = new("TextBox", {Parent = Content, Text = "2", PlaceholderText = "2", Size = UDim2.new(0,120,0,30), Position = UDim2.new(0,260,0,116), BackgroundColor3 = Color3.fromRGB(36,36,38), TextColor3 = Color3.fromRGB(240,240,240), ClearTextOnFocus = false, BorderSizePixel = 0})
    new("UICorner", {Parent = boxInterval, CornerRadius = UDim.new(0,6)})
    -- status
    local status = new("TextLabel", {Parent = Content, Text = "Status: Idle", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,160)})
    -- buttons
    local startBtn = new("TextButton", {Parent = Content, Text = "Start", Size = UDim2.new(0,140,0,36), Position = UDim2.new(0,16,0,196), BackgroundColor3 = Color3.fromRGB(0,150,0), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(240,240,240), BorderSizePixel = 0})
    new("UICorner", {Parent = startBtn, CornerRadius = UDim.new(0,6)})
    local stopBtn = new("TextButton", {Parent = Content, Text = "Stop", Size = UDim2.new(0,140,0,36), Position = UDim2.new(0,168,0,196), BackgroundColor3 = Color3.fromRGB(150,0,0), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(240,240,240), BorderSizePixel = 0})
    new("UICorner", {Parent = stopBtn, CornerRadius = UDim.new(0,6)})

    -- suicide logic (use user's tested method)
    local function killOnce()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            pcall(function() humanoid.Health = 0 end)
            return
        end
        if char.PrimaryPart then
            pcall(function() char:BreakJoints() end)
            return
        end
        for _,p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") then
                pcall(function() p:BreakJoints() end)
                break
            end
        end
    end

    local runner = nil
    startBtn.MouseButton1Click:Connect(function()
        if runner then return end
        local reps = tonumber(boxAmount.Text) or 0
        local interval = tonumber(boxInterval.Text) or 2
        local counter = 0
        status.Text = "Status: Running (0/" .. (reps==0 and "∞" or tostring(reps)) .. ")"
        runner = true
        spawn(function()
            if reps == 0 then
                while runner do
                    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
                    killOnce()
                    counter = counter + 1
                    status.Text = "Status: Running ("..counter.."/∞)"
                    LocalPlayer.CharacterAdded:Wait()
                    local elapsed = 0
                    while runner and elapsed < interval do task.wait(0.1); elapsed = elapsed + 0.1 end
                end
            else
                for i=1,reps do
                    if not runner then break end
                    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
                    killOnce()
                    counter = counter + 1
                    status.Text = "Status: Running ("..counter.."/"..tostring(reps)..")"
                    LocalPlayer.CharacterAdded:Wait()
                    local elapsed = 0
                    while runner and elapsed < interval do task.wait(0.1); elapsed = elapsed + 0.1 end
                end
            end
            runner = nil
            if not runner then status.Text = "Status: Idle" end
        end)
    end)
    stopBtn.MouseButton1Click:Connect(function()
        runner = nil
        status.Text = "Status: Stopped"
    end)
end

-- ---------- Settings page ----------
local function openSettings()
    clearContent()
    new("TextLabel", {Parent = Content, Text = "Settings", TextSize = 20, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240,240,240), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,16)})
    new("TextLabel", {Parent = Content, Text = "No special settings yet. This panel reserved for future options.", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,56)})
end

-- ---------- About page ----------
local function openAbout()
    clearContent()
    new("TextLabel", {Parent = Content, Text = "About", TextSize = 20, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240,240,240), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,16)})
    new("TextLabel", {Parent = Content, Text = "Executor Menu v1 — UI tries to be compatible with common executors.\nMade for testing only.", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Position = UDim2.new(0,16,0,56)})
end

-- ---------- menu behaviour ----------
local function resetBars()
    for _,b in ipairs({barDash, barAuto, barSet, barAbout}) do
        pcall(function() b.BackgroundColor3 = Color3.fromRGB(0,0,0); b.Size = UDim2.new(0,6,1,0) end)
    end
end

btnDash.MouseButton1Click:Connect(function() resetBars(); barDash.BackgroundColor3 = Color3.fromRGB(0,170,255); openDashboard() end)
btnAuto.MouseButton1Click:Connect(function() resetBars(); barAuto.BackgroundColor3 = Color3.fromRGB(0,170,0); openAuto() end)
btnSet.MouseButton1Click:Connect(function() resetBars(); barSet.BackgroundColor3 = Color3.fromRGB(255,170,0); openSettings() end)
btnAbout.MouseButton1Click:Connect(function() resetBars(); barAbout.BackgroundColor3 = Color3.fromRGB(180,180,180); openAbout() end)

-- default page
resetBars(); barDash.BackgroundColor3 = Color3.fromRGB(0,170,255); openDashboard()

-- ---------- drag logic (header) ----------
local dragging = false; local dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- minimize / close buttons
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,c in pairs(Window:GetChildren()) do
        if c ~= Header then c.Visible = not minimized end
    end
    MinBtn.Text = minimized and "+" or "–"
    if minimized then
        TweenService:Create(Window, TweenInfo.new(0.18), {Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, 44)}):Play()
    else
        TweenService:Create(Window, TweenInfo.new(0.18), {Size = UDim2.new(0,760,0,420)}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    pcall(function() ScreenGui:Destroy() end)
end)

-- bring to front on click
Window.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ScreenGui.Parent = parent -- re-parent to ensure top
    end
end)

-- debug print (executor console)
pcall(function() print("MenuUI_v1 loaded. Parent: ".. tostring(parent)) end)