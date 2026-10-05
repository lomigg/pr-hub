-- PR Hub Loader
-- Rebranded from Miranda Hub for BZMEMBER
-- Repo: lomigg/pr-hub (public)
-- Routes to the right script based on PlaceId / GameId

pcall(function()
    local url
    if game.PlaceId == 107778070777162 then
        -- Steal An Egg
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/stealaegg"
    elseif game.GameId == 10200395747 then
        -- Grow A Garden 2
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/gag2.lua"
    else
        -- Default: load test.lua (universal)
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/test.lua"
    end
    loadstring(game:HttpGet(url))()
end)
