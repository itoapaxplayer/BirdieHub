local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Webhook when the script injects
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

-- 🛠️ FIX 1: Added the 'Server Info' Tab here so it doesn't crash!
local Tabs = {
    Main = Window:AddTab('Main Tab'),
    ['Server Info'] = Window:AddTab('Server Info'), 
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================== --
-- 🏃 ANTI-AFK SYSTEM
-- ========================================== --
_G.AntiAfkEnabled = true 

task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    print("🛡️ Anti-AFK Started!")
    
    while _G.AntiAfkEnabled do
        local success, err = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
        task.wait(5) 
    end
    print("🛑 Anti-AFK successfully shut down!")
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

FarmBox:AddInput('MaxWeight', {
    Default = '1', 
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
        if Value == true then
            task.spawn(function()
                while _G.AutoHarvest do
                    local success, errorMessage = pcall(function() 
                        local fishFolder = workspace:FindFirstChild("Fish")
                        if not fishFolder then return end
                        
                        local allFish = fishFolder:GetChildren()
                        for _, fishModel in pairs(allFish) do
                            local uuid = fishModel:GetAttribute("Id")
                            local fishType = fishModel:GetAttribute("FishId")
                            local fishWeight = fishModel:GetAttribute("Weight") or 0
                            
                            local targetChoice = Options.HarvestTarget.Value or {}
                            local maxWeight = tonumber(Options.MaxWeight.Value) or 9999 
                            local protectMutations = Toggles.ProtectMutated.Value
                            
                            if uuid and fishType then
                                if targetChoice['All'] or targetChoice[fishType] then
                                    if fishWeight < maxWeight then
                                        
                                        local isMutated = false
                                        if protectMutations then
                                             local mutationsFolder = fishModel:FindFirstChild("Mutations", true)
                                             if mutationsFolder then
                                                 for _, file in pairs(mutationsFolder:GetChildren()) do
                                                     if file.Name ~= "UIListLayout" and file.Name ~= "MutationNameTemplate" and file.Name ~= "PlusTemplate" then
                                                         isMutated = true
                                                         break 
                                                     end
                                                 end
                                             end
                                        end
                                        
                                        if not isMutated then
                                            local ui = fishModel:FindFirstChild("FishInfoUI", true)
                                            local canHarvest = ui and ui:FindFirstChild("CanHarvest", true)
                                            
                                            if canHarvest and canHarvest.Visible == true then
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
                    task.wait(2) 
                end
            end)
        end
    end
})

FarmBox:AddToggle('AutoSell', {
    Text = 'Auto Sell All Fish',
    Default = false,
    Callback = function(Value)
        _G.AutoSell = Value
        if Value == true then
            task.spawn(function()
                while _G.AutoSell do
                    pcall(function()
                        local args = { [1] = { [1] = "All", [2] = "\8" } }
                        game:GetService("ReplicatedStorage"):WaitForChild("ffrostflame_bridgenet2@1.0.0"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                    end)
                    task.wait(10) 
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
                    pcall(function()
                        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                        local bubloons = leaderstats and leaderstats:FindFirstChild("Bubloons")
                        if bubloons then
                            local currentMoney = bubloons.Value
                            local selectedEggs = Options.EggTarget.Value
                            for eggName, isSelected in pairs(selectedEggs) do
                                if isSelected and _G.AutoBuy then
                                    local price = EggPrices[eggName] or 99999999
                                    if currentMoney >= price then
                                        local buyArgs = { [1] = { [1] = { [1] = "Fish", [2] = eggName }, [2] = ")" } }
                                        game:GetService("ReplicatedStorage")["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer(unpack(buyArgs))
                                        currentMoney = currentMoney - price 
                                        task.wait(0.3) 
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
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
    Default = 0,
    Multi = true, 
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
                    pcall(function()
                        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                        local bubloons = leaderstats and leaderstats:FindFirstChild("Bubloons")
                        if bubloons then
                            local currentMoney = bubloons.Value
                            local selectedRods = Options.RodTarget.Value 
                            for rodName, isSelected in pairs(selectedRods) do
                                if isSelected and _G.AutoBuyRod then
                                    local price = RodPrices[rodName]
                                    if price and currentMoney >= price then
                                        local buyArgs = { [1] = { [1] = { [1] = "Rod", [2] = rodName }, [2] = ")" } }
                                        game:GetService("ReplicatedStorage")["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer(unpack(buyArgs))
                                        currentMoney = currentMoney - price 
                                        task.wait(0.5) 
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1.5) 
                end
            end)
        end
    end
})

local BoosterBox = Tabs.Main:AddRightGroupbox('Auto Booster Shop')

local BoosterPrices = {
    ["Worm"] = 9000,
    ["FishBag"] = 50000,
    ["MassiveFishnet"] = 30000,
    ["FavoriteTool"] = 999999999,
    ["MegaWrench"] = 35000,
    ["MegaPellets"] = 999999999,
    ["AppraiseTool"] = 25000
}

BoosterBox:AddDropdown('BoosterTarget', {
    Values = { 'Worm', 'FishBag', 'MassiveFishnet', 'FavoriteTool', 'MegaWrench', 'MegaPellets', 'AppraiseTool' },
    Default = 0,
    Multi = true, 
    Text = 'Select Boosters to Buy',
})

BoosterBox:AddToggle('AutoBuyBooster', {
    Text = 'Enable Auto-Buy Booster',
    Default = false,
    Callback = function(Value)
        _G.AutoBuyBooster = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyBooster do
                    pcall(function()
                        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                        local bubloons = leaderstats and leaderstats:FindFirstChild("Bubloons")
                        if bubloons then
                            local currentMoney = bubloons.Value
                            local selectedBoosters = Options.BoosterTarget.Value 
                            for boosterName, isSelected in pairs(selectedBoosters) do
                                if isSelected and _G.AutoBuyBooster then
                                    local price = BoosterPrices[boosterName]
                                    if price and currentMoney >= price then
                                        local buyArgs = { [1] = { [1] = { [1] = "Booster", [2] = boosterName }, [2] = ")" } }
                                        game:GetService("ReplicatedStorage")["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer(unpack(buyArgs))
                                        currentMoney = currentMoney - price 
                                        task.wait(0.5) 
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1.5) 
                end
            end)
        end
    end
})

-- ========================================== --
-- 📍 COORDINATES & CONFIG
-- ========================================== --
local fishingPos = Vector3.new(83.85430908203125, 34.499996185302734, 87.47100067138672)
local fishingLook = Vector3.new(0.012112696655094624, -0, 0.9999266266822815)
local restingPos = Vector3.new(-184.541015625, 58.499996185302734, -104.27984619140625)
local restingLook = Vector3.new(0.500154972076416, -6.941311170294284e-08, 0.8659359216690063)

local isSitting = false
local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local function DebugLog(text)
    print("🛠️ [FISH-DEBUG]: " .. tostring(text))
end

-- ========================================== --
-- 🪑 CHAIR LOGIC (ProximityPrompt Fix)
-- ========================================== --
local function ToggleChair(state)
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if state == "Sit" and not isSitting then
        if hrp then
            -- Scan workspace for the prompt near the player
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.ActionText == "Sit" or obj.ActionText == "Sleep") then
                    if obj.Parent and obj.Parent:IsA("BasePart") then
                        -- Make sure we only trigger the one right next to us
                        local dist = (obj.Parent.Position - hrp.Position).Magnitude
                        if dist < 15 then
                            fireproximityprompt(obj)
                            isSitting = true
                            DebugLog("Fired ProximityPrompt to Sit!")
                            return
                        end
                    end
                end
            end
            DebugLog("Could not find the 'E' prompt for the chair nearby.")
        end

    elseif state == "Stand" and isSitting then
        if humanoid then
            -- Standard Roblox way to force a character to stand up
            humanoid.Sit = false 
            humanoid.Jump = true 
        end
        isSitting = false
        DebugLog("Forced character to stand up.")
    end
end
-- ========================================== --
-- 🎣 SMART ROD FINDER (Now uses RodId & Forces Coralith for Event)
-- ========================================== --
local function getBestRod()
    local char = player.Character
    local backpack = player.Backpack:GetChildren()
    local charTools = char and char:GetChildren() or {}
    local allRods = {}

    -- Gather all tools that have a "RodId" attribute
    for _, item in ipairs(backpack) do 
        if item:IsA("Tool") and item:GetAttribute("RodId") then table.insert(allRods, item) end 
    end
    for _, item in ipairs(charTools) do 
        if item:IsA("Tool") and item:GetAttribute("RodId") then table.insert(allRods, item) end 
    end

    -- 🚨 META PLAY: Force Coralith Rod during ColorfulCoral Event
    if _G.CurrentEvent == "ColorfulCoral" then
        local bestCoralith = nil
        for _, rod in ipairs(allRods) do
            if rod:GetAttribute("RodId") == "CoralithRod" then
                if not bestCoralith then 
                    bestCoralith = rod
                else
                    -- Pick the one with lower health to use it up
                    local curHealth = rod:GetAttribute("Health") or 100
                    local bHealth = bestCoralith:GetAttribute("Health") or 100
                    if curHealth < bHealth then bestCoralith = rod end
                end
            end
        end
        if bestCoralith then return bestCoralith end
        DebugLog("Warning: ColorfulCoral event active but no Coralith Rod found!")
    end

    -- NORMAL LOGIC
    local selectedRods = Options.RodSelection.Value
    local priority = { ["CoralithRod"] = 4, ["AdvancedRod"] = 3, ["BasicRod"] = 2, ["StickRod"] = 1 }
    
    local bestRod = nil
    for _, rod in ipairs(allRods) do
        local id = rod:GetAttribute("RodId")
        
        if selectedRods[id] then
            if not bestRod then 
                bestRod = rod
            else
                local bestId = bestRod:GetAttribute("RodId")
                if (priority[id] or 0) > (priority[bestId] or 0) then 
                    bestRod = rod
                elseif id == bestId then
                    local curHealth = rod:GetAttribute("Health") or 100
                    local bHealth = bestRod:GetAttribute("Health") or 100
                    if curHealth < bHealth then bestRod = rod end
                end
            end
        end
    end
    return bestRod
end

local function simulateClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ========================================== --
-- 🎣 MAIN CONTROLLER
-- ========================================== --
local FishBox = Tabs.Main:AddLeftGroupbox('Auto Fishing')

FishBox:AddDropdown('RodSelection', { 
    Text = 'Rods to Use', 
    Default = 1, 
    Multi = true, 
    Values = { 'CoralithRod', 'AdvancedRod', 'BasicRod', 'StickRod' }
})
FishBox:AddDropdown('ActiveEventSelection', { Text = 'Allowed Events', Default = 1, Multi = true, Values = { 'Bioluminescence', 'BountifulBlessing', 'ColorfulCoral' }})
FishBox:AddToggle('EventOnly', { Text = 'Only Fish During Selected Events', Default = false })
FishBox:AddToggle('AutoChair', { Text = 'Auto-Sit at Rest Spot', Default = false })

FishBox:AddToggle('AutoFish', {
    Text = 'Full AFK Auto-Fish',
    Default = false,
    Callback = function(Value)
        _G.AutoFishing = Value
        if Value then
            -- HIGH-SPEED MINI-GAME LOOP
            task.spawn(function()
                local RunService = game:GetService("RunService")
                local catchConn
                catchConn = RunService.RenderStepped:Connect(function()
                    if not _G.AutoFishing then catchConn:Disconnect() return end
                    
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp or (hrp.Position - fishingPos).Magnitude > 15 then return end

                    local ui = player.PlayerGui:FindFirstChild("HitTheZoneCircleUI")
                    local holder = ui and ui:FindFirstChild("Holder")

                    if holder and holder.Visible then
                        local main = holder:FindFirstChild("Main")
                        local target = main and main:FindFirstChild("Target")
                        local arrow = main and main:FindFirstChild("Arrow")
                        local uiScaleObj = holder:FindFirstChildOfClass("UIScale")

                        if target and arrow then
                            local aRot = arrow.Rotation % 360
                            local tRot = target.Rotation % 360
                            local currentScale = uiScaleObj and uiScaleObj.Scale or 1
                            if math.abs(aRot - tRot) < (12 * currentScale) then
                                simulateClick()
                                task.wait(0.5)
                            end
                        end
                    end
                end)
            end)

            -- MANAGER LOOP
            task.spawn(function()
                while _G.AutoFishing do
                    local char = player.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if not hrp or not humanoid then task.wait(1) continue end

                    local isEventActive = not Toggles.EventOnly.Value or Options.ActiveEventSelection.Value[_G.CurrentEvent]

                    if isEventActive then
                        ToggleChair("Stand") 

                        if (hrp.Position - fishingPos).Magnitude > 5 then
                            DebugLog("Moving to water...")
                            local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(fishingPos, fishingPos + fishingLook)})
                            tween:Play()
                            tween.Completed:Wait()
                            task.wait(0.5)
                        end

                        local targetRod = getBestRod()
                        if targetRod then
                            if targetRod.Parent ~= char then 
                                DebugLog("Equipping Rod: " .. targetRod.Name)
                                humanoid:EquipTool(targetRod)
                                task.wait(0.3)
                                
                                if targetRod.Parent ~= char then
                                    DebugLog("Force-Parenting Rod...")
                                    targetRod.Parent = char
                                end
                                task.wait(0.5)
                            end

                            local ui = player.PlayerGui:FindFirstChild("HitTheZoneCircleUI")
                            local holder = ui and ui:FindFirstChild("Holder")
                            if not holder or not holder.Visible then
                                DebugLog("Casting line...")
                                simulateClick()
                                task.wait(3.5)
                            end
                        else
                            DebugLog("No rod found! Ensure GUI matches Backpack tool attributes.")
                        end
                    else
                        -- NO EVENT: MOVE TO CHAIR
                        if (hrp.Position - restingPos).Magnitude > 2 then
                            DebugLog("No event. Moving to chair...")
                            local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Quad), {CFrame = CFrame.new(restingPos, restingPos + restingLook)})
                            tween:Play()
                            tween.Completed:Wait() 
                            task.wait(0.7) -- Small delay to settle character
                        end
                        
                        -- Now checking outside the magnitude check so it sits even if you were already close
                        if Toggles.AutoChair.Value and not isSitting then 
                            isSitting = false -- Force reset
                            ToggleChair("Sit") 
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ========================================== --
-- 🔔 DISCORD WEBHOOK ALERTS (Kept your logic)
-- ========================================== --
local WebhookBox = Tabs['Server Info']:AddRightGroupbox('Discord Webhook Alerts')

WebhookBox:AddInput('WebhookURL', { Default = '', Text = 'Webhook URL' })
WebhookBox:AddInput('DiscordID', { Default = '', Text = 'Discord User ID to Ping' })
WebhookBox:AddDropdown('PingEvents', {
    Values = { 'Autumn', 'AxoParty', 'Bioluminescence', 'BountifulBlessing', 'ColorfulCoral', 'Comeback', 'DJNogalo', 'GoldenHour', 'InkRain', 'IronCafeParty', 'LoveBomb', 'LoversTrial', 'Lunar', 'Obby', 'Petrification', 'Rain', 'Sandstorm', 'Snow', 'SolarEclipse', 'Staircase', 'Tower', 'TravishConcert', 'TridentRain', 'Valentines' },
    Default = 0, Multi = true, Text = 'Events to Ping For',
})
WebhookBox:AddToggle('EnableWebhook', { Text = 'Enable Webhook Pings', Default = false, Callback = function(V) _G.EnableWebhook = V end })

local function SendDiscordPing(eventName)
    if not _G.EnableWebhook or Options.WebhookURL.Value == "" then return end
    if not Options.PingEvents.Value[eventName] then return end 

    local pingText = Options.DiscordID.Value ~= "" and "<@" .. Options.DiscordID.Value .. "> " or ""
    local payload = game:GetService("HttpService"):JSONEncode({
        ["content"] = pingText .. "🚨 **" .. eventName .. "** event has started!",
        ["embeds"] = {{ ["title"] = "🌍 Event Sniper Activated", ["description"] = "The `" .. eventName .. "` event is now active!", ["color"] = 16711680 }}
    })

    local requestFunc = request or http_request or (http and http.request) or syn.request
    if requestFunc then
        requestFunc({ Url = Options.WebhookURL.Value, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
    end
end

-- ========================================== --
-- 🌍 GLOBAL EVENT WATCHER (Syncs with _G.CurrentEvent)
-- ========================================== --
_G.CurrentEvent = "None" 
_G.EventWatcherEnabled = true

task.spawn(function()
    local success, controller = pcall(function()
        return require(game:GetService("Players").LocalPlayer.PlayerScripts.Client.Controllers.WorldEventController)
    end)

    if success and type(controller) == "table" then
        while _G.EventWatcherEnabled do
            local foundEvent = false
            if controller._startedEvents then
                for eventName, _ in pairs(controller._startedEvents) do
                    if _G.CurrentEvent ~= eventName then
                        _G.CurrentEvent = eventName
                        Library:Notify('🌍 EVENT STARTED: ' .. tostring(eventName), 8)
                        task.spawn(function() SendDiscordPing(eventName) end)
                    end
                    foundEvent = true
                    break 
                end
            end
            
            if not foundEvent and _G.CurrentEvent ~= "None" then
                Library:Notify('🛑 EVENT ENDED: ' .. tostring(_G.CurrentEvent), 5)
                _G.CurrentEvent = "None"
            end
            task.wait(1)
        end
    end
end)
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
    _G.AntiAfkEnabled = false
    _G.EventWatcherEnabled = false -- Fixed: Kills the event watcher too!
    _G.AutoBuyBooster = false
    _G.AutoFishing = false
    print("Birdie Hub successfully wiped from memory. Safe to re-inject!")
end

UnloadBox:AddButton('Unload / Destroy GUI', function()
    Library:Unload() 
end)

-- ========================================== --
-- ⬇️ BOTTOM: THE ENGINE
-- ========================================== --
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('BirdieHub')
SaveManager:SetFolder('BirdieHub/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:SetWatermarkVisibility(false)
Library.KeybindFrame.Visible = false

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
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.RightControl then
        task.wait(0.1) 
        UIS.MouseIconEnabled = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

task.spawn(function()
    while true do
        -- ✅ Changed to Library.Toggled
        if Library.Toggled then 
            UIS.MouseIconEnabled = true
        end
        task.wait(0.5)
    end
end)

print("✅ Birdie Hub loaded. Right Shift/Control toggles, Cursor forced ON!")
