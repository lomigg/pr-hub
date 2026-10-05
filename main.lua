-- PR Hub Loader v3 (Brand Hijacker Edition)
-- Rebranded from Miranda Hub for BZMEMBER
-- Repo: lomigg/pr-hub (public)
-- 
-- This loader intercepts the obfuscated Miranda script's GUI at runtime
-- and rewrites "Miranda" → "PR Hub" in all visible text labels.

pcall(function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local PlayerGui = lp:WaitForChild("PlayerGui")

    -- ============================================================
    -- BRAND REWRITE TABLE
    -- ============================================================
    -- Every string matching these patterns gets rewritten before display.
    local REWRITES = {
        -- Brand name (case-sensitive)
        ["MIRANDA HUB"]        = "PR HUB",
        ["Miranda Hub"]        = "PR Hub",
        ["MIRANDA"]            = "PR HUB",
        ["Miranda"]            = "PR Hub",
        ["miranda"]            = "pr hub",
        ["MIRANDAHUB"]         = "PRHUB",
        ["MirandaHub"]         = "PRHub",
        ["mirandahub"]         = "prhub",
        -- ScreenGui names (also caught by GUI renamer below)
        ["MirandaUpdatedUI"]   = "PRHubUI",
        ["MirandaUI"]          = "PRHubUI",
        ["MirandaMainUI"]      = "PRHubUI",
        -- Discord link swap
        ["https://discord.gg/8cqVS3DUzu"] = "https://discord.gg/bluezygpt",
        ["discord.gg/8cqVS3DUzu"]         = "discord.gg/bluezygpt",
        -- Common Miranda update nag text
        ["Get the updated version now in our official Discord."] = "PR Hub - join Discord for updates.",
        ["UPDATED!!!"]         = "PR HUB",
        ["COPY DISCORD"]       = "JOIN DISCORD",
        ["COPY"]               = "JOIN",
    }

    -- Apply rewrites to a single string
    local function rewriteString(s)
        if type(s) ~= "string" then return s end
        local out = s
        for old, new in pairs(REWRITES) do
            -- Use plain find (no pattern) for safety
            out = string.gsub(out, old, new)
        end
        -- Catch RichText color spans like <font color="...">MIRANDA</font>
        -- → <font color="...">PR HUB</font> (already handled by direct gsub above)
        return out
    end

    -- ============================================================
    -- 1. POPUP KILLER + BRAND REWRITER (continuous scan)
    -- ============================================================
    local POPUP_NAMES_TO_KILL = {
        "Outdated", "UpdatePopup", "DiscordPopup", "VersionPopup",
    }
    local POPUP_TEXT_TO_KILL = {
        "outdated", "get the updated", "updated version", "official discord",
    }

    task.spawn(function()
        while task.wait(0.2) do
            pcall(function()
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local name = gui.Name
                        local kill = false
                        for _, pat in ipairs(POPUP_NAMES_TO_KILL) do
                            if name == pat then kill = true break end
                        end
                        if not kill then
                            for _, desc in ipairs(gui:GetDescendants()) do
                                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                    local t = (desc.Text or ""):lower()
                                    for _, pat in ipairs(POPUP_TEXT_TO_KILL) do
                                        if t:find(pat, 1, true) then
                                            kill = true
                                            break
                                        end
                                    end
                                    if kill then break end
                                end
                            end
                        end
                        if kill then
                            gui:Destroy()
                        end
                    end
                end
            end)
        end
    end)

    -- ============================================================
    -- 2. CONTINUOUS BRAND REWRITER (after script loads)
    -- ============================================================
    -- Walk every GUI descendant and rewrite TextLabel/TextButton text.
    task.spawn(function()
        while task.wait(0.3) do
            pcall(function()
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        -- Rename ScreenGui itself
                        if REWRITES[gui.Name] then
                            pcall(function() gui.Name = REWRITES[gui.Name] end)
                        end
                        for _, desc in ipairs(gui:GetDescendants()) do
                            -- Rename instances
                            if REWRITES[desc.Name] then
                                pcall(function() desc.Name = REWRITES[desc.Name] end)
                            end
                            -- Rewrite text
                            if desc:IsA("TextLabel") or desc:IsA("TextButton")
                               or desc:IsA("TextBox") then
                                local t = desc.Text
                                if t and #t > 0 then
                                    local new = rewriteString(t)
                                    if new ~= t then
                                        pcall(function() desc.Text = new end)
                                    end
                                end
                                -- Also rewrite PlaceholderText for TextBoxes
                                if desc:IsA("TextBox") and desc.PlaceholderText then
                                    local p = desc.PlaceholderText
                                    local np = rewriteString(p)
                                    if np ~= p then
                                        pcall(function() desc.PlaceholderText = np end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- ============================================================
    -- 3. HOOK Instance.new — intercept TextLabel creation
    -- ============================================================
    -- When Miranda script calls Instance.new("TextLabel"), we wrap the
    -- returned object so any subsequent .Text = "..." gets rewritten.
    pcall(function()
        if not hookmetamethod then return end
        local originalNew = Instance.new
        local mt = getrawmetatable(game)
        setreadonly(mt, false)

        -- Hook __namecall to catch :SetText() style calls (rare in Roblox but possible)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure and newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "SetText" then
                local args = {...}
                for i, a in ipairs(args) do
                    if type(a) == "string" then
                        args[i] = rewriteString(a)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
            return oldNamecall(self, ...)
        end) or oldNamecall

        setreadonly(mt, true)
    end)

    -- ============================================================
    -- 4. HOOK __newindex — catch .Text = "..." assignments
    -- ============================================================
    -- This catches when Miranda sets TextLabel.Text = "MIRANDA HUB"
    -- We intercept and rewrite before it's stored.
    pcall(function()
        if not hookmetamethod then return end
        local mt = getrawmetatable(game)
        setreadonly(mt, false)

        local oldNewindex = mt.__newindex
        mt.__newindex = newcclosure and newcclosure(function(self, k, v)
            if (k == "Text" or k == "PlaceholderText" or k == "Name") and type(v) == "string" then
                local new = rewriteString(v)
                if new ~= v then
                    v = new
                end
            end
            return oldNewindex(self, k, v)
        end) or oldNewindex

        setreadonly(mt, true)
    end)

    -- ============================================================
    -- 5. LOAD TARGET SCRIPT — go straight to luarmor for SAE
    -- ============================================================
    local url
    if game.PlaceId == 107778070777162 then
        -- Steal An Egg — load Miranda's luarmor loader directly
        url = "https://api.luarmor.net/files/v4/loaders/7891557d7950ed56a7d1d8f57b66ad4d.lua"
    elseif game.GameId == 10200395747 then
        -- Grow A Garden 2
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/gag2.lua"
    else
        -- Default — universal test script
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/test.lua"
    end

    print("[PR Hub] Loading target: " .. url)
    print("[PR Hub] Brand hijacker active - rewriting Miranda → PR Hub")
    loadstring(game:HttpGet(url))()
end)
