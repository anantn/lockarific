
-- True globals
LockarificUI, FramePoint = {}, {}, {}

-- File scope
local gTicks = {}
local gBarMax = 1000
local gBarPadding = 5
local gBarWidth, gBarHeight = 20, 250
local gFrameWidth, gFrameHeight = 150, 250

function LockarificUI:CreateSpellSet(spells)
	local spellSet = {}

	local frame = CreateFrame("Frame", nil, UIParent)
	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.25)
	background:SetAllPoints()

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("RightButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		FramePoint["point"], _, FramePoint["relativePoint"], FramePoint["x"], FramePoint["y"] =
			frame:GetPoint()
	end)

	if next(FramePoint) == nil then
		frame:SetPoint("CENTER", UIParent)
	else
		frame:SetPoint(FramePoint["point"], UIParent, FramePoint["relativePoint"], FramePoint["x"], FramePoint["y"])
	end

	frame:SetWidth(gFrameWidth)
	frame:SetHeight(gFrameHeight)

	frame.num = 0
	for _, spell in pairs(spells) do
		spellSet[spell] = LockarificUI:CreateBar(nil, frame, spell)
	end

	frame:Hide()
	return frame, spellSet
end

function LockarificUI:CreateBar(name, parent, spell)
	local bar = CreateFrame("StatusBar", name, parent)

	-- Setup spell bar
	bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetOrientation("VERTICAL")
	bar:SetMinMaxValues(0, gBarMax)
	bar:SetValue(0)
	bar:SetWidth(gBarWidth)
	bar:SetHeight(gBarHeight)

	-- Attach bar to spellSet frame
	bar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", parent.num * (gBarWidth + gBarPadding), 0)
	bar:SetStatusBarColor(0, 1, 0)

	-- Get icon and put it under bar
	spellName, _, icon = GetSpellInfo(spell)
	local texture = bar:CreateTexture(nil, "BORDER")
	texture:SetWidth(gBarWidth)
	texture:SetHeight(gBarWidth)
	texture:SetTexture(icon)
	texture:SetPoint("TOP", bar, "BOTTOM")

	-- Make sure the next bar to be added to this set is offset
	parent.num = parent.num + 1
	bar._spell = spellName
	return bar
end

function LockarificUI:SetSpell(bar, time, duration)
	-- Convert times to % of bar remaining
	bar:SetValue((time * gBarMax) / duration)
end

function LockarificUI:SetSpellTick(bar, tickLength, duration)
	-- Total ticks at current tickLength for duration
	local total = math.floor(duration / tickLength)
	local height = bar:GetHeight() / total

	if not gTicks[bar] then
		gTicks[bar] = {}
	end

	-- Draw ticks
	local tick = 1
	while tick <= total do
		-- If previous tick exists, just move it
		local texture = nil
		if gTicks[bar][tick] then
			texture = gTicks[bar][tick]
		else
			texture = bar:CreateTexture(nil, "OVERLAY")
			texture:SetHeight(1)
			texture:SetWidth(bar:GetWidth())
			texture:SetTexture(1, 1, 1, 1)
			table.insert(gTicks[bar], texture)
		end

		texture:SetPoint("TOP", bar, "TOP", 0, -(tick * height))
		tick = tick + 1
	end
end
