local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local webhookUrl = "https://discord.com/api/webhooks/1481919666799640637/vH6HePynK3m_WNJXrcEoqqrNPuQirTPt-BqSMWVo25VKmYVgTvhMI1eLsCRVeKOL6C_z"

local data = {
    ["content"] = "",
    ["embeds"] = {{
        ["title"] = "🦅 BirdieHub Execution!",
        ["description"] = "User: **" .. game.Players.LocalPlayer.Name .. "** has executed Birdie Hub!",
        ["color"] = 16711680
    }}
}

request({
    Url = webhookUrl,
    Method = "POST",
    Headers = {["Content-Type"] = "application/json"},
    Body = game:GetService("HttpService"):JSONEncode(data)
})

local Window = Library:CreateWindow({
    Title = 'Birdie Hub | Toasted Twins Productions',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main Tab'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================== --
-- 🏃 ANTI-AFK SYSTEM
-- ========================================== --
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    
    while true do
        -- Simulates a small mouse click on the game window
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
        
        print("🛡️ Anti-AFK: Clicked to prevent idle kick!") -- Moved inside the loop!
        
        task.wait(5) 
    end
end)

-- ========================================== --
-- 🌾 AUTO HARVEST SECTION
-- ========================================== --
local FarmBox = Tabs.Main:AddLeftGroupbox('Auto Harvest')

FarmBox:AddDropdown('HarvestTarget', {
    Values = { 
        'All', 'Sardine', 'Anchovy', 'Eel', 'Bass', 'Tilapia', 
        'Catfish', 'Stubby', 'Salmon', 'Shrimp', 'Goldfish', 
        'BlueTang', 'Clownfish', 'Koi', 'Swordfish', 
        'AngelSquid', 'Lionfish', 'BlobFish', 
        'HammerheadShark', 'SeaTurtle', 'Manatee', 
        'Megalodon', 'Squid', 'Bloop'
    },
    Default = 1,
    Multi = true,
    Text = 'Target Fish to Harvest',
    Tooltip = 'Select a specific fish, or choose All',
})

FarmBox:AddToggle('ProtectMutated', {
    Text = 'Protect Mutated Fish',
    Default = true, 
    Tooltip = 'Ignores fish that already have a passive mutation',
})

-- ⚖️ UPDATED: Maximum Weight Filter (Keeps the Big Ones!)
FarmBox:AddInput('MaxWeight', {
    Default = '1', -- Default is super high so it harvests everything unless you change it
    Numeric = true,
    Finished = false, 
    Text = 'Max Harvest Weight (Save Big Fish)',
    Tooltip = 'Harvests fish UNDER this weight. Set to 30 to save everything 30+.',
    Placeholder = 'e.g. 30',
})

FarmBox:AddToggle('AutoHarvest', {
    Text = 'Auto Harvest Fish (LOUD DEBUG)',
    Default = false,
    Callback = function(Value)
        _G.AutoHarvest = Value
        print("🟢 TOGGLE CLICKED! Value is now:", Value)
        
        if Value == true then
            task.spawn(function()
                print("🚀 Auto-Harvest Loop Started!")
                while _G.AutoHarvest do
                    
                    local success, errorMessage = pcall(function() 
                        local fishFolder = workspace:FindFirstChild("Fish")
                        if not fishFolder then return end
                        
                        local allFish = fishFolder:GetChildren()
                        
                        for _, fishModel in pairs(allFish) do
                            local uuid = fishModel:GetAttribute("Id")
                            local fishType = fishModel:GetAttribute("FishId")
                            local fishWeight = fishModel:GetAttribute("Weight") or 0
                            
                            -- 🛠️ THE REAL FIX: Proper tables! Options for dropdowns/inputs, Toggles for checkboxes!
                            local targetChoice = Options.HarvestTarget.Value or {}
                            local maxWeight = tonumber(Options.MaxWeight.Value) or 9999 
                            local protectMutations = Toggles.ProtectMutated.Value
                            
                            if uuid and fishType then
                                if targetChoice['All'] or targetChoice[fishType] then
                                    if fishWeight < maxWeight then
                                        
                                        local isMutated = false
                                            if protectMutations then
                                             -- FindFirstChild(..., true) searches all the way down through the Shrimp/Eel to the UI
                                             local mutationsFolder = fishModel:FindFirstChild("Mutations", true)
    
                                             if mutationsFolder then
                                            -- Check every file inside the folder
                                             for _, file in pairs(mutationsFolder:GetChildren()) do
                                             -- If the file is NOT one of the 3 default UI files, it must be a mutation!
                                             if file.Name ~= "UIListLayout" and file.Name ~= "MutationNameTemplate" and file.Name ~= "PlusTemplate" then
                                              isMutated = true
                                             print("✨ SAVED A MUTATED FISH! Type:", fishType, "| Mutation:", file.Name)
                                            break -- We found a mutation, stop checking this fish
                                                            end
                                                       end
                                                 end
                                            end
                                        
                                        if not isMutated then
                                            local ui = fishModel:FindFirstChild("FishInfoUI", true)
                                            local canHarvest = ui and ui:FindFirstChild("CanHarvest", true)
                                            
                                            if canHarvest and canHarvest.Visible == true then
                                                print("🎯 HARVESTING", fishType, "| Weight:", fishWeight)
                                                local args = { [1] = { [1] = uuid, [2] = "\7" } }
                                                game:GetService("ReplicatedStorage"):WaitForChild("ffrostflame_bridgenet2@1.0.0"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                                                task.wait(0.2) 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    
                    if not success then
                        warn("🔴 SCRIPT CRASHED INSIDE THE LOOP: " .. tostring(errorMessage))
                    end
                    
                    task.wait(2) 
                end
                print("🛑 Auto-Harvest Loop Stopped!")
            end)
        end
    end
})

FarmBox:AddToggle('AutoSell', {
    Text = 'Auto Sell All Fish',
    Default = false,
    Callback = function(Value)
        _G.AutoSell = Value
        print("🟢 Auto Sell:", Value)
        
        if Value == true then
            task.spawn(function()
                while _G.AutoSell do
                    local success, errorMessage = pcall(function()
                        local args = {
                            [1] = {
                                [1] = "All",
                                [2] = "\8"
                            }
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("ffrostflame_bridgenet2@1.0.0"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                        print("💸 Auto-Sold all fish!")
                    end)
                    
                    if not success then
                        warn("🔴 Auto Sell Error:", errorMessage)
                    end
                    
                    task.wait(10) -- Sells every 10 seconds. You can change this number!
                end
            end)
        end
    end
})

-- ========================================== --
-- 🥚 AUTO BUY EGGS SECTION
-- ========================================== --
local BuyBox = Tabs.Main:AddRightGroupbox('Auto Egg Shop')

local EggPrices = {
    ["Bloop"] = 1500000, ["Squid"] = 1000000, ["Megalodon"] = 1000000, 
    ["Manatee"] = 850000, ["SeaTurtle"] = 750000, ["HammerheadShark"] = 500000, 
    ["BlobFish"] = 150000, ["Lionfish"] = 120000, ["AngelSquid"] = 110000, 
    ["Swordfish"] = 100000, ["Koi"] = 50000, ["Clownfish"] = 15000, 
    ["BlueTang"] = 12000, ["Goldfish"] = 6000, ["Shrimp"] = 5100, 
    ["Salmon"] = 3250, ["Stubby"] = 1200, ["Catfish"] = 1000, 
    ["Bass"] = 400, ["Tilapia"] = 120, ["Eel"] = 200, 
    ["Anchovy"] = 50, ["Sardine"] = 10
}

BuyBox:AddDropdown('EggTarget', {
    Values = { 
        'Sardine', 'Anchovy', 'Eel', 'Bass', 'Tilapia', 'Catfish', 
        'Stubby', 'Salmon', 'Shrimp', 'Goldfish', 'BlueTang', 
        'Clownfish', 'Koi', 'Swordfish', 'AngelSquid', 'Lionfish', 
        'BlobFish', 'HammerheadShark', 'SeaTurtle', 'Manatee', 
        'Megalodon', 'Squid', 'Bloop' 
    },
    Default = 1,
    Multi = true,
    Text = 'Select Eggs to Buy',
})

BuyBox:AddToggle('AutoBuy', {
    Text = 'Enable Auto-Buy',
    Default = false,
    Callback = function(Value)
        _G.AutoBuy = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuy do
                    local success, err = pcall(function()
                        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                        local bubloons = leaderstats and leaderstats:FindFirstChild("Bubloons")
                        
                        if bubloons then
                            local currentMoney = bubloons.Value
                            local selectedEggs = Options.EggTarget.Value

                            for eggName, isSelected in pairs(selectedEggs) do
                                if isSelected and _G.AutoBuy then
                                    local price = EggPrices[eggName] or 99999999
                                    
                                    if currentMoney >= price then
                                        local buyArgs = {
                                            [1] = {
                                                [1] = { [1] = "Fish", [2] = eggName },
                                                [2] = ")"
                                            }
                                        }
                                        game:GetService("ReplicatedStorage")["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer(unpack(buyArgs))
                                        
                                        currentMoney = currentMoney - price -- Local math to prevent over-buying
                                        task.wait(0.3) -- Small delay between multiple purchases
                                    end
                                end
                            end
                        end
                    end)
                    
                    if not success then warn("Auto Buy Error: " .. err) end
                    task.wait(1) -- Wait before checking prices/selections again
                end
            end)
        end
    end
})

-- ========================================== --
-- 🎣 AUTO BUY ROD SECTION
-- ========================================== --
local RodBox = Tabs.Main:AddRightGroupbox('Auto Rod Shop')

local RodPrices = {
    ["CoralithRod"] = 999999,
    ["AdvancedRod"] = 650000,
    ["BasicRod"] = 500000,
    ["StickRod"] = 250000
}

RodBox:AddDropdown('RodTarget', {
    Values = { 'StickRod', 'BasicRod', 'AdvancedRod', 'CoralithRod' },
    Default = 1,
    Multi = true, -- Changed to true!
    Text = 'Select Rods to Buy',
})

RodBox:AddToggle('AutoBuyRod', {
    Text = 'Enable Auto-Buy Rod',
    Default = false,
    Callback = function(Value)
        _G.AutoBuyRod = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyRod do
                    local success, err = pcall(function()
                        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                        local bubloons = leaderstats and leaderstats:FindFirstChild("Bubloons")
                        
                        if bubloons then
                            local currentMoney = bubloons.Value
                            local selectedRods = Options.RodTarget.Value -- This is now a table of true/false values
                            
                            -- Loop through the table of rods you checked
                            for rodName, isSelected in pairs(selectedRods) do
                                if isSelected and _G.AutoBuyRod then
                                    local price = RodPrices[rodName]
                                    
                                    if price and currentMoney >= price then
                                        local buyArgs = {
                                            [1] = {
                                                [1] = { [1] = "Rod", [2] = rodName },
                                                [2] = ")"
                                            }
                                        }
                                        game:GetService("ReplicatedStorage")["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer(unpack(buyArgs))
                                        
                                        print("🎣 Bought Rod: " .. rodName)
                                        currentMoney = currentMoney - price -- Local math to prevent trying to buy 2 expensive rods at once
                                        task.wait(0.5) -- Small delay between buys
                                    end
                                end
                            end
                        end
                    end)
                    
                    if not success then warn("Auto Buy Rod Error: " .. tostring(err)) end
                    task.wait(1.5) -- Check wallet every 1.5 seconds
                end
            end)
        end
    end
})

-- ========================================== --
-- 🛑 KILL SWITCH / UNLOAD
-- ========================================== --
local UnloadBox = Tabs['UI Settings']:AddLeftGroupbox('Hub Management')

Library.OnUnload = function()
    print("Shutting down Birdie Hub...")
    _G.AutoHarvest = false
    _G.AutoSell = false
    _G.AutoBuy = false
    _G.AutoBuyRod = false
    print("Birdie Hub successfully wiped from memory. Safe to re-inject!")
end

UnloadBox:AddButton('Unload / Destroy GUI', function()
    Library:Unload() 
end)

-- ========================================== --
-- ⬇️ BOTTOM: THE ENGINE (THE ULTIMATE FIX)
-- ========================================== --

-- 1. Essential Managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- 2. Build the Config Section
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('BirdieHub')
SaveManager:SetFolder('BirdieHub/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- 3. Visuals & Keybinds
Library:SetWatermarkVisibility(false)
Library.KeybindFrame.Visible = false

-- Change the keybind to Right Control so Right Shift isn't the only way
task.spawn(function()
    task.wait(0.5)
    if Options.MenuKeybind then
        Options.MenuKeybind:SetValue(Enum.KeyCode.RightControl)
    end
    ThemeManager:ApplyTheme('Jester')
end)

-- ========================================== --
-- 🚀 THE "CURSOR JAILBREAK" LOGIC
-- ========================================== --
local UIS = game:GetService("UserInputService")

-- This forces the cursor to stay visible even if the UI tries to hide it
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.RightControl then
        task.wait(0.1) -- Wait for the menu to finish toggling
        UIS.MouseIconEnabled = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- A secondary loop to ensure the cursor NEVER stays hidden
task.spawn(function()
    while true do
        if Library.MainThreadGroup.Visible then
            UIS.MouseIconEnabled = true
        end
        task.wait(0.5)
    end
end)

print("✅ Birdie Hub loaded. Right Shift/Control toggles, Cursor forced ON!")
