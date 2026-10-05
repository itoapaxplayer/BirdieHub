local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Your Webhook & Discord Info
local WebhookUrl = "https://discord.com/api/webhooks/1556490323860004915/9dPHECNaeU1iMRrO4lnyNPhCSWlhEh2iUiXLo1OuHDm8XrG4Ht_rRMysqTQ9Uo6pM64E"
local UserToPing = "<@983705158292762634>"
local messageId = nil
local currentEventId = 0

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ========================================== --
-- 1. CREATE MOBILE-FRIENDLY UI
-- ========================================== --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeatherWebhookNotifier"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local quitButton = Instance.new("TextButton")
quitButton.Size = UDim2.new(0, 140, 0, 45)
quitButton.Position = UDim2.new(0.5, -70, 0, 20)
quitButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
quitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quitButton.Font = Enum.Font.GothamBold
quitButton.TextSize = 16
quitButton.Text = "Stop Notifier"
quitButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = quitButton

-- ========================================== --
-- 2. DISCORD WEBHOOK LOGIC
-- ========================================== --

local function stripHtmlTags(str)
    return (str:gsub("<[^>]+>", ""))
end

local function initializeWebhook()
    if not httprequest then return end
    
    local data = {
        embeds = {{
            title = "🌤️ Weather Monitor Active",
            description = "**Status:** No active events.\nWaiting for the sky to change...",
            color = 3447003 
        }}
    }
    
    local response = httprequest({
        Url = WebhookUrl .. "?wait=true",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
    
    if response and response.Body then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.id then
            messageId = decoded.id
        end
    end
end

-- NEW: Sends a fresh message specifically to force a push notification
local function sendPing(eventData)
    if not httprequest or not eventData then return end
    
    local displayEventName = eventData.eventTitle or eventData.eventName or "Unknown"
    
    httprequest({
        Url = WebhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = UserToPing .. " 🚨 **" .. displayEventName .. "** event just started! Check the live timer."
        })
    })
end

local function updateWebhook(isActive, eventData)
    if not messageId or not httprequest then return end
    
    local embed = {}
    
    if isActive and eventData then
        local cleanDesc = stripHtmlTags(eventData.eventDesc or "")
        local duration = tonumber(eventData.duration) or 0
        local endTime = math.floor(os.time() + duration)
        local displayEventName = eventData.eventTitle or eventData.eventName or "Unknown"
        
        embed = {
            title = "🌩️ " .. (eventData.startTitle or "Event Started!"),
            description = "**Event:** " .. displayEventName .. "\n" ..
                          "**Ends:** <t:" .. endTime .. ":R>\n\n" .. 
                          "*" .. cleanDesc .. "*",
            color = 16711680 
        }
    else
        embed = {
            title = "🌤️ Weather Monitor",
            description = "**Status:** No active events.\nWaiting for the next event...",
            color = 3447003 
        }
    end
    
    httprequest({
        Url = WebhookUrl .. "/messages/" .. messageId,
        Method = "PATCH",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            embeds = {embed}
        })
    })
end

local function logCompletedEvent(eventData)
    if not httprequest or not eventData then return end
    
    local cleanDesc = stripHtmlTags(eventData.eventDesc or "")
    local duration = tonumber(eventData.duration) or 0
    local durationMins = math.floor(duration / 60)
    local durationSecs = duration % 60
    
    local displayEventName = eventData.eventTitle or eventData.eventName or "Unknown"
    
    local logEmbed = {
        title = "📜 Event Concluded: " .. displayEventName,
        description = "**Detailed Log Report**\n" ..
                      "**Type:** " .. (eventData.startTitle or "Weather Event") .. "\n" ..
                      "**Total Duration:** " .. durationMins .. "m " .. durationSecs .. "s (" .. duration .. " seconds)\n" ..
                      "**Modifiers Applied:**\n*" .. cleanDesc .. "*",
        color = 5763719, 
        footer = { text = "Logged dynamically via Hub" },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    httprequest({
        Url = WebhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({embeds = {logEmbed}})
    })
end

-- ========================================== --
-- 3. WEATHER EVENT LISTENER
-- ========================================== --
local eventRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TypeEventState")

task.spawn(initializeWebhook)

local connection = eventRemote.OnClientEvent:Connect(function(data)
    if type(data) == "table" and (data.kind == "PreStart" or data.kind == "Started") then
        
        currentEventId = currentEventId + 1
        local thisEventId = currentEventId
        local duration = tonumber(data.duration) or 150
        local displayEventName = data.eventTitle or data.eventName or "Unknown"
        
        StarterGui:SetCore("SendNotification", {
            Title = data.startTitle or "Weather Event!",
            Text = "Event: " .. displayEventName,
            Duration = 5,
        })
        
        -- Force the ping message FIRST, then update the live status board
        sendPing(data)
        updateWebhook(true, data)
        
        task.delay(duration, function()
            if currentEventId == thisEventId then
                logCompletedEvent(data) 
                updateWebhook(false)    
            end
        end)
    end
end)

-- ========================================== --
-- 4. QUIT BUTTON LOGIC (CLEANUP)
-- ========================================== --
quitButton.MouseButton1Click:Connect(function()
    if connection then connection:Disconnect() end
    screenGui:Destroy()
    
    if messageId and httprequest then
        httprequest({
            Url = WebhookUrl .. "/messages/" .. messageId,
            Method = "PATCH",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🛑 Monitor Offline",
                    description = "The Roblox script has been closed. No longer tracking events.",
                    color = 8421504 
                }}
            })
        })
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "Notifier Stopped",
        Text = "Webhook script has been fully unloaded.",
        Duration = 5,
    })
end)