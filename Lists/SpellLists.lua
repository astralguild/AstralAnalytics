local _, ADDON = ...
local strformat = string.format

ADDON.SPELL_CATEGORIES = {}

function ADDON:LoadSpells()
  if (AstralAnalytics.spellIds == nil) then
    AstralAnalytics.spellIds = {}
  end
  for key, value in pairs(AstralAnalytics.spellIds) do
    if key ~= nil then
      if key == 'Taunt' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Taunt', '<sourceName> taunted <destName> with <spell>')
        end
      elseif key == 'Bloodlust' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Bloodlust', '<sourceName> cast <spell>')
        end
      elseif key == 'Targeted Utility' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Targeted Utility', '<sourceName> cast <spell> on <destName>')
        end
      elseif key == 'Misdirects' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Misdirects', '<sourceName> cast <spell> on <destName>')
        end
      elseif key == 'Group Utility' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Group Utility', '<sourceName> cast <spell>')
        end
      elseif key == 'AoE Stops' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'AoE Stops', '<sourceName> cast <spell>')
        end
      elseif key == 'Major Defensive' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Major Defensives', '<sourceName> cast <spell>')
        end
      elseif key == 'Toys' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Toys', '<sourceName> used toy <spell>')
        end
      elseif key == 'Raid' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Raid', '<sourceName> cast <spell>')
        end
      elseif key == 'Externals' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Externals', '<sourceName> cast <spell> on <destName>')
        end
      elseif key == 'crowd' then
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToCategory(spellId, 'Crowd Control')
        end
      else
        for spellId, _ in pairs(value) do
          ADDON:AddSpellToCategory(spellId, key)
        end
      end
    end
  end
  LoadPresets()
end

function ADDON:AddSpellToCategory(spellID, spellCategory)
  if not spellID or type(spellID) ~= 'number' then
    error('ADDON:AddSpellToCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
  end
  if not spellCategory or type(spellCategory) ~= 'string' then
    error('ADDON:AddSpellToCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
  end
  if not self.SPELL_CATEGORIES[spellCategory] then
    self.SPELL_CATEGORIES[spellCategory] = {}
  end
  if self.SPELL_CATEGORIES[spellCategory][spellID] ~= nil then
    ADDON:Print('AstralAnalytics:AddSpellToCategory(spellID, spellCategory) spellId already exists ' .. type(spellID))
  end
  table.insert(self.SPELL_CATEGORIES[spellCategory], spellID)
  if (AstralAnalytics.spellIds[spellCategory] == nil) then
    AstralAnalytics.spellIds[spellCategory] = {}
  end
  AstralAnalytics.spellIds[spellCategory][spellID] = true
end

function ADDON:RemoveSpellFromCategory(spellID, spellCategory)
  if not spellID or type(spellID) ~= 'number' then
    error('ADDON:AddSpellToCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
  end
  if not spellCategory or type(spellCategory) ~= 'string' then
    error('ADDON:AddSpellToCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
  end
  if self.SPELL_CATEGORIES[spellCategory][spellID] ~= nil then
    ADDON:Print('AstralAnalytics:AddSpellToCategory(spellID, spellCategory) spellId already does not exist ' .. type(spellID))
  end
  AstralAnalytics.spellIds[spellCategory][spellID] = nil
end

function ADDON:RetrieveSpellCategorySpells(spellCategory)
  if not spellCategory or type(spellCategory) ~= 'string' then
    error('ADDON:RetrieveSpellCategorySpells(spellCategory) spellCategory, string expected got ' .. type(spellCategory))
  end
  
  return self.SPELL_CATEGORIES[spellCategory]
end

function ADDON:IsSpellInCategory(spellID, spellCategory)
  if not spellID or type(spellID) ~= 'number' then
    error('ADDON:IsSpellInCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
  end
  if not spellCategory or type(spellCategory) ~= 'string' then
    error('ADDON:IsSpellInCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
  end

  if self.SPELL_CATEGORIES[spellCategory] then
    for i = 1, #self.SPELL_CATEGORIES[spellCategory] do
      if self.SPELL_CATEGORIES[spellCategory][i] == spellID then
        return true
      end
    end
  end

  return false
end

function ADDON:AddSpellToSubEvent(subEvent, spellID, spellCategory, msgString, channel)
  if not self[subEvent] then
    self[subEvent] = {}
  end

  if not channel then
    channel = 'console'
  end

  local string = msgString

  local ls = ''
  local commandList = ''
  for command in string:gmatch('<(%w+)>') do
    if command:find('Name') then
      local unitText = command:sub(1, command:find('Name')- 1)
      if unitText == 'dest' then
        commandList = strformat('%s, %s, %sFlags, %sRaidFlags', commandList, command, unitText, unitText)
      else
        commandList = strformat('%s, %s, %sRaidFlags', commandList, command, unitText)
      end
    else
      commandList = strformat('%s, %s', commandList, command)
    end
    ls = strformat('%s, %s', ls, command)
  end
  commandList = commandList:sub(commandList:find(',') + 1)

  local fstring = string:gsub('<(.-)>', '%%s')

  ls = ls:gsub('(%w+)', function(w)
    if w:find('Name') then
      local flagText = w:sub(1, w:find('Name')- 1) .. 'RaidFlags'
      if w:find('dest') then
        return [[WrapNameInColorAndIcons(]] .. w .. [[, destFlags, ]] .. flagText .. [[)]]
      else
        return [[WrapNameInColorAndIcons(]] .. w .. [[, nil, ]] .. flagText .. [[)]]
      end
      --local colourText = w:find('dest') and ADDON.COLOURS.TARGET or 'nil'
      --return [[WrapNameInColorAndIcons(]] .. w .. [[, destFlags, ]] .. flagText .. [[)]]
    else
      return w
    end

  end)

  local codeString = [[
  if not AstralAnalytics.options.combatEvents[']] .. spellCategory .. [['] or not AstralAnalytics.options.combatEvents[']] .. spellCategory .. [['].isEnabled then return end
  if AstralAnalytics.options.combatEvents[]] .. spellID .. [[] and not AstralAnalytics.options.combatEvents[]] .. spellID .. [[].isEnabled then return end
  local sourceName, sourceRaidFlags, spell, destName, destFlags, destRaidFlags = ...
  AstralSendMessage(string.format(']] .. fstring .. [[' ]] .. ls .. [[), ']] .. channel .. [[')]]

  local func, cerr = loadstring(codeString)
  if cerr then
    error(cerr)
  end

  self[subEvent][spellID] = {textString = msgString, method = func}
  self:AddSpellToCategory(spellID, spellCategory)
end

function ADDON:IsSpellTracked(subEvent, spellID)
  if not subEvent or type(subEvent) ~= 'string' then
    error('ADDON:IsSpellTracked(subEvent, spellID) subEvent, string expected got ' .. type(subEvent))
  end
  if not spellID or type(spellID) ~= 'number' then
    error('ADDON:IsSpellTracked(subEvent, spellID) spellID, number expected got ' .. type(spellID))
  end
  if self[subEvent] and self[subEvent][spellID] then
    return true
  else
    return false
  end
end

function ADDON:GetSubEventMethod(subEvent, spellID)
  if not subEvent or type(subEvent) ~= 'string' then
    error('ADDON:GetSubEventMethod(subEvent, spellID) subEvent, string expected got ' .. type(subEvent))
  end
  if not spellID or type(spellID) ~= 'number' then
    error('ADDON:GetSubEventMethod(subEvent, spellID) spellID, string expected got ' .. type(spellID))
  end

  return self[subEvent][spellID].method
end

function LoadPresets()
  for _, s in pairs(ADDON:GetSpellsForCategory('Bloodlust')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Bloodlust', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('battleRes')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'battleRes', '<sourceName> resurrected <destName> with <spell>')
  end
  ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 207399, 'battleRes', '<sourceName> cast <spell>') -- Ancestral Protection Totem

  for _, s in pairs(ADDON:GetSpellsForCategory('Taunt')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Taunt', '<sourceName> taunted <destName> with <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Targeted Utility')) do
    if s.spellID == 370665 then
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Targeted Utility', '<sourceName> rescued <destName>', 'SWAP')
    elseif s.spellID == 73325 then
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Targeted Utility', '<sourceName> gripped <destName>', 'SWAP')
    else
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Targeted Utility', '<sourceName> cast <spell> on <destName>')
    end 
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Group Utility')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Group Utility', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Raid Defensives')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Raid Defensives', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('AoE Stops')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'AoE Stops', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('AoE Control')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'AoE Control', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Interrupts')) do
    ADDON:AddSpellToCategory(s.spellID, 'Interrupts')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Crowd Control')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Crowd Control', '<sourceName> cast <spell> on <destName>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Externals')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Externals', '<sourceName> cast <spell> on <destName>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Slows')) do
    if s.subEvent == 'SPELL_CAST_SUCCESS' then
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Slows', '<sourceName> cast <spell>')
    else
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Slows', '<sourceName> cast <spell> on <destName>')
    end
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Major Defensives')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Major Defensives', '<sourceName> cast <spell>')
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Toys')) do
    if s.spellID == 161399 then
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Toys', '<sourceName> swapped <destName>', 'SWAP')
    else
      ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Toys', '<sourceName> cast <spell>')
    end
  end

  for _, s in pairs(ADDON:GetSpellsForCategory('Raid')) do
    ADDON:AddSpellToSubEvent(s.subEvent, s.spellID, 'Raid', '<sourceName> cast <spell>')
  end

  -- Misdirects
  ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 57934, 'Misdirects', '<sourceName> cast <spell> on <destName>') -- Tricks of the Trade, Rogue
  ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 34477, 'Misdirects', '<sourceName> cast <spell> on <destName>') -- Misdirect, Hunter

  AstralAnalytics.spellIds['crowd'] = nil
  AstralAnalytics.spellIds['Targeted Crowd Control'] = nil
  AstralAnalytics.spellIds['Dispel'] = nil
  AstralAnalytics.spellIds['Soothe'] = nil
  AstralAnalytics.spellIds['AoE CC'] = nil
  AstralAnalytics.spellIds['Battle Res'] = nil
end
