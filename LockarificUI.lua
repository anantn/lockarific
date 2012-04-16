
LockarificUI = {}
local gBarPadding = 5
local gBarWidth, gBarHeight = 20, 250
local gFrameWidth, gFrameHeight = 150, 250

function LockarificUI:CreateSpellSet(spells, max)
	local set = {}

	local frame = CreateFrame("Frame", nil, UIParent)
	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.25)
	background:SetAllPoints()

	frame:SetPoint("CENTER", UIParent)
	frame:SetWidth(gFrameWidth)
	frame:SetHeight(gFrameHeight)

	frame.num = 0
	for _, spell in pairs(spells) do
		set[spell] = LockarificUI:CreateBar(nil, frame, max)
	end

	frame:Hide()
	return frame, set
end

function LockarificUI:CreateBar(name, parent, max)
	local bar = CreateFrame("StatusBar", name, parent)

	bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetOrientation("VERTICAL")
	bar:SetMinMaxValues(0, max)
	bar:SetValue(0)
	bar:SetWidth(gBarWidth)
	bar:SetHeight(gBarHeight)

	bar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", parent.num * (gBarWidth + bBarPadding), 0)
	parent.num = parent.num + 1
	bar:SetStatusBarColor(0, 1, 0)

	return bar
end
