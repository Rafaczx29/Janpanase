--[[ 
    ================================================
    MOUNT TARANJANG AUTO SUMMIT - STELLAR SINGLE TAB
    LOGIKA BARU: Teleport -> Reset -> Delay (Patokan user).
    Urutan: Teleport ke Summit -> 2 Detik Jeda -> Reset Karakter -> Wait Respawn -> Delay.
    ================================================
]]

-- UBAH INI SESUAI KEINGINANMU
local Author = "Rafaczx"
local SUMMIT_CFRAME = CFrame.new(8711.95215, 1637.02124, 1343.46667, 0.375418901, -4.74302198e-09, 0.926855266, 1.80503723e-10, 1, 5.04421527e-09, -0.926855266, -1.72639292e-09, 0.375418901)
-- ================================================

-- 1. MEMUAT LIBRARY STELLAR
local StellarLibrary = (loadstring(Game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua")))();

if StellarLibrary:LoadAnimation() then
	StellarLibrary:StartLoad();
end;
if StellarLibrary:LoadAnimation() then
	StellarLibrary:Loaded();
end;

-- 2. LOGIKA TELEPORTASI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local running = false
local teleportsLeft = 10 
local delayTime = 2     

-- FUNGSI INTI: MELAKUKAN SATU SIKLUS LOOP (Teleport -> Kill -> Wait Respawn -> Delay)
local function executeCycle(delay)
    local success = pcall(function()
        
        -- Ambil karakter yang SAAT INI ada (karakter yang baru respawn dari loop sebelumnya)
        local char = player.Character or player.CharacterAdded:Wait(5)
        if not char then return end 

        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        
        -- Siapkan sinyal untuk menangkap karakter BERIKUTNYA setelah kill
        local newCharWait = player.CharacterAdded:Once() 
        
        -----------------------------------
        -- 1. TELEPORT KE SUMMIT
        -----------------------------------
        root.CFrame = SUMMIT_CFRAME
        
        -- ** JEDA 2 DETIK SETELAH TELEPORT (SESUAI PERMINTAAN USER) **
        task.wait(5) 
        
        -----------------------------------
        -- 2. RESET/KILL KARAKTER
        -----------------------------------
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
        
        -----------------------------------
        -- 3. TUNGGU RESPOND KARAKTER BARU (WAJIB)
        -----------------------------------
        newCharWait:Wait() 
        
        -----------------------------------
        -- 4. DELAY (PATOKAN USER)
        -----------------------------------
        if delay > 0 then task.wait(delay) end
    end)
    
    if not success then
        -- Jika ada error, beri jeda untuk mencegah crash total
        task.wait(2)
        StellarLibrary:Notify("RUNNING", 2)
    end
end


-- Fungsi Utama: Memulai loop teleportasi
local function startTeleportLoop(count, delay)
    -- Jika sudah berjalan, hentikan dulu
    if running then
        running = false
        task.wait(delay * 0.5)
    end

    -- Update variabel kontrol
    teleportsLeft = count
    delayTime = delay
    running = true
    
    StellarLibrary:Notify("Auto Summit Dimulai! Count: " .. (count == -1 and "Infinite" or count), 3);

    task.spawn(function()
        while running and (teleportsLeft > 0 or teleportsLeft == -1) do
            
            -- Panggil fungsi inti untuk satu siklus loop
            executeCycle(delayTime)
            
            if teleportsLeft > 0 then
                teleportsLeft -= 1
            end
        end
        running = false
        StellarLibrary:Notify("Auto Summit Selesai.", 2);
    end)
end

local function stopTeleportLoop()
    running = false
    StellarLibrary:Notify("Auto Summit Dihentikan Manual.", 2);
end


-- 3. PEMBUATAN WINDOW DAN TAB TUNGGAL
local UserInputService = game:GetService("UserInputService")
local Window = StellarLibrary:Window({
	SubTitle = "Rafaczx HUB - " .. Author,
	Size = game:GetService("UserInputService").TouchEnabled and UDim2.new(0, 380, 0, 260) or UDim2.new(0, 500, 0, 320),
	TabWidth = 140
})

local SummitTab = Window:Tab("Mount Taranjang", "rbxassetid://10723407389")


-- 4. MENAMBAHKAN KONTROL AUTO SUMMIT KE TAB
SummitTab:Seperator("Auto Summit Settings by " .. Author);

-- Textbox Loop Count: Perbarui variabel global saat nilai berubah
local TeleportCountTextbox = SummitTab:Textbox("JUMLAH SUMMIT", "10", function(value)
    local count = tonumber(value)
    if count and count >= 0 then
        teleportsLeft = (count == 0) and -1 or math.floor(count) 
    end
end)

-- Textbox Delay: Perbarui variabel global saat nilai berubah
local DelayTextbox = SummitTab:Textbox("DELAY", "2", function(value)
    local delay = tonumber(value)
    if delay and delay >= 0.1 then
        delayTime = delay
    end
end)

SummitTab:Line();

-- TOMBOL RUN UTAMA
SummitTab:Button("START AUTO SUMMIT", function()
    local count = teleportsLeft 
    local delay = delayTime
    
    if running then
        stopTeleportLoop()
        task.wait(delay * 0.5)
    end
    
    startTeleportLoop(count, delay);
end);

-- TOMBOL STOP
SummitTab:Button("STOP AUTO LOOP", function()
    stopTeleportLoop();
end);