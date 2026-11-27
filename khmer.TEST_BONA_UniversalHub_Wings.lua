--[[ UNIVERSAL HUB v2 | Liquid Blue Glass Dashboard
     Sidebar nav, glowing cards, live FPS/Ping/Server widgets,
     avatar panel on the right. Toggle: RightShift or the floating button ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

---------------------------------------------------------------- ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

---------------------------------------------------------------- THEME (swap BLUE for purple if you want Pic 2 colors)
local BLUE = Color3.fromRGB(90, 180, 255)
local BLUE2 = Color3.fromRGB(40, 110, 230)
local INK = Color3.fromRGB(9, 12, 24)
local CARD = Color3.fromRGB(16, 22, 42)
local WHITE = Color3.new(1, 1, 1)
local MUTED = Color3.fromRGB(150, 170, 205)

-- BONA custom assets
local FLOATING_ICON_IMAGE = "rbxassetid://11603715677"
local WING_RIGHT_IMAGE = "rbxassetid://6322040181"
local WING_LEFT_IMAGE = "rbxassetid://6322037950"
local WING_SPIN_SPEED = 0    -- degrees per second (negative = spin the other way)
local WING_LENGTH = 62       -- size of each wing in pixels
local WING_INSET = 16        -- how far each wing starts inside the icon (so it looks attached)
local WING_RING_SIZE = 200   -- invisible spinning frame, must be bigger than the wings
local WING_FLAP_SPEED = 1.5   -- flaps per second
local WING_FLAP_ANGLE = 32    -- how far the wings swing up and down (degrees)
local WING_FLAP_REST = 14     -- resting angle, positive = wings tilted up (degrees)
local WING_MIRROR_LEFT = false -- false = left wing uses its own image as-is; true = mirror it (only if left looks backwards)
local WING_USE_IMAGE = true   -- false = built-in crimson feather wings (no asset id needed), true = use the image ids above
local WING_FEATHERS = 7      -- feathers per wing (built-in wings)
local WING_TILT = 28         -- how much each feather leans to make the swirl
local MENU_BACKGROUND_IMAGE = "rbxassetid://10110319522"

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) new("UICorner", {CornerRadius = UDim.new(0, r or 12)}, o) end
local function stroke(o, t, c)
	return new("UIStroke", {Color = c or WHITE, Transparency = t or 0.75, Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function tween(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end
local function txt(parent, text, pos, size, o)
	o = o or {}
	return new("TextLabel", {Text = text, Font = o.font or Enum.Font.GothamMedium, TextSize = o.size or 13,
		TextColor3 = o.color or WHITE, BackgroundTransparency = 1, Position = pos, Size = size,
		TextXAlignment = o.align or Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, parent)
end
local function glass(parent, size, pos)
	local f = new("Frame", {Size = size, Position = pos, BackgroundColor3 = WHITE, BackgroundTransparency = 0.1,
		BorderSizePixel = 0, ClipsDescendants = true}, parent)
	corner(f, 20); stroke(f, 0.55, BLUE)
	new("UIGradient", {Rotation = 60, Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 74, 160)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(11, 16, 34)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 4, 10))})}, f)
	return f
end

---------------------------------------------------------------- HOLDER (window + avatar panel)
local holder = new("Frame", {Name = "Holder", Size = UDim2.new(0, 700, 0, 330), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 60), BackgroundTransparency = 1}, gui)
local uiScale = new("UIScale", {}, holder)
local baseScale = 1
local function fit()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local v = cam.ViewportSize
	baseScale = math.clamp(math.min((v.X - 16) / 700, (v.Y - 70) / 330), 0.4, 1)
	uiScale.Scale = baseScale
end
fit()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end

local main = glass(holder, UDim2.new(0, 540, 1, 0), UDim2.new(0, 0, 0, 0))

-- BONA menu background (behind the existing menu controls)
local menuBackground = new("ImageLabel", {
    Name = "BONA_MenuBackground",
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundTransparency = 1,
    Image = MENU_BACKGROUND_IMAGE,
    ImageTransparency = 0.08,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 1
}, main)
corner(menuBackground, 20)

local menuShade = new("Frame", {
    Name = "MenuBackgroundShade",
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundColor3 = INK,
    BackgroundTransparency = 0.52,
    BorderSizePixel = 0,
    ZIndex = 1
}, main)
corner(menuShade, 20)

local avatarPanel = glass(holder, UDim2.new(0, 150, 1, 0), UDim2.new(0, 550, 0, 0))

-- drag (moves both)
local dragZone = new("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, main)
do
	local dragging, startPos, startInput
	dragZone.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, holder.Position, i.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = (i.Position - startInput) / uiScale.Scale
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

---------------------------------------------------------------- SIDEBAR
txt(main, "◆  BONA", UDim2.new(0, 16, 0, 14), UDim2.new(0, 110, 0, 22), {font = Enum.Font.GothamBold, size = 14})
new("Frame", {Position = UDim2.new(0, 132, 0, 12), Size = UDim2.new(0, 1, 1, -24), BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.88, BorderSizePixel = 0}, main)
local nav = new("ScrollingFrame", {Position = UDim2.new(0, 8, 0, 54), Size = UDim2.new(0, 118, 1, -64), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = BLUE, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, main)
new("UIListLayout", {Padding = UDim.new(0, 4)}, nav)

local content = new("Frame", {Position = UDim2.new(0, 142, 0, 0), Size = UDim2.new(1, -152, 1, 0), BackgroundTransparency = 1}, main)
local pageTitle = txt(content, "Dashboard", UDim2.new(0, 0, 0, 12), UDim2.new(0.4, 0, 0, 24), {font = Enum.Font.GothamBold, size = 17})

-- profile chip + minimize
local chip = new("Frame", {Position = UDim2.new(1, -176, 0, 10), Size = UDim2.new(0, 136, 0, 28),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.92}, content)
corner(chip, 14); stroke(chip, 0.8)
local headImg = new("ImageLabel", {Position = UDim2.new(0, 3, 0, 3), Size = UDim2.new(0, 22, 0, 22),
	BackgroundColor3 = BLUE2, BackgroundTransparency = 0.4, BorderSizePixel = 0}, chip)
corner(headImg, 11)
txt(chip, lp.DisplayName, UDim2.new(0, 31, 0, 0), UDim2.new(1, -36, 1, 0), {size = 12})
local minBtn = new("TextButton", {Text = "–", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = WHITE,
	BackgroundColor3 = INK, BackgroundTransparency = 0.3, Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -30, 0, 10), AutoButtonColor = false}, content)
corner(minBtn, 14); stroke(minBtn, 0.7)

---------------------------------------------------------------- TABS
local pages, tabBtns = {}, {}
local function selectTab(name)
	pageTitle.Text = name
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(tabBtns) do
		tween(b, 0.2, {BackgroundTransparency = (n == name) and 0.3 or 1,
			TextColor3 = (n == name) and WHITE or MUTED})
	end
end
local function addTab(name)
	local b = new("TextButton", {Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = MUTED,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = BLUE2, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false}, nav)
	corner(b, 10)
	new("UIPadding", {PaddingLeft = UDim.new(0, 14)}, b)
	local p = new("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -58),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = BLUE,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, content)
	new("UIListLayout", {Padding = UDim.new(0, 8)}, p)
	pages[name], tabBtns[name] = p, b
	b.MouseButton1Click:Connect(function() selectTab(name) end)
	return p
end

---------------------------------------------------------------- CARDS + CONTROLS
local function baseCard(parent, size)
	local c = new("Frame", {Size = size, BackgroundColor3 = CARD, BackgroundTransparency = 0.3, BorderSizePixel = 0}, parent)
	corner(c, 14); stroke(c, 0.5, BLUE)
	return c
end
local function listCard(page, title)
	local c = baseCard(page, UDim2.new(1, -6, 0, 0))
	c.AutomaticSize = Enum.AutomaticSize.Y
	new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, c)
	new("UIListLayout", {Padding = UDim.new(0, 6)}, c)
	txt(c, title, UDim2.new(), UDim2.new(1, 0, 0, 16), {font = Enum.Font.GothamBold, size = 12, color = BLUE})
	return c
end
local function row(parent, h)
	local r = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93,
		BorderSizePixel = 0}, parent)
	corner(r, 10)
	return r
end

local function toggle(parent, text, cb, default)
	local r = row(parent, 36)
	txt(r, text, UDim2.new(0, 12, 0, 0), UDim2.new(1, -70, 1, 0))
	local on = default or false
	local sw = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10),
		BackgroundColor3 = on and BLUE or INK, BackgroundTransparency = on and 0.1 or 0.2}, r)
	corner(sw, 10); stroke(sw, 0.6)
	local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14),
		Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = WHITE}, sw)
	corner(knob, 7)
	local btn = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, r)
	local function apply(v, silent)
		on = v
		tween(knob, 0.2, {Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
		tween(sw, 0.2, {BackgroundColor3 = on and BLUE or INK, BackgroundTransparency = on and 0.1 or 0.2})
		if not silent then cb(on) end
	end
	btn.MouseButton1Click:Connect(function() apply(not on) end)
	return apply
end

local function slider(parent, text, min, max, default, cb)
	local r = row(parent, 50)
	txt(r, text, UDim2.new(0, 12, 0, 5), UDim2.new(1, -70, 0, 18))
	local val = txt(r, tostring(default), UDim2.new(1, -62, 0, 5), UDim2.new(0, 50, 0, 18), {align = Enum.TextXAlignment.Right})
	local bar = new("Frame", {Position = UDim2.new(0, 12, 0, 32), Size = UDim2.new(1, -24, 0, 10),
		BackgroundColor3 = INK, BackgroundTransparency = 0.3}, r)
	corner(bar, 5)
	local fill = new("Frame", {Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = BLUE}, bar)
	corner(fill, 5)
	local dragging = false
	local function set(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * a + 0.5)
		fill.Size = UDim2.new(a, 0, 1, 0); val.Text = tostring(v); cb(v)
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; set(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then set(i.Position.X) end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

local function button(parent, text, cb)
	local r = row(parent, 34)
	local b = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text,
		Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = WHITE}, r)
	b.MouseButton1Click:Connect(function()
		tween(r, 0.1, {BackgroundTransparency = 0.7})
		task.delay(0.15, function() tween(r, 0.2, {BackgroundTransparency = 0.93}) end)
		cb()
	end)
end

local function infoRow(parent, name)
	local r = row(parent, 28)
	txt(r, name, UDim2.new(0, 12, 0, 0), UDim2.new(0.5, 0, 1, 0), {color = MUTED, size = 12})
	return txt(r, "-", UDim2.new(0.5, 0, 0, 0), UDim2.new(0.5, -12, 1, 0), {align = Enum.TextXAlignment.Right, size = 12})
end

---------------------------------------------------------------- FEATURES
local S = {speedOn = false, speed = 32, jumpOn = false, jump = 100, infJump = false,
	noclip = false, fly = false, flySpeed = 60, esp = false}
local function hum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end

RunService.Heartbeat:Connect(function()
	local h = hum(); if not h then return end
	if S.speedOn and not S.moveOwns then h.WalkSpeed = S.speed end
	if S.jumpOn then h.UseJumpPower = true; h.JumpPower = S.jump end
end)
UIS.JumpRequest:Connect(function()
	if S.infJump then local h = hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
RunService.Stepped:Connect(function()
	if not S.noclip then return end
	local c = lp.Character; if not c then return end
	for _, p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = false end
	end
end)

local flyBV, flyBG
local function stopFly()
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
	local h = hum(); if h then h.PlatformStand = false end
end
RunService.RenderStepped:Connect(function()
	local c = lp.Character
	local root = c and c:FindFirstChild("HumanoidRootPart")
	local h = hum()
	if S.fly and root and h then
		if not flyBV then
			flyBV = new("BodyVelocity", {MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.zero}, root)
			flyBG = new("BodyGyro", {MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 9e4}, root)
		end
		local cam = workspace.CurrentCamera
		local mv, vel = h.MoveDirection, Vector3.zero
		if mv.Magnitude > 0 then
			local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
			local flat, flatR = Vector3.new(look.X, 0, look.Z), Vector3.new(right.X, 0, right.Z)
			if flat.Magnitude > 0.01 and flatR.Magnitude > 0.01 then
				vel = look * mv:Dot(flat.Unit) + right * mv:Dot(flatR.Unit)
			end
		end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.yAxis end
		flyBV.Velocity = vel * S.flySpeed
		flyBG.CFrame = cam.CFrame
		h.PlatformStand = true
	elseif flyBV then
		stopFly()
	end
end)

local espObjs = {}
local function clearESP(p) if espObjs[p] then espObjs[p]:Destroy() espObjs[p] = nil end end
local function addESP(p)
	if p == lp or not S.esp or not p.Character then return end
	clearESP(p)
	espObjs[p] = new("Highlight", {FillColor = BLUE, OutlineColor = WHITE, FillTransparency = 0.5,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop}, p.Character)
end
local function hookPlayer(p) p.CharacterAdded:Connect(function() task.wait(0.5) addESP(p) end) end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(clearESP)

local oldLight
local function setFullbright(on)
	if on then
		oldLight = {Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient}
		Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	elseif oldLight then
		Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient = unpack(oldLight)
	end
end

lp.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

---------------------------------------------------------------- DASHBOARD PAGE
local pDash = addTab("Dashboard")
-- HERO (profile header like the reference pics: avatar, title, badge, quick access, live stats)
local HERO = {}
do
	local MarketplaceService = game:GetService("MarketplaceService")
	local hero = baseCard(pDash, UDim2.new(1, -6, 0, 138))
	hero.BackgroundColor3 = WHITE
	hero.BackgroundTransparency = 0.15
	new("UIGradient", {Rotation = 20, Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 100, 215)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(14, 22, 48)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 6, 14))})}, hero)

	local av = new("ImageLabel", {Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(0, 66, 0, 66),
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0}, hero)
	corner(av, 16); stroke(av, 0.25, WHITE)
	task.spawn(function()
		local ok1, img = pcall(function()
			return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok1 then av.Image = img end
	end)

	txt(hero, "BONA  ♛", UDim2.new(0, 92, 0, 12), UDim2.new(1, -104, 0, 26), {font = Enum.Font.GothamBold, size = 17})
	txt(hero, "By BONA", UDim2.new(0, 92, 0, 38), UDim2.new(1, -104, 0, 16), {color = MUTED, size = 12})
	local badge = new("TextLabel", {Text = "Premium", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
		BackgroundColor3 = INK, BackgroundTransparency = 0.3, Position = UDim2.new(0, 92, 0, 58), Size = UDim2.new(0, 84, 0, 22)}, hero)
	corner(badge, 11); stroke(badge, 0.4, WHITE)
	local sess = new("TextLabel", {Text = "Session 00:00", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = MUTED,
		BackgroundColor3 = INK, BackgroundTransparency = 0.45, Position = UDim2.new(0, 184, 0, 58), Size = UDim2.new(0, 112, 0, 22)}, hero)
	corner(sess, 11); stroke(sess, 0.7, WHITE)

	-- quick access (jumps to tabs)
	local qa = new("Frame", {Position = UDim2.new(0, 12, 0, 92), Size = UDim2.new(1, -24, 0, 34), BackgroundTransparency = 1}, hero)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, qa)
	for _, name in ipairs({"Player", "Movement", "Executor", "Visuals"}) do
		local b = new("TextButton", {Text = name, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = WHITE,
			BackgroundColor3 = INK, BackgroundTransparency = 0.35, Size = UDim2.new(1 / 4, -6, 1, 0), AutoButtonColor = false}, qa)
		corner(b, 10); stroke(b, 0.6, BLUE)
		b.MouseButton1Click:Connect(function() if pages[name] then selectTab(name) end end)
	end

	-- live stats grid
	local stats = baseCard(pDash, UDim2.new(1, -6, 0, 0))
	stats.AutomaticSize = Enum.AutomaticSize.Y
	new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, stats)
	local grid = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, stats)
	new("UIGridLayout", {CellSize = UDim2.new(0.5, -4, 0, 40), CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder}, grid)
	local function stat(order, title, value)
		local r = row(grid, 40)
		r.LayoutOrder = order
		txt(r, title, UDim2.new(0, 12, 0, 4), UDim2.new(1, -24, 0, 14), {color = MUTED, size = 10})
		return txt(r, value, UDim2.new(0, 12, 0, 18), UDim2.new(1, -24, 0, 18), {font = Enum.Font.GothamBold, size = 13})
	end
	stat(1, "Player", lp.DisplayName)
	local gameLbl = stat(2, "Game", "Loading...")
	local pingLbl2 = stat(3, "Ping", "-")
	local fpsLbl2 = stat(4, "FPS", "-")
	local timeLbl = stat(5, "Local time", "-")
	local playersLbl = stat(6, "Players", "-")
	task.spawn(function()
		local ok1, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
		gameLbl.Text = (ok1 and info and info.Name) or tostring(game.PlaceId)
	end)

	local started = os.clock()
	HERO.update = function(fpsValue, pingValue)
		pingLbl2.Text = pingValue .. " ms"
		fpsLbl2.Text = fpsValue .. " fps"
		timeLbl.Text = os.date("%H:%M")
		playersLbl.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		local t = math.floor(os.clock() - started)
		sess.Text = string.format("Session %02d:%02d", t // 60, t % 60)
	end
end

local top = new("Frame", {Size = UDim2.new(1, -6, 0, 124), BackgroundTransparency = 1}, pDash)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, top)

-- FPS card
local fpsCard = baseCard(top, UDim2.new(0.5, -4, 1, 0))
txt(fpsCard, "Live FPS", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 16), {font = Enum.Font.GothamBold, size = 12, color = BLUE})
local fpsLbl = txt(fpsCard, "60", UDim2.new(0, 12, 0, 24), UDim2.new(1, -24, 0, 32), {font = Enum.Font.GothamBold, size = 26})
local barBox = new("Frame", {Position = UDim2.new(0, 12, 0, 62), Size = UDim2.new(1, -24, 0, 50), BackgroundTransparency = 1}, fpsCard)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Bottom,
	Padding = UDim.new(0, 3)}, barBox)
local bars, hist = {}, {}
for i = 1, 16 do
	hist[i] = 0
	local b = new("Frame", {Size = UDim2.new(0, 7, 0, 3), BackgroundColor3 = BLUE, BackgroundTransparency = 0.15,
		BorderSizePixel = 0}, barBox)
	corner(b, 3)
	bars[i] = b
end

-- Ping card
local pingCard = baseCard(top, UDim2.new(0.5, -4, 1, 0))
txt(pingCard, "Ping", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 16), {font = Enum.Font.GothamBold, size = 12, color = BLUE})
local pingLbl = txt(pingCard, "0 ms", UDim2.new(0, 12, 0, 24), UDim2.new(1, -24, 0, 32), {font = Enum.Font.GothamBold, size = 26})
local track = new("Frame", {Position = UDim2.new(0, 12, 0, 74), Size = UDim2.new(1, -24, 0, 8), BackgroundColor3 = WHITE,
	BorderSizePixel = 0}, pingCard)
corner(track, 4)
new("UIGradient", {Color = ColorSequence.new(BLUE, Color3.fromRGB(255, 90, 110))}, track)
local marker = new("Frame", {Size = UDim2.new(0, 4, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = WHITE,
	BorderSizePixel = 0}, track)
corner(marker, 2)
local pingState = txt(pingCard, "Good", UDim2.new(0, 12, 0, 92), UDim2.new(1, -24, 0, 18), {color = MUTED, size = 12})

-- Server card
local srv = listCard(pDash, "Server")
local vPlayers, vUptime, vPlace, vHealth = infoRow(srv, "Players"), infoRow(srv, "Session time"), infoRow(srv, "Place ID"), infoRow(srv, "Health")
vPlace.Text = tostring(game.PlaceId)

---------------------------------------------------------------- PLAYER PAGE
local pPlayer = addTab("Player")
local mv = listCard(pPlayer, "Movement")
toggle(mv, "Speed", function(v)
	S.speedOn = v
	if not v then local h = hum() if h then h.WalkSpeed = 16 end end
end)
slider(mv, "Walk Speed", 16, 200, S.speed, function(v) S.speed = v end)
toggle(mv, "Jump Power", function(v)
	S.jumpOn = v
	if not v then local h = hum() if h then h.JumpPower = 50 end end
end)
slider(mv, "Jump Height", 50, 300, S.jump, function(v) S.jump = v end)
toggle(mv, "Infinite Jump", function(v) S.infJump = v end)
local ab = listCard(pPlayer, "Abilities")
toggle(ab, "Noclip", function(v) S.noclip = v end)
toggle(ab, "Fly", function(v) S.fly = v end)
slider(ab, "Fly Speed", 20, 200, S.flySpeed, function(v) S.flySpeed = v end)

---------------------------------------------------------------- VISUALS PAGE
---------------------------------------------------------------- CAMERA (freecam ported from universal_freecam_v13) + SPECTATE
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local function cam() return workspace.CurrentCamera end

local FC = {active = false, speed = 100, remember = false, yaw = 0, pitch = 0, pos = Vector3.zero,
	savedPos = nil, savedPitch = nil, savedYaw = nil, frozen = nil, origAnchored = false,
	falling = false, fallStart = 0, conn = nil}
local SINK = 2000000
local keys = {W = false, A = false, S = false, D = false, E = false, Q = false, LeftShift = false}
local keyMap = {[Enum.KeyCode.W] = "W", [Enum.KeyCode.A] = "A", [Enum.KeyCode.S] = "S", [Enum.KeyCode.D] = "D",
	[Enum.KeyCode.E] = "E", [Enum.KeyCode.Q] = "Q", [Enum.KeyCode.LeftShift] = "LeftShift"}

local controls
pcall(function()
	local ps = lp:WaitForChild("PlayerScripts", 2)
	local pm = ps and ps:FindFirstChild("PlayerModule")
	if pm then controls = require(pm):GetControls() end
end)

-- executor hook: games polling IsKeyDown don't see WASD/Space while freecam is on
pcall(function()
	if hookfunction then
		local old
		old = hookfunction(UIS.IsKeyDown, function(self, key)
			if FC.active and (keyMap[key] or key == Enum.KeyCode.Space) then return false end
			return old(self, key)
		end)
	end
end)

-- dynamic glass joystick (mobile)
local joy = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 110, 0, 110),
	BackgroundColor3 = INK, BackgroundTransparency = 0.45, Visible = false}, gui)
corner(joy, 55); stroke(joy, 0.4, BLUE)
local knob = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 46, 0, 46),
	Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = BLUE, BackgroundTransparency = 0.25}, joy)
corner(knob, 23); stroke(knob, 0.3)
local moveTouch, lookTouch, joyCenter, joyVec = nil, nil, Vector2.zero, Vector2.zero
local joyRadius = 50

local function overHub(pos)
	if not holder.Visible then return false end
	local p0, sz = holder.AbsolutePosition, holder.AbsoluteSize
	return pos.X >= p0.X and pos.X <= p0.X + sz.X and pos.Y >= p0.Y and pos.Y <= p0.Y + sz.Y
end

local function keyAction(_, state, input)
	if not FC.active then return Enum.ContextActionResult.Pass end
	local k = input and keyMap[input.KeyCode]
	if k then keys[k] = (state == Enum.UserInputState.Begin) end
	return Enum.ContextActionResult.Sink
end

UIS.InputBegan:Connect(function(input, gp)
	if not FC.active or gp or input.UserInputType ~= Enum.UserInputType.Touch then return end
	local p = Vector2.new(input.Position.X, input.Position.Y)
	if overHub(p) then return end
	local vp = cam().ViewportSize
	if p.X < vp.X * 0.48 and not moveTouch then
		moveTouch, joyCenter, joyVec = input, p, Vector2.zero
		joy.Position = UDim2.new(0, p.X, 0, p.Y)
		knob.Position = UDim2.new(0.5, 0, 0.5, 0)
		joy.Visible = true
	elseif p.X >= vp.X * 0.48 and not lookTouch then
		lookTouch = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if not FC.active then return end
	if input.UserInputType == Enum.UserInputType.Touch then
		if input == moveTouch then
			local d = Vector2.new(input.Position.X, input.Position.Y) - joyCenter
			if d.Magnitude > joyRadius then d = d.Unit * joyRadius end
			knob.Position = UDim2.new(0.5, d.X, 0.5, d.Y)
			joyVec = Vector2.new(d.X / joyRadius, -d.Y / joyRadius)
		elseif input == lookTouch then
			FC.yaw = FC.yaw - input.Delta.X * 0.35
			FC.pitch = math.clamp(FC.pitch - input.Delta.Y * 0.35, -89, 89)
		end
	elseif input.UserInputType == Enum.UserInputType.MouseMovement
		and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		FC.yaw = FC.yaw - input.Delta.X * 0.2
		FC.pitch = math.clamp(FC.pitch - input.Delta.Y * 0.2, -89, 89)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input == moveTouch then moveTouch, joyVec = nil, Vector2.zero; joy.Visible = false
	elseif input == lookTouch then lookTouch = nil end
end)

local stopSpectate -- defined in the Spectate section
local fcSet

local function startFreecam()
	local char = lp.Character
	local h = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (h and root) then return false end
	if stopSpectate then stopSpectate() end
	h:UnequipTools()
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)
	FC.falling = false
	FC.origAnchored = root.Anchored
	FC.frozen = root.CFrame
	root.Anchored = true
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	if controls then controls:Disable() end
	local tg = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("TouchGui")
	if tg then tg.Enabled = false end
	ContextActionService:BindActionAtPriority("UniversalHubFreecamSink", keyAction, false, SINK,
		Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q,
		Enum.KeyCode.Space, Enum.KeyCode.LeftShift,
		Enum.PlayerActions.CharacterForward, Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft, Enum.PlayerActions.CharacterRight, Enum.PlayerActions.CharacterJump)

	if FC.remember and FC.savedPos then
		FC.pos, FC.pitch, FC.yaw = FC.savedPos, FC.savedPitch, FC.savedYaw
	else
		local cf = cam().CFrame
		FC.pos = cf.Position
		local x, y = cf:ToOrientation()
		FC.pitch, FC.yaw = math.deg(x), math.deg(y)
	end
	cam().CameraType = Enum.CameraType.Scriptable
	FC.active = true

	FC.conn = RunService.RenderStepped:Connect(function(dt)
		local c = lp.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if r then
			if FC.falling then
				local vel = r.AssemblyLinearVelocity
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Exclude
				rp.FilterDescendantsInstances = {c}
				local hit = workspace:Raycast(r.Position, Vector3.new(0, -(r.Size.Y / 2 + 0.35), 0), rp)
				local elapsed = tick() - FC.fallStart
				if elapsed > 0.15 and ((hit and math.abs(vel.Y) < 1.5) or elapsed > 8) then
					FC.falling = false
					r.Anchored = true
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
					FC.frozen = r.CFrame
				end
			else
				r.CFrame = FC.frozen
				r.Anchored = true
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end
		end

		local rot = CFrame.Angles(0, math.rad(FC.yaw), 0) * CFrame.Angles(math.rad(FC.pitch), 0, 0)
		local mv = Vector3.zero
		if joyVec.Magnitude > 0.05 then
			mv += rot.RightVector * joyVec.X + rot.LookVector * joyVec.Y
		end
		local f = (keys.W and 1 or 0) - (keys.S and 1 or 0)
		local rt = (keys.D and 1 or 0) - (keys.A and 1 or 0)
		local u = (keys.E and 1 or 0) - (keys.Q and 1 or 0)
		if f ~= 0 or rt ~= 0 or u ~= 0 then
			mv += rot.LookVector * f + rot.RightVector * rt + Vector3.yAxis * u
		end
		if mv.Magnitude > 0 then
			FC.pos += mv.Unit * (FC.speed * (keys.LeftShift and 2 or 1) * dt)
		end
		cam().CFrame = CFrame.new(FC.pos) * rot
	end)
	return true
end

local function stopFreecam()
	if not FC.active then return end
	FC.active = false
	if FC.conn then FC.conn:Disconnect() FC.conn = nil end
	ContextActionService:UnbindAction("UniversalHubFreecamSink")
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
	moveTouch, lookTouch, joyVec = nil, nil, Vector2.zero
	joy.Visible = false
	if controls then controls:Enable() end
	local tg = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("TouchGui")
	if tg then tg.Enabled = true end
	for k in pairs(keys) do keys[k] = false end
	if FC.remember then FC.savedPos, FC.savedPitch, FC.savedYaw = FC.pos, FC.pitch, FC.yaw end
	local c = lp.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	local r = c and c:FindFirstChild("HumanoidRootPart")
	if h then cam().CameraSubject = h end
	if r then
		r.Anchored = FC.origAnchored
		if not FC.falling then
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
		end
	end
	FC.falling = false
	cam().CameraType = Enum.CameraType.Custom
end

-- Camera page
local pCam = addTab("Camera")
local fcCard = listCard(pCam, "Freecam")
fcSet = toggle(fcCard, "Freecam", function(v)
	if v then
		if not startFreecam() then fcSet(false, true) end
	else
		stopFreecam()
	end
end)
slider(fcCard, "Cam Speed", 10, 1000, FC.speed, function(v) FC.speed = v end)
toggle(fcCard, "Remember Position", function(v)
	FC.remember = v
	if not v then FC.savedPos, FC.savedPitch, FC.savedYaw = nil, nil, nil end
end)
button(fcCard, "Teleport Me To Cam", function()
	local c = lp.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	local r = c and c:FindFirstChild("HumanoidRootPart")
	if FC.active and r and h then
		FC.falling = true
		FC.fallStart = tick()
		r.Anchored = false
		r.CFrame = CFrame.new(cam().CFrame.Position) * CFrame.Angles(0, math.rad(FC.yaw), 0)
		r.AssemblyLinearVelocity = Vector3.zero
		r.AssemblyAngularVelocity = Vector3.zero
		pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end)
	end
end)
local helpRow = row(fcCard, 44)
new("TextLabel", {Text = "PC: WASD + Q/E, hold right mouse to look, Shift = fast.\nMobile: left side joystick, right side drag to look.",
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = MUTED, TextWrapped = true, BackgroundTransparency = 1,
	Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left}, helpRow)

-- Spectate page
local pSpec = addTab("Spectate")
local specCard = listCard(pSpec, "Spectate")
local specLbl = txt(specCard, "Not spectating", UDim2.new(), UDim2.new(1, 0, 0, 18), {color = MUTED, size = 12})
local spectating = nil

stopSpectate = function()
	spectating = nil
	specLbl.Text = "Not spectating"
	local h = hum()
	if h then cam().CameraSubject = h end
end
local function spectate(p)
	if not p or not p.Character then return end
	local h = p.Character:FindFirstChildOfClass("Humanoid")
	if not h then return end
	if FC.active then fcSet(false) end
	spectating = p
	cam().CameraType = Enum.CameraType.Custom
	cam().CameraSubject = h
	specLbl.Text = "Spectating: " .. p.DisplayName
end
local function others()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(t, p) end end
	return t
end
local function step(d)
	local t = others()
	if #t == 0 then return end
	local i = table.find(t, spectating) or (d > 0 and 0 or 1)
	spectate(t[((i - 1 + d) % #t) + 1])
end
button(specCard, "◀  Previous Player", function() step(-1) end)
button(specCard, "Next Player  ▶", function() step(1) end)
button(specCard, "Stop Spectating", stopSpectate)
button(specCard, "Teleport To Spectated Player", function()
	local r = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	local tr = spectating and spectating.Character and spectating.Character:FindFirstChild("HumanoidRootPart")
	if r and tr then r.CFrame = tr.CFrame * CFrame.new(0, 0, 4) end
end)

local listCardF = listCard(pSpec, "Players")
local listRows = {}
local function refreshList()
	for _, r in ipairs(listRows) do r:Destroy() end
	listRows = {}
	local t = others()
	if #t == 0 then
		local r = row(listCardF, 30)
		txt(r, "No other players", UDim2.new(0, 12, 0, 0), UDim2.new(1, -24, 1, 0), {color = MUTED, size = 12})
		table.insert(listRows, r)
	end
	for _, p in ipairs(t) do
		local r = row(listCardF, 30)
		local b = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			Text = p.DisplayName .. "  (@" .. p.Name .. ")", Font = Enum.Font.GothamMedium, TextSize = 12,
			TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r)
		new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8)}, b)
		b.MouseButton1Click:Connect(function() spectate(p) end)
		table.insert(listRows, r)
	end
end
refreshList()
Players.PlayerAdded:Connect(function() task.wait(0.2) refreshList() end)
Players.PlayerRemoving:Connect(function(p)
	if p == spectating then stopSpectate() end
	task.defer(refreshList)
end)
-- keep following the target after they (or you) respawn
RunService.RenderStepped:Connect(function()
	if not spectating or FC.active then return end
	local c = spectating.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if h and cam().CameraSubject ~= h then cam().CameraSubject = h end
end)

---------------------------------------------------------------- SKINS (ported from BONA Skin Changer, wrapped in do-block to save locals)
do
	local InsertService = game:GetService("InsertService")

	local SKINS = {
		{name = "ALIEN", sub = "Local outfit"},
		{name = "OUTFIT 1", sub = "Local outfit"},
		{name = "OUTFIT 2", sub = "Local outfit"},
		{name = "OUTFIT 6", sub = "Headless"},
		{name = "BONA", sub = "Signature outfit"},
		{name = "NEW SKIN", sub = "Invisible legs - visual"},
	}
	local SKIN_ASSETS = {
		[1] = {ids = {135296002070804, 97875527870836, 16072291686, 135610651695612}},
		[2] = {ids = {15592661894, 5550364408, 6312623103, 117643913811336}},
		[3] = {ids = {138754481686105, 83972993348410, 75902648004142, 346678359}},
		[4] = {ids = {84919411340444, 18852198255, 9843097284, 123913269946783, 72864103625783}},
		[5] = {ids = {111835011450307, 105131101388933, 89792283174629, 138489178542039}},
		[6] = {ids = {104705732583473, 1145116885, 9843097284, 15046427166, 128823533211252}},
	}

	local SK = {active = false, selected = 1, visualParts = {}, charConn = nil, generation = 0}
	local function bumpGen() SK.generation += 1 return SK.generation end

	local function resetChar()
		for _, obj in ipairs(SK.visualParts) do pcall(function() obj:Destroy() end) end
		SK.visualParts = {}
		if SK.charConn then SK.charConn:Disconnect() SK.charConn = nil end
	end

	local function getObjects(assetId)
		local ok1, objs = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId)) end)
		if ok1 and objs and #objs > 0 then return objs end
		local ok2, model = pcall(function() return InsertService:LoadAsset(assetId) end)
		if ok2 and model then return {model} end
		return nil
	end

	local function findAttachment(char, name)
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Attachment") and obj.Name == name and not obj:FindFirstAncestorWhichIsA("Accessory") then
				return obj
			end
		end
	end

	local function hideWearables(char)
		for _, obj in ipairs(char:GetChildren()) do
			if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic")
				or obj:IsA("CharacterMesh") then
				obj:Destroy()
			end
		end
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
		end
	end

	local function attachAccessory(acc, char, root, track)
		local handle = acc:FindFirstChild("Handle") or acc:FindFirstChildWhichIsA("BasePart", true)
		if not handle then return false end
		for _, obj in ipairs(acc:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.Anchored = false; obj.CanCollide = false; obj.CanTouch = false
				obj.CanQuery = false; obj.Massless = true
			end
		end
		acc.Parent = char
		local targetPart
		for _, obj in ipairs(handle:GetChildren()) do
			if obj:IsA("Attachment") then
				local att = findAttachment(char, obj.Name)
				if att then
					targetPart = att.Parent
					handle.CFrame = att.WorldCFrame * obj.CFrame:Inverse()
					break
				end
			end
		end
		if not targetPart then
			targetPart = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
				or char:FindFirstChild("UpperTorso") or root
			handle.CFrame = root.CFrame
		end
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = targetPart
		weld.Part1 = handle
		weld.Parent = handle
		if track ~= false then table.insert(SK.visualParts, acc) end
		return true
	end

	local function applyOutfitToRig(char, idx, track)
		local data = SKIN_ASSETS[idx]
		if not data then return end
		hideWearables(char)
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		for _, id in ipairs(data.ids) do
			local objects = getObjects(id)
			if objects then
				for _, obj in ipairs(objects) do
					if obj:IsA("Accessory") or obj:IsA("Accoutrement") then
						attachAccessory(obj, char, root, track)
					else
						for _, sub in ipairs(obj:GetDescendants()) do
							if sub:IsA("Accessory") or sub:IsA("Accoutrement") then
								attachAccessory(sub:Clone(), char, root, track)
							end
						end
						local function addClothing(cl)
							if not (cl:IsA("Shirt") or cl:IsA("Pants") or cl:IsA("ShirtGraphic")) then return end
							for _, ex in ipairs(char:GetChildren()) do
								if ex.ClassName == cl.ClassName then ex:Destroy() end
							end
							local cloned = cl:Clone()
							cloned.Parent = char
							if track ~= false then table.insert(SK.visualParts, cloned) end
						end
						addClothing(obj)
						for _, sub in ipairs(obj:GetDescendants()) do addClothing(sub) end
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end
	end

	local function applyOutfit(char, idx)
		if not char then return end
		local gen = bumpGen()
		task.wait()
		if gen ~= SK.generation then return end
		if lp.Character ~= char or not char.Parent then return end
		applyOutfitToRig(char, idx, true)
	end

	local function stopSkin()
		bumpGen()
		SK.active = false
		resetChar()
		local char = lp.Character
		if not char then return end
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
		end
		local head = char:FindFirstChild("Head")
		if head then
			head.Transparency = 0
			head.CanCollide = true
		end
		for _, name in ipairs({"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"}) do
			local part = char:FindFirstChild(name)
			if part then part.Transparency = 0 end
		end
	end

	local function applySkin(idx)
		SK.selected = math.clamp(idx, 1, #SKINS)
		stopSkin()
		local char = lp.Character
		if not char then return end
		SK.active = true
		local selected = SK.selected
		applyOutfit(char, selected)
		SK.charConn = lp.CharacterAdded:Connect(function(newChar)
			task.wait(0.6)
			if SK.active and SK.selected == selected then applyOutfit(newChar, selected) end
		end)
	end

	-- 3D previews
	local function createPreviewRig()
		local ok1, rig = pcall(function()
			return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
		end)
		if ok1 and rig then return rig end
		local char = lp.Character
		if char then
			local prev = char.Archivable
			char.Archivable = true
			local clone = char:Clone()
			char.Archivable = prev
			if clone then
				for _, obj in ipairs(clone:GetDescendants()) do
					if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ForceField") then obj:Destroy() end
				end
				return clone
			end
		end
		return nil
	end

	local orbitTargets = {}
	local function loadPreview(viewport, idx, loadingLbl)
		local world = Instance.new("WorldModel")
		world.Parent = viewport
		local pcam = Instance.new("Camera")
		pcam.FieldOfView = 38
		pcam.Parent = viewport
		viewport.CurrentCamera = pcam
		task.spawn(function()
			local rig = createPreviewRig()
			if not rig or not viewport.Parent then
				if loadingLbl then loadingLbl.Text = "N/A" end
				return
			end
			for _, part in ipairs(rig:GetDescendants()) do
				if part:IsA("BasePart") then part.Color = Color3.fromRGB(220, 220, 225) end
			end
			local root = rig:FindFirstChild("HumanoidRootPart")
			if root then
				root.Anchored = true
				rig:PivotTo(CFrame.new(0, 0, 0))
			end
			rig.Parent = world
			applyOutfitToRig(rig, idx, false)
			local okBox, cf, size = pcall(function() return rig:GetBoundingBox() end)
			local center = (okBox and cf and cf.Position) or (root and root.Position) or Vector3.zero
			local maxDim = (okBox and size and math.max(size.Y, size.X * 1.15, 5.2)) or 5.5
			local dist = (maxDim * 0.5 / math.tan(math.rad(pcam.FieldOfView * 0.5))) * 1.25
			pcam.CFrame = CFrame.lookAt(center + Vector3.new(0, dist * 0.08, -dist), center)
			table.insert(orbitTargets, {cam = pcam, center = center, dist = dist, offset = (idx - 1) * 0.65})
			if loadingLbl and loadingLbl.Parent then loadingLbl:Destroy() end
		end)
	end

	-- Skins tab UI
	local pSkin = addTab("Skins")
	local skCard = listCard(pSkin, "Skin Changer")
	local skLbl = txt(skCard, "No skin active", UDim2.new(), UDim2.new(1, 0, 0, 18), {color = MUTED, size = 12})
	local cards = {}
	local function refreshCards()
		for i, c in ipairs(cards) do
			local on = SK.active and SK.selected == i
			c.stroke.Color = on and BLUE or WHITE
			c.stroke.Transparency = on and 0.1 or 0.82
			c.check.Visible = on
		end
		skLbl.Text = SK.active and ("Active: " .. SKINS[SK.selected].name) or "No skin active"
	end
	button(skCard, "Remove Skin (respawn restores your look)", function() stopSkin() refreshCards() end)

	local grid = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, skCard)
	new("UIGridLayout", {CellSize = UDim2.new(0.5, -4, 0, 168), CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder}, grid)

	local thumbData = {}
	for i, skin in ipairs(SKINS) do
		local card = new("TextButton", {LayoutOrder = i, Text = "", AutoButtonColor = false, BackgroundColor3 = WHITE,
			BackgroundTransparency = 0.93, BorderSizePixel = 0}, grid)
		corner(card, 12)
		local cs = stroke(card, 0.82)
		local tb = new("Frame", {Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(1, -12, 0, 118),
			BackgroundColor3 = INK, BackgroundTransparency = 0.3, BorderSizePixel = 0}, card)
		corner(tb, 9)
		local vp = new("ViewportFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			Ambient = Color3.fromRGB(225, 225, 225), LightColor = WHITE, LightDirection = Vector3.new(0, -1, 1)}, tb)
		corner(vp, 9)
		local ll = txt(vp, "...", UDim2.new(), UDim2.new(1, 0, 1, 0), {color = MUTED, size = 11, align = Enum.TextXAlignment.Center})
		txt(card, skin.name, UDim2.new(0, 8, 0, 128), UDim2.new(1, -16, 0, 16), {font = Enum.Font.GothamBold, size = 11})
		txt(card, skin.sub, UDim2.new(0, 8, 0, 146), UDim2.new(1, -16, 0, 14), {color = MUTED, size = 9})
		local chk = new("TextLabel", {Text = "ON", Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = INK,
			BackgroundColor3 = BLUE, Size = UDim2.new(0, 30, 0, 18), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 10), Visible = false, ZIndex = 3}, card)
		corner(chk, 9)
		card.Activated:Connect(function() applySkin(i) refreshCards() end)
		cards[i] = {stroke = cs, check = chk}
		thumbData[i] = {vp = vp, ll = ll}
	end

	-- load previews lazily (first time the tab is opened), staggered to avoid lag
	local started = false
	tabBtns["Skins"].MouseButton1Click:Connect(function()
		if started then return end
		started = true
		for i, t in ipairs(thumbData) do
			task.delay((i - 1) * 0.4, function() loadPreview(t.vp, i, t.ll) end)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not holder.Visible or not pages["Skins"].Visible then return end
		local t = os.clock()
		for _, item in ipairs(orbitTargets) do
			if item.cam and item.cam.Parent then
				local a = t * 0.85 + item.offset
				local pos = item.center + Vector3.new(math.sin(a) * item.dist, item.dist * 0.08, -math.cos(a) * item.dist)
				item.cam.CFrame = CFrame.lookAt(pos, item.center)
			end
		end
	end)
end

---------------------------------------------------------------- BONA MOVEMENT (ported from Velvet Movement v1.8, renamed to BONA)
do
	local MV = {
		Anim = {
			PeekLeft = "122321203757460", PeekRight = "76424982385842",
			CrouchIdle = "109602961761132", CrouchWalk = "134301743319119",
			HeadLock = "121974370703684", Slide = "78375600391909", Crawl = "106501741606953",
			Run = "77128372412361", Walk = "71118455586086",
		},
		CrouchSpeed = 7, CrawlSpeed = 4, RunMult = 1, WalkMult = 0.7, Accel = 45, Decel = 70, Fade = 0.2,
		SlideDur = 0.8, SlideDelay = 0.2, SlideBoost = 12, SlideAnimStart = 2.4, SlideAnimNormal = 1, SlideAnimEase = 0.67,
		PeekStart = 17, PeekFreeze = 0.35, FirstPerson = 1.2, FirstPersonExit = 1.8,
	}
	local P = {Enabled = true, Walking = false, RunAnim = MV.Anim.Run, WalkAnim = MV.Anim.Walk}

	local Chr, Hum, Head, Animator, Neck
	local Tracks, BaseTrack, PeekTrack = {}, nil, nil
	local Crouching, Crawling, RunOn, RunHeld, PeekDir = false, false, false, false, nil
	local Sliding, SlideBoostOn, SlideSpeed, SlideDir = false, false, 16, Vector3.new(0, 0, -1)
	local NormalSpeed, CurrentSpeed, wasActive = 16, 16, false
	local setupToken, slideToken, peekGen = 0, 0, 0
	local TurnAttach, TurnAlign
	local prevAuto, camOwned, HeadHidden, CrawlMoving = true, false, false, false
	local syncUI, SetCrawling, SetRun, SetCrouch
	local tCrouch, tCrawl, tRun, tPeekL, tPeekR
	local fb = {}

	local function Running() return RunOn or RunHeld end

	---------------------------------------------------------------- tracks
	local function LoadTrack(id, priority)
		local a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://" .. id
		local ok1, t = pcall(function() return Animator:LoadAnimation(a) end)
		if ok1 and t then
			t.Priority = priority
			t.Looped = true
			return t
		end
		return nil
	end
	local function RebuildLoco(kind)
		local old = Tracks[kind]
		if old then
			if BaseTrack == old then BaseTrack = nil end
			pcall(function() old:Stop(0) old:Destroy() end)
			Tracks[kind] = nil
		end
		if not Animator then return end
		local id = (kind == "Run") and P.RunAnim or P.WalkAnim
		if id and id ~= "" then Tracks[kind] = LoadTrack(id, Enum.AnimationPriority.Movement) end
	end
	local function SetupTracks()
		local A, AP = MV.Anim, Enum.AnimationPriority
		Tracks.CrouchIdle = LoadTrack(A.CrouchIdle, AP.Movement)
		Tracks.CrouchWalk = LoadTrack(A.CrouchWalk, AP.Movement)
		RebuildLoco("Run")
		RebuildLoco("Walk")
		Tracks.Crawl = LoadTrack(A.Crawl, AP.Movement)
		Tracks.PeekLeft = LoadTrack(A.PeekLeft, AP.Action)
		Tracks.PeekRight = LoadTrack(A.PeekRight, AP.Action)
		Tracks.HeadLock = LoadTrack(A.HeadLock, AP.Action2)
		Tracks.Slide = LoadTrack(A.Slide, AP.Action)
		if Tracks.Slide then Tracks.Slide.Looped = false end
	end
	local function SetupRotation(root)
		if TurnAlign then TurnAlign:Destroy() end
		if TurnAttach then TurnAttach:Destroy() end
		TurnAttach = Instance.new("Attachment")
		TurnAttach.Parent = root
		TurnAlign = Instance.new("AlignOrientation")
		TurnAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
		TurnAlign.Attachment0 = TurnAttach
		TurnAlign.Responsiveness = 11.5
		TurnAlign.MaxTorque = 100000
		TurnAlign.RigidityEnabled = false
		TurnAlign.Enabled = false
		TurnAlign.Parent = root
	end

	local function SetupCharacter(char)
		setupToken += 1
		slideToken += 1
		local tk = setupToken
		Chr, Hum, Head, Animator, Neck = nil, nil, nil, nil, nil
		Tracks, BaseTrack, PeekTrack = {}, nil, nil
		Sliding, SlideBoostOn, Crawling = false, false, false
		local h = char:WaitForChild("Humanoid")
		local hd = char:WaitForChild("Head")
		local root = char:WaitForChild("HumanoidRootPart")
		if tk ~= setupToken or not char.Parent then return end
		Chr, Hum, Head = char, h, hd
		local n = char:FindFirstChild("Neck", true)
		if n and n:IsA("Motor6D") then Neck = n end
		Animator = h:FindFirstChildOfClass("Animator")
		if not Animator then
			Animator = Instance.new("Animator")
			Animator.Parent = h
		end
		NormalSpeed = S.speedOn and 16 or h.WalkSpeed
		CurrentSpeed = h.WalkSpeed
		wasActive = false
		SetupTracks()
		SetupRotation(root)
	end

	---------------------------------------------------------------- base layer
	local function PlayBase(name)
		local t = Tracks[name]
		if not t then return end
		if BaseTrack == t and t.IsPlaying then return end
		if BaseTrack then BaseTrack:Stop(MV.Fade) end
		BaseTrack = t
		t:Play(MV.Fade)
	end
	local function StopBase()
		if BaseTrack then BaseTrack:Stop(MV.Fade) BaseTrack = nil end
	end
	local function CanLoco()
		if not Hum or Hum.FloorMaterial == Enum.Material.Air then return false end
		local st = Hum:GetState()
		return st ~= Enum.HumanoidStateType.Climbing and st ~= Enum.HumanoidStateType.Swimming
			and st ~= Enum.HumanoidStateType.Seated and st ~= Enum.HumanoidStateType.Freefall
			and st ~= Enum.HumanoidStateType.Jumping
	end
	local function UpdateBase()
		if not Hum or Hum.Health <= 0 or SlideBoostOn then return end
		if not P.Enabled then StopBase() return end
		if Crawling then StopBase() return end
		local moving = Hum.MoveDirection.Magnitude > 0.05
		if Crouching then
			PlayBase(moving and "CrouchWalk" or "CrouchIdle")
		elseif moving and Running() and Tracks.Run and CanLoco() then
			PlayBase("Run")
		elseif moving and P.Walking and not Running() and Tracks.Walk and CanLoco() then
			PlayBase("Walk")
		else
			StopBase()
		end
	end

	---------------------------------------------------------------- camera
	local function UpdateCamera()
		local cam = workspace.CurrentCamera
		if not cam or not Hum or not Head or FC.active or spectating then return end
		if PeekDir or Sliding or Crawling then
			cam.CameraSubject = Head
			camOwned = true
		elseif camOwned then
			cam.CameraSubject = Hum
			camOwned = false
		end
	end

	---------------------------------------------------------------- peek
	local function PlayPeek(name)
		local t = Tracks[name]
		if not t then return end
		if PeekTrack == t and t.IsPlaying then return end
		peekGen += 1
		local gen = peekGen
		if PeekTrack then PeekTrack:Stop(0) end
		PeekTrack = t
		t.Looped = false
		t:Play(0.05, 1, MV.PeekStart)
		task.spawn(function()
			while gen == peekGen and PeekTrack == t and t.IsPlaying do
				local len = t.Length
				if len > 0 then
					local freeze = math.max(0, len - MV.PeekFreeze)
					if t.TimePosition >= freeze then
						t.TimePosition = freeze
						t:AdjustSpeed(0)
						break
					end
				end
				task.wait()
			end
		end)
	end
	local function StopPeek()
		peekGen += 1
		if PeekTrack then PeekTrack:Stop(0.15) PeekTrack = nil end
	end
	local function UpdatePeek()
		if not Hum or Hum.Health <= 0 then return end
		local lock = Tracks.HeadLock
		if PeekDir and P.Enabled then
			if lock and not lock.IsPlaying then
				lock.Looped = true
				lock:Play(0, 1, 0)
				lock.TimePosition = 0
				lock:AdjustSpeed(0)
			end
			PlayPeek(PeekDir == "Left" and "PeekLeft" or "PeekRight")
		else
			StopPeek()
			if lock and lock.IsPlaying then lock:Stop(0.1) end
		end
		UpdateCamera()
	end
	local function StartPeek(dir)
		if not P.Enabled then return end
		PeekDir = dir
		UpdatePeek()
		syncUI()
	end
	local function EndPeek(dir)
		if PeekDir == dir then
			PeekDir = nil
			UpdatePeek()
			syncUI()
		end
	end

	---------------------------------------------------------------- speed (only writes WalkSpeed while a stance is active)
	local function BaseSpeed() return (S.speedOn and S.speed) or NormalSpeed end
	local function StanceSpeed()
		if Crawling then return MV.CrawlSpeed
		elseif Crouching then return MV.CrouchSpeed
		elseif Running() then return BaseSpeed() * MV.RunMult
		elseif P.Walking then return BaseSpeed() * MV.WalkMult end
		return nil
	end
	local function StepSpeed(dt)
		if not Hum or Hum.Health <= 0 or not P.Enabled then S.moveOwns = false return end
		if SlideBoostOn then
			CurrentSpeed = SlideSpeed
			wasActive = true
			S.moveOwns = true
			Hum.WalkSpeed = CurrentSpeed
			return
		end
		local target = StanceSpeed()
		if not target then
			if wasActive and math.abs(CurrentSpeed - BaseSpeed()) > 0.05 then
				target = BaseSpeed()
			else
				wasActive = false
				S.moveOwns = false
				CurrentSpeed = Hum.WalkSpeed
				return
			end
		else
			wasActive = true
		end
		S.moveOwns = true
		local delta = target - CurrentSpeed
		local rate = (delta > 0 and MV.Accel or MV.Decel) * dt
		CurrentSpeed += math.clamp(delta, -rate, rate)
		if math.abs(target - CurrentSpeed) < 0.001 then CurrentSpeed = target end
		Hum.WalkSpeed = CurrentSpeed
	end

	---------------------------------------------------------------- slide
	local function EndSlideTurn()
		if TurnAlign then
			TurnAlign.Enabled = false
			TurnAlign.Responsiveness = 11.5
		end
		if Hum then Hum.AutoRotate = prevAuto end
	end
	local function Slide()
		if not P.Enabled or Sliding or Crawling or not Hum or Hum.Health <= 0 then return end
		local track = Tracks.Slide
		if not track then return end
		local hum = Hum
		slideToken += 1
		local tk = slideToken
		Sliding = true

		local root = hum.RootPart
		local look = root and root.CFrame.LookVector or Vector3.new(0, 0, -1)
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
		SlideDir = flat.Unit
		prevAuto = hum.AutoRotate
		hum.AutoRotate = false
		if TurnAlign then
			TurnAlign.CFrame = CFrame.lookAt(Vector3.zero, SlideDir)
			TurnAlign.Responsiveness = 999
			TurnAlign.Enabled = true
		end
		UpdateCamera()
		track:Play(0.05, 1, MV.SlideAnimStart)

		task.spawn(function()
			local el = 0
			while el < MV.SlideAnimEase and tk == slideToken and track.IsPlaying do
				el += task.wait()
				if tk ~= slideToken then return end
				local a = math.clamp(el / MV.SlideAnimEase, 0, 1)
				local eased = 1 - (1 - a) ^ 3
				track:AdjustSpeed(MV.SlideAnimStart + (MV.SlideAnimNormal - MV.SlideAnimStart) * eased)
			end
			if tk == slideToken and track.IsPlaying then track:AdjustSpeed(MV.SlideAnimNormal) end
		end)

		task.wait(MV.SlideDelay)
		if tk ~= slideToken or hum ~= Hum then return end
		if hum.Health <= 0 then
			Sliding = false
			EndSlideTurn()
			UpdateCamera()
			return
		end
		SlideSpeed = CurrentSpeed + MV.SlideBoost
		SlideBoostOn = true
		CurrentSpeed = SlideSpeed
		S.moveOwns = true
		hum.WalkSpeed = SlideSpeed
		hum:Move(SlideDir, false)

		task.wait(MV.SlideDur - MV.SlideDelay)
		if tk ~= slideToken or hum ~= Hum then return end
		SlideBoostOn = false
		hum:Move(Vector3.zero, false)
		if track.IsPlaying then track:Stop(0.15) end
		Sliding = false
		EndSlideTurn()
		UpdateCamera()
		UpdateBase()
	end
	RunService:BindToRenderStep("BONASlideSteer", Enum.RenderPriority.Input.Value + 1, function()
		if not SlideBoostOn or not Hum or Hum.Health <= 0 then return end
		local cam = workspace.CurrentCamera
		if controls and cam then
			local ok1, mvv = pcall(function() return controls:GetMoveVector() end)
			if ok1 and mvv and mvv.Magnitude > 0.05 then
				local w = cam.CFrame:VectorToWorldSpace(mvv)
				w = Vector3.new(w.X, 0, w.Z)
				if w.Magnitude > 0.05 then SlideDir = w.Unit end
			end
		end
		Hum:Move(SlideDir, false)
		if TurnAlign then TurnAlign.CFrame = CFrame.lookAt(Vector3.zero, SlideDir) end
	end)

	---------------------------------------------------------------- crouch / crawl / run
	local function CancelStance()
		if Crawling then SetCrawling(false) end
		Crouching = false
	end
	SetRun = function(v)
		if v and not P.Enabled then return end
		if v then CancelStance() end
		RunOn = v
		UpdateBase()
		syncUI()
	end
	SetCrouch = function(v)
		if v and not P.Enabled then return end
		Crouching = v
		if v then RunOn = false end
		UpdateBase()
		syncUI()
	end
	SetCrawling = function(v)
		if not Hum or Hum.Health <= 0 or Crawling == v then return end
		if v and (not P.Enabled or Sliding) then return end
		local track = Tracks.Crawl
		if not track then return end
		Crawling = v
		if v then
			RunOn = false
			prevAuto = Hum.AutoRotate
			Hum.AutoRotate = false
			if TurnAlign then
				TurnAlign.Responsiveness = 11.5
				TurnAlign.Enabled = true
			end
			track:Play(0.15, 1, 1)
			CrawlMoving = false
			track:AdjustSpeed(0)
		else
			Hum.AutoRotate = prevAuto
			if TurnAlign then TurnAlign.Enabled = false end
			track:Stop(0.15)
			CrawlMoving = false
		end
		UpdateBase()
		UpdateCamera()
		syncUI()
	end
	local function UpdateCrawl()
		if not Crawling or not Hum or Hum.Health <= 0 then return end
		local md = Hum.MoveDirection
		if TurnAlign and md.Magnitude > 0.05 then
			TurnAlign.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(md.X, 0, md.Z))
		end
		local track = Tracks.Crawl
		if not track or not track.IsPlaying then return end
		local moving = md.Magnitude > 0.05
		if moving ~= CrawlMoving then
			CrawlMoving = moving
			track:AdjustSpeed(moving and 1 or 0)
		end
	end
	local function ResetAll()
		SetCrawling(false)
		Crouching, RunOn, RunHeld, PeekDir = false, false, false, nil
		UpdateBase()
		UpdatePeek()
		S.moveOwns = false
		syncUI()
	end

	---------------------------------------------------------------- loops + input
	RunService.Heartbeat:Connect(function()
		if not Hum or Hum.Health <= 0 or not P.Enabled then return end
		UpdateBase()
		UpdateCrawl()
	end)
	RunService.PreSimulation:Connect(function(dt)
		StepSpeed(dt)
		if Neck and PeekTrack and PeekTrack.IsPlaying then Neck.Transform = CFrame.identity end
	end)
	RunService:BindToRenderStep("BONAHeadHide", Enum.RenderPriority.Camera.Value + 1, function()
		local cam = workspace.CurrentCamera
		if not P.Enabled or not cam or not Head or not Head.Parent then return end
		local d = (cam.CFrame.Position - Head.Position).Magnitude
		local inFirst = HeadHidden and d < MV.FirstPersonExit or (not HeadHidden and d < MV.FirstPerson)
		if inFirst or HeadHidden then
			local v = inFirst and 1 or 0
			Head.LocalTransparencyModifier = v
			for _, c in ipairs(Chr:GetChildren()) do
				if c:IsA("Accessory") then
					local hd = c:FindFirstChild("Handle")
					if hd and hd:IsA("BasePart") then hd.LocalTransparencyModifier = v end
				end
			end
			HeadHidden = inFirst
		end
	end)
	UIS.InputBegan:Connect(function(input, gp)
		if gp or not P.Enabled or UIS:GetFocusedTextBox() then return end
		local k = input.KeyCode
		if k == Enum.KeyCode.C then SetCrouch(not Crouching)
		elseif k == Enum.KeyCode.X then SetCrawling(not Crawling)
		elseif k == Enum.KeyCode.Q then StartPeek("Left")
		elseif k == Enum.KeyCode.E then StartPeek("Right")
		elseif k == Enum.KeyCode.LeftControl then
			CancelStance()
			RunHeld = true
			UpdateBase()
			syncUI()
		end
	end)
	UIS.InputEnded:Connect(function(input)
		local k = input.KeyCode
		if k == Enum.KeyCode.Q then EndPeek("Left")
		elseif k == Enum.KeyCode.E then EndPeek("Right")
		elseif k == Enum.KeyCode.LeftControl and RunHeld then
			RunHeld = false
			UpdateBase()
			syncUI()
		end
	end)
	lp.CharacterAdded:Connect(function(char)
		Crouching, RunOn, RunHeld, PeekDir, HeadHidden, camOwned = false, false, false, nil, false, false
		SetupCharacter(char)
		syncUI()
	end)

	---------------------------------------------------------------- floating on-screen buttons (BONA style)
	local btnFrame = new("Frame", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -120),
		Size = UDim2.new(0, 160, 0, 126), BackgroundTransparency = 1, Visible = false}, gui)
	local wantButtons = UIS.TouchEnabled
	local function refreshButtons() btnFrame.Visible = wantButtons and not holder.Visible end
	holder:GetPropertyChangedSignal("Visible"):Connect(refreshButtons)
	refreshButtons()
	new("UIGridLayout", {CellSize = UDim2.new(0, 76, 0, 34), CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder}, btnFrame)
	local function fbtn(name, order, onDown, onUp)
		local b = new("TextButton", {LayoutOrder = order, Text = name, Font = Enum.Font.GothamBold, TextSize = 11,
			TextColor3 = WHITE, BackgroundColor3 = INK, BackgroundTransparency = 0.25, AutoButtonColor = false}, btnFrame)
		corner(b, 10)
		stroke(b, 0.55, BLUE)
		if onUp then
			b.MouseButton1Down:Connect(onDown)
			b.MouseButton1Up:Connect(onUp)
			b.MouseLeave:Connect(onUp)
		else
			b.Activated:Connect(onDown)
		end
		fb[name] = b
	end
	fbtn("CROUCH", 1, function() SetCrouch(not Crouching) end)
	fbtn("CRAWL", 2, function() SetCrawling(not Crawling) end)
	fbtn("PEEK L", 3, function() StartPeek("Left") end, function() EndPeek("Left") end)
	fbtn("PEEK R", 4, function() StartPeek("Right") end, function() EndPeek("Right") end)
	fbtn("RUN", 5, function() SetRun(not RunOn) end)
	fbtn("SLIDE", 6, function() task.spawn(Slide) end)

	---------------------------------------------------------------- hub tab
	local pMove = addTab("Movement")
	local mvCard = listCard(pMove, "BONA Movement")
	toggle(mvCard, "Enable BONA Movement", function(v)
		P.Enabled = v
		if not v then ResetAll() end
	end, true)
	tCrouch = toggle(mvCard, "Crouch  (C)", function(v) SetCrouch(v) end)
	tCrawl = toggle(mvCard, "Crawl  (X)", function(v) SetCrawling(v) end)
	tRun = toggle(mvCard, "Run  (hold Ctrl)", function(v) SetRun(v) end)
	tPeekL = toggle(mvCard, "Peek Left  (Q)", function(v) if v then StartPeek("Left") else EndPeek("Left") end end)
	tPeekR = toggle(mvCard, "Peek Right  (E)", function(v) if v then StartPeek("Right") else EndPeek("Right") end end)
	button(mvCard, "Slide", function() task.spawn(Slide) end)
	toggle(mvCard, "Walking mode (slower until Run)", function(v) P.Walking = v UpdateBase() end)
	toggle(mvCard, "On-screen buttons (shown when the hub is closed)", function(v) wantButtons = v refreshButtons() end, UIS.TouchEnabled)

	local function ParseId(raw)
		local t = tostring(raw):gsub("%s+", ""):lower()
		t = t:gsub("^rbxassetid://", ""):gsub("^https?://www%.roblox%.com/asset/%?id=", "")
		if t:match("^%d+$") and #t <= 20 then return t end
		return nil
	end
	local animCard = listCard(pMove, "Animations  (id, Default or None)")
	local function animEditor(title, kind)
		local key = kind .. "Anim"
		local r = row(animCard, 34)
		txt(r, title, UDim2.new(0, 12, 0, 0), UDim2.new(0, 50, 1, 0))
		local box = new("TextBox", {Position = UDim2.new(0, 62, 0.5, -12), Size = UDim2.new(1, -74, 0, 24),
			BackgroundColor3 = INK, BackgroundTransparency = 0.3, BorderSizePixel = 0, TextColor3 = WHITE,
			PlaceholderText = "animation id", PlaceholderColor3 = MUTED, Font = Enum.Font.GothamMedium, TextSize = 12,
			ClearTextOnFocus = false, Text = P[key]}, r)
		corner(box, 8)
		local function commit(id)
			P[key] = id
			box.Text = id
			RebuildLoco(kind)
			UpdateBase()
		end
		box.FocusLost:Connect(function()
			local id = ParseId(box.Text)
			if id then commit(id) else box.Text = P[key] end
		end)
		button(animCard, title .. ": Default", function() commit(MV.Anim[kind]) end)
		button(animCard, title .. ": None (avatar's own)", function() commit("") end)
	end
	animEditor("Run", "Run")
	animEditor("Walk", "Walk")

	syncUI = function()
		if tCrouch then tCrouch(Crouching, true) end
		if tCrawl then tCrawl(Crawling, true) end
		if tRun then tRun(Running(), true) end
		if tPeekL then tPeekL(PeekDir == "Left", true) end
		if tPeekR then tPeekR(PeekDir == "Right", true) end
		local function mark(name, on) fb[name].BackgroundColor3 = on and BLUE2 or INK end
		mark("CROUCH", Crouching)
		mark("CRAWL", Crawling)
		mark("PEEK L", PeekDir == "Left")
		mark("PEEK R", PeekDir == "Right")
		mark("RUN", Running())
	end

	if lp.Character then task.spawn(SetupCharacter, lp.Character) end
end

---------------------------------------------------------------- DEATH FX (ported from BONA VFX | stage 1: engine + 8 effects)
do
	local Debris = game:GetService("Debris")
	local Workspace = game:GetService("Workspace")
	local rng = Random.new()
	local RANDOM_ID = "__random__"
	local DFX = {Selected = RANDOM_ID, SkipLocal = false, Enabled = true, MaxActive = 12, DefaultLifetime = 8}

	do
		local old = Workspace:FindFirstChild("BONA_LocalVFX")
		if old then old:Destroy() end
	end
	local EffectsFolder = Instance.new("Folder")
	EffectsFolder.Name = "BONA_LocalVFX"
	EffectsFolder.Parent = Workspace

	------------------------------------------------------------ UTIL
	local Util = {}
	function Util.Rand(a, b) return rng:NextNumber(a, b) end
	function Util.RandInt(a, b) return rng:NextInteger(a, b) end
	function Util.RandomDirection() return rng:NextUnitVector() end
	function Util.RandomHorizontal()
		local a = rng:NextNumber(0, math.pi * 2)
		return Vector3.new(math.cos(a), 0, math.sin(a))
	end
	function Util.Tween(inst, duration, props, style, direction)
		local t = TweenService:Create(inst, TweenInfo.new(duration, style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out), props)
		t:Play()
		return t
	end
	function Util.NewPart(parent, props)
		local p = Instance.new("Part")
		p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Material = Enum.Material.SmoothPlastic
		p.Size = Vector3.new(1, 1, 1)
		for k, v in pairs(props or {}) do p[k] = v end
		p.Parent = parent
		return p
	end
	function Util.Move(parts, cfs)
		if #parts == 0 then return end
		if parts[1]:IsDescendantOf(Workspace) then
			local ok1 = pcall(Workspace.BulkMoveTo, Workspace, parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
			if ok1 then return end
		end
		for i, p in ipairs(parts) do p.CFrame = cfs[i] end
	end
	function Util.GetRigType(model)
		local h = model:FindFirstChildOfClass("Humanoid")
		return (h and h.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
	end
	function Util.GetBounds(model)
		local ok1, cf, size = pcall(function() return model:GetBoundingBox() end)
		if ok1 and cf then return cf, size end
		local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
		return root and root.CFrame or CFrame.new(), Vector3.new(2, 5, 1)
	end
	function Util.GetGround(origin, ignoreList, maxDistance)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList or {}
		local res = Workspace:Raycast(origin, Vector3.new(0, -(maxDistance or 40), 0), params)
		return res and res.Position or nil
	end
	function Util.PointInPart(part)
		local s = part.Size
		return part.CFrame:PointToWorldSpace(Vector3.new(rng:NextNumber(-0.5, 0.5) * s.X,
			rng:NextNumber(-0.5, 0.5) * s.Y, rng:NextNumber(-0.5, 0.5) * s.Z))
	end
	function Util.Hide(part)
		part.Transparency = 1
		for _, d in ipairs(part:GetChildren()) do
			if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
		end
	end
	function Util.FadeOut(part, duration, style, direction)
		Util.Tween(part, duration, {Transparency = 1}, style, direction)
		for _, d in ipairs(part:GetChildren()) do
			if d:IsA("Decal") or d:IsA("Texture") then Util.Tween(d, duration, {Transparency = 1}, style, direction) end
		end
	end
	function Util.StripTextures(model, removeDecals)
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("Clothing") or d:IsA("ShirtGraphic") or d:IsA("SurfaceAppearance") then d:Destroy()
			elseif d:IsA("MeshPart") then d.TextureID = ""
			elseif d:IsA("SpecialMesh") then d.TextureId = ""
			elseif removeDecals and (d:IsA("Decal") or d:IsA("Texture")) then d:Destroy() end
		end
	end
	function Util.Recolor(parts, color, material, duration, transparency)
		for _, p in ipairs(parts) do
			if material then p.Material = material end
			local goal = {Color = color}
			if transparency then goal.Transparency = transparency end
			if duration and duration > 0 then Util.Tween(p, duration, goal)
			else for k, v in pairs(goal) do p[k] = v end end
		end
	end
	function Util.Emitter(parent, props)
		local e = Instance.new("ParticleEmitter")
		for k, v in pairs(props or {}) do e[k] = v end
		e.Parent = parent
		return e
	end
	function Util.Emit(parent, count, props)
		local copy = table.clone(props or {})
		copy.Enabled = false; copy.Rate = 0
		local e = Util.Emitter(parent, copy)
		e:Emit(count)
		return e
	end
	function Util.SmokeProps(color, maxSize)
		return {
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new(color or Color3.fromRGB(80, 80, 80)),
			Size = NumberSequence.new((maxSize or 6) * 0.4, maxSize or 6),
			Transparency = NumberSequence.new(0.35, 1),
			Lifetime = NumberRange.new(1.2, 2.2), Speed = NumberRange.new(4, 10),
			SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, 4, 0),
		}
	end
	function Util.SparkProps(color, size)
		return {
			Color = ColorSequence.new(color or Color3.new(1, 1, 1)),
			Size = NumberSequence.new(size or 0.5, 0),
			Lifetime = NumberRange.new(0.5, 1.2), Speed = NumberRange.new(8, 22),
			SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
		}
	end
	function Util.Flash(parent, position, color, brightness, range, duration)
		duration = duration or 0.5
		local p = Util.NewPart(parent, {Transparency = 1, CFrame = CFrame.new(position)})
		local light = Instance.new("PointLight")
		light.Color = color; light.Brightness = brightness or 6; light.Range = range or 18
		light.Parent = p
		Util.Tween(light, duration, {Brightness = 0, Range = 0})
		Debris:AddItem(p, duration + 0.2)
		return p
	end
	function Util.Shockwave(parent, position, color, maxDiameter, duration)
		local ring = Util.NewPart(parent, {
			Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 1, 1),
			CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
			Color = color, Material = Enum.Material.Neon, Transparency = 0.25,
		})
		Util.Tween(ring, duration or 0.5, {Size = Vector3.new(0.3, maxDiameter, maxDiameter), Transparency = 1})
		return ring
	end
	function Util.Lightning(parent, from, to, color, thickness, segments)
		segments = segments or 10
		local dir = to - from
		local points = {from}
		for i = 1, segments - 1 do
			table.insert(points, from + dir * (i / segments) + Vector3.new(Util.Rand(-1, 1), 0, Util.Rand(-1, 1)) * 3)
		end
		table.insert(points, to)
		local bolts = {}
		for i = 1, #points - 1 do
			local a, b = points[i], points[i + 1]
			local len = (b - a).Magnitude
			if len > 0.01 then
				table.insert(bolts, Util.NewPart(parent, {
					Size = Vector3.new(thickness or 0.6, thickness or 0.6, len),
					CFrame = CFrame.lookAt(a, b, Vector3.new(1, 0, 0)) * CFrame.new(0, 0, -len / 2),
					Color = color, Material = Enum.Material.Neon,
				}))
			end
		end
		return bolts
	end
	function Util.Shake(parts, duration, intensity)
		local base = {}
		for i, p in ipairs(parts) do base[i] = p.CFrame end
		local start = os.clock()
		local conn
		conn = RunService.Heartbeat:Connect(function()
			local done = (os.clock() - start) >= duration
			for i, p in ipairs(parts) do
				if p.Parent then
					p.CFrame = done and base[i] or (base[i] + Vector3.new(Util.Rand(-1, 1), Util.Rand(-1, 1), Util.Rand(-1, 1)) * intensity)
				end
			end
			if done then conn:Disconnect() end
		end)
	end
	function Util.MakeShards(parent, part, count, opts)
		opts = opts or {}
		local items = {}
		local origin = opts.Origin or part.Position
		for _ = 1, count do
			local s = Util.Rand(opts.MinSize or 0.3, opts.MaxSize or 0.8)
			local color = opts.Color or part.Color
			if type(color) == "function" then color = color() end
			local shard = Util.NewPart(parent, {
				Size = Vector3.new(s, s * Util.Rand(0.4, 1), s * Util.Rand(0.5, 1.2)),
				CFrame = CFrame.new(Util.PointInPart(part)) * CFrame.Angles(Util.Rand(0, 6.28), Util.Rand(0, 6.28), Util.Rand(0, 6.28)),
				Color = color, Material = opts.Material or part.Material, Transparency = opts.Transparency or 0,
			})
			local dir = shard.Position - origin
			dir = (dir.Magnitude > 0.1) and dir.Unit or Util.RandomDirection()
			table.insert(items, {
				Part = shard,
				Velocity = dir * Util.Rand(opts.MinSpeed or 15, opts.MaxSpeed or 40)
					+ Vector3.new(0, Util.Rand(opts.MinUp or 10, opts.MaxUp or 30), 0),
				Spin = Util.RandomDirection() * Util.Rand(5, 20),
			})
		end
		return items
	end
	function Util.Ballistic(items, opts)
		opts = opts or {}
		local gravity = opts.Gravity or 90
		local drag = opts.Drag or 0
		local bounce = opts.Bounce or 0.35
		local groundY = opts.GroundY or -math.huge
		local duration = opts.Duration or 4
		local fadeAfter = opts.FadeAfter or (duration - 1)
		local fadeTime = opts.FadeTime or 1
		local start = os.clock()
		local faded = false
		local parts, cfs = {}, {}
		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			local elapsed = os.clock() - start
			if elapsed > duration then conn:Disconnect() return end
			if not faded and elapsed >= fadeAfter then
				faded = true
				for _, it in ipairs(items) do
					if it.Part.Parent then Util.FadeOut(it.Part, fadeTime) end
				end
			end
			table.clear(parts); table.clear(cfs)
			for _, it in ipairs(items) do
				local p = it.Part
				if p.Parent and not it.Settled then
					local v = it.Velocity
					if drag > 0 then v = v * math.max(0, 1 - drag * dt) end
					v = v - Vector3.new(0, gravity * dt, 0)
					local cf = p.CFrame
					local pos = cf.Position + v * dt
					local spin = it.Spin or Vector3.zero
					local half = it.Radius or (math.max(p.Size.X, p.Size.Y, p.Size.Z) / 2)
					if pos.Y < groundY + half and v.Y < 0 then
						pos = Vector3.new(pos.X, groundY + half, pos.Z)
						if -v.Y < 4 then
							it.Settled = true
							v = Vector3.zero
						else
							v = Vector3.new(v.X * 0.65, -v.Y * bounce, v.Z * 0.65)
							spin = spin * 0.6
							it.Spin = spin
						end
					end
					it.Velocity = v
					table.insert(parts, p)
					table.insert(cfs, CFrame.new(pos) * cf.Rotation * CFrame.Angles(spin.X * dt, spin.Y * dt, spin.Z * dt))
				end
			end
			Util.Move(parts, cfs)
		end)
	end

	------------------------------------------------------------ EFFECT REGISTRY
	local Effects, EffectsByName = {}, {}
	local function AddEffect(name, description, playFunction, lifetime)
		local def = {Name = name, Description = description or "", Play = playFunction, Lifetime = lifetime or DFX.DefaultLifetime}
		local existing = EffectsByName[name]
		if existing then
			local idx = table.find(Effects, existing)
			if idx then table.remove(Effects, idx) end
		end
		table.insert(Effects, def)
		EffectsByName[name] = def
		return def
	end

	------------------------------------------------------------ EFFECTS
	AddEffect("Shatter", "The body breaks into glassy shards.", function(ctx)
		Util.Flash(ctx.Folder, ctx.Center, Color3.fromRGB(200, 235, 255), 5, 18, 0.35)
		local items = {}
		for _, part in ipairs(ctx.Parts) do
			for _, it in ipairs(Util.MakeShards(ctx.Folder, part, 6, {Material = Enum.Material.Glass, Transparency = 0.15, Origin = ctx.Center})) do
				table.insert(items, it)
			end
			Util.Hide(part)
		end
		Util.Ballistic(items, {GroundY = ctx.Ground.Y, Duration = 5, FadeAfter = 3.5, FadeTime = 1.3})
	end, 7)

	AddEffect("Disintegrate", "Turns to dust and blows away in the wind.", function(ctx)
		local wind = Util.RandomHorizontal() * Util.Rand(10, 16)
		for _, part in ipairs(ctx.Parts) do
			local vol = part.Size.X * part.Size.Y * part.Size.Z
			for _ = 1, math.clamp(math.floor(vol * 2.2), 4, 14) do
				local s = Util.Rand(0.2, 0.45)
				local dust = Util.NewPart(ctx.Folder, {
					Size = Vector3.new(s, s, s),
					CFrame = CFrame.new(Util.PointInPart(part)) * CFrame.Angles(Util.Rand(0, 6), Util.Rand(0, 6), Util.Rand(0, 6)),
					Color = part.Color,
				})
				task.delay(Util.Rand(0.1, 1.4), function()
					if not dust.Parent then return end
					local drift = wind + Vector3.new(Util.Rand(-3, 3), Util.Rand(2, 8), Util.Rand(-3, 3))
					Util.Tween(dust, Util.Rand(1.4, 2.4), {
						CFrame = (dust.CFrame + drift) * CFrame.Angles(Util.Rand(-3, 3), Util.Rand(-3, 3), 0),
						Transparency = 1,
					}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
				end)
			end
			task.delay(Util.Rand(0, 1), function() if part.Parent then Util.FadeOut(part, 0.5) end end)
		end
	end, 6)

	AddEffect("Explosion", "Blows the body apart in a fiery blast.", function(ctx)
		local c = ctx.Center
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(c)})
		Util.Flash(ctx.Folder, c, Color3.fromRGB(255, 170, 60), 10, 30, 0.6)
		Util.Shockwave(ctx.Folder, ctx.Ground + Vector3.new(0, 0.2, 0), Color3.fromRGB(255, 200, 120), 28, 0.5)
		Util.Emit(anchor, 45, {
			Texture = "rbxasset://textures/particles/fire_main.dds",
			Color = ColorSequence.new(Color3.fromRGB(255, 200, 80), Color3.fromRGB(255, 60, 20)),
			Size = NumberSequence.new(4, 0), Transparency = NumberSequence.new(0, 1),
			Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(20, 40),
			SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
		})
		Util.Emit(anchor, 25, Util.SmokeProps(Color3.fromRGB(60, 60, 60), 9))
		local items = {}
		for _, part in ipairs(ctx.Parts) do
			local dir = part.Position - c
			dir = (dir.Magnitude > 0.5) and dir.Unit or Util.RandomDirection()
			table.insert(items, {Part = part, Velocity = dir * Util.Rand(35, 60) + Vector3.new(0, Util.Rand(25, 45), 0),
				Spin = Util.RandomDirection() * Util.Rand(8, 18)})
			Util.Tween(part, 0.5, {Color = Color3.fromRGB(35, 30, 28)})
		end
		Util.Ballistic(items, {GroundY = ctx.Ground.Y, Duration = 4.5, FadeAfter = 3, FadeTime = 1.2})
	end, 7)

	AddEffect("Freeze & Shatter", "Frozen solid, then it bursts into ice.", function(ctx)
		local ice = Color3.fromRGB(150, 220, 255)
		Util.StripTextures(ctx.Ghost, true)
		Util.Recolor(ctx.Parts, ice, Enum.Material.Ice, 0.4, 0.1)
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(ctx.Center)})
		local frost = Util.SparkProps(Color3.new(1, 1, 1), 0.6)
		frost.Speed = NumberRange.new(3, 9)
		Util.Emit(anchor, 30, frost)
		Util.Shake(ctx.Parts, 1.2, 0.08)
		task.wait(1.4)
		if not ctx.Folder.Parent then return end
		Util.Flash(ctx.Folder, ctx.Center, ice, 6, 20, 0.4)
		Util.Shockwave(ctx.Folder, ctx.Ground + Vector3.new(0, 0.2, 0), ice, 18, 0.5)
		local items = {}
		for _, part in ipairs(ctx.Parts) do
			for _, it in ipairs(Util.MakeShards(ctx.Folder, part, 5, {
				Color = function() return ice:Lerp(Color3.new(1, 1, 1), Util.Rand(0, 0.5)) end,
				Material = Enum.Material.Ice, Transparency = 0.1, Origin = ctx.Center})) do
				table.insert(items, it)
			end
			Util.Hide(part)
		end
		Util.Emit(anchor, 40, frost)
		Util.Ballistic(items, {GroundY = ctx.Ground.Y, Duration = 4, FadeAfter = 2.8, FadeTime = 1.1})
	end, 8)

	AddEffect("Petrify", "Turns to stone, then crumbles to rubble.", function(ctx)
		local stone = Color3.fromRGB(120, 120, 126)
		Util.StripTextures(ctx.Ghost, true)
		Util.Recolor(ctx.Parts, stone, Enum.Material.Slate, 0.9, 0)
		task.wait(1.7)
		if not ctx.Folder.Parent then return end
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(ctx.Ground + Vector3.new(0, 1, 0))})
		Util.Emit(anchor, 25, Util.SmokeProps(Color3.fromRGB(140, 140, 140), 6))
		local items = {}
		for _, part in ipairs(ctx.Parts) do
			for _, it in ipairs(Util.MakeShards(ctx.Folder, part, 5, {
				Color = function() return stone:Lerp(Color3.new(0, 0, 0), Util.Rand(0, 0.4)) end,
				Material = Enum.Material.Slate, MinSize = 0.4, MaxSize = 0.9,
				MinSpeed = 2, MaxSpeed = 9, MinUp = 0, MaxUp = 6, Origin = ctx.Center})) do
				table.insert(items, it)
			end
			Util.Hide(part)
		end
		Util.Ballistic(items, {GroundY = ctx.Ground.Y, Duration = 4, FadeAfter = 2.8, FadeTime = 1.1, Bounce = 0.25})
	end, 8)

	AddEffect("Lightning Strike", "A bolt from the sky fries the body.", function(ctx)
		local color = Color3.fromRGB(190, 220, 255)
		local top = ctx.Center + Vector3.new(Util.Rand(-6, 6), 70, Util.Rand(-6, 6))
		Util.StripTextures(ctx.Ghost, true)
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(ctx.Center)})
		for i = 1, 3 do
			local bolts = Util.Lightning(ctx.Folder, top, ctx.Center, color, 0.9)
			Util.Flash(ctx.Folder, ctx.Center, color, 12, 40, 0.15)
			if i == 1 then
				Util.Recolor(ctx.Parts, Color3.fromRGB(25, 25, 25), Enum.Material.Slate, 0.08)
				Util.Emit(anchor, 40, Util.SparkProps(color, 0.4))
				Util.Shockwave(ctx.Folder, ctx.Ground + Vector3.new(0, 0.2, 0), color, 20, 0.4)
			end
			task.wait(0.08)
			for _, b in ipairs(bolts) do b:Destroy() end
			task.wait(0.06)
		end
		if not ctx.Folder.Parent then return end
		Util.Shake(ctx.Parts, 0.7, 0.15)
		Util.Emit(anchor, 25, Util.SmokeProps(Color3.fromRGB(50, 50, 50), 5))
		task.wait(0.8)
		for _, p in ipairs(ctx.Parts) do Util.FadeOut(p, 1.2) end
	end, 5)

	AddEffect("Ascend", "Turns into light and rises to the sky.", function(ctx)
		local gold = Color3.fromRGB(255, 244, 200)
		Util.Recolor(ctx.Parts, Color3.new(1, 1, 1), Enum.Material.Neon, 0.4, 0.1)
		local pillar = Util.NewPart(ctx.Folder, {
			Shape = Enum.PartType.Cylinder, Size = Vector3.new(90, 5, 5),
			CFrame = CFrame.new(ctx.Ground + Vector3.new(0, 45, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = gold, Material = Enum.Material.Neon, Transparency = 0.55,
		})
		Util.Tween(pillar, 2.8, {Size = Vector3.new(90, 0.4, 0.4), Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		Util.Flash(ctx.Folder, ctx.Center, gold, 8, 28, 2.5)
		Util.Shockwave(ctx.Folder, ctx.Ground + Vector3.new(0, 0.2, 0), gold, 16, 0.8)
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(ctx.Center)})
		local sparkles = Util.Emitter(anchor, {
			Rate = 70, Color = ColorSequence.new(gold), Size = NumberSequence.new(0.5, 0),
			Lifetime = NumberRange.new(0.8, 1.5), Speed = NumberRange.new(1, 5),
			SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
		})
		task.wait(0.5)
		if not ctx.Folder.Parent then return end
		for _, p in ipairs(ctx.Parts) do
			Util.Tween(p, 2.6, {CFrame = p.CFrame + Vector3.new(0, 30, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			Util.FadeOut(p, 2.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
		Util.Tween(anchor, 2.6, {CFrame = anchor.CFrame + Vector3.new(0, 30, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(2.6)
		sparkles.Enabled = false
	end, 6)

	AddEffect("Ghost Soul", "A translucent soul drifts up and fades.", function(ctx)
		local blue = Color3.fromRGB(180, 225, 255)
		Util.Recolor(ctx.Parts, blue, Enum.Material.Neon, 0.35, 0.45)
		local anchor = Util.NewPart(ctx.Folder, {Transparency = 1, CFrame = CFrame.new(ctx.Center)})
		local wisps = Util.SmokeProps(blue, 3)
		wisps.Rate = 25
		wisps.Acceleration = Vector3.new(0, 2, 0)
		local wispEmitter = Util.Emitter(anchor, wisps)
		task.wait(0.4)
		if not ctx.Folder.Parent then return end
		local duration = 3.4
		for _, p in ipairs(ctx.Parts) do Util.FadeOut(p, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In) end
		local parts, base, cfs = {}, {}, {}
		for i, p in ipairs(ctx.Parts) do parts[i] = p; base[i] = p.CFrame end
		parts[#parts + 1] = anchor
		base[#base + 1] = anchor.CFrame
		local start = os.clock()
		while ctx.Folder.Parent do
			local t = (os.clock() - start) / duration
			if t >= 1 then break end
			local offset = Vector3.new(math.sin(t * 14) * 1.1 * t, 24 * t * t, math.cos(t * 11) * 1.1 * t)
			for i = 1, #parts do cfs[i] = base[i] + offset end
			Util.Move(parts, cfs)
			RunService.Heartbeat:Wait()
		end
		wispEmitter.Enabled = false
	end, 6)

	-- >>> NEXT STAGES: more effects get added right above this line <<<

	------------------------------------------------------------ ENGINE
	local function trySet(inst, prop, value) pcall(function() inst[prop] = value end) end

	local function makeGhost(model, parent)
		local ghost
		pcall(function()
			local was = model.Archivable
			model.Archivable = true
			ghost = model:Clone()
			model.Archivable = was
		end)
		if not ghost then
			ghost = Instance.new("Model")
			for _, d in ipairs(model:GetDescendants()) do
				if d:IsA("BasePart") then
					pcall(function()
						local was = d.Archivable
						d.Archivable = true
						local copy = d:Clone()
						d.Archivable = was
						if copy then copy.Parent = ghost end
					end)
				end
			end
		end
		ghost.Name = "Ghost"
		for _, d in ipairs(ghost:GetDescendants()) do
			if d:IsA("LuaSourceContainer") or d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("WeldConstraint")
				or d:IsA("Sound") or d:IsA("ForceField") or d:IsA("BillboardGui") or d:IsA("ParticleEmitter")
				or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("Trail") or d:IsA("Beam")
				or d:IsA("Highlight") or d:IsA("Animator") or d:IsA("BodyMover") then
				d:Destroy()
			end
		end
		local root = ghost:FindFirstChild("HumanoidRootPart")
		if root then root:Destroy() end
		for _, d in ipairs(ghost:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored = true; d.CanCollide = false; d.CanTouch = false; d.CanQuery = false
			elseif d:IsA("Humanoid") then
				trySet(d, "BreakJointsOnDeath", false)
				trySet(d, "RequiresNeck", false)
				trySet(d, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None)
				trySet(d, "HealthDisplayType", Enum.HumanoidHealthDisplayType.AlwaysOff)
				trySet(d, "EvaluateStateMachine", false)
			end
		end
		ghost.Parent = parent
		return ghost
	end

	local hiddenModels = {}
	local function hideModel(model)
		if hiddenModels[model] then return end
		local isLocal = (model == lp.Character)
		local undo = {}
		local function remember(inst, prop, newValue)
			local old = inst[prop]
			inst[prop] = newValue
			table.insert(undo, function() inst[prop] = old end)
		end
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				remember(d, "Transparency", 1)
				remember(d, "CanCollide", false)
				remember(d, "CanTouch", false)
				remember(d, "CanQuery", false)
				if isLocal then remember(d, "Anchored", true) end
			elseif d:IsA("Decal") or d:IsA("Texture") then remember(d, "Transparency", 1)
			elseif d:IsA("BillboardGui") then remember(d, "Enabled", false)
			elseif d:IsA("Humanoid") then remember(d, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None) end
		end
		hiddenModels[model] = function()
			hiddenModels[model] = nil
			for _, f in ipairs(undo) do pcall(f) end
		end
		model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(game) then hiddenModels[model] = nil end
		end)
	end
	local function restoreModel(model)
		local r = hiddenModels[model]
		if r then r() end
	end

	local function buildContext(model, effect)
		local cf, size = Util.GetBounds(model)
		local center = cf.Position
		local ctx = {IsPreview = false, Model = model, Humanoid = model:FindFirstChildOfClass("Humanoid"),
			Rig = Util.GetRigType(model), Center = center, Size = size, Height = size.Y}
		ctx.Ground = Util.GetGround(center, {model, EffectsFolder}) or (center - Vector3.new(0, size.Y / 2, 0))
		local folder = Instance.new("Folder")
		folder.Name = effect.Name
		folder.Parent = EffectsFolder
		ctx.Folder = folder
		ctx.Ghost = makeGhost(model, folder)
		ctx.Parts = {}
		for _, d in ipairs(ctx.Ghost:GetDescendants()) do
			if d:IsA("BasePart") and d.Transparency < 1 then table.insert(ctx.Parts, d) end
		end
		ctx.Head = ctx.Ghost:FindFirstChild("Head")
		ctx.Torso = ctx.Ghost:FindFirstChild("UpperTorso") or ctx.Ghost:FindFirstChild("Torso")
		ctx.Root = ctx.Torso or ctx.Parts[1]
		return ctx
	end

	local activeEffects = 0
	local function playEffect(model, effect)
		if activeEffects >= DFX.MaxActive then return end
		local ok1, ctx = pcall(buildContext, model, effect)
		if not ok1 then warn("[DeathFX] could not prepare '" .. effect.Name .. "': " .. tostring(ctx)) return end
		activeEffects += 1
		hideModel(model)
		task.delay(effect.Lifetime or DFX.DefaultLifetime, function()
			activeEffects -= 1
			if ctx.Folder then ctx.Folder:Destroy() end
		end)
		task.spawn(function()
			local success, err = pcall(effect.Play, ctx)
			if not success then
				warn("[DeathFX] effect '" .. effect.Name .. "' errored: " .. tostring(err))
				restoreModel(model)
				if ctx.Folder then ctx.Folder:Destroy() end
			end
		end)
	end

	local function pickEffect()
		if #Effects == 0 then return nil end
		if DFX.Selected == RANDOM_ID then return Effects[rng:NextInteger(1, #Effects)] end
		return EffectsByName[DFX.Selected] or Effects[1]
	end

	local tracked = {}
	local function untrack(h)
		local conns = tracked[h]
		if conns then
			for _, c in ipairs(conns) do c:Disconnect() end
			tracked[h] = nil
		end
	end
	local function trackHumanoid(h)
		if tracked[h] or h:IsDescendantOf(EffectsFolder) then return end
		local conns = {}
		tracked[h] = conns
		local handled = h.Health <= 0
		local function died()
			if handled then return end
			handled = true
			if not DFX.Enabled then return end
			local model = h.Parent
			if not model or not model:IsA("Model") then return end
			if DFX.SkipLocal and model == lp.Character then return end
			local effect = pickEffect()
			if effect then playEffect(model, effect) end
		end
		table.insert(conns, h.Died:Connect(died))
		table.insert(conns, h.HealthChanged:Connect(function(health)
			if health <= 0 then died()
			elseif handled then
				handled = false
				if h.Parent then restoreModel(h.Parent) end
			end
		end))
		table.insert(conns, h.AncestryChanged:Connect(function()
			if not h:IsDescendantOf(Workspace) then untrack(h) end
		end))
	end
	Workspace.DescendantAdded:Connect(function(inst) if inst:IsA("Humanoid") then trackHumanoid(inst) end end)
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst:IsA("Humanoid") then trackHumanoid(inst) end
	end

	local previewDebounce = false
	local function previewSelected()
		if previewDebounce then return false, "Please wait a moment..." end
		local char = lp.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return false, "No character to preview on" end
		local effect = pickEffect()
		if not effect then return false, "No effects registered" end
		previewDebounce = true
		task.delay(0.6, function() previewDebounce = false end)
		local dummy = makeGhost(char, EffectsFolder)
		dummy.Name = "PreviewDummy"
		local pivot = dummy:GetPivot()
		local target = root.Position + root.CFrame.LookVector * 10
		dummy:PivotTo(CFrame.new(target) * pivot.Rotation * CFrame.Angles(0, math.pi, 0))
		Debris:AddItem(dummy, (effect.Lifetime or DFX.DefaultLifetime) + 2)
		playEffect(dummy, effect)
		return true, "Previewing: " .. effect.Name
	end

	------------------------------------------------------------ HUB TAB
	local pFx = addTab("Death FX")
	local fxCard = listCard(pFx, "Death Effects")
	local function selName() return DFX.Selected == RANDOM_ID and "Random (every death)" or DFX.Selected end
	local fxStatus = txt(fxCard, "Selected: " .. selName(), UDim2.new(), UDim2.new(1, 0, 0, 18), {color = MUTED, size = 12})
	toggle(fxCard, "Enable death effects", function(v) DFX.Enabled = v end, true)
	toggle(fxCard, "Skip my own character", function(v) DFX.SkipLocal = v end)

	local fxList = listCard(pFx, "Effects (" .. #Effects .. ")")
	local fxRows = {}
	local function refreshSel()
		for id, r in pairs(fxRows) do
			local on = DFX.Selected == id
			r.Color = on and BLUE or WHITE
			r.Transparency = on and 0.1 or 0.82
		end
		fxStatus.Text = "Selected: " .. selName()
	end
	button(fxCard, "Preview in the world", function()
		local _, msg = previewSelected()
		fxStatus.Text = msg
		task.delay(1.6, function() fxStatus.Text = "Selected: " .. selName() end)
	end)
	local function addFxRow(id, title, desc)
		local r = row(fxList, 40)
		fxRows[id] = stroke(r, 0.82)
		txt(r, title, UDim2.new(0, 12, 0, 4), UDim2.new(1, -24, 0, 16), {font = Enum.Font.GothamBold, size = 12})
		txt(r, desc, UDim2.new(0, 12, 0, 21), UDim2.new(1, -24, 0, 14), {color = MUTED, size = 10})
		local b = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, r)
		b.Activated:Connect(function() DFX.Selected = id refreshSel() end)
	end
	addFxRow(RANDOM_ID, "Random", "A different random effect on every death")
	for _, def in ipairs(Effects) do addFxRow(def.Name, def.Name, def.Description) end
	refreshSel()
end

---------------------------------------------------------------- EXECUTOR (code editor with line numbers, New Line button, undo, execute)
do
	local RED = Color3.fromRGB(255, 120, 130)
	local GREEN = Color3.fromRGB(120, 230, 165)

	local pExec = addTab("Executor")
	local exCard = listCard(pExec, "BONA Executor")

	-- editor frame -----------------------------------------------------
	local ed = new("Frame", {Size = UDim2.new(1, 0, 0, 190), BackgroundColor3 = INK, BackgroundTransparency = 0.25,
		BorderSizePixel = 0, ClipsDescendants = true}, exCard)
	corner(ed, 10); stroke(ed, 0.6, BLUE)

	local scroll = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, ScrollBarImageColor3 = BLUE, ScrollingDirection = Enum.ScrollingDirection.XY,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY}, ed)
	new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 8)}, scroll)

	local FONT, SIZE = Enum.Font.Code, 13
	local gutter = new("TextLabel", {Size = UDim2.new(0, 34, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Font = FONT, TextSize = SIZE, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top, Text = "1"}, scroll)
	new("Frame", {Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.85, BorderSizePixel = 0}, scroll)

	local box = new("TextBox", {Position = UDim2.new(0, 46, 0, 0), Size = UDim2.new(0, 280, 0, 170),
		AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, BorderSizePixel = 0, Font = FONT, TextSize = SIZE,
		TextColor3 = Color3.fromRGB(235, 240, 255), PlaceholderText = "-- write your script here", PlaceholderColor3 = MUTED,
		MultiLine = true, TextWrapped = false, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, Text = '-- BONA Executor\nprint("Hello from BONA")'}, scroll)

	-- status line --------------------------------------------------------
	local status = new("TextLabel", {Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = MUTED, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, Text = "Ready"}, exCard)
	local function setStatus(msg, color)
		status.Text = msg
		status.TextColor3 = color or MUTED
	end

	-- line numbers -------------------------------------------------------
	local function lineCount(text)
		local _, n = text:gsub("\n", "")
		return n + 1
	end
	local function refreshGutter()
		local n = lineCount(box.Text)
		local parts = table.create(n)
		for i = 1, n do parts[i] = tostring(i) end
		gutter.Text = table.concat(parts, "\n")
	end

	-- undo history -------------------------------------------------------
	local hist, suppress, snapTok = {box.Text}, false, 0
	local function snapshot()
		if box.Text ~= hist[#hist] then
			table.insert(hist, box.Text)
			if #hist > 40 then table.remove(hist, 1) end
		end
	end
	box:GetPropertyChangedSignal("Text"):Connect(function()
		refreshGutter()
		if suppress then return end
		snapTok += 1
		local tk = snapTok
		task.delay(0.8, function() if tk == snapTok then snapshot() end end)
	end)
	refreshGutter()

	-- cursor tracking (tapping a button unfocuses the box, so remember the last position) ----
	local lastCursor
	box:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		if box.CursorPosition > 0 then lastCursor = box.CursorPosition end
	end)

	local function scrollToCursor(pos)
		local before = box.Text:sub(1, pos - 1)
		local line = lineCount(before) - 1
		local lines = lineCount(box.Text)
		local lh = (box.TextBounds.Y > 0) and (box.TextBounds.Y / lines) or SIZE
		local y = line * lh
		local view = scroll.AbsoluteWindowSize.Y - 14
		local cp = scroll.CanvasPosition
		if y < cp.Y then
			scroll.CanvasPosition = Vector2.new(cp.X, y)
		elseif y + lh > cp.Y + view then
			scroll.CanvasPosition = Vector2.new(cp.X, y + lh - view)
		end
	end

	-- insert text at the cursor; newline mode keeps (and extends) the indentation ---------
	local function insertAtCursor(ins, newline)
		snapshot()
		local text = box.Text
		local pos = math.clamp(lastCursor or (#text + 1), 1, #text + 1)
		local before, after = text:sub(1, pos - 1), text:sub(pos)
		local add = ins
		if newline then
			local cur = before:match("([^\n]*)$") or ""
			local indent = cur:match("^[ \t]*") or ""
			local t = cur:match("^%s*(.-)%s*$") or ""
			if t:match("then$") or t:match("do$") or t == "else" or t:match("repeat$") or t:match("{$")
				or (t:match("%)$") and t:find("function", 1, true)) then
				indent = indent .. "    "
			end
			add = "\n" .. indent
		end
		box.Text = before .. add .. after
		local newPos = #before + #add + 1
		lastCursor = newPos
		box:CaptureFocus()
		task.wait()
		box.CursorPosition = newPos
		scrollToCursor(newPos)
	end

	-- buttons -------------------------------------------------------------
	local function btnRow(items)
		local r = new("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1}, exCard)
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6)}, r)
		local n = #items
		for _, it in ipairs(items) do
			local b = new("TextButton", {Text = it[1], Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
				BackgroundColor3 = it.accent and BLUE2 or WHITE, BackgroundTransparency = it.accent and 0.15 or 0.9,
				AutoButtonColor = false, Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 1, 0)}, r)
			corner(b, 10); stroke(b, 0.75, it.accent and BLUE or WHITE)
			b.Activated:Connect(it[2])
		end
	end

	local function runCode()
		local code = box.Text
		if (code:gsub("%s", "")) == "" then setStatus("Nothing to run") return end
		local loader = loadstring or load
		if not loader then setStatus("Not work: loadstring is not available here", RED) return end
		local fn, err = loader(code)
		if not fn then
			setStatus("Not work: syntax error - " .. tostring(err), RED)
			warn("[BONA Executor] Not work: syntax error - " .. tostring(err))
			return
		end
		setStatus("Running...")
		task.spawn(function()
			local ok1, e = pcall(fn)
			if ok1 then
				setStatus("Successfully", GREEN)
				print("[BONA Executor] Successfully")
			else
				setStatus("Not work: " .. tostring(e), RED)
				warn("[BONA Executor] Not work: " .. tostring(e))
			end
		end)
	end

	btnRow({
		{"New Line", function() insertAtCursor("", true) end},
		{"Tab", function() insertAtCursor("    ", false) end},
		{"Undo", function()
			snapshot()
			if #hist > 1 then
				table.remove(hist)
				suppress = true
				box.Text = hist[#hist]
				suppress = false
				refreshGutter()
				setStatus("Undone")
			end
		end},
		{"Clear", function()
			snapshot()
			box.Text = ""
			lastCursor = nil
			setStatus("Cleared")
		end},
	})
	btnRow({
		{"Execute", runCode, accent = true},
		{"Copy", function()
			local fn = setclipboard or toclipboard
			if fn then pcall(fn, box.Text) setStatus("Copied", GREEN) else setStatus("Clipboard is not available here", RED) end
		end},
		{"Paste", function()
			local fn = readclipboard or getclipboard
			if not fn then setStatus("Clipboard is not available here", RED) return end
			local ok1, clip = pcall(fn)
			if ok1 and type(clip) == "string" and clip ~= "" then
				insertAtCursor(clip, false)
				setStatus("Pasted", GREEN)
			else
				setStatus("Clipboard is empty", RED)
			end
		end},
	})
end

local pVis = addTab("Visuals")
local vc = listCard(pVis, "World & Players")
toggle(vc, "Player ESP", function(v)
	S.esp = v
	for _, p in ipairs(Players:GetPlayers()) do if v then addESP(p) else clearESP(p) end end
end)
toggle(vc, "Fullbright", function(v) setFullbright(v) end)

---------------------------------------------------------------- MISC PAGE
local pMisc = addTab("Misc")
local mc = listCard(pMisc, "Utilities")
toggle(mc, "Avatar Panel", function(v) avatarPanel.Visible = v end, true)
local loadAvatar
button(mc, "Refresh Avatar", function() if loadAvatar then loadAvatar() end end)
button(mc, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, lp) end)
button(mc, "Reset Character", function() local h = hum() if h then h.Health = 0 end end)
button(mc, "Destroy UI", function() stopFly() gui:Destroy() end)

---------------------------------------------------------------- AVATAR PANEL
txt(avatarPanel, "Avatar", UDim2.new(0, 14, 0, 12), UDim2.new(1, -28, 0, 16), {font = Enum.Font.GothamBold, size = 12, color = BLUE})
local avatarImg = new("ImageLabel", {Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 126),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.92, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Fit}, avatarPanel)
corner(avatarImg, 14); stroke(avatarImg, 0.75, BLUE)
txt(avatarPanel, lp.DisplayName, UDim2.new(0, 14, 0, 168), UDim2.new(1, -28, 0, 20), {font = Enum.Font.GothamBold, size = 14})
txt(avatarPanel, "@" .. lp.Name, UDim2.new(0, 14, 0, 188), UDim2.new(1, -28, 0, 16), {color = MUTED, size = 11})
txt(avatarPanel, "Health", UDim2.new(0, 14, 0, 218), UDim2.new(1, -28, 0, 14), {color = MUTED, size = 11})
local hpTrack = new("Frame", {Position = UDim2.new(0, 14, 0, 236), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = INK,
	BackgroundTransparency = 0.3, BorderSizePixel = 0}, avatarPanel)
corner(hpTrack, 4)
local hpFill = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = BLUE, BorderSizePixel = 0}, hpTrack)
corner(hpFill, 4)
txt(avatarPanel, "Account age", UDim2.new(0, 14, 0, 258), UDim2.new(1, -28, 0, 14), {color = MUTED, size = 11})
txt(avatarPanel, lp.AccountAge .. " days", UDim2.new(0, 14, 0, 274), UDim2.new(1, -28, 0, 16), {size = 12})
txt(avatarPanel, "User ID", UDim2.new(0, 14, 0, 296), UDim2.new(1, -28, 0, 14), {color = MUTED, size = 11})
txt(avatarPanel, tostring(lp.UserId), UDim2.new(0, 14, 0, 310), UDim2.new(1, -28, 0, 14), {size = 11})

-- A / C switch: A = avatar preview, C = console (with a Clear button)
do
	local LogService = game:GetService("LogService")

	-- everything created above belongs to the avatar view
	local title
	local items = {}
	for _, o in ipairs(avatarPanel:GetChildren()) do
		if o:IsA("GuiObject") then
			if not title and o:IsA("TextLabel") and o.Text == "Avatar" then title = o else table.insert(items, o) end
		end
	end
	if title then title.Size = UDim2.new(1, -90, 0, 16) end

	local function tabBtn(text, x)
		local b = new("TextButton", {Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
			BackgroundColor3 = INK, BackgroundTransparency = 0.3, AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 8), Size = UDim2.new(0, 24, 0, 24)}, avatarPanel)
		corner(b, 12); stroke(b, 0.6, BLUE)
		return b
	end
	local btnA, btnC = tabBtn("A", -42), tabBtn("C", -12)

	-- console view
	local cons = new("Frame", {Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -40), BackgroundTransparency = 1,
		Visible = false}, avatarPanel)
	local logScroll = new("ScrollingFrame", {Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, -48),
		BackgroundColor3 = INK, BackgroundTransparency = 0.35, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = BLUE, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y}, cons)
	corner(logScroll, 10); stroke(logScroll, 0.7, BLUE)
	new("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6)}, logScroll)
	new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, logScroll)

	local clearBtn = new("TextButton", {Text = "Clear", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
		BackgroundColor3 = BLUE2, BackgroundTransparency = 0.2, AutoButtonColor = false, AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 30)}, cons)
	corner(clearBtn, 10); stroke(clearBtn, 0.5, BLUE)

	local LINE_COLORS = {
		[Enum.MessageType.MessageOutput] = WHITE,
		[Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 210, 110),
		[Enum.MessageType.MessageError] = Color3.fromRGB(255, 120, 130),
		[Enum.MessageType.MessageInfo] = BLUE,
	}
	local lines, order, MAX_LINES = {}, 0, 200

	local function addLine(msg, mtype)
		local atBottom = logScroll.CanvasPosition.Y + logScroll.AbsoluteWindowSize.Y >= logScroll.AbsoluteCanvasSize.Y - 8
		order += 1
		local l = new("TextLabel", {LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 10, TextColor3 = LINE_COLORS[mtype] or WHITE,
			TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			Text = tostring(msg)}, logScroll)
		table.insert(lines, l)
		if #lines > MAX_LINES then table.remove(lines, 1):Destroy() end
		if atBottom then
			task.spawn(function()
				task.wait()
				logScroll.CanvasPosition = Vector2.new(0, 1e6)
			end)
		end
	end

	-- show recent output right away, then follow new messages
	local history = LogService:GetLogHistory()
	for i = math.max(1, #history - 39), #history do
		addLine(history[i].message, history[i].messageType)
	end
	LogService.MessageOut:Connect(function(message, mtype) addLine(message, mtype) end)

	clearBtn.Activated:Connect(function()
		for _, l in ipairs(lines) do l:Destroy() end
		lines = {}
	end)

	local function setMode(m)
		for _, o in ipairs(items) do o.Visible = (m == "A") end
		cons.Visible = (m == "C")
		if title then title.Text = (m == "A") and "Avatar" or "Console" end
		btnA.BackgroundColor3 = (m == "A") and BLUE2 or INK
		btnC.BackgroundColor3 = (m == "C") and BLUE2 or INK
		if m == "C" then
			task.spawn(function()
				task.wait()
				logScroll.CanvasPosition = Vector2.new(0, 1e6)
			end)
		end
	end
	btnA.Activated:Connect(function() setMode("A") end)
	btnC.Activated:Connect(function() setMode("C") end)
	setMode("A")
end

loadAvatar = function()
	task.spawn(function()
		local ok1, img = pcall(function()
			return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
		end)
		if ok1 then avatarImg.Image = img end
		local ok2, head = pcall(function()
			return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok2 then headImg.Image = head end
	end)
end
loadAvatar()

---------------------------------------------------------------- LIVE METRICS
local frames, acc, fps = 0, 0, 60
RunService.RenderStepped:Connect(function(dt)
	frames += 1; acc += dt
	if acc >= 0.5 then fps = math.floor(frames / acc + 0.5); frames, acc = 0, 0 end
end)
local function getPing()
	local ok3, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
	if ok3 and v then return math.floor(v) end
	return math.floor(lp:GetNetworkPing() * 1000)
end
local joined = os.clock()
task.spawn(function()
	while gui.Parent do
		table.remove(hist, 1); table.insert(hist, fps)
		for i, b in ipairs(bars) do
			tween(b, 0.4, {Size = UDim2.new(0, 7, 0, math.clamp(hist[i] / 120 * 50, 3, 50))})
		end
		fpsLbl.Text = fps .. " fps"
		local ping = getPing()
		pingLbl.Text = ping .. " ms"
		if HERO.update then HERO.update(fps, ping) end
		marker.Position = UDim2.new(math.clamp(ping / 300, 0, 0.97), 0, 0.5, -8)
		pingState.Text = ping < 80 and "Good" or (ping < 160 and "Fair" or "High")
		vPlayers.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		local t = math.floor(os.clock() - joined)
		vUptime.Text = string.format("%02d:%02d", t // 60, t % 60)
		local h = hum()
		if h and h.MaxHealth > 0 then
			local a = math.clamp(h.Health / h.MaxHealth, 0, 1)
			tween(hpFill, 0.3, {Size = UDim2.new(a, 0, 1, 0)})
			vHealth.Text = math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth)
		end
		task.wait(0.5)
	end
end)

selectTab("Dashboard")

---------------------------------------------------------------- OPEN / CLOSE
-- BONA image-only floating launcher.
-- No jumpscare code or sound is included.

local fab = new("ImageButton", {
    Name = "BONA_FloatingIcon",
    Image = FLOATING_ICON_IMAGE,
    ImageTransparency = 0,
    ScaleType = Enum.ScaleType.Fit,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Active = true,
    Selectable = true,
    Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 14, 0, 110),
    ZIndex = 50
}, gui)

-- Wings that spin around the floating icon.
-- A separate frame sits behind the icon, follows it when it is dragged and rotates forever.
local wingHolder = new("Frame", {
    Name = "BONA_WingSpin",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, WING_RING_SIZE, 0, WING_RING_SIZE),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = false,
    ZIndex = 49
}, gui)

local wingSparkles = {}

local rightWing, leftWing

if WING_USE_IMAGE then
    -- Wings are centered images; the loop below swings them around a hinge hidden behind the icon.
    rightWing = new("ImageLabel", {
        Name = "RightWing",
        Image = WING_RIGHT_IMAGE,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Stretch,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, WING_RING_SIZE / 2 + WING_INSET + WING_LENGTH / 2, 0, WING_RING_SIZE / 2),
        Size = UDim2.new(0, WING_LENGTH, 0, WING_LENGTH),
        ZIndex = 49
    }, wingHolder)

    -- Left wing: its own image (WING_MIRROR_LEFT flips it if it looks backwards).
    leftWing = new("ImageLabel", {
        Name = "LeftWing",
        Image = WING_LEFT_IMAGE,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Stretch,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, WING_RING_SIZE / 2 - WING_INSET - WING_LENGTH / 2, 0, WING_RING_SIZE / 2),
        Size = UDim2.new(0, WING_MIRROR_LEFT and -WING_LENGTH or WING_LENGTH, 0, WING_LENGTH),
        ZIndex = 49
    }, wingHolder)
else
    -- Built-in crimson feather wings: two fans of curved feathers that sweep around the icon
    -- (right wing + left wing, rotationally symmetric like the reference picture), plus sparkles.
    local C = WING_RING_SIZE / 2
    local BASE_R = 36

    local function feather(angleDeg, t)
        local rad = math.rad(angleDeg)
        local len = 18 + 34 * math.sin(t * math.pi)          -- short at the ends, long in the middle
        local r = BASE_R + 10 * math.sin(t * math.pi)        -- bulges outward in the middle = crescent
        local f = new("Frame", {
            Name = "Feather",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, C + r * math.cos(rad), 0, C + r * math.sin(rad)),
            Size = UDim2.new(0, 8, 0, len),
            Rotation = angleDeg + WING_TILT,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 49
        }, wingHolder)
        new("UICorner", {CornerRadius = UDim.new(1, 0)}, f)
        new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 175)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(200, 25, 55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 5, 25))
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.05),
                NumberSequenceKeypoint.new(1, 0.55)
            })
        }, f)
        new("UIStroke", {Color = Color3.fromRGB(255, 190, 205), Transparency = 0.45, Thickness = 1}, f)
    end

    for i = 1, WING_FEATHERS do
        local t = (i - 1) / math.max(1, WING_FEATHERS - 1)
        feather(-75 + 150 * t, t)      -- right wing
        feather(105 + 150 * t, t)      -- left wing
    end

    local function sparkle(angleDeg, radius, size)
        local rad = math.rad(angleDeg)
        local d = new("Frame", {
            Name = "Sparkle",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, C + radius * math.cos(rad), 0, C + radius * math.sin(rad)),
            Size = UDim2.new(0, size, 0, size),
            Rotation = 45,
            BackgroundColor3 = Color3.fromRGB(255, 225, 232),
            BorderSizePixel = 0,
            ZIndex = 49
        }, wingHolder)
        new("UIStroke", {Color = Color3.fromRGB(255, 90, 120), Transparency = 0.3, Thickness = 1.5}, d)
        table.insert(wingSparkles, d)
    end
    sparkle(-38, 64, 6)
    sparkle(35, 62, 5)
    sparkle(8, 72, 4)
    sparkle(142, 64, 6)
    sparkle(215, 62, 5)
    sparkle(188, 72, 4)
end

local wingScale = new("UIScale", {}, wingHolder)

local function syncWings()
    local p = fab.Position
    wingHolder.Position = UDim2.new(
        p.X.Scale, p.X.Offset + fab.AbsoluteSize.X / 2,
        p.Y.Scale, p.Y.Offset + fab.AbsoluteSize.Y / 2
    )
end
syncWings()
fab:GetPropertyChangedSignal("Position"):Connect(syncWings)
fab:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncWings)

local wingConn
wingConn = RunService.RenderStepped:Connect(function()
    if not gui.Parent then
        wingConn:Disconnect()
        return
    end
    local now = os.clock()
    wingHolder.Rotation = (now * WING_SPIN_SPEED) % 360
    wingScale.Scale = 1 + 0.03 * math.sin(now * 2.5)

    if rightWing and leftWing then
        -- Flap: swing each wing up/down around its root, with a little float.
        local phase = now * WING_FLAP_SPEED * math.pi * 2
        local phi = WING_FLAP_REST + WING_FLAP_ANGLE * math.sin(phase)      -- degrees, + = up
        local rad = math.rad(phi)
        local half = WING_LENGTH / 2
        local cx = WING_RING_SIZE / 2
        local cy = WING_RING_SIZE / 2 + math.sin(phase * 0.5 + 1) * 2
        rightWing.Position = UDim2.new(0, cx + WING_INSET + half * math.cos(rad), 0, cy - half * math.sin(rad))
        rightWing.Rotation = -phi
        leftWing.Position = UDim2.new(0, cx - WING_INSET - half * math.cos(rad), 0, cy - half * math.sin(rad))
        leftWing.Rotation = phi
    end
    for i, s in ipairs(wingSparkles) do
        s.BackgroundTransparency = 0.15 + 0.7 * (0.5 + 0.5 * math.sin(now * 4 + i * 1.7))
    end
end)

local open = true
local function setOpen(v)
    open = v
    if v then
        holder.Visible = true
        uiScale.Scale = baseScale * 0.9
        tween(uiScale, 0.25, {Scale = baseScale})
    else
        tween(uiScale, 0.15, {Scale = baseScale * 0.9})
        task.delay(0.16, function()
            if not open then
                holder.Visible = false
            end
        end)
    end
end

minBtn.Activated:Connect(function()
    setOpen(false)
end)

-- Mobile-safe drag handling for the floating icon.
-- Touch movement is handled through UserInputService.TouchMoved so it keeps
-- tracking the finger even when the finger moves outside the ImageButton.
local fabDragging = false
local fabDragMoved = false
local fabStartPointer = nil
local fabLastPointer = nil
local fabStartPosition = nil
local fabActiveTouch = nil
local DRAG_THRESHOLD = 6

local function updateFabPosition(pointerPosition)
    if not fabDragging or not fabStartPointer or not fabStartPosition then
        return
    end

    local delta = pointerPosition - fabStartPointer
    if delta.Magnitude > DRAG_THRESHOLD then
        fabDragMoved = true
    end

    -- Use the actual absolute screen position as the drag origin.
    -- This avoids mixing Scale and Offset values (the old 0.5 Y scale
    -- caused upward movement to clamp at the top and appear stuck).
    local x = fabStartPosition.X + delta.X
    local y = fabStartPosition.Y + delta.Y

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if viewport then
        x = math.clamp(x, 0, math.max(0, viewport.X - fab.AbsoluteSize.X))
        y = math.clamp(y, 0, math.max(0, viewport.Y - fab.AbsoluteSize.Y))
    end

    fab.Position = UDim2.fromOffset(x, y)
end

local function finishFabDrag()
    if not fabDragging then
        return
    end

    local wasDragged = fabDragMoved
    fabDragging = false
    fabActiveTouch = nil
    fabStartPointer = nil
    fabLastPointer = nil
    fabStartPosition = nil

    if not wasDragged then
        setOpen(not open)
    end
end

fab.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        fabDragging = true
        fabDragMoved = false
        fabStartPointer = Vector2.new(input.Position.X, input.Position.Y)
        fabLastPointer = fabStartPointer
        fabStartPosition = fab.AbsolutePosition

        if input.UserInputType == Enum.UserInputType.Touch then
            fabActiveTouch = input
        end

        -- This catches release even if the finger/mouse is no longer over the icon.
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                finishFabDrag()
            end
        end)
    end
end)

-- Mouse movement (desktop).
UIS.InputChanged:Connect(function(input)
    if not fabDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local pointer = Vector2.new(input.Position.X, input.Position.Y)
        updateFabPosition(pointer)
    end
end)

-- Dedicated touch movement (mobile). This avoids depending on the button's
-- InputChanged event, which may stop firing after the finger leaves the button.
UIS.TouchMoved:Connect(function(input)
    if not fabDragging or not fabActiveTouch then
        return
    end

    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    updateFabPosition(pointer)
end)

UIS.TouchEnded:Connect(function(input)
    if fabDragging and fabActiveTouch and input == fabActiveTouch then
        finishFabDrag()
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        setOpen(not open)
    end
end)

print("[BONA] Universal Hub loaded")
print("[BONA] Floating icon: 11603715677")
print("[BONA] Wings: left 6322037950 / right 6322040181, flapping")
print("[BONA] Menu background: 10110319522")
