
LockarificUI = {}
local barPadding = 5
local barWidth, barHeight = 20, 250
local frameWidth, frameHeight = 150, 250

function LockarificUI:CreateSpellSet(spells, max)
	local set = {}

	local frame = CreateFrame("Frame", nil, UIParent)
	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.25)
	background:SetAllPoints()

	frame:SetPoint("CENTER", UIParent)
	frame:SetWidth(frameWidth)
	frame:SetHeight(frameHeight)

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
	bar:SetWidth(barWidth)
	bar:SetHeight(barHeight)

	bar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", parent.num * (barWidth + barPadding), 0)
	parent.num = parent.num + 1
	bar:SetStatusBarColor(0, 1, 0)

	return bar
end
