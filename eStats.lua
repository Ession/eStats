-- =============================================================================
--
--       Filename:  eStats.lua
--
--    Description:  Status texts like fps, ping, time etc.
--
--        Version:  5.2.3
--        Created:  Mon Nov 02 16:47:25 CET 2009
--       Revision:  none
--
--         Author:  Mathias Jost (mail@mathiasjost.com)
--					
--		   Edited by Lars Thevißen
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Get a reference to the library
-- -----------------------------------------------------------------------------
local LibQTip = LibStub('LibQTip-1.0')


-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------
local timer = 0
local blizz
local addons = {}
local addon  = {}
local memtotal
local cputotal
local nr
local memory
local cpu
local playername    = UnitName("player")
local playerlevel	= UnitLevel("player")
local playerxp		= UnitXP("player")
local playermaxxp	= UnitXPMax("player")
local xppercent		= 0
local realmname     = GetRealmName()
local scriptProfile = GetCVar("scriptProfile")


	
function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
-- -----------------------------------------------------------------------------
-- function intended to format a simple integer value into a currency string
-- -----------------------------------------------------------------------------
local function FormatMoney(value)
  if value >= 10000 then
    value = abs(value / 10000)
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", value, "ffd700", "g")
  elseif value >= 100 then
    value = abs(mod((value / 100), 100))
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", value, "c7c7cf", "s")
  else
    value = abs(mod(value, 100))
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", value, "eda55f", "c")
  end
end


-- -----------------------------------------------------------------------------
-- function intended to format 2 integers into a formatted string
-- -----------------------------------------------------------------------------
local function FormatValor(current, weekly)
  return format("%d (%d)", current, weekly)
end


-- -----------------------------------------------------------------------------
-- format memory usage
-- -----------------------------------------------------------------------------
local memformat = function(number)
  if number >= 1024 then
    return string.format("%.2f mb", (number / 1024))
  else
    return string.format("%.0f kb", floor(number))
  end
end


-- -----------------------------------------------------------------------------
-- format cpu time
-- -----------------------------------------------------------------------------
local cpuformat = function(number)
  if number >= 1000 then
    return string.format("%.2f s", (number / 1000))
  else
    return string.format("%.f ms", number)
  end
end


-- -----------------------------------------------------------------------------
-- returns the number of seconds since the last weekly valor cap reset
-- -----------------------------------------------------------------------------
local function timeSinceValorCapReset()
  -- this array/table hekps us to calculate how 
  -- many days it has been since the last reset
  local daysSinceReset = { 4, 5, 6, 0, 1, 2, 3 }

  -- calculates how many seconds have passed since midnight
  local secondsSinceMidnight = date("%H") * 3600 + date("%M") * 60 + date("%S")

  -- we take the days since the last reset and the seconds 
  -- since midnight and add them up, then we substract 10800 
  -- because the valor reset is at 3am, not at midnight
  return daysSinceReset[date("%w")+1] * 86400 + secondsSinceMidnight - 10800
end


-- -----------------------------------------------------------------------------
-- table ordering
-- -----------------------------------------------------------------------------
local addoncompare = function(a, b)
  return a.memory > b.memory
end


-- -----------------------------------------------------------------------------
-- Create addon frame
-- -----------------------------------------------------------------------------
local eStats = CreateFrame("Frame")


-- -----------------------------------------------------------------------------
-- Register event
-- -----------------------------------------------------------------------------
eStats:RegisterEvent("VARIABLES_LOADED")


-- -----------------------------------------------------------------------------
-- Event handler
-- -----------------------------------------------------------------------------
eStats:SetScript("OnEvent", function(self, event, ...)

  if event == "VARIABLES_LOADED" then

    if not eStatsDB then
      eStatsDB = {
      }
    end

    if not eStatsDB[realmname] then
      eStatsDB[realmname] = {}
    end
	
	if not eStatsDB[realmname][playername] then
		eStatsDB[realmname][playername] = {}
	end

  end

  eStatsDB[realmname][playername].Money = GetMoney()
  eStatsDB[realmname][playername].currentValor = select(2, GetCurrencyInfo(396))
  eStatsDB[realmname][playername].weeklyValor = select(4, GetCurrencyInfo(396))
  
  -- set to current time to know when you last logged out on this char
  eStatsDB[realmname][playername].LastChange = time()
  
  -- if the current weekly valor is 0 there is a chance 
  -- that the weekly valor cap has been reset
  if eStatsDB[realmname][playername].weeklyValor == 0 then

    -- looping through all the saved character data
    for name, entry in pairs(eStatsDB[realmname]) do

      -- checks if the last change was before the last weeekly valor cap reset
      if entry.LastChange and name and entry.LastChange < time()-timeSinceValorCapReset() then
        
        -- resets the weekly valor to 0
        eStatsDB[realmname][name].weeklyValor = 0
        
      end -- if entry.LastChange and entry.LastChange < time()-timeSinceValorCapReset() then

    end -- for k, entry in pairs(eStatsDB[realmname]) do

  end -- if eStatsDB[realmname][playername].weeklyValor == 0 then
end)


-- -----------------------------------------------------------------------------
-- Register OnUpdate
-- -----------------------------------------------------------------------------
eStats:SetScript("OnUpdate", function(self, elapsed)

  timer = timer + elapsed

  if timer > 1 then
    -- gets the stats
    currentTime = date("%H:%M:%S")
    fps         = floor(GetFramerate())
    ping        = select(3, GetNetStats())



    -- get memory usage
    memory = collectgarbage("count")
    memory = memformat(memory)

    -- set the clock text
    eStatsClockText:SetText(currentTime)

    -- set the stats text
    eStatsStatsText:SetText(ping.." ms  "..fps.." fps  "..memory)
	
    -- reset the timer for the next update
    timer = 0
  end

end)


-- -----------------------------------------------------------------------------
-- Create Spec frame
-- -----------------------------------------------------------------------------
local eStatsSpec = CreateFrame("Frame", "eStatsSpec", UIParent)
eStatsSpec:SetFrameLevel(3)
eStatsSpec:SetWidth(150)
eStatsSpec:SetHeight(15)
eStatsSpec:SetPoint("BOTTOMRIGHT", -250, 0)
eStatsSpec:Show()

eStatsSpecText = eStatsSpec:CreateFontString(nil, "OVERLAY")
eStatsSpecText:SetPoint("CENTER")
eStatsSpecText:SetFont("Interface\\AddOns\\eStats\\font.ttf", 14, "THINOUTLINE")
eStatsSpecText:SetTextColor(1, 1, 1)

eStatsSpec:SetScript("OnMouseUp", function(self, btn)
	if btn == ("LeftButton") then
		if GetActiveSpecGroup() == 1 then
			SetActiveSpecGroup(2)
		else
			SetActiveSpecGroup(1)
		end
	end
end)
eStatsSpec:SetScript("OnEnter", function(self, motion)
	eStatsSpecText:SetTextColor(1, 0, 0)
	local tooltip = LibQTip:Acquire("SpecTooltip", 1)
	-- self.tooltip = tooltip
	-- tooltip:AddHeader("Skillung")
	-- tooltip:SmartAnchorTo(self)
	-- tooltip:Show()
end)
eStatsSpec:SetScript("OnLeave", function(self, motion)
	eStatsSpecText:SetTextColor(1, 1, 1)
end)

eStatsSpec:RegisterEvent("PLAYER_LOGIN")
eStatsSpec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eStatsSpec:SetScript("OnEvent", function(self, event, ...)	
    local currentSpec = GetSpecialization()
	local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
    eStatsSpecText:SetText(currentSpecName)
end)




-- -----------------------------------------------------------------------------
-- Create Clock frame
-- -----------------------------------------------------------------------------
local eStatsClock = CreateFrame("Frame", "eStatsClock", UIParent)
eStatsClock:SetFrameLevel(3)
eStatsClock:SetWidth(50)
eStatsClock:SetHeight(15)
eStatsClock:SetPoint("BOTTOMRIGHT", 0, 0)
eStatsClock:Show()

eStatsClockText = eStatsClock:CreateFontString(nil, "OVERLAY")
eStatsClockText:SetPoint("CENTER")
eStatsClockText:SetFont("Interface\\AddOns\\eStats\\font.ttf", 14, "THINOUTLINE")
eStatsClockText:SetTextColor(1, 1, 1)

eStatsClock:SetScript("OnMouseUp", function(self, btn)
	if btn == ("LeftButton") then
		GameTimeFrame:Click()
	end
end)
eStatsClock:SetScript("OnEnter", function(self, motion)
	eStatsClockText:SetTextColor(1, 0, 0)
end)
eStatsClock:SetScript("OnLeave", function(self, motion)
	eStatsClockText:SetTextColor(1, 1, 1)
end)
-- -----------------------------------------------------------------------------
-- Create Stats text frame
-- -----------------------------------------------------------------------------
local eStatsStats = CreateFrame("Button",  "eStatsStats", UIParent)
eStatsStats:SetFrameLevel(3)
eStatsStats:SetWidth(150)
eStatsStats:SetHeight(15)
eStatsStats:SetPoint("BOTTOMRIGHT", -50, 0)
eStatsStats:Show()

eStatsStatsText = eStatsStats:CreateFontString(nil, "OVERLAY")
eStatsStatsText:SetPoint("CENTER")
eStatsStatsText:SetFont("Interface\\AddOns\\eStats\\font.ttf", 14, "THINOUTLINE")
eStatsStatsText:SetTextColor(1, 1, 1)


-- -----------------------------------------------------------------------------
-- Create Money text frame
-- -----------------------------------------------------------------------------
local eStatsMoney = CreateFrame("Button",  "eStatsMoney", UIParent)
eStatsMoney:SetFrameLevel(3)
eStatsMoney:SetWidth(50)
eStatsMoney:SetHeight(15)
eStatsMoney:SetPoint("BOTTOMRIGHT", -200, 0)
eStatsMoney:Show()

eStatsMoneyText = eStatsMoney:CreateFontString(nil, "OVERLAY")
eStatsMoneyText:SetPoint("CENTER")
eStatsMoneyText:SetFont("Interface\\AddOns\\eStats\\font.ttf", 14, "THINOUTLINE")
eStatsMoneyText:SetTextColor(1, 1, 1)

eStatsMoney:RegisterEvent("PLAYER_MONEY")
eStatsMoney:RegisterEvent("PLAYER_LOGIN")
eStatsMoney:SetScript("OnEvent", function(self, event, ...)	
    local money = FormatMoney(GetMoney())
    eStatsMoneyText:SetText(money)
end)
-- -----------------------------------------------------------------------------
-- Create experience text frame
-- -----------------------------------------------------------------------------

if playerlevel < 90 then
	local eStatsExp = CreateFrame("Button",  "eStatsExp", UIParent)
	eStatsExp:SetFrameLevel(3)
	eStatsExp:SetWidth(100)
	eStatsExp:SetHeight(15)
	eStatsExp:SetPoint("BOTTOMRIGHT", -300, 0)
	eStatsExp:Show()

	eStatsExpText = eStatsExp:CreateFontString(nil, "OVERLAY")
	eStatsExpText:SetPoint("CENTER")
	eStatsExpText:SetFont("Interface\\AddOns\\eStats\\font.ttf", 14, "THINOUTLINE")
	eStatsExpText:SetTextColor(1, 1, 1)

	eStatsExp:RegisterEvent("PLAYER_XP_UPDATE")
	eStatsExp:RegisterEvent("PLAYER_LOGIN")

eStatsExp:SetScript("OnEvent", function(self, event, ...)
	-- if playerlevel == 90 then
		-- eStatsExp:Hide()	
	-- else
		playerxp = UnitXP("player")
		playermaxxp	= UnitXPMax("player")
		xppercent = round(100*playerxp/playermaxxp, 2)
		eStatsExpText:SetText(xppercent.."%")
	-- end
end)
end


-- -----------------------------------------------------------------------------
-- Create memory tooltip
-- -----------------------------------------------------------------------------
eStatsStats:SetScript("OnEnter", function(self, motion)

  -- if CPU Proviling is enabled
  if scriptProfile == "1" then

    -- variables
    blizz    = collectgarbage("count")
    memtotal = 0
    cputotal = 0
    nr       = 0

    -- for getting new usage data
    UpdateAddOnMemoryUsage()
    UpdateAddOnCPUUsage()

    -- Acquire a tooltip with 2 columns, aligned to left and right
    local tooltip = LibQTip:Acquire("MoneyTooltip", 3, "LEFT", "RIGHT", "RIGHT")
    self.tooltip  = tooltip

    -- Add header
    tooltip:AddHeader("Name", "Memory", "CPU")
    tooltip:AddSeparator()

    -- get the addons and their memory usage
    for i=1, GetNumAddOns(), 1 do
      addons[i] = {name = GetAddOnInfo(i), memory = GetAddOnMemoryUsage(i), cpu = GetAddOnCPUUsage(i)}
      memtotal  = memtotal + addons[i].memory
      cputotal  = cputotal + addons[i].cpu
    end

    -- sort the addons by memory usage
    table.sort(addons, addoncompare)

    -- display the addons in the tooltip
    for k, entry in pairs(addons) do
      if nr < 25 then
        tooltip:AddLine(entry.name, memformat(entry.memory), cpuformat(entry.cpu))
        nr = nr + 1
      end
    end

    -- add totals
    tooltip:AddSeparator()
    tooltip:AddLine("Total", memformat(memtotal), cpuformat(cputotal))

    -- Use smart anchoring code to anchor the tooltip to our frame
    tooltip:SmartAnchorTo(self)

    -- Show it
    tooltip:Show()

  elseif scriptProfile == "0" then

    -- variables
    blizz    = collectgarbage("count")
    memtotal = 0
    nr       = 0

    -- for getting new usage data
    UpdateAddOnMemoryUsage()

    -- Acquire a tooltip with 2 columns, aligned to left and right
    local tooltip = LibQTip:Acquire("MoneyTooltip", 2, "LEFT", "RIGHT")
    self.tooltip  = tooltip

    -- Add header
    tooltip:AddHeader("Name", "Memory")
    tooltip:AddSeparator()

    -- get the addons and their memory usage
    for i=1, GetNumAddOns(), 1 do
      addons[i] = {name = GetAddOnInfo(i), memory = GetAddOnMemoryUsage(i)}
      memtotal = memtotal + addons[i].memory
    end

    -- sort the addons by memory usage
    table.sort(addons, addoncompare)

    -- display the addons in the tooltip
    for k, entry in pairs(addons) do
      if nr < 25 then
        tooltip:AddLine(entry.name, memformat(entry.memory))
        nr = nr + 1
      end
    end

    -- add totals
    tooltip:AddSeparator()
    tooltip:AddLine("Total", memformat(memtotal))

    -- Use smart anchoring code to anchor the tooltip to our frame
    tooltip:SmartAnchorTo(self)

    -- Show it
    tooltip:Show()

  end

end)


eStatsStats:SetScript("OnLeave", function(self, motion)

  -- Release the tooltip
  LibQTip:Release(self.tooltip)
  self.tooltip = nil

end)


-- -----------------------------------------------------------------------------
-- Create Currency tooltip
-- -----------------------------------------------------------------------------
eStatsMoney:SetScript("OnEnter", function(self, motion)

  -- Acquire a tooltip with 2 columns, aligned to left and right
  local tooltip = LibQTip:Acquire("MoneyTooltip", 4, "LEFT", "RIGHT", "RIGHT", "RIGHT")
  self.tooltip = tooltip

  -- Add an header
  tooltip:AddHeader("Character", "Money", "Valor")
  tooltip:AddSeparator()

  -- reset totals to zero
  MoneyTotal = 0

  -- add the characters and their amounts
  for name, data in pairs(eStatsDB[realmname]) do
    tooltip:AddLine(name, FormatMoney(data.Money), FormatValor(data.currentValor, data.weeklyValor))
    MoneyTotal = MoneyTotal + data.Money
  end

  -- add the totals
  tooltip:AddSeparator()
  tooltip:AddLine("Total", FormatMoney(MoneyTotal))

  -- Use smart anchoring code to anchor the tooltip to our frame
  tooltip:SmartAnchorTo(self)

  -- Show it
  tooltip:Show()

end)


eStatsMoney:SetScript("OnLeave", function(self, motion)

  -- Release the tooltip
  LibQTip:Release(self.tooltip)
  self.tooltip = nil

end)
