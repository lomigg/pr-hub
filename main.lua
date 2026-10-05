-- PR Hub Loader v2 (Popup Killer Edition)
-- Rebranded from Miranda Hub for BZMEMBER
-- Repo: lomigg/pr-hub (public)

pcall(function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- ============================================================
    -- POPUP KILLER — auto-destroy any "updated/discord" popup GUI
    -- ============================================================
    -- Miranda's obfuscated scripts spawn a popup forcing you to Discord.
    -- We kill any ScreenGui matching that pattern as soon as it appears.
    pcall(function()
        local PlayerGui = lp:WaitForChild("PlayerGui")
        local POPUP_NAMES = {
            "PRHubUI", "MirandaUpdatedUI", "MirandaUI", "Updated",
            "UpdatePopup", "DiscordPopup", "VersionPopup", "Outdated",
        }
        task.spawn(function()
            while task.wait(0.2) do
                pcall(function()
                    for _, gui in ipairs(PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") then
                            local name = gui.Name
                            local kill = false
                            for _, pat in ipairs(POPUP_NAMES) do
                                if name == pat then kill = true break end
                            end
                            -- Also kill if it has a "JOIN DISCORD" / "COPY DISCORD" / "Get updated" button
                            if not kill then
                                for _, desc in ipairs(gui:GetDescendants()) do
                                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                        local t = (desc.Text or ""):lower()
                                        if t:find("join discord") or t:find("copy discord")
                                           or t:find("get the updated") or t:find("updated version")
                                           or t:find("official discord") then
                                            kill = true
                                            break
                                        end
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
        -- Also catch popups added later
        PlayerGui.ChildAdded:Connect(function(child)
            task.wait(0.3)
            if child:IsA("ScreenGui") then
                local kill = false
                for _, pat in ipairs(POPUP_NAMES) do
                    if child.Name == pat then kill = true break end
                end
                if kill then child:Destroy() end
            end
        end)
    end)

    -- ============================================================
    -- LOAD TARGET SCRIPT — go straight to luarmor for SAE (skip popup)
    -- ============================================================
    local url
    if game.PlaceId == 107778070777162 then
        -- Steal An Egg — load Miranda's luarmor loader directly (their actual SAE script)
        -- This skips the popup wrapper that forces Discord join
        url = "https://api.luarmor.net/files/v4/loaders/7891557d7950ed56a7d1d8f57b66ad4d.lua"
    elseif game.GameId == 10200395747 then
        -- Grow A Garden 2 — Luraph script (no popup wrapper, just the script)
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/gag2.lua"
    else
        -- Default — universal test script
        url = "https://raw.githubusercontent.com/lomigg/pr-hub/main/test.lua"
    end

    loadstring(game:HttpGet(url))()
end)
