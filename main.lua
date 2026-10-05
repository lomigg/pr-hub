-- main.lua — PR Hub v1.1 — own GUI + Miranda features
-- Architecture: clean MVC, anti-duplicate, mobile+PC responsive GUI
-- Repo: lomigg/pr-hub (public)
-- GUI by BluezyGPT (PR Hub styling) - features powered by Miranda's scripts

-- ===================== SERVICES =====================
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local TextService       = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ===================== CLEANUP =====================
local HUB_ID = "PRHub_v1"
pcall(function()
    local old = CoreGui:FindFirstChild(HUB_ID)
    if old then old:Destroy() end
end)
pcall(function()
    if _G[HUB_ID .. "_Conns"] then
        for _, c in ipairs(_G[HUB_ID .. "_Conns"]) do
            pcall(function() c:Disconnect() end)
        end
    end
end)
_G[HUB_ID .. "_Conns"] = {}

local function trackConn(c)
    table.insert(_G[HUB_ID .. "_Conns"], c)
    return c
end

-- ===================== THEME (PR Hub red) =====================
local Theme = {
    Bg        = Color3.fromRGB(18, 18, 22),
    BgLight   = Color3.fromRGB(28, 28, 38),
    Accent    = Color3.fromRGB(220, 38, 44),    -- PR Hub red
    AccentHv  = Color3.fromRGB(255, 80, 90),
    Text      = Color3.fromRGB(235, 235, 245),
    TextDim   = Color3.fromRGB(150, 150, 165),
    Green     = Color3.fromRGB(72, 207, 173),
    Red       = Color3.fromRGB(235, 87, 87),
    Card      = Color3.fromRGB(34, 34, 46),
    Stroke    = Color3.fromRGB(50, 50, 65),
    Success   = Color3.fromRGB(72, 207, 173),
    Warn      = Color3.fromRGB(255, 184, 108),
}

-- ===================== UTILS =====================
local Utils = {}

function Utils.Tween(obj, props, time, dir)
    dir = dir or Enum.EasingDirection.Out
    time = time or 0.18
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, dir), props):Play()
end

function Utils.Round(obj, r)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, r or 8)
    corner.Parent = obj
end

function Utils.Stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    trackConn(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end))
    trackConn(handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

function Utils.IsMobile()
    return UserInputService.TouchEnabled
    and not UserInputService.MouseEnabled
end

-- ===================== NOTIFY SYSTEM =====================
local NotifySys = {}
local notifyHolder

function NotifySys.Init(parent)
    notifyHolder = Instance.new("Frame")
    notifyHolder.Name = "NotifyHolder"
    notifyHolder.Size = UDim2.new(0, 300, 1, -20)
    notifyHolder.Position = UDim2.new(1, -320, 0, 10)
    notifyHolder.BackgroundTransparency = 1
    notifyHolder.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = notifyHolder
end

function NotifySys.Push(title, msg, kind)
    kind = kind or "info"
    if not notifyHolder then return end

    local color = Theme.Accent
    if kind == "success" then color = Theme.Success
    elseif kind == "warn"  then color = Theme.Warn
    elseif kind == "error" then color = Theme.Red end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Theme.Card
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.Parent = notifyHolder
    Utils.Round(card, 8)
    Utils.Stroke(card, color, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = card
    Utils.Round(bar, 2)

    local title_l = Instance.new("TextLabel")
    title_l.BackgroundTransparency = 1
    title_l.Position = UDim2.new(0, 12, 0, 8)
    title_l.Size = UDim2.new(1, -16, 0, 16)
    title_l.Font = Enum.Font.GothamBold
    title_l.TextSize = 13
    title_l.TextColor3 = color
    title_l.TextXAlignment = Enum.TextXAlignment.Left
    title_l.Text = title
    title_l.Parent = card

    local msg_l = Instance.new("TextLabel")
    msg_l.BackgroundTransparency = 1
    msg_l.Position = UDim2.new(0, 12, 0, 26)
    msg_l.Size = UDim2.new(1, -16, 0, 14)
    msg_l.Font = Enum.Font.Gotham
    msg_l.TextSize = 12
    msg_l.TextColor3 = Theme.TextDim
    msg_l.TextXAlignment = Enum.TextXAlignment.Left
    msg_l.Text = msg
    msg_l.Parent = card

    local bounds = TextService:GetTextSize(msg, 12, Enum.Font.Gotham,
        Vector2.new(280, math.huge))
    card.Size = UDim2.new(1, 0, 0, bounds.Y + 44)

    card.Position = UDim2.new(1, 50, 0, 0)
    card.AnchorPoint = Vector2.new(0, 1)
    card.Position = UDim2.new(1, 50, 1, 0)
    Utils.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.25)

    task.delay(4, function()
        Utils.Tween(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)}, 0.3)
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ===================== WIDGETS =====================
local Widgets = {}

function Widgets.Toggle(text, default, callback)
    local state = default or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Theme.Card
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = nil
    Utils.Round(btn, 6)
    local stroke = Utils.Stroke(btn, Theme.Stroke, 1)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -48, 0.5, -9)
    track.BackgroundColor3 = state and Theme.Accent or Theme.Stroke
    track.BorderSizePixel = 0
    track.Parent = btn
    Utils.Round(track, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    Utils.Round(knob, 7)

    btn.MouseButton1Click:Connect(function()
        state = not state
        Utils.Tween(track, {BackgroundColor3 = state and Theme.Accent or Theme.Stroke})
        if state then
            Utils.Tween(knob, {Position = UDim2.new(1, -16, 0.5, -7)})
        else
            Utils.Tween(knob, {Position = UDim2.new(0, 2, 0.5, -7)})
        end
        if callback then callback(state) end
        NotifySys.Push("Toggle", text .. ": " .. (state and "ON" or "OFF"),
            state and "success" or "info")
    end)

    return btn
end

function Widgets.Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Card
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Theme.Text
    btn.Text = text
    btn.AutoButtonColor = false
    Utils.Round(btn, 6)
    local stroke = Utils.Stroke(btn, Theme.Stroke, 1)

    btn.MouseButton1Enter:Connect(function()
        Utils.Tween(btn, {BackgroundColor3 = Theme.Accent})
        Utils.Tween(stroke, {Color = Theme.AccentHv})
    end)
    btn.MouseButton1Leave:Connect(function()
        Utils.Tween(btn, {BackgroundColor3 = Theme.Card})
        Utils.Tween(stroke, {Color = Theme.Stroke})
    end)
    btn.MouseButton1Click:Connect(function()
        Utils.Tween(btn, {BackgroundColor3 = Theme.AccentHv}, 0.08)
        task.wait(0.08)
        Utils.Tween(btn, {BackgroundColor3 = Theme.Card})
        if callback then callback() end
    end)

    return btn
end

function Widgets.Label(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.Accent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    return lbl
end

-- ===================== MAIN GUI =====================
local Hub = {}

function Hub.Build()
    local gui = Instance.new("ScreenGui")
    gui.Name = HUB_ID
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = PlayerGui end

    NotifySys.Init(gui)

    local isMobile = Utils.IsMobile()
    local winW = isMobile and 320 or 560
    local winH = isMobile and 420 or 360

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, winW, 0, winH)
    window.Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2)
    window.BackgroundColor3 = Theme.Bg
    window.BorderSizePixel = 0
    window.Active = true
    window.Draggable = false
    window.Parent = gui
    Utils.Round(window, 10)
    Utils.Stroke(window, Theme.Stroke, 1)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Theme.BgLight
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    Utils.Round(titleBar, 10)

    local cover = Instance.new("Frame")
    cover.Size = UDim2.new(1, 0, 0, 12)
    cover.Position = UDim2.new(0, 0, 1, -12)
    cover.BackgroundColor3 = Theme.BgLight
    cover.BorderSizePixel = 0
    cover.Parent = titleBar

    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 16, 0, 16)
    logoFrame.Position = UDim2.new(0, 14, 0, 12)
    logoFrame.BackgroundColor3 = Theme.Accent
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = titleBar
    Utils.Round(logoFrame, 4)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 38, 0, 6)
    title.Size = UDim2.new(1, -100, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Text = "PR Hub"
    title.Parent = titleBar

    local versionLabel = Instance.new("TextLabel")
    versionLabel.BackgroundTransparency = 1
    versionLabel.Position = UDim2.new(0, 38, 0, 24)
    versionLabel.Size = UDim2.new(1, -100, 0, 12)
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 10
    versionLabel.TextColor3 = Theme.TextDim
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.TextYAlignment = Enum.TextYAlignment.Center
    versionLabel.Text = "v1.1 - PR Hub"
    versionLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -33, 0.5, -13)
    closeBtn.BackgroundColor3 = Theme.Red
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    Utils.Round(closeBtn, 6)

    local closeX = Instance.new("TextLabel")
    closeX.BackgroundTransparency = 1
    closeX.Size = UDim2.new(1, 0, 1, 0)
    closeX.Font = Enum.Font.GothamBold
    closeX.TextSize = 14
    closeX.TextColor3 = Theme.Text
    closeX.Text = "X"
    closeX.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        Utils.Tween(window, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.2)
        task.wait(0.22)
        gui:Destroy()
        NotifySys.Push("PR Hub", "Unload OK", "success")
    end)

    Utils.MakeDraggable(window, titleBar)

    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -24, 0, 32)
    tabBar.Position = UDim2.new(0, 12, 0, 50)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = window

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabBar

    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -24, 1, -94)
    contentArea.Position = UDim2.new(0, 12, 0, 88)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = window

    local pages = {}
    local tabBtns = {}

    local function switchTab(name)
        for n, page in pairs(pages) do
            page.Visible = (n == name)
        end
        for n, btn in pairs(tabBtns) do
            Utils.Tween(btn, {BackgroundColor3 = (n == name) and Theme.Accent or Theme.BgLight})
        end
    end

    function Hub.AddTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 0, 1, 0)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Theme.BgLight
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Theme.Text
        btn.Text = "  " .. name .. "  "
        btn.AutoButtonColor = false
        btn.Parent = tabBar
        Utils.Round(btn, 6)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.Parent = btn

        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabBtns[name] = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Theme.Stroke
        page.CanvasSize = UDim2.new(1, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = contentArea

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.Parent = page

        pages[name] = page
        return page
    end

    function Hub.SwitchTab(name) switchTab(name) end

    if isMobile then
        local floatBtn = Instance.new("TextButton")
        floatBtn.Size = UDim2.new(0, 44, 0, 44)
        floatBtn.Position = UDim2.new(0, 12, 0.5, -22)
        floatBtn.BackgroundColor3 = Theme.Accent
        floatBtn.Text = "P"
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextSize = 18
        floatBtn.TextColor3 = Theme.Text
        floatBtn.Parent = gui
        Utils.Round(floatBtn, 22)
        Utils.MakeDraggable(floatBtn)
        floatBtn.MouseButton1Click:Connect(function()
            window.Visible = not window.Visible
            if window.Visible then
                Utils.Tween(window, {Size = UDim2.new(0, winW, 0, winH)}, 0.2)
            end
        end)
    end

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 26, 0, 26)
    minBtn.Position = UDim2.new(1, -65, 0.5, -13)
    minBtn.BackgroundColor3 = Theme.Card
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    Utils.Round(minBtn, 6)

    local minIcon = Instance.new("TextLabel")
    minIcon.BackgroundTransparency = 1
    minIcon.Size = UDim2.new(1, 0, 1, 0)
    minIcon.Font = Enum.Font.GothamBold
    minIcon.TextSize = 14
    minIcon.TextColor3 = Theme.Text
    minIcon.Text = "_"
    minIcon.Parent = minBtn

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            contentArea.Visible = false
            tabBar.Visible = false
            Utils.Tween(window, {Size = UDim2.new(0, winW, 0, 40)}, 0.2)
        else
            Utils.Tween(window, {Size = UDim2.new(0, winW, 0, winH)}, 0.2, Enum.EasingDirection.Out)
            task.wait(0.2)
            contentArea.Visible = true
            tabBar.Visible = true
        end
    end)

    return Hub
end

-- ===================== MIRANDA FEATURE LOADERS =====================
-- These load Miranda's actual obfuscated scripts (kept original)

local MIRANDA = {
    -- luarmor loaders (Miranda's actual SAE / Anti-AFK scripts)
    SAE_LUARMOR     = "https://api.luarmor.net/files/v4/loaders/7891557d7950ed56a7d1d8f57b66ad4d.lua",
    ANTIAFK_LUARMOR = "https://api.luarmor.net/files/v4/loaders/6b07a458832f08b2314f706f14723212.lua",
    -- Local mirrors of Miranda's Luraph scripts (in our repo)
    SAE_LOCAL       = "https://raw.githubusercontent.com/lomigg/pr-hub/main/stealaegg",
    GAG2_LOCAL      = "https://raw.githubusercontent.com/lomigg/pr-hub/main/gag2.lua",
    ANTIAFK_LOCAL   = "https://raw.githubusercontent.com/lomigg/pr-hub/main/antiafk",
    UNIVERSAL_LOCAL = "https://raw.githubusercontent.com/lomigg/pr-hub/main/test.lua",
}

local function safeLoad(url, label)
    NotifySys.Push("PR Hub", "Loading: " .. label, "info")
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if ok then
            NotifySys.Push("PR Hub", label .. " loaded", "success")
        else
            NotifySys.Push("PR Hub", label .. " failed: " .. tostring(err):sub(1, 80), "error")
        end
    end)
end

-- ===================== BUILD PAGES =====================
local ok = pcall(function()
    Hub.Build()

    local pageMain = Hub.AddTab("Main")
    local pageScripts = Hub.AddTab("Scripts")
    local pageSettings = Hub.AddTab("Settings")

    -- ============= MAIN TAB =============
    local lblMain = Widgets.Label("QUICK ACTIONS")
    lblMain.Parent = pageMain

    local btnUnload = Widgets.Button("Unload PR Hub", function()
        NotifySys.Push("PR Hub", "Closing...", "warn")
        task.wait(0.3)
        local g = CoreGui:FindFirstChild(HUB_ID)
        if g then g:Destroy() end
    end)
    btnUnload.Parent = pageMain

    local btnCopyDiscord = Widgets.Button("Copy Discord", function()
        if setclipboard then setclipboard("https://discord.gg/bluezygpt") end
        NotifySys.Push("Discord", "Copied", "success")
    end)
    btnCopyDiscord.Parent = pageMain

    local btnRejoin = Widgets.Button("Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    btnRejoin.Parent = pageMain

    local lblMainInfo = Widgets.Label("INFO")
    lblMainInfo.Parent = pageMain
    local lblMainInfo2 = Widgets.Label("PR Hub v1.1 - GUI by BluezyGPT, features by Miranda")
    lblMainInfo2.Parent = pageMain

    -- ============= SCRIPTS TAB (Miranda features) =============
    local lblScr = Widgets.Label("STEAL AN EGG")
    lblScr.Parent = pageScripts

    local btnSAE_LU = Widgets.Button("Load SAE (Luarmor - latest)", function()
        safeLoad(MIRANDA.SAE_LUARMOR, "SAE Luarmor")
    end)
    btnSAE_LU.Parent = pageScripts

    local btnSAE_LCL = Widgets.Button("Load SAE (Local mirror)", function()
        safeLoad(MIRANDA.SAE_LOCAL, "SAE local")
    end)
    btnSAE_LCL.Parent = pageScripts

    local lblGag = Widgets.Label("GROW A GARDEN 2")
    lblGag.Parent = pageScripts

    local btnGag = Widgets.Button("Load GaG2 (Local mirror)", function()
        safeLoad(MIRANDA.GAG2_LOCAL, "GaG2")
    end)
    btnGag.Parent = pageScripts

    local lblAFK = Widgets.Label("ANTI-AFK")
    lblAFK.Parent = pageScripts

    local btnAFK_LU = Widgets.Button("Load Anti-AFK (Luarmor - latest)", function()
        safeLoad(MIRANDA.ANTIAFK_LUARMOR, "Anti-AFK Luarmor")
    end)
    btnAFK_LU.Parent = pageScripts

    local btnAFK_LCL = Widgets.Button("Load Anti-AFK (Local mirror)", function()
        safeLoad(MIRANDA.ANTIAFK_LOCAL, "Anti-AFK local")
    end)
    btnAFK_LCL.Parent = pageScripts

    local lblUni = Widgets.Label("UNIVERSAL")
    lblUni.Parent = pageScripts

    local btnUni = Widgets.Button("Load Universal Script", function()
        safeLoad(MIRANDA.UNIVERSAL_LOCAL, "Universal")
    end)
    btnUni.Parent = pageScripts

    -- ============= SETTINGS TAB =============
    local lblSet = Widgets.Label("INTERFACE")
    lblSet.Parent = pageSettings

    local togKeybind = Widgets.Toggle("Show Keybind (RightCtrl)", true, function(s) end)
    togKeybind.Parent = pageSettings

    local btnReload = Widgets.Button("Reload PR Hub", function()
        local g = CoreGui:FindFirstChild(HUB_ID)
        if g then g:Destroy() end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lomigg/pr-hub/main/main.lua"))()
    end)
    btnReload.Parent = pageSettings

    local lblSetInfo = Widgets.Label("CREDITS")
    lblSetInfo.Parent = pageSettings
    local lblSetInfo2 = Widgets.Label("GUI: BluezyGPT - Features: Miranda Hub")
    lblSetInfo2.Parent = pageSettings

    Hub.SwitchTab("Main")

    task.spawn(function()
        task.wait(0.5)
        NotifySys.Push("PR Hub v1.1", "Loaded - Hello BZMEMBER", "success")
        task.wait(2)
        NotifySys.Push("Tip", "Right-Ctrl toggle - Drag title bar", "info")
        task.wait(2)
        NotifySys.Push("Features", "Go to Scripts tab to load Miranda", "info")
    end)

    trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            local g = CoreGui:FindFirstChild(HUB_ID)
            if g then
                local w = g:FindFirstChild("Window")
                if w then w.Visible = not w.Visible end
            end
        end
    end))
end)

if not ok then
    warn("[PR Hub] build error - check syntax")
    error("PR Hub failed to initialize")
end
