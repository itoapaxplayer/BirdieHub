local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- You can change the 'Title' to whatever game you are hacking!
local Window = Library:CreateWindow({
    Title = 'Birdie Hub | Toasted Twins Productions',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main Tab'),
    ['UI Settings'] = Window:AddTab('UI Settings'), -- NEVER DELETE THIS TAB!
}


-- ========================================== --
-- 🛠️ MIDDLE: YOUR PLAYGROUND 🛠️
-- ========================================== --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- 🚨 THE FIX: Create the Groupbox inside the Main Tab first!
local FarmBox = Tabs.Main:AddLeftGroupbox('Auto Farming')

-- Add this slider ABOVE the toggle so you can adjust speed on the fly!
FarmBox:AddSlider('CollectDelay', {
    Text = 'Collection Wait Time',
    Default = 1.2,
    Min = 0.5,
    Max = 3,
    Rounding = 1,
    Compact = false,
})
-- Create the Zone Dropdown
FarmBox:AddDropdown('ZoneSelector', {
    Values = { 'Zone2', 'Zone3', 'Zone4', 'Zone5', 'Zone6', 'Zone7', 'Zone8', 'Zone9', 'Zone10', 'Zone11', 'Zone12', 'Zone13' },
    Default = 1,
    Multi = false,
    Text = 'Select Farm Zone',
})

-- 🦈 SHARK RADAR: Snap to safe spot if GoldShark or others are near
local function checkSharkSafety(root, safeCFrame)
    -- Checking workspace.GoldShark specifically as requested
    local sharks = {workspace:FindFirstChild("GoldShark"), workspace:FindFirstChild("PurpleShark"), workspace:FindFirstChild("Shark")}
    for _, shark in pairs(sharks) do
        if shark and shark:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - shark.HumanoidRootPart.Position).Magnitude
            if dist < 45 then 
                root.CFrame = safeCFrame -- Instant TP back to base
                return false 
            end
        end
    end
    return true
end

-- 🎯 DYNAMIC TARGETING: Finds the item with the highest Value regardless of part names
local function getHighestValueItem(folder)
    local items = folder:GetChildren()
    if #items == 0 then return nil end

    local bestItem = nil
    local highestValue = -1

    for _, item in pairs(items) do
        pcall(function()
            -- Instead of looking for "Mesh", we find the folder "ObjectInfo" wherever it is hidden
            local infoFolder = item:FindFirstChild("ObjectInfo", true) -- "true" makes it search all descendants
            
            if infoFolder then
                local valueObj = infoFolder:FindFirstChild("Value")
                local label = valueObj and valueObj:FindFirstChild("ValueLabel")

                if label and label:IsA("TextLabel") then
                    -- Clean the text ($5,000 -> 5000)
                    local cleanText = label.Text:gsub("[^%d%.]", "")
                    local val = tonumber(cleanText)

                    if val and val > highestValue then
                        highestValue = val
                        bestItem = item
                    end
                end
            end
        end)
    end

    -- If no labels found, fallback to the first item so the loop doesn't break
    return bestItem or items[1]
end

-- ========================================== --
-- 🚜 THE MASTER FARMER
-- ========================================== --
FarmBox:AddToggle('MasterFarm', {
    Text = 'Elite Auto-Farm (Smart Target)',
    Default = false,
    Callback = function(Value)
        _G.MasterFarm = Value
        task.spawn(function()
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            -- Save base position for the 9-second water timer reset
            local safePos = hrp and hrp.CFrame or CFrame.new(0, 100, 0)

            while _G.MasterFarm do
                pcall(function()
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local zoneName = Options.ZoneSelector.Value
                    local objectsFolder = workspace.Zones[zoneName].Objects
                    
                    -- 🎯 Find the highest value (even for Dragon/Cube.117)
                    local targetItem = getHighestValueItem(objectsFolder)
                    
                    if targetItem and root then
                        local targetPart = targetItem:FindFirstChildWhichIsA("BasePart", true)
                        if targetPart then
                            -- 🛸 Teleport
                            root.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                            
                            local collectTimer = 0
                            while collectTimer < 2.5 and targetItem.Parent == objectsFolder do
                                if not _G.MasterFarm then break end
                                
                                -- 🦈 Shark Radar (Snaps to base if GoldShark is < 45 studs)
                                if not checkSharkSafety(root, safePos) then
                                    warn("🦈 Shark detected! Snapping to safety.")
                                    task.wait(2)
                                    break 
                                end

                                -- Hold E
                                if collectTimer == 0.5 then
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                end
                                
                                task.wait(0.1)
                                collectTimer = collectTimer + 0.1
                            end
                            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            
                            -- 🏝️ Return home to reset the 9s water timer
                            root.CFrame = safePos
                            task.wait(0.7)
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
})

-- ========================================== --
-- 💰 AUTO-COLLECT MONEY (1-30 RANGE)
-- ========================================== --
FarmBox:AddToggle('AutoCollectMoney', {
    Text = 'Auto-Collect Money',
    Default = false,
    Tooltip = 'Claims all 30 slots using the 1-30 ID system!',
    Callback = function(Value)
        _G.AutoCollectMoney = Value
        
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local claimRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classes"):WaitForChild("Remote"):WaitForChild("Remotes"):WaitForChild("BaseShared_ClaimSlotBalance")
            
            while _G.AutoCollectMoney do
                pcall(function()
                    -- 🔥 Corrected range: 1 to 30 as requested!
                    for i = 1, 30 do
                        if not _G.AutoCollectMoney then break end
                        claimRemote:FireServer(i)
                    end
                end)
                task.wait(5) -- Collect every 5 seconds
            end
        end)
    end
})

local function parsePrice(text)
    local clean = text:gsub("[^%d%.%a]", ""):upper()
    local num = tonumber(clean:gsub("[%a]", ""))
    if not num then return 0 end
    
    if clean:find("K") then return num * 1000 end
    if clean:find("M") then return num * 1000000 end
    if clean:find("B") then return num * 1000000000 end
    if clean:find("T") then return num * 1000000000000 end
    return num
end

FarmBox:AddToggle('SmartUpgrade', {
    Text = 'Smart Auto-Upgrade (Force-Find)',
    Default = false,
    Callback = function(Value)
        _G.SmartUpgrade = Value
        task.spawn(function()
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Classes"):WaitForChild("Remote"):WaitForChild("Remotes"):WaitForChild("BaseShared_UpgradeSlot")
            
            while _G.SmartUpgrade do
                pcall(function()
                    local stats = LocalPlayer:FindFirstChild("leaderstats")
                    local cashObj = stats and stats:FindFirstChild("\240\159\146\181 Cash")
                    local currentCash = cashObj and cashObj.Value or 0
                    
                    -- 🕵️ SEARCH FOR BASE
                    local myBase = nil
                    for _, b in pairs(workspace.Bases:GetChildren()) do
                        -- Check if the base name matches you or the specific folder name
                        if b.Name == LocalPlayer.Name or b.Name == "IntimateIsolated" or b:FindFirstChild("Owner") and b.Owner.Value == LocalPlayer.Name then
                            myBase = b
                            break
                        end
                    end
                    
                    if not myBase then 
                        print("❌ Error: Could not detect your Base folder!")
                        return 
                    end

                    local cheapestSlot = nil
                    local lowestPrice = math.huge
                    
                    for i = 1, 30 do
                        local slot = myBase.Slots:FindFirstChild("Slot" .. i)
                        if slot then
                            -- 🔎 Search for the label that contains the cost
                            local foundLabel = nil
                            for _, v in pairs(slot:GetDescendants()) do
                                -- Check for common price indicators
                                if (v:IsA("TextLabel") or v:IsA("TextBox")) and (v.Text:find("%$") or v.Name:lower():find("price")) then
                                    foundLabel = v
                                    break
                                end
                            end

                            if foundLabel then
                                local price = parsePrice(foundLabel.Text)
                                if price > 0 and price <= currentCash and price < lowestPrice then
                                    lowestPrice = price
                                    cheapestSlot = i
                                end
                            end
                        end
                    end
                    
                    if cheapestSlot then
                        remote:FireServer(cheapestSlot)
                        -- Wait a tiny bit between upgrades so the UI can update
                        task.wait(0.2)
                    end
                end)
                task.wait(1) 
            end
        end)
    end
})
-- ========================================== --
-- 🛑 KILL SWITCH / UNLOAD
-- ========================================== --
local UnloadBox = Tabs['UI Settings']:AddLeftGroupbox('Hub Management')

-- This tells the UI what to do the exact moment it gets destroyed
Library.OnUnload = function()
    print("Shutting down Birdie Hub...")
    -- 1. Kill all background loops!
     _G.MasterFarm = false
     _G.AutoCollectMoney = false
     _G.SmartUpgrade = false
    -- 2. Let the console know it's safe to re-execute
    print("Birdie Hub successfully wiped from memory. Safe to re-inject!")
end

-- This is the actual button you click to trigger the destruction
UnloadBox:AddButton('Unload / Destroy GUI', function()
    Library:Unload() -- This is Linoria's built-in self-destruct code
end)

-- ========================================== --
-- ⬇️ BOTTOM: THE ENGINE (KEEP THIS AT THE VERY END) ⬇️
-- ========================================== --
Library:SetWatermarkVisibility(false)
Library:SetWatermark('Birdie Hub') 

Library.KeybindFrame.Visible = false

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('BirdieHub')
SaveManager:SetFolder('BirdieHub/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

ThemeManager:SetTheme('Jester')
