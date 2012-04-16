

local updateInterval = 0.1
local Frame, Spells, Auras = {}, {}, {}
local Lockarific, Events = CreateFrame("Frame"), {}

local Affliction = {"Haunt", "Corruption", "Bane of Agony", "Unstable Affliction"}

function Events:PLAYER_REGEN_DISABLED(args)
	-- Player entered combat
	Frame:Show() -- Showing frame starts OnUpdate events
end
function Events:PLAYER_REGEN_ENABLED(args)
	-- Player leaving combat
	Frame:Hide() -- Hiding frame stops OnUpdate events
	for name, bar in pairs(Spells) do
		bar:SetValue(0)
	end
end

function Lockarific:UpdateAuras()
	local index = 1
	local currentTime = GetTime()

	repeat
		local name, _, icon, count, _, duration, expirationTime, caster, _, _, spellId = UnitDebuff("target", index)
		if (name) then
			if (Spells[name]) then
				Auras[name] = { count, duration, expirationTime - currentTime }
			end
			index = index + 1
		end
	until not name
end

function Lockarific:UpdateBars()
	for spell, values in pairs(Auras) do
		-- % of bar left is (timeLeft * 100) / duration
		Spells[spell]:SetValue((values[3] * 100) / values[2])
	end
end

function Lockarific:InitializeTimer(frame)
	frame.timeSinceUpdate = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timeSinceUpdate = self.timeSinceUpdate + elapsed
		if (self.timeSinceUpdate > updateInterval) then
			-- Find current state of Auras
			Lockarific:UpdateAuras()
			-- Update bars
			Lockarific:UpdateBars()
			-- Reset
			self.timeSinceUpdate = 0;
		end
	end)
end

function OnLoad(self)
	Lockarific:SetScript("OnEvent", function(self, event, ...)
		Events[event](self, ...)
	end)
	for k, v in pairs(Events) do
		Lockarific:RegisterEvent(k)
	end

	-- Initialize Affliction Bars
	Frame, Spells = LockarificUI:CreateSpellSet(Affliction)
	Lockarific:InitializeTimer(Frame)
end
