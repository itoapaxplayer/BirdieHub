-- [[ Birdie Hub: Universal Loader ]] --

local Games = {
    -- [PlaceID] = "Raw GitHub Link"
    [89046742932569] = "https://raw.githubusercontent.com/itoapaxplayer/BirdieHub/refs/heads/main/SailABrainrot.lua?token=GHSAT0AAAAAADXWNVHGDN6GE37FOXJLXDZK2NTYBFQ",
    [130223052405478] = "https://raw.githubusercontent.com/itoapaxplayer/BirdieHub/refs/heads/main/OwnAFishPond.lua?token=GHSAT0AAAAAADXWNVHHUF6EWLMPPKER63HK2NUMF5Q",
}

local scriptUrl = Games[game.PlaceId]

if scriptUrl then
    print("🦅 Birdie Hub | Game Detected! Loading script...")
    -- This line fetches your code from GitHub and runs it
    loadstring(game:HttpGet(scriptUrl))()
else
    warn("🦅 Birdie Hub | This game is not supported yet.")
    -- Optional: You can put a 'Universal' script link here for fly/speed
end
