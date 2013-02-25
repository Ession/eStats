-- =============================================================================
--
--       Filename:  eStats.lua
--
--    Description:  Status texts like fps, ping, time etc.
--
--        Version:  5.0.2
--        Created:  Mon Nov 02 16:47:25 CET 2009
--       Revision:  none
--
--         Author:  Mathias Jost (mail@mathiasjost.com)
--					
--		   Edited:  Lars Thevißen
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
function FormatMoney(value, coin)
  if coin == "gold" and value >= 10000 then
    local gold = abs(value / 10000)
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", gold, "ffd700", "g")
  elseif coin == "silver" and value >= 100 then
    local silver = abs(mod((value / 100), 100))
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", silver, "c7c7cf", "s")
  elseif coin == "copper" then
    local copper = abs(mod(value, 100))
    return format("|cff%s%s%d|r|cff%s%s|r", "ffffff", "", copper, "eda55f", "c")
  end
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

  eStatsDB[realmname][playername].Gold = GetMoney()
  eStatsDB[realmname][playername].Valor = select(2, GetCurrencyInfo(396))
  eStatsDB[realmname][playername].ValorWeek = select(4, GetCurrencyInfo(396))
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
eStatsMoney:SetWidth(100)
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
	-- build the money string
    if GetMoney() >= 10000 then
      money = FormatMoney(GetMoney(), "gold") .." ".. FormatMoney(GetMoney(), "silver") .." ".. FormatMoney(GetMoney(), "copper")
    elseif GetMoney() >= 100 then
      money = FormatMoney(GetMoney(), "silver") .." ".. FormatMoney(GetMoney(), "copper")
    else
      money = FormatMoney(GetMoney(), "copper")
    end
	-- set the money text
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
-- Create money tooltip
-- -----------------------------------------------------------------------------
eStatsMoney:SetScript("OnEnter", function(self, motion)

  -- Acquire a tooltip with 2 columns, aligned to left and right
  local tooltip = LibQTip:Acquire("MoneyTooltip", 4, "LEFT", "RIGHT", "RIGHT", "RIGHT")
  self.tooltip = tooltip

  -- Add an header
  tooltip:AddHeader("Character", "Gold", "Valor")
  tooltip:AddSeparator()

  -- reset totals to zero
  total = 0

  -- add the characters and their amounts
  for name, player in pairs(eStatsDB[realmname]) do
    tooltip:AddLine(name, FormatMoney(player.Gold, "gold"), player.Valor.."("..player.ValorWeek..")")
    total = total + player.Gold
  end

  -- add the totals
  tooltip:AddSeparator()
  tooltip:AddLine("Total", FormatMoney(total, "gold"))

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
