
-- 1000 gives better precision than 100
local gBarMax = 1000
local gCombat = false
local gUpdateInterval = 0.1
local gFrame, gSpells, gAuras = {}, {}, {}
local gAffliction = {"Haunt", "Corruption", "Bane of Agony", "Unstable Affliction"}

local Lockarific, Events = CreateFrame("Frame"), {}

function Events:ADDON_LOADED()
	-- Initialize Affliction Bars
	gFrame, gSpells = LockarificUI:CreateSpellSet(gAffliction, gBarMax)
	Lockarific:InitializeTimer(gFrame)
end
function Events:PLAYER_REGEN_DISABLED()
	-- Player entered combat
	gCombat = true
	-- Showing frame starts OnUpdate events
	gFrame:Show()
end
function Events:PLAYER_REGEN_ENABLED()
	-- Player leaving combat, don't hide frame until debuffs fall
	gCombat = false
end

function Lockarific:UpdateAuras()
	local index = 1
	local currentTime = GetTime()
	
	gAuras = {}
	repeat
		local name, _, icon, count, _, duration, expirationTime, caster, _, _, spellId = UnitDebuff("target", index)
		if name then
			if gSpells[name] then
				gAuras[name] = { count, duration, expirationTime - currentTime }
			end
			index = index + 1
		end
	until not name
end

function Lockarific:UpdateBars()
	if not gCombat and next(gAuras) == nil then
		for _, bar in pairs(gSpells) do
			bar:SetValue(0)
		end
		gFrame:Hide()
		return
	end

	for spell, bar in pairs(gSpells) do
		if gAuras[spell] then
			-- % of bar left is (timeLeft * 1000) / duration
			local values = gAuras[spell]
			bar:SetValue((values[3] * gBarMax) / values[2])
		else
			-- Debuff dropped, set to 0
			bar:SetValue(0)
		end
	end
end

function Lockarific:InitializeTimer()
	-- Throttle updates to every gUpdateInterval seconds
	frame.timeSinceUpdate = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timeSinceUpdate = self.timeSinceUpdate + elapsed
		if self.timeSinceUpdate > gUpdateInterval then
			-- Find current state of Auras
			Lockarific:UpdateAuras()
			-- Update bars
			Lockarific:UpdateBars()
			-- Reset
			self.timeSinceUpdate = 0;
		end
	end)
end

function Lockarific:Startup()
	Lockarific:SetScript("OnEvent", function(self, event, ...)
		Events[event](self, ...)
	end)
	for k, v in pairs(Events) do
		Lockarific:RegisterEvent(k)
	end
end

Lockarific:Startup()
