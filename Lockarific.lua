

local updateInterval = 0.1
local Frame, Spells = {}, {}
local Lockarific, Events = CreateFrame("Frame"), {}

local Affliction = {"Haunt", "Corruption", "Bane of Agony", "Unstable Affliction"}

function Events:PLAYER_REGEN_DISABLED(args)
	-- Player entered combat
	Frame:Show()
end
function Events:PLAYER_REGEN_ENABLED(args)
	-- Player leaving combat
	Frame:Hide()
end

--[[
function Events:UNIT_SPELLCAST_SUCCEEDED(caster, name, _, _, spellId)
	if (Spells[name]) then
		Spells[name]:Show()
	end
	--Lockarific:PrintTargetAuras();
end
]]--

function Lockarific:PrintTargetAuras()
	local index = 1
	repeat
		local name, _, icon, count, _, duration, expirationTime, caster, _, _, spellId = UnitDebuff("target", index)
		if name then
			print(name .. " on target!")
			index = index + 1
		end
	until not name
end

function Lockarific:InitializeTimer(frame)
	frame.timeSinceUpdate = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timeSinceUpdate = self.timeSinceUpdate + elapsed
		if (self.timeSinceUpdate > updateInterval) then
			-- Find current state of Auras
			--Lockarific:UpdateAuras()
			-- Update bars
			--Lockarific:UpdateBars()
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
	Frame, Spells = LockarificUI:CreateSpellSet(Affliction, 30)
	Lockarific:InitializeTimer(Frame)
end
