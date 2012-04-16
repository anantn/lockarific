-- TODO:
-- Fix tick prediction
-- Make bar red when it is ideal time to recast the spell
-- Customizable number of bars & spells

local gCombat = false
local gUpdateInterval = 0.1
local gFrame, gSpells, gAuras, gTicks, gLog = {}, {}, {}, {}, {}
local gAffliction = {"Haunt", "Corruption", "Bane of Agony", "Unstable Affliction"}

local Lockarific, Events = CreateFrame("Frame"), {}

function Events:ADDON_LOADED()
	-- Initialize Affliction Bars
	gFrame, gSpells = LockarificUI:CreateSpellSet(gAffliction)
	Lockarific:InitializeTimer()
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
function Events:COMBAT_LOG_EVENT_UNFILTERED(time, event, _, source, _, _, _, target, _, _, _, ...)
	if source ~= UnitGUID("player") then
		return
	end
	if target ~= UnitGUID("target") then
		return
	end
	if not string.find(event, "SPELL_PERIODIC") then
		return
	end

	local spell = select(2, ...)
	if not gSpells[spell] then
		return
	end

	print(spell .. " ticked")
	LockarificUI:ShowTickFlash(gSpells[spell])

	local function round(num, idp)
	local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	-- Luckily for us, only the difference in times matters!
	-- The timestamp in the combat log is milliseconds since epoch,
	-- while GetTime() which is used in UpdateBars() is milliseconds since boot.
	if not gLog[spell] then
		gLog[spell] = time
	else
		-- This number is varying too much
		-- Perhaps if we could calculate tickLength just once at the beginning of a cast?
		gTicks[spell] = round(time - gLog[spell], 1)
		gLog[spell] = time
		LockarificUI:SetSpellTick(gSpells[spell], gTicks[spell], gAuras[spell][2])
	end
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
			local values = gAuras[spell]
			-- Update spell bar height
			LockarificUI:SetSpell(bar, values[3], values[2])
		else
			-- Debuff dropped, set to 0
			bar:SetValue(0)
		end
	end
end

function Lockarific:InitializeTimer()
	-- Throttle updates to every gUpdateInterval seconds
	gFrame.timeSinceUpdate = 0
	gFrame:SetScript("OnUpdate", function(self, elapsed)
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
