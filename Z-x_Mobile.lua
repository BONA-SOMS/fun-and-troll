
print("Z-x Loading")
print("WSP")
print("MY")
print("NIGGAS")
print("")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Mouse = LocalPlayer:GetMouse()


if not cloneref then getgenv().cloneref = function(instance) return instance end end
local Library = (function()

return function(ui)
    local L = {Options = {}, Toggles = {}, cleanup = {}, native = ui}
    local Options, Toggles = L.Options, L.Toggles
    local function call(fn, ...) if fn then return fn(...) end end
    local function key(v)
        if typeof(v) == "EnumItem" then return v end
        if v == "MB1" then return Enum.UserInputType.MouseButton1 end
        if v == "MB2" then return Enum.UserInputType.MouseButton2 end
        if not v or v == "None" then return nil end
        return Enum.KeyCode[v]
    end
    local function register(id, api, kind)
        api.Type = kind
        Options[id] = api
        if kind == "Toggle" then
            Toggles[id] = api
            if id == "AutoStrafeToggle" then Options.AutoStrafeEnabled = api end
        end
        if ui.ConfigItems and ui.ConfigItems[id] and kind ~= "KeyPicker" and kind ~= "ColorPicker" then
            function api:Get()
                if kind == "Dropdown" and api.Multi then
                    local list = {} for _, name in ipairs(api.Values) do if api.Value[name] then list[#list + 1] = name end end
                    return list
                end
                return api.Value
            end
            ui.ConfigItems[id].api = api
        end
        return api
    end
    local Group = {}
    Group.__index = Group
    local TextService = game:GetService("TextService")
    local KB = {
        Enabled = true,
        H = 14, GAP = 2, PAD = 6, ICON = 10, ICON_GAP = 5, FADE = 40,
        FONT = Enum.Font.GothamMedium, TEXT_SIZE = 11,
        ALPHA = 0.3, TWEEN = 0.18,
        ACCENT = Color3.fromRGB(245, 49, 116),
        TAB_ICONS = {
            ["Movement Physics"] = "rbxassetid://10747373176", ["Legacy Tools"] = "rbxassetid://10723407335",
            ["Hitbox Creator"] = "rbxassetid://10709782497", ["Visuals"] = "rbxassetid://10723346959",
            ["Adjust Lighting"] = "rbxassetid://10734974297", ["Post Effects"] = "rbxassetid://10747376565",
            ["FFlags Injector"] = "rbxassetid://10734975932", ["Misc"] = "rbxassetid://10709811595",
            ["Emotes"] = "rbxassetid://10734964441", ["Nametags"] = "rbxassetid://10734976528",
            ["System Settings"] = "rbxassetid://10734950309",
            ["Anti Aim"] = "rbxassetid://10734951847",
            ["Addons"] = "rbxassetid://10709782497",
        },
    }
    L.KeybindHUD = KB
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "Z-xKeybindHUD"
    hudGui.ResetOnSpawn = false
    hudGui.IgnoreGuiInset = true
    hudGui.DisplayOrder = 100
    do
        local ok, root = pcall(function() return gethui and gethui() end)
        hudGui.Parent = (ok and root) or CoreGui
    end
    L.cleanup[#L.cleanup + 1] = function() hudGui:Destroy() end

    local records, order = {}, {}
    local function relayout()
        for i, entry in ipairs(order) do
            TweenService:Create(entry.frame, TweenInfo.new(KB.TWEEN, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0.5, (i - 1) * (KB.H + KB.GAP))}):Play()
        end
    end
    local function isOn(rec)
        if rec.parent and rec.parent.Type == "Toggle" then return rec.parent.Value == true end
        return rec.api.active == true
    end
    local function show(rec)
        local keyText = rec.api.Value ~= "None" and tostring(rec.api.Value) or "-"
        local str = rec.text .. " | " .. keyText
        local textW = TextService:GetTextSize(str, KB.TEXT_SIZE, KB.FONT, Vector2.new(1000, KB.H)).X
        local width = KB.PAD + KB.ICON + KB.ICON_GAP + textW + KB.PAD + KB.FADE
        local frame = Instance.new("CanvasGroup")
        frame.Name = "Bind_" .. rec.id
        frame.AnchorPoint = Vector2.new(0, 0.5)
        frame.Size = UDim2.fromOffset(width, KB.H)
        frame.Position = UDim2.new(0, -12, 0.5, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.GroupTransparency = 1
        local fade = Instance.new("UIGradient")
        local fadeStart = math.clamp(1 - KB.FADE / width, 0.05, 0.95)
        fade.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, KB.ALPHA),
            NumberSequenceKeypoint.new(fadeStart, KB.ALPHA),
            NumberSequenceKeypoint.new(1, 1),
        })
        fade.Parent = frame
        local iconId = KB.TAB_ICONS[rec.tab]
        local icon = Instance.new(iconId and "ImageLabel" or "Frame")
        icon.BackgroundTransparency = iconId and 1 or 0
        icon.BackgroundColor3 = KB.ACCENT
        icon.BorderSizePixel = 0
        if iconId then icon.Image = iconId; icon.ImageColor3 = KB.ACCENT end
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, KB.PAD, 0.5, 0)
        icon.Size = UDim2.fromOffset(KB.ICON, KB.ICON)
        icon.Parent = frame
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Font = KB.FONT
        label.TextSize = KB.TEXT_SIZE
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.fromOffset(KB.PAD + KB.ICON + KB.ICON_GAP, 0)
        label.Size = UDim2.new(0, textW, 1, 0)
        label.Text = str
        label.Parent = frame
        frame.Parent = hudGui
        local entry = {frame = frame, key = rec.api.Value}
        rec.entry = entry
        table.insert(order, 1, entry)
        TweenService:Create(frame, TweenInfo.new(KB.TWEEN), {GroupTransparency = 0}):Play()
        relayout()
    end
    local function hide(rec)
        local entry = rec.entry
        rec.entry = nil
        local idx = table.find(order, entry)
        if idx then table.remove(order, idx) end
        relayout()
        local tw = TweenService:Create(entry.frame, TweenInfo.new(KB.TWEEN), {GroupTransparency = 1})
        tw.Completed:Once(function() entry.frame:Destroy() end)
        tw:Play()
    end
    local hudConn = RunService.Heartbeat:Connect(function()
        for _, rec in ipairs(records) do
            local on = KB.Enabled and (not L.KeybindFrame or L.KeybindFrame.Visible) and isOn(rec)
            if on and not rec.entry then show(rec)
            elseif not on and rec.entry then hide(rec)
            elseif on and rec.entry.key ~= rec.api.Value then hide(rec); show(rec) end
        end
    end)
    L.cleanup[#L.cleanup + 1] = function() hudConn:Disconnect() end
    local function decorate(api, group, text)
        function api:AddColorPicker(id, cfg) return group:AddColorPicker(id, cfg, text) end
        function api:AddKeyPicker(id, cfg) return group:AddKeyPicker(id, cfg, api, text) end
        return api
    end
    function Group:AddToggle(id, cfg)
        local api = {Value = cfg.Default == true}
        local widget
        local function changed(v)
            if api.Value == v then return end
            api.Value = v
            call(cfg.Callback, v)
        end
        widget = self.section:Checkbox(cfg.Text or id, api.Value, changed, {flag = id})
        function api:SetValue(v)
            v = v == true
            if api.Value == v then return end
            widget:Set(v)
            changed(v)
        end
        api.Set = api.SetValue
        return decorate(register(id, api, "Toggle"), self, cfg.Text or id)
    end
    function Group:AddSlider(id, cfg)
        local api = {Value = cfg.Default or cfg.Min}
        local function changed(v)
            local power = 10 ^ (cfg.Rounding or 0)
            v = math.floor(v * power + 0.5) / power
            if api.Value == v then return end
            api.Value = v
            call(cfg.Callback, v)
        end
        local fmt = "%0." .. tostring(cfg.Rounding or 0) .. "f" .. tostring(cfg.Suffix or ""):gsub("%%", "%%%%")
        local widget = self.section:SliderFloat(cfg.Text or id, cfg.Min, cfg.Max, api.Value, changed, fmt, id)
        function api:SetValue(v) widget:Set(v); changed(widget:Get()) end
        api.Set = api.SetValue
        return register(id, api, "Slider")
    end
    function Group:AddInput(id, cfg)
        local api = {Value = tostring(cfg.Default or "")}
        local widget
        local function changed(v)
            if cfg.Numeric and v ~= "" and not tonumber(v) then widget:Set(api.Value); return end
            if api.Value == v then return end
            api.Value = v
            call(cfg.Callback, v)
        end
        widget = self.section:TextInput(cfg.Text or id, api.Value, changed, cfg.Placeholder, id)
        function api:SetValue(v) widget:Set(tostring(v)); changed(widget:Get()) end
        api.Set = api.SetValue
        return register(id, api, "Input")
    end
    function Group:AddDropdown(id, cfg)
        local values = cfg.Values or {}
        local default = cfg.Default
        if type(default) == "number" then default = values[default] end
        local api = {Value = cfg.Multi and {} or default, Values = values, Multi = cfg.Multi}
        local widget
        local function changed(v)
            if cfg.Multi then
                local map = {} for _, name in ipairs(v) do map[name] = true end
                api.Value = map
            else
                if api.Value == v then return end
                api.Value = v
            end
            call(cfg.Callback, api.Value)
        end
        if cfg.Multi then
            local selected = {}
            if type(default) == "table" then
                for k, v in pairs(default) do selected[#selected + 1] = type(k) == "number" and v or k end
            elseif default then selected = {default} end
            api.Value = {} for _, v in ipairs(selected) do api.Value[v] = true end
            widget = self.section:MultiCombo(cfg.Text or id, values, selected, changed, id)
        else
            widget = self.section:Combo(cfg.Text or id, values, default, changed, id)
            api.Value = widget:Get()
        end
        function api:SetValue(v)
            if cfg.Multi then
                local list = {} for k, value in pairs(v or {}) do if value then list[#list + 1] = type(k) == "number" and value or k end end
                widget:Set(list); changed(list)
            else widget:Set(v); changed(widget:Get()) end
        end
        api.Set = api.SetValue
        function api:SetValues(v) api.Values = v; widget:SetItems(v, api.Value, true) end
        if cfg.Searchable then
            self.section:TextInput("Search " .. (cfg.Text or id), "", function(query)
                local filtered = {}
                for _, name in ipairs(api.Values) do
                    if tostring(name):lower():find(tostring(query):lower(), 1, true) then filtered[#filtered + 1] = name end
                end
                widget:SetItems(filtered, api.Value, true)
            end, "Filter catalogue…", "__search_" .. id)
            ui.ConfigIgnore["__search_" .. id] = true
        end
        return register(id, api, "Dropdown")
    end
    function Group:AddColorPicker(id, cfg, text)
        local api = {Value = cfg.Default, Transparency = cfg.Transparency or 0}
        local function changed(v, a)
            api.Value, api.Transparency = v, 1 - (a or 1)
            call(cfg.Callback, v)
        end
        local widget = self.section:ColorPicker(cfg.Title or text or id, cfg.Default, changed, 1 - api.Transparency, id)
        function api:SetValueRGB(v, transparency) widget:Set(v, 1 - (transparency or 0)); changed(v, 1 - (transparency or 0)) end
        api.SetValue = api.SetValueRGB
        api.Set = api.SetValueRGB
        return register(id, api, "ColorPicker")
    end
    function Group:AddKeyPicker(id, cfg, parent, text)
        local api = {Value = cfg.Default or "None", Mode = cfg.Mode or "Toggle", active = false}
        local modes = {Hold = "On Hotkey", Toggle = "Toggle", Always = "Always On", Press = "On Hotkey"}
        local function changed(k)
            api.Value = k and k.Name or "None"
            if id == "MenuKeybind" then ui.ToggleKey = k end
            call(cfg.ChangedCallback, k or Enum.KeyCode.Unknown)
        end
        local widget = self.section:Keybind(cfg.Text or text or id, key(api.Value), changed, id, {
            mode = modes[api.Mode], noModeMenu = cfg.NoUI or cfg.Mode == "Press",
            onMode = function(mode) api.Mode = mode == "On Hotkey" and "Hold" or mode == "Always On" and "Always" or "Toggle" end,
            onActive = function(active)
                api.active = active
                if cfg.SyncToggleState and parent and parent.SetValue then
                    if api.Mode == "Toggle" then parent:SetValue(not parent.Value) else parent:SetValue(active) end
                end
                if cfg.Mode ~= "Press" or active then call(cfg.Callback, active) end
            end,
        })
        if id == "MenuKeybind" then ui:SetToggleKey(key(api.Value)) end
        function api:SetValue(v)
            local mode = type(v) == "table" and v[2] or api.Mode
            local value = type(v) == "table" and v[1] or v
            widget:SetMode(modes[mode] or "Toggle"); widget:Set(key(value)); changed(key(value))
        end
        function api:GetState() return api.active end
        register(id, api, "KeyPicker")
        if id ~= "MenuKeybind" and cfg.Mode ~= "Press" and not cfg.NoUI then
            records[#records + 1] = {id = id, api = api, parent = parent, text = cfg.Text or text or id, tab = self.tabName}
        end
        return api
    end
    function Group:AddLabel(text)
        local widget = self.section:Label(text)
        local api = {}
        function api:SetText(v) widget:Set(v) end
        return decorate(api, self, text)
    end
    function Group:AddButton(cfg, fn)
        local text = type(cfg) == "table" and cfg.Text or cfg
        self.section:Button(text, type(cfg) == "table" and cfg.Func or fn)
        return decorate({}, self, text)
    end
    function Group:AddDivider() return self.section:Separator() end
    function Group:AddCustomFrame(height) return self.section:CustomFrame(height) end
    function L:CreateWindow()
        local window = {}
        function window:AddTab(name)
            local pages = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"}
            local native = ui:AddTab(name, pages)
            local tab = {name = name, counts = {0, 0}, native = native}
            local function add(title, column)
                tab.counts[column] = tab.counts[column] + 1
                local n = tab.counts[column]
                assert(n <= #pages, "Too many groups in " .. name)
                return setmetatable({section = ui:AddSection(name, pages[n], title, column, 440), tabName = name}, Group)
            end
            function tab:AddLeftGroupbox(title) return add(title, 1) end
            function tab:AddRightGroupbox(title) return add(title, 2) end
            return tab
        end
        return window
    end
    function L:Finalize()
        if Toggles.ToggleWatermarkVisibility then
            getgenv().WatermarkEnabled = Toggles.ToggleWatermarkVisibility.Value
            self:SetWatermarkVisibility(Toggles.ToggleWatermarkVisibility.Value)
        end
        for _, tab in ipairs(ui.Tabs) do
            local used = 1
            for i, page in ipairs(tab.pages) do if #page.sections > 0 then used = i end end
            for i, entry in ipairs(tab.subButtons) do
                entry.button.Visible = i <= used
                entry.button.Size = UDim2.new(1 / used, 0, 0, 22)
                entry.button.Position = UDim2.new((i - 1) / used, 0, 0, 0)
            end
        end
        ui:SetWindowSize(620, 440)
    end
    function L:OnUnload(fn) self.cleanup[#self.cleanup + 1] = fn end
    local destroy = ui.Destroy
    function ui:Destroy()
        if L.Unloaded then return end
        L.Unloaded = true
        for _, fn in ipairs(L.cleanup) do local ok, err = pcall(fn); if not ok then warn(err) end end
        destroy(self)
    end
    ui.Unload = ui.Destroy
    function L:Unload() ui:Destroy() end
    function L:Notify(cfg)
        if ui.Notify and ui:Notify(cfg) then return end
        local frame = Instance.new("TextLabel")
        frame.Size = UDim2.fromOffset(340, 72)
        frame.Position = UDim2.new(1, -350, 1, -82)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        frame.TextColor3 = Color3.new(1, 1, 1)
        frame.Font = Enum.Font.GothamMedium
        frame.TextSize = 14
        frame.TextWrapped = true
        frame.Text = tostring(cfg.Title or "Z-x") .. "\n" .. tostring(cfg.Description or "")
        frame.Parent = ui.Gui
        task.delay(cfg.Time or cfg.Duration or 4, function() frame:Destroy() end)
    end
        local WM = {TEXT_SIZE = 13, PAD_Y = 8, FADE = 26, ALPHA = 0.3, ACCENT = Color3.fromRGB(245, 49, 116)}
    local watermark = Instance.new("Frame")
    watermark.Name = "Z-xWatermark"
    watermark.AnchorPoint = Vector2.new(0.5, 1)
    watermark.Position = UDim2.new(0.5, 0, 1, -14)
    watermark.AutomaticSize = Enum.AutomaticSize.X
    watermark.Size = UDim2.new(0, 0, 0, WM.TEXT_SIZE + WM.PAD_Y)
    watermark.BackgroundColor3 = Color3.new(0, 0, 0)
    watermark.BorderSizePixel = 0
    watermark.Visible = false
    local wmFade = Instance.new("UIGradient")
    wmFade.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.22, WM.ALPHA),
        NumberSequenceKeypoint.new(0.78, WM.ALPHA), NumberSequenceKeypoint.new(1, 1),
    })
    wmFade.Parent = watermark
    local wmPad = Instance.new("UIPadding")
    wmPad.PaddingLeft = UDim.new(0, WM.FADE)
    wmPad.PaddingRight = UDim.new(0, WM.FADE)
    wmPad.Parent = watermark
    local wmLine = Instance.new("Frame")
    wmLine.BackgroundColor3 = WM.ACCENT
    wmLine.BorderSizePixel = 0
    wmLine.Position = UDim2.new(0, -WM.FADE, 0, 0)
    wmLine.Size = UDim2.new(1, 2 * WM.FADE, 0, 1)
    local wmLineFade = Instance.new("UIGradient")
    wmLineFade.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0), NumberSequenceKeypoint.new(1, 1),
    })
    wmLineFade.Parent = wmLine
    wmLine.Parent = watermark
    local wmLabel = Instance.new("TextLabel")
    wmLabel.BackgroundTransparency = 1
    wmLabel.AutomaticSize = Enum.AutomaticSize.X
    wmLabel.Size = UDim2.new(0, 0, 1, 0)
    wmLabel.Font = Enum.Font.GothamBold
    wmLabel.TextSize = WM.TEXT_SIZE
    wmLabel.TextColor3 = Color3.new(1, 1, 1)
    wmLabel.TextStrokeTransparency = 0.6
    wmLabel.RichText = true
    wmLabel.Text = ""
    wmLabel.Parent = watermark
    watermark.Parent = ui.Gui
    local wmVisible, wmText = false, ""
    local function wmRefresh() watermark.Visible = wmVisible and wmText ~= "" end
    function L:SetWatermark(text) wmText = tostring(text or ""); wmLabel.Text = wmText; wmRefresh() end
    function L:SetWatermarkVisibility(v) wmVisible = v == true; wmRefresh() end
    function L:SetWatermarkStats(fps, ping)
        local sep = '<font color="#8c8c8c"> | </font>'
        L:SetWatermark('Z-x' .. sep .. tostring(fps) .. ' fps' .. sep .. tostring(ping) .. ' ms')
    end
    local bindFrame = Instance.new("TextLabel")
    bindFrame.Size = UDim2.fromOffset(230, 300); bindFrame.Position = UDim2.new(0, 12, 0.5, -150)
    bindFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26); bindFrame.TextColor3 = Color3.new(1, 1, 1)
    bindFrame.Font = Enum.Font.GothamMedium; bindFrame.TextSize = 13; bindFrame.TextYAlignment = Enum.TextYAlignment.Top
    bindFrame.Visible = false; bindFrame.Parent = ui.Gui; L.KeybindFrame = bindFrame
    bindFrame.BackgroundTransparency = 1; bindFrame.TextTransparency = 1; bindFrame.TextStrokeTransparency = 1; bindFrame.Size = UDim2.fromOffset(0, 0)
    ui.Connections[#ui.Connections + 1] = game:GetService("RunService").RenderStepped:Connect(function()
        if not bindFrame.Visible then return end
        local lines = {"Keybinds"}
        for id, api in pairs(Options) do if api.Type == "KeyPicker" then lines[#lines + 1] = id .. " [" .. api.Value .. "]" end end
        table.sort(lines); bindFrame.Text = table.concat(lines, "\n")
    end)
    return L
end

end)()((function()







local ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer


local BRAND = "Z-x"
local MENU_KEY_DEFAULT = "RightControl"
local WINDOW_SIZE = UDim2.new(0, 620, 0, 440)
local CONFIG_NAME, CONFIG_FOLDER = "SW", "SpermaConfigs"
local FATALITY_SRC = "https://raw.githubusercontent.com/ImInsane-1337/Fatality-UI/main/src/source.luau"
local FATALITY_CACHE = "fatality_lib_src.luau"

local TAB_TITLE = {
	["Movement Physics"] = "MOVEMENT", ["Legacy Tools"] = "LEGACY", ["Hitbox Creator"] = "HITBOX",
	["Visuals"] = "VISUALS", ["Effects"] = "EFFECTS", ["Adjust Lighting"] = "LIGHTING",
	["Post Effects"] = "POST FX", ["FFlags Injector"] = "FFLAGS", ["Misc"] = "MISC",
	["Emotes"] = "EMOTES", ["Nametags"] = "NAMETAGS", ["System Settings"] = "SETTINGS", ["Addons"] = "ADDONS", ["Anti Aim"] = "ANTI AIM",
}
local TAB_ICON = {
	["Movement Physics"] = "user", ["Legacy Tools"] = "history", ["Hitbox Creator"] = "box",
	["Visuals"] = "eye", ["Effects"] = "sparkles", ["Adjust Lighting"] = "sun",
	["Post Effects"] = "wand", ["FFlags Injector"] = "syringe", ["Misc"] = "component",
	["Emotes"] = "smile", ["Nametags"] = "tag", ["System Settings"] = "settings", ["Addons"] = "plug", ["Anti Aim"] = "shield",
}


for _, key in ipairs({"__SW_UI", "__MILLIONWARE_SLATE"}) do
	local prev = ENV[key]
	if prev and type(prev.Destroy) == "function" then pcall(function() prev:Destroy() end) end
	ENV[key] = nil
end


local function loadFatality()
	local src
	local ok, res = pcall(function() return game:HttpGet(FATALITY_SRC) end)
	if ok and type(res) == "string" and #res > 1000 then
		src = res
		if typeof(writefile) == "function" then pcall(writefile, FATALITY_CACHE, res) end
	elseif typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(FATALITY_CACHE) then
		src = readfile(FATALITY_CACHE)
	end
	assert(src, "[SW] Fatality UI source unavailable: HttpGet failed and no cached copy")
	local fn, err = loadstring(src)
	assert(fn, "[SW] Fatality UI source does not compile: " .. tostring(err))
	local lib = fn()
	assert(type(lib) == "table" and lib.new and lib.Loader, "[SW] Fatality UI did not return the expected table")
	return lib
end
local Fatality = loadFatality()



local rawCreateElements = Fatality.CreateElements
Fatality.CreateElements = function(self, Parent, ZIndex, Event, SearchAPI)
	local el = rawCreateElements(self, Parent, ZIndex, Event, SearchAPI)
	if type(el) == "table" then el.__parent, el.__zindex, el.__event = Parent, ZIndex, Event end
	return el
end


local winCfg = {Name = BRAND, Keybind = MENU_KEY_DEFAULT, Expire = "never", Scale = WINDOW_SIZE}
pcall(function() Fatality:Loader({Name = BRAND, Duration = 3}) end)
local knownGuis = {}
for g in pairs(Fatality.WindowFlags) do knownGuis[g] = true end
local Window = Fatality.new(winCfg)
local fatGui
for g in pairs(Fatality.WindowFlags) do if not knownGuis[g] then fatGui = g end end

-- Z-x requested background image (kept behind the window's existing controls).
pcall(function()
    if fatGui then
        local root
        local largest = -1
        for _, obj in ipairs(fatGui:GetDescendants()) do
            if obj:IsA("Frame") then
                local area = obj.AbsoluteSize.X * obj.AbsoluteSize.Y
                if area > largest then
                    largest = area
                    root = obj
                end
            end
        end
        if root then
            local background = Instance.new("ImageLabel")
            background.Name = "ZX_BackgroundImage"
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromScale(1, 1)
            background.Position = UDim2.fromScale(0, 0)
            background.Image = "rbxassetid://6942501524"
            background.ScaleType = Enum.ScaleType.Crop
            background.ImageTransparency = 0.12
            background.ZIndex = root.ZIndex
            background.Parent = root
            pcall(function() background.Active = false end)
        end
    end
end)

-- Floating Z-x icon: tap to show/hide the menu; drag with touch or mouse to reposition.
do
    local floatingGui = Instance.new("ScreenGui")
    floatingGui.Name = "ZX_FloatingIcon"
    floatingGui.ResetOnSpawn = false
    floatingGui.IgnoreGuiInset = true
    floatingGui.DisplayOrder = 10000
    local floatingParent = CoreGui
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then floatingParent = hui end
    end
    local parentOK = pcall(function() floatingGui.Parent = floatingParent end)
    if not parentOK then floatingGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local iconButton = Instance.new("ImageButton")
    iconButton.Name = "ZX_FloatingButton"
    iconButton.Size = UDim2.fromOffset(52, 52)
    iconButton.Position = UDim2.new(0, 16, 0.48, 0)
    iconButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    iconButton.BackgroundTransparency = 0.12
    iconButton.BorderSizePixel = 0
    iconButton.AutoButtonColor = false
    iconButton.Image = "rbxassetid://7903525711"
    iconButton.ScaleType = Enum.ScaleType.Fit
    iconButton.ZIndex = 10001
    iconButton.Parent = floatingGui
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = iconButton
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(245, 49, 116)
    outline.Thickness = 1.5
    outline.Parent = iconButton

    local dragging = false
    local moved = false
    local dragStart
    local startPosition
    local activeInput
    iconButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPosition = iconButton.Position
            activeInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) + math.abs(delta.Y) > 6 then moved = true end
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
            local x = math.clamp(startPosition.X.Offset + delta.X, 0, math.max(0, viewport.X - iconButton.AbsoluteSize.X))
            local y = math.clamp(startPosition.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - iconButton.AbsoluteSize.Y))
            iconButton.Position = UDim2.new(0, x, 0, y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved and fatGui then
                pcall(function() fatGui.Enabled = not fatGui.Enabled end)
            end
            activeInput = nil
        end
    end)
end

pcall(function()
	Window:SetUsername(LocalPlayer.DisplayName)
	Window:SetProfile("rbxthumb://type=HeadShot&id=" .. LocalPlayer.UserId .. "&w=180&h=180")
end)


local overlay = Instance.new("ScreenGui")
overlay.Name = HttpService:GenerateGUID(false)
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.DisplayOrder = 5
do
	local parent = CoreGui
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then parent = h end
	end
	local ok = pcall(function() overlay.Parent = parent end)
	if not ok then overlay.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local ui = {Tabs = {}, ConfigItems = {}, ConfigOrder = {}, ConfigIgnore = {}, Connections = {}, Gui = overlay, Window = Window}
ENV.__SW_UI = ui
ENV.__MILLIONWARE_SLATE = ui

local function register(id, item)
	if not id then return end
	if not ui.ConfigItems[id] then ui.ConfigOrder[#ui.ConfigOrder + 1] = id end
	ui.ConfigItems[id] = item
end




local LEGACY_KINDS = {checkbox = true, slider = true, combo = true, multi = true, keybind = true, color = true, text = true}

local function legacyKey(k)
	if type(k) ~= "table" or type(k.name) ~= "string" then return nil, nil end
	local enumName = tostring(k.enum or "")
	enumName = enumName:gsub("^Enum%.", "")
	return k.name, (enumName == "UserInputType") and "U" or "K"
end

local function normalizeLegacy(data)
	local out = {}
	for id, e in pairs(data) do
		if type(e) == "table" and LEGACY_KINDS[e.t] then
			if e.t == "checkbox" then
				if type(e.v) == "boolean" then out[id] = e.v end
				local kn, kt = legacyKey(e.key)
				if kn or e.mode then out[id .. "__key"] = {k = kn or "None", t = kt or "K", m = e.mode} end
			elseif e.t == "keybind" then
				local kn, kt = legacyKey(e.key)
				out[id] = {k = kn or "None", t = kt or "K", m = e.mode}
			elseif e.t == "color" then
				if type(e.v) == "table" then out[id] = {r = e.v[1], g = e.v[2], b = e.v[3], a = e.v[4]} end
			elseif e.v ~= nil then
				out[id] = e.v
			end
		else
			out[id] = e
		end
	end
	return out
end

local function serializeConfig()
	local out = {}
	for _, id in ipairs(ui.ConfigOrder) do
		local item = ui.ConfigItems[id]
		if item and item.save and not ui.ConfigIgnore[id] then
			local ok, v = pcall(item.save)
			if ok and v ~= nil then out[id] = v end
		end
	end
	return out
end
local function applyConfig(data)
	if type(data) ~= "table" then return end
	data = normalizeLegacy(data)
	for _, id in ipairs(ui.ConfigOrder) do
		local item = ui.ConfigItems[id]
		local v = data[id]
		if item and item.load and v ~= nil and not ui.ConfigIgnore[id] then
			local ok, err = pcall(item.load, v)
			if not ok then warn("[SW] config key '" .. id .. "': " .. tostring(err)) end
		end
	end
end

Window.GetFlagConfig = function() return serializeConfig() end
Window.LoadConfig = function(_, data) applyConfig(data) end

local configWindow
pcall(function()
	configWindow = Window:AddConfig()
	configWindow:Init(CONFIG_NAME, CONFIG_FOLDER)
	configWindow:ReloadConfig()
end)



local CONFIG_DIR = CONFIG_FOLDER .. "/Config/" .. CONFIG_NAME
local LEGACY_DIR = CONFIG_FOLDER .. "/SW/millionware"
local LEGACY_TAG = "[old] "
local AUTOLOAD_FILE = CONFIG_FOLDER .. "/SW_autoload.txt"
ui.ConfigFolder = CONFIG_DIR

local function haveFs()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
		and typeof(listfiles) == "function" and typeof(isfolder) == "function" and typeof(makefolder) == "function"
end
local function ensureDir()
	for _, p in ipairs({CONFIG_FOLDER, CONFIG_FOLDER .. "/Config", CONFIG_DIR}) do
		if not isfolder(p) then pcall(makefolder, p) end
	end
end
local function baseName(path)
	local n = tostring(path)
	n = n:gsub("\\", "/")
	return n:match("([^/]+)$")
end
local function validName(name)
	name = tostring(name or "")
	name = name:gsub("^%s+", "")
	name = name:gsub("%s+$", "")
	if name == "" or name:find("[/\\:]") then return nil end
	return name
end

function ui:ListConfigs()
	local out = {}
	if not haveFs() then return out end
	ensureDir()
	local ok, files = pcall(listfiles, CONFIG_DIR)
	if ok and type(files) == "table" then
		for _, f in ipairs(files) do
			local n = baseName(f)
			if n then out[#out + 1] = n end
		end
	end
	if isfolder(LEGACY_DIR) then
		local ok2, old = pcall(listfiles, LEGACY_DIR)
		if ok2 and type(old) == "table" then
			for _, f in ipairs(old) do
				local n = baseName(f)
				local stem = n and n:match("^(.+)%.json$")
				if stem and stem ~= "autoload" then out[#out + 1] = LEGACY_TAG .. stem end
			end
		end
	end
	table.sort(out, function(a, b) return a:lower() < b:lower() end)
	return out
end

function ui:SaveConfig(name)
	name = validName(name)
	if not name then return false, "invalid name" end
	if name:sub(1, #LEGACY_TAG) == LEGACY_TAG then return false, "old configs are read-only" end
	if not haveFs() then return false, "file functions unavailable" end
	ensureDir()
	local ok, json = pcall(function() return HttpService:JSONEncode(serializeConfig()) end)
	if not ok then return false, "encode failed" end
	if not pcall(writefile, CONFIG_DIR .. "/" .. name, json) then return false, "write failed" end
	return true
end

function ui:LoadConfig(name)
	name = validName(name)
	if not name then return false, "invalid name" end
	if not haveFs() then return false, "file functions unavailable" end
	local path
	if name:sub(1, #LEGACY_TAG) == LEGACY_TAG then
		path = LEGACY_DIR .. "/" .. name:sub(#LEGACY_TAG + 1) .. ".json"
	else
		path = CONFIG_DIR .. "/" .. name
	end
	if not isfile(path) then return false, "not found" end
	local rok, raw = pcall(readfile, path)
	if not rok then return false, "read failed" end
	local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not dok or type(data) ~= "table" then return false, "corrupt file" end
	applyConfig(data)
	return true
end

function ui:DeleteConfig(name)
	name = validName(name)
	if not name or name:sub(1, #LEGACY_TAG) == LEGACY_TAG then return false end
	if typeof(isfile) ~= "function" or typeof(delfile) ~= "function" then return false end
	local path = CONFIG_DIR .. "/" .. name
	if not isfile(path) then return false end
	return (pcall(delfile, path))
end

function ui:SetAutoloadConfig(name)
	if typeof(writefile) ~= "function" then return false end
	if haveFs() then ensureDir() end
	return (pcall(writefile, AUTOLOAD_FILE, validName(name) or ""))
end

function ui:GetAutoloadConfig()
	if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then return nil end
	if not isfile(AUTOLOAD_FILE) then return nil end
	local ok, n = pcall(readfile, AUTOLOAD_FILE)
	if ok and type(n) == "string" then return validName(n) end
	return nil
end


function ui:Notify(cfg)
	cfg = cfg or {}
	local ok = pcall(function()
		Window.Notifier:Notify({
			Title = tostring(cfg.Title or BRAND),
			Content = tostring(cfg.Description or cfg.Content or ""),
			Icon = "settings",
			Duration = tonumber(cfg.Time or cfg.Duration) or 4,
		})
	end)
	return ok
end




local headerPopups
local function installHeaderPopups()
	if headerPopups or not fatGui then return end
	local ACCENT = Color3.fromRGB(245, 49, 116)
	local BG, LINE, ROW = Color3.fromRGB(16, 16, 18), Color3.fromRGB(44, 44, 50), Color3.fromRGB(26, 26, 30)
	local Z = 500
	local popups = {}

	local function styleText(obj, size, bold)
		obj.TextSize = size
		if Fatality.FontSemiBold then obj.FontFace = Fatality.FontSemiBold
		else obj.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium end
	end
	local function newLabel(parent, text, size, color, bold, pos, sizeUdim)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = color
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.Position, l.Size = pos, sizeUdim
		l.ZIndex = Z + 2
		styleText(l, size, bold)
		l.Parent = parent
		return l
	end
	local function newPopup(w, h)
		local f = Instance.new("Frame")
		f.Name = HttpService:GenerateGUID(false)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(0.5, 0.5)
		f.Size = UDim2.fromOffset(w, h)
		f.BackgroundColor3 = BG
		f.BorderSizePixel = 0
		f.Active = true
		f.Visible = false
		f.ZIndex = Z
		local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = f
		local st = Instance.new("UIStroke") st.Color = LINE st.Thickness = 1 st.Parent = f
		local bar = Instance.new("Frame")
		bar.BackgroundColor3 = ACCENT
		bar.BorderSizePixel = 0
		bar.Size = UDim2.new(1, 0, 0, 2)
		bar.ZIndex = Z + 1
		local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 6) bc.Parent = bar
		bar.Parent = f
		local x = Instance.new("TextButton")
		x.AutoButtonColor = false
		x.BackgroundTransparency = 1
		x.AnchorPoint = Vector2.new(1, 0)
		x.Position = UDim2.new(1, -6, 0, 6)
		x.Size = UDim2.fromOffset(22, 22)
		x.Text = "x"
		x.TextColor3 = Color3.fromRGB(150, 150, 156)
		x.ZIndex = Z + 3
		styleText(x, 15, true)
		x.MouseEnter:Connect(function() x.TextColor3 = ACCENT end)
		x.MouseLeave:Connect(function() x.TextColor3 = Color3.fromRGB(150, 150, 156) end)
		x.MouseButton1Click:Connect(function() f.Visible = false end)
		x.Parent = f
		f.Parent = fatGui
		popups[#popups + 1] = f
		return f
	end
	local function toggle(f, onOpen)
		local open = not f.Visible
		for _, other in ipairs(popups) do other.Visible = false end
		if open then
			if onOpen then onOpen() end
			f.Visible = true
		end
	end


	local info = newPopup(250, 122)
	newLabel(info, "Z-x", 20, ACCENT, true, UDim2.fromOffset(16, 14), UDim2.new(1, -44, 0, 24))
	local body = newLabel(info, "creators: DureXXX\nUI: FATALITY\n2025-2026", 14, Color3.fromRGB(230, 230, 235), false,
		UDim2.fromOffset(16, 46), UDim2.new(1, -32, 0, 64))
	body.LineHeight = 1.3


	local cfg = newPopup(300, 330)
	newLabel(cfg, "Configs", 16, ACCENT, true, UDim2.fromOffset(14, 12), UDim2.new(1, -44, 0, 20))
	local list = Instance.new("ScrollingFrame")
	list.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	list.BorderSizePixel = 0
	list.Position = UDim2.fromOffset(10, 40)
	list.Size = UDim2.new(1, -20, 1, -78)
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 3
	list.ScrollBarImageColor3 = ACCENT
	list.ZIndex = Z + 1
	local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 4) lc.Parent = list
	local ll = Instance.new("UIListLayout") ll.Padding = UDim.new(0, 3) ll.SortOrder = Enum.SortOrder.LayoutOrder ll.Parent = list
	local lp = Instance.new("UIPadding")
	lp.PaddingTop, lp.PaddingBottom, lp.PaddingLeft, lp.PaddingRight = UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4)
	lp.Parent = list
	list.Parent = cfg
	local status = newLabel(cfg, "LMB - select, RMB - load", 12, Color3.fromRGB(150, 150, 156), false,
		UDim2.new(0, 12, 1, -28), UDim2.new(1, -24, 0, 18))
	status.TextTruncate = Enum.TextTruncate.AtEnd

	local rows, selected = {}, nil
	local function paint()
		for name, row in pairs(rows) do
			local on = name == selected
			row.BackgroundColor3 = on and ACCENT or ROW
			row.BackgroundTransparency = on and 0.75 or 0
			row.TextColor3 = on and ACCENT or Color3.fromRGB(230, 230, 235)
		end
	end
	local function setStatus(text, color) status.Text = text status.TextColor3 = color end
	local function loadNamed(name)
		local ok, err = ui:LoadConfig(name)
		if ok then
			setStatus("Loaded: " .. name, Color3.fromRGB(110, 220, 130))
		else
			setStatus("Load failed: " .. tostring(err), Color3.fromRGB(255, 110, 110))
		end
		ui:Notify({Title = "Config", Description = ok and ("Loaded config '" .. name .. "'") or ("Load failed: " .. tostring(err))})
	end
	local emptyNote
	local function refresh()
		for _, r in pairs(rows) do r:Destroy() end
		rows = {}
		if emptyNote then emptyNote:Destroy() emptyNote = nil end
		local names = ui:ListConfigs()
		local found = false
		for i, name in ipairs(names) do
			if name == selected then found = true end
			local row = Instance.new("TextButton")
			row.AutoButtonColor = false
			row.BorderSizePixel = 0
			row.LayoutOrder = i
			row.Size = UDim2.new(1, 0, 0, 26)
			row.Text = name
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.TextTruncate = Enum.TextTruncate.AtEnd
			row.ZIndex = Z + 2
			styleText(row, 13, false)
			local rp = Instance.new("UIPadding") rp.PaddingLeft = UDim.new(0, 10) rp.PaddingRight = UDim.new(0, 8) rp.Parent = row
			local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 3) rc.Parent = row
			row.MouseButton1Click:Connect(function() selected = name paint() end)
			row.MouseButton2Click:Connect(function() selected = name paint() loadNamed(name) end)
			row.Parent = list
			rows[name] = row
		end
		if not found then selected = nil end
		if #names == 0 then
			emptyNote = newLabel(list, "no configs found", 13, Color3.fromRGB(120, 120, 126), false, UDim2.new(), UDim2.new(1, 0, 0, 24))
			emptyNote.TextXAlignment = Enum.TextXAlignment.Center
			emptyNote.TextYAlignment = Enum.TextYAlignment.Center
		end
		setStatus("LMB - select, RMB - load", Color3.fromRGB(150, 150, 156))
		paint()
	end


	ui.Connections[#ui.Connections + 1] = fatGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not fatGui.Enabled then for _, f in ipairs(popups) do f.Visible = false end end
	end)


	local okInfo = type(Window.AddInfo) == "function" and pcall(function() Window:AddInfo(function() toggle(info) end) end)
	local okSave = type(Window.AddSave) == "function" and pcall(function() Window:AddSave(function() toggle(cfg, refresh) end) end)
	if not okInfo then warn("[SW] Window:AddInfo missing - about popup not hooked") end
	if not okSave then warn("[SW] Window:AddSave missing - configs popup not hooked") end
	for _, d in ipairs(fatGui:GetDescendants()) do
		if d:IsA("ImageButton") and d.Name == "ConfigButton" then d.Visible = false end
	end
	headerPopups = true
end


local MODE_NEXT = {["On Hotkey"] = "Toggle", ["Toggle"] = "Always On", ["Always On"] = "On Hotkey"}
local MODE_SHORT = {["On Hotkey"] = "Hold", ["Toggle"] = "Toggle", ["Always On"] = "Always"}
local KEY_SHORT = {
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftAlt = "LAlt", RightAlt = "RAlt",
}
local binders = {}
local capturing = nil

local function resolveKey(name, kind)
	if not name or name == "None" then return nil end
	local ok, v
	if kind == "U" then ok, v = pcall(function() return Enum.UserInputType[name] end)
	else ok, v = pcall(function() return Enum.KeyCode[name] end) end
	return ok and v or nil
end

ui.Connections[#ui.Connections + 1] = UserInputService.InputBegan:Connect(function(input, gp)
	if capturing then
		local b, k = capturing, nil
		local t = input.UserInputType
		if t == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then k = false else k = input.KeyCode end
		elseif t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
			k = t
		end
		if k ~= nil then
			capturing = nil
			b.assign(k or nil, true)
		end
		return
	end
	if UserInputService:GetFocusedTextBox() then return end
	for _, b in ipairs(binders) do
		local k = b.key
		if k then
			local hit
			if k.EnumType == Enum.KeyCode then
				hit = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == k
			else
				hit = (not gp) and input.UserInputType == k
			end
			if hit then b.press() end
		end
	end
end)
ui.Connections[#ui.Connections + 1] = UserInputService.InputEnded:Connect(function(input)
	for _, b in ipairs(binders) do
		local k = b.key
		if k and b.mode == "On Hotkey" and b.active then
			local hit
			if k.EnumType == Enum.KeyCode then
				hit = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == k
			else
				hit = input.UserInputType == k
			end
			if hit then b.release() end
		end
	end
end)


local function parseFmt(fmt)
	fmt = tostring(fmt or "%.0f")
	local digits = tonumber(fmt:match("%%%d*%.(%d+)f")) or 0
	local suffix = fmt:match("%%[%d%.]*[fdi](.*)$") or ""
	suffix = (suffix:gsub("%%%%", "%%"))
	return digits, suffix
end

local function newSection(sec)
	assert(type(sec) == "table" and sec.__parent, "[SW] Fatality section has no content frame (CreateElements patch failed)")
	local S = {}
	local last = nil

	local function setText(l, size)
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		l.TextSize = size or 12
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextTransparency = 0.4
		if Fatality.FontSemiBold then l.FontFace = Fatality.FontSemiBold else l.Font = Enum.Font.GothamMedium end
		l.TextXAlignment = Enum.TextXAlignment.Left
	end
	local function track(obj)
		obj.Name = HttpService:GenerateGUID(false)
		obj.ZIndex = (sec.__zindex or 1) + 1
		obj.Parent = sec.__parent
		local ev = sec.__event
		obj.Visible = (ev ~= nil) and (ev:GetAttribute("V") == true)
		if ev then ev.Event:Connect(function(v) obj.Visible = not not v end) end
		pcall(function() Fatality:AddDragBlacklist(obj) end)
	end
	local function newFrame(height)
		local row = Instance.new("Frame")
		row.BackgroundColor3 = (Fatality.Colors and Fatality.Colors.Black) or Color3.fromRGB(21, 21, 21)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -25, 0, height or 25)
		track(row)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 2)
		c.Parent = row
		return row
	end
	function S:CustomFrame(height) return newFrame(height) end

		local function consumeLast(name, suffix)
		local l = last
		last = nil
		if not l then return name end
		if l.kind == "Label" then
			if l.row and l.row.Parent then l.row:Destroy() end
			return name
		end
		if name == l.text then return name .. suffix end
		return name
	end

	function S:Label(text)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -25, 0, 18)
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.TextWrapped = true
		l.Text = tostring(text)
		l.TextYAlignment = Enum.TextYAlignment.Top
		setText(l, 12)
		track(l)
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = l
		last = {kind = "Label", text = tostring(text), row = l}
		local w = {}
		function w:Set(t) l.Text = tostring(t) end
		return w
	end

	function S:Separator()
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, -25, 0, 1)
		track(f)
		last = nil
		return {}
	end

	function S:Button(text, fn)
		sec:AddButton({Name = tostring(text), Callback = function()
			if fn then fn() end
		end})
		last = {kind = "Button", text = tostring(text)}
		return {}
	end

	function S:Checkbox(text, value, cb, opts)
		opts = opts or {}
		local name = tostring(text)
		local cur = value == true
		local el = sec:AddToggle({Name = name, Default = cur, Callback = function(v)
			v = v == true
			if v == cur then return end
			cur = v
			if cb then cb(v) end
		end})
		local w = {}
		function w:Get() return cur end
		function w:Set(v) el:SetValue(v == true) end
		register(opts.flag, {save = function() return cur end, load = function(v) w:Set(v == true) end})
		last = {kind = "Checkbox", text = name}
		if opts.keybind ~= nil then
			local kb = S:Keybind(name .. " key", opts.keybind or nil, nil, opts.flag and (opts.flag .. "__key") or nil,
				{mode = opts.mode, onActive = opts.onActive})
			w.Binder = kb.Binder
			last = {kind = "Checkbox", text = name}
		end
		return w
	end

	local function slider(text, min, max, value, cb, fmt, id, isInt)
		local digits, suffix = parseFmt(fmt)
		if isInt then digits = 0 end
		min, max = tonumber(min) or 0, tonumber(max) or 1
		if max <= min then max = min + 1 end
		local power = 10 ^ digits
		local function snap(v) return math.clamp(math.floor(v * power + 0.5) / power, min, max) end
		local cur = snap(tonumber(value) or min)
		local el = sec:AddSlider({Name = tostring(text), Min = min, Max = max, Default = cur, Round = digits, Type = suffix,
			Callback = function(v)
				v = tonumber(v)
				if not v or v == cur then return end
				cur = v
				if cb then cb(v) end
			end})
		local w = {}
		function w:Get() return cur end
		function w:Set(v)
			local n = tonumber(v)
			if n and n == n then el:SetValue(snap(n)) end
		end
		register(id, {save = function() return cur end, load = function(v) if tonumber(v) then w:Set(tonumber(v)) end end})
		last = {kind = "Slider", text = tostring(text)}
		return w
	end
	function S:SliderFloat(text, min, max, value, cb, fmt, id) return slider(text, min, max, value, cb, fmt, id, false) end
	function S:SliderInt(text, min, max, value, cb, fmt, id) return slider(text, min, max, value, cb, fmt, id, true) end

	function S:TextInput(text, value, cb, placeholder, id)
		local row = newFrame(25)
		local nameL = Instance.new("TextLabel")
		nameL.Size = UDim2.new(0.45, -6, 1, 0)
		nameL.Position = UDim2.new(0, 6, 0, 0)
		nameL.Text = tostring(text)
		nameL.TextTruncate = Enum.TextTruncate.AtEnd
		nameL.ZIndex = row.ZIndex + 1
		setText(nameL, 12)
		nameL.Parent = row
		local box = Instance.new("TextBox")
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -4, 0.5, 0)
		box.Size = UDim2.new(0.55, -8, 0, 19)
		box.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.Text = tostring(value or "")
		box.PlaceholderText = tostring(placeholder or "")
		box.TextColor3 = Color3.new(1, 1, 1)
		box.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		if Fatality.FontSemiBold then box.FontFace = Fatality.FontSemiBold else box.Font = Enum.Font.GothamMedium end
		box.ZIndex = row.ZIndex + 1
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 5)
		pad.Parent = box
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = box
		box.Parent = row
		local function commit() if cb then cb(box.Text) end end
		box.FocusLost:Connect(commit)
		local w = {}
		function w:Get() return box.Text end
		function w:Set(v) box.Text = tostring(v) end
		register(id, {save = function() return box.Text end, load = function(v) w:Set(tostring(v)); commit() end})
		last = {kind = "Input", text = tostring(text)}
		return w
	end

	function S:Combo(text, values, default, cb, id)
		local items = values or {}
		local cur = default
		local el = sec:AddDropdown({Name = tostring(text), Values = items, Default = cur, Multi = false, Callback = function(v)
			if v == nil or v == cur then return end
			cur = v
			if cb then cb(v) end
		end})
		local w = {}
		function w:Get() return cur end
		function w:Set(v)
			if v == nil then return end
			el:SetValue(v)
			el:SetData(items)
		end
		function w:SetItems(list, current)
			items = list or {}
			if current ~= nil then cur = current end
			el:SetData(items)
		end
		register(id, {save = function() return cur end, load = function(v) if type(v) == "string" then w:Set(v) end end})
		last = {kind = "Combo", text = tostring(text)}
		return w
	end

	function S:MultiCombo(text, values, selected, cb, id)
		local items = values or {}
		local function toMap(list)
			local m = {}
			for _, v in ipairs(list or {}) do m[v] = true end
			return m
		end
		local function toList(map)
			local out = {}
			for _, v in ipairs(items) do if map[v] == true then out[#out + 1] = v end end
			return out
		end
		local sel = toList(toMap(selected))
		local curKey = table.concat(sel, "\0")
		local el = sec:AddDropdown({Name = tostring(text), Values = items, Default = toMap(selected), Multi = true, Callback = function(args)
			if type(args) ~= "table" then return end
			local list = toList(args)
			local key = table.concat(list, "\0")
			if key == curKey then return end
			curKey = key
			sel = list
			if cb then cb(list) end
		end})
		local w = {}
		function w:Get() return table.clone(sel) end
		function w:Set(list)
			el:SetValue(toMap(list))
			el:SetData(items)
		end
		function w:SetItems(list) items = list or {}; el:SetData(items) end
		register(id, {
			save = function() return table.clone(sel) end,
			load = function(v) if type(v) == "table" then w:Set(v) end end,
		})
		last = {kind = "MultiCombo", text = tostring(text)}
		return w
	end

	function S:ColorPicker(title, default, cb, alpha, id)
		local name = consumeLast(tostring(title), " color")
		local curC, curA = default or Color3.new(1, 1, 1), alpha or 1
		local el = sec:AddColorPicker({Name = name, Default = curC, Transparency = 1 - curA, Callback = function(rgb, opc)
			local a = 1 - (opc or 0)
			if rgb == curC and math.abs(a - curA) < 1e-6 then return end
			curC, curA = rgb, a
			if cb then cb(rgb, a) end
		end})
		local w = {}
		function w:Get() return curC, curA end
		function w:Set(c, a)
			if typeof(c) ~= "Color3" then return end
			a = a or 1
			curC, curA = c, a
			el:SetValue(c, 1 - a)
		end
		register(id, {
			save = function() return {r = curC.R, g = curC.G, b = curC.B, a = curA} end,
			load = function(v)
				if type(v) == "table" and tonumber(v.r) and tonumber(v.g) and tonumber(v.b) then
					local c, a = Color3.new(v.r, v.g, v.b), tonumber(v.a) or 1
					w:Set(c, a)

					if cb then cb(c, a) end
				end
			end,
		})
		last = {kind = "Color", text = name}
		return w
	end

	function S:Keybind(text, key, changed, id, opts)
		opts = opts or {}
		local name = consumeLast(tostring(text), " key")
		local isMenu = (id == "MenuKeybind")
		local b = {key = key, mode = opts.mode or "Toggle", active = false}
		if isMenu and key and key.EnumType == Enum.KeyCode then winCfg.Keybind = key.Name end

		local row = newFrame(25)
		local nameL = Instance.new("TextLabel")
		nameL.Size = UDim2.new(0.55, -6, 1, 0)
		nameL.Position = UDim2.new(0, 6, 0, 0)
		nameL.Text = name
		nameL.TextTruncate = Enum.TextTruncate.AtEnd
		nameL.ZIndex = row.ZIndex + 1
		setText(nameL, 12)
		nameL.Parent = row
		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, -4, 0.5, 0)
		btn.Size = UDim2.new(0.45, -8, 0, 19)
		btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextTransparency = 0.2
		btn.TextSize = 12
		if Fatality.FontSemiBold then btn.FontFace = Fatality.FontSemiBold else btn.Font = Enum.Font.GothamMedium end
		btn.ZIndex = row.ZIndex + 1
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = btn
		btn.Parent = row

		local function refreshText()
			local n = b.key and (KEY_SHORT[b.key.Name] or b.key.Name) or "None"
			if isMenu or opts.noModeMenu then btn.Text = "[" .. n .. "]"
			else btn.Text = "[" .. n .. "] " .. (MODE_SHORT[b.mode] or b.mode) end
		end
		local function fire(v)
			if opts.onActive then
				local ok, err = pcall(opts.onActive, v)
				if not ok then warn("[SW] keybind callback: " .. tostring(err)) end
			end
		end
		function b.assign(k, fromUser)
			b.key = k
			b.active = false
			if isMenu and k and k.EnumType == Enum.KeyCode then winCfg.Keybind = k.Name end
			refreshText()
			if fromUser and changed then changed(k) end
		end
		function b.press()
			if b.mode == "On Hotkey" then
				b.active = true; fire(true)
			elseif b.mode == "Toggle" then
				b.active = not b.active; fire(b.active)
			end
		end
		function b.release()
			if b.active and b.mode == "On Hotkey" then
				b.active = false; fire(false)
			end
		end
		local function setMode(m)
			if not MODE_NEXT[m] or m == b.mode then return end
			local old = b.mode
			b.mode = m
			b.active = false
			if m == "Always On" then
				b.active = true; fire(true)
			elseif old == "Always On" and m == "On Hotkey" then
				fire(false)
			end
			if opts.onMode then pcall(opts.onMode, m) end
			refreshText()
		end
		btn.MouseButton1Click:Connect(function()
			if capturing then return end
			capturing = b
			btn.Text = "[...]"
		end)
		btn.MouseButton2Click:Connect(function()
			if capturing or isMenu or opts.noModeMenu then return end
			setMode(MODE_NEXT[b.mode])
		end)
		refreshText()
		if not isMenu then binders[#binders + 1] = b end
		if b.mode == "Always On" then task.defer(function() b.active = true; fire(true) end) end

		local w = {Binder = b}
		function w:Set(k) b.assign(k, false) end
		function w:SetMode(m) setMode(m) end
		register(id, {
			save = function()
				return {k = b.key and b.key.Name or "None", t = (b.key and b.key.EnumType == Enum.UserInputType) and "U" or "K", m = b.mode}
			end,
			load = function(v)
				if type(v) ~= "table" then return end
				setMode(v.m)
				local k = resolveKey(v.k, v.t)
				b.assign(k, false)
				if changed then changed(k) end
			end,
		})
		last = nil
		return w
	end

	return S
end



do
	local modal = Instance.new("TextButton")
	modal.Name = HttpService:GenerateGUID(false)
	modal.BackgroundTransparency = 1
	modal.Text = ""
	modal.Size = UDim2.fromOffset(0, 0)
	modal.Modal = false
	if fatGui then pcall(function() modal.Parent = fatGui end) end

	local fill, outline
	if type(Drawing) == "table" and type(Drawing.new) == "function" then
		pcall(function()
			outline = Drawing.new("Triangle")
			outline.Filled = false outline.Thickness = 2 outline.Color = Color3.new(0, 0, 0) outline.ZIndex = 9998 outline.Visible = false
			fill = Drawing.new("Triangle")
			fill.Filled = true fill.Color = Color3.new(1, 1, 1) fill.ZIndex = 9999 fill.Visible = false
		end)
		if not (fill and outline) then fill, outline = nil, nil end
	end

	local opened, prevIcon = false, UserInputService.MouseIconEnabled
	local lockedBefore = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter



	local FORCE_ICON_ON_CLOSE = true
	local function restoreIcon()
		local v = prevIcon
		if FORCE_ICON_ON_CLOSE and not v and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then v = true end
		UserInputService.MouseIconEnabled = v
	end
	local function setTri(t, x, y)
		t.PointA = Vector2.new(x, y)
		t.PointB = Vector2.new(x, y + 16)
		t.PointC = Vector2.new(x + 11, y + 12)
	end
	local conn = RunService.RenderStepped:Connect(function()
		local open = fatGui ~= nil and fatGui.Parent ~= nil and fatGui.Enabled
		if open then
			if not opened then opened = true prevIcon = UserInputService.MouseIconEnabled end
			modal.Modal = true
			UserInputService.MouseIconEnabled = (fill == nil)
			if fill then
				local m = UserInputService:GetMouseLocation()
				setTri(fill, m.X, m.Y) setTri(outline, m.X, m.Y)
				fill.Visible, outline.Visible = true, true
			end
		elseif opened then
			opened = false
			modal.Modal = false
			restoreIcon()
			if lockedBefore then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end
			if fill then fill.Visible, outline.Visible = false, false end
		else
			lockedBefore = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
		end
	end)
	ui.Connections[#ui.Connections + 1] = {Disconnect = function()
		conn:Disconnect()
		modal.Modal = false
		if opened then restoreIcon() end
		for _, d in ipairs({fill or false, outline or false}) do
			if d then if not pcall(function() d:Remove() end) then pcall(function() d:Destroy() end) end end
		end
		pcall(function() modal:Destroy() end)
	end}
end


do
	local TweenService_ = game:GetService("TweenService")
	local GuiService_ = game:GetService("GuiService")
	local ARROW_W, ARROW_GAP = 22, 4

	local function inside(gui, p)
		local a, s = gui.AbsolutePosition, gui.AbsoluteSize
		return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
	end


	local function findTabStrip(root)
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("ScrollingFrame") then
				local lay = d:FindFirstChildOfClass("UIListLayout")
				local par = d.Parent
				if lay and lay.FillDirection == Enum.FillDirection.Horizontal and par and par:IsA("Frame") and par.ClipsDescendants then
					return d
				end
			end
		end
	end

	local function installTabArrows()
		if not fatGui then return end
		local strip = findTabStrip(fatGui)
		if not strip then warn("[SW] tab strip not found, arrows skipped") return end
		local holder = strip.Parent
		local header = holder.Parent
		local oldPos, oldSize = holder.Position, holder.Size
		local px, sx = oldPos.X.Offset, oldSize.X.Offset
		holder.Position = UDim2.new(oldPos.X.Scale, px + ARROW_W + ARROW_GAP, oldPos.Y.Scale, oldPos.Y.Offset)
		holder.Size = UDim2.new(oldSize.X.Scale, sx - 2 * (ARROW_W + ARROW_GAP), oldSize.Y.Scale, oldSize.Y.Offset)

		local accent = Fatality.Colors and Fatality.Colors.Main
		if typeof(accent) ~= "Color3" then accent = Color3.fromRGB(245, 49, 116) end

		local function makeArrow(text, pos)
			local b = Instance.new("TextButton")
			b.Name = HttpService:GenerateGUID(false)
			b.AutoButtonColor = false
			b.AnchorPoint = Vector2.new(0, holder.AnchorPoint.Y)
			b.Position = pos
			b.Size = UDim2.new(0, ARROW_W, oldSize.Y.Scale, oldSize.Y.Offset)
			b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			b.BorderSizePixel = 0
			b.ZIndex = 6
			b.Font = Enum.Font.GothamBold
			b.Text = text
			b.TextSize = 16
			b.TextColor3 = Color3.new(1, 1, 1)
			b.TextTransparency = 0.15
			local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 3) c.Parent = b
			local st = Instance.new("UIStroke") st.Transparency = 0.95 st.Parent = b
			b.Parent = header
			return b
		end
		local leftBtn = makeArrow("<", UDim2.new(oldPos.X.Scale, px, oldPos.Y.Scale, oldPos.Y.Offset))
		local rightBtn = makeArrow(">", UDim2.new(oldPos.X.Scale + oldSize.X.Scale, px + sx - ARROW_W, oldPos.Y.Scale, oldPos.Y.Offset))

		local function limit() return math.max(0, strip.CanvasSize.X.Offset - strip.AbsoluteSize.X) end
		local function refresh()
			local x, m = strip.CanvasPosition.X, limit()
			leftBtn.TextTransparency = (x > 1) and 0.1 or 0.7
			rightBtn.TextTransparency = (x < m - 1) and 0.1 or 0.7
		end
		local function scrollTo(x)
			x = math.clamp(x, 0, limit())
			TweenService_:Create(strip, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(x, 0)}):Play()
		end
		local function step() return math.max(120, strip.AbsoluteSize.X * 0.6) end

		leftBtn.MouseButton1Click:Connect(function() scrollTo(strip.CanvasPosition.X - step()) end)
		rightBtn.MouseButton1Click:Connect(function() scrollTo(strip.CanvasPosition.X + step()) end)
		for _, b in ipairs({leftBtn, rightBtn}) do
			b.MouseEnter:Connect(function() b.TextColor3 = accent end)
			b.MouseLeave:Connect(function() b.TextColor3 = Color3.new(1, 1, 1) end)
		end
		strip:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
		strip:GetPropertyChangedSignal("CanvasSize"):Connect(refresh)
		strip:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
		refresh()
		task.defer(refresh)

		local function mouseInGui()
			local sg = holder:FindFirstAncestorOfClass("ScreenGui")
			local m = UserInputService:GetMouseLocation()
			if not (sg and sg.IgnoreGuiInset) then m = m - GuiService_:GetGuiInset() end
			return m
		end
		ui.Connections[#ui.Connections + 1] = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
			if not holder:IsDescendantOf(game) or not inside(holder, mouseInGui()) then return end
			strip.CanvasPosition = Vector2.new(math.clamp(strip.CanvasPosition.X - input.Position.Z * 80, 0, limit()), 0)
		end)
		ui.Connections[#ui.Connections + 1] = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			local p = mouseInGui()
			if not holder:IsDescendantOf(game) or not inside(holder, p) then return end
			task.defer(function()
				for _, b in ipairs(strip:GetChildren()) do
					if b:IsA("GuiObject") and inside(b, p) then
						local cur, view = strip.CanvasPosition.X, strip.AbsoluteSize.X
						local left = b.AbsolutePosition.X - strip.AbsolutePosition.X + cur
						local right = left + b.AbsoluteSize.X
						if left < cur + 4 then scrollTo(left - 8) elseif right > cur + view - 4 then scrollTo(right - view + 8) end
						break
					end
				end
			end)
		end)
	end


	local tabByName, gen = {}, 0

	local function rowsHeight(elements)
		local h = 30
		for _, c in ipairs(elements:GetChildren()) do
			if c:IsA("GuiObject") then
				local y = (c.Size.Y.Scale == 0 and c.Size.Y.Offset > 0) and c.Size.Y.Offset or c.AbsoluteSize.Y
				if y <= 0 then y = 24 end
				h = h + y + 5
			end
		end
		return h
	end

	local function balance(entry)
		local secs = {}
		for _, s in ipairs(entry.sections) do if s.frame.Parent then secs[#secs + 1] = s end end
		if #secs == 0 then return end
		local liber = secs[1].frame.Parent.Parent
		if not liber then return end
		local cols = {}
		for _, c in ipairs(liber:GetChildren()) do if c:IsA("ScrollingFrame") then cols[#cols + 1] = c end end
		if #cols ~= 3 then return end
		table.sort(cols, function(a, b) return a.Position.X.Scale < b.Position.X.Scale end)
		for _, c in ipairs(cols) do
			c.ScrollingDirection = Enum.ScrollingDirection.Y
			c.ScrollBarThickness = 3
			c.ScrollBarImageColor3 = Color3.fromRGB(245, 49, 116)
			c.ScrollBarImageTransparency = 0.35
			c.ElasticBehavior = Enum.ElasticBehavior.Never
		end
		local n, load = #secs, {0, 0, 0}
		for i, s in ipairs(secs) do
			local idx
			if n == 1 then idx = 2
			elseif n == 2 then idx = (i == 1) and 1 or 3
			else
				idx = 1
				for k = 2, 3 do if load[k] < load[idx] then idx = k end end
			end
			load[idx] = load[idx] + rowsHeight(s.elements) + 5
			s.frame.LayoutOrder = i
			if s.frame.Parent ~= cols[idx] then s.frame.Parent = cols[idx] end
		end
	end

	local function schedule()
		gen = gen + 1
		local my = gen
		task.delay(0.6, function()
			if my ~= gen then return end
			for _, e in pairs(tabByName) do
				local ok, err = pcall(balance, e)
				if not ok then warn("[SW] column balance failed: " .. tostring(err)) end
			end
		end)
	end

	function ui:_registerTab(name, entry) tabByName[name] = entry end
	function ui:_trackSection(tabName, sec, column)
		local entry = tabByName[tabName]
		if not entry or type(sec) ~= "table" or not sec.__parent then return end
		local frame = sec.__parent.Parent
		if not frame then return end
		entry.sections[#entry.sections + 1] = {frame = frame, elements = sec.__parent, want = column}
		schedule()
	end

	local ok, err = pcall(installTabArrows)
	if not ok then warn("[SW] tab arrows failed: " .. tostring(err)) end
end

local menus = {}
function ui:AddTab(name, pages)
	if menus[name] then return menus[name] end
	local menu = Window:AddMenu({Name = TAB_TITLE[name] or string.upper(tostring(name)), Icon = TAB_ICON[name] or "settings", AutoFill = false})
	menus[name] = menu
	ui.Tabs[#ui.Tabs + 1] = {name = name, menu = menu, pages = {}, subButtons = {}, sections = {}}
		ui:_registerTab(name, ui.Tabs[#ui.Tabs])
	installHeaderPopups()
	return menu
end
function ui:AddSection(tab, page, title, column, height)
	local menu = menus[tab]
	assert(menu, "[SW] unknown tab: " .. tostring(tab))
	local sec = menu:AddSection({Name = tostring(title), Position = (column == 2) and "right" or "left"})
		ui:_trackSection(tab, sec, column)
	return newSection(sec)
end
function ui:SetToggleKey(k)
	if k and k.EnumType == Enum.KeyCode then winCfg.Keybind = k.Name end
end
function ui:SetWindowSize() end

function ui:Destroy()
	for _, c in ipairs(ui.Connections) do pcall(function() c:Disconnect() end) end
	table.clear(ui.Connections)
	capturing = nil
	table.clear(binders)
	pcall(function() if fatGui then fatGui:Destroy() end end)
	pcall(function() overlay:Destroy() end)
	if ENV.__SW_UI == ui then ENV.__SW_UI = nil end
	if ENV.__MILLIONWARE_SLATE == ui then ENV.__MILLIONWARE_SLATE = nil end
end

return ui
end)())
local ThemeManager, SaveManager = (function()


return function(L)
    local ui = L.native
    local ThemeManager, SaveManager = {}, {}
    function ThemeManager:SetLibrary() end
    function ThemeManager:SetFolder() end
    function ThemeManager:ApplyTheme() end
    function ThemeManager:ApplyToTab() end
    function SaveManager:SetLibrary() end
    function SaveManager:IgnoreThemeSettings() end
    function SaveManager:SetIgnoreIndexes(ids) for _, id in ipairs(ids) do ui.ConfigIgnore[id] = true end end
    function SaveManager:SetFolder() end
    function SaveManager:BuildConfigSection(tab)
        local g = tab:AddLeftGroupbox("Configs")
        local selected, typed, dropdown
        local function notify(ok, err)
            L:Notify({Title = "Configs", Description = ok and "Done" or tostring(err or "File operation unavailable"), Time = 3})
        end
        local function refresh()
            local names = ui:ListConfigs()
            if #names == 0 then names = {"None"} end
            dropdown:SetValues(names)
            dropdown:SetValue(selected or names[1])
        end
        dropdown = g:AddDropdown("__config", {Text = "Saved config", Values = {"None"}, Default = 1,
            Callback = function(v) selected = v ~= "None" and v or nil end})
        g:AddInput("__config_name", {Text = "Config name", Default = "", Callback = function(v) typed = v end})
        local function target() return typed and typed:match("%S") and typed or selected end
        g:AddButton("Create / Save", function() local ok, err = ui:SaveConfig(target()); notify(ok, err); if ok then selected = target(); refresh() end end)
        g:AddButton("Load selected", function() notify(ui:LoadConfig(selected)) end)
        g:AddButton("Delete selected", function() local ok = ui:DeleteConfig(selected); notify(ok); if ok then selected = nil; refresh() end end)
        g:AddButton("Refresh", refresh)
        g:AddButton("Set autoload", function() notify(ui:SetAutoloadConfig(selected or "")) end)
        g:AddButton("Clear autoload", function() notify(ui:SetAutoloadConfig("")) end)
        g:AddLabel("Same files as the save icon (bottom-left). [old] entries are Millionware configs (read-only).")
        ui.ConfigIgnore.__config = true; ui.ConfigIgnore.__config_name = true
        refresh()
    end
    function SaveManager:LoadAutoloadConfig()


        self.pendingAutoload = true
    end
    function SaveManager:Finish()
        L:Finalize()
        if self.pendingAutoload then
            local name = ui:GetAutoloadConfig()
            if name then local ok, err = ui:LoadConfig(name); if not ok then L:Notify({Title = "Autoload", Description = tostring(err)}) end end
        end
    end
    return ThemeManager, SaveManager
end

end)()(Library)

;(function()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
 Title = "Z-x",
 Footer = "mobile edition",
 NotifySide = "Right",
 ShowCustomCursor = true,
})

Tabs = {
 Movement = Window:AddTab("Movement Physics", "user"),
 AntiAim = Window:AddTab("Anti Aim", "shield"),
 Legacy = Window:AddTab("Legacy Tools", "history"),
 Hitbox = Window:AddTab("Hitbox Creator", "box"),
 Visuals = Window:AddTab("Visuals", "eye"),
 Effects = Window:AddTab("Effects", "sparkles"),
 Lighting = Window:AddTab("Adjust Lighting", "sun"),
 PostEffects = Window:AddTab("Post Effects", "wand"),
 FFlags = Window:AddTab("FFlags Injector", "syringe"),
 Misc = Window:AddTab("Misc", "component"),
 Emotes = Window:AddTab("Emotes", "smile"),
 Nametags = Window:AddTab("Nametags", "tag"),
 Settings = Window:AddTab("System Settings", "settings")
}
Tabs["Anti Aim"] = Tabs.AntiAim






local eventTaunts = {
 "CursedFlashlight", "WerewolfHowl", "Tombstone", "Baghead", "DemonHorns",
 "Candlehead", "ImpaledHead", "WitchHat", "DualBoneSwords", "LavaLamp",
 "SpiderInfestation", "PumpItUp", "VampireOutfit", "OminousDemise",
 "BlueHallowedFace", "GreenHallowedFace", "OrangeHallowedFace",
 "GhostCatcher", "DemonWings", "CandleLamp", "FungalOvergrowth",
 "Reanimated", "ToxicInferno", "Monoculi", "WretchedWings", "PhantomBlades",
 "AmethystStaff", "GhostAbduction", "Telespell", "Thriller", "BluefirePortal",
 "HellfirePortal", "SeekingEye", "EyeCorruption", "Necromonicon", "FrightFunk",
 "BlueUFOAbduction", "PinkUFOAbduction", "Cauldronhead", "HellishGrip",
 "HauntedIredescence", "CobwebTrap", "MechanicalScythe", "DragonSkull",
 "GhostFriend", "SpilledCauldron", "WardingLantern", "RockinStride",
 "Rockin'Stride", "DarkTendrils", "AlchemistBelt", "Frankenstein",
 "ElectrifyingGuitar", "BatVision", "BananaSuit", "EyeIllusions",
 "BroomOfDoom", "BloodMoon"
}


getgenv().respawning = false
getgenv().flly = false
getgenv().cframespeed = false
getgenv().cfspeed = 0
getgenv().autobuy = false
getgenv().breakbots = false
getgenv().annoydowned = false
getgenv().tspam = false
getgenv().botesp = false
getgenv().downesp = false
getgenv().tf = false


function f()
 local UIS = game:GetService("UserInputService")
 while getgenv().cframespeed and task.wait() do
 if getgenv().cfspeed ~= getgenv().cfspeed then
 break
 end
 repeat
 task.wait()
 until game.Players.LocalPlayer.Character or workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)

 local You = game.Players.LocalPlayer.Character or workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
 local hrp = You:WaitForChild("HumanoidRootPart", 0.1)

 if not hrp then
 repeat
 task.wait()
 until You:FindFirstChild('HumanoidRootPart')
 end
 hrp = You.HumanoidRootPart
 if UIS:IsKeyDown(Enum.KeyCode.W) then
 hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -getgenv().cfspeed)
 end
 if UIS:IsKeyDown(Enum.KeyCode.A) then
 hrp.CFrame = hrp.CFrame * CFrame.new(-getgenv().cfspeed, 0, 0)
 end
 if UIS:IsKeyDown(Enum.KeyCode.S) then
 hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, getgenv().cfspeed)
 end
 if UIS:IsKeyDown(Enum.KeyCode.D) then
 hrp.CFrame = hrp.CFrame * CFrame.new(getgenv().cfspeed, 0, 0)
 end
 end
end


function bb()
 while getgenv().breakbots do
 local n = math.random(1, 10000000)
 local z = math.random(200, 8000)
 local x = math.random(1, 10000000)
 if not getgenv().breakbots then
 break
 end
 if game:GetService("Workspace").Game:WaitForChild('Map'):WaitForChild('Parts'):FindFirstChild("KillBricks") then
 game:GetService("Workspace").Game:WaitForChild('Map').KillBricks:Destroy()
 end
 task.wait()
 game.Workspace.Game.Players:WaitForChild(game.Players.LocalPlayer.Name):WaitForChild("HumanoidRootPart").CFrame =
 CFrame.new(0, z, 0)
 end
end


function annoydown()
 if getgenv().annoydowned then
 Library:Notify({Title = "LoosLine", Description = "PLS RESPAWN AND ACTIVATE!!", Time = 3})
 end
 while task.wait() do
 if not getgenv().annoydowned then
 break
 end
 pcall(
 function()
 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(250, 250, 250)
 for i, v in next, game:GetService("Workspace").Game.Players:GetDescendants() do
 if v.IsA(v, "NumberValue") and v.Name == "Downed" and
 not v.Parent.Parent.Parent:FindFirstChild("CarriedBy") and
 game.Players[v.Parent.Parent.Parent.Name].Settings.CanBeCarried.Value == true
 then
 local holder = v.Parent.Parent.Parent.Name
 local hold = workspace.Game.Players[holder]
 local scrip = require(game:GetService("ReplicatedStorage").ModuleStorage.Interact.Interactions.Revive.Revive)
 game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
 CFrame.new(hold.HumanoidRootPart.Position)
 task.wait(0.3)
 game:GetService("ReplicatedStorage").Events.Revive.CarryPlayer:FireServer(holder)
 task.wait(0.3)
 game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 3000, 0)
 task.wait(0.2)
 game:GetService("ReplicatedStorage").Events.Revive.CarryPlayer:FireServer(holder, true)
 task.wait(1)
 end
 end
 end
 )
 end
end


function makeNotification(type, head, body)
 Library:Notify({Title = head, Description = body, Time = 5})
end


function Simple_Create(base, name, trackername, studs)
 local bb = Instance.new("BillboardGui", game.CoreGui)
 bb.Adornee = base
 bb.ExtentsOffset = Vector3.new(0, 1, 0)
 bb.AlwaysOnTop = true
 bb.Size = UDim2.new(0, 6, 0, 6)
 bb.StudsOffset = Vector3.new(0, 1, 0)
 bb.Name = trackername

 local frame = Instance.new("Frame", bb)
 frame.ZIndex = 10
 frame.BackgroundTransparency = 0.3
 frame.Size = UDim2.new(1, 0, 1, 0)
 frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

 local txtlbl = Instance.new("TextLabel", bb)
 txtlbl.ZIndex = 10
 txtlbl.BackgroundTransparency = 1
 txtlbl.Position = UDim2.new(0, 0, 0, -48)
 txtlbl.Size = UDim2.new(1, 0, 10, 0)
 txtlbl.Font = "ArialBold"
 txtlbl.FontSize = "Size12"
 txtlbl.Text = name
 txtlbl.TextStrokeTransparency = 0.5
 txtlbl.TextColor3 = Color3.fromRGB(255, 0, 0)
end


function ClearESP(espname)
 for _, v in pairs(game.CoreGui:GetChildren()) do
 if v.Name == espname and v:IsA("BillboardGui") then
 v:Destroy()
 end
 end
end


function nowaterdmg(t)
 for i, v in next, t:GetChildren() do
 if v.IsA(v, 'BasePart') then
 v.CanTouch = false
 end
 end
end








local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local repstorage = game:GetService("ReplicatedStorage")

getgenv().Evade = getgenv().Evade or {}

local funcs = require(repstorage:WaitForChild("Objects").Game.Character.Client.Movement.MoveFunction.Functions)

local originalRun, originalAir = funcs.Run, funcs.Air

local strafeCut, backCut = 0.65, 0.4
local accel, turn = 80, 10
local gain, decay, swingRef = 25, 8, 5
local ease, drag, brake = 70, 18, 200
local scale = 60





getgenv().AutoStrafe = {
    enabled = false,
    isActive = false,
    connection = nil,
    spd = 0,
    extra = 0,
    dir = Vector2.new(0, -1),
    lastY = 0
}

local function turnTo(cur, goal, max)
    if goal.Magnitude < 1e-4 then return cur end
    if cur.Magnitude < 1e-4 then return goal.Unit end
    local a, b = cur.Unit, goal.Unit
    local ang = math.acos(math.clamp(a.X * b.X + a.Y * b.Y, -1, 1))
    if ang <= max then return b end
    local side = (a.X * b.Y - a.Y * b.X) >= 0 and 1 or -1
    local c, s = math.cos(max * side), math.sin(max * side)
    return Vector2.new(a.X * c - a.Y * s, a.X * s + a.Y * c)
end

local function step(dt, data, mover, state, grounded)
    if not getgenv().AutoStrafe.isActive then return mover, state end
    if not (mover and mover.BaseMover) then return mover, state end

    local look = data:Get("LookCFrame")
    local input = data:Get("MoveDirection") or Vector3.zero
    local world = look and look:VectorToWorldSpace(input) or input
    local wish = Vector2.new(world.X, world.Z)
    local moving = wish.Magnitude > 0.05

    local aim = wish
    if not moving and look then
        aim = Vector2.new(look.LookVector.X, look.LookVector.Z)
    end

    getgenv().AutoStrafe.dir = turnTo(getgenv().AutoStrafe.dir, aim, turn * dt)

    local face = look and Vector2.new(look.LookVector.X, look.LookVector.Z) or getgenv().AutoStrafe.dir
    local align = face.Magnitude > 0 and getgenv().AutoStrafe.dir:Dot(face.Unit) or 1
    local cut = align >= 0
        and strafeCut + (1 - strafeCut) * align
        or strafeCut + (strafeCut - backCut) * align

    local y = look and math.atan2(look.LookVector.X, look.LookVector.Z) or getgenv().AutoStrafe.lastY
    local dy = (y - getgenv().AutoStrafe.lastY + math.pi) % (2 * math.pi) - math.pi
    getgenv().AutoStrafe.lastY = y
    local swing = dt > 0 and math.clamp(math.abs(dy) / dt / swingRef, 0, 1) or 0
    getgenv().AutoStrafe.extra = math.clamp(getgenv().AutoStrafe.extra + ((moving and swing * gain or 0) - decay) * dt, 0, 30)

    local target = moving and (60 + getgenv().AutoStrafe.extra) * cut or 0


    if getgenv().AutoStrafe.spd < target then
        getgenv().AutoStrafe.spd = math.min(target, getgenv().AutoStrafe.spd + accel * dt)
    else

        if not moving then
            local decel = grounded and brake or 0
            getgenv().AutoStrafe.spd = math.max(target, getgenv().AutoStrafe.spd - decel * dt)
        else

            local decel = ease * 0.3
            getgenv().AutoStrafe.spd = math.max(target, getgenv().AutoStrafe.spd - decel * dt)
        end
    end

    local v = getgenv().AutoStrafe.dir * (getgenv().AutoStrafe.spd * scale * ((getgenv().AutoStrafe.maxSpeed or 60) / 60))

    if state and state.Velocity then
        state.Velocity = Vector3.new(v.X, state.Velocity.Y, v.Y)
    end

    return mover, state
end


getgenv().AutoStrafe.start = function()
    if getgenv().AutoStrafe.isActive then return end

    getgenv().AutoStrafe.isActive = true
    getgenv().Evd = true

    funcs.Run = function(dt, m, data, char, stats)
        local mover, state = originalRun(dt, m, data, char, stats)
        return step(dt, data, mover, state, true)
    end

    funcs.Air = function(dt, m, data, char, stats)
        local mover, state = originalAir(dt, m, data, char, stats)
        return step(dt, data, mover, state, false)
    end

    print("")
end


getgenv().AutoStrafe.stop = function()
    if not getgenv().AutoStrafe.isActive then return end

    getgenv().AutoStrafe.isActive = false
    getgenv().Evd = false

    funcs.Run = originalRun
    funcs.Air = originalAir

    getgenv().AutoStrafe.spd = 0
    getgenv().AutoStrafe.extra = 0
    getgenv().AutoStrafe.dir = Vector2.new(0, -1)
    getgenv().AutoStrafe.lastY = 0


end

getgenv().AutoStrafe.enabled = false
getgenv().AutoStrafe.isActive = false



local EnhancedBhop = {
 mode = "Default",
 enabled = false,
 holdModeEnabled = false,
 isHoldingSpace = false,
 inputModeDelay = 0.15,
 lastSpacePress = 0,
 connection = nil,
 frictionTables = {}
}

function EnhancedBhop.setupDefault()
 EnhancedBhop.mode = "Default"
 if EnhancedBhop.connection then EnhancedBhop.connection:Disconnect() end

 EnhancedBhop.connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
 if gameProcessed then return end
 if input.KeyCode == Enum.KeyCode.Space and EnhancedBhop.enabled then
 EnhancedBhop.isHoldingSpace = true
 end
 end)

 UserInputService.InputEnded:Connect(function(input, gameProcessed)
 if input.KeyCode == Enum.KeyCode.Space then
 EnhancedBhop.isHoldingSpace = false
 end
 end)
end

function EnhancedBhop.setupInputImitation()
 EnhancedBhop.mode = "InputImitation"
 if EnhancedBhop.connection then EnhancedBhop.connection:Disconnect() end

 EnhancedBhop.connection = RunService.Heartbeat:Connect(function()
 if not EnhancedBhop.enabled or not LocalPlayer.Character then return end

 local char = LocalPlayer.Character
 local hum = char:FindFirstChildOfClass("Humanoid")
 local hrp = char:FindFirstChild("HumanoidRootPart")

 if not hum or not hrp or hum.Health <= 0 then return end

 local state = hum:GetState()

 if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running then
 if tick() - EnhancedBhop.lastSpacePress > EnhancedBhop.inputModeDelay then
 VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
 task.wait(0.05)
 VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
 EnhancedBhop.lastSpacePress = tick()
 end
 end
 end)
end

function EnhancedBhop.enable(mode)
 EnhancedBhop.enabled = true
 if mode == "InputImitation" then
 EnhancedBhop.setupInputImitation()
 else
 EnhancedBhop.setupDefault()
 end
end

function EnhancedBhop.disable()
 EnhancedBhop.enabled = false
 if EnhancedBhop.connection then
 EnhancedBhop.connection:Disconnect()
 EnhancedBhop.connection = nil
 end
end

local SlideBounce = {
 enabled = false,
 bounceMode = "NoStuck",
 slideSpeedMultiplier = 1.05,
 slideSpeedMultiplierInput = 17.01,
 rotationEnabled = false,
 connection = nil,
 lastBounceTime = 0,
 bounceCooldown = 0.1
}

function SlideBounce.applyNoStuck()
 SlideBounce.bounceMode = "NoStuck"
 if SlideBounce.connection then SlideBounce.connection:Disconnect() end

 SlideBounce.connection = RunService.Heartbeat:Connect(function()
 if not SlideBounce.enabled or not LocalPlayer.Character then return end

 local char = LocalPlayer.Character
 local hrp = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")

 if not hrp or not hum or hum.Health <= 0 then return end

 local velocity = hrp.AssemblyLinearVelocity
 local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
 local speed = horizontalVelocity.Magnitude

 local isCrouching = hum:GetState() == Enum.HumanoidStateType.Crouching
 local isLanded = hum:GetState() == Enum.HumanoidStateType.Landed

 if isCrouching and speed > 19 then
 if isLanded and tick() - SlideBounce.lastBounceTime > SlideBounce.bounceCooldown then
 local boostedVelocity = horizontalVelocity * SlideBounce.slideSpeedMultiplier
 hrp.AssemblyLinearVelocity = Vector3.new(boostedVelocity.X, velocity.Y, boostedVelocity.Z)
 SlideBounce.lastBounceTime = tick()

 if SlideBounce.rotationEnabled then
 SlideBounce.applyRotation(hrp, horizontalVelocity)
 end
 end
 end
 end)
end

function SlideBounce.applyInputImitation()
 SlideBounce.bounceMode = "Input"
 if SlideBounce.connection then SlideBounce.connection:Disconnect() end

 SlideBounce.connection = RunService.Heartbeat:Connect(function()
 if not SlideBounce.enabled or not LocalPlayer.Character then return end

 local char = LocalPlayer.Character
 local hrp = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")

 if not hrp or not hum or hum.Health <= 0 then return end

 local velocity = hrp.AssemblyLinearVelocity
 local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
 local speed = horizontalVelocity.Magnitude

 local isCrouching = hum:GetState() == Enum.HumanoidStateType.Crouching
 local isLanded = hum:GetState() == Enum.HumanoidStateType.Landed

 if isCrouching and speed > 19 then
 if isLanded and tick() - SlideBounce.lastBounceTime > SlideBounce.bounceCooldown then
 local boostedVelocity = horizontalVelocity * SlideBounce.slideSpeedMultiplierInput
 hrp.AssemblyLinearVelocity = Vector3.new(boostedVelocity.X, velocity.Y, boostedVelocity.Z)
 SlideBounce.lastBounceTime = tick()

 if SlideBounce.rotationEnabled then
 SlideBounce.applyRotation(hrp, horizontalVelocity)
 end
 end
 end
 end)
end

function SlideBounce.applyRotation(hrp, velocity)
 if velocity.Magnitude > 0 then
 local targetCFrame = CFrame.new(
 hrp.Position,
 hrp.Position + velocity.Unit
 )

 local currentCFrame = hrp.CFrame
 local lerpAlpha = 0.2
 local newCFrame = currentCFrame:Lerp(targetCFrame, lerpAlpha)
 hrp.CFrame = CFrame.new(hrp.Position) * (newCFrame - newCFrame.Position)
 end
end

function SlideBounce.enable(mode)
 SlideBounce.enabled = true
 if mode == "Input" then
 SlideBounce.applyInputImitation()
 else
 SlideBounce.applyNoStuck()
 end
end

function SlideBounce.disable()
 SlideBounce.enabled = false
 if SlideBounce.connection then
 SlideBounce.connection:Disconnect()
 SlideBounce.connection = nil
 end
end

local BetterRotation = {
 enabled = false,
 smoothness = 0.2,
 minVelocity = 1.0,
 connection = nil
}

function BetterRotation.start()
 if BetterRotation.connection then BetterRotation.connection:Disconnect() end

 BetterRotation.connection = RunService.Heartbeat:Connect(function()
 if not BetterRotation.enabled or not LocalPlayer.Character then return end

 local char = LocalPlayer.Character
 local hrp = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")

 if not hrp or not hum or hum.Health <= 0 then return end

 local velocity = hrp.AssemblyLinearVelocity
 local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)

 if horizontalVelocity.Magnitude > BetterRotation.minVelocity then
 local targetCFrame = CFrame.new(
 hrp.Position,
 hrp.Position + horizontalVelocity.Unit
 )

 local currentCFrame = hrp.CFrame
 local newCFrame = currentCFrame:Lerp(targetCFrame, BetterRotation.smoothness)
 hrp.CFrame = CFrame.new(hrp.Position) * (newCFrame - newCFrame.Position)
 end
 end)
end

function BetterRotation.stop()
 BetterRotation.enabled = false
 if BetterRotation.connection then
 BetterRotation.connection:Disconnect()
 BetterRotation.connection = nil
 end
end



local Spoofer = {
 statOriginals = {tokens = nil, points = nil, wins = nil},
 levelOriginal = nil,
 targetLevel = nil,
 spoofLevelVal = "",
 spoofTokensVal = "",
 spoofPointsVal = "",
 spoofWinsVal = "",
 activeTag = nil
}

local Nametags = { selectedNametag = "" }




local LagSwitch = {
 enabled = false,
 visualizerModel = nil,
 connection = nil,
 lastTick = 0,
 minPing = 80,
 maxPing = 300,
 updateDelay = 0.5,
 chamsColor = Color3.fromRGB(0, 255, 255),
 chamsMaterial = Enum.Material.ForceField,
 trailDelay = 0.0,
 chamsTransparency = 1.0
}

function LagSwitch.UpdateVisuals()
 if LagSwitch.visualizerModel then
 for _, v in pairs(LagSwitch.visualizerModel:GetDescendants()) do
 if v:IsA("BasePart") or v:IsA("MeshPart") then
 v.Color = LagSwitch.chamsColor
 v.Material = LagSwitch.chamsMaterial
 v.Transparency = LagSwitch.chamsTransparency
 end
 end
 end
end

function LagSwitch.setLag(state)
 LagSwitch.enabled = state
 if state then
 task.spawn(function()
 while LagSwitch.enabled do
 local minP = LagSwitch.minPing or 80
 local maxP = LagSwitch.maxPing or 300
 if maxP > 2000 then maxP = 2000 end
 if minP > maxP then minP = maxP end
 local randomPingMs = math.random(minP, maxP)
 local currentFakePing = randomPingMs / 1000
 pcall(function()
 local netSettings = settings():GetService("NetworkSettings")
 if sethiddenproperty then
 sethiddenproperty(netSettings, "IncomingReplicationLag", currentFakePing)
 else
 netSettings.IncomingReplicationLag = currentFakePing
 end
 end)
 task.wait(2)
 end
 end)

 local char = LocalPlayer.Character
 if not char then return end
 char.Archivable = true
 local clone = char:Clone()
 local fakeHum = clone:FindFirstChildOfClass("Humanoid")
 if fakeHum then fakeHum:Destroy() end
 clone.Name = "LagSwitchChams"

 for _, v in pairs(clone:GetDescendants()) do
 if v:IsA("BasePart") or v:IsA("MeshPart") then
 v.Anchored = true
 v.CanCollide = false
 v.CanTouch = false
 v.CanQuery = false
 v.Massless = true
 v.Material = LagSwitch.chamsMaterial
 v.Color = LagSwitch.chamsColor
 v.Transparency = LagSwitch.chamsTransparency
 elseif v:IsA("Script") or v:IsA("LocalScript") then v:Destroy()
 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
 end

 clone.Parent = workspace
 LagSwitch.visualizerModel = clone
 LagSwitch.lastTick = tick()

 LagSwitch.connection = RunService.RenderStepped:Connect(function()
 if not LocalPlayer.Character or not LagSwitch.visualizerModel then return end
 if tick() - LagSwitch.lastTick >= LagSwitch.trailDelay then
 LagSwitch.lastTick = tick()
 for _, part in pairs(LocalPlayer.Character:GetChildren()) do
 if part:IsA("BasePart") then
 local clonePart = LagSwitch.visualizerModel:FindFirstChild(part.Name)
 if clonePart and clonePart:IsA("BasePart") then clonePart.CFrame = part.CFrame end
 end
 end
 end
 end)
 else
 pcall(function()
 if settings() and settings().Network then settings().Network.IncomingReplicationLag = 0 end
 end)
 if LagSwitch.visualizerModel then LagSwitch.visualizerModel:Destroy(); LagSwitch.visualizerModel = nil end
 if LagSwitch.connection then LagSwitch.connection:Disconnect(); LagSwitch.connection = nil end
 end
end



function Spoofer.updateTabLeaderboard()
 local pgui = LocalPlayer:FindFirstChild("PlayerGui")
 if not pgui then return end

 local function scanAndApply(parent)
 if not parent then return end
 for _, obj in ipairs(parent:GetDescendants()) do
 if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("CanvasGroup") then
 local isLocalFrame = (obj.Name == LocalPlayer.Name)
 if not isLocalFrame then
 local nameLbl = obj:FindFirstChild("PlayerName") or obj:FindFirstChild("Name") or obj:FindFirstChild("Username")
 if nameLbl and nameLbl:IsA("TextLabel") then
 if nameLbl.Text == LocalPlayer.Name or nameLbl.Text == LocalPlayer.DisplayName then isLocalFrame = true end
 end
 end

 if isLocalFrame then
 if Spoofer.targetLevel then
 local lvlLbl = obj:FindFirstChild("Level") or obj:FindFirstChild("Lvl")
 if lvlLbl and lvlLbl:IsA("TextLabel") then lvlLbl.Text = tostring(Spoofer.targetLevel) end
 end
 if Spoofer.activeTag and Spoofer.activeTag ~= "" then
 local tagLbl = obj:FindFirstChild("Tag") or obj:FindFirstChild("Nametag") or obj:FindFirstChild("Badge") or obj:FindFirstChild("Role")
 if tagLbl and tagLbl:IsA("TextLabel") then tagLbl.Text = tostring(Spoofer.activeTag) end
 end
 if Spoofer.spoofWinsVal and Spoofer.spoofWinsVal ~= "" then
 local winLbl = obj:FindFirstChild("Wins") or obj:FindFirstChild("Survivals") or obj:FindFirstChild("WinsText")
 if winLbl and winLbl:IsA("TextLabel") then winLbl.Text = Spoofer.formatNumber(Spoofer.spoofWinsVal) end
 end
 if Spoofer.spoofTokensVal and Spoofer.spoofTokensVal ~= "" then
 local tokLbl = obj:FindFirstChild("Tokens") or obj:FindFirstChild("Cash")
 if tokLbl and tokLbl:IsA("TextLabel") then tokLbl.Text = Spoofer.formatNumber(Spoofer.spoofTokensVal) end
 end
 if Spoofer.spoofPointsVal and Spoofer.spoofPointsVal ~= "" then
 local pntLbl = obj:FindFirstChild("Points")
 if pntLbl and pntLbl:IsA("TextLabel") then pntLbl.Text = Spoofer.formatNumber(Spoofer.spoofPointsVal) end
 end
 end
 end
 end
 end

 scanAndApply(pgui:FindFirstChild("Global"))
 scanAndApply(pgui:FindFirstChild("Tab"))
 scanAndApply(pgui:FindFirstChild("Leaderboard"))
 scanAndApply(pgui:FindFirstChild("Scoreboard"))
 scanAndApply(pgui:FindFirstChild("Menu"))
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
 if input.KeyCode == Enum.KeyCode.Tab then
 task.wait(0.05)
 Spoofer.updateTabLeaderboard()
 end
end)




function Spoofer.formatNumber(num)
 local str = tostring(num):gsub(",", "")
 local reversed = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
 if reversed:sub(1, 1) == "," then reversed = reversed:sub(2) end
 return reversed
end

function Spoofer.setLevel(number)
 local gui = LocalPlayer:FindFirstChild("PlayerGui") if not gui then return end
 local menu = gui:FindFirstChild("Menu") if not menu then return end
 local views = menu:FindFirstChild("Views") if not views then return end
 local default = views:FindFirstChild("Default") if not default then return end
 local bottom = default:FindFirstChild("Bottom") if not bottom then return end
 local lvl = bottom:FindFirstChild("Level") if not lvl then return end
 local lbl = lvl:FindFirstChild("Level")
 if lbl and lbl:IsA("TextLabel") then
 if not Spoofer.levelOriginal then Spoofer.levelOriginal = lbl.Text end
 lbl.Text = "LEVEL " .. number
 end
 Spoofer.updateTabLeaderboard()
end

function Spoofer.resetLevel()
 if not Spoofer.levelOriginal then return end
 local gui = LocalPlayer:FindFirstChild("PlayerGui") if not gui then return end
 local menu = gui:FindFirstChild("Menu") if not menu then return end
 local views = menu:FindFirstChild("Views") if not views then return end
 local default = views:FindFirstChild("Default") if not default then return end
 local bottom = default:FindFirstChild("Bottom") if not bottom then return end
 local lvl = bottom:FindFirstChild("Level") if not lvl then return end local lbl = lvl:FindFirstChild("Level")
 if lbl and lbl:IsA("TextLabel") then lbl.Text = Spoofer.levelOriginal end Spoofer.levelOriginal = nil
 Spoofer.targetLevel = nil
 Spoofer.updateTabLeaderboard()
end

LocalPlayer.CharacterAdded:Connect(function()
 if Spoofer.targetLevel then task.wait(0.3) pcall(Spoofer.setLevel, Spoofer.targetLevel) end
 if Spoofer.activeTag then task.wait(0.5) pcall(Nametags.applyNametag, Spoofer.activeTag) end
 task.wait(0.5)
 Spoofer.updateTabLeaderboard()
end)

if LocalPlayer:FindFirstChild("PlayerGui") then
 LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
 if (child.Name == "Menu" or child.Name == "Global" or child.Name == "Tab") and Spoofer.targetLevel then
 task.wait(0.2)
 pcall(Spoofer.setLevel, Spoofer.targetLevel)
 Spoofer.updateTabLeaderboard()
 end
 end)
end

function Spoofer.saveStatOriginals()
 local gui = LocalPlayer:FindFirstChild("PlayerGui") if not gui then return end
 local menu = gui:FindFirstChild("Menu") if not menu then return end
 local views = menu:FindFirstChild("Views") if not views then return end
 local default = views:FindFirstChild("Default") if not default then return end
 local bottom = default:FindFirstChild("Bottom") if not bottom then return end
 local left = bottom:FindFirstChild("Left") if not left then return end
 if not Spoofer.statOriginals.tokens then local t = left:FindFirstChild("Tokens") if t then local cash = t:FindFirstChild("Cash") if cash then Spoofer.statOriginals.tokens = cash.Text end end end
 if not Spoofer.statOriginals.points then local p = left:FindFirstChild("Points") if p then local cash = p:FindFirstChild("Cash") if cash then Spoofer.statOriginals.points = cash.Text end end end
 if not Spoofer.statOriginals.wins then local s = left:FindFirstChild("Survivals") if s then local cash = s:FindFirstChild("Cash") if cash then Spoofer.statOriginals.wins = cash.Text end end end
end

function Spoofer.setStats(tokens, points, wins)
 Spoofer.saveStatOriginals()
 local gui = LocalPlayer:FindFirstChild("PlayerGui") if not gui then return end
 local menu = gui:FindFirstChild("Menu") if not menu then return end
 local views = menu:FindFirstChild("Views") if not views then return end
 local default = views:FindFirstChild("Default") if not default then return end
 local bottom = default:FindFirstChild("Bottom") if not bottom then return end
 local left = bottom:FindFirstChild("Left") if not left then return end
 if tokens and tokens ~= "" then local t = left:FindFirstChild("Tokens") if t then local cash = t:FindFirstChild("Cash") if cash then cash.Text = Spoofer.formatNumber(tokens) end end end
 if points and points ~= "" then local p = left:FindFirstChild("Points") if p then local cash = p:FindFirstChild("Cash") if cash then cash.Text = Spoofer.formatNumber(points) end end end
 if wins and wins ~= "" then local s = left:FindFirstChild("Survivals") if s then local cash = s:FindFirstChild("Cash") if cash then cash.Text = Spoofer.formatNumber(wins) end end end
 Spoofer.updateTabLeaderboard()
end

function Spoofer.resetStats()
 if not Spoofer.statOriginals.tokens and not Spoofer.statOriginals.points and not Spoofer.statOriginals.wins then return end
 local gui = LocalPlayer:FindFirstChild("PlayerGui") if not gui then return end
 local menu = gui:FindFirstChild("Menu") if not menu then return end
 local views = menu:FindFirstChild("Views") if not views then return end
 local default = views:FindFirstChild("Default") if not default then return end
 local bottom = default:FindFirstChild("Bottom") if not bottom then return end
 local left = bottom:FindFirstChild("Left") if not left then return end
 if Spoofer.statOriginals.tokens then local t = left:FindFirstChild("Tokens") if t then local cash = t:FindFirstChild("Cash") if cash then cash.Text = Spoofer.statOriginals.tokens end end end
 if Spoofer.statOriginals.points then local p = left:FindFirstChild("Points") if p then local cash = p:FindFirstChild("Cash") if cash then cash.Text = Spoofer.statOriginals.points end end end
 if Spoofer.statOriginals.wins then local s = left:FindFirstChild("Survivals") if s then local cash = s:FindFirstChild("Cash") if cash then cash.Text = Spoofer.statOriginals.wins end end end
 Spoofer.statOriginals = {tokens = nil, points = nil, wins = nil}
 Spoofer.spoofTokensVal = ""
 Spoofer.spoofPointsVal = ""
 Spoofer.spoofWinsVal = ""
 Spoofer.updateTabLeaderboard()
end




function Nametags.getNametagList()
 local items = {}
 local seen = {}

 local function addNamesFrom(folder)
 if folder then
 for _, child in ipairs(folder:GetChildren()) do
 if not seen[child.Name] then
 seen[child.Name] = true
 table.insert(items, child.Name)
 end
 end
 end
 end

 local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
 if itemsFolder then
 addNamesFrom(itemsFolder:FindFirstChild("Nametags"))
 addNamesFrom(itemsFolder:FindFirstChild("Tags"))
 local cos = itemsFolder:FindFirstChild("Cosmetics")
 if cos then addNamesFrom(cos:FindFirstChild("Nametags")) addNamesFrom(cos:FindFirstChild("Tags")) end
 end

 if #items == 0 then
 for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
 if desc:IsA("Folder") and (desc.Name:lower() == "nametags" or desc.Name:lower() == "tags") then addNamesFrom(desc) end
 end
 end

 if #items == 0 then
 local fallbackList = { "VIP", "Developer", "Staff", "Content Creator", "Moderator", "Veteran", "Pro", "Champion", "Legend", "Master", "Evader", "Survivor", "Speedrunner", "Ghost", "Demon", "Angel", "King", "Queen", "Boss", "God" }
 for _, name in ipairs(fallbackList) do table.insert(items, name) end
 end

 table.sort(items)
 return items
end

function Nametags.applyNametag(name)
 if not name or name == "" then return end
 Nametags.selectedNametag = name
 Spoofer.activeTag = name

 local rs = game:GetService("ReplicatedStorage")
 local nametagsFolder = rs:FindFirstChild("Items") and rs.Items:FindFirstChild("Nametags")

 if nametagsFolder then
 local tagModule = nametagsFolder:FindFirstChild(name)
 if tagModule and tagModule:IsA("ModuleScript") then
 local tagId = tagModule:GetAttribute("ID")
 if tagId ~= nil then
 pcall(function() LocalPlayer:SetAttribute("Nametag", tagId) end)
 pcall(function() LocalPlayer:SetAttribute("Tag", tagId) end)

 if LocalPlayer.Character then
 pcall(function() LocalPlayer.Character:SetAttribute("Nametag", tagId) end)
 pcall(function() LocalPlayer.Character:SetAttribute("Tag", tagId) end)
 end

 local evadePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
 if evadePlayers then
 local playerModel = evadePlayers:FindFirstChild(LocalPlayer.Name)
 if playerModel then
 pcall(function() playerModel:SetAttribute("Nametag", tagId) end)
 pcall(function() playerModel:SetAttribute("Tag", tagId) end)
 end
 end
 end
 end
 end

 if Spoofer.updateTabLeaderboard then pcall(function() Spoofer.updateTabLeaderboard() end) end
 if Library and Library.Notify then Library:Notify({ Title = "Nametags", Description = "Applied Nametag: " .. name, Time = 4 }) end
end

function Nametags.openBrowser(callback)
 local items = Nametags.getNametagList()
 local w, h = 360, 250

 local browser = Instance.new("ScreenGui")
 browser.Name = "NametagsBrowser"
 browser.Parent = LocalPlayer:WaitForChild("PlayerGui")
 browser.DisplayOrder = 99999
 browser.IgnoreGuiInset = true
 browser.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

 local overlay = Instance.new("TextButton")
 overlay.Size = UDim2.new(1, 0, 1, 0)
 overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
 overlay.BackgroundTransparency = 1
 overlay.BorderSizePixel = 0
 overlay.Text = ""
 overlay.AutoButtonColor = false
 overlay.ZIndex = 49
 overlay.Parent = browser
 TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()

 local blur = Instance.new("BlurEffect")
 blur.Size = 0
 blur.Parent = browser
 TweenService:Create(blur, TweenInfo.new(0.3), {Size = 6}):Play()

 local bg = Instance.new("Frame")
 bg.Size = UDim2.new(0, w, 0, 0)
 bg.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
 bg.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
 bg.BackgroundTransparency = 0.05
 bg.BorderSizePixel = 0
 bg.ZIndex = 50
 bg.ClipsDescendants = true
 bg.Parent = browser

 local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = bg
 local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(0, 190, 200) stroke.Thickness = 1.6 stroke.Transparency = 0.3 stroke.Parent = bg

 local titleBar = Instance.new("Frame")
 titleBar.Size = UDim2.new(1, 0, 0, 34)
 titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
 titleBar.BackgroundTransparency = 0.1
 titleBar.BorderSizePixel = 0
 titleBar.ZIndex = 51
 titleBar.Parent = bg

 local titleCorner = Instance.new("UICorner") titleCorner.CornerRadius = UDim.new(0, 10) titleCorner.Parent = titleBar

 local titleLabel = Instance.new("TextLabel")
 titleLabel.Size = UDim2.new(0, 150, 1, 0)
 titleLabel.Position = UDim2.new(0, 12, 0, 0)
 titleLabel.BackgroundTransparency = 1
 titleLabel.Text = "Select Nametag (" .. #items .. ")"
 titleLabel.TextColor3 = Color3.fromRGB(80, 230, 240)
 titleLabel.TextSize = 13
 titleLabel.Font = Enum.Font.GothamBold
 titleLabel.TextXAlignment = Enum.TextXAlignment.Left
 titleLabel.ZIndex = 52
 titleLabel.Parent = titleBar

 local searchBox = Instance.new("TextBox")
 searchBox.Size = UDim2.new(0, 140, 0, 22)
 searchBox.Position = UDim2.new(1, -152, 0, 6)
 searchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
 searchBox.BackgroundTransparency = 0.2
 searchBox.BorderSizePixel = 0
 searchBox.PlaceholderText = "Search tag..."
 searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
 searchBox.Text = ""
 searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
 searchBox.TextSize = 11
 searchBox.Font = Enum.Font.Gotham
 searchBox.ZIndex = 52
 searchBox.Parent = titleBar

 local sbCorner = Instance.new("UICorner") sbCorner.CornerRadius = UDim.new(0, 5) sbCorner.Parent = searchBox
 local sbStroke = Instance.new("UIStroke") sbStroke.Color = Color3.fromRGB(0, 120, 130) sbStroke.Thickness = 1 sbStroke.Transparency = 0.4 sbStroke.Parent = searchBox

 local sf = Instance.new("ScrollingFrame")
 sf.Size = UDim2.new(1, -14, 1, -42)
 sf.Position = UDim2.new(0, 7, 0, 38)
 sf.BackgroundTransparency = 1
 sf.BorderSizePixel = 0
 sf.CanvasSize = UDim2.new(0, 0, 0, 0)
 sf.ScrollBarThickness = 3
 sf.ScrollBarImageColor3 = Color3.fromRGB(0, 190, 200)
 sf.ScrollBarImageTransparency = 0.3
 sf.ZIndex = 50
 sf.Parent = bg

 local grid = Instance.new("UIGridLayout")
 grid.CellSize = UDim2.new(0, 108, 0, 32)
 grid.CellPadding = UDim2.new(0, 6, 0, 6)
 grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
 grid.Parent = sf

 local slots = {}
 local function closeBrowser()
 TweenService:Create(blur, TweenInfo.new(0.25), {Size = 0}):Play()
 TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
 TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, w, 0, 0), BackgroundTransparency = 0.9}):Play()
 task.delay(0.25, function() browser:Destroy() end)
 end

 local function updateList(filter)
 for _, slot in ipairs(slots) do slot:Destroy() end
 slots = {}
 local count = 0
 for _, name in ipairs(items) do
 if filter == "" or name:lower():find(filter:lower(), 1, true) then
 count = count + 1
 local slot = Instance.new("TextButton")
 slot.Size = UDim2.new(1, 0, 0, 32)
 slot.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
 slot.BackgroundTransparency = 0.2
 slot.BorderSizePixel = 0
 slot.Text = name
 slot.TextColor3 = Color3.fromRGB(240, 240, 240)
 slot.TextSize = 11
 slot.Font = Enum.Font.GothamSemibold
 slot.ZIndex = 51
 slot.Parent = sf

 local slCorner = Instance.new("UICorner") slCorner.CornerRadius = UDim.new(0, 6) slCorner.Parent = slot
 local slStroke = Instance.new("UIStroke") slStroke.Color = Color3.fromRGB(0, 90, 100) slStroke.Thickness = 1 slStroke.Transparency = 0.4 slStroke.Parent = slot

 slot.Activated:Connect(function()
 if callback then callback(name) end
 closeBrowser()
 end)
 table.insert(slots, slot)
 end
 end
 sf.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / 3) * 38)
 end

 updateList("")
 searchBox:GetPropertyChangedSignal("Text"):Connect(function() updateList(searchBox.Text) end)
 overlay.Activated:Connect(function() closeBrowser() end)
 TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, w, 0, h)}):Play()
end
















local Effects, CustomTrail
;(function()

local FX_RS = game:GetService("ReplicatedStorage")


local FX_EFFECT_CLASSES = {
 ParticleEmitter = true, Beam = true, Trail = true, Fire = true, Smoke = true,
 Sparkles = true, PointLight = true, SpotLight = true, SurfaceLight = true, Highlight = true,
}


local FX_JUNK_CLASSES = {
 Motor6D = true, Weld = true, WeldConstraint = true, Snap = true, Rotate = true,
 RotateP = true, RotateV = true, Glue = true, ManualWeld = true,
 SpecialMesh = true, BlockMesh = true, CylinderMesh = true, FileMesh = true,
 Vector3Value = true, StringValue = true, NumberValue = true, BoolValue = true,
 CFrameValue = true, ObjectValue = true, IntValue = true, Color3Value = true,
 Decal = true, Texture = true, WrapTarget = true, WrapLayer = true, FaceControls = true,
 Humanoid = true, AnimationController = true, Animator = true, Animation = true,
 CharacterMesh = true, Shirt = true, Pants = true, ShirtGraphic = true, BodyColors = true,
 Accessory = true, HumanoidDescription = true, Folder = true,
 Script = true, LocalScript = true, ModuleScript = true, Status = true,
}


local FX_R15_TO_R6 = {
 Head = "Head",
 UpperTorso = "Torso", LowerTorso = "Torso", HumanoidRootPart = "Torso", Torso = "Torso",
 LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Arm",
 RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Arm",
 LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Leg",
 RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Leg",
}

local FX_BODY_PARTS = { "Auto", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "TorsoRot", "ArmRot" }




local AuraDB = { list = {}, byName = {}, count = 0, source = "none" }

function AuraDB.build()
 table.clear(AuraDB.list)
 table.clear(AuraDB.byName)

 local function add(name, id, mod)
 if name and mod and not AuraDB.byName[name] then
 AuraDB.byName[name] = { name = name, id = id, module = mod }
 table.insert(AuraDB.list, name)
 end
 end


 local items = FX_RS:FindFirstChild("Items")
 local registry = items and items:FindFirstChild("Registry")
 if registry then
 local ok, reg = pcall(require, registry)
 if ok and type(reg) == "table" and type(reg.GetAll) == "function" then
 local ok2, all = pcall(reg.GetAll)
 if ok2 and type(all) == "table" then
 for _, entry in pairs(all) do
 local mod = type(entry) == "table" and entry.Module or nil
 if mod and mod:IsA("ModuleScript") then
 local ok3, cfg = pcall(require, mod)
 if ok3 and type(cfg) == "table" then
 local eq = cfg.EquipInfo
 if type(eq) == "table" and eq.SlotType == "Unusual" then
 add(mod.Name, entry.Id, mod)
 end
 end
 end
 end
 if #AuraDB.list > 0 then AuraDB.source = "Registry" end
 end
 end
 end


 if #AuraDB.list == 0 then
 local base = items and items:FindFirstChild("BaseItems")
 if base then
 for _, mod in ipairs(base:GetDescendants()) do
 if mod:IsA("ModuleScript")
 and (mod:FindFirstChild("CharacterClassic") or mod:FindFirstChild("Character") or mod:FindFirstChild("Aura")) then
 add(mod.Name, 0, mod)
 end
 end
 if #AuraDB.list > 0 then AuraDB.source = "BaseItems scan" end
 end
 end

 table.sort(AuraDB.list)
 AuraDB.count = #AuraDB.list
 return AuraDB.count
end


function AuraDB.resolve(query)
 if type(query) ~= "string" or query == "" then return nil end
 if AuraDB.byName[query] then return query end
 local q = query:lower():gsub("%s+", "")
 if q == "" then return nil end
 for _, n in ipairs(AuraDB.list) do if n:lower() == q then return n end end
 for _, n in ipairs(AuraDB.list) do if n:lower():sub(1, #q) == q then return n end end
 for _, n in ipairs(AuraDB.list) do if n:lower():find(q, 1, true) then return n end end
 return nil
end





local function fxHasEffect(inst)
 if FX_EFFECT_CLASSES[inst.ClassName] then return true end
 for _, d in ipairs(inst:GetDescendants()) do
 if FX_EFFECT_CLASSES[d.ClassName] then return true end
 end
 return false
end


local function fxIsPayload(inst)
 if FX_EFFECT_CLASSES[inst.ClassName] then return true end
 if FX_JUNK_CLASSES[inst.ClassName] then return false end
 if inst:IsA("Attachment") or inst:IsA("BasePart") or inst:IsA("Model") then
 return fxHasEffect(inst)
 end
 return false
end


function AuraDB.getPayload(auraName)
 local info = AuraDB.byName[auraName]
 if not info then return nil, "аура '" .. tostring(auraName) .. "' не найдена в каталоге" end
 local mod = info.module
 if not mod or not mod.Parent then return nil, "модуль ауры выгружен" end

 local groups, mode = {}, nil

 local function harvest(model, remap)
 for _, srcPart in ipairs(model:GetChildren()) do
 if srcPart:IsA("BasePart") then
 local fx = {}
 for _, child in ipairs(srcPart:GetChildren()) do
 if fxIsPayload(child) then table.insert(fx, child) end
 end
 if #fx > 0 then
 local target = srcPart.Name
 if remap then target = FX_R15_TO_R6[srcPart.Name] or srcPart.Name end
 table.insert(groups, { target = target, src = srcPart, fx = fx })
 end
 end
 end
 end


 local classic = mod:FindFirstChild("CharacterClassic")
 if classic and classic:IsA("Model") then
 harvest(classic, false)
 mode = "CharacterClassic"
 end


 if #groups == 0 then
 for _, child in ipairs(mod:GetChildren()) do
 if child:IsA("Model") and (child.Name == "Character" or child.Name == "CharacterOLD") then
 harvest(child, true)
 end
 end
 if #groups > 0 then mode = "Character (R15->R6)" end
 end


 if #groups == 0 then
 local fx = {}
 for _, child in ipairs(mod:GetChildren()) do
 if (child:IsA("BasePart") or child:IsA("Model")) and fxHasEffect(child) then
 table.insert(fx, child)
 end
 end
 if #fx > 0 then
 table.insert(groups, { target = "Torso", src = nil, fx = fx })
 mode = "RELICS"
 end
 end

 if #groups == 0 then return nil, "у ауры '" .. auraName .. "' нет визуальных эффектов" end
 return { mode = mode, groups = groups }
end




local RigTarget = {}

function RigTarget.get()
 local rigs = workspace:FindFirstChild("Rigs")
 if rigs then
 local m = rigs:FindFirstChild(LocalPlayer.Name)
 if m and m:IsA("Model") and m:FindFirstChild("Head") then return m end
 for _, child in ipairs(rigs:GetChildren()) do
 if child:IsA("Model") and child:FindFirstChild("Head") and child:FindFirstChild("Torso") then
 if child.Name == LocalPlayer.Name then return child end
 end
 end
 end
 local ch = LocalPlayer.Character
 if ch and (ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")) then return ch end
 return nil
end


function RigTarget.findPart(rig, name)
 if not rig or not name then return nil end
 local p = rig:FindFirstChild(name)
 if p and p:IsA("BasePart") then return p end
 local alt = FX_R15_TO_R6[name]
 if alt then
 p = rig:FindFirstChild(alt)
 if p and p:IsA("BasePart") then return p end
 end

 for _, cand in ipairs({ "Torso", "UpperTorso", "HumanoidRootPart" }) do
 p = rig:FindFirstChild(cand)
 if p and p:IsA("BasePart") then return p end
 end
 return nil
end






local FxTune = {}

local function scaleNumberSeq(seq, k)
 local kp = {}
 for _, p in ipairs(seq.Keypoints) do
 table.insert(kp, NumberSequenceKeypoint.new(p.Time, math.max(p.Value * k, 0), math.max(p.Envelope * k, 0)))
 end
 return NumberSequence.new(kp)
end

local function fadeNumberSeq(seq, t)
 if t <= 0 then return seq end
 local kp = {}
 for _, p in ipairs(seq.Keypoints) do
 local v = p.Value + (1 - p.Value) * t
 table.insert(kp, NumberSequenceKeypoint.new(p.Time, math.clamp(v, 0, 1), 0))
 end
 return NumberSequence.new(kp)
end


function FxTune.capture(inst)
 local b = { class = inst.ClassName }
 if inst:IsA("ParticleEmitter") then
 b.Size, b.Color, b.Transparency = inst.Size, inst.Color, inst.Transparency
 b.Rate, b.Speed, b.Lifetime = inst.Rate, inst.Speed, inst.Lifetime
 elseif inst:IsA("Beam") then
 b.Width0, b.Width1, b.Color, b.Transparency = inst.Width0, inst.Width1, inst.Color, inst.Transparency
 elseif inst:IsA("Trail") then
 b.WidthScale, b.Color, b.Transparency, b.Lifetime = inst.WidthScale, inst.Color, inst.Transparency, inst.Lifetime
 elseif inst:IsA("Fire") then
 b.Size, b.Heat, b.Color, b.SecondaryColor = inst.Size, inst.Heat, inst.Color, inst.SecondaryColor
 elseif inst:IsA("Smoke") then
 b.Size, b.Color, b.Opacity, b.RiseVelocity = inst.Size, inst.Color, inst.Opacity, inst.RiseVelocity
 elseif inst:IsA("Sparkles") then
 b.SparkleColor = inst.SparkleColor
 elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
 b.Range, b.Brightness, b.Color = inst.Range, inst.Brightness, inst.Color
 elseif inst:IsA("Highlight") then
 b.FillColor, b.OutlineColor = inst.FillColor, inst.OutlineColor
 b.FillTransparency, b.OutlineTransparency = inst.FillTransparency, inst.OutlineTransparency
 elseif inst:IsA("Attachment") then
 b.Position, b.Orientation = inst.Position, inst.Orientation
 elseif inst:IsA("BasePart") then
 b.Size, b.Color, b.Transparency = inst.Size, inst.Color, inst.Transparency
 end
 return b
end


function FxTune.apply(inst, b, opts)
 if not inst or not inst.Parent or not b then return end
 local k = opts.scale or 1
 local col = opts.color
 local use = opts.useColor and col ~= nil
 local t = math.clamp(opts.transparency or 0, 0, 1)
 local rateK = opts.rate or 1

 if inst:IsA("ParticleEmitter") then
 inst.Size = scaleNumberSeq(b.Size, k)
 inst.Transparency = fadeNumberSeq(b.Transparency, t)
 inst.Rate = math.max(b.Rate * rateK, 0)
 inst.Speed = NumberRange.new(b.Speed.Min * k, b.Speed.Max * k)
 if use then inst.Color = ColorSequence.new(col) else inst.Color = b.Color end
 elseif inst:IsA("Beam") then
 inst.Width0, inst.Width1 = b.Width0 * k, b.Width1 * k
 inst.Transparency = fadeNumberSeq(b.Transparency, t)
 if use then inst.Color = ColorSequence.new(col) else inst.Color = b.Color end
 elseif inst:IsA("Trail") then
 inst.WidthScale = scaleNumberSeq(b.WidthScale, k)
 inst.Transparency = fadeNumberSeq(b.Transparency, t)
 if use then inst.Color = ColorSequence.new(col) else inst.Color = b.Color end
 elseif inst:IsA("Fire") then
 inst.Size, inst.Heat = b.Size * k, b.Heat
 if use then
 inst.Color = col
 inst.SecondaryColor = Color3.new(col.R * 0.45, col.G * 0.45, col.B * 0.45)
 else
 inst.Color, inst.SecondaryColor = b.Color, b.SecondaryColor
 end
 elseif inst:IsA("Smoke") then
 inst.Size = b.Size * k
 inst.Opacity = math.clamp(b.Opacity * (1 - t), 0, 1)
 inst.Color = use and col or b.Color
 elseif inst:IsA("Sparkles") then
 inst.SparkleColor = use and col or b.SparkleColor
 elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
 inst.Range = math.clamp(b.Range * k, 0, 60)
 inst.Brightness = b.Brightness * (1 - t)
 inst.Color = use and col or b.Color
 elseif inst:IsA("Highlight") then
 inst.FillTransparency = math.clamp(b.FillTransparency + (1 - b.FillTransparency) * t, 0, 1)
 inst.OutlineTransparency = math.clamp(b.OutlineTransparency + (1 - b.OutlineTransparency) * t, 0, 1)
 inst.FillColor = use and col or b.FillColor
 inst.OutlineColor = use and col or b.OutlineColor
 elseif inst:IsA("Attachment") then
 inst.Position = b.Position * k + Vector3.new(0, opts.offsetY or 0, 0)
 elseif inst:IsA("BasePart") then
 inst.Size = b.Size * k
 inst.Transparency = math.clamp(b.Transparency + (1 - b.Transparency) * t, 0, 1)
 if use and b.Transparency < 1 then inst.Color = col end
 end
end




Effects = {}
Effects.LAYER_COUNT = 5
Effects.MAIN = 0
Effects.layers = {}
Effects.autoReapply = true
Effects._settings = { autoReapplyOnRespawn = true, defaultsEnabled = false }

local function newLayer(i)
 return {
 index = i, auraName = "", part = "Auto",
 scale = 1, color = Color3.fromRGB(0, 170, 255), useColor = false,
 transparency = 0, rate = 1, offsetY = 0,
 enabled = false, spawned = {}, mode = "-",
 }
end

for i = Effects.MAIN, Effects.LAYER_COUNT do
 Effects.layers[i] = newLayer(i)
end

function Effects.getLayer(i)
 local l = Effects.layers[i]
 if not l then l = newLayer(i) Effects.layers[i] = l end
 return l
end


function Effects.clearLayer(i)
 local layer = Effects.getLayer(i)
 for _, rec in ipairs(layer.spawned) do
 if rec.inst then pcall(function() rec.inst:Destroy() end) end
 end
 table.clear(layer.spawned)
 layer.mode = "-"

 local rig = RigTarget.get()
 if rig then
 local prefix = "FW_L" .. tostring(i) .. "_"
 for _, d in ipairs(rig:GetDescendants()) do
 if d.Name:sub(1, #prefix) == prefix then pcall(function() d:Destroy() end) end
 end
 end
 return true
end


function Effects.refreshLayer(i)
 local layer = Effects.getLayer(i)
 local opts = {
 scale = layer.scale, color = layer.color, useColor = layer.useColor,
 transparency = layer.transparency, rate = layer.rate, offsetY = layer.offsetY,
 }
 for _, rec in ipairs(layer.spawned) do
 if rec.inst and rec.inst.Parent then
 FxTune.apply(rec.inst, rec.base, opts)

 if rec.weld and rec.relCF then
 local pos = rec.relCF.Position * layer.scale + Vector3.new(0, layer.offsetY, 0)
 rec.weld.C0 = CFrame.new(pos) * rec.relCF.Rotation
 end
 end
 end
 return true
end


function Effects.applyLayer(i, auraName)
 local layer = Effects.getLayer(i)
 auraName = AuraDB.resolve(auraName or layer.auraName)
 if not auraName then
 return false, "аура не найдена (введено: '" .. tostring(layer.auraName) .. "')"
 end
 layer.auraName = auraName

 local rig = RigTarget.get()
 if not rig then return false, "живой риг не найден (workspace.Rigs." .. LocalPlayer.Name .. ")" end

 local payload, err = AuraDB.getPayload(auraName)
 if not payload then return false, err end

 Effects.clearLayer(i)
 layer.mode = payload.mode

 local prefix = "FW_L" .. tostring(i) .. "_"
 local made = 0

 for _, group in ipairs(payload.groups) do
 local targetName = (layer.part == "Auto") and group.target or layer.part
 local targetPart = RigTarget.findPart(rig, targetName)
 if targetPart then
 for _, srcFx in ipairs(group.fx) do
 local ok, clone = pcall(function() return srcFx:Clone() end)
 if ok and clone then
 clone.Name = prefix .. srcFx.Name
 local rec = { inst = clone, base = FxTune.capture(clone) }

 if clone:IsA("BasePart") or clone:IsA("Model") then

 local root = clone
 if clone:IsA("Model") then
 root = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
 end
 if root then
 local relCF = CFrame.new()
 if group.src then
 local okc, res = pcall(function()
 return group.src.CFrame:ToObjectSpace(root.CFrame)
 end)
 if okc and res then relCF = res end
 end
 for _, d in ipairs(clone:IsA("Model") and clone:GetDescendants() or { root }) do
 if d:IsA("BasePart") then
 d.Anchored, d.CanCollide, d.Massless = false, false, true
 end
 end
 clone.Parent = targetPart
 local weld = Instance.new("Weld")
 weld.Name = prefix .. "Weld"
 weld.Part0, weld.Part1 = targetPart, root
 weld.C0 = relCF
 weld.Parent = root
 rec.weld, rec.relCF = weld, relCF
 rec.base = FxTune.capture(root)
 rec.inst = root
 rec.holder = clone

 for _, d in ipairs(clone:GetDescendants()) do
 if FX_EFFECT_CLASSES[d.ClassName] or d:IsA("Attachment") then
 table.insert(layer.spawned, { inst = d, base = FxTune.capture(d) })
 end
 end
 else
 clone:Destroy()
 clone = nil
 end
 else
 clone.Parent = targetPart

 for _, d in ipairs(clone:GetDescendants()) do
 if FX_EFFECT_CLASSES[d.ClassName] then
 table.insert(layer.spawned, { inst = d, base = FxTune.capture(d) })
 end
 end
 end

 if clone then
 table.insert(layer.spawned, rec)
 made += 1
 end
 end
 end
 end
 end

 if made == 0 then
 return false, "не удалось прицепить ни один эффект (часть тела '" .. tostring(layer.part) .. "' не найдена)"
 end

 layer.enabled = true
 Effects.refreshLayer(i)
 return true, ("%s | %s | %d эффектов"):format(auraName, payload.mode, made)
end

function Effects.clearAllLayers()
 for i = Effects.MAIN, Effects.LAYER_COUNT do
 Effects.clearLayer(i)
 Effects.layers[i].enabled = false
 end
 return true
end

function Effects.reapplyAll()
 for i = Effects.MAIN, Effects.LAYER_COUNT do
 local l = Effects.layers[i]
 if l.enabled and l.auraName ~= "" then
 pcall(Effects.applyLayer, i, l.auraName)
 end
 end
end


function Effects.clearAura() return Effects.clearAllLayers() end
function Effects.applyAura(name) return Effects.applyLayer(Effects.MAIN, name) end
function Effects.getStatus()
 local on, names = 0, {}
 for i = Effects.MAIN, Effects.LAYER_COUNT do
 local l = Effects.layers[i]
 if l.enabled and #l.spawned > 0 then
 on += 1
 table.insert(names, (i == Effects.MAIN and "main:" or ("L" .. i .. ":")) .. l.auraName)
 end
 end
 if on == 0 then return "слоёв активно: 0" end
 return ("слоёв активно: %d | %s"):format(on, table.concat(names, ", "))
end




Effects._customAuraID = ""

function Effects.applyCustomAura(assetId, scale, transparency)
 local id = tostring(assetId or ""):gsub("%D", "")
 if id == "" then return false, "пустой Asset ID" end
 local rig = RigTarget.get()
 if not rig then return false, "живой риг не найден" end
 local target = RigTarget.findPart(rig, "Torso")
 if not target then return false, "нет Torso" end

 local objs
 local ok = pcall(function() objs = game:GetObjects("rbxassetid://" .. id) end)
 if not ok or type(objs) ~= "table" or #objs == 0 then
 return false, "не удалось загрузить asset " .. id .. " (нужен публичный Model)"
 end

 Effects.clearCustomAura()
 local holder = Instance.new("Folder")
 holder.Name = "FW_CustomAura"
 holder.Parent = target

 local n = 0
 for _, obj in ipairs(objs) do
 for _, d in ipairs(obj:GetDescendants()) do
 if FX_EFFECT_CLASSES[d.ClassName] then
 local att = Instance.new("Attachment")
 att.Name = "FW_CustomAtt"
 att.Parent = target
 local c = d:Clone()
 c.Parent = att
 local b = FxTune.capture(c)
 FxTune.apply(c, b, { scale = scale or 1, transparency = transparency or 0, rate = 1, useColor = false })
 att.Parent = holder.Parent
 n += 1
 end
 end
 obj:Destroy()
 end

 if n == 0 then
 holder:Destroy()
 return false, "в asset " .. id .. " нет частиц/бимов/трейлов"
 end
 return true, ("загружено %d эффектов из asset %s"):format(n, id)
end

function Effects.clearCustomAura()
 local rig = RigTarget.get()
 if not rig then return end
 for _, d in ipairs(rig:GetDescendants()) do
 if d.Name == "FW_CustomAura" or d.Name == "FW_CustomAtt" then pcall(function() d:Destroy() end) end
 end
end




Effects.extra = {
 highlight = { on = false, color = Color3.fromRGB(0, 170, 255), transparency = 0.7 },
 light = { on = false, color = Color3.fromRGB(0, 170, 255), range = 14, brightness = 3 },
 fire = { on = false, color = Color3.fromRGB(255, 100, 0), size = 6, heat = 10 },
}

function Effects.toggleHighlight(state)
 Effects.extra.highlight.on = state and true or false
 local rig = RigTarget.get()
 if not rig then return false, "нет рига" end
 local hl = rig:FindFirstChild("FW_SelfGlow")
 if not state then if hl then hl:Destroy() end return true end
 if not hl then
 hl = Instance.new("Highlight")
 hl.Name = "FW_SelfGlow"
 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
 hl.Parent = rig
 end
 hl.Adornee = rig
 hl.Enabled = true
 hl.FillColor = Effects.extra.highlight.color
 hl.OutlineColor = Effects.extra.highlight.color
 hl.FillTransparency = Effects.extra.highlight.transparency
 hl.OutlineTransparency = 0
 return true
end

function Effects.togglePointLight(state)
 Effects.extra.light.on = state and true or false
 local rig = RigTarget.get()
 if not rig then return false, "нет рига" end
 local target = RigTarget.findPart(rig, "Torso")
 if not target then return false, "нет Torso" end
 local pl = target:FindFirstChild("FW_AuraGlow")
 if not state then if pl then pl:Destroy() end return true end
 if not pl then
 pl = Instance.new("PointLight")
 pl.Name = "FW_AuraGlow"
 pl.Parent = target
 end
 pl.Enabled = true
 pl.Color = Effects.extra.light.color
 pl.Range = Effects.extra.light.range
 pl.Brightness = Effects.extra.light.brightness
 pl.Shadows = false
 return true
end

function Effects.toggleFire(state)
 Effects.extra.fire.on = state and true or false
 local rig = RigTarget.get()
 if not rig then return false, "нет рига" end
 if not state then
 for _, d in ipairs(rig:GetDescendants()) do
 if d.Name == "FW_LegFire" then d:Destroy() end
 end
 return true
 end
 for _, legName in ipairs({ "Left Leg", "Right Leg" }) do
 local leg = rig:FindFirstChild(legName) or RigTarget.findPart(rig, "Torso")
 if leg then
 local f = leg:FindFirstChild("FW_LegFire")
 if not f then
 f = Instance.new("Fire")
 f.Name = "FW_LegFire"
 f.Parent = leg
 end
 f.Enabled = true
 f.Size = Effects.extra.fire.size
 f.Heat = Effects.extra.fire.heat
 f.Color = Effects.extra.fire.color
 local c = Effects.extra.fire.color
 f.SecondaryColor = Color3.new(c.R * 0.45, c.G * 0.45, c.B * 0.45)
 end
 end
 return true
end

function Effects.applyDefaultEffects()
 Effects._settings.defaultsEnabled = true
 Effects.toggleHighlight(Effects.extra.highlight.on)
 Effects.togglePointLight(Effects.extra.light.on)
 Effects.toggleFire(Effects.extra.fire.on)
 return true
end

function Effects.clearDefaultEffects()
 Effects._settings.defaultsEnabled = false
 local rig = RigTarget.get()
 if rig then
 for _, d in ipairs(rig:GetDescendants()) do
 if d.Name == "FW_SelfGlow" or d.Name == "FW_AuraGlow" or d.Name == "FW_LegFire" then
 pcall(function() d:Destroy() end)
 end
 end
 end
 return true
end




local TRAIL_PRESETS = {
 neon_cyan = { color1 = Color3.fromRGB(0, 255, 255), color2 = Color3.fromRGB(0, 150, 255), lifetime = 0.6, width0 = 1.2, width1 = 0.1, transparency = 0.15 },
 neon_purple = { color1 = Color3.fromRGB(255, 0, 255), color2 = Color3.fromRGB(150, 0, 255), lifetime = 0.7, width0 = 1.4, width1 = 0.15, transparency = 0.2 },
 neon_fire = { color1 = Color3.fromRGB(255, 100, 0), color2 = Color3.fromRGB(255, 200, 0), lifetime = 0.8, width0 = 1.6, width1 = 0.2, transparency = 0.1 },
 neon_ice = { color1 = Color3.fromRGB(0, 200, 255), color2 = Color3.fromRGB(100, 255, 255), lifetime = 0.9, width0 = 1.3, width1 = 0.12, transparency = 0.25 },
 neon_pink = { color1 = Color3.fromRGB(255, 105, 180), color2 = Color3.fromRGB(255, 20, 147), lifetime = 0.65, width0 = 1.1, width1 = 0.08, transparency = 0.18 },
 neon_green = { color1 = Color3.fromRGB(0, 255, 100), color2 = Color3.fromRGB(0, 200, 50), lifetime = 0.55, width0 = 1.5, width1 = 0.2, transparency = 0.12 },
 neon_gold = { color1 = Color3.fromRGB(255, 215, 0), color2 = Color3.fromRGB(200, 150, 0), lifetime = 0.75, width0 = 1.4, width1 = 0.18, transparency = 0.22 },
 neon_red = { color1 = Color3.fromRGB(255, 0, 0), color2 = Color3.fromRGB(200, 0, 50), lifetime = 0.7, width0 = 1.3, width1 = 0.15, transparency = 0.2 },
 rainbow = { color1 = Color3.fromRGB(255, 0, 0), color2 = Color3.fromRGB(0, 0, 255), lifetime = 1.0, width0 = 1.5, width1 = 0.2, transparency = 0.15 },
 plasma = { color1 = Color3.fromRGB(100, 200, 255), color2 = Color3.fromRGB(255, 0, 150), lifetime = 0.85, width0 = 1.7, width1 = 0.25, transparency = 0.1 },
}

CustomTrail = {
 enabled = false, preset = "neon_cyan",
 color1 = Color3.fromRGB(0, 255, 255), color2 = Color3.fromRGB(255, 0, 255),
 lifetime = 0.5, width0 = 1.2, width1 = 0.1, transparency = 0.2,
 texture = "rbxassetid://188006888",
 trailObj = nil, att0 = nil, att1 = nil,
}

function CustomTrail.remove()
 for _, ref in ipairs({ "trailObj", "att0", "att1" }) do
 local o = CustomTrail[ref]
 if o then pcall(function() o:Destroy() end) end
 CustomTrail[ref] = nil
 end
 local rig = RigTarget.get()
 if rig then
 for _, d in ipairs(rig:GetDescendants()) do
 if d.Name == "FW_CustomTrail" or d.Name == "FW_TrailAtt0" or d.Name == "FW_TrailAtt1" then
 pcall(function() d:Destroy() end)
 end
 end
 end
end

function CustomTrail.apply()
 CustomTrail.remove()
 if not CustomTrail.enabled then return false, "трейл выключен" end
 local rig = RigTarget.get()
 if not rig then return false, "нет рига" end
 local root = RigTarget.findPart(rig, "Torso")
 if not root then return false, "нет Torso" end

 local att0 = Instance.new("Attachment") att0.Name = "FW_TrailAtt0" att0.Position = Vector3.new(0, 1.2, 0) att0.Parent = root
 local att1 = Instance.new("Attachment") att1.Name = "FW_TrailAtt1" att1.Position = Vector3.new(0, -1.2, 0) att1.Parent = root

 local trail = Instance.new("Trail")
 trail.Name = "FW_CustomTrail"
 trail.Attachment0, trail.Attachment1 = att0, att1
 trail.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, CustomTrail.color1), ColorSequenceKeypoint.new(1, CustomTrail.color2) })
 trail.Transparency = NumberSequence.new(CustomTrail.transparency)
 trail.Lifetime = CustomTrail.lifetime
 trail.MinLength = 0.1
 trail.MaxLength = 500
 trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, CustomTrail.width0), NumberSequenceKeypoint.new(1, CustomTrail.width1) })
 trail.FaceCamera = true
 if CustomTrail.texture and CustomTrail.texture ~= "" then
 trail.Texture = CustomTrail.texture
 trail.TextureMode = Enum.TextureMode.Wrap
 trail.TextureLength = 2
 end
 trail.Parent = root

 CustomTrail.trailObj, CustomTrail.att0, CustomTrail.att1 = trail, att0, att1
 return true
end

function CustomTrail.applyPreset(presetName)
 local p = TRAIL_PRESETS[presetName]
 if not p then return false end
 CustomTrail.preset = presetName
 CustomTrail.color1, CustomTrail.color2 = p.color1, p.color2
 CustomTrail.lifetime, CustomTrail.width0, CustomTrail.width1 = p.lifetime, p.width0, p.width1
 CustomTrail.transparency = p.transparency
 if CustomTrail.enabled then CustomTrail.apply() end
 return true
end




AuraDB.build()
local AURA_LIST = AuraDB.list
local AURA_VALUES = (#AURA_LIST > 0) and AURA_LIST or { "<каталог пуст>" }

local FxStatusLabel, FxLayerLabels = nil, {}

local function fxNotify(text, time)
 pcall(function() Library:Notify({ Title = "Effects", Description = tostring(text), Time = time or 4 }) end)
end

local function fxUpdateStatus()
 if FxStatusLabel then pcall(function() FxStatusLabel:SetText(Effects.getStatus()) end) end
end


;(function()
 local Motion = {
  trail = { enabled = false, aura = AURA_LIST[1] or "", size = 1, density = 1, lifetime = 0.8 },
  jump = { enabled = false, aura = AURA_LIST[1] or "", mode = "Circles", size = 1, count = 20,
   color = Color3.fromRGB(0, 200, 255) },
  attachments = {}, bursts = {}, templates = {}, dead = false,
 }
 Effects.motion = Motion

 Motion.trails = { Motion.trail }
 for i = 1, 3 do
  local t = Motion.trails[i] or { enabled = false, aura = AURA_LIST[1] or "", size = 1, density = 1, lifetime = 0.8 }
  t.attachments, t.delay, t.elapsed, t.useTrail = {}, 0, 0, false
  t.id = i == 1 and "FxAuraTrail" or ("FxAuraTrailL" .. i)
  Motion.trails[i] = t
 end
 Motion.attachments = Motion.trail.attachments

 function Motion.collect(name, useTrail)
  local payload, err = AuraDB.getPayload(name)
  if not payload then return nil, err end
  local found, seen = {}, {}
  local function add(inst)
   if inst:IsA(useTrail and "Trail" or "ParticleEmitter") and not seen[inst] and #found < 32
    and (not useTrail or (inst.Attachment0 and inst.Attachment1)) then
    seen[inst] = true
    table.insert(found, inst)
   end
  end
  for _, group in ipairs(payload.groups) do
   for _, src in ipairs(group.fx) do
    add(src)
    for _, d in ipairs(src:GetDescendants()) do add(d) end
   end
  end
  if #found == 0 then return nil, useTrail and "У выбранной ауры нет встроенного Trail" or "У выбранной ауры нет ParticleEmitter" end
  return found
 end

 function Motion.clearTrail(layer)
  if not layer then
   for _, t in ipairs(Motion.trails) do Motion.clearTrail(t) end
   return
  end
  for _, att in ipairs(layer.attachments) do att:Destroy() end
  table.clear(layer.attachments)
  layer.root, layer.elapsed = nil, 0
  if layer == Motion.trail then Motion.root = nil end
 end
 function Motion.clearJumps()
  for _, rec in ipairs(Motion.bursts) do rec.part:Destroy() end
  table.clear(Motion.bursts)
 end

 local function cloneEmitter(src, parent, size)
  local e = src:Clone()

  for _, child in ipairs(e:GetChildren()) do child:Destroy() end
  e.Enabled = false
  e.LockedToPart = false
  e.Size = scaleNumberSeq(src.Size, size)
  e.Parent = parent
  return e
 end

 function Motion.buildTrail(root, layer)
  layer = layer or Motion.trail
  Motion.clearTrail(layer)
  if not root then return false, "Нет рига" end
  local templates, err = Motion.collect(layer.aura, layer.useTrail)
  if not templates then return false, err end
  local att = Instance.new("Attachment")
  att.Name = "FW_AuraTrail"
  att.Position = Vector3.new(0, -1, 0)
  att.Parent = root
  table.insert(layer.attachments, att)
  for _, src in ipairs(templates) do
   if layer.useTrail then
    if src.Attachment0 and src.Attachment1 then
     local endpoints = {}
     for i, original in ipairs({ src.Attachment0, src.Attachment1 }) do
      local a = Instance.new("Attachment")
      a.Name = "FW_AuraTrailEndpoint"
      a.Position = original.Position * layer.size
      a.Parent = root
      table.insert(layer.attachments, a)
      endpoints[i] = a
     end
     local trail = src:Clone()
     for _, child in ipairs(trail:GetChildren()) do child:Destroy() end
     trail.Attachment0, trail.Attachment1 = endpoints[1], endpoints[2]
     trail.WidthScale = scaleNumberSeq(src.WidthScale, layer.size)
     trail.Lifetime, trail.Enabled = layer.lifetime, false
     trail.Parent = att
    end
   else
    local e = cloneEmitter(src, att, layer.size)
    e.Lifetime = NumberRange.new(layer.lifetime)
    e.Rate = math.clamp(src.Rate * layer.density, 1, 150)
   end
  end
  layer.root = root
  if layer == Motion.trail then Motion.root = root end
  return true
 end

 function Motion.setTrail(state, layer)
  layer = layer or Motion.trail
  layer.enabled = state
  Motion.clearTrail(layer)
  if state then
   local templates, err = Motion.collect(layer.aura, layer.useTrail)
   if not templates then
    layer.enabled = false
    fxNotify(err)
    if Toggles[layer.id .. "On"] then Toggles[layer.id .. "On"]:SetValue(false) end
   end
  end
 end

 function Motion.prepareJump()
  Motion.templates = {}
  if Motion.jump.mode ~= "Aura Particles" then return true end
  local templates, err = Motion.collect(Motion.jump.aura)
  if not templates then return false, err end
  Motion.templates = templates
  return true
 end

 function Motion.setJump(state)
  Motion.jump.enabled = state
  Motion.clearJumps()
  if state then
   local ok, err = Motion.prepareJump()
   if not ok then
    Motion.jump.enabled = false
    fxNotify(err)
    if Toggles.FxJumpOn then Toggles.FxJumpOn:SetValue(false) end
   end
  end
 end

 function Motion.emitJump(root, humanoid, rig)

  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  local exclude = { rig }
  if LocalPlayer.Character then table.insert(exclude, LocalPlayer.Character) end
  for _, rec in ipairs(Motion.bursts) do table.insert(exclude, rec.part) end
  params.FilterDescendantsInstances = exclude
  local distance = humanoid.HipHeight + root.Size.Y * 0.5 + 1
  local hit = workspace:Raycast(root.Position, Vector3.new(0, -distance - 3, 0), params)
  local position = hit and hit.Position or (root.Position - Vector3.new(0, distance, 0))
  local part = Instance.new("Part")
  part.Name = "FW_JumpEffect"
  part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
  part.Transparency = 1
  part.Size = Vector3.new(1, 1, 1)
  part.Position = position + Vector3.new(0, 0.05, 0)
  part.Parent = workspace
  local life = 0.7
  if Motion.jump.mode == "Circles" then
   local gui = Instance.new("SurfaceGui")
   gui.Face = Enum.NormalId.Top
   gui.CanvasSize = Vector2.new(256, 256)
   gui.Parent = part
   local circle = Instance.new("Frame")
   circle.Size = UDim2.fromScale(1, 1)
   circle.BackgroundTransparency = 1
   circle.Parent = gui
   local corner = Instance.new("UICorner")
   corner.CornerRadius = UDim.new(0.5, 0)
   corner.Parent = circle
   local stroke = Instance.new("UIStroke")
   stroke.Thickness = 6
   stroke.Color = Motion.jump.color
   stroke.Parent = circle
   table.insert(Motion.bursts, { part = part, age = 0, life = life, stroke = stroke, size = Motion.jump.size })
  else
   for _, src in ipairs(Motion.templates) do
    if src.Parent then
     local e = cloneEmitter(src, part, Motion.jump.size)

     e.Lifetime = NumberRange.new(math.min(src.Lifetime.Min, 3), math.min(src.Lifetime.Max, 3))
     e:Emit(Motion.jump.count)
     life = math.max(life, e.Lifetime.Max + 0.1)
    end
   end
   table.insert(Motion.bursts, { part = part, age = 0, life = life })
  end
  while #Motion.bursts > 12 do
   table.remove(Motion.bursts, 1).part:Destroy()
  end
 end

 local heartbeat = RunService.Heartbeat:Connect(function(dt)
  if Motion.dead then return end
  for i = #Motion.bursts, 1, -1 do
   local rec = Motion.bursts[i]
   rec.age = rec.age + dt
   if rec.age >= rec.life then
    rec.part:Destroy()
    table.remove(Motion.bursts, i)
   elseif rec.stroke then
    local t = rec.age / rec.life
    local diameter = (1 + t * 7) * rec.size
    rec.part.Size = Vector3.new(diameter, 0.05, diameter)
    rec.stroke.Transparency = t
   end
  end
  local rig = RigTarget.get()
  local root = rig and RigTarget.findPart(rig, "HumanoidRootPart")
  local char = LocalPlayer.Character
  local hum = char and char:FindFirstChildOfClass("Humanoid")
  hum = hum or (rig and rig:FindFirstChildOfClass("Humanoid"))
  if Motion.character ~= char or Motion.rig ~= rig then
   Motion.clearTrail()
   Motion.wasJumping = false
   Motion.character, Motion.rig = char, rig
  end
  for _, layer in ipairs(Motion.trails) do
   if layer.enabled and root then
    if layer.root ~= root then
     local ok, err = Motion.buildTrail(root, layer)
     if not ok then
      Motion.setTrail(false, layer)
      fxNotify(err)
      if Toggles[layer.id .. "On"] then Toggles[layer.id .. "On"]:SetValue(false) end
     end
    end
    local velocity = root.AssemblyLinearVelocity
    local moving = Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.5
    layer.elapsed = moving and (layer.elapsed + dt) or 0
    local emit = moving and layer.delay > 0 and layer.elapsed >= layer.delay
    if emit then layer.elapsed = layer.elapsed % layer.delay end
    for _, att in ipairs(layer.attachments) do
     for _, e in ipairs(att:GetChildren()) do
      e.Enabled = moving and (layer.useTrail or layer.delay == 0)
      if emit and e:IsA("ParticleEmitter") then
       e:Emit(math.clamp(math.floor(e.Rate * layer.delay + 0.5), 1, 50))
      end
     end
    end
   elseif layer.root then Motion.clearTrail(layer) end
  end
  local jumping = hum and hum.Health > 0 and hum:GetState() == Enum.HumanoidStateType.Jumping
  if Motion.jump.enabled and jumping and not Motion.wasJumping and root then
   Motion.emitJump(root, hum, rig)
  end
  Motion.wasJumping = jumping
 end)
 Library:OnUnload(function()
  Motion.dead = true
  heartbeat:Disconnect()
  Motion.clearTrail()
  Motion.clearJumps()
 end)

 function Motion.addTrailControls(g, layer)
  local id = layer.id
  local function update(key, value)
   layer[key] = value
   Motion.clearTrail(layer)
  end
  g:AddDropdown(id .. "Aura", { Values = AURA_VALUES, Default = 1, Searchable = true,
   Text = "Trail Aura", Callback = function(v) update("aura", tostring(v)) end })
  g:AddToggle(id .. "On", { Text = "Enable Aura Trail", Default = false,
   Callback = function(v) Motion.setTrail(v, layer) end })
  g:AddToggle(id .. "UseTrail", { Text = "Use Aura Trail (not particles)", Default = false,
   Callback = function(v) update("useTrail", v) if layer.enabled then Motion.setTrail(true, layer) end end })
  g:AddSlider(id .. "Size", { Text = "Size / Width", Min = 0.1, Max = 5, Default = 1, Rounding = 1,
   Callback = function(v) update("size", v) end })
  g:AddSlider(id .. "Density", { Text = "Particle Density", Min = 0.1, Max = 3, Default = 1, Rounding = 1,
   Callback = function(v) update("density", v) end })
  g:AddSlider(id .. "Life", { Text = "Trail Lifetime", Min = 0.1, Max = 3, Default = 0.8, Rounding = 1,
   Callback = function(v) update("lifetime", v) end })
  g:AddSlider(id .. "Delay", { Text = "Particle Spawn Delay", Min = 0, Max = 2, Default = 0, Rounding = 2, Suffix = "s",
   Callback = function(v) update("delay", v) end })
  g:AddLabel("Delay 0 = continuous particles.\nDelay / density apply only to particles.", true)
 end
 Motion.addTrailControls(Tabs.Effects:AddLeftGroupbox("Auras Trails"), Motion.trail)
 local j = Tabs.Effects:AddRightGroupbox("Jump Effects")
 j:AddDropdown("FxJumpMode", { Values = { "Circles", "Aura Particles" }, Default = 1, Text = "Jump Mode",
  Callback = function(v) Motion.jump.mode = v if Motion.jump.enabled then Motion.setJump(true) end end })
 j:AddDropdown("FxJumpAura", { Values = AURA_VALUES, Default = 1, Searchable = true, Text = "Jump Aura",
  Callback = function(v) Motion.jump.aura = tostring(v) if Motion.jump.enabled then Motion.setJump(true) end end })
 j:AddToggle("FxJumpOn", { Text = "Enable Jump Effects", Default = false, Callback = Motion.setJump })
 j:AddSlider("FxJumpSize", { Text = "Jump Effect Size", Min = 0.1, Max = 5, Default = 1, Rounding = 1,
  Callback = function(v) Motion.jump.size = v end })
 j:AddSlider("FxJumpCount", { Text = "Particles per Emitter", Min = 1, Max = 50, Default = 20, Rounding = 0,
  Callback = function(v) Motion.jump.count = v end })
 j:AddLabel("Circle Color"):AddColorPicker("FxJumpColor", { Default = Motion.jump.color,
  Title = "Circle Color", Callback = function(v) Motion.jump.color = v end })
end)()


local AuraInventory = { items = {}, maxSlots = 20, gui = nil, isOpen = false }


function AuraInventory.restoreNative()
    if AuraInventory.watch then AuraInventory.watch:Disconnect() AuraInventory.watch = nil end
    for inst, enabled in pairs(AuraInventory.hidden or {}) do
        if inst.Parent then pcall(function() inst.Enabled = enabled end) end
    end
    AuraInventory.hidden = {}
end

function AuraInventory.hideNative(inv)
    AuraInventory.restoreNative()
    local id = inv.GetEquipped("UnusualSlot")
    local name
    for n, info in pairs(AuraDB.byName) do if info.id == id then name = n break end end
    if not name then return end
    local payload = AuraDB.getPayload(name)
    local rig = RigTarget.get()
    if not payload or not rig then return end
    local names = {}
    for _, group in ipairs(payload.groups) do
        for _, fx in ipairs(group.fx) do
            names[fx.Name] = true
            for _, d in ipairs(fx:GetDescendants()) do names[d.Name] = true end
        end
    end
    local function hide(inst)
        if not (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
            or inst:IsA("Light") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")) then return end
        local node, matches = inst, false
        while node and node ~= rig do
            if node.Name:sub(1, 3) == "FW_" then return end
            if names[node.Name] then matches = true end
            node = node.Parent
        end
        if matches and AuraInventory.hidden[inst] == nil then
            AuraInventory.hidden[inst] = inst.Enabled
            inst.Enabled = false
            if inst:IsA("ParticleEmitter") or inst:IsA("Trail") then inst:Clear() end
        end
    end
    for _, inst in ipairs(rig:GetDescendants()) do hide(inst) end
    AuraInventory.watch = rig.DescendantAdded:Connect(hide)
end

function AuraInventory.clearSelection()
    if AuraInventory.selected then
        Effects.clearLayer(Effects.MAIN)
        Effects.getLayer(Effects.MAIN).enabled = false
    end
    AuraInventory.selected = nil
    AuraInventory.restoreNative()
end


function AuraInventory.install()
    if AuraInventory.native then return true end
    local ok, err = pcall(function()
        local inv = require(FX_RS.Client.Services.UserData.Inventory)
        local originals = { GetOwnedBySlotType = inv.GetOwnedBySlotType, Equip = inv.Equip, Unequip = inv.Unequip }
        local wrappers = {}
        wrappers.GetOwnedBySlotType = function(slotType)
            local result = originals.GetOwnedBySlotType(slotType)
            if slotType ~= "Unusual" then return result end
            local list, seen = {}, {}
            for _, id in ipairs(result) do list[#list + 1] = id seen[id] = true end
            for _, item in ipairs(AuraInventory.items) do
                if item.id and not seen[item.id] then
                    list[#list + 1] = item.id seen[item.id] = true
                end
            end
            return list
        end
        wrappers.Equip = function(slot, id)
            if slot == "UnusualSlot" then
                for _, item in ipairs(AuraInventory.items) do
                    if item.id == id then
                        local applied, message = Effects.applyLayer(Effects.MAIN, item.name)
                        if applied then
                            AuraInventory.selected = item.name
                            AuraInventory.hideNative(inv)
                        else fxNotify(tostring(message), 4) end
                        return
                    end
                end
            end
            if slot == "UnusualSlot" then AuraInventory.clearSelection() end
            return originals.Equip(slot, id)
        end
        wrappers.Unequip = function(slot)
            if slot == "UnusualSlot" then AuraInventory.clearSelection() end
            return originals.Unequip(slot)
        end
        if type(setreadonly) ~= "function" then error("Executor needs setreadonly") end
        setreadonly(inv, false)
        for key, fn in pairs(wrappers) do inv[key] = fn end
        setreadonly(inv, true)
        AuraInventory.native = { api = inv, originals = originals, wrappers = wrappers }
    end)
    return ok, err
end

function AuraInventory.uninstall()
    AuraInventory.clearSelection()
    local native = AuraInventory.native
    if not native then return end
    setreadonly(native.api, false)
    for key, fn in pairs(native.wrappers) do
        if native.api[key] == fn then native.api[key] = native.originals[key] end
    end
    setreadonly(native.api, true)
    AuraInventory.native = nil
end

function AuraInventory.add(n)
    if not n or n == "" then return end
    for _, it in ipairs(AuraInventory.items) do
        if it.name == n then return end
    end
    local info = AuraDB.byName[n]
    if not info or type(info.id) ~= "number" then
        fxNotify("Aura has no registered Unusual item ID", 4) return
    end
    if #AuraInventory.items >= AuraInventory.maxSlots then
        fxNotify("Local inventory full", 3) return
    end
    local ready, err = AuraInventory.install()
    if not ready then fxNotify("Local inventory unavailable: " .. tostring(err), 5) return end
    table.insert(AuraInventory.items, {name=n, id=info.id})
    if AuraInventory.isOpen then pcall(AuraInventory.refresh) end
end

Library:OnUnload(function()
    AuraInventory.uninstall()
    AuraInventory.close()
end)

function AuraInventory.remove(n)
    if AuraInventory.selected == n then AuraInventory.clearSelection() end
    for i, it in ipairs(AuraInventory.items) do
        if it.name == n then table.remove(AuraInventory.items, i)
            if AuraInventory.isOpen then pcall(AuraInventory.refresh) end return end
    end
end

function AuraInventory.refresh()
    if not AuraInventory.gui or not AuraInventory.gui.Parent then return end
    local sf = AuraInventory.gui:FindFirstChild("InvSF", true) if not sf then return end
    for _, ch in pairs(sf:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    local slotH = 52
    sf.CanvasSize = UDim2.new(0,0,0,#AuraInventory.items*(slotH+6)+8)
    for idx, item in ipairs(AuraInventory.items) do
        local cname = item.name
        local slot = Instance.new("Frame")
        slot.Size = UDim2.new(1,-10,0,slotH) slot.Position = UDim2.new(0,5,0,(idx-1)*(slotH+6)+6)
        slot.BackgroundColor3 = Color3.fromRGB(20,26,40) slot.BorderSizePixel = 0 slot.Parent = sf
        local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,8) sc.Parent = slot
        local nl = Instance.new("TextLabel")
        nl.Text = idx..". "..cname nl.Font = Enum.Font.GothamSemibold nl.TextSize = 12
        nl.TextColor3 = Color3.fromRGB(220,235,255) nl.BackgroundTransparency = 1
        nl.Size = UDim2.new(1,-152,1,0) nl.Position = UDim2.new(0,8,0,0)
        nl.TextXAlignment = Enum.TextXAlignment.Left nl.TextTruncate = Enum.TextTruncate.AtEnd nl.Parent = slot
        local eb = Instance.new("TextButton")
        eb.Text = "Equip" eb.Font = Enum.Font.GothamBold eb.TextSize = 11
        eb.TextColor3 = Color3.fromRGB(255,255,255) eb.BackgroundColor3 = Color3.fromRGB(35,110,210)
        eb.BorderSizePixel = 0 eb.Size = UDim2.new(0,72,0,32) eb.Position = UDim2.new(1,-152,0.5,-16) eb.Parent = slot
        local ebc = Instance.new("UICorner") ebc.CornerRadius = UDim.new(0,6) ebc.Parent = eb
        eb.MouseButton1Click:Connect(function()
            Effects.getLayer(Effects.MAIN).auraName = cname
            pcall(function() Effects.applyLayer(Effects.MAIN, cname) end)
            pcall(function() Library:Notify({Title="Equipped",Description=cname,Time=3}) end)
        end)
        local rb = Instance.new("TextButton")
        rb.Text = "X" rb.Font = Enum.Font.GothamBold rb.TextSize = 13
        rb.TextColor3 = Color3.fromRGB(255,90,90) rb.BackgroundColor3 = Color3.fromRGB(40,18,18)
        rb.BorderSizePixel = 0 rb.Size = UDim2.new(0,34,0,32) rb.Position = UDim2.new(1,-66,0.5,-16) rb.Parent = slot
        local rbc = Instance.new("UICorner") rbc.CornerRadius = UDim.new(0,6) rbc.Parent = rb
        rb.MouseButton1Click:Connect(function() AuraInventory.remove(cname) end)
    end
    if #AuraInventory.items == 0 then
        local el = Instance.new("TextLabel")
        el.Text = "Inventory empty. Right-click an aura in dropdown to add."
        el.Font = Enum.Font.Gotham el.TextSize = 12 el.TextColor3 = Color3.fromRGB(140,155,175)
        el.BackgroundTransparency = 1 el.Size = UDim2.new(1,0,0,80) el.Position = UDim2.new(0,0,0,10)
        el.TextWrapped = true el.Parent = sf
    end
end

function AuraInventory.open()
    if AuraInventory.isOpen and AuraInventory.gui and AuraInventory.gui.Parent then AuraInventory.close() return end
    AuraInventory.close()
    local W, H = 430, 490
    local sg = Instance.new("ScreenGui")
    sg.Name = "AuraInventoryGui" sg.IgnoreGuiInset = true sg.DisplayOrder = 99998
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
    AuraInventory.gui = sg AuraInventory.isOpen = true
    local ov = Instance.new("TextButton") ov.Size = UDim2.new(1,0,1,0) ov.BackgroundColor3 = Color3.new(0,0,0)
    ov.BackgroundTransparency = 0.55 ov.BorderSizePixel = 0 ov.Text = "" ov.AutoButtonColor = false ov.ZIndex = 49 ov.Parent = sg
    local bg = Instance.new("Frame") bg.Name = "InvBG" bg.Size = UDim2.new(0,W,0,0)
    bg.Position = UDim2.new(0.5,-W/2,0.5,-H/2) bg.BackgroundColor3 = Color3.fromRGB(10,12,22)
    bg.BorderSizePixel = 0 bg.ZIndex = 50 bg.ClipsDescendants = true bg.Parent = sg
    local bgc = Instance.new("UICorner") bgc.CornerRadius = UDim.new(0,14) bgc.Parent = bg
    local bgs = Instance.new("UIStroke") bgs.Color = Color3.fromRGB(60,140,255) bgs.Thickness = 2 bgs.Transparency = 0.2 bgs.Parent = bg
    TweenService:Create(bg,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,W,0,H)}):Play()
    local hdr = Instance.new("Frame") hdr.Size = UDim2.new(1,0,0,50) hdr.BackgroundColor3 = Color3.fromRGB(16,22,40)
    hdr.BorderSizePixel = 0 hdr.ZIndex = 51 hdr.Parent = bg
    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0,14) hc.Parent = hdr
    local tl = Instance.new("TextLabel") tl.Text = "Aura Inventory ("..#AuraInventory.items.."/"..AuraInventory.maxSlots..")"
    tl.Font = Enum.Font.GothamBold tl.TextSize = 15 tl.TextColor3 = Color3.fromRGB(90,200,255)
    tl.BackgroundTransparency = 1 tl.Size = UDim2.new(1,-60,1,0) tl.Position = UDim2.new(0,14,0,0)
    tl.TextXAlignment = Enum.TextXAlignment.Left tl.ZIndex = 52 tl.Parent = hdr
    local xb = Instance.new("TextButton") xb.Text = "X" xb.Font = Enum.Font.GothamBold xb.TextSize = 17
    xb.TextColor3 = Color3.fromRGB(255,90,90) xb.BackgroundColor3 = Color3.fromRGB(35,18,18)
    xb.BorderSizePixel = 0 xb.Size = UDim2.new(0,38,0,38) xb.Position = UDim2.new(1,-44,0,6) xb.ZIndex = 52 xb.Parent = hdr
    local xbc = Instance.new("UICorner") xbc.CornerRadius = UDim.new(0,8) xbc.Parent = xb
    xb.MouseButton1Click:Connect(function() AuraInventory.close() end)
    ov.MouseButton1Click:Connect(function() AuraInventory.close() end)
    local hint = Instance.new("TextLabel") hint.Text = "RMB on any aura in dropdown = add to inventory | Equip = apply to main slot"
    hint.Font = Enum.Font.Gotham hint.TextSize = 10 hint.TextColor3 = Color3.fromRGB(120,150,190)
    hint.BackgroundColor3 = Color3.fromRGB(14,20,36) hint.BorderSizePixel = 0
    hint.Size = UDim2.new(1,0,0,26) hint.Position = UDim2.new(0,0,0,50) hint.ZIndex = 51 hint.Parent = bg
    local sf = Instance.new("ScrollingFrame") sf.Name = "InvSF"
    sf.Size = UDim2.new(1,0,1,-118) sf.Position = UDim2.new(0,0,0,78)
    sf.BackgroundTransparency = 1 sf.BorderSizePixel = 0 sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.ScrollBarThickness = 4 sf.ScrollBarImageColor3 = Color3.fromRGB(60,140,255)
    sf.ScrollBarImageTransparency = 0.3 sf.ZIndex = 50 sf.Parent = bg
    local foot = Instance.new("Frame") foot.Size = UDim2.new(1,0,0,40) foot.Position = UDim2.new(0,0,1,-40)
    foot.BackgroundColor3 = Color3.fromRGB(14,18,32) foot.BorderSizePixel = 0 foot.ZIndex = 51 foot.Parent = bg
    local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = foot
    local cb = Instance.new("TextButton") cb.Text = "Clear All" cb.Font = Enum.Font.GothamBold cb.TextSize = 12
    cb.TextColor3 = Color3.fromRGB(255,130,130) cb.BackgroundColor3 = Color3.fromRGB(35,18,18)
    cb.BorderSizePixel = 0 cb.Size = UDim2.new(0,110,0,28) cb.Position = UDim2.new(0,10,0.5,-14) cb.ZIndex = 52 cb.Parent = foot
    local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0,6) cbc.Parent = cb
    cb.MouseButton1Click:Connect(function()
        AuraInventory.clearSelection() table.clear(AuraInventory.items) AuraInventory.refresh()
        pcall(function() Library:Notify({Title="Aura Inventory",Description="Cleared!",Time=2}) end)
    end)
    local escConn escConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.Escape then AuraInventory.close() if escConn then escConn:Disconnect() end end
    end)
    AuraInventory.refresh()
end

function AuraInventory.close()
    if AuraInventory.gui then pcall(function() AuraInventory.gui:Destroy() end) AuraInventory.gui = nil end
    AuraInventory.isOpen = false
end




do
 local g = Tabs.Effects:AddLeftGroupbox("Evade Auras (" .. AuraDB.count .. " from Registry)")

 local auraDropdown = g:AddDropdown("FxMainAura", {
 Values = AURA_VALUES, Default = 1, Multi = false, Searchable = true,
 Text = "Aura", Tooltip = "All auras with Unusual slot, read from ReplicatedStorage.Items.Registry",
 Callback = function(v)
    Effects.getLayer(Effects.MAIN).auraName = tostring(v)
 end,
 })
 g:AddButton({ Text = "Add Selected to UNUSUAL (local)", Func = function()
     AuraInventory.add(Effects.getLayer(Effects.MAIN).auraName)
 end })

 if auraDropdown.DropdownFrame then
     for _, btn in pairs(auraDropdown.DropdownFrame:GetChildren()) do
         if btn:IsA("TextButton") and btn.Name == "Option" then
             local auraName = btn.Text
             btn.MouseButton2Click:Connect(function() AuraInventory.add(auraName) end)
         end
     end
 end
 g:AddDropdown("FxMainPart", {
 Values = FX_BODY_PARTS, Default = 1, Multi = false,
 Text = "Body Part", Tooltip = "Auto = as intended by aura author",
 Callback = function(v)
 Effects.getLayer(Effects.MAIN).part = tostring(v)
 end,
 })
 g:AddButton({
 Text = "Apply Aura",
 Func = function()
 local l = Effects.getLayer(Effects.MAIN)
 if l.auraName == "" and Options.FxMainAura then l.auraName = tostring(Options.FxMainAura.Value) end
 local ok, msg = Effects.applyLayer(Effects.MAIN, l.auraName)
 fxNotify(ok and (" " .. msg) or (" " .. tostring(msg)), ok and 4 or 6)
 fxUpdateStatus()
 end,
 })
 g:AddButton({
 Text = "Remove Aura",
 Func = function()
 Effects.clearLayer(Effects.MAIN)
 Effects.getLayer(Effects.MAIN).enabled = false
 fxUpdateStatus()
 fxNotify("Main aura removed", 2)
 end,
 })
 g:AddDivider()
 g:AddSlider("FxMainScale", {
 Text = "Size", Min = 0.1, Max = 8, Default = 1, Rounding = 2, Suffix = "x",
 Callback = function(v) Effects.getLayer(Effects.MAIN).scale = v Effects.refreshLayer(Effects.MAIN) end,
 })
 g:AddSlider("FxMainRate", {
 Text = "Particle Density", Min = 0, Max = 5, Default = 1, Rounding = 2, Suffix = "x",
 Callback = function(v) Effects.getLayer(Effects.MAIN).rate = v Effects.refreshLayer(Effects.MAIN) end,
 })
 g:AddSlider("FxMainTransp", {
 Text = "Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2,
 Callback = function(v) Effects.getLayer(Effects.MAIN).transparency = v Effects.refreshLayer(Effects.MAIN) end,
 })
 g:AddSlider("FxMainOffsetY", {
 Text = "Height Offset", Min = -5, Max = 5, Default = 0, Rounding = 2,
 Callback = function(v) Effects.getLayer(Effects.MAIN).offsetY = v Effects.refreshLayer(Effects.MAIN) end,
 })
 g:AddToggle("FxMainColorOn", {
 Text = "Recolor Aura", Default = false,
 Tooltip = "Off = original aura author colors",
 Callback = function(s) Effects.getLayer(Effects.MAIN).useColor = s Effects.refreshLayer(Effects.MAIN) end,
 }):AddColorPicker("FxMainColor", {
 Default = Color3.fromRGB(0, 170, 255), Title = "Aura Color",
 Callback = function(c) Effects.getLayer(Effects.MAIN).color = c Effects.refreshLayer(Effects.MAIN) end,
 })
 g:AddDivider()
 g:AddToggle("FxAutoReapply", {
 Text = "Reapply after respawn", Default = true,
 Callback = function(s)
 Effects.autoReapply = s
 Effects._settings.autoReapplyOnRespawn = s
 end,
 })
 FxStatusLabel = g:AddLabel(Effects.getStatus(), true)
end


do
 local g = Tabs.Effects:AddRightGroupbox("Aura Layering (" .. Effects.LAYER_COUNT .. " layers)")
 g:AddLabel("Layers are independent: you can wear\nmultiple auras at once,\neach with its own color and size.", true)
 g:AddDivider()

 for i = 1, Effects.LAYER_COUNT do
 g:AddDropdown("FxL" .. i .. "_Aura", {
 Values = AURA_VALUES, Default = 1, Multi = false, Searchable = true,
 Text = "Layer " .. i .. " - Aura",
 Tooltip = "Choose an aura from the full catalogue",
 Callback = function(v)
 local l = Effects.getLayer(i)
 l.auraName = tostring(v)
 local res = AuraDB.resolve(v)
 if l.enabled then
 local ok, err = Effects.applyLayer(i, l.auraName)
 if not ok then fxNotify(err) end
 fxUpdateStatus()
 end
 if FxLayerLabels[i] then
 pcall(function()
 FxLayerLabels[i]:SetText(res and ("→ " .. res) or (v ~= "" and "→ not found" or "→ empty"))
 end)
 end
 end,
 })
 FxLayerLabels[i] = g:AddLabel("→ empty", true)
 g:AddDropdown("FxL" .. i .. "_Part", {
 Values = FX_BODY_PARTS, Default = 1, Multi = false, Text = "Layer " .. i .. " - Body Part",
 Callback = function(v) Effects.getLayer(i).part = tostring(v) end,
 })
 g:AddSlider("FxL" .. i .. "_Scale", {
 Text = "Layer " .. i .. " - Size", Min = 0.1, Max = 8, Default = 1, Rounding = 2, Suffix = "x",
 Callback = function(v) Effects.getLayer(i).scale = v Effects.refreshLayer(i) end,
 })
 g:AddSlider("FxL" .. i .. "_Rate", {
 Text = "Layer " .. i .. " - Particle Density", Min = 0, Max = 5, Default = 1, Rounding = 2, Suffix = "x",
 Callback = function(v) Effects.getLayer(i).rate = v Effects.refreshLayer(i) end,
 })
 g:AddToggle("FxL" .. i .. "_ColorOn", {
 Text = "Layer " .. i .. " - Custom Color", Default = false,
 Callback = function(s) Effects.getLayer(i).useColor = s Effects.refreshLayer(i) end,
 }):AddColorPicker("FxL" .. i .. "_Color", {
 Default = Color3.fromRGB(255, 255, 255), Title = "Layer " .. i .. " Color",
 Callback = function(c) Effects.getLayer(i).color = c Effects.refreshLayer(i) end,
 })
 g:AddToggle("FxL" .. i .. "_On", {
 Text = "Enable Layer " .. i, Default = false,
 Callback = function(state)
 local l = Effects.getLayer(i)
 if state then
 local ok, msg = Effects.applyLayer(i, l.auraName)
 if not ok then
 l.enabled = false
 pcall(function() Toggles["FxL" .. i .. "_On"]:SetValue(false) end)
 fxNotify("Layer " .. i .. ": " .. tostring(msg), 5)
 else
 fxNotify("Layer " .. i .. ": " .. msg, 3)
 end
 else
 Effects.clearLayer(i)
 l.enabled = false
 end
 fxUpdateStatus()
 end,
 })
 if i < Effects.LAYER_COUNT then g:AddDivider() end
 end

 g:AddDivider()
 g:AddButton({
 Text = " Reapply All Layers",
 Func = function()
 Effects.reapplyAll()
 fxUpdateStatus()
 fxNotify("Слои переприменены", 3)
 end,
 })
 g:AddButton({
 Text = " Clear All Layers",
 Func = function()
 Effects.clearAllLayers()
 for i = 1, Effects.LAYER_COUNT do
 pcall(function() Toggles["FxL" .. i .. "_On"]:SetValue(false) end)
 end
 fxUpdateStatus()
 fxNotify("Все слои очищены", 3)
 end,
 })
end


do
 local g = Tabs.Effects:AddLeftGroupbox(" Неоновый трейл")
 g:AddToggle("FxTrailOn", {
 Text = "Enable Trail", Default = false,
 Callback = function(state)
 CustomTrail.enabled = state
 if state then
 local ok, msg = CustomTrail.apply()
 if not ok then fxNotify("Трейл: " .. tostring(msg), 5) end
 else
 CustomTrail.remove()
 end
 end,
 })
 g:AddDropdown("FxTrailPreset", {
 Values = { "neon_cyan", "neon_purple", "neon_fire", "neon_ice", "neon_pink", "neon_green", "neon_gold", "neon_red", "rainbow", "plasma" },
 Default = 1, Multi = false, Text = "Preset",
 Callback = function(v)
 CustomTrail.applyPreset(tostring(v))
 pcall(function() Options.FxTrailColor1:SetValueRGB(CustomTrail.color1) end)
 pcall(function() Options.FxTrailColor2:SetValueRGB(CustomTrail.color2) end)
 end,
 })
 g:AddLabel("Start Color"):AddColorPicker("FxTrailColor1", {
 Default = Color3.fromRGB(0, 255, 255), Title = "Start Color",
 Callback = function(c) CustomTrail.color1 = c if CustomTrail.enabled then CustomTrail.apply() end end,
 })
 g:AddLabel("End Color"):AddColorPicker("FxTrailColor2", {
 Default = Color3.fromRGB(255, 0, 255), Title = "End Color",
 Callback = function(c) CustomTrail.color2 = c if CustomTrail.enabled then CustomTrail.apply() end end,
 })
 g:AddSlider("FxTrailLifetime", {
 Text = "Length (seconds)", Min = 0.1, Max = 3, Default = 0.5, Rounding = 2,
 Callback = function(v) CustomTrail.lifetime = v if CustomTrail.enabled then CustomTrail.apply() end end,
 })
 g:AddSlider("FxTrailWidth", {
 Text = "Width", Min = 0.1, Max = 6, Default = 1.2, Rounding = 2,
 Callback = function(v) CustomTrail.width0 = v if CustomTrail.enabled then CustomTrail.apply() end end,
 })
 g:AddSlider("FxTrailTransp", {
 Text = "Transparency", Min = 0, Max = 1, Default = 0.2, Rounding = 2,
 Callback = function(v) CustomTrail.transparency = v if CustomTrail.enabled then CustomTrail.apply() end end,
 })
end


do
 local g = Tabs.Effects:AddRightGroupbox(" Glow, подсветка, огонь")

 g:AddToggle("FxHighlightOn", {
 Text = "Highlight Self (Highlight)", Default = false,
 Callback = function(s) Effects.toggleHighlight(s) end,
 }):AddColorPicker("FxHighlightColor", {
 Default = Color3.fromRGB(0, 170, 255), Title = "Highlight Color",
 Callback = function(c)
 Effects.extra.highlight.color = c
 if Effects.extra.highlight.on then Effects.toggleHighlight(true) end
 end,
 })
 g:AddSlider("FxHighlightTransp", {
 Text = "Highlight Transparency", Min = 0, Max = 1, Default = 0.7, Rounding = 2,
 Callback = function(v)
 Effects.extra.highlight.transparency = v
 if Effects.extra.highlight.on then Effects.toggleHighlight(true) end
 end,
 })
 g:AddDivider()
 g:AddToggle("FxLightOn", {
 Text = "Glow (PointLight)", Default = false,
 Callback = function(s) Effects.togglePointLight(s) end,
 }):AddColorPicker("FxLightColor", {
 Default = Color3.fromRGB(0, 170, 255), Title = "Glow Color",
 Callback = function(c)
 Effects.extra.light.color = c
 if Effects.extra.light.on then Effects.togglePointLight(true) end
 end,
 })
 g:AddSlider("FxLightRange", {
 Text = "Glow Radius", Min = 2, Max = 60, Default = 14, Rounding = 0,
 Callback = function(v)
 Effects.extra.light.range = v
 if Effects.extra.light.on then Effects.togglePointLight(true) end
 end,
 })
 g:AddSlider("FxLightBrightness", {
 Text = "Glow Brightness", Min = 0, Max = 10, Default = 3, Rounding = 1,
 Callback = function(v)
 Effects.extra.light.brightness = v
 if Effects.extra.light.on then Effects.togglePointLight(true) end
 end,
 })
 g:AddDivider()
 g:AddToggle("FxFireOn", {
 Text = "Feet Fire", Default = false,
 Callback = function(s) Effects.toggleFire(s) end,
 }):AddColorPicker("FxFireColor", {
 Default = Color3.fromRGB(255, 100, 0), Title = "Fire Color",
 Callback = function(c)
 Effects.extra.fire.color = c
 if Effects.extra.fire.on then Effects.toggleFire(true) end
 end,
 })
 g:AddSlider("FxFireSize", {
 Text = "Fire Size", Min = 1, Max = 30, Default = 6, Rounding = 0,
 Callback = function(v)
 Effects.extra.fire.size = v
 if Effects.extra.fire.on then Effects.toggleFire(true) end
 end,
 })
end


do
 local g = Tabs.Effects:AddLeftGroupbox(" Кастомная аура (Asset ID)")
 g:AddInput("FxCustomID", {
 Default = "", Text = "Model Asset ID", Placeholder = "e.g. 1234567890", Numeric = true,
 Callback = function(v) Effects._customAuraID = tostring(v):gsub("%D", "") end,
 })
 g:AddSlider("FxCustomScale", {
 Text = "Size", Min = 0.1, Max = 10, Default = 1, Rounding = 2, Suffix = "x",
 Callback = function(v) Effects._customScale = v end,
 })
 g:AddSlider("FxCustomTransp", {
 Text = "Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2,
 Callback = function(v) Effects._customTransp = v end,
 })
 g:AddButton({
 Text = " Load and Wear",
 Func = function()
 local ok, msg = Effects.applyCustomAura(Effects._customAuraID, Effects._customScale or 1, Effects._customTransp or 0)
 fxNotify(ok and (" " .. msg) or (" " .. tostring(msg)), ok and 4 or 6)
 end,
 })
 g:AddButton({ Text = " Remove Custom", Func = function() Effects.clearCustomAura() fxNotify("Custom aura removed", 2) end })
end




do
 local function scheduleReapply(why)
 if not Effects.autoReapply then return end
 task.delay(0.75, function()
 local rig = RigTarget.get()
 if not rig then return end
 Effects.reapplyAll()
 if AuraInventory.selected and AuraInventory.native then AuraInventory.hideNative(AuraInventory.native.api) end
 if CustomTrail.enabled then pcall(CustomTrail.apply) end
 if Effects.extra.highlight.on then pcall(Effects.toggleHighlight, true) end
 if Effects.extra.light.on then pcall(Effects.togglePointLight, true) end
 if Effects.extra.fire.on then pcall(Effects.toggleFire, true) end
 fxUpdateStatus()
 end)
 end

 local rigs = workspace:FindFirstChild("Rigs")
 if rigs then
 rigs.ChildAdded:Connect(function(child)
 if child.Name == LocalPlayer.Name then scheduleReapply("rig") end
 end)
 else
 workspace.ChildAdded:Connect(function(c)
 if c.Name == "Rigs" then
 c.ChildAdded:Connect(function(child)
 if child.Name == LocalPlayer.Name then scheduleReapply("rig-late") end
 end)
 end
 end)
 end

 LocalPlayer.CharacterAdded:Connect(function() scheduleReapply("char") end)
end


Effects.motion.addTrailControls(Tabs.Effects:AddLeftGroupbox("Auras Trails - Layer 2"), Effects.motion.trails[2])
Effects.motion.addTrailControls(Tabs.Effects:AddRightGroupbox("Auras Trails - Layer 3"), Effects.motion.trails[3])


do
    local gInv = Tabs.Effects:AddLeftGroupbox("UNUSUAL Inventory Changer (local)")
    gInv:AddLabel("Add selected aura, then reopen the game's UNUSUAL picker. Local visuals only; no account unlock. Open Inventory manages your local entries.", true)
    gInv:AddButton({ Text = "Open Inventory", Func = function() AuraInventory.open() end })
    gInv:AddButton({ Text = "Clear Inventory", Func = function()
        AuraInventory.clearSelection() table.clear(AuraInventory.items)
        pcall(function() Library:Notify({Title="Aura Inventory",Description="Cleared!",Time=2}) end)
    end })
end
print(("[Aura System v4.0] cat: %d aurs (%s) | cen: workspace.Rigs.%s")
 :format(AuraDB.count, AuraDB.source, LocalPlayer.Name))

end)()


local currentSettings = { Speed = 1500, JumpPowerValue = 3.5, JumpCap = 1, AirStrafeAcceleration = 187 }
getgenv().bhopHoldSystemEnabled = false
getgenv().bhopHoldActive = false
getgenv().bhopMode = "Acceleration"
getgenv().bhopAccelValue = -0.5
local frictionTables = {}
local CurrentJumpCount = 0
local LastJump = 0
local maxJumpsValue = math.huge
local turnbindEnabled = false
local turnbindLeftKey = "A"
local turnbindRightKey = "D"
local autoBounceEnabled = false
local autoBounceKeybind = "B"
local bouncePowerMin, bouncePowerMax = 40, 60
local bounceDebounce = false
local bounceConnection = nil
local BounceBhop = { enabled = false, minAngle = 70, maxAngle = 90 }
local cosmetic1, cosmetic2 = "", ""
local isSwapped = false
local originalCosmetic1, originalCosmetic2 = "", ""
local headlessEnabled = false
local korbloxEnabled = false
local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"
local downDashEnabled = false
local downDashSpeed = 185
local downDashCurrentSpeed = 0
local downDashActive = false
local downDashPreActivated = false
local isDownedState = false
local downDashHasUsed = false
local edgeBoostSkipWords = {}
local HITBOX_SIZE = Vector3.new(5.0, 2.0, 5.0)
local HITBOX_TRANSPARERECY = 1
local HITBOX_COLOR = Color3.fromRGB(0, 255, 255)
local NO_FRICTION_PHYSICS = PhysicalProperties.new(0.7, 0, 1, 0, 1)
local customHitboxEnabled = false
local customHitboxWidth = 5
local customHitboxHeight = 5
local customHitboxLength = 5
local customHitboxColor = Color3.fromRGB(255, 0, 0)
local customHitboxTransparency = 0.5
local CustomHitboxFolder = Instance.new("Folder")
CustomHitboxFolder.Name = "Sperma_CustomHitboxes"
CustomHitboxFolder.Parent = workspace
local mapID = ""
local spawnedMap = nil
local globalColorValue = Color3.fromRGB(255, 255, 255)
local globalColorOriginals = {}
local globalColorApplied = false
local hideOthersEnabled = false
local hideSelfEnabled = false
local hideOthersConn = nil
local removeInvisWallsEnabled = false
local invisWallOriginals = {}
local edgeBoostEnabled = false
local edgeBoostPower = 100
local edgeBoostConn = nil
local edgeVMin = 1.0
local currentEmotes = {}
local selectEmotes = {}
local emoteEnabled = {}
for i = 1, 12 do
 currentEmotes[i] = ""
 selectEmotes[i] = ""
 emoteEnabled[i] = false
end

local Events = ReplicatedStorage:WaitForChild("Events", 10)
local CharacterFolder = Events and Events:WaitForChild("Character", 10)
local EmoteRemote = CharacterFolder and CharacterFolder:WaitForChild("Emote", 10)
local PassCharacterInfo = CharacterFolder and CharacterFolder:WaitForChild("PassCharacterInfo", 10)
local remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent
local currentTag = nil
local pendingSlot = nil
local blockOriginalEmote = false
local feOriginalEmotes = {}
for i = 1, 6 do feOriginalEmotes[i] = LocalPlayer:GetAttribute("Emote" .. i) or "" end
local feHookInstalled = false
local feBlockRemote = false
local fePendingEmotes = {}
local feValidEmotes = {}
local feEmoteInputs = {}
local feEmoteSpeedConn = nil
local feEmotingConn = nil
local feEmoteSpeedCache = {}
local feEmoteRunnerActive = false

local function feScanValidEmotes()
 local emotes = {}
 local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
 if itemsFolder then
 local emotesFolder = itemsFolder:FindFirstChild("Emotes")
 if emotesFolder then
 for _, item in pairs(emotesFolder:GetChildren()) do
 if item:IsA("ModuleScript") then emotes[item.Name] = true end
 end
 end
 end
 return emotes
end

feValidEmotes = feScanValidEmotes()
local function feIsValidEmote(name) return name and name ~= "" and feValidEmotes[name] == true end
local function feGetTagData() return LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Tag") end
local function feGetEmoteSpeedMult(emoteName)
 if not feIsValidEmote(emoteName) then return 1 end
 if feEmoteSpeedCache[emoteName] then return feEmoteSpeedCache[emoteName] end
 local itemsFolder = ReplicatedStorage:FindFirstChild("Items") if not itemsFolder then return 1 end
 local emotesFolder = itemsFolder:FindFirstChild("Emotes") if not emotesFolder then return 1 end
 local emoteModule = emotesFolder:FindFirstChild(emoteName) if not emoteModule or not emoteModule:IsA("ModuleScript") then return 1 end
 local ok, emoteData = pcall(require, emoteModule) if not ok or not emoteData then return 1 end
 local speedMult = emoteData.SpeedMult or (emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult) or 1
 feEmoteSpeedCache[emoteName] = speedMult
 return speedMult
end

local function feSetupEmoteSpeedChange(apply)
 if feEmoteSpeedConn then feEmoteSpeedConn:Disconnect(); feEmoteSpeedConn = nil end
 local gamePlayers = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players") if not gamePlayers then return end
 local localModel = gamePlayers:FindFirstChild(LocalPlayer.Name) if not localModel then return end
 local function getSpeedFolder()
 local sc = localModel:FindFirstChild("StatChanges")
 return sc and sc:FindFirstChild("Speed")
 end
 local function applySpeedValue(emoteName)
 local sp = getSpeedFolder() if not sp then return end
 local mult = feGetEmoteSpeedMult(emoteName)
 local esv = sp:FindFirstChild("EmoteSpeed")
 if apply then
 if esv then esv.Value = mult
 else
 esv = Instance.new("NumberValue") esv.Name = "EmoteSpeed" esv.Value = mult esv.Parent = sp
 end
 else
 if esv then esv:Destroy() end
 end
 end
 local function removeSpeedValue()
 local sp = getSpeedFolder() if not sp then return end
 local esv = sp:FindFirstChild("EmoteSpeed") if esv then esv:Destroy() end
 end
 if localModel:GetAttribute("Emoting") == true then
 for i = 1, 6 do
 local cur = LocalPlayer:GetAttribute("Emote" .. i)
 if cur and cur ~= "" and feIsValidEmote(cur) then
 if apply then applySpeedValue(cur) else removeSpeedValue() end
 break
 end
 end else removeSpeedValue() end
 if apply then
 feEmoteSpeedConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
 if localModel:GetAttribute("Emoting") == true then
 for i = 1, 6 do
 local cur = LocalPlayer:GetAttribute("Emote" .. i)
 if cur and cur ~= "" and feIsValidEmote(cur) then applySpeedValue(cur) break end
 end
 else removeSpeedValue() end
 end)
 end
end

LocalPlayer.Idled:Connect(function()
 local virtualUser = game:GetService("VirtualUser")
 virtualUser:CaptureController()
 virtualUser:ClickButton2(Vector2.new(0, 0))
end)

local function feSetupTPCameraOnEmoting(apply)
 if feEmotingConn then feEmotingConn:Disconnect(); feEmotingConn = nil end
 if not apply then return end
 local gamePlayers = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players") if not gamePlayers then return end
 local localModel = gamePlayers:FindFirstChild(LocalPlayer.Name) if not localModel then return end
 feEmotingConn = localModel:GetAttributeChangedSignal("Emoting"):Connect(function()
 if localModel:GetAttribute("Emoting") == true then
 local char = LocalPlayer.Character
 if char then
 local clientEvent = char:FindFirstChild("Client")
 if clientEvent then pcall(function() firesignal(clientEvent.OnClientEvent, "TPCamera", { Zoom = 10 }) end) end
 end
 end
 end)
end

local function feTriggerTagEmote(slot)
 local swapName = fePendingEmotes[slot]
 if not swapName or swapName == "" then swapName = LocalPlayer:GetAttribute("Emote" .. slot) end
 if not swapName or swapName == "" or not feIsValidEmote(swapName) then return end
 local tagData = feGetTagData() if not tagData then return end
 local emoteEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Character") and ReplicatedStorage.Events.Character:FindFirstChild("Emote")
 if emoteEvent then task.defer(function() firesignal(emoteEvent.OnClientEvent, tagData, swapName) end) end
end

local function feInstallHook()
 if feHookInstalled then return end
 local emoteRemoteFE = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Emote")
 if not emoteRemoteFE then return end
 pcall(function()
 local mt = getrawmetatable(emoteRemoteFE)
 if mt and mt.__namecall then
 local old = mt.__namecall
 setreadonly(mt, false)
 mt.__namecall = function(self, ...)
 local method = getnamecallmethod()
 if method == "FireServer" and self == emoteRemoteFE then
 local args = {...}
 local num = tostring(args[1])
 if num:match("^[1-6]$") and feBlockRemote then
 feTriggerTagEmote(tonumber(num))
 return
 end
 end
 return old(self, ...)
 end
 setreadonly(mt, true)
 feHookInstalled = true
 end end)
end

local function feApplyAllEmotes()
 feBlockRemote = true
 pcall(function()
 for i = 1, 6 do
 if fePendingEmotes[i] and fePendingEmotes[i] ~= "" and feIsValidEmote(fePendingEmotes[i]) then
 LocalPlayer:SetAttribute("Emote" .. i, fePendingEmotes[i])
 end
 end
 fePendingEmotes = {}
 feInstallHook()
 if not feEmoteRunnerActive then
 feSetupEmoteSpeedChange(true) feSetupTPCameraOnEmoting(true)
 end
 end)
end

local function feResetAllEmotes()
 feBlockRemote = false
 pcall(function()
 feSetupEmoteSpeedChange(false)
 feSetupTPCameraOnEmoting(false)
 fePendingEmotes = {}
 for i = 1, 6 do
 LocalPlayer:SetAttribute("Emote" .. i, feOriginalEmotes[i])
 pcall(function() Options["FEEmoteSlot" .. i]:SetValue(feOriginalEmotes[i] or "") end)
 end
 end)
end

local wallClimbEnabled = false
local wallClimbKeybind = "H"
local wallClimbMode = "Hold"
_G.IsHoldingH = false
local currentLockedY = 0
local RunningConnections = {}

local function SafeConnect(signal, callback)
 local conn = signal:Connect(callback)
 table.insert(RunningConnections, conn)
 return conn
end

local function parseKeyCode(key)
 if typeof(key) == "EnumItem" then return key end
 if type(key) == "string" then
 local success, result = pcall(function() return Enum.KeyCode[key] end)
 if success then return result end
 end
 return nil
end

local RealSpeed = 1500
local JumpHeight = 3
local AirStrafeAcceleration = 187
local jumpcap = 1
local SpringSpeedMultiplier = 1
local AirAcceleration = 1
autoJumpEnabled = false
bhopHoldFeature = false
bhopHoldActive = false
local jumpCooldown = 0.05
local bhopSpamDelay = 0
local accelerationMethod = "Acceleration"
local groundFriction = -0.5
local AutoAccelerationEnabled = false
local MaxSpeed = 70
local MaxAcceleration = 3
local MinAcceleration = -1
local bhopLoaded = false
local movementModule = nil
local originalApplyFriction = nil
local bhopConnection = nil

local function checkIsPlayerDown(char, hum)
 if not hum or not char then return false end
 if hum.Health <= 0 then return true end
 if hum.WalkSpeed <= 0 and hum.JumpPower <= 0 then return true end
 if hum:GetState() == Enum.HumanoidStateType.Dead then return true end
 if char:FindFirstChild("Down") or char:FindFirstChild("Downed") or char:GetAttribute("Downed") or char:GetAttribute("Down") then return true end
 return false end

local function IsOnGround()
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if not char or not hrp or not hum then return false end
 local success, result = pcall(function()
 local state = hum:GetState()
 if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Swimming then return false end
 local raycastParams = RaycastParams.new()
 raycastParams.FilterType = Enum.RaycastFilterType.Exclude
 raycastParams.FilterDescendantsInstances = {char}
 return Workspace:Raycast(hrp.Position, Vector3.new(0, -3.5, 0), raycastParams) ~= nil
 end)
 return success and result
end

local function updateBhop()
 if not bhopLoaded then return end
 pcall(function()
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if not char or not hum then return end
 local isBhopActive = autoJumpEnabled or (bhopHoldFeature and bhopHoldActive)
 if isBhopActive then
 local now = tick()
 local effectiveDelay = jumpCooldown + (bhopSpamDelay / 1000)
 if IsOnGround() and (now - LastJump) > effectiveDelay then
 LastJump = now
 hum:ChangeState(Enum.HumanoidStateType.Jumping)
 end
 end
 end)
end

local function checkBhopState()
 if autoJumpEnabled or (bhopHoldFeature and bhopHoldActive) then
 if not bhopLoaded then
 bhopLoaded = true
 if bhopConnection then bhopConnection:Disconnect() end
 bhopConnection = RunService.Heartbeat:Connect(updateBhop)
 end
 else
 if bhopLoaded then
 bhopLoaded = false
 if bhopConnection then bhopConnection:Disconnect(); bhopConnection = nil end
 end
 bhopHoldActive = false
 end
end

local function getCurrentSpeed()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp then return (hrp.Velocity * Vector3.new(1, 0, 1)).Magnitude end
 return 0
end

local function reapplyModifications()
 if not movementModule then return end
 if not originalApplyFriction then originalApplyFriction = movementModule.ApplyFriction end
 local isBhopActive = autoJumpEnabled or (bhopHoldFeature and bhopHoldActive)
 if isBhopActive then
 movementModule.ApplyFriction = function(self, frictionAmount)
 local isGrounded = self.a == true
 if isGrounded then
 if accelerationMethod == "No Acceleration" then frictionAmount = 0
 elseif accelerationMethod == "Ground Acceleration" or accelerationMethod == "Acceleration" then
 local finalFriction = groundFriction
 if AutoAccelerationEnabled then
 if getCurrentSpeed() > MaxSpeed then finalFriction = MaxAcceleration else finalFriction = MinAcceleration end
 end
 frictionAmount = finalFriction
 end
 end
 return originalApplyFriction(self, frictionAmount)
 end
 else
 movementModule.ApplyFriction = originalApplyFriction
 end
end

local function setupLegacyCharacter(character)
 local movement = character:WaitForChild("Movement", 10)
 if movement and movement:IsA("ModuleScript") then
 pcall(function()
 local module = require(movement)
 movementModule = module
 reapplyModifications()
 local originalUpdate = module.Update
 module.Update = function(self, dt)
 local originalSpeed = self.j
 self.j = RealSpeed * SpringSpeedMultiplier
 local originalAirMove = self.AirMove
 self.AirMove = function(airSelf, ...)
 local originalAccelerate = airSelf.Accelerate
 airSelf.Accelerate = function(accSelf, direction, targetSpeed, acceleration)
 targetSpeed = targetSpeed * AirAcceleration
 return originalAccelerate(accSelf, direction, targetSpeed, acceleration)
 end
 originalAirMove(airSelf, ...)
 airSelf.Accelerate = originalAccelerate
 end
 originalUpdate(self, dt)
 self.AirMove = originalAirMove
 self.j = originalSpeed
 end
 end)
 end
 task.spawn(function()
 pcall(function()
 local playerFolder = Workspace:WaitForChild("Game"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
 local movePath = playerFolder:WaitForChild("Movement")
 local moveMod = require(movePath)
 local oldAirMove = moveMod.AirMove
 moveMod.AirMove = function(self)
 oldAirMove(self)
 if self.f.a == 0 and self.f.b ~= 0 then
 local v1 = LocalPlayer.PlayerScripts.CameraCFrame.Value:VectorToWorldSpace(Vector3.new(self.f.b, 0, self.f.a))
 local v2 = Vector3.new(v1.X, 0, v1.Z)
 local v4 = (v2 == Vector3.new(0, 0, 0)) and v2 or v2.Unit
 self:Accelerate(v4, AirStrafeAcceleration, AirStrafeAcceleration)
 end
 end
 end)
 end)
 local hum = character:WaitForChild("Humanoid")
 hum.JumpHeight = JumpHeight
 local jumps = 0
 local jumpTick = tick()
 SafeConnect(hum.StateChanged, function(old, new)
 if new == Enum.HumanoidStateType.Landed then jumps = 0 end
 end)
 SafeConnect(UserInputService.JumpRequest, function()
 if jumpcap > 1 and jumps >= 1 and jumps < jumpcap and tick() - jumpTick > 0.05 then
 jumpTick = tick()
 jumps = jumps + 1
 hum:ChangeState(Enum.HumanoidStateType.Jumping)
 end
 end)
 checkBhopState()
end

local function createHitboxOnTop(cactus)
 if cactus:FindFirstChild("HasBhopHitbox") then return end
 local cframe, size
 if cactus:IsA("Model") then cframe, size = cactus:GetBoundingBox()
 elseif cactus:IsA("BasePart") then cframe, size = cactus.CFrame, cactus.Size
 else
 local primary = cactus:FindFirstChildWhichIsA("BasePart", true)
 if primary then cframe, size = primary.CFrame, primary.Size else return end
 end
 local spawnPosition = cframe.Position + Vector3.new(0, size.Y / 2, 0)
 local hitbox = Instance.new("Part")
 hitbox.Name = "BhopHitbox_Cactus"
 hitbox.Size = HITBOX_SIZE
 hitbox.CFrame = CFrame.new(spawnPosition + Vector3.new(0, 2.0 / 2, 0))
 hitbox.Transparency = HITBOX_TRANSPARERECY
 hitbox.Color = HITBOX_COLOR
 hitbox.Material = Enum.Material.Neon
 hitbox.Anchored = true
 hitbox.CanCollide = true
 hitbox.CustomPhysicalProperties = NO_FRICTION_PHYSICS
 local tag = Instance.new("BoolValue", cactus)
 tag.Name = "HasBhopHitbox"
 hitbox.Parent = workspace
end

local function forceScanCactus()
 for _, obj in ipairs(workspace:GetDescendants()) do
 local objName = string.lower(obj.Name)
 if string.find(objName, "cactus1") or string.find(objName, "cactus2") then
 if not obj:FindFirstChild("HasBhopHitbox") then task.spawn(function() createHitboxOnTop(obj) end) end
 end
 end
end

local function forceScanCarPole()
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj.Name == "CarPole" then
 if not obj:FindFirstChild("HasBhopHitbox") then task.spawn(function() createHitboxOnTop(obj) end) end
 end
 end
end

local function getMatchingTables()


 local ok, res = pcall(filtergc, "table", {
 Keys = {"Friction", "AirStrafeAcceleration", "JumpHeight", "Speed", "WalkSpeedMultiplier"},
 }, false)
 if ok and type(res) == "table" then return res end
 return {}
end

local function applyMovementSettings()
 local targets = getMatchingTables()
 for _, tbl in ipairs(targets) do
 pcall(function()
 tbl.Speed = currentSettings.Speed
 tbl.JumpCap = currentSettings.JumpCap
 tbl.AirStrafeAcceleration = currentSettings.AirStrafeAcceleration
 end)
 end
end

local function isCharacterGrounded(char, hrp, hum)
 if hum:GetState() == Enum.HumanoidStateType.Running then return true end
 if table.find({Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Swimming}, hum:GetState()) then return false end
 local raycastParams = RaycastParams.new()
 raycastParams.FilterType = Enum.RaycastFilterType.Exclude
 raycastParams.FilterDescendantsInstances = {char}
 return Workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), raycastParams) ~= nil
end

function applyBhopFriction(forceReset)
 if not forceReset and #frictionTables == 0 and getgenv().bhopHoldSystemEnabled then
 local ok, res = pcall(filtergc, "table", { Keys = {"Friction"} }, false)
 if ok and type(res) == "table" then
 for _, obj in ipairs(res) do
 if rawget(obj, "Friction") then
 table.insert(frictionTables, {obj = obj, original = obj.Friction})
 end
 end
 end
 end
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local grounded = (char and hum and hrp) and isCharacterGrounded(char, hrp, hum)
 local isActive = getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive and grounded and not forceReset
 for _, tableData in ipairs(frictionTables) do
 if tableData.obj and type(tableData.obj) == "table" then
 pcall(function()
 local isAccel = (isActive and getgenv().bhopMode == "Acceleration")
 tableData.obj.Friction = isAccel and getgenv().bhopAccelValue or tableData.original
 end)
 end
 end
end

local function sendKeyEvent(keyCode, isDown)
 pcall(function() VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game) end)
end


function BounceBhop.matchesSurface(char, hum, hrp)
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances = {char}
 params.RespectCanCollide = true
 local reach = math.max(4, hum.HipHeight + hrp.Size.Y * 0.5 + 1)
 local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, -reach, 0), params)
 if not hit then return false end
 local angle = math.deg(math.acos(math.clamp(hit.Normal.Y, -1, 1)))
 return angle >= BounceBhop.minAngle - 0.001 and angle <= BounceBhop.maxAngle + 0.001
end

local function onBouncePostSimulation()
 if not autoBounceEnabled and not BounceBhop.enabled then return end
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local hrp = char and char:FindFirstChild("HumanoidRootPart")

 if hum and hrp and hum.Health > 0 then
 local isGrounded = (hum.FloorMaterial ~= Enum.Material.Air) or (hum:GetState() == Enum.HumanoidStateType.Landed)
 if BounceBhop.enabled then isGrounded = BounceBhop.matchesSurface(char, hum, hrp) end
 if isGrounded and not bounceDebounce then
 bounceDebounce = true
 hum:ChangeState(Enum.HumanoidStateType.Jumping)
 hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
 local randomPower = math.random(math.min(bouncePowerMin, bouncePowerMax), math.max(bouncePowerMin, bouncePowerMax))
 local customImpulse = (randomPower / 2) * hrp.Mass
 hrp:ApplyImpulse(Vector3.new(0, customImpulse, 0))
 task.delay(0.05, function() bounceDebounce = false end)
 end
 end
end

function BounceBhop.updateConnection()
 if autoBounceEnabled or BounceBhop.enabled then
 if not bounceConnection then
 bounceDebounce = false
 bounceConnection = RunService.PostSimulation:Connect(onBouncePostSimulation)
 end
 else
 if bounceConnection then bounceConnection:Disconnect(); bounceConnection = nil end
 end
end

function toggleAutoBounce(state)
 autoBounceEnabled = state
 BounceBhop.updateConnection()
end

function BounceBhop.setEnabled(state)
 BounceBhop.enabled = state
 BounceBhop.updateConnection()
end

local function checkNearWall()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local raycastParams = RaycastParams.new()
 raycastParams.FilterType = Enum.RaycastFilterType.Exclude
 raycastParams.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Effects")}
 local directions = {hrp.CFrame.LookVector * 3.5, -hrp.CFrame.LookVector * 3.5, hrp.CFrame.RightVector * 3.5, -hrp.CFrame.RightVector * 3.5}
 for _, dir in ipairs(directions) do
 local result = Workspace:Raycast(hrp.Position, dir, raycastParams)
 if result and result.Instance and result.Instance.CanCollide == true then return true end
 end
 return false
end

local function onWallClimbRenderStepped()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if _G.IsHoldingH and hrp and hum then
 if checkNearWall() then
 local currentPos = hrp.Position
 hrp.CFrame = CFrame.new(currentPos.X, currentLockedY, currentPos.Z) * hrp.CFrame.Rotation
 hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
 hum:ChangeState(Enum.HumanoidStateType.Physics)
 else
 _G.IsHoldingH = false
 if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect(); _G.WallClimbConnection = nil end
 hum:ChangeState(Enum.HumanoidStateType.GettingUp)
 end
 end
end

local function startWallHold()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp and checkNearWall() then
 _G.IsHoldingH = true
 currentLockedY = hrp.Position.Y
 if not _G.WallClimbConnection then _G.WallClimbConnection = RunService.RenderStepped:Connect(onWallClimbRenderStepped) end
 end
end

local function stopWallHold()
 _G.IsHoldingH = false
 if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect(); _G.WallClimbConnection = nil end
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function applyCosmetics()
 if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then return end
 pcall(function()
 local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
 local a, b = Cosmetics:FindFirstChild(cosmetic1), Cosmetics:FindFirstChild(cosmetic2)
 if not a or not b then return end
 if not isSwapped then originalCosmetic1, originalCosmetic2 = cosmetic1, cosmetic2 end
 local tempRoot = Instance.new("Folder", Cosmetics)
 local tempA = Instance.new("Folder", tempRoot)
 local tempB = Instance.new("Folder", tempRoot)
 for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
 for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end
 for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
 for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end
 tempRoot:Destroy()
 isSwapped = true
 end)
end

local function resetCosmetics()
 if not isSwapped or originalCosmetic1 == "" or originalCosmetic2 == "" then return end
 pcall(function()
 local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
 local a, b = Cosmetics:FindFirstChild(originalCosmetic1), Cosmetics:FindFirstChild(originalCosmetic2)
 if a and b then
 local tempRoot = Instance.new("Folder", Cosmetics)
 local tempA = Instance.new("Folder", tempRoot)
 local tempB = Instance.new("Folder", tempRoot)
 for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
 for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end
 for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
 for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end
 tempRoot:Destroy()
 end
 isSwapped = false
 cosmetic1, cosmetic2 = "", ""
 end)
end

local function applyHeadless(character)
 if not headlessEnabled or not character then return end
 local head = character:FindFirstChild("Head")
 if not head then return end
 head.Transparency = 1
 head.CanCollide = false
 local face = head:FindFirstChildOfClass("Decal")
 if face then face:Destroy() end
 for _, v in ipairs(head:GetChildren()) do
 if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end
 end
 local mesh = Instance.new("SpecialMesh")
 mesh.MeshType = Enum.MeshType.FileMesh
 mesh.MeshId = HEADLESS_MESH_ID
 mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
 mesh.Parent = head
end

local function applyKorblox(character)
 if not korbloxEnabled or not character then return end
 local rightLeg = character:FindFirstChild("Right Leg")
 if not rightLeg then return end
 for _, v in ipairs(rightLeg:GetChildren()) do
 if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end
 end
 local mesh = Instance.new("SpecialMesh")
 mesh.MeshType = Enum.MeshType.FileMesh
 mesh.MeshId = KORBLOX_MESH_ID
 mesh.TextureId = KORBLOX_TEXTURE_ID
 mesh.Scale = Vector3.new(1, 1, 1)
 mesh.Parent = rightLeg
end

local function isPlayerPart(obj)
 for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
 if player.Character and obj:IsDescendantOf(player.Character) then return true end
 end
 return false
end

local function saveOriginalColors()
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") and not globalColorOriginals[obj] and not isPlayerPart(obj) then
 globalColorOriginals[obj] = { Color = obj.Color, Material = obj.Material }
 end
 end
end

local function applyGlobalColor(color)
 saveOriginalColors()
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") and not isPlayerPart(obj) then pcall(function() obj.Color = color end) end
 end
 globalColorApplied = true
end

local function applyRandomColor()
 saveOriginalColors()
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") and not isPlayerPart(obj) then
 pcall(function() obj.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)) end)
 end
 end
 globalColorApplied = true
end

local function resetGlobalColor()
 for obj, data in pairs(globalColorOriginals) do
 pcall(function()
 if obj and obj.Parent then obj.Color = data.Color obj.Material = data.Material end
 end)
 end
 globalColorOriginals = {}
 globalColorApplied = false
end

local function setCharacterVisibility(character, visible)
 if not character then return end
 for _, obj in ipairs(character:GetDescendants()) do
 if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then pcall(function() obj.Transparency = visible and 0 or 1 end)
 elseif obj:IsA("Decal") or obj:IsA("Texture") then pcall(function() obj.Transparency = visible and 0 or 1 end)
 elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then pcall(function() obj.Enabled = visible end) end
 end
end

local function refreshHideOthers()
 for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
 if player ~= LocalPlayer then setCharacterVisibility(player.Character, not hideOthersEnabled) end
 end
end

local function saveAndRemoveInvisWalls()
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") then
 if invisWallOriginals[obj] == nil then invisWallOriginals[obj] = obj.CanCollide end
 if obj.Transparency > 0.5 and obj.CanCollide == true then pcall(function() obj.CanCollide = false end) end
 end
 end
end

local function restoreInvisWalls()
 for obj, originalCollide in pairs(invisWallOriginals) do
 pcall(function() if obj and obj.Parent then obj.CanCollide = originalCollide end end)
 end
 invisWallOriginals = {}
end

local function applyEdgeBoost()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health <= 0 then return end
 if hrp.AssemblyLinearVelocity.Y >= -edgeVMin then return end
 local touching = hrp:GetTouchingParts()
 if #touching == 0 then return end

 local isBounce = false
 for _, pt in pairs(touching) do
 local n = string.lower(pt.Name)
 for _, w in pairs(edgeBoostSkipWords) do
 if w ~= "" and n:find(w) then isBounce = true; break end
 end
 if not isBounce and pt.Parent then
 local pn = string.lower(pt.Parent.Name)
 for _, w in pairs(edgeBoostSkipWords) do
 if w ~= "" and pn:find(w) then isBounce = true; break end
 end
 end
 if isBounce then break end
 end
 if not isBounce then
 local vel = hrp.AssemblyLinearVelocity
 hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) + Vector3.new(0, edgeBoostPower, 0)
 end
end

local function fireSelectEmote(slot)
 if not currentTag or not selectEmotes[slot] or selectEmotes[slot] == "" then return end
 local tagNumber = tonumber(currentTag)
 if not tagNumber or tagNumber < 0 or tagNumber > 255 then return end
 if remoteSignal then
 pcall(function()
 local buf = buffer.create(2)
 buffer.writeu8(buf, 0, tagNumber)
 buffer.writeu8(buf, 1, 17)
 firesignal(remoteSignal, buf, {selectEmotes[slot]})
 end)
 end
end

local function onRespawnTagCheck()
 currentTag = nil; pendingSlot = nil
 task.spawn(function()
 local startTime = tick()
 while tick() - startTime < 10 do
 if Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players") then
 local playerFolder = Workspace.Game.Players:FindFirstChild(LocalPlayer.Name)
 if playerFolder then
 local tagAttr = playerFolder:GetAttribute("Tag") or (playerFolder:FindFirstChild("Tag") and playerFolder.Tag.Value)
 if tagAttr then
 local tagNum = tonumber(tagAttr)
 if tagNum and tagNum >= 0 and tagNum <= 255 then currentTag = tagAttr; break end
 end
 end
 end
 task.wait(0.5)
 end
 end)
end

if PassCharacterInfo and EmoteRemote then
 SafeConnect(PassCharacterInfo.OnClientEvent, function(...)
 if not pendingSlot then return end
 local slot = pendingSlot; pendingSlot = nil
 task.wait(0.1); fireSelectEmote(slot)
 end)
 local oldNamecall
 oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
 local methodName = getnamecallmethod()
 local args = {...}
 if methodName == "FireServer" and self == EmoteRemote and type(args[1]) == "string" then
 for i = 1, 12 do
 if emoteEnabled[i] and currentEmotes[i] ~= "" and args[1]:gsub("%s+", ""):lower() == currentEmotes[i]:lower() then
 pendingSlot = i; blockOriginalEmote = true task.spawn(function()
 task.wait(0.1); blockOriginalEmote = false
 if pendingSlot == i then pendingSlot = nil; fireSelectEmote(i) end
 end)
 if blockOriginalEmote then return nil end
 end
 end
 end
 return oldNamecall(self, ...)
 end)
end






local Stats = game:GetService("Stats")
local WatermarkConnection
getgenv().WatermarkEnabled = false

WatermarkConnection = (function()
 local acc, frames, fps = 0, 0, 0
 return RunService.RenderStepped:Connect(function(deltaTime)
  if not getgenv().WatermarkEnabled then return end
  acc = acc + deltaTime frames = frames + 1
  if fps > 0 and acc < 0.5 then return end
  fps = math.max(1, math.floor(frames / acc + 0.5)) acc, frames = 0, 0
  local ping = 0
  pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
  Library:SetWatermarkStats(fps, ping)
 end)
end)()

do
 local g = Tabs.Movement:AddLeftGroupbox("Player Modification Settings")
 g:AddInput("PlayerSpeedModifier", { Default = "1500", Text = "Player Speed Modifier", Placeholder = "Default: 1500", Numeric = true, Callback = function(value) local val = tonumber(value) if val then currentSettings.Speed = val; applyMovementSettings() end end })
 g:AddInput("PlayerJumpHeightPower", { Default = "3.5", Text = "Player Jump Height Power", Placeholder = "Default: 3.5", Numeric = true, Callback = function(value) if tonumber(value) then currentSettings.JumpPowerValue = tonumber(value) end end })
 g:AddInput("PlayerJumpCapMultiplier", { Default = "1", Text = "Player Jump Cap Multiplier", Placeholder = "Default: 1", Numeric = true, Callback = function(value) local val = tonumber(value) if val then currentSettings.JumpCap = val; applyMovementSettings() end end })
 g:AddInput("AirStrafeAcceleration", { Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true, Callback = function(value) local val = tonumber(value) if val then currentSettings.AirStrafeAcceleration = val; applyMovementSettings() end end })
end

do
 local g = Tabs.Movement:AddLeftGroupbox("Bhop")
 g:AddToggle("EnableBhopSystem", {
 Text = "Enable Bhop System (Hold Space)",
 Default = false,
 Callback = function(state)
 getgenv().bhopHoldSystemEnabled = state
 if not state then getgenv().bhopHoldActive = false end
 applyBhopFriction(not state)
 end
 })

 g:AddDivider()
 g:AddSlider("BhopSystemDelay", {
 Text = "Jump Spam Delay (ms)",
 Min = 0, Max = 500, Default = 150, Rounding = 10,
 Callback = function(value)
 bhopSystemSpamDelay = value / 1000
 end
 })
end

do
 local g = Tabs.Movement:AddLeftGroupbox("Down Dash Overhaul")
 g:AddToggle("EnableDownDashOverhaul", { Text = "Enable Down Dash Overhaul", Default = false, Callback = function(state) downDashEnabled = state if not state then downDashActive = false; downDashPreActivated = false; downDashCurrentSpeed = 0 end end })
 g:AddSlider("DownDashSpeedSlider", { Text = "Down Dash Speed", Min = 20, Max = 300, Default = 185, Rounding = 0, Callback = function(value) downDashSpeed = value end })
end

do
 local g = Tabs.Misc:AddLeftGroupbox("Emote Utilities")
 g:AddButton({ Text = "Nonmovable Emote", DoubleClick = false, Func = function()
 local EmotesFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Emotes")
 for _, emoteModule in pairs(EmotesFolder:GetChildren()) do
 if emoteModule:IsA("ModuleScript") then
 local ok, emoteData = pcall(require, emoteModule)
 if ok and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult == 0 then emoteData.EmoteInfo.SpeedMult = 0.7 end
 end
 end
 end })
end

do
 local g = Tabs.Movement:AddRightGroupbox("Edge Boost")
 g:AddToggle("EnableEdgeBoost", { Text = "Enable Edge Boost", Default = false, Callback = function(state) edgeBoostEnabled = state if state then if edgeBoostConn then edgeBoostConn:Disconnect() end edgeBoostConn = RunService.Stepped:Connect(applyEdgeBoost) else if edgeBoostConn then edgeBoostConn:Disconnect(); edgeBoostConn = nil end end end })
 g:AddSlider("EdgeBoostPower", { Text = "Edge Power", Min = 10, Max = 500, Default = 100, Rounding = 0, Callback = function(value) edgeBoostPower = value end })
 g:AddDropdown("EdgeBoostWordsDropdown", {
 Values = {"bounce", "boost", "launch", "jump", "pad", "ramp", "platform", "truss", "step"},
 Default = 0, Multi = true, Text = "Skip Words", Tooltip = "Mark words to skip",
 Callback = function(selectedValues)
 edgeBoostSkipWords = {}
 for word, isSelected in pairs(selectedValues) do if isSelected then table.insert(edgeBoostSkipWords, string.lower(word)) end end
 end
 })
end

do
 local g = Tabs.Movement:AddRightGroupbox("Wall Cling Modifier")
 g:AddToggle("EnableWallClingFunction", { Text = "Enable Wall Cling Function", Default = false, Callback = function(state) wallClimbEnabled = state if not state then stopWallHold() end end })
 g:AddDropdown("ActivationTriggerMode", { Values = { "Hold", "Toggle" }, Default = "Hold", Text = "Activation Trigger Mode", Callback = function(value) wallClimbMode = value stopWallHold() end })
 g:AddLabel("Wall Activation KeyBind"):AddKeyPicker("WallClimbKeybindPicker", { Default = "H", SyncToggleState = false, Mode = "Toggle", Text = "Wall Activation Key", ChangedCallback = function(key) wallClimbKeybind = key.Name end })
end

do
 local g = Tabs.Movement:AddRightGroupbox("Auto Bounce Velocity")
 g:AddToggle("EnableAutoBounceLoop", { Text = "Enable Auto Bounce Loop", Default = false, Callback = function(state) toggleAutoBounce(state) end })
 g:AddLabel("Auto Bounce Switch Key"):AddKeyPicker("AutoBounceKeybindPicker", { Default = "B", SyncToggleState = false, Mode = "Toggle", Text = "Auto Bounce Switch Key", ChangedCallback = function(key) autoBounceKeybind = key.Name end })
 g:AddSlider("BounceForceMin", { Text = "Min Bounce Velocity", Min = 10, Max = 150, Default = 40, Rounding = 0, Callback = function(value) bouncePowerMin = value end })
 g:AddSlider("BounceForceMax", { Text = "Max Bounce Velocity", Min = 10, Max = 150, Default = 60, Rounding = 0, Callback = function(value) bouncePowerMax = value end })
 g:AddDivider()
 g:AddToggle("EnableAutoBounceBhop", { Text = "AutoBounceBhop", Default = false, Callback = BounceBhop.setEnabled })
 g:AddSlider("BounceBhopMinAngle", { Text = "Bhop Min Surface Angle", Min = 50, Max = 99, Default = 70, Rounding = 0, Suffix = "°",
 Callback = function(v)
 BounceBhop.minAngle = v
 if v > BounceBhop.maxAngle then
 BounceBhop.maxAngle = v
 if Options.BounceBhopMaxAngle then Options.BounceBhopMaxAngle:SetValue(v) end
 end
 end })
 g:AddSlider("BounceBhopMaxAngle", { Text = "Bhop Max Surface Angle", Min = 50, Max = 99, Default = 90, Rounding = 0, Suffix = "°",
 Callback = function(v)
 BounceBhop.maxAngle = v
 if v < BounceBhop.minAngle then
 BounceBhop.minAngle = v
 if Options.BounceBhopMinAngle then Options.BounceBhopMinAngle:SetValue(v) end
 end
 end })
 g:AddLabel("Bhop uses the bounce force above.\nWhen both modes are on, the angle filter wins.", true)
end

do
 local g = Tabs.Movement:AddRightGroupbox("Turnbind Engineering")
 g:AddToggle("EnableTurnbindModifier", { Text = "Enable Turnbind Modifier", Default = false, Callback = function(state) turnbindEnabled = state end })
 g:AddInput("LeftTurnKeyBinding", { Default = "A", Text = "Left Turn Key Binding", Placeholder = "A", Callback = function(v) turnbindLeftKey = v:upper() end })
 g:AddInput("RightTurnKeyBinding", { Default = "D", Text = "Right Turn Key Binding", Placeholder = "D", Callback = function(v) turnbindRightKey = v:upper() end })
end


do
    local g = Tabs.Movement:AddLeftGroupbox("Auto Strafe System")

    g:AddToggle("AutoStrafeToggle", {
        Text = "Enable Auto Strafe",
        Default = false,
        Callback = function(value)
            if value then
                if getgenv().AutoStrafe then
                    getgenv().AutoStrafe.enabled = true
                    getgenv().AutoStrafe.start()
                    Library:Notify({
                        Title = "Auto Strafe",
                        Description = "Activated - Hold W to strafe",
                        Time = 2
                    })
                end
            else
                if getgenv().AutoStrafe then
                    getgenv().AutoStrafe.enabled = false
                    getgenv().AutoStrafe.stop()
                    Library:Notify({
                        Title = "Auto Strafe",
                        Description = "Disabled",
                        Time = 1
                    })
                end
            end
        end
    }):AddKeyPicker("AutoStrafeKeyPicker", {
        Default = "Z",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Auto Strafe"
    })

    g:AddSlider("FWAutoStrafeMax", {
        Text = "Max Speed (default 60)",
        Min = 10,
        Max = 500,
        Default = 60,
        Rounding = 0,
        Callback = function(value)
            if getgenv().AutoStrafe then
                getgenv().AutoStrafe.maxSpeed = value
            end
        end
    })
    g:AddLabel("Scales AutoStrafe output speed. 60 = unchanged.")

    g:AddSlider("StarterSpeedMin", {
        Text = "Min Starter Speed",
        Min = 40,
        Max = 70,
        Default = 60,
        Rounding = 0
    })

    g:AddSlider("StarterSpeedMax", {
        Text = "Max Starter Speed",
        Min = 40,
        Max = 100,
        Default = 90,
        Rounding = 0
    })

    g:AddLabel("Controls:")
    g:AddLabel("• Hold W to activate")
    g:AddLabel("• Use A/D to steer")
end




;(function()
    local Surf = {
        enabled = false, speed = 40, randomize = false, minSpeed = 30, maxSpeed = 60,
        range = 3, current = 40, nextRoll = 0, lockY = nil, lostAt = nil,
        standoff = 1.2, pullGain = 14, maxPull = 40, grace = 0.1, reroll = 0.12,
        rng = Random.new(),
        dirs = {},
        params = RaycastParams.new(),
    }
    for i = 0, 7 do
        local a = math.rad(i * 45)
        Surf.dirs[#Surf.dirs + 1] = Vector3.new(math.cos(a), 0, math.sin(a))
    end
    Surf.params.FilterType = Enum.RaycastFilterType.Exclude
    Surf.params.RespectCanCollide = true

    local function playerParts()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return nil end
        return char, hum, root
    end

    local function findWall(char, root, reach)
        local exclude = { char }
        for _, name in ipairs({ "Rigs", "Players" }) do
            local folder = Workspace:FindFirstChild(name)
            if folder then exclude[#exclude + 1] = folder end
        end
        Surf.params.FilterDescendantsInstances = exclude
        local best, bestDist = nil, math.huge
        for _, dir in ipairs(Surf.dirs) do
            local hit = Workspace:Raycast(root.Position, dir * reach, Surf.params)
            if hit and math.abs(hit.Normal.Y) < 0.3 then
                local d = (hit.Position - root.Position).Magnitude
                if d < bestDist then best, bestDist = hit, d end
            end
        end
        return best
    end

    local function currentSpeed(now)
        if not Surf.randomize then return Surf.speed end
        if now >= Surf.nextRoll then
            local lo = math.min(Surf.minSpeed, Surf.maxSpeed)
            local hi = math.max(Surf.minSpeed, Surf.maxSpeed)
            Surf.current = Surf.rng:NextNumber(lo, hi)
            Surf.nextRoll = now + Surf.reroll
        end
        return Surf.current
    end

    local function holdHeight(root)
        if not Surf.lockY then return end
        local dy = Surf.lockY - root.Position.Y
        if math.abs(dy) > 0.005 then
            root.CFrame = root.CFrame + Vector3.new(0, dy, 0)
        end
        local v = root.AssemblyLinearVelocity
        if v.Y ~= 0 then
            root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
        end
    end

    local function release()
        Surf.lockY = nil
        Surf.lostAt = nil
    end

    local function stepPre(dt)
        if not Surf.enabled then
            release()
            return
        end
        local char, hum, root = playerParts()
        if not char then
            release()
            return
        end
        local now = os.clock()
        local hit = findWall(char, root, Surf.range + Surf.standoff)
        if not hit then
            if Surf.lockY then
                Surf.lostAt = Surf.lostAt or now
                if now - Surf.lostAt > Surf.grace then
                    release()
                else
                    holdHeight(root)
                end
            end
            return
        end
        Surf.lostAt = nil
        local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
        if n.Magnitude < 1e-3 then return end
        n = n.Unit

        local pos = root.Position
        if not Surf.lockY then Surf.lockY = pos.Y end
        dt = math.clamp(dt, 0, 0.05)

        local gap = (pos - hit.Position):Dot(n) - Surf.standoff
        local pull = math.clamp(gap * math.min(1, Surf.pullGain * dt), -Surf.maxPull * dt, Surf.maxPull * dt)

        local slide = Vector3.zero
        local md = hum.MoveDirection
        local wish = Vector3.new(md.X, 0, md.Z)
        if wish.Magnitude >= 0.05 then
            local tangent = wish - n * wish:Dot(n)
            if tangent.Magnitude >= 0.05 then
                local speed = currentSpeed(now)
                if speed == speed and speed ~= math.huge then
                    slide = tangent.Unit * speed * dt
                end
            end
        end

        root.CFrame = root.CFrame + Vector3.new(slide.X - n.X * pull, 0, slide.Z - n.Z * pull)
        holdHeight(root)
    end

    local function stepPost()
        if not Surf.enabled or not Surf.lockY then return end
        local _, _, root = playerParts()
        if root then holdHeight(root) end
    end

    local c1 = RunService.PreSimulation:Connect(stepPre)
    local c2 = RunService.PostSimulation:Connect(stepPost)
    Library:OnUnload(function() Surf.enabled = false; c1:Disconnect(); c2:Disconnect() end)

    local gSurf = Tabs.Movement:AddLeftGroupbox("Pixel Surf")
    gSurf:AddToggle("FWPixelSurf", {
        Text = "Enable Pixel Surf",
        Default = false,
        Callback = function(v)
            Surf.enabled = v
            release()
            Surf.nextRoll = 0
        end
    }):AddKeyPicker("FWPixelSurfKey", {
        Default = "X",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Pixel Surf"
    })
    gSurf:AddSlider("FWPixelSurfRange", {
        Text = "Magnet Range (studs)",
        Min = 0.5,
        Max = 10,
        Default = 3,
        Rounding = 1,
        Callback = function(v) Surf.range = v end
    })
    gSurf:AddSlider("FWPixelSurfSpeed", {
        Text = "Surf Speed (extra, along wall)",
        Min = 0,
        Max = 300,
        Default = 40,
        Rounding = 1,
        Callback = function(v) Surf.speed = v end
    })
    gSurf:AddToggle("FWPixelSurfRandom", {
        Text = "Randomize Surf Speed",
        Default = false,
        Callback = function(v)
            Surf.randomize = v
            Surf.nextRoll = 0
        end
    })
    gSurf:AddSlider("FWPixelSurfMin", {
        Text = "Random Min Speed",
        Min = 0,
        Max = 300,
        Default = 30,
        Rounding = 1,
        Callback = function(v) Surf.minSpeed = v end
    })
    gSurf:AddSlider("FWPixelSurfMax", {
        Text = "Random Max Speed",
        Min = 0,
        Max = 300,
        Default = 60,
        Rounding = 1,
        Callback = function(v) Surf.maxSpeed = v end
    })
    gSurf:AddLabel("Hold/Toggle: right-click key box. Pulls to wall and holds height until release or wall ends.")
end)()




;(function()
    local AA = {
        enabled = false, mode = "Spin",
        spin = 180, jitter = 60, jitterRate = 20, wayRate = 4,
        stances = { Forward = true, Center = true, Backwards = true },
        baseYaw = 0, baseT = 0, t0 = 0, hum = nil, autoRotate = nil,
        order = { "Forward", "Center", "Backwards" },
        stanceYaw = { Forward = 0, Center = math.rad(90), Backwards = math.pi },
        bind = "FWAntiAimRender",
    }

    local function playerParts()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return nil end
        return char, hum, root
    end

    local function cameraYaw()
        local cam = Workspace.CurrentCamera
        if not cam then return nil end
        local look = cam.CFrame.LookVector
        if look.X * look.X + look.Z * look.Z < 1e-6 then return nil end
        return math.atan2(-look.X, -look.Z)
    end

    local function spinYaw(now)
        return (AA.baseYaw + math.rad(AA.spin) * (now - AA.baseT)) % (2 * math.pi)
    end

    local function restore()
        if AA.hum and AA.hum.Parent and AA.autoRotate ~= nil then
            AA.hum.AutoRotate = AA.autoRotate
        end
        AA.hum, AA.autoRotate = nil, nil
    end

    local function apply()
        if not AA.enabled then
            if AA.hum then restore() end
            return
        end
        local char, hum, root = playerParts()
        if not char or hum.Sit then
            restore()
            return
        end
        local now = os.clock()
        if AA.hum ~= hum then
            restore()
            AA.hum, AA.autoRotate = hum, hum.AutoRotate
            local _, y = root.CFrame:ToOrientation()
            AA.baseYaw, AA.baseT, AA.t0 = y % (2 * math.pi), now, now
        end
        hum.AutoRotate = false

        local yaw
        if AA.mode == "Spin" then
            yaw = spinYaw(now)
        else
            local base = cameraYaw()
            if not base then return end
            local clock = now - AA.t0
            if AA.mode == "Jitter" then
                local flip = math.floor(clock * AA.jitterRate) % 2 == 0
                yaw = base + math.rad(flip and AA.jitter or -AA.jitter)
            else
                local list = {}
                for _, name in ipairs(AA.order) do
                    if AA.stances[name] then list[#list + 1] = name end
                end
                if #list == 0 then return end
                local i = math.floor(clock * AA.wayRate) % #list + 1
                yaw = base + AA.stanceYaw[list[i]]
            end
        end
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local c1 = RunService.PreSimulation:Connect(apply)
    local c2 = RunService.PostSimulation:Connect(apply)
    RunService:BindToRenderStep(AA.bind, Enum.RenderPriority.Last.Value + 1, apply)
    Library:OnUnload(function()
        AA.enabled = false
        c1:Disconnect()
        c2:Disconnect()
        pcall(function() RunService:UnbindFromRenderStep(AA.bind) end)
        restore()
    end)

    local secAA = Tabs.AntiAim:AddLeftGroupbox("Anti Aim")
    secAA:AddToggle("FWAntiAim", {
        Text = "Enable Anti Aim",
        Default = false,
        Callback = function(v)
            AA.enabled = v
            AA.hum = nil
            if not v then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and AA.autoRotate ~= nil then hum.AutoRotate = AA.autoRotate end
                AA.autoRotate = nil
            end
        end
    }):AddKeyPicker("FWAntiAimKey", {
        Default = "G",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Anti Aim"
    })

    secAA:AddDropdown("FWAAMode", {
        Text = "AA Mode",
        Values = { "Spin", "Jitter", "3-Way" },
        Default = "Spin",
        Callback = function(v)
            AA.mode = v
            AA.t0 = os.clock()
            AA.hum = nil
        end
    })

    secAA:AddSlider("FWAASpin", {
        Text = "AA Spin Speed (-360..360 deg/s)",
        Min = -360,
        Max = 360,
        Default = 180,
        Rounding = 0,
        Callback = function(v)
            local now = os.clock()
            AA.baseYaw = spinYaw(now)
            AA.baseT = now
            AA.spin = v
        end
    })

    secAA:AddSlider("FWAAJitter", {
        Text = "AA Jitter Angle (-89..89 deg)",
        Min = -89,
        Max = 89,
        Default = 60,
        Rounding = 0,
        Callback = function(v) AA.jitter = v end
    })

    secAA:AddSlider("FWAAJitterRate", {
        Text = "Jitter Rate (flips/s)",
        Min = 1,
        Max = 60,
        Default = 20,
        Rounding = 1,
        Callback = function(v) AA.jitterRate = v end
    })

    secAA:AddLabel("Spin: own rotation. Jitter and 3-Way are relative to your camera yaw. Position and velocity are not touched.")

    local secWay = Tabs.AntiAim:AddRightGroupbox("3-Way")
    secWay:AddDropdown("FWAAWays", {
        Text = "3-Way Stances",
        Values = AA.order,
        Default = AA.order,
        Multi = true,
        Callback = function(list)
            AA.stances = { Forward = false, Center = false, Backwards = false }
            if type(list) == "table" then
                for k, v in pairs(list) do
                    local name = type(k) == "string" and k or v
                    if AA.stances[name] ~= nil then AA.stances[name] = true end
                end
            end
        end
    })

    secWay:AddSlider("FWAAWayRate", {
        Text = "3-Way Rate (changes/s)",
        Min = 0.5,
        Max = 30,
        Default = 4,
        Rounding = 1,
        Callback = function(v) AA.wayRate = v end
    })

    secWay:AddLabel("Forward = camera yaw, Center = camera yaw +90 deg, Backwards = camera yaw +180 deg. Cycles in that order.")
end)()




;(function()
    task.spawn(function()
        local alive = true
        Library:OnUnload(function() alive = false end)

        local itemsRoot = ReplicatedStorage:FindFirstChild("Items")
        if not itemsRoot then return end
        local scanning, rescan = false, false

        local function collect()
            local names, seen = {}, 0
            for _, m in ipairs(itemsRoot:GetDescendants()) do
                if not alive then return nil end
                if m:IsA("ModuleScript") then
                    local ok, t = pcall(require, m)
                    if ok and type(t) == "table" and type(t.EquipInfo) == "table" and t.EquipInfo.SlotType == "Unusual" then
                        names[m.Name] = true
                    end
                    seen = seen + 1
                    if seen % 40 == 0 then task.wait() end
                end
            end
            return names
        end

        local function auraDropdowns(names)
            local found = {}
            for _, item in pairs(Library.Options or {}) do
                local vals = item and item.Values
                if type(vals) == "table" and type(item.SetValues) == "function" and #vals >= 20 then
                    local hit = 0
                    for _, v in ipairs(vals) do
                        if names[v] then hit = hit + 1 end
                    end
                    if hit / #vals >= 0.8 then found[#found + 1] = item end
                end
            end
            return found
        end

        local function sync()
            if scanning then
                rescan = true
                return
            end
            scanning = true
            repeat
                rescan = false
                local names = collect()
                if not names then break end
                local added, dropdowns = {}, auraDropdowns(names)
                for _, api in ipairs(dropdowns) do
                    local have = {}
                    for _, v in ipairs(api.Values) do have[v] = true end
                    local add = {}
                    for name in pairs(names) do
                        if not have[name] then add[#add + 1] = name end
                    end
                    if #add > 0 then
                        table.sort(add)
                        local merged = table.clone(api.Values)
                        for _, name in ipairs(add) do merged[#merged + 1] = name end
                        api:SetValues(merged)
                        added = add
                    end
                end
                local total = 0
                for _ in pairs(names) do total = total + 1 end
                getgenv().FW_AutoAuras = { detected = total, dropdowns = #dropdowns, added = added }
            until not rescan or not alive
            scanning = false
        end

        sync()
        local pending = false
        local conn = itemsRoot.DescendantAdded:Connect(function(inst)
            if not inst:IsA("ModuleScript") or pending then return end
            pending = true
            task.delay(3, function()
                pending = false
                if alive then sync() end
            end)
        end)
        Library:OnUnload(function() conn:Disconnect() end)
    end)
end)()


do
 local g = Tabs.Movement:AddLeftGroupbox(" Enhanced Bhop System")

 local bhopModeDropdown = g:AddDropdown("BhopMode", {
 Values = {"Hold Space (Default)", "Input Imitation"},
 Default = 1,
 Multi = false,
 Callback = function(value)
 if Options.BhopEnabled.Value then
 if value == "Input Imitation" then
 EnhancedBhop.enable("InputImitation")
 Library:Notify({Title = "Bhop Mode", Description = "Switched to Input Imitation", Duration = 1})
 else
 EnhancedBhop.enable("Default")
 Library:Notify({Title = "Bhop Mode", Description = "Switched to Hold Space", Duration = 1})
 end
 end
 end
 })

 g:AddToggle("BhopEnabled", {
 Text = "Enable Bhop",
 Default = false,
 Callback = function(value)
 if value then
 local mode = bhopModeDropdown.Value
 if mode == "Input Imitation" then
 EnhancedBhop.enable("InputImitation")
 else
 EnhancedBhop.enable("Default")
 end
 Library:Notify({Title = "Bhop System", Description = " Enabled - Mode: " .. mode, Duration = 2})
 else
 EnhancedBhop.disable()
 Library:Notify({Title = "Bhop System", Description = " Disabled", Duration = 1})
 end
 end
 })

 g:AddSlider("BhopInputDelay", {
 Text = "Input Mode Delay (ms)",
 Min = 50, Max = 500, Default = 150, Rounding = 10,
 Callback = function(value)
 EnhancedBhop.inputModeDelay = value / 1000
 end
 })

 g:AddDivider()
 g:AddSlider("BhopSpamDelay", {
 Text = "Space Press Delay (ms)",
 Min = 0, Max = 500, Default = 0, Rounding = 10,
 Callback = function(value)
 bhopSpamDelay = value
 if value > 0 then
 Library:Notify({Title = "Bhop", Description = "Spam delay: " .. value .. "ms", Duration = 1})
 end
 end
 })

 g:AddLabel("Higher = smoother, less like noclip")
end


do
 local g = Tabs.Movement:AddRightGroupbox(" Infinite Slide System")

 local slideBounceModeDropdown = g:AddDropdown("SlideBounceMode", {
 Values = {"SlideBounceNoStuck (1.05x)", "SlideBounceNoStuck (Input - 17.01x)"},
 Default = 1,
 Multi = false,
 Callback = function(value)
 if Options.SlideEnabled.Value then
 if value == "SlideBounceNoStuck (Input - 17.01x)" then
 SlideBounce.enable("Input")
 Library:Notify({Title = "Slide Mode", Description = "Switched to Input (17.01x)", Duration = 1})
 else
 SlideBounce.enable("NoStuck")
 Library:Notify({Title = "Slide Mode", Description = "Switched to Default (1.05x)", Duration = 1})
 end
 end
 end
 })

 g:AddToggle("SlideEnabled", {
 Text = "Enable Infinite Slide Bounce",
 Default = false,
 Callback = function(value)
 if value then
 local mode = slideBounceModeDropdown.Value
 if mode == "SlideBounceNoStuck (Input - 17.01x)" then
 SlideBounce.enable("Input")
 else
 SlideBounce.enable("NoStuck")
 end
 Library:Notify({Title = "Slide Bounce", Description = " Enabled - Mode: " .. mode, Duration = 2})
 else
 SlideBounce.disable()
 Library:Notify({Title = "Slide Bounce", Description = " Disabled", Duration = 1})
 end
 end
 })

 g:AddSlider("SlideSpeedDefault", {
 Text = "Slide Speed (Default Mode)",
 Min = 1.0, Max = 2.0, Default = 1.05, Rounding = 2,
 Callback = function(value)
 SlideBounce.slideSpeedMultiplier = value
 end
 })

 g:AddSlider("SlideSpeedInput", {
 Text = "Slide Speed (Input Mode)",
 Min = 5.0, Max = 25.0, Default = 17.01, Rounding = 2,
 Callback = function(value)
 SlideBounce.slideSpeedMultiplierInput = value
 end
 })

 g:AddToggle("SlideRotation", {
 Text = "Enable Slide Rotation",
 Default = false,
 Callback = function(value)
 SlideBounce.rotationEnabled = value
 if value then
 Library:Notify({Title = "Slide Rotation", Description = " Enabled", Duration = 1})
 end
 end
 })
end


do
 local g = Tabs.Movement:AddRightGroupbox(" Better Rotation System")

 g:AddToggle("BetterRotationEnabled", {
 Text = "Enable Better Rotation",
 Default = false,
 Callback = function(value)
 BetterRotation.enabled = value
 if value then
 BetterRotation.start()
 Library:Notify({Title = "Better Rotation", Description = " Enabled - Smooth character rotation based on velocity", Duration = 2})
 else
 BetterRotation.stop()
 Library:Notify({Title = "Better Rotation", Description = " Disabled", Duration = 1})
 end
 end
 })

 g:AddSlider("BetterRotationSmoothness", {
 Text = "Rotation Smoothness",
 Min = 0.05, Max = 0.5, Default = 0.2, Rounding = 3,
 Callback = function(value)
 BetterRotation.smoothness = value
 end
 })

 g:AddLabel("Min Velocity for Rotation:")
 g:AddSlider("BetterRotationMinVelocity", {
 Text = "Minimum Velocity (studs/s)",
 Min = 0.1, Max = 10, Default = 1.0, Rounding = 1,
 Callback = function(value)
 BetterRotation.minVelocity = value
 end
 })
end


do
 local g = Tabs.Movement:AddLeftGroupbox(" Quick Presets")

 g:AddButton(" Preset: Aggressive Mode", function()
 AutoStrafe.enabled = true
 AutoStrafe.start()
 AutoStrafe.cameraRotationSpeed = 4.5
 EnhancedBhop.enable("InputImitation")
 SlideBounce.enable("Input")
 BetterRotation.enabled = true
 BetterRotation.start()

 Options.AutoStrafeEnabled:Set(true)
 Options.BhopEnabled:Set(true)
 Options.SlideEnabled:Set(true)
 Options.BetterRotationEnabled:Set(true)

 Library:Notify({
 Title = "Preset Applied",
 Description = " Aggressive Mode: Auto-Strafe + Input Bhop + Input Slide + Better Rotation",
 Duration = 3
 })
 end)

 g:AddButton(" Preset: Casual Mode", function()
 AutoStrafe.stop()
 EnhancedBhop.enable("Default")
 SlideBounce.enable("NoStuck")
 BetterRotation.enabled = true
 BetterRotation.start()

 Options.AutoStrafeEnabled:Set(false)
 Options.BhopEnabled:Set(true)
 Options.SlideEnabled:Set(true)
 Options.BetterRotationEnabled:Set(true)

 Library:Notify({
 Title = "Preset Applied",
 Description = " Casual Mode: Hold Bhop + Default Slide + Better Rotation",
 Duration = 3
 })
 end)

 g:AddButton(" Reset All Movement", function()
 AutoStrafe.stop()
 EnhancedBhop.disable()
 SlideBounce.disable()
 BetterRotation.stop()

 Options.AutoStrafeEnabled:Set(false)
 Options.BhopEnabled:Set(false)
 Options.SlideEnabled:Set(false)
 Options.BetterRotationEnabled:Set(false)

 Library:Notify({Title = "Reset", Description = "All movement systems disabled", Duration = 2})
 end)
end


do
 local g = Tabs.Movement:AddRightGroupbox(" System Information")
 g:AddLabel("Auto Strafe: Hold W + A/D auto-alternate with camera rotation")
 g:AddLabel("Bhop Default: Hold Space to continuous bhop")
 g:AddLabel("Bhop Input: Auto-simulates Space presses with custom delay")
 g:AddLabel("Slide Default: Applies 1.05x speed multiplier on slide")
 g:AddLabel("Slide Input: Applies 17.01x speed multiplier on slide (VERY POWERFUL!)")
 g:AddLabel("Better Rotation: Auto-rotates character to face movement direction")
end



do
 local g = Tabs.Legacy:AddLeftGroupbox("Legacy Player Modification")
 g:AddInput("RealSpeedMultiplier", { Default = "1500", Text = "Real Speed Multiplier", Placeholder = "Default: 1500", Numeric = true, Callback = function(value) local n = tonumber(value) if n then RealSpeed = n end end })
 g:AddInput("LegacyJumpHeight", { Default = "3", Text = "Legacy Jump Height", Placeholder = "Default: 3", Numeric = true, Callback = function(value) local n = tonumber(value) if n then JumpHeight = n local char = LocalPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid") if hum then hum.JumpHeight = n end end end })
 g:AddInput("AirStrafeAccelerationLegacy", { Default = "187", Text = "Air Strafe Acceleration", Placeholder = "Default: 187", Numeric = true, Callback = function(value) local n = tonumber(value) if n then AirStrafeAcceleration = n end end })
end

do
 local g = Tabs.Legacy:AddLeftGroupbox("Legacy Bhop")
 g:AddToggle("EnableBhopAutoJump", { Text = "Enable Bhop (Auto Jump)", Default = false, Callback = function(state) autoJumpEnabled = state checkBhopState() reapplyModifications() end })
 g:AddToggle("BhopKeyHoldingSpace", { Text = "Bhop Key Holding (Space / Mobile Jump)", Default = false, Callback = function(state) bhopHoldFeature = state if not state then bhopHoldActive = false checkBhopState() reapplyModifications() end end })
 g:AddDropdown("BhopModeDropdown", { Values = {"No Acceleration", "Ground Acceleration", "Acceleration"}, Default = "Acceleration", Text = "Bhop Mode", Callback = function(value) accelerationMethod = value reapplyModifications() end })
 g:AddInput("BhopAccelerationInput", { Default = "-0.5", Text = "Bhop Acceleration (Negative Value Only)", Placeholder = "-0.5", Callback = function(value) local n = tonumber(value) if n then groundFriction = n reapplyModifications() end end })
end

do
 local g = Tabs.Legacy:AddRightGroupbox("Legacy Auto Acceleration")
 g:AddToggle("EnableAutoAccelerationLegit", { Text = "Enable Auto Acceleration (Legit)", Default = false, Callback = function(state) AutoAccelerationEnabled = state reapplyModifications() end })
end

do
 local g = Tabs.Legacy:AddRightGroupbox("Legacy Exploits & Utilities")
 g:AddButton({ Text = "Scan & Apply Cactus Hitbox", DoubleClick = false, Func = function() forceScanCactus() end })
 g:AddButton({ Text = "Scan & Apply CarPole Hitbox", DoubleClick = false, Func = function() forceScanCarPole() end })
end

do
 local g = Tabs.Misc:AddLeftGroupbox("Remove Invisible Walls")
 g:AddToggle("EnableRemoveInvisWalls", { Text = "Remove Invisible Walls", Default = false, Callback = function(state)
 removeInvisWallsEnabled = state
 if state then saveAndRemoveInvisWalls() else restoreInvisWalls() end
 end })
 g:AddButton({ Text = "Refresh Walls", DoubleClick = false, Func = function()
 if removeInvisWallsEnabled then restoreInvisWalls(); saveAndRemoveInvisWalls() else restoreInvisWalls() end
 end })
end

do
 local g = Tabs.Misc:AddLeftGroupbox("Fake Ping (Lag Switch)")
 g:AddToggle("EnableLagSwitchToggle", { Text = "Enable Fake Ping", Default = false, Callback = function(state) LagSwitch.setLag(state) end }):AddKeyPicker("LagSwitchKeyPicker", { Default = "F3", SyncToggleState = true, Mode = "Toggle", Text = "Fake Ping Key" })
 g:AddSlider("MinPingSlider", { Text = "Min Ping (ms)", Min = 0, Max = 5000, Default = 80, Rounding = 0, Callback = function(value) LagSwitch.minPing = value end })
 g:AddSlider("MaxPingSlider", { Text = "Max Ping (ms)", Min = 0, Max = 8000, Default = 300, Rounding = 0, Callback = function(value) LagSwitch.maxPing = value end })
 g:AddSlider("PingUpdateDelay", { Text = "Ping Update Rate (sec)", Min = 0.1, Max = 2.0, Default = 0.5, Rounding = 1, Callback = function(value) LagSwitch.updateDelay = value end })
end
task.spawn(function()
 local backtrackEnabled = false
 local backtrackConnection = nil
 local visualizerModel = nil
 local lastBacktrackTick = 0
 local chamsColor = Color3.fromRGB(0, 255, 255)
 local chamsMaterial = Enum.Material.ForceField
 local chamsTransparency = 0.2
 local minFakePing = 0.1
 local maxFakePing = 0.4
 local currentFakePing = 0.2

 local function updateVisuals()
 if visualizerModel then
 for _, v in pairs(visualizerModel:GetDescendants()) do
 if v:IsA("BasePart") or v:IsA("MeshPart") then
 v.Color = chamsColor
 v.Material = chamsMaterial
 v.Transparency = chamsTransparency
 end
 end
 end
 end

 local function toggleBacktrack(state)
 backtrackEnabled = state
 if state then
 task.spawn(function()
 while backtrackEnabled do
 currentFakePing = minFakePing + (math.random() * (maxFakePing - minFakePing))
 pcall(function() if settings() and settings().Network then settings().Network.IncomingReplicationLag = currentFakePing end end)
 task.wait(0.2)
 end
 end)
 local char = LocalPlayer.Character if not char then return end
 char.Archivable = true
 local clone = char:Clone() clone.Name = "BacktrackChams"
 local fakeHum = clone:FindFirstChildOfClass("Humanoid") if fakeHum then fakeHum:Destroy() end
 for _, v in pairs(clone:GetDescendants()) do
 if v:IsA("BasePart") or v:IsA("MeshPart") then
 v.Anchored = true v.CanCollide = false v.CanTouch = false v.CanQuery = false v.Massless = true
 v.Material = chamsMaterial v.Color = chamsColor v.Transparency = chamsTransparency
 elseif v:IsA("Script") or v:IsA("LocalScript") then v:Destroy()
 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
 end
 clone.Parent = workspace
 visualizerModel = clone
 lastBacktrackTick = tick()
 backtrackConnection = RunService.RenderStepped:Connect(function()
 if not LocalPlayer.Character or not visualizerModel then return end
 if tick() - lastBacktrackTick >= currentFakePing then
 lastBacktrackTick = tick()
 for _, part in pairs(LocalPlayer.Character:GetChildren()) do
 if part:IsA("BasePart") then
 local clonePart = visualizerModel:FindFirstChild(part.Name)
 if clonePart and clonePart:IsA("BasePart") then clonePart.CFrame = part.CFrame end
 end
 end
 end
 end)
 else
 pcall(function() if settings() and settings().Network then settings().Network.IncomingReplicationLag = 0 end end)
 if visualizerModel then visualizerModel:Destroy() visualizerModel = nil end
 if backtrackConnection then backtrackConnection:Disconnect() backtrackConnection = nil end
 end
 end

 do
 local g = Tabs.Misc:AddRightGroupbox("Backtrack & Chams")
 g:AddToggle("EnableBacktrack", { Text = "Enable Backtrack", Default = false, Callback = function(state) toggleBacktrack(state) end }):AddKeyPicker("BacktrackKeyPicker", { Default = "F4", SyncToggleState = true, Mode = "Toggle", Text = "Backtrack Toggle" })
 g:AddSlider("MinFakePingSlider", { Text = "Min Fake Ping (Sec)", Min = 0.0, Max = 2.0, Default = 0.1, Rounding = 2, Callback = function(value) minFakePing = value if minFakePing > maxFakePing then maxFakePing = minFakePing end end })
 g:AddSlider("MaxFakePingSlider", { Text = "Max Fake Ping (Sec)", Min = 0.1, Max = 5.0, Default = 0.4, Rounding = 2, Callback = function(value) maxFakePing = value if maxFakePing < minFakePing then minFakePing = maxFakePing end end })
 g:AddDropdown("BacktrackMaterial", { Values = {"ForceField", "Neon", "Plastic", "SmoothPlastic", "Glass", "Ice"}, Default = 1, Multi = false, Text = "Chams Material", Callback = function(value) chamsMaterial = Enum.Material[value] updateVisuals() end })
 g:AddSlider("BacktrackTransparency", { Text = "Chams Transparency", Min = 0, Max = 1, Default = 0.2, Rounding = 2, Callback = function(value) chamsTransparency = value updateVisuals() end })
 g:AddLabel("Chams Color"):AddColorPicker("BacktrackColorPicker", { Default = Color3.fromRGB(0, 255, 255), Title = "Chams Color", Callback = function(value) chamsColor = value updateVisuals() end })
 end
end)


task.spawn(function()
 local customFovEnabled = false
 local customFovValue = 90
 local fovConnection = nil
 local function onFovStepped()
 if not customFovEnabled then return end
 local cam = workspace.CurrentCamera
 if cam then cam.FieldOfView = customFovValue end
 end
 do
 local g = Tabs.Misc:AddRightGroupbox("First Person FOV")
 g:AddToggle("EnableCustomFOV", { Text = "Enable Custom FOV", Default = false, Callback = function(state)
 customFovEnabled = state
 if state then
 if fovConnection then fovConnection:Disconnect() end
 fovConnection = RunService.RenderStepped:Connect(onFovStepped)
 else
 if fovConnection then fovConnection:Disconnect() fovConnection = nil end
 local cam = workspace.CurrentCamera if cam then cam.FieldOfView = 70 end
 end
 end })
 g:AddSlider("CustomFOVSlider", { Text = "FOV Value", Min = 70, Max = 120, Default = 90, Rounding = 0, Callback = function(value)
 customFovValue = value
 if customFovEnabled then local cam = workspace.CurrentCamera if cam then cam.FieldOfView = customFovValue end end
 end })
 end
end)


do
 local g = Tabs.Misc:AddRightGroupbox("Stats & Level Spoofer")
 g:AddInput("SpoofLevelInput", { Text = "Spoofed Level", Placeholder = "e.g. 100", Numeric = true, Callback = function(v) Spoofer.spoofLevelVal = v end })
 g:AddButton({ Text = "Apply Level", Func = function()
 local n = tonumber(Spoofer.spoofLevelVal)
 if n then Spoofer.targetLevel = n Spoofer.setLevel(n) Library:Notify({ Title = "Spoofer", Description = "Level & TAB updated to " .. n, Time = 3 }) end
 end })
 g:AddButton({ Text = "Reset Level", Func = function() Spoofer.resetLevel() Library:Notify({ Title = "Spoofer", Description = "Level reset to original", Time = 3 }) end })
 g:AddDivider()
 g:AddInput("SpoofTokensInput", { Text = "Tokens", Placeholder = "e.g. 999999", Numeric = true, Callback = function(v) Spoofer.spoofTokensVal = v end })
 g:AddInput("SpoofPointsInput", { Text = "Points", Placeholder = "e.g. 999999", Numeric = true, Callback = function(v) Spoofer.spoofPointsVal = v end })
 g:AddInput("SpoofWinsInput", { Text = "Wins / Survivals", Placeholder = "e.g. 500", Numeric = true, Callback = function(v) Spoofer.spoofWinsVal = v end })
 g:AddButton({ Text = "Apply Stats", Func = function() Spoofer.setStats(Spoofer.spoofTokensVal, Spoofer.spoofPointsVal, Spoofer.spoofWinsVal) Library:Notify({ Title = "Spoofer", Description = "Stats & TAB updated!", Time = 3 }) end })
 g:AddButton({ Text = "Reset Stats", Func = function() Spoofer.resetStats() Library:Notify({ Title = "Spoofer", Description = "Stats reset to original", Time = 3 }) end })
end


task.spawn(function()
 local ESP = {
 Enabled = false, ChamsColor = Color3.fromRGB(255, 0, 0), OutlineColor = Color3.fromRGB(255, 255, 255),
 Transparency = 0.5, TeamCheck = false,
 NextbotsEnabled = false, ItemsEnabled = false, NextbotColor = Color3.fromRGB(255, 165, 0),
 ItemColor = Color3.fromRGB(0, 255, 255),
 CacheUpdate = 0
 }

 RunService.RenderStepped:Connect(function()
 if ESP.NextbotsEnabled or ESP.ItemsEnabled then
 for _, obj in pairs(workspace:GetDescendants()) do
 if ESP.NextbotsEnabled then
 if obj:IsA("Model") and (obj:FindFirstChild("Humanoid") or obj.Name:lower():find("nextbot")) and obj ~= LocalPlayer.Character then
 if not obj:FindFirstChild("NextbotESP") then
 local hl = Instance.new("Highlight")
 hl.Name = "NextbotESP"
 hl.FillColor = ESP.NextbotColor
 hl.FillTransparency = 0.4
 hl.OutlineColor = Color3.fromRGB(255, 255, 255)
 hl.Parent = obj
 end
 end
 else
 if obj:IsA("Model") and obj:FindFirstChild("NextbotESP") then obj.NextbotESP:Destroy() end
 end

if ESP.ItemsEnabled then
 if (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model")) and (obj.Name:lower():find("ticket") or obj.Name:lower():find("item") or obj.Name:lower():find("drop") or obj.Name:lower():find("coin")) then


 local targetVisual = obj

 if obj:IsA("Model") then

 targetVisual = obj:FindFirstChild("Visual")
 or obj:FindFirstChild("Mesh")
 or obj:FindFirstChildOfClass("MeshPart")
 or obj.PrimaryPart
 or obj
 end


 if obj.Name:lower():find("hitbox") and obj.Parent then
 targetVisual = obj.Parent:FindFirstChildOfClass("MeshPart") or obj.Parent
 end

 if targetVisual and not obj:FindFirstChild("ItemESP") then
 local hl = Instance.new("Highlight")
 hl.Name = "ItemESP"
 hl.FillColor = ESP.ItemColor
 hl.FillTransparency = 0.3
 hl.OutlineColor = Color3.fromRGB(255, 255, 255)


 hl.Adornee = targetVisual
 hl.Parent = obj
 end
 end
else
 if (obj:IsA("Part") or obj:IsA("Model")) and obj:FindFirstChild("ItemESP") then
 obj.ItemESP:Destroy()
 end
end
 end
 end
 end)



 do
 local g = Tabs.Visuals:AddLeftGroupbox("Player ESP")
 local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
 local function on(id) local t = Toggles[id] return t ~= nil and t.Value == true end
 local function col(id, d) local o = Options[id] local v = o and o.Value if typeof(v) == "Color3" then return v end return d end
 local function num(id, d) local o = Options[id] local v = o and o.Value if type(v) == "number" then return v end return d end

 g:AddToggle("EnableESP", { Text = "Enable ESP", Default = false })
 g:AddToggle("ESPBox", { Text = "Box", Default = true })
 g:AddLabel("Box Color"):AddColorPicker("ESPBoxColor", { Default = white, Title = "Box Color" })
 g:AddToggle("ESPName", { Text = "Name", Default = true })
 g:AddLabel("Name Color"):AddColorPicker("ESPNameColor", { Default = white, Title = "Name Color" })
 g:AddToggle("ESPHealth", { Text = "Health Bar", Default = true })
 g:AddToggle("ESPDistance", { Text = "Distance", Default = true })
 g:AddToggle("ESPTracer", { Text = "Tracer", Default = false })
 g:AddLabel("Tracer Color"):AddColorPicker("ESPTracerColor", { Default = white, Title = "Tracer Color" })
 g:AddToggle("EnableChams", { Text = "Chams", Default = false })
 g:AddSlider("ESPTransparency", { Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
 g:AddLabel("Chams Fill Color"):AddColorPicker("ESPColor", { Default = Color3.fromRGB(255, 0, 0), Title = "Chams Fill Color" })
 g:AddLabel("Chams Outline Color"):AddColorPicker("ESPOutlineColor", { Default = white, Title = "Chams Outline Color" })
 g:AddToggle("ESPTeamCheck", { Text = "Team Check", Default = false })
 g:AddSlider("ESPMaxDistance", { Text = "Max Distance", Min = 100, Max = 5000, Default = 2000, Rounding = 0 })


 local drawOK = type(Drawing) == "table" and type(Drawing.new) == "function"
 if not drawOK then warn("[ESP] Drawing API missing, only chams will work") end
 local pool, wasOn, warned = {}, false, false

 local function newD(class, props)
  local d = Drawing.new(class)
  for k, v in pairs(props) do d[k] = v end
  return d
 end
 local function makeSet()
  return {
   boxOut = newD("Square", {Thickness = 3, Filled = false, Color = black, Visible = false, ZIndex = 1}),
   box = newD("Square", {Thickness = 1, Filled = false, Visible = false, ZIndex = 2}),
   name = newD("Text", {Size = 13, Center = true, Outline = true, Visible = false, ZIndex = 3}),
   dist = newD("Text", {Size = 12, Center = true, Outline = true, Visible = false, ZIndex = 3}),
   hpBg = newD("Line", {Thickness = 5, Color = black, Visible = false, ZIndex = 1}),
   hp = newD("Line", {Thickness = 3, Visible = false, ZIndex = 2}),
   tracer = newD("Line", {Thickness = 1, Visible = false, ZIndex = 1}),
  }
 end
 local function hideSet(s) for _, o in pairs(s) do o.Visible = false end end
 local function killSet(s) for _, o in pairs(s) do if not pcall(function() o:Remove() end) then pcall(function() o:Destroy() end) end end end
 local function clearChams(char) local h = char and char:FindFirstChild("SW_Chams") if h then h:Destroy() end end

 local function step()
  local cam = workspace.CurrentCamera
  if not on("EnableESP") or not cam then
   if wasOn then
    wasOn = false
    for _, s in pairs(pool) do hideSet(s) end
    for _, p in ipairs(Players:GetPlayers()) do clearChams(p.Character) end
   end
   return
  end
  wasOn = true
  local showBox, showName, showHP, showDist, showTracer = on("ESPBox"), on("ESPName"), on("ESPHealth"), on("ESPDistance"), on("ESPTracer")
  local useChams, teamCheck = on("EnableChams"), on("ESPTeamCheck")
  local boxCol, nameCol, tracerCol = col("ESPBoxColor", white), col("ESPNameColor", white), col("ESPTracerColor", white)
  local chamFill, chamOut, chamAlpha = col("ESPColor", Color3.fromRGB(255, 0, 0)), col("ESPOutlineColor", white), num("ESPTransparency", 0.5)
  local maxDist = num("ESPMaxDistance", 2000)
  local camPos, vp = cam.CFrame.Position, cam.ViewportSize
  local seen = {}
  for _, p in ipairs(Players:GetPlayers()) do
   if p ~= LocalPlayer then
    seen[p] = true
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local dist = hrp and (hrp.Position - camPos).Magnitude or math.huge
    local pass = hum ~= nil and hrp ~= nil and hum.Health > 0 and dist <= maxDist
     and not (teamCheck and p.Team ~= nil and p.Team == LocalPlayer.Team)
    local s = pool[p]
    if pass then
     if useChams then
      local h = char:FindFirstChild("SW_Chams")
      if not h then h = Instance.new("Highlight") h.Name = "SW_Chams" h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop h.Parent = char end
      h.FillColor, h.OutlineColor, h.FillTransparency, h.OutlineTransparency = chamFill, chamOut, chamAlpha, 0
     else
      clearChams(char)
     end
     if drawOK then
      s = s or makeSet()
      pool[p] = s
      local cf, size = char:GetBoundingBox()
      local up = Vector3.new(0, size.Y / 2, 0)
      local top = cam:WorldToViewportPoint(cf.Position + up)
      local bot = cam:WorldToViewportPoint(cf.Position - up)
      local h = bot.Y - top.Y
      if top.Z > 0 and bot.Z > 0 and h == h and h > 2 and h < 6000 then
       local w = h * 0.55
       local cx = (top.X + bot.X) / 2
       local x, y = cx - w / 2, top.Y
       s.boxOut.Visible, s.box.Visible = showBox, showBox
       if showBox then
        s.boxOut.Position, s.boxOut.Size = Vector2.new(x, y), Vector2.new(w, h)
        s.box.Position, s.box.Size, s.box.Color = Vector2.new(x, y), Vector2.new(w, h), boxCol
       end
       s.name.Visible = showName
       if showName then
        s.name.Text = (p.DisplayName ~= "" and p.DisplayName) or p.Name
        s.name.Position, s.name.Color = Vector2.new(cx, y - 16), nameCol
       end
       s.dist.Visible = showDist
       if showDist then
        s.dist.Text = string.format("[%d]", math.floor(dist + 0.5))
        s.dist.Position, s.dist.Color = Vector2.new(cx, y + h + 2), white
       end
       s.hpBg.Visible, s.hp.Visible = showHP, showHP
       if showHP then
        local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local bx = x - 6
        s.hpBg.From, s.hpBg.To = Vector2.new(bx, y - 1), Vector2.new(bx, y + h + 1)
        s.hp.From, s.hp.To = Vector2.new(bx, y + h), Vector2.new(bx, y + h - h * ratio)
        s.hp.Color = Color3.new(1 - ratio, ratio, 0)
       end
       s.tracer.Visible = showTracer
       if showTracer then
        s.tracer.From, s.tracer.To, s.tracer.Color = Vector2.new(vp.X / 2, vp.Y), Vector2.new(cx, y + h), tracerCol
       end
      else
       hideSet(s)
      end
     end
    else
     if s then hideSet(s) end
     if char then clearChams(char) end
    end
   end
  end
  for p, s in pairs(pool) do
   if not seen[p] then killSet(s) pool[p] = nil end
  end
 end

 local espConn = RunService.RenderStepped:Connect(function()
  local ok, err = pcall(step)
  if not ok and not warned then warned = true warn("[ESP] " .. tostring(err)) end
 end)
 Library:OnUnload(function()
  espConn:Disconnect()
  for _, s in pairs(pool) do killSet(s) end
  table.clear(pool)
  for _, p in ipairs(Players:GetPlayers()) do clearChams(p.Character) end
 end)


 local pg = Tabs.Visuals:AddRightGroupbox("ESP Preview")
 local panel = pg:AddCustomFrame(214)
 panel.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
 panel.ClipsDescendants = true
 local z0 = panel.ZIndex
 local BODY = Color3.fromRGB(84, 86, 96)
 local function rect(name, ax, ay, px, py, w, h, color, z)
  local f = Instance.new("Frame")
  f.Name = name
  f.AnchorPoint = Vector2.new(ax, ay)
  f.Position = UDim2.new(0.5, px, 0, py)
  f.Size = UDim2.fromOffset(w, h)
  f.BackgroundColor3 = color
  f.BorderSizePixel = 0
  f.ZIndex = z0 + z
  f.Parent = panel
  return f
 end
 local limbs = {}
 local function limb(x, y, w, h, round)
  local f = rect("limb", 0.5, 0, x, y, w, h, BODY, 1)
  if round then local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = f end
  local st = Instance.new("UIStroke") st.Thickness = 1.5 st.Enabled = false st.Parent = f
  limbs[#limbs + 1] = {f = f, s = st}
 end
 limb(0, 38, 24, 24, true)
 limb(0, 64, 40, 50)
 limb(-27, 64, 12, 46) limb(27, 64, 12, 46)
 limb(-10, 116, 18, 52) limb(10, 116, 18, 52)
 local function hollow(name, w, h, thick, z)
  local f = rect(name, 0.5, 0, 0, 32, w, h, black, z)
  f.BackgroundTransparency = 1
  local st = Instance.new("UIStroke") st.Thickness = thick st.Parent = f
  return f, st
 end
 local boxOutF, boxOutS = hollow("boxOut", 82, 142, 3, 2)
 boxOutS.Color = black
 local boxF, boxS = hollow("box", 80, 142, 1, 3)
 local hpBg = rect("hpBg", 0.5, 0, -46, 31, 5, 144, black, 2)
 local hpFill = rect("hp", 0.5, 1, -46, 174, 3, 100, Color3.new(0.3, 0.7, 0), 3)
 local tracerF = rect("tracer", 0.5, 0, 0, 174, 1, 40, white, 1)
 local function label(name, y, size, text)
  local l = Instance.new("TextLabel")
  l.Name = name
  l.AnchorPoint = Vector2.new(0.5, 0)
  l.Position = UDim2.new(0.5, 0, 0, y)
  l.Size = UDim2.new(1, 0, 0, 14)
  l.BackgroundTransparency = 1
  l.Font = Enum.Font.GothamMedium
  l.TextSize = size
  l.TextStrokeTransparency = 0.4
  l.TextColor3 = white
  l.Text = text
  l.ZIndex = z0 + 3
  l.Parent = panel
  return l
 end
 local nameL = label("name", 15, 12, "Player")
 local distL = label("dist", 177, 11, "[42]")
 local PREVIEW_IMAGE = "fateware_preview.png"
  do
   local B64 = [=[
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
]=]
   local ok, err = pcall(function()
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, #alphabet do map[alphabet:byte(i)] = i - 1 end
    local s = B64:gsub("%s", "")
    local parts = {}
    for i = 1, #s, 4 do
     local c1, c2, c3, c4 = s:byte(i, i + 3)
     local v = map[c1] * 262144 + map[c2] * 4096 + (map[c3] or 0) * 64 + (map[c4] or 0)
     local b1, b2, b3 = math.floor(v / 65536), math.floor(v / 256) % 256, v % 256
     if c3 == 61 then parts[#parts + 1] = string.char(b1)
     elseif c4 == 61 then parts[#parts + 1] = string.char(b1, b2)
     else parts[#parts + 1] = string.char(b1, b2, b3) end
    end
    local bytes = table.concat(parts)
    assert(#bytes == 28796, "PNG length mismatch: " .. #bytes)
    assert(bytes:sub(1, 8) == "\137PNG\r\n\26\n", "bad PNG signature")
    local crcT = {}
    for i = 0, 255 do
     local c = i
     for _ = 1, 8 do
      if bit32.band(c, 1) == 1 then c = bit32.bxor(bit32.rshift(c, 1), 0xEDB88320) else c = bit32.rshift(c, 1) end
     end
     crcT[i] = c
    end
    local crc = 0xFFFFFFFF
    for i = 1, #bytes do crc = bit32.bxor(crcT[bit32.band(bit32.bxor(crc, bytes:byte(i)), 255)], bit32.rshift(crc, 8)) end
    crc = bit32.bxor(crc, 0xFFFFFFFF)
    assert(crc == 0xB8DFC1CC, "PNG crc mismatch: " .. string.format("%08X", crc))
    writefile(PREVIEW_IMAGE, bytes)
   end)
   if not ok then warn("[ESP Preview] could not write embedded image: " .. tostring(err)) end
  end
  local previewImg
  do
   local okF, exists = pcall(function() return isfile and getcustomasset and isfile(PREVIEW_IMAGE) end)
   if okF and exists then
    local okA, asset = pcall(getcustomasset, PREVIEW_IMAGE)
    if okA and type(asset) == "string" and asset ~= "" then
     previewImg = Instance.new("ImageLabel")
     previewImg.Name = "previewImage"
     previewImg.AnchorPoint = Vector2.new(0.5, 0)
     previewImg.Position = UDim2.new(0.5, 0, 0, 32)
     previewImg.Size = UDim2.fromOffset(80, 142)
     previewImg.BackgroundTransparency = 1
     previewImg.BorderSizePixel = 0
     previewImg.Image = asset
     previewImg.ScaleType = Enum.ScaleType.Fit
     previewImg.ZIndex = z0 + 1
     previewImg.Parent = panel

     previewImg.Size = UDim2.fromOffset(114, 142)
     boxOutF.Size = UDim2.fromOffset(116, 142)
     boxF.Size = UDim2.fromOffset(114, 142)
     hpBg.Position = UDim2.new(0.5, -64, 0, 31)
     hpFill.Position = UDim2.new(0.5, -64, 0, 174)
     for _, l in ipairs(limbs) do l.f.Visible = false end
    else
     warn("[ESP Preview] getcustomasset failed for " .. PREVIEW_IMAGE .. ": " .. tostring(asset) .. " (built-in figure kept)")
    end
   else
    warn("[ESP Preview] " .. PREVIEW_IMAGE .. " not found in workspace or isfile/getcustomasset unavailable (built-in figure kept)")
   end
  end
  local previewConn = RunService.RenderStepped:Connect(function()
  if not panel.Parent or not panel.Visible then return end
   if previewImg then
    local chamsOn = on("EnableChams")
    previewImg.ImageColor3 = chamsOn and col("ESPColor", Color3.fromRGB(255, 0, 0)) or white
    previewImg.ImageTransparency = chamsOn and num("ESPTransparency", 0.5) or 0
   end
  local showBox = on("ESPBox")
  boxOutF.Visible, boxF.Visible = showBox, showBox
  boxS.Color = col("ESPBoxColor", white)
  nameL.Visible = on("ESPName")
  nameL.TextColor3 = col("ESPNameColor", white)
  local hp = on("ESPHealth")
  hpBg.Visible, hpFill.Visible = hp, hp
  distL.Visible = on("ESPDistance")
  tracerF.Visible = on("ESPTracer")
  tracerF.BackgroundColor3 = col("ESPTracerColor", white)
  local chams = on("EnableChams")
  local fillC, fillT, outC = col("ESPColor", Color3.fromRGB(255, 0, 0)), num("ESPTransparency", 0.5), col("ESPOutlineColor", white)
  for _, l in ipairs(limbs) do
   l.f.BackgroundColor3 = chams and fillC or BODY
   l.f.BackgroundTransparency = chams and fillT or 0
   l.s.Enabled = chams
   l.s.Color = outC
  end
 end)
 Library:OnUnload(function() previewConn:Disconnect() end)
 end

 do
 local g = Tabs.Visuals:AddRightGroupbox("Entities & Items")
 g:AddToggle("EnableNextbotsESP", { Text = "Nextbots ESP", Default = false, Callback = function(state) ESP.NextbotsEnabled = state if not state then for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("NextbotESP") then obj.NextbotESP:Destroy() end end end end })
 g:AddToggle("EnableItemsESP", { Text = "Tickets / Items ESP", Default = false, Callback = function(state) ESP.ItemsEnabled = state if not state then for _, obj in pairs(workspace:GetDescendants()) do if (obj:IsA("Part") or obj:IsA("Model")) and obj:FindFirstChild("ItemESP") then obj.ItemESP:Destroy() end end end end })
 g:AddLabel("Nextbot Color"):AddColorPicker("NextbotColorPicker", { Default = Color3.fromRGB(255, 165, 0), Callback = function(val) ESP.NextbotColor = val end })
 g:AddLabel("Item Color"):AddColorPicker("ItemColorPicker", { Default = Color3.fromRGB(0, 255, 255), Callback = function(val) ESP.ItemColor = val end })
 end
end)


task.spawn(function()
 local InfSlide = { Enabled = false, Multiplier = 1.05 }
 RunService.Heartbeat:Connect(function()
 if not InfSlide.Enabled then return end
 local character = LocalPlayer.Character if not character then return end
 local humanoid = character:FindFirstChildOfClass("Humanoid")
 local rootPart = character:FindFirstChild("HumanoidRootPart")
 if not humanoid or not rootPart then return end
 if humanoid:GetState() == Enum.HumanoidStateType.Sliding or humanoid.PlatformStand then
 local velocity = rootPart.AssemblyLinearVelocity
 rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X * InfSlide.Multiplier, velocity.Y, velocity.Z * InfSlide.Multiplier)
 end
 end)

 local MovementTab = Tabs.Movement or Window:AddTab("Movement", "activity")
 do
 local g = MovementTab:AddLeftGroupbox("Slide Modifications")
 g:AddToggle("EnableInfSlide", { Text = "Infinite Slide", Default = false, Callback = function(state) InfSlide.Enabled = state end })
 g:AddSlider("SlideBoost", { Text = "Slide Speed Multiplier", Min = 1.0, Max = 1.5, Default = 1.05, Rounding = 2, Callback = function(value) InfSlide.Multiplier = value end })
 end
end)


task.spawn(function()
 local noclipEnabled = false
 local noclipConnection = nil
 local customCamEnabled = false
 local customCamDistance = 12
 local previousCamDistance = 0.5

 local function onNoclipStepped()
 if not noclipEnabled then return end
 local char = LocalPlayer.Character
 if char then
 for _, part in ipairs(char:GetDescendants()) do
 if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
 end
 end
 end

 local function toggleNoclip(state)
 noclipEnabled = state
 if state then
 if noclipConnection then noclipConnection:Disconnect() end
 noclipConnection = RunService.Stepped:Connect(onNoclipStepped)
 else
 if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
 end
 end

 do
 local g = Tabs.Misc:AddRightGroupbox("Noclip & Camera Settings")
 g:AddToggle("EnableNoclip", { Text = "Enable Noclip", Default = false, Callback = function(state) toggleNoclip(state) end }):AddKeyPicker("NoclipKeyPicker", { Default = "N", SyncToggleState = true, Mode = "Toggle", Text = "Noclip Toggle" })
 g:AddDivider()
 g:AddToggle("EnableCustomCamDist", { Text = "Lock Camera Distance", Default = false, Callback = function(state)
 customCamEnabled = state
 if state then
 pcall(function()
 local cam = workspace.CurrentCamera
 if cam then previousCamDistance = (cam.CFrame.Position - cam.Focus.Position).Magnitude end
 LocalPlayer.CameraMinZoomDistance = customCamDistance
 LocalPlayer.CameraMaxZoomDistance = customCamDistance
 end)
 else
 pcall(function()
 LocalPlayer.CameraMinZoomDistance = previousCamDistance
 LocalPlayer.CameraMaxZoomDistance = previousCamDistance
 task.defer(function()
 LocalPlayer.CameraMinZoomDistance = 0.5
 LocalPlayer.CameraMaxZoomDistance = 400
 end)
 end)
 end
 end }):AddKeyPicker("ThirdPersonKeyPicker", { Default = "V", SyncToggleState = true, Mode = "Toggle", Text = "Third Person Toggle" })

 g:AddSlider("ThirdPersonDistance", { Text = "Third Person Distance", Min = 2, Max = 100, Default = 12, Rounding = 1, Callback = function(value)
 customCamDistance = value
 if customCamEnabled then
 pcall(function() LocalPlayer.CameraMinZoomDistance = customCamDistance LocalPlayer.CameraMaxZoomDistance = customCamDistance end)
 end
 end })
 end
end)


task.spawn(function()
 local airJumpEnabled = false
 local keysPressed = {}

 local function checkAirJumpCombo()
 if not airJumpEnabled then return end


 local hasW = keysPressed[Enum.KeyCode.W] or false
 local hasC = keysPressed[Enum.KeyCode.C] or false
 local hasSpace = keysPressed[Enum.KeyCode.Space] or false
 local hasMouse1 = keysPressed["MouseButton1"] or false


 if hasW and hasC and hasSpace and hasMouse1 then
 local char = LocalPlayer.Character
 local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
 if humanoid then
 humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
 end
 end
 end


 UserInputService.InputBegan:Connect(function(input, gameProcessed)
 if gameProcessed then return end

 if input.KeyCode == Enum.KeyCode.W then
 keysPressed[Enum.KeyCode.W] = true
 elseif input.KeyCode == Enum.KeyCode.C then
 keysPressed[Enum.KeyCode.C] = true
 elseif input.KeyCode == Enum.KeyCode.Space then
 keysPressed[Enum.KeyCode.Space] = true
 elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
 keysPressed["MouseButton1"] = true
 end

 checkAirJumpCombo()
 end)


 UserInputService.InputEnded:Connect(function(input, gameProcessed)
 if input.KeyCode == Enum.KeyCode.W then
 keysPressed[Enum.KeyCode.W] = false
 elseif input.KeyCode == Enum.KeyCode.C then
 keysPressed[Enum.KeyCode.C] = false
 elseif input.KeyCode == Enum.KeyCode.Space then
 keysPressed[Enum.KeyCode.Space] = false
 elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
 keysPressed["MouseButton1"] = false
 end
 end)

 UserInputService.JumpRequest:Connect(onJumpRequest)

 local function tpToDowned()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local gameFolder = workspace:FindFirstChild("Game")
 local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
 if hrp and playersFolder then
 for _, v in ipairs(playersFolder:GetChildren()) do
 if v:GetAttribute("Downed") then
 local targetHrp = v:FindFirstChild("HumanoidRootPart")
 if targetHrp then hrp.CFrame = targetHrp.CFrame break end
 end
 end
 end
 end

 local function teleportToLookDirection()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local camera = workspace.CurrentCamera
 if not hrp or not camera then return end
 local lookVector = camera.CFrame.LookVector
 local teleportDistance = 100
 local raycastParams = RaycastParams.new()
 raycastParams.FilterDescendantsInstances = {char}
 raycastParams.FilterType = Enum.RaycastFilterType.Exclude
 local raycastResult = workspace:Raycast(camera.CFrame.Position, lookVector * teleportDistance, raycastParams)
 local targetPosition = camera.CFrame.Position + (lookVector * teleportDistance)
 if raycastResult then targetPosition = raycastResult.Position - (lookVector * 2) end
 hrp.CFrame = CFrame.new(targetPosition)
 end

 local function doServerHop()
 local placeId = game.PlaceId
 local jobId = game.JobId

 local success, rawData = pcall(function()
 return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
 end)

 if success and rawData then
 local decodeSuccess, body = pcall(function()
 return HttpService:JSONDecode(rawData)
 end)

 if decodeSuccess and body and body.data then
 for _, v in ipairs(body.data) do
 if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) then
 if v.playing < v.maxPlayers and v.id ~= jobId then
 TeleportService:TeleportToPlaceInstance(placeId, v.id, LocalPlayer)
 return
 end
 end
 end
 end
 end
 end

do
 local g = Tabs.Misc:AddRightGroupbox("Player Utilities")
 g:AddToggle("EnableFastRevive", { Text = "Fast Revive", Default = false, Callback = function(state)
 local gameFolder = workspace:FindFirstChild("Game")
 local settings = gameFolder and gameFolder:FindFirstChild("Settings")
 if settings then settings:SetAttribute("ReviveTime", state and 2.25 or 3) end
 end })
 g:AddToggle("EnableAirJump", {
 Text = "Air Jump",
 Default = false,
 Callback = function(state)
 airJumpEnabled = state
 end
 })
 g:AddButton({ Text = "Teleport to Downed", DoubleClick = false, Func = tpToDowned }):AddKeyPicker("TPDownedKeyPicker", { Default = "None", SyncToggleState = false, Mode = "Press", Text = "Teleport to Downed", Callback = tpToDowned })
 g:AddButton({ Text = "Look Teleport", DoubleClick = false, Func = teleportToLookDirection }):AddKeyPicker("LookTPKeyPicker", { Default = "None", SyncToggleState = false, Mode = "Press", Text = "Look Teleport", Callback = teleportToLookDirection })
 g:AddButton({ Text = "Server Hop", DoubleClick = false, Func = doServerHop })
end
end)


task.spawn(function()
 local AfkFarmEnabled = false
 local AutoItemEnabled = false
 local originalPosition = nil
 local noItemTimer = 0
 local savedAfkState = false
 local savedCollectState = false

 local function isPlayerAsset(instance)
 for _, player in ipairs(Players:GetPlayers()) do
 if instance == player.Character or (player.Character and instance:IsDescendantOf(player.Character)) then return true end
 end
 return false
 end

 local function getAllItems()
 local items = {}
 for _, v in pairs(workspace:GetDescendants()) do
 if (v:IsA("BasePart") or v:IsA("Model")) then
 local nameLower = string.lower(v.Name)
 if string.find(nameLower, "bubble") or string.find(nameLower, "coconut") then
 local isVisualEffect = v:FindFirstChildWhichIsA("ParticleEmitter") or v:FindFirstChildWhichIsA("Trail") or v:FindFirstChildWhichIsA("Beam") or v.ClassName == "Accessory"
 local hasAnimation = v:FindFirstChildWhichIsA("Animation") or v:FindFirstChildWhichIsA("Animator")
 if not isVisualEffect and not hasAnimation and not isPlayerAsset(v) then
 if v.Parent and not isPlayerAsset(v.Parent) then
 local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
 if part and not isPlayerAsset(part) then table.insert(items, part) end
 end
 end
 end
 end
 end
 return items
 end

 local function isNextbotNear(position)
 for _, v in pairs(workspace:GetDescendants()) do
 if v:IsA("Model") and v:GetAttribute("Nextbot") == true then
 local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
 if root then
 local distance = (position - root.Position).Magnitude
 if distance <= 12 then return true end
 end
 end
 end
 return false
 end

 local function getClosestSafeItem(hrp, items)
 local closest, minDst = nil, math.huge
 for _, part in ipairs(items) do
 local dst = (hrp.Position - part.Position).Magnitude
 if dst < minDst and not isNextbotNear(part.Position) then closest = part minDst = dst end
 end
 return closest
 end

 local function teleportTo(hrp, pos, duration)
 local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
 tween:Play() tween.Completed:Wait()
 end

 task.spawn(function()
 while true do
 local items = getAllItems()
 local char = LocalPlayer.Character
 local isDowned = char and char:GetAttribute("Downed")
 local hrp = char and char:FindFirstChild("HumanoidRootPart")

 if #items == 0 then
 noItemTimer = noItemTimer + 0.5
 if noItemTimer >= 20 then
 if AfkFarmEnabled then
 AfkFarmEnabled = false Options.EnableAfkFarm:SetValue(false) if hrp then hrp.Anchored = false end
 end
 end
 else
 if noItemTimer >= 20 and savedAfkState and not isDowned then
 task.wait(1)
 if hrp then
 AfkFarmEnabled = true Options.EnableAfkFarm:SetValue(true)
 originalPosition = hrp.Position + Vector3.new(0, 200, 0) hrp.CFrame = CFrame.new(originalPosition) task.wait(0.1) hrp.Anchored = true
 end
 end
 noItemTimer = 0
 end

 if AutoItemEnabled and not isDowned and #items > 0 then
 if hrp then
 local item = getClosestSafeItem(hrp, items)
 if item then
 local startPos = hrp.Position hrp.Anchored = false
 teleportTo(hrp, item.Position, 0.2)
 pcall(function()
 local collectId = item.Parent:GetAttribute("Id") or item:GetAttribute("Id") or "a19ac91bff904b7385e826fd6a23dc01"
 ReplicatedStorage.Events.Collectibles.Invoke:InvokeServer(LocalPlayer, collectId, "Collect")
 end)
 task.wait(1)
 isDowned = char and char:GetAttribute("Downed")
 if AutoItemEnabled and not isDowned and noItemTimer < 20 then
 if AfkFarmEnabled and originalPosition then teleportTo(hrp, originalPosition, 0.2) hrp.Anchored = true
 else teleportTo(hrp, startPos, 0.2) end
 end
 end
 end
 end
 task.wait(0.5)
 end
 end)

 task.spawn(function()
 while true do
 task.wait(2)
 local char = LocalPlayer.Character
 local isDowned = char and char:GetAttribute("Downed")
 if AfkFarmEnabled and not AutoItemEnabled and not isDowned and noItemTimer < 20 then
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp and hrp.Anchored == false then
 originalPosition = hrp.Position + Vector3.new(0, 200, 0) hrp.CFrame = CFrame.new(originalPosition) task.wait(0.1) hrp.Anchored = true
 end
 end
 end
 end)

 local function setupCharacter(char)
 char:GetAttributeChangedSignal("Downed"):Connect(function()
 local isDowned = char:GetAttribute("Downed")
 local hrp = char:FindFirstChild("HumanoidRootPart")
 if isDowned then
 AutoItemEnabled = false AfkFarmEnabled = false Options.EnableAutoItem:SetValue(false) Options.EnableAfkFarm:SetValue(false) if hrp then hrp.Anchored = false end
 else
 task.wait(1)
 if hrp then
 originalPosition = hrp.Position + Vector3.new(0, 200, 0) hrp.CFrame = CFrame.new(originalPosition) task.wait(0.2) hrp.Anchored = true
 AfkFarmEnabled = savedAfkState AutoItemEnabled = savedCollectState Options.EnableAfkFarm:SetValue(savedAfkState) Options.EnableAutoItem:SetValue(savedCollectState)
 end
 end
 end)
 end

 LocalPlayer.CharacterAdded:Connect(setupCharacter)
 if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

 do
 local g = Tabs.Misc:AddLeftGroupbox("EventPlay / Auto Farm")
 g:AddToggle("EnableAfkFarm", { Text = "AFK Farm", Default = false, Callback = function(state)
 local char = LocalPlayer.Character if (char and char:GetAttribute("Downed")) then return end
 local hrp = char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
 AfkFarmEnabled = state savedAfkState = state
 if AfkFarmEnabled then originalPosition = hrp.Position + Vector3.new(0, 200, 0) hrp.CFrame = CFrame.new(originalPosition) task.wait(0.1) hrp.Anchored = true else hrp.Anchored = false end
 end })

 g:AddToggle("EnableAutoItem", { Text = "Auto Item Collect", Default = false, Callback = function(state)
 local char = LocalPlayer.Character if (char and char:GetAttribute("Downed")) then return end
 AutoItemEnabled = state savedCollectState = state
 end })
 end
end)

fastTurnConnection = nil
fastTurnActive = false
local function runFastTurn()
 if fastTurnActive then return end
 fastTurnActive = true
 local char = LocalPlayer.Character if not char then return end
 local humanoid = char:FindFirstChildOfClass("Humanoid")
 local rootPart = char:FindFirstChild("HumanoidRootPart")
 if not humanoid or not rootPart then return end
 local TURN_SPEED = 22
 humanoid.AutoRotate = false
 if fastTurnConnection then fastTurnConnection:Disconnect() end
 fastTurnConnection = RunService.RenderStepped:Connect(function(dt)
 if not char or not humanoid or not rootPart then return end
 if humanoid.MoveDirection.Magnitude > 0 then
 local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + humanoid.MoveDirection)
 rootPart.CFrame = rootPart.CFrame:lerp(targetCFrame, TURN_SPEED * dt)
 end
 end)
 LocalPlayer.CharacterAdded:Connect(function(newChar)
 fastTurnActive = false
 if fastTurnConnection then fastTurnConnection:Disconnect(); fastTurnConnection = nil end
 end)
end

do
 local g = Tabs.Legacy:AddRightGroupbox("Fast Turn")
 g:AddButton({ Text = "Fast Turn", Func = function() runFastTurn() end })
end

SafeConnect(LocalPlayer.CharacterAdded, function()
 task.wait(1)
 if not feEmoteRunnerActive then pcall(function() feSetupEmoteSpeedChange(true) feSetupTPCameraOnEmoting(true) end) end
end)

do
 local g = Tabs.Emotes:AddLeftGroupbox("FE Change Emote")
 for i = 1, 6 do
 local currentVal = LocalPlayer:GetAttribute("Emote" .. i) or ""
 feEmoteInputs[i] = g:AddInput("FEEmoteSlot" .. i, { Default = currentVal, Text = "Emote Slot " .. i, Placeholder = "e.g. Wave, Dab...", Callback = function(value) fePendingEmotes[i] = value:gsub("%s+", "") end })
 end
 g:AddButton({ Text = "Apply Emotes", Func = function() feApplyAllEmotes() end })
 g:AddButton({ Text = "Reset Emotes", Func = function() feResetAllEmotes() end })
 g:AddToggle("EmoteRunner", { Text = "Emote Runner", Default = false, Callback = function(state)
 feEmoteRunnerActive = state
 if state then feSetupEmoteSpeedChange(false) feSetupTPCameraOnEmoting(false)
 else feSetupEmoteSpeedChange(true) feSetupTPCameraOnEmoting(true) feInstallHook() end
 end })
end


(function()
    local spin = { enabled = false, speed = 360, angle = 0 }
    function spin.restore()
        if spin.hum and spin.hum.Parent then spin.hum.AutoRotate = spin.autoRotate end
        spin.hum, spin.angle = nil, 0
    end
    function spin.step(dt)
        local char = LocalPlayer.Character
        local players = Workspace:FindFirstChild("Game")
        players = players and players:FindFirstChild("Players")
        local model = players and players:FindFirstChild(LocalPlayer.Name)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local velocity = root and root.AssemblyLinearVelocity
        local emoting = (model and model:GetAttribute("Emoting") == true)
            or (char and char:GetAttribute("Emoting") == true)
        local airborne = hum and (hum:GetState() == Enum.HumanoidStateType.Jumping
            or hum:GetState() == Enum.HumanoidStateType.Freefall)
        local moving = velocity and (velocity.X * velocity.X + velocity.Z * velocity.Z > 1)
        if not spin.enabled or not hum or hum.Health <= 0 or not root
            or not emoting or not airborne or not moving then spin.restore() return end
        if spin.hum ~= hum then
            spin.restore()
            spin.hum, spin.autoRotate = hum, hum.AutoRotate
            local _, yaw = root.CFrame:ToOrientation()
            spin.angle = yaw
        end
        hum.AutoRotate = false
        spin.angle = (spin.angle + math.rad(spin.speed) * dt) % (2 * math.pi)
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, spin.angle, 0)
    end
    function spin.setEnabled(value)
        spin.enabled = value
        if spin.connection then spin.connection:Disconnect() spin.connection = nil end
        spin.restore()
        if value then spin.connection = RunService.Heartbeat:Connect(spin.step) end
    end
    local g = Tabs.Emotes:AddRightGroupbox("360 Emote Bhop")
    g:AddToggle("EmoteBhop360", { Text = "360 Emote Bhop", Default = false,
        Callback = spin.setEnabled }):AddKeyPicker("EmoteBhop360Key", {
        Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "360 Emote Bhop" })
    g:AddSlider("EmoteBhop360Speed", { Text = "Rotation Speed (deg/s)", Min = 30,
        Max = 1440, Default = 360, Rounding = 0, Callback = function(v) spin.speed = v end })
    Library:OnUnload(function() spin.setEnabled(false) end)
end)()


do
 local g = Tabs.Nametags:AddLeftGroupbox("Nametags Explorer & Selector")
 g:AddButton({ Text = "Open Nametags Browser GUI", DoubleClick = false, Func = function()
 Nametags.openBrowser(function(name)
 Nametags.selectedNametag = name pcall(function() Options.SelectedNametagInput:SetValue(name) end) Nametags.applyNametag(name)
 end)
 end })
 g:AddInput("SelectedNametagInput", { Default = "", Text = "Selected Nametag", Placeholder = "Search via Browser or type name...", Callback = function(v) Nametags.selectedNametag = v end })
 g:AddButton({ Text = "Apply Selected Nametag", Func = function()
 if Nametags.selectedNametag == "" then Library:Notify({ Title = "Nametags", Description = "Please select a nametag first!", Time = 3 }) return end
 Nametags.applyNametag(Nametags.selectedNametag)
 end })
end


do
 local g = Tabs.Hitbox:AddLeftGroupbox("Mouse Target Hitbox Settings")
 g:AddToggle("EnableCustomHitboxCreation", { Text = "Enable Custom Hitbox Creation", Default = false, Callback = function(state) customHitboxEnabled = state end })
 g:AddButton({ Text = "Clear All Created Hitboxes", DoubleClick = false, Func = function() CustomHitboxFolder:ClearAllChildren() end })
end
do
 local g = Tabs.Hitbox:AddLeftGroupbox("Hitbox Dimensions")
 g:AddSlider("HitboxWidth", { Text = "Hitbox Width", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxWidth = value end })
 g:AddSlider("HitboxHeight", { Text = "Hitbox Height", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxHeight = value end })
 g:AddSlider("HitboxLength", { Text = "Hitbox Length", Min = 1, Max = 6, Default = 4, Rounding = 1, Callback = function(value) customHitboxLength = value end })
end
do
 local g = Tabs.Hitbox:AddRightGroupbox("Hitbox Styling")
 g:AddLabel("Select Hitbox Box Color"):AddColorPicker("HitboxColorPicker", { Default = Color3.fromRGB(255, 0, 0), Title = "Select Hitbox Box Color", Callback = function(color) customHitboxColor = color end })
 g:AddSlider("HitboxTransparency", { Text = "Hitbox Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) customHitboxTransparency = value end })
end
do
 local g = Tabs.Hitbox:AddLeftGroupbox("Hide Players")
 g:AddToggle("HideOtherPlayers", { Text = "Hide Other Players", Default = false, Callback = function(state)
 hideOthersEnabled = state refreshHideOthers()
 if state then
 if hideOthersConn then hideOthersConn:Disconnect() end
 hideOthersConn = game:GetService("Players").PlayerAdded:Connect(function(player)
 if hideOthersEnabled then player.CharacterAdded:Connect(function(char) task.wait(0.5) if hideOthersEnabled then setCharacterVisibility(char, false) end end) end
 end)
 for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
 if player ~= LocalPlayer then player.CharacterAdded:Connect(function(char) task.wait(0.5) if hideOthersEnabled then setCharacterVisibility(char, false) end end) end
 end
 else
 if hideOthersConn then hideOthersConn:Disconnect(); hideOthersConn = nil end
 end
 end })
 g:AddToggle("HideSelfPlayer", { Text = "Hide Myself", Default = false, Callback = function(state)
 hideSelfEnabled = state setCharacterVisibility(LocalPlayer.Character, not state)
 SafeConnect(LocalPlayer.CharacterAdded, function(char) task.wait(0.5) if hideSelfEnabled then setCharacterVisibility(char, false) end end)
 end })
end
do
 local g = Tabs.Hitbox:AddRightGroupbox("Map System")
 g:AddInput("MapIDInput", { Default = "", Text = "Map Asset ID", Placeholder = "e.g. 12345678", Numeric = true, Callback = function(value) mapID = value:gsub("%D", "") end })
 g:AddButton({ Text = "Create Map", DoubleClick = false, Func = function()
 if spawnedMap then spawnedMap:Destroy(); spawnedMap = nil end
 local backup = workspace:FindFirstChild("Sperma_CustomMap") if backup then backup:Destroy() end
 if mapID == "" then return end
 pcall(function()
 local obj = game:GetObjects("rbxassetid://" .. mapID)[1]
 if obj then spawnedMap = obj spawnedMap.Name = "SpermaCustomMap" spawnedMap.Parent = workspace if spawnedMap:IsA("Model") then spawnedMap:MoveTo(Vector3.new(0, 2500, 0)) end end
 end)
 end })
 g:AddButton({ Text = "Teleport to Map", DoubleClick = false, Func = function() if spawnedMap and LocalPlayer.Character then LocalPlayer.Character:MoveTo(Vector3.new(0, 2515, 0)) end end })
 g:AddButton({ Text = "Delete Map", DoubleClick = false, Func = function()
 if spawnedMap then spawnedMap:Destroy(); spawnedMap = nil else local backup = workspace:FindFirstChild("Sperma_CustomMap") if backup then backup:Destroy() end end
 end })
end

SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
 if gameProcessed then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 and customHitboxEnabled then
 if Mouse.Target and Mouse.Hit then
 local targetObj = Mouse.Target
 if not targetObj:IsDescendantOf(CustomHitboxFolder) then
 pcall(function()
 local exactClickPos = Mouse.Hit.Position
 local surfaceNormal = Vector3.FromNormalId(Mouse.TargetSurface)
 local spawnCFrame = CFrame.new(exactClickPos + (surfaceNormal * (customHitboxHeight / 2)))
 local newHitbox = Instance.new("Part")
 newHitbox.Name = "SpermaCreated_Hitbox"
 newHitbox.Size = Vector3.new(customHitboxWidth, customHitboxHeight, customHitboxLength)
 newHitbox.CFrame = spawnCFrame
 newHitbox.Transparency = customHitboxTransparency
 newHitbox.Color = customHitboxColor
 newHitbox.Material = Enum.Material.Neon
 newHitbox.Anchored = true
 newHitbox.CanCollide = true
 newHitbox.CustomPhysicalProperties = NO_FRICTION_PHYSICS
 newHitbox.Parent = CustomHitboxFolder
 end)
 end
 end
 end
end)


do
 local g = Tabs.Visuals:AddLeftGroupbox("Avatar Body Enhancements")
 g:AddToggle("EnableHeadlessHead", { Text = "Enable Headless Head", Default = false, Callback = function(state) headlessEnabled = state if state and LocalPlayer.Character then applyHeadless(LocalPlayer.Character) end end })
 g:AddToggle("EnableKorbloxRightLeg", { Text = "Enable Korblox Right Leg", Default = false, Callback = function(state) korbloxEnabled = state if state and LocalPlayer.Character then applyKorblox(LocalPlayer.Character) end end })
end
do
 local g = Tabs.Visuals:AddLeftGroupbox("Client Cosmetic Replacer")
 g:AddInput("CurrentOwnedItemName", { Default = "", Text = "Current Owned Item Name", Placeholder = "Owned item...", Callback = function(v) cosmetic1 = v end })
 g:AddInput("TargetSwapItemName", { Default = "", Text = "Target Swap Item Name", Placeholder = "Desired item...", Callback = function(v) cosmetic2 = v end })
 g:AddButton({ Text = "Execute Cosmetic Replacement (Apply)", Func = function() applyCosmetics() end })
 g:AddButton({ Text = "Reset Cosmetic & Restore Original", Func = function()
 resetCosmetics()
 pcall(function() Options.CurrentOwnedItemName:SetValue("") end)
 pcall(function() Options.TargetSwapItemName:SetValue("") end)
 end })
end
do
 local g = Tabs.Lighting:AddLeftGroupbox("Global Color")
 g:AddLabel("Pick Global Color"):AddColorPicker("GlobalColorPicker", { Default = Color3.fromRGB(255, 255, 255), Title = "Pick Global Color", Callback = function(color) globalColorValue = color end })
 g:AddButton({ Text = "Apply Global Color", Func = function() applyGlobalColor(globalColorValue) end })
 g:AddButton({ Text = "Random Color", Func = function() applyRandomColor() end })
 g:AddButton({ Text = "Reset to Original Colors", Func = function() resetGlobalColor() end })
end



do
 local g = Tabs.Emotes:AddRightGroupbox("12 Owned Emotes & 12 Target Emotes")
 for i = 1, 12 do
 g:AddInput("EmoteSlotGoc_"..i, { Default = "", Text = string.format("Slot %02d [own]", i), Placeholder = "name emote...", Callback = function(v) currentEmotes[i] = v:gsub("%s+", "") end })
 g:AddInput("EmoteSlotTrao_"..i, { Default = "", Text = string.format("Slot %02d [want to swap]", i), Placeholder = "name emote swap...", Callback = function(v) selectEmotes[i] = v:gsub("%s+", "") end })
 end
end
do
 local g = Tabs.Emotes:AddRightGroupbox("Emote Remap Action Buttons")
 g:AddButton({ Text = "Apply Emotes Remap System", Func = function()
 for i = 1, 12 do if currentEmotes[i] ~= "" and selectEmotes[i] ~= "" then emoteEnabled[i] = true else emoteEnabled[i] = false end end
 end })
 g:AddButton({ Text = "Reset All Emote Slots to Default", Func = function()
 for i = 1, 12 do
 currentEmotes[i] = "" selectEmotes[i] = "" emoteEnabled[i] = false
 pcall(function() Options["EmoteSlotGoc_"..i]:SetValue("") end)
 pcall(function() Options["EmoteSlotTrao_"..i]:SetValue("") end)
 end
 end })
end


local lightingOriginals = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient }
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local atmosphereOriginals = atmosphere and { Density = atmosphere.Density, Offset = atmosphere.Offset, Color = atmosphere.Color, Decay = atmosphere.Decay, Haze = atmosphere.Haze } or nil
local sunRaysEffect = Lighting:FindFirstChild("SpermaSunRays")
if not sunRaysEffect then
 sunRaysEffect = Instance.new("SunRaysEffect")
 sunRaysEffect.Name = "SpermaSunRays"
 sunRaysEffect.Enabled = false
 sunRaysEffect.Intensity = 0.5
 sunRaysEffect.Spread = 0.5
 sunRaysEffect.Parent = Lighting
end
local colorCorrection = Lighting:FindFirstChild("SpermaColorCorrection")
if not colorCorrection then
 colorCorrection = Instance.new("ColorCorrectionEffect")
 colorCorrection.Name = "SpermaColorCorrection"
 colorCorrection.Parent = Lighting
end
local originalSky = Lighting:FindFirstChildOfClass("Sky")
local customSkyModelID = ""
local customSkyModelObj = nil
local customImageSkyID = ""

local function getOrCreateAtmosphere()
 if not atmosphere or not atmosphere.Parent then atmosphere = Instance.new("Atmosphere") atmosphere.Parent = Lighting end
 return atmosphere
end
local function applyCustomSkyModel()
 if customSkyModelID == "" then return end
 if originalSky then originalSky.Parent = nil end
 if customSkyModelObj then customSkyModelObj:Destroy(); customSkyModelObj = nil end
 pcall(function()
 local id = customSkyModelID:match("%d+") or customSkyModelID
 local assets = game:GetObjects("rbxassetid://" .. id)
 if assets and assets[1] and assets[1]:IsA("Sky") then
 customSkyModelObj = assets[1]
 customSkyModelObj.Name = "SpermaCustomSky"
 customSkyModelObj.Parent = Lighting
 end
 end)
end
local function applyImageSky()
 if customImageSkyID == "" then return end
 local assetId = "rbxassetid://" .. customImageSkyID
 local sky = Lighting:FindFirstChildOfClass("Sky")
 if not sky then sky = Instance.new("Sky") sky.Name = "SpermaImageSky" sky.Parent = Lighting end
 sky.SkyboxBk = assetId sky.SkyboxDn = assetId sky.SkyboxFt = assetId sky.SkyboxLf = assetId sky.SkyboxRt = assetId sky.SkyboxUp = assetId
end
local function resetSky()
 if customSkyModelObj then customSkyModelObj:Destroy(); customSkyModelObj = nil end
 local argoSky = Lighting:FindFirstChild("SpermaCustomSky") if argoSky then argoSky:Destroy() end
 local argoImg = Lighting:FindFirstChild("SpermaImageSky") if argoImg then argoImg:Destroy() end
 if originalSky then originalSky.Parent = Lighting end
end
local function resetLighting()
 Lighting.Brightness = lightingOriginals.Brightness
 Lighting.ClockTime = lightingOriginals.ClockTime
 Lighting.Ambient = lightingOriginals.Ambient
 Lighting.OutdoorAmbient = lightingOriginals.OutdoorAmbient
 colorCorrection.Brightness = 0 colorCorrection.Contrast = 0 colorCorrection.Saturation = 0 colorCorrection.TintColor = Color3.new(1, 1, 1)
 sunRaysEffect.Enabled = false
 if atmosphere and atmosphereOriginals then
 atmosphere.Density = atmosphereOriginals.Density atmosphere.Offset = atmosphereOriginals.Offset atmosphere.Color = atmosphereOriginals.Color atmosphere.Decay = atmosphereOriginals.Decay atmosphere.Haze = atmosphereOriginals.Haze
 end
 resetSky()
end

do
 local g = Tabs.Lighting:AddLeftGroupbox("Lighting Controls")
 g:AddSlider("LightBrightness", { Text = "Brightness", Min = 0, Max = 10, Default = math.floor(Lighting.Brightness * 10 + 0.5) / 10, Rounding = 1, Callback = function(value) Lighting.Brightness = value end })
 g:AddSlider("LightSaturation", { Text = "Saturation", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Saturation = value end })
 g:AddSlider("LightContrast", { Text = "Contrast", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Contrast = value end })
 g:AddSlider("LightExposure", { Text = "Exposure", Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(value) colorCorrection.Brightness = value end })
 g:AddSlider("LightClockTime", { Text = "Time of Day", Min = 0, Max = 24, Default = Lighting.ClockTime, Rounding = 1, Callback = function(value) Lighting.ClockTime = value end })
 g:AddButton({ Text = "Reset Lighting to Original", Func = function() resetLighting() end })
end

do
 local g = Tabs.Lighting:AddLeftGroupbox("Sun Rays")
 g:AddToggle("EnableSunRays", { Text = "Enable Sun Rays", Default = false, Callback = function(state) sunRaysEffect.Enabled = state end })
 g:AddSlider("SunRaysIntensity", { Text = "Intensity", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) sunRaysEffect.Intensity = value end })
 g:AddSlider("SunRaysSpread", { Text = "Spread", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Callback = function(value) sunRaysEffect.Spread = value end })
end

do
 local g = Tabs.Lighting:AddLeftGroupbox("Fog & Sky Temperature")
 g:AddSlider("AtmoFogDensity", { Text = "Fog Density", Min = 0, Max = 1, Default = atmosphere and atmosphere.Density or 0, Rounding = 2, Callback = function(value) getOrCreateAtmosphere().Density = value end })
 g:AddLabel("Fog Color"):AddColorPicker("AtmoFogColor", { Default = atmosphere and atmosphere.Color or Color3.fromRGB(199, 199, 199), Title = "Fog Color", Callback = function(color) getOrCreateAtmosphere().Color = color end })
 g:AddSlider("AtmoHaze", { Text = "Sky Temperature (Haze)", Min = 0, Max = 10, Default = atmosphere and atmosphere.Haze or 0, Rounding = 1, Callback = function(value) getOrCreateAtmosphere().Haze = value end })
 g:AddLabel("Sky Tint (Warm = orange/red, Cool = blue)"):AddColorPicker("AtmoDecay", { Default = atmosphere and atmosphere.Decay or Color3.fromRGB(255, 100, 30), Title = "Sky Tint Color", Callback = function(color) getOrCreateAtmosphere().Decay = color end })
end

do
 local g = Tabs.Lighting:AddRightGroupbox("Sky Box (Model ID)")
 g:AddInput("SkyboxModelIDInput", { Default = "", Text = "Sky Object ID", Placeholder = "Model ID from Toolbox", Numeric = true, Callback = function(value) customSkyModelID = value:gsub("%D", "") end })
 g:AddButton({ Text = "Apply Sky", Func = function() applyCustomSkyModel() end })
 g:AddButton({ Text = "Reset Sky", Func = function() resetSky() end })
end

do
 local g = Tabs.Lighting:AddRightGroupbox("Sky Box (Image ID)")
 g:AddInput("SkyImageIDInput", { Default = "", Text = "Image Asset ID", Placeholder = "e.g. 123280270736635", Numeric = true, Callback = function(value) customImageSkyID = value:gsub("%D", "") end })
 g:AddButton({ Text = "Apply Image Sky", Func = function() applyImageSky() end })
 g:AddButton({ Text = "Reset Sky", Func = function() resetSky() end })
end




;(function()
    local function new(class, props, parent)
        local obj = Instance.new(class)
        for key, value in pairs(props or {}) do obj[key] = value end
        obj.Parent = parent
        return obj
    end
    local worldFolder = new("Folder", {Name = "Z-xWeather"}, Workspace)
    local Assets = {Rain = "rbxassetid://241868005", Snow = "rbxassetid://99851851", Ember = "rbxassetid://242205518", Petal = "", Glow = ""}
    local SOFT = "rbxasset://textures/particles/smoke_main.dds"
    local GLYPHS = "01234567890123456789アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワン+-*=<>:"
    local WEATHER = {
        Rain = {
            Texture = Assets.Rain, Rate = 450, Speed = {80, 100}, Life = 1.0,
            Size = {7, 10}, Box = Vector3.new(110, 1, 110), Orient = Enum.ParticleOrientation.VelocityParallel,
            Spread = Vector2.new(1, 1), T = 0.5, FadeIn = 0.05, FadeOut = 0.9,
            Colors = {Color3.fromRGB(190, 210, 245)}, Light = 0,
        },
        Snow = {
            Texture = Assets.Snow, Rate = 200, Speed = {7, 12}, Life = 9,
            Size = {0.3, 0.9}, Box = Vector3.new(110, 1, 110), Spin = 60,
            Spread = Vector2.new(12, 12), T = 0.25, FadeIn = 0.08, FadeOut = 0.9,
            Colors = {Color3.new(1, 1, 1)}, Light = 0,
        },
        Ember = {
            Texture = Assets.Ember, Rate = 110, Speed = {6, 14}, Life = 4, Rise = true,
            Size = {0.5, 1.5}, Box = Vector3.new(60, 1, 60), Spin = 140, Shrink = true,
            Spread = Vector2.new(25, 25), T = 0.15, FadeIn = 0.1, FadeOut = 0.55,
            Colors = {Color3.fromRGB(255, 190, 70), Color3.fromRGB(255, 70, 20)}, Light = 0.8,
        },
        Sakura = {
            Texture = (Assets.Petal ~= "") and Assets.Petal or SOFT, Rate = 45, Speed = {3, 6}, Life = 10,
            Size = {0.35, 0.7}, Box = Vector3.new(100, 1, 100), Spin = 90,
            Spread = Vector2.new(25, 25), T = 0.2, FadeIn = 0.08, FadeOut = 0.9,
            Colors = {Color3.fromRGB(255, 205, 220), Color3.fromRGB(255, 140, 180)}, Light = 0.15,
        },
        Fireflies = {
            Texture = (Assets.Glow ~= "") and Assets.Glow or SOFT, Rate = 14, Speed = {0.3, 1.6}, Life = 7,
            Size = {0.5, 1.2}, Box = Vector3.new(70, 22, 70), Wander = true,
            Spread = Vector2.new(180, 180), T = 0.12, FadeIn = 0.3, FadeOut = 0.7,
            Colors = {Color3.fromRGB(200, 255, 120), Color3.fromRGB(255, 230, 120)}, Light = 1,
        },
        Matrix = {Matrix = true, Count = 45, Speed = {8, 18}, Color = Color3.fromRGB(60, 255, 100)},
    }
    local WEATHER_NAMES = {rain = "Rain", snow = "Snow", ember = "Ember", embers = "Ember", fire = "Ember", hellfire = "Ember", sakura = "Sakura", petals = "Sakura", cherryblossom = "Sakura", firefly = "Fireflies", fireflies = "Fireflies", matrix = "Matrix", matrixrain = "Matrix", code = "Matrix"}
    local weatherRandom = Random.new()
    local function weatherName(name)
        if type(name) ~= "string" then return "None" end
        return WEATHER_NAMES[(name:lower():gsub("[%s_%-]", ""))] or "None"
    end
    local function roll(min, max) return weatherRandom:NextNumber(min, max) end
    local currentWeatherName, weatherTint = "None", nil
    local weatherSpeed, weatherCountMultiplier, weatherSize = 10, 1, 1
    local weatherAngle, weatherWind, weatherGlow = 10, 0, 0
    local weatherPart, weatherEmitter, weatherConn
    local matrixCols = {}
    local MATRIX_R, MATRIX_H, MATRIX_LIST = 55, 50, nil
    local function moveDir(cfg)
        local th, ph = math.rad(weatherAngle), math.rad(weatherWind)
        local h, y = math.sin(th), math.cos(th)
        if not cfg.Rise then y = -y end
        return Vector3.new(h * math.cos(ph), y, h * math.sin(ph))
    end
    local function travelOf(cfg)
        return (cfg.Speed[1] + cfg.Speed[2]) / 2 * (weatherSpeed / 10) * (cfg.Life or 1)
    end
    local function colorSequence(cfg)
        if weatherTint then return ColorSequence.new(weatherTint) end
        if #cfg.Colors == 1 then return ColorSequence.new(cfg.Colors[1]) end
        return ColorSequence.new(cfg.Colors[1], cfg.Colors[2])
    end
    local function transparencySequence(cfg)
        return NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(cfg.FadeIn, cfg.T), NumberSequenceKeypoint.new(cfg.FadeOut, cfg.T), NumberSequenceKeypoint.new(1, 1)}
    end
    local function ApplyWeather()
        local cfg = WEATHER[currentWeatherName]
        if not cfg then return end
        if cfg.Matrix then
            for _, c in ipairs(matrixCols) do
                c.Gui.Size = UDim2.fromScale(c.S * 1.1 * weatherSize, c.S * c.Len * weatherSize)
                c.Label.TextColor3 = weatherTint or cfg.Color
                c.Label.TextStrokeTransparency = math.clamp(0.7 - weatherGlow * 0.6, 0, 1)
            end
        elseif weatherEmitter then
            local e, sm = weatherEmitter, weatherSpeed / 10
            e.Rate = math.max(1, cfg.Rate * weatherCountMultiplier)
            e.Speed = NumberRange.new(cfg.Speed[1] * sm, cfg.Speed[2] * sm)
            local lo, hi = cfg.Size[1] * weatherSize, cfg.Size[2] * weatherSize
            local mid, half, endMul = (lo + hi) / 2, (hi - lo) / 2, cfg.Shrink and 0.25 or 1
            e.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, mid, half), NumberSequenceKeypoint.new(1, mid * endMul, half * endMul)}
            e.LightEmission = math.clamp(cfg.Light + weatherGlow, 0, 1)
            e.Color = colorSequence(cfg)
            if weatherPart and not cfg.Wander then
                weatherPart.Size = Vector3.new(cfg.Box.X, math.max(1, travelOf(cfg) * 0.8), cfg.Box.Z)
            end
        end
    end
    local function respawnColumn(c, camPos, anywhere)
        local ang, r = roll(0, math.pi * 2), MATRIX_R * math.sqrt(roll(0, 1))
        local y = anywhere and roll(-MATRIX_H / 2, MATRIX_H / 2) or (MATRIX_H / 2 + roll(0, 14))
        c.Pos = camPos + Vector3.new(math.cos(ang) * r, y, math.sin(ang) * r)
    end
    local function newColumn(cfg)
        if not MATRIX_LIST then
            MATRIX_LIST = {}
            for _, code in utf8.codes(GLYPHS) do table.insert(MATRIX_LIST, utf8.char(code)) end
        end
        local part = new("Part", {Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, Transparency = 1, Locked = true, Size = Vector3.new(0.2, 0.2, 0.2)}, worldFolder)
        local gui = new("BillboardGui", {Adornee = part, AlwaysOnTop = false, LightInfluence = 0, MaxDistance = 150}, part)
        local label = new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.Code,
            TextScaled = true, LineHeight = 1, TextColor3 = cfg.Color, TextStrokeColor3 = Color3.fromRGB(50, 255, 90),
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, Text = "",
        }, gui)
        new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 0)}}, label)
        local c = {Part = part, Gui = gui, Label = label, S = roll(0.8, 1.6), Len = math.floor(roll(8, 20)), Speed = roll(cfg.Speed[1], cfg.Speed[2]), Shuffle = roll(0.05, 0.2), ShuffleT = 0, Chars = {}}
        for i = 1, c.Len do c.Chars[i] = MATRIX_LIST[math.random(#MATRIX_LIST)] end
        label.Text = table.concat(c.Chars, "\n")
        return c
    end
    local function updateWeather(dt)
        local cfg, cam = WEATHER[currentWeatherName], Workspace.CurrentCamera
        if not cfg or not cam then return end
        local pos = cam.CFrame.Position
        if cfg.Matrix then
            local d, dir = math.min(dt, 0.05) * (weatherSpeed / 10), moveDir(cfg)
            for _, c in ipairs(matrixCols) do
                c.Pos = c.Pos + dir * c.Speed * d
                local rel = c.Pos - pos
                if rel.Y < -MATRIX_H / 2 - c.S * c.Len or rel.Y > MATRIX_H * 1.5 or Vector3.new(rel.X, 0, rel.Z).Magnitude > MATRIX_R * 1.2 then respawnColumn(c, pos, false) end
                c.Part.Position = c.Pos
                c.ShuffleT = c.ShuffleT + d
                if c.ShuffleT >= c.Shuffle then
                    c.ShuffleT = 0
                    c.Chars[math.random(#c.Chars)] = MATRIX_LIST[math.random(#MATRIX_LIST)]
                    c.Label.Text = table.concat(c.Chars, "\n")
                end
            end
        elseif weatherPart then
            if cfg.Wander then weatherPart.CFrame = CFrame.new(pos + Vector3.new(0, -2, 0)); return end
            local vy = -moveDir(cfg)
            local vx = vy:Cross(Vector3.new(0, 0, 1)).Unit
            weatherPart.CFrame = CFrame.fromMatrix(pos, vx, vy, vx:Cross(vy))
        end
    end
    local function ClearWeather()
        if weatherConn then weatherConn:Disconnect(); weatherConn = nil end
        if weatherPart then weatherPart:Destroy(); weatherPart, weatherEmitter = nil, nil end
        for _, c in ipairs(matrixCols) do c.Gui:Destroy(); c.Part:Destroy() end
        table.clear(matrixCols)
    end
    local function RebuildWeather()
        ClearWeather()
        local cfg = WEATHER[currentWeatherName]
        if not cfg then return end
        local cam = Workspace.CurrentCamera
        if cfg.Matrix then
            local camPos = cam and cam.CFrame.Position or Vector3.zero
            for _ = 1, math.max(1, math.floor(cfg.Count * weatherCountMultiplier)) do
                local c = newColumn(cfg)
                respawnColumn(c, camPos, true)
                c.Part.Position = c.Pos
                table.insert(matrixCols, c)
            end
        else
            weatherPart = new("Part", {Name = "WeatherEmitter", Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, Transparency = 1, Locked = true, Size = cfg.Box}, worldFolder)
            weatherEmitter = new("ParticleEmitter", {
                Texture = cfg.Texture, Lifetime = NumberRange.new(cfg.Life), Shape = Enum.ParticleEmitterShape.Box,
                ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
                EmissionDirection = cfg.Wander and Enum.NormalId.Top or Enum.NormalId.Bottom,
                SpreadAngle = cfg.Spread, Orientation = cfg.Orient or Enum.ParticleOrientation.FacingCamera,
                Transparency = transparencySequence(cfg), LockedToPart = false, Drag = 0, Acceleration = Vector3.zero,
            }, weatherPart)
            if cfg.Spin then weatherEmitter.Rotation = NumberRange.new(0, 360); weatherEmitter.RotSpeed = NumberRange.new(-cfg.Spin, cfg.Spin) end
        end
        ApplyWeather()
        updateWeather(0)
        weatherConn = RunService.RenderStepped:Connect(updateWeather)
    end
    local bloom = new("BloomEffect", {Name = "Z-xWeatherBloom", Enabled = false, Intensity = 1, Size = 24, Threshold = 0.9}, Lighting)
    Library:OnUnload(function()
        ClearWeather()
        worldFolder:Destroy()
        bloom:Destroy()
    end)
    local g = Tabs.Lighting:AddRightGroupbox("Weather Effects")
    g:AddDropdown("WeatherFX", {
        Values = {"None", "Snow", "Rain", "Hell Fire", "Ember", "Sakura", "Fireflies", "Matrix"}, Default = 1, Multi = false, Text = "Weather Effect",
        Callback = function(name) currentWeatherName = weatherName(name); RebuildWeather() end,
    })
    g:AddLabel("Weather Color (white = natural)"):AddColorPicker("WColor", {Default = Color3.new(1, 1, 1), Title = "Weather Color", Callback = function(color)
        weatherTint = color ~= Color3.new(1, 1, 1) and color or nil
        ApplyWeather()
    end})
    g:AddSlider("WSpeed", {Text = "Weather Speed", Min = 0.1, Max = 5, Default = 1, Rounding = 2, Suffix = "x", Callback = function(v) weatherSpeed = v * 10; ApplyWeather() end})
    g:AddSlider("WDensity", {Text = "Weather Intensity", Min = 0.1, Max = 20, Default = 1, Rounding = 1, Suffix = "x", Callback = function(v)
        weatherCountMultiplier = v
        if WEATHER[currentWeatherName] and WEATHER[currentWeatherName].Matrix then RebuildWeather() else ApplyWeather() end
    end})
    g:AddSlider("WSize", {Text = "Particle Size", Min = 0.2, Max = 5, Default = 1, Rounding = 1, Suffix = "x", Callback = function(v) weatherSize = v; ApplyWeather() end})
    g:AddSlider("WAngle", {Text = "Fall Angle (tilt)", Min = 0, Max = 60, Default = 10, Rounding = 0, Suffix = "°", Callback = function(v) weatherAngle = v end})
    g:AddSlider("WWind", {Text = "Fall Direction (compass)", Min = 0, Max = 360, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) weatherWind = v end})
    g:AddSlider("WGlow", {Text = "Particle Glow", Min = 0, Max = 1, Default = 0, Rounding = 2, Callback = function(v) weatherGlow = v; ApplyWeather() end})
    g:AddToggle("WeatherBloom", {Text = "Weather Bloom", Default = false, Callback = function(state) bloom.Enabled = state end})
    g:AddSlider("WeatherBloomIntensity", {Text = "Bloom Intensity", Min = 0, Max = 5, Default = 1, Rounding = 1, Callback = function(v) bloom.Intensity = v end})
    g:AddSlider("WeatherBloomSize", {Text = "Bloom Size", Min = 0, Max = 56, Default = 24, Rounding = 0, Callback = function(v) bloom.Size = v end})
    g:AddSlider("WeatherBloomThreshold", {Text = "Bloom Threshold", Min = 0, Max = 3, Default = 0.9, Rounding = 2, Callback = function(v) bloom.Threshold = v end})
    g:AddButton({Text = "Clear Weather", Func = function() Options.WeatherFX:SetValue("None") end})
end)()



;(function()
getgenv().FFlagStoragePath = "path/to/storage"
local FFlagHandler = {}

function FFlagHandler:SetFFlag(flag, value)
 if type(flag) ~= "string" or flag:gsub(" ", ""):len() == 0 then return false, "InvalidFlagName" end
 local stripped = flag:gsub("^DFInt", ""):gsub("^DFFlag", ""):gsub("^FFlag", ""):gsub("^FInt", ""):gsub("^DFString", ""):gsub("^FString", "")
 local strValue = (type(value) == "boolean") and (value and "True" or "False") or tostring(value)
 local success, method = false, "Unknown"
 local ok = pcall(setfflag, stripped, strValue)
 if ok then success = true; method = "NativeStripped"
 else
 local ok2 = pcall(setfflag, flag, strValue)
 if ok2 then success = true; method = "NativeFull"
 else
 local ok3 = pcall(function() if settings() and settings().FFlags then settings().FFlags[flag] = strValue end end)
 if ok3 then success = true; method = "Settings" end
 end
 end
 if success then
 pcall(function()
 local raw = readfile(FFlagStoragePath)
 local fflagfile = raw and HttpService:JSONDecode(raw) or {}
 fflagfile[flag] = strValue
 writefile(FFlagStoragePath, HttpService:JSONEncode(fflagfile))
 end)
 return true, method
 end
 return false, "InjectionFailed"
end

function FFlagHandler:GetFFlag(flag)
 if type(flag) ~= "string" or flag:gsub(" ", ""):len() == 0 then return nil, "InvalidFlagName" end
 local stripped = flag:gsub("^DFInt", ""):gsub("^DFFlag", ""):gsub("^FFlag", ""):gsub("^FInt", ""):gsub("^DFString", ""):gsub("^FString", "")
 local ok, result = pcall(getfflag, stripped) if ok and result ~= nil then return result, "NativeBare" end
 local ok2, result2 = pcall(getfflag, flag) if ok2 and result2 ~= nil then return result2, "NativeFull" end
 local ok3, raw = pcall(readfile, FFlagStoragePath)
 if ok3 and raw then
 local ok4, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
 if ok4 and decoded and decoded[flag] ~= nil then return decoded[flag], "Persisted" end
 end
 return nil, "FlagNotFound"
end

function FFlagHandler:BulkSet(flagsTable)
 local results = { success = {}, failed = {}, total = 0 }
 for flag, value in pairs(flagsTable) do
 results.total = results.total + 1
 local ok, msg = self:SetFFlag(flag, value)
 if ok then table.insert(results.success, { flag = flag, value = value, method = msg })
 else table.insert(results.failed, { flag = flag, error = msg }) end
 task.wait(0.05)
 end
 return results
end

function FFlagHandler:ClearFlags() pcall(function() writefile(FFlagStoragePath, "{}") end) return true end
function FFlagHandler:GetStats()
 local stats = { totalInjected = 0 }
 local ok, raw = pcall(readfile, FFlagStoragePath)
 if ok and raw then
 local decoded = HttpService:JSONDecode(raw)
 for _ in pairs(decoded) do stats.totalInjected = stats.totalInjected + 1 end
 end
 return stats
end

local FFlagPresets = {
 Performance = { ["DFIntTaskSchedulerTargetFps"] = 0, ["DFIntFrameRateCap"] = 0, ["DFIntRenderShadowMapResolution"] = 256, ["DFIntMaxTextureSize"] = 512, ["DFFlagRenderClutterVoxel"] = false, ["DFIntGraphicsQualityLevel"] = 1 },
 Graphics = { ["DFIntGraphicsQualityLevel"] = 21, ["DFIntAntiAliasingMode"] = 2, ["DFIntRenderShadowMapResolution"] = 2048, ["DFIntMaxTextureSize"] = 4096, ["DFFlagEnableGraphicsModeAutoDetect"] = false },
 Unlock = { ["DFFlagDebugPausePhysicsOnError"] = false, ["DFFlagCharacterAutoJump"] = false, ["DFFlagAllowThirdPartySales"] = true, ["DFFlagUseNewTeleportService"] = false, ["DFFlagDisableTeleportService"] = false, ["DFIntMaxPlayerMovementSpeed"] = 100, ["DFIntMaxPlayerMovementAcceleration"] = 100, ["DFIntJumpPower"] = 80 },
 FPSUnlock = { ["DFIntTaskSchedulerTargetFps"] = 0, ["DFIntFrameRateCap"] = 0, ["DFIntRenderShadowMapResolution"] = 128, ["DFIntMaxTextureSize"] = 256, ["DFFlagRenderClutterVoxel"] = false, ["DFIntGraphicsQualityLevel"] = 1 },
}

do
 local g = Tabs.FFlags:AddLeftGroupbox("Single Injection")
 g:AddInput("FlagNameInput", { Text = "Flag Name", Placeholder = "DFIntMaxPlayerMovementSpeed", ClearTextOnFocus = true })
 g:AddInput("FlagValueInput", { Text = "Flag Value", Placeholder = "100 or true/false", ClearTextOnFocus = true })
 g:AddDropdown("ValueTypeDropdown", { Text = "Value Type", Values = {"AutoDetect", "Number", "Boolean", "String"}, Default = 1 })
 g:AddButton({ Text = "Inject Single Flag", Func = function()
 local flag = Options.FlagNameInput.Value local value = Options.FlagValueInput.Value local valueType = Options.ValueTypeDropdown.Value
 if not flag or flag == "" then Library:Notify({ Title = "Error", Description = "Please enter a flag name", Time = 3 }) return end
 local parsedValue
 if valueType == "AutoDetect" then
 if value:lower() == "true" then parsedValue = true elseif value:lower() == "false" then parsedValue = false elseif tonumber(value) then parsedValue = tonumber(value) else parsedValue = value end
 elseif valueType == "Number" then parsedValue = tonumber(value) or 0
 elseif valueType == "Boolean" then parsedValue = value:lower() == "true"
 else parsedValue = value end
 local ok, msg = FFlagHandler:SetFFlag(flag, parsedValue)
 if ok then Library:Notify({ Title = "Injected", Description = flag .. " = " .. tostring(parsedValue), Time = 4 })
 else Library:Notify({ Title = "Failed", Description = "Could not inject: " .. flag, Time = 4 }) end
 end })
end

do
 local g = Tabs.FFlags:AddRightGroupbox("Bulk Injection & Presets")
 g:AddLabel("Bulk Injection (JSON):")
 g:AddInput("BulkInput", { Text = "JSON Data", Placeholder = '{"DFIntMaxPlayerMovementSpeed": 100}', ClearTextOnFocus = false })
 g:AddButton({ Text = "Bulk Inject", Func = function()
 local json = Options.BulkInput.Value if not json or json == "" then Library:Notify({ Title = "Error", Description = "Please enter JSON data", Time = 3 }) return end
 local ok, flags = pcall(function() return HttpService:JSONDecode(json) end)
 if not ok or type(flags) ~= "table" then Library:Notify({ Title = "Invalid JSON", Description = "Check your JSON syntax", Time = 3 }) return end
 local results = FFlagHandler:BulkSet(flags)
 Library:Notify({ Title = "Bulk Injection Done", Description = "Success: " .. #results.success .. " Failed: " .. #results.failed, Time = 4 })
 end })

 g:AddDivider()
 g:AddLabel("Presets")
 for presetName, flags in pairs(FFlagPresets) do
 g:AddButton({ Text = presetName, Func = function()
 local results = FFlagHandler:BulkSet(flags)
 Library:Notify({ Title = "Preset Applied", Description = presetName .. ": " .. #results.success .. " flags injected", Time = 3 })
 end })
 end
 g:AddDivider()
 g:AddButton({ Text = "Show Stats", Func = function()
 local stats = FFlagHandler:GetStats()
 Library:Notify({ Title = "FFlags Stats", Description = "Total injected: " .. stats.totalInjected .. " flags", Time = 4 })
 end })
 g:AddButton({ Text = "Clear All Flags", Func = function() FFlagHandler:ClearFlags() Library:Notify({ Title = "Cleared", Description = "All flags cleared", Time = 3 }) end })
end
end)()

do
 local g = Tabs.Settings:AddLeftGroupbox("Menu Settings")
 g:AddLabel("Global Menu Open/Close Shortcut"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })
 Library.ToggleKeybind = Options.MenuKeybind
 g:AddToggle("ToggleWatermarkVisibility", { Text = "Show Watermark", Default = true, Callback = function(state)
 getgenv().WatermarkEnabled = state
 pcall(function() Library:SetWatermarkVisibility(state) end)
 if not state then pcall(function() Library:SetWatermark("") end) end
 end })
 g:AddToggle("ShowKeybinds", { Text = "Show Keybinds List", Default = false, Callback = function(state) Library.KeybindFrame.Visible = state end })
 Library.KeybindFrame.Visible = Options.ShowKeybinds and Options.ShowKeybinds.Value or false

 g:AddButton({ Text = "Terminate Script & Clear Cache", Func = function()
 pcall(function()
 for _, conn in ipairs(RunningConnections) do if conn then conn:Disconnect() end end
 table.clear(RunningConnections)
 end)
 pcall(function() if WatermarkConnection then WatermarkConnection:Disconnect() end end)
 pcall(function() if bounceConnection then bounceConnection:Disconnect() end end)
 pcall(function() if _G.WallClimbConnection then _G.WallClimbConnection:Disconnect() end end)
 pcall(function() if bhopConnection then bhopConnection:Disconnect() end end)
 pcall(function() if feEmoteSpeedConn then feEmoteSpeedConn:Disconnect() end end)
 pcall(function() if feEmotingConn then feEmotingConn:Disconnect() end end)
 pcall(function() if edgeBoostConn then edgeBoostConn:Disconnect() end end)
 pcall(function() if hideOthersConn then hideOthersConn:Disconnect() end end)
 pcall(function() if fastTurnConnection then fastTurnConnection:Disconnect() end end)

 pcall(function() if removeInvisWallsEnabled then restoreInvisWalls() end end)
 pcall(function() for _, player in ipairs(game:GetService("Players"):GetPlayers()) do setCharacterVisibility(player.Character, true) end end)
 pcall(function()
 getgenv().Evd = false
 if AutoStrafe then AutoStrafe.enabled = false; AutoStrafe.stop() end
 getgenv().bhopHoldSystemEnabled = false
 getgenv().bhopHoldActive = false
 BounceBhop.enabled = false
 toggleAutoBounce(false)
 customHitboxEnabled = false
 LagSwitch.setLag(false)
 end)

 pcall(function() Spoofer.resetLevel() end)
 pcall(function() Spoofer.resetStats() end)
 pcall(function() if CustomHitboxFolder then CustomHitboxFolder:Destroy() end end)
 pcall(function() if spawnedMap then spawnedMap:Destroy() end end)
 pcall(function() Effects.clearAura() end)
 pcall(function() CustomTrail.remove() end)
 pcall(function() Effects.clearDefaultEffects() end)
 pcall(function() resetCosmetics() end)
 pcall(function() resetGlobalColor() end)

 pcall(function() resetLighting() end)
 pcall(function() if colorCorrection then colorCorrection:Destroy() end end)
 pcall(function() if sunRaysEffect then sunRaysEffect:Destroy() end end)

 pcall(function()
 if movementModule and originalApplyFriction then
 movementModule.ApplyFriction = originalApplyFriction
 end
 end)

 pcall(function() Library:Unload() end)
 end })
end

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("SpermaConfigs")
SaveManager:SetFolder("SpermaConfigs/SW")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:ApplyTheme("Fatality")

SaveManager:LoadAutoloadConfig()
SafeConnect(RunService.RenderStepped, function()
 if getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive then applyBhopFriction() end
end)


local bhopSystemSpamDelay = 0.15

SafeConnect(RunService.Heartbeat, function()
 local isBhopActive = getgenv().bhopHoldSystemEnabled and getgenv().bhopHoldActive
 if isBhopActive then
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hum and hrp and hum.Health > 0 then
 local now = tick()
 if isCharacterGrounded(char, hrp, hum) and (now - LastJump) > bhopSystemSpamDelay then
 LastJump = now
 pcall(function()
 LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
 LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
 end)
 hum:ChangeState(Enum.HumanoidStateType.Jumping)
 end
 end
 end
end)

SafeConnect(RunService.Heartbeat, function()
 if downDashEnabled and LocalPlayer.Character then
 local char = LocalPlayer.Character
 local hum = char:FindFirstChildOfClass("Humanoid")
 local hrp = char:FindFirstChild("HumanoidRootPart")
 local camera = workspace.CurrentCamera
 if hum and hrp and camera then
 local wasDown = isDownedState
 isDownedState = checkIsPlayerDown(char, hum)
 if wasDown and not isDownedState then downDashPreActivated = false; downDashActive = false; downDashCurrentSpeed = 0 end
 if not wasDown and isDownedState then if not downDashHasUsed then downDashHasUsed = true end end
 local canDash = isDownedState and (downDashActive or downDashPreActivated)
 if canDash then
 downDashCurrentSpeed = downDashCurrentSpeed + (downDashSpeed - downDashCurrentSpeed) * 0.2
 if downDashCurrentSpeed > downDashSpeed then downDashCurrentSpeed = downDashSpeed end
 local camLook = camera.CFrame.LookVector
 local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
 if moveDir.Magnitude >= 0.01 then
 moveDir = moveDir.Unit
 local vy = hrp.AssemblyLinearVelocity.Y
 hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * downDashCurrentSpeed, vy, moveDir.Z * downDashCurrentSpeed)
 end
 else
 if downDashCurrentSpeed > 0.5 then
 downDashCurrentSpeed = downDashCurrentSpeed * 0.85
 local camLook = camera.CFrame.LookVector
 local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
 if moveDir.Magnitude > 0.01 then
 moveDir = moveDir.Unit
 local vy = hrp.AssemblyLinearVelocity.Y
 hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * downDashCurrentSpeed, vy, moveDir.Z * downDashCurrentSpeed)
 end
 else downDashCurrentSpeed = 0 end
 end
 end
 end
end)

SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
 if gameProcessed then return end
 if input.KeyCode == Enum.KeyCode.Space then
 if getgenv().bhopHoldSystemEnabled then getgenv().bhopHoldActive = true; applyBhopFriction() end
 if bhopHoldFeature then bhopHoldActive = true; checkBhopState() end
 end
 if downDashEnabled and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C) then
 downDashActive = true
 if not isDownedState then downDashPreActivated = true end
 end
 if turnbindEnabled then
 local leftEnum = parseKeyCode(turnbindLeftKey)
 local rightEnum = parseKeyCode(turnbindRightKey)
 if leftEnum and input.KeyCode == leftEnum then sendKeyEvent(Enum.KeyCode.Left, true)
 elseif rightEnum and input.KeyCode == rightEnum then sendKeyEvent(Enum.KeyCode.Right, true) end
 end
 if input.KeyCode == Enum.KeyCode[autoBounceKeybind] then
 local newState = not autoBounceEnabled
 toggleAutoBounce(newState)
 pcall(function() Toggles.EnableAutoBounceLoop:SetValue(newState) end)
 end
 if input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Toggle" then
 if _G.IsHoldingH then stopWallHold() else startWallHold() end
 elseif input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Hold" then
 startWallHold()
 end
end)

SafeConnect(UserInputService.InputEnded, function(input)
 if input.KeyCode == Enum.KeyCode.Space then
 getgenv().bhopHoldActive = false; applyBhopFriction(true)
 bhopHoldActive = false; checkBhopState()
 end
 if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
 downDashActive = false
 if not isDownedState then downDashPreActivated = false end
 downDashCurrentSpeed = 0
 end
 if turnbindEnabled then
 local leftEnum = parseKeyCode(turnbindLeftKey)
 local rightEnum = parseKeyCode(turnbindRightKey)
 if leftEnum and input.KeyCode == leftEnum then sendKeyEvent(Enum.KeyCode.Left, false)
 elseif rightEnum and input.KeyCode == rightEnum then sendKeyEvent(Enum.KeyCode.Right, false) end
 end
 if input.KeyCode == Enum.KeyCode[wallClimbKeybind] and wallClimbEnabled and wallClimbMode == "Hold" then
 stopWallHold()
 end
end)


getgenv().instantRevive = false
spawn(function()
 while true do
 if getgenv().instantRevive then
 local character = LocalPlayer.Character
 if character then
 local isDowned = character:GetAttribute("Downed")
 if isDowned then
 pcall(function()
 ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
 end)
 task.wait(0.1)
 end
 end
 end
 task.wait(0.5)
 end
end)

do
 local g = Tabs.Misc:AddLeftGroupbox("Revive System")
 g:AddToggle("EnableInstantRevive", { Text = "Instant Revive", Default = false, Callback = function(state) getgenv().instantRevive = state end })
end

local function setupCharacter(character)
 task.wait(0.5)
 local humanoid = character:WaitForChild("Humanoid")
 local rootPart = character:WaitForChild("HumanoidRootPart")
 downDashCurrentSpeed = 0; downDashActive = false; downDashPreActivated = false
 isDownedState = false; downDashHasUsed = false
 SafeConnect(humanoid.StateChanged, function(_, newState)
 if newState == Enum.HumanoidStateType.Landed then CurrentJumpCount = 0 end
 end)
 SafeConnect(humanoid.Jumping, function(isJumping)
 if isJumping and CurrentJumpCount < maxJumpsValue then
 CurrentJumpCount = CurrentJumpCount + 1
 humanoid.JumpHeight = currentSettings.JumpPowerValue
 if CurrentJumpCount > 1 and rootPart then
 rootPart:ApplyImpulse(Vector3.new(0, currentSettings.JumpPowerValue * rootPart.Mass, 0))
 end
 end
 end)
 onRespawnTagCheck()
 task.wait(0.5)
 if headlessEnabled then applyHeadless(character) end
 if korbloxEnabled then applyKorblox(character) end
 setupLegacyCharacter(character)
end

if LocalPlayer.Character then task.spawn(setupCharacter, LocalPlayer.Character) end
SafeConnect(LocalPlayer.CharacterAdded, setupCharacter)




;(function()
local PostEffects = {

 bloomEnabled = false,
 bloomIntensity = 0.5,


 blurEnabled = false,
 blurAmount = 15,
 blurAmplifier = 5,


 motionBlurEnabled = false,
 motionBlurAmount = 15,
 motionBlurAmplifier = 5,


 anamorphicEnabled = false, anamorphicIntensity = 0.5,


 shadowsEnabled = false,
 shadowsIntensity = 1.0,
 autoFixGraphicsEnabled = false,


 shadowSoftnessEnabled = false,
 shadowSoftness = 0.5,
 ambientOcclusionEnabled = false,
 ambientOcclusionIntensity = 0.3,
 colorCorrectionEnabled = false,
 colorCorrectionTint = Color3.new(1, 1, 1),
 colorCorrectionSaturation = 0,
 colorCorrectionContrast = 0,


 blurEffect = nil,
 motionBlurEffect = nil,
 lastVector = nil,
 anamorphicOverlay = nil,
 lightingEffects = {},
}

local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local motionBlurConnection = nil


function PostEffects.applyBloomEffect()
 if not PostEffects.bloomEnabled then return end
 pcall(function()
 if not lighting:FindFirstChild("PostBloom") then
 local bloom = Instance.new("BloomEffect")
 bloom.Name = "PostBloom"
 bloom.Intensity = PostEffects.bloomIntensity
 bloom.Size = 15
 bloom.Threshold = 1
 bloom.Parent = lighting
 PostEffects.lightingEffects.bloom = bloom
 else
 local bloom = lighting:FindFirstChild("PostBloom")
 if bloom then bloom.Intensity = PostEffects.bloomIntensity end
 end
 end)
end

function PostEffects.removeBloomEffect()
 pcall(function()
 local bloom = lighting:FindFirstChild("PostBloom")
 if bloom then bloom:Destroy() end
 PostEffects.lightingEffects.bloom = nil
 end)
end


function PostEffects.applyScreenBlur()
 if not PostEffects.blurEnabled then return end
 pcall(function()
 local currentCamera = workspace.CurrentCamera
 if not currentCamera then return end

 if PostEffects.blurEffect and PostEffects.blurEffect.Parent then
 PostEffects.blurEffect.Size = PostEffects.blurAmount
 else
 PostEffects.blurEffect = Instance.new("BlurEffect")
 PostEffects.blurEffect.Size = PostEffects.blurAmount
 PostEffects.blurEffect.Parent = currentCamera
 end
 end)
end

function PostEffects.removeScreenBlur()
 pcall(function()
 if PostEffects.blurEffect and PostEffects.blurEffect.Parent then
 PostEffects.blurEffect:Destroy()
 PostEffects.blurEffect = nil
 end
 end)
end


function PostEffects.startMotionBlur()
 if PostEffects.motionBlurEnabled then return end
 PostEffects.motionBlurEnabled = true

 pcall(function()
 local currentCamera = workspace.CurrentCamera
 if not currentCamera then return end

 PostEffects.lastVector = currentCamera.CFrame.LookVector

 if not PostEffects.motionBlurEffect or not PostEffects.motionBlurEffect.Parent then
 PostEffects.motionBlurEffect = Instance.new("BlurEffect", currentCamera)
 end

 workspace.Changed:Connect(function(property)
 if property == "CurrentCamera" and PostEffects.motionBlurEnabled then
 local newCamera = workspace.CurrentCamera
 if PostEffects.motionBlurEffect and PostEffects.motionBlurEffect.Parent then
 PostEffects.motionBlurEffect.Parent = newCamera
 else
 PostEffects.motionBlurEffect = Instance.new("BlurEffect", newCamera)
 end
 end
 end)

 if motionBlurConnection then motionBlurConnection:Disconnect() end
 motionBlurConnection = runService.Heartbeat:Connect(function()
 if not PostEffects.motionBlurEnabled then return end

 local currentCamera = workspace.CurrentCamera
 if not currentCamera then return end

 if not PostEffects.motionBlurEffect or PostEffects.motionBlurEffect.Parent == nil then
 PostEffects.motionBlurEffect = Instance.new("BlurEffect", currentCamera)
 end

 local magnitude = (currentCamera.CFrame.LookVector - PostEffects.lastVector).magnitude
 PostEffects.motionBlurEffect.Size = math.abs(magnitude) * PostEffects.motionBlurAmount * PostEffects.motionBlurAmplifier / 2
 PostEffects.lastVector = currentCamera.CFrame.LookVector
 end)
 end)

 Library:Notify({Title = "Motion Blur", Description = " Motion Blur Enabled", Time = 2})
end

function PostEffects.stopMotionBlur()
 PostEffects.motionBlurEnabled = false
 PostEffects.lastVector = nil

 if motionBlurConnection then
 motionBlurConnection:Disconnect()
 motionBlurConnection = nil
 end

 pcall(function()
 if PostEffects.motionBlurEffect and PostEffects.motionBlurEffect.Parent then
 PostEffects.motionBlurEffect:Destroy()
 PostEffects.motionBlurEffect = nil
 end
 end)

 Library:Notify({Title = "Motion Blur", Description = " Motion Blur Disabled", Time = 2})
end


function PostEffects.applyAnamorphicEffect()
 if not PostEffects.anamorphicEnabled then return end
 pcall(function()
 local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
 if playerGui then
 if PostEffects.anamorphicOverlay and PostEffects.anamorphicOverlay.Parent then
 PostEffects.anamorphicOverlay.ImageTransparency = 1 - PostEffects.anamorphicIntensity
 else
 local screenGui = Instance.new("ScreenGui")
 screenGui.Name = "AnamorphicGui"
 screenGui.ResetOnSpawn = false
 screenGui.ZIndex = 999997
 screenGui.Parent = playerGui

 local anamorphic = Instance.new("ImageLabel")
 anamorphic.Name = "AnamorphicOverlay"
 anamorphic.Size = UDim2.new(1, 0, 1, 0)
 anamorphic.Position = UDim2.new(0, 0, 0, 0)
 anamorphic.BackgroundTransparency = 1
 anamorphic.ImageTransparency = 1 - PostEffects.anamorphicIntensity
 anamorphic.Image = "rbxasset://textures/Lens flare/flare_main.png"
 anamorphic.Parent = screenGui

 PostEffects.anamorphicOverlay = anamorphic
 end
 end
 end)
end

function PostEffects.removeAnamorphicEffect()
 pcall(function()
 if PostEffects.anamorphicOverlay then
 local parent = PostEffects.anamorphicOverlay.Parent
 if parent and parent.Parent then
 parent:Destroy()
 end
 PostEffects.anamorphicOverlay = nil
 end
 end)
end


function PostEffects.applyShadowSoftness()
 if not PostEffects.shadowSoftnessEnabled then return end
 pcall(function()
 lighting.ShadowSoftness = PostEffects.shadowSoftness
 end)
end

function PostEffects.removeShadowSoftness()
 pcall(function()
 lighting.ShadowSoftness = 0
 end)
end


function PostEffects.applyAmbientOcclusion()
 if not PostEffects.ambientOcclusionEnabled then return end
 pcall(function()
 if not lighting:FindFirstChild("AmbientOcclusionEffect") then
 local aoEffect = Instance.new("ColorCorrectionEffect")
 aoEffect.Name = "AmbientOcclusionEffect"
 aoEffect.Saturation = -PostEffects.ambientOcclusionIntensity * 0.2
 aoEffect.Contrast = -PostEffects.ambientOcclusionIntensity * 0.1
 aoEffect.Brightness = -PostEffects.ambientOcclusionIntensity * 0.05
 aoEffect.Parent = lighting
 PostEffects.lightingEffects.ao = aoEffect
 else
 local aoEffect = lighting:FindFirstChild("AmbientOcclusionEffect")
 if aoEffect then
 aoEffect.Saturation = -PostEffects.ambientOcclusionIntensity * 0.2
 aoEffect.Contrast = -PostEffects.ambientOcclusionIntensity * 0.1
 aoEffect.Brightness = -PostEffects.ambientOcclusionIntensity * 0.05
 end
 end
 end)
end

function PostEffects.removeAmbientOcclusion()
 pcall(function()
 local aoEffect = lighting:FindFirstChild("AmbientOcclusionEffect")
 if aoEffect then aoEffect:Destroy() end
 PostEffects.lightingEffects.ao = nil
 end)
end


function PostEffects.applyColorCorrection()
 if not PostEffects.colorCorrectionEnabled then return end
 pcall(function()
 if not lighting:FindFirstChild("PostColorCorrection") then
 local correction = Instance.new("ColorCorrectionEffect")
 correction.Name = "PostColorCorrection"
 correction.TintColor = PostEffects.colorCorrectionTint
 correction.Saturation = PostEffects.colorCorrectionSaturation
 correction.Contrast = PostEffects.colorCorrectionContrast
 correction.Parent = lighting
 PostEffects.lightingEffects.colorCorrection = correction
 else
 local correction = lighting:FindFirstChild("PostColorCorrection")
 if correction then
 correction.TintColor = PostEffects.colorCorrectionTint
 correction.Saturation = PostEffects.colorCorrectionSaturation
 correction.Contrast = PostEffects.colorCorrectionContrast
 end
 end
 end)
end

function PostEffects.removeColorCorrection()
 pcall(function()
 local correction = lighting:FindFirstChild("PostColorCorrection")
 if correction then correction:Destroy() end
 PostEffects.lightingEffects.colorCorrection = nil
 end)
end


local graphicConnection = nil

function PostEffects.enableGraphicsShadows()
 if not PostEffects.shadowsEnabled then return end
 pcall(function()
 lighting.GlobalShadows = true
 lighting.ShadowSoftness = PostEffects.shadowsIntensity

 for _, part in pairs(workspace:GetPartBoundsInRadius(workspace.CurrentCamera.CFrame.Position, 1000)) do
 if part:IsA("BasePart") then
 pcall(function()
 part.CastShadow = true
 end)
 end
 end
 end)
end

function PostEffects.disableGraphicsShadows()
 pcall(function()
 lighting.GlobalShadows = false
 lighting.ShadowSoftness = 0
 end)
end

function PostEffects.autoFixGraphics()
 if not PostEffects.autoFixGraphicsEnabled then return end

 if graphicConnection then graphicConnection:Disconnect() end
 graphicConnection = runService.Heartbeat:Connect(function()
 if not PostEffects.autoFixGraphicsEnabled then return end

 pcall(function()
 lighting.GlobalShadows = true
 lighting.ShadowSoftness = PostEffects.shadowsIntensity
 lighting.Brightness = math.max(lighting.Brightness, 1)

 if PostEffects.shadowsEnabled then
 for _, part in pairs(workspace:GetPartBoundsInRadius(workspace.CurrentCamera.CFrame.Position, 500)) do
 if part:IsA("BasePart") then
 pcall(function()
 part.CastShadow = true
 end)
 end
 end
 end
 end)
 end)
end

function PostEffects.stopAutoFixGraphics()
 if graphicConnection then
 graphicConnection:Disconnect()
 graphicConnection = nil
 end
end

function PostEffects.boostLighting()
 pcall(function()
 lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
 lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
 lighting.Brightness = 2
 end)
end


do
 local g = Tabs.PostEffects:AddLeftGroupbox("Bloom Effect")
 g:AddToggle("BloomToggle", {
 Text = "Enable Bloom",
 Default = false,
 Callback = function(value)
 PostEffects.bloomEnabled = value
 if value then
 PostEffects.applyBloomEffect()
 else
 PostEffects.removeBloomEffect()
 end
 end
 })
 g:AddSlider("BloomIntensity", {
 Text = "Bloom Intensity",
 Min = 0.1, Max = 2.0, Default = 0.5, Rounding = 2,
 Callback = function(value)
 PostEffects.bloomIntensity = value
 if PostEffects.bloomEnabled then PostEffects.applyBloomEffect() end
 end
 })
end

do
 local g = Tabs.PostEffects:AddLeftGroupbox("Screen Blur (Intro)")
 g:AddToggle("ScreenBlurToggle", {
 Text = "Enable Screen Blur",
 Default = false,
 Callback = function(value)
 PostEffects.blurEnabled = value
 if value then
 PostEffects.applyScreenBlur()
 else
 PostEffects.removeScreenBlur()
 end
 end
 })
 g:AddSlider("ScreenBlurAmount", {
 Text = "Blur Intensity",
 Min = 1, Max = 50, Default = 15, Rounding = 0,
 Callback = function(value)
 PostEffects.blurAmount = value
 if PostEffects.blurEnabled then PostEffects.applyScreenBlur() end
 end
 })
end

do
 local g = Tabs.PostEffects:AddLeftGroupbox("Motion Blur")
 g:AddToggle("MotionBlurToggle", {
 Text = "Enable Motion Blur",
 Default = false,
 Callback = function(value)
 if value then
 PostEffects.startMotionBlur()
 else
 PostEffects.stopMotionBlur()
 end
 end
 })
 g:AddSlider("MotionBlurIntensity", {
 Text = "Motion Blur Amount",
 Min = 1, Max = 50, Default = 15, Rounding = 0,
 Callback = function(value) PostEffects.motionBlurAmount = value end
 })
 g:AddSlider("MotionBlurAmplifier", {
 Text = "Motion Blur Amplifier",
 Min = 1, Max = 10, Default = 5, Rounding = 1,
 Callback = function(value) PostEffects.motionBlurAmplifier = value end
 })
end

do
 local g = Tabs.PostEffects:AddLeftGroupbox("Lighting & Shadows")
 g:AddToggle("ShadowSoftnessToggle", {
 Text = "Enable Shadow Softness",
 Default = false,
 Callback = function(value)
 PostEffects.shadowSoftnessEnabled = value
 if value then
 PostEffects.applyShadowSoftness()
 else
 PostEffects.removeShadowSoftness()
 end
 end
 })
 g:AddSlider("ShadowSoftnessAmount", {
 Text = "Shadow Softness",
 Min = 0, Max = 100, Default = 50, Rounding = 0,
 Callback = function(value)
 PostEffects.shadowSoftness = value / 100
 if PostEffects.shadowSoftnessEnabled then PostEffects.applyShadowSoftness() end
 end
 })
end

do
 local g = Tabs.PostEffects:AddRightGroupbox("Ambient Occlusion")
 g:AddToggle("AmbientOcclusionToggle", {
 Text = "Enable Ambient Occlusion",
 Default = false,
 Callback = function(value)
 PostEffects.ambientOcclusionEnabled = value
 if value then
 PostEffects.applyAmbientOcclusion()
 else
 PostEffects.removeAmbientOcclusion()
 end
 end
 })
 g:AddSlider("AmbientOcclusionIntensity", {
 Text = "AO Intensity",
 Min = 0.1, Max = 1.0, Default = 0.3, Rounding = 2,
 Callback = function(value)
 PostEffects.ambientOcclusionIntensity = value
 if PostEffects.ambientOcclusionEnabled then PostEffects.applyAmbientOcclusion() end
 end
 })
end

do
 local g = Tabs.PostEffects:AddRightGroupbox("Anamorphic Effect")
 g:AddToggle("AnamorphicToggle", {
 Text = "Enable Anamorphic",
 Default = false,
 Callback = function(value)
 PostEffects.anamorphicEnabled = value
 if value then
 PostEffects.applyAnamorphicEffect()
 else
 PostEffects.removeAnamorphicEffect()
 end
 end
 })
 g:AddSlider("AnamorphicIntensity", {
 Text = "Anamorphic Intensity",
 Min = 0.1, Max = 1.0, Default = 0.5, Rounding = 2,
 Callback = function(value)
 PostEffects.anamorphicIntensity = value
 if PostEffects.anamorphicEnabled then PostEffects.applyAnamorphicEffect() end
 end
 })
end

do
 local g = Tabs.PostEffects:AddLeftGroupbox("Graphics Spoof (BETA)")
 g:AddToggle("ShadowsToggle", {
 Text = "Force Enable Shadows",
 Default = false,
 Callback = function(value)
 PostEffects.shadowsEnabled = value
 if value then
 PostEffects.enableGraphicsShadows()
 else
 PostEffects.disableGraphicsShadows()
 end
 end
 })
 g:AddSlider("ShadowsIntensity", {
 Text = "Shadow Intensity",
 Min = 0, Max = 100, Default = 100, Rounding = 0,
 Callback = function(value)
 PostEffects.shadowsIntensity = value / 100
 if PostEffects.shadowsEnabled then PostEffects.enableGraphicsShadows() end
 end
 })
 g:AddToggle("AutoFixToggle", {
 Text = "Auto Fix Graphics",
 Default = false,
 Callback = function(value)
 PostEffects.autoFixGraphicsEnabled = value
 if value then
 PostEffects.autoFixGraphics()
 else
 PostEffects.stopAutoFixGraphics()
 end
 end
 })
 g:AddButton("Boost Lighting", function()
 PostEffects.boostLighting()
 Library:Notify({
 Title = "Graphics Boost",
 Description = " Lighting boosted",
 Time = 2
 })
 end)
end

do
 local g = Tabs.PostEffects:AddRightGroupbox("Color Correction")
 g:AddToggle("ColorCorrectionToggle", {
 Text = "Enable Color Correction",
 Default = false,
 Callback = function(value)
 PostEffects.colorCorrectionEnabled = value
 if value then
 PostEffects.applyColorCorrection()
 else
 PostEffects.removeColorCorrection()
 end
 end
 })
 g:AddSlider("ColorCorrectionSaturation", {
 Text = "Saturation",
 Min = -1, Max = 1, Default = 0, Rounding = 2,
 Callback = function(value)
 PostEffects.colorCorrectionSaturation = value
 if PostEffects.colorCorrectionEnabled then PostEffects.applyColorCorrection() end
 end
 })
 g:AddSlider("ColorCorrectionContrast", {
 Text = "Contrast",
 Min = -1, Max = 1, Default = 0, Rounding = 2,
 Callback = function(value)
 PostEffects.colorCorrectionContrast = value
 if PostEffects.colorCorrectionEnabled then PostEffects.applyColorCorrection() end
 end
 })
end
do
 local g = Tabs.PostEffects:AddRightGroupbox("Presets")

 g:AddButton(" Cinematic Mode", function()
 PostEffects.bloomEnabled = true
 PostEffects.applyBloomEffect()
 PostEffects.blurEnabled = true
 PostEffects.applyScreenBlur()
 PostEffects.startMotionBlur()
 PostEffects.anamorphicEnabled = true
 PostEffects.applyAnamorphicEffect()
 PostEffects.shadowSoftnessEnabled = true
 PostEffects.applyShadowSoftness()
 PostEffects.shadowsEnabled = true
 PostEffects.enableGraphicsShadows()

 Options.BloomToggle:Set(true)
 Options.ScreenBlurToggle:Set(true)
 Options.MotionBlurToggle:Set(true)
 Options.AnamorphicToggle:Set(true)
 Options.ShadowSoftnessToggle:Set(true)
 Options.ShadowsToggle:Set(true)

 Library:Notify({
 Title = "Preset Applied",
 Description = " Cinematic Mode Active",
 Time = 3
 })
 end)

 g:AddButton(" Gaming Mode", function()
 PostEffects.removeBloomEffect()
 PostEffects.removeScreenBlur()
 PostEffects.stopMotionBlur()
 PostEffects.removeAnamorphicEffect()
 PostEffects.removeShadowSoftness()
 PostEffects.disableGraphicsShadows()
 PostEffects.removeAmbientOcclusion()
 PostEffects.removeColorCorrection()
 PostEffects.stopAutoFixGraphics()

 Options.BloomToggle:Set(false)
 Options.ScreenBlurToggle:Set(false)
 Options.MotionBlurToggle:Set(false)
 Options.AnamorphicToggle:Set(false)
 Options.ShadowSoftnessToggle:Set(false)
 Options.ShadowsToggle:Set(false)
 Options.AmbientOcclusionToggle:Set(false)
 Options.ColorCorrectionToggle:Set(false)
 Options.AutoFixToggle:Set(false)

 Library:Notify({
 Title = "Preset Applied",
 Description = " Gaming Mode Active",
 Time = 3
 })
 end)

 g:AddButton(" Reset All Effects", function()
 PostEffects.removeBloomEffect()
 PostEffects.removeScreenBlur()
 PostEffects.stopMotionBlur()
 PostEffects.removeAnamorphicEffect()
 PostEffects.removeShadowSoftness()
 PostEffects.disableGraphicsShadows()
 PostEffects.removeAmbientOcclusion()
 PostEffects.removeColorCorrection()
 PostEffects.stopAutoFixGraphics()

 Options.BloomToggle:Set(false)
 Options.ScreenBlurToggle:Set(false)
 Options.MotionBlurToggle:Set(false)
 Options.AnamorphicToggle:Set(false)
 Options.ShadowSoftnessToggle:Set(false)
 Options.ShadowsToggle:Set(false)
 Options.AmbientOcclusionToggle:Set(false)
 Options.ColorCorrectionToggle:Set(false)
 Options.AutoFixToggle:Set(false)

 Library:Notify({
 Title = "Reset",
 Description = " All Post Effects disabled",
 Time = 2
 })
 end)
end
end)()



getgenv().CFG = {
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracer = true,
    TextColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 0, 0),
}

;(function()
local activeDrawings = {}

local function newDrawing(class, props)
    local obj = Drawing.new(class)
    for prop, val in pairs(props) do
        obj[prop] = val
    end
    table.insert(activeDrawings, obj)
    return obj
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not getgenv().botesp then
        for _, drawing in pairs(activeDrawings) do
            pcall(function() drawing:Remove() end)
        end
        activeDrawings = {}
        return
    end

    for _, drawing in pairs(activeDrawings) do
        pcall(function() drawing:Remove() end)
    end
    activeDrawings = {}

    local camera = workspace.CurrentCamera
    local players = game:GetService("Players")
    local LocalPlayer = players.LocalPlayer

    local NPC_NAMES = {
        ["Nextbot"] = true,
        ["Skibidi"] = true,
        ["Huggy"] = true,
        ["Siren Head"] = true,
        ["SpongeBob"] = true,
        ["Demogorgon"] = true,
    }

    for _, model in pairs(workspace:GetDescendants()) do
        local isNextBot = false
        for name, _ in pairs(NPC_NAMES) do
            if string.find(model.Name:lower(), name:lower()) then
                isNextBot = true
                break
            end
        end

        if not isNextBot then continue end
        if LocalPlayer.Character and model:IsDescendantOf(LocalPlayer.Character) then continue end

        local hum = model:FindFirstChild("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart")

        if not hum or not hrp then continue end
        if hum.Health <= 0 then continue end

        local pos = hrp.Position
        local dist = (camera.CFrame.Position - pos).Magnitude

        local screenPoint, onScreen = camera:WorldToScreenPoint(pos)
        if not onScreen then continue end

        local size = hrp.Size
        local extents = (size.Magnitude / 2)

        local topLeft = camera:WorldToScreenPoint(pos + Vector3.new(-extents, extents, 0))
        local topRight = camera:WorldToScreenPoint(pos + Vector3.new(extents, extents, 0))
        local botLeft = camera:WorldToScreenPoint(pos + Vector3.new(-extents, -extents, 0))
        local botRight = camera:WorldToScreenPoint(pos + Vector3.new(extents, -extents, 0))

        local minX = math.min(topLeft.X, topRight.X, botLeft.X, botRight.X)
        local maxX = math.max(topLeft.X, topRight.X, botLeft.X, botRight.X)
        local minY = math.min(topLeft.Y, topRight.Y, botLeft.Y, botRight.Y)
        local maxY = math.max(topLeft.Y, topRight.Y, botLeft.Y, botRight.Y)

        local boxW = maxX - minX
        local boxH = maxY - minY
        local centerSP = Vector2.new((minX + maxX) / 2, (minY + maxY) / 2)
        local midBot = Vector2.new(centerSP.X, maxY)


        newDrawing("Rectangle", {
            Position = Vector2.new(minX, minY),
            Size = Vector2.new(boxW, boxH),
            Filled = false,
            Color = Color3.fromRGB(255, 100, 0),
            Thickness = 1.5,
            Visible = true
        })


        if getgenv().CFG.ShowName then
            local label = model.Name
            if getgenv().CFG.ShowDistance then
                label = label .. string.format(" [%.0f]", dist)
            end
            newDrawing("Text", {
                Text = label,
                Position = Vector2.new(centerSP.X, minY - 18),
                Size = 14,
                Color = getgenv().CFG.TextColor,
                Outline = true,
                OutlineColor = Color3.new(0, 0, 0),
                Center = true,
                Visible = true,
            })
        elseif getgenv().CFG.ShowDistance then
            newDrawing("Text", {
                Text = string.format("[%.0f]", dist),
                Position = Vector2.new(centerSP.X, minY - 18),
                Size = 12,
                Color = getgenv().CFG.TextColor,
                Outline = true,
                OutlineColor = Color3.new(0, 0, 0),
                Center = true,
                Visible = true,
            })
        end


        if getgenv().CFG.ShowHealth and boxH > 0 then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barX = minX - 6
            local barTop = minY
            local barBot = maxY
            local barH = barBot - barTop
            local filledH = barH * hpRatio

            newDrawing("Line", {
                From = Vector2.new(barX, barTop), To = Vector2.new(barX, barBot),
                Color = Color3.fromRGB(30, 30, 30), Thickness = 4, Visible = true
            })

            local hpColor = Color3.fromRGB(
                math.floor(255 * (1 - hpRatio)),
                math.floor(255 * hpRatio),
                0
            )
            newDrawing("Line", {
                From = Vector2.new(barX, barBot), To = Vector2.new(barX, barBot - filledH),
                Color = hpColor, Thickness = 3, Visible = true
            })
        end


        if getgenv().CFG.ShowTracer then
            newDrawing("Line", {
                From = midBot, To = centerSP,
                Color = getgenv().CFG.TracerColor, Thickness = 1, Visible = true
            })
        end
    end
end)


end)()

Library:Notify({ Title = "Z-x v1.0", Description = "GET GOOD GET Z-x", Time = 5 })

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() or Library.Unloaded then return end
    if input.KeyCode == Enum.KeyCode.Z and Toggles.AutoStrafeToggle then
        Toggles.AutoStrafeToggle:SetValue(not Toggles.AutoStrafeToggle.Value)
    end
end)
SaveManager:Finish()
end)()