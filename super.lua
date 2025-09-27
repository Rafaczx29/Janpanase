--[[ 
    ================================================
    MOUNT TARANJANG & MOUNT JAPANESE AUTO SUMMIT - STELLAR SINGLE TAB
    LOGIKA BARU: Teleport -> Reset -> Delay (Patokan user).
    Urutan: Teleport ke Summit -> 2 Detik Jeda -> Reset Karakter -> Wait Respawn -> Delay.
    ================================================
]]

-- UBAH INI SESUAI KEINGINANMU
local Author = "v2.1 Summit"

-- CFRAME SUMMIT
local TARANJANG_CFRAME = CFrame.new(8711.95215, 1637.02124, 1343.46667, 0.375418901, -4.74302198e-09, 0.926855266, 1.80503723e-10, 1, 5.04421527e-09, -0.926855266, -1.72639292e-09, 0.375418901)
local JAPANESE_CFRAME = CFrame.new(-18.1628742, 1019.05713, 7.24377155, -0.809797227, -9.46244825e-08, 0.586709857, -4.64653951e-08, 1, 9.71467173e-08, -0.586709857, 5.14074365e-08, -0.809797227)
-- ================================================

-- 1. MEMUAT LIBRARY STELLAR
local StellarLibrary = (loadstring(Game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua")))();

if StellarLibrary:LoadAnimation() then
	StellarLibrary:StartLoad();
end;
if StellarLibrary:LoadAnimation() then
	StellarLibrary:Loaded();
end;

-- 2. LOGIKA TELEPORTASI & KONTROL
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Variabel Kontrol Global
local runningTaranjang = false
local teleportsLeftTaranjang = 10 
local delayTimeTaranjang = 2

local runningJapanese = false
local teleportsLeftJapanese = 10 
local delayTimeJapanese = 2

-- FUNGSI INTI: MELAKUKAN SATU SIKLUS LOOP
-- Fungsi umum yang menerima CFrame dan menjalankan satu siklus Teleport -> Kill -> Wait Respawn -> Delay
local function executeCycle(summitCFrame, delay)
    local success = pcall(function()
        
        -- Ambil karakter yang SAAT INI ada
        local char = player.Character or player.CharacterAdded:Wait(1)
        if not char then return end 

        local root = char:WaitForChild("HumanoidRootPart", 1)
        if not root then return end
        
        -- Siapkan sinyal untuk menangkap karakter BERIKUTNYA setelah kill
        local newCharWait = player.CharacterAdded:Once() 
        
        -----------------------------------
        -- 1. TELEPORT KE SUMMIT
        -----------------------------------
        root.CFrame = summitCFrame
        
        -- ** JEDA 2 DETIK SETELAH TELEPORT (SESUAI PERMINTAAN USER) **
        task.wait(2) 
        
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
        StellarLibrary:Notify("RUNNING SCRIPT", 2)
    end
    return success
end


-- Fungsi Utama: Memulai loop teleportasi Mount Taranjang
local function startTaranjangLoop(count, delay)
    -- Jika loop lain sedang berjalan, hentikan dulu
    if runningJapanese then stopJapaneseLoop() end
    if runningTaranjang then stopTaranjangLoop(); task.wait(delay * 0.5) end

    -- Update variabel kontrol
    teleportsLeftTaranjang = count
    delayTimeTaranjang = delay
    runningTaranjang = true
    
    StellarLibrary:Notify("Auto Summit Taranjang Dimulai! Count: " .. (count == -1 and "Infinite" or count), 3);

    task.spawn(function()
        while runningTaranjang and (teleportsLeftTaranjang > 0 or teleportsLeftTaranjang == -1) do
            
            -- Panggil fungsi inti untuk satu siklus loop
            executeCycle(TARANJANG_CFRAME, delayTimeTaranjang)
            
            if teleportsLeftTaranjang > 0 then
                teleportsLeftTaranjang -= 1
            end
        end
        runningTaranjang = false
        StellarLibrary:Notify("Auto Summit Taranjang Selesai.", 2);
    end)
end

local function stopTaranjangLoop()
    runningTaranjang = false
    StellarLibrary:Notify("Auto Summit Taranjang Dihentikan Manual.", 2);
end


-- Fungsi Utama: Memulai loop teleportasi Mount Japanese
local function startJapaneseLoop(count, delay)
    -- Jika loop lain sedang berjalan, hentikan dulu
    if runningTaranjang then stopTaranjangLoop() end
    if runningJapanese then stopJapaneseLoop(); task.wait(delay * 0.5) end

    -- Update variabel kontrol
    teleportsLeftJapanese = count
    delayTimeJapanese = delay
    runningJapanese = true
    
    StellarLibrary:Notify("Auto Summit Japanese Dimulai! Count: " .. (count == -1 and "Infinite" or count), 3);

    task.spawn(function()
        while runningJapanese and (teleportsLeftJapanese > 0 or teleportsLeftJapanese == -1) do
            
            -- Panggil fungsi inti untuk satu siklus loop
            executeCycle(JAPANESE_CFRAME, delayTimeJapanese)
            
            if teleportsLeftJapanese > 0 then
                teleportsLeftJapanese -= 1
            end
        end
        runningJapanese = false
        StellarLibrary:Notify("Auto Summit Japanese Selesai.", 2);
    end)
end

local function stopJapaneseLoop()
    runningJapanese = false
    StellarLibrary:Notify("Auto Summit Japanese Dihentikan Manual.", 2);
end


-- 3. PEMBUATAN WINDOW DAN TAB
local UserInputService = game:GetService("UserInputService")
local Window = StellarLibrary:Window({
	SubTitle = "Rafaczx HUB - " .. Author,
	Size = game:GetService("UserInputService").TouchEnabled and UDim2.new(0, 380, 0, 260) or UDim2.new(0, 500, 0, 320),
	TabWidth = 140
})

-- TAB LAMA
local TaranjangTab = Window:Tab("Mount Taranjang", "rbxassetid://10723407389")
-- TAB BARU
local JapaneseTab = Window:Tab("Mount Japanese", "rbxassetid://10723407389")


-- 4. MENAMBAHKAN KONTROL AUTO SUMMIT KE TAB TARANJANG
TaranjangTab:Seperator("Auto Summit Taranjang Settings by " .. Author);

-- Textbox Loop Count: Perbarui variabel global saat nilai berubah
local TeleportCountTextboxTaranjang = TaranjangTab:Textbox("JUMLAH SUMMIT", "10", function(value)
    local count = tonumber(value)
    if count and count >= 0 then
        teleportsLeftTaranjang = (count == 0) and -1 or math.floor(count) 
    end
end)

-- Textbox Delay: Perbarui variabel global saat nilai berubah
local DelayTextboxTaranjang = TaranjangTab:Textbox("DELAY", "2", function(value)
    local delay = tonumber(value)
    if delay and delay >= 0.1 then
        delayTimeTaranjang = delay
    end
end)

TaranjangTab:Line();

-- TOMBOL RUN UTAMA
TaranjangTab:Button("START AUTO SUMMIT TARANJANG", function()
    local count = teleportsLeftTaranjang 
    local delay = delayTimeTaranjang
    
    startTaranjangLoop(count, delay);
end);

-- TOMBOL STOP
TaranjangTab:Button("STOP AUTO LOOP", function()
    stopTaranjangLoop();
end);

---
--- KONTROL UNTUK MOUNT JAPANESE
---

JapaneseTab:Seperator("Auto Summit Japanese Settings by " .. Author);

-- Textbox Loop Count: Perbarui variabel global saat nilai berubah
local TeleportCountTextboxJapanese = JapaneseTab:Textbox("JUMLAH SUMMIT", "10", function(value)
    local count = tonumber(value)
    if count and count >= 0 then
        teleportsLeftJapanese = (count == 0) and -1 or math.floor(count) 
    end
end)

-- Textbox Delay: Perbarui variabel global saat nilai berubah
local DelayTextboxJapanese = JapaneseTab:Textbox("DELAY", "2", function(value)
    local delay = tonumber(value)
    if delay and delay >= 0.1 then
        delayTimeJapanese = delay
    end
end)

JapaneseTab:Line();

-- TOMBOL RUN UTAMA
JapaneseTab:Button("START AUTO SUMMIT JAPANESE", function()
    local count = teleportsLeftJapanese 
    local delay = delayTimeJapanese
    
    startJapaneseLoop(count, delay);
end);

-- TOMBOL STOP
JapaneseTab:Button("STOP AUTO LOOP", function()
    stopJapaneseLoop();
end);