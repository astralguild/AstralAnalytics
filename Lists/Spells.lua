local _, ADDON = ...

local SPELL_TABLE = {}

-- AoE Stops

SPELL_TABLE['aoeStops'] = {}
local aoeStops = SPELL_TABLE['aoeStops']

aoeStops[31661] = {name = 'Dragon\'s Breath', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 31661}
aoeStops[192058] = {name = 'Capacitor Totem', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 192058}
aoeStops[207167] = {name = 'Blinding Sleet', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 207167}
aoeStops[205369] = {name = 'Mind Bomb', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 205369}
aoeStops[51490] = {name = 'Thunderstorm', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 51490}
aoeStops[30282] = {name = 'Shadowfury', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 30282}
aoeStops[132469] = {name = 'Typhoon', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 132469}
aoeStops[108119] = {name = 'Gorefiend\'s Grasp', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 108119}
aoeStops[119381] = {name = 'Leg Sweep', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 119381}
aoeStops[115750] = {name = 'Blinding Light', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 115750}
aoeStops[99] = {name = 'Incapacitating Roar', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 99}
aoeStops[179057] = {name = 'Chaos Nova', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 179057}
aoeStops[255654] = {name = 'Bull Rush', class = 'Racial', subEvent = 'SPELL_CAST_SUCCESS', spellID = 255654}
aoeStops[20549] = {name = 'War Stomp', class = 'Racial', subEvent = 'SPELL_CAST_SUCCESS', spellID = 20549}
aoeStops[368970] = {name = 'Tail Swipe', class = 'Racial', subEvent = 'SPELL_CAST_SUCCESS', spellID = 368970}
aoeStops[357214] = {name = 'Wing Buffet', class = 'Racial', subEvent = 'SPELL_CAST_SUCCESS', spellID = 357214}
aoeStops[202138] = {name = 'Sigil of Chains', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 202138}
aoeStops[191427] = {name = 'Metamorphosis', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 191427}
aoeStops[186387] = {name = 'Bursting Shot', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 186387}
aoeStops[113724] = {name = 'Ring of Frost', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 113724}
aoeStops[157981] = {name = 'Blast Wave', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 157981}
aoeStops[157980] = {name = 'Supernova', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 157980}
aoeStops[8122] = {name = 'Psychic Scream', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 8122}
aoeStops[5246] = {name = 'Intimidating Shout', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 5246}
aoeStops[46968] = {name = 'Shockwave', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 46968}
aoeStops[382269] = {name = 'Abomination Limb', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 382269}
aoeStops[1122] = {name = 'Summon Infernal', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 1122}

-- AoE Control

SPELL_TABLE['aoeControl'] = {}
local aoeControl = SPELL_TABLE['aoeControl']

aoeControl[372048] = {name = 'Oppressing Roar', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 372048}
aoeControl[207684] = {name = 'Sigil of Misery', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 207684}
aoeControl[102359] = {name = 'Mass Entanglement', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 102359}
aoeControl[102793] = {name = 'Ursol\'s Vortex', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 102793}
aoeControl[358385] = {name = 'Landslide', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 358385}
aoeControl[109248] = {name = 'Binding Shot', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 109248}
aoeControl[122] = {name = 'Frost Nova', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 122}
aoeControl[116844] = {name = 'Ring of Peace', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 116844}
aoeControl[51485] = {name = 'Earthgrab Totem', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 51485}
aoeControl[392060] = {name = 'Wailing Arrow', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 392060}
aoeControl[108920] = {name = 'Void Tendrils', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 108920}
aoeControl[202137] = {name = 'Sigil of Silence', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 202137}

-- Externals

SPELL_TABLE['externals'] = {}
local externals = SPELL_TABLE['externals']

externals[47788] = {name = 'Guardian Spirit', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 47788}
externals[1022] = {name = 'Blessing of Protection', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 1022}
externals[204018] = {name = 'Blessing of Spellwarding', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 204018}
externals[116849] = {name = 'Life Cocoon', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 116849}
externals[357170] = {name = 'Time Dilation', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 357170}
externals[6940] = {name = 'Blessing of Sacrifice', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 6940}
externals[102342] = {name = 'Ironbark', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 102342}
externals[633] = {name = 'Lay on Hands', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 633}
externals[33206] = {name = 'Pain Suppression', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 33206}

-- Major Defensives

SPELL_TABLE['majorDefensives'] = {}
local majorDefensives = SPELL_TABLE['majorDefensives']

majorDefensives[642] = {name = 'Divine Shield', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 642}
majorDefensives[48707] = {name = 'Anti-Magic Shell', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 48707}
majorDefensives[31224] = {name = 'Cloak of Shadows', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 31224}
majorDefensives[196555] = {name = 'Netherwalk', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 196555}
majorDefensives[45438] = {name = 'Ice Block', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 45438}
majorDefensives[186265] = {name = 'Aspect of the Turtle', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 186265}
majorDefensives[114556] = {name = 'Purgatory', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 114556}
majorDefensives[209258] = {name = 'Last Resort', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 209258}
majorDefensives[392966] = {name = 'Spell Block', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 392966}
majorDefensives[118038] = {name = 'Die by the Sword', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 118038}
majorDefensives[5277] = {name = 'Evasion', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 5277}
majorDefensives[31230] = {name = 'Cheat Death', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 31230}


-- Raid Defensives

SPELL_TABLE['raidDefensives'] = {}
local raidDefensives = SPELL_TABLE['raidDefensives']

raidDefensives[51052] = {name = 'Anti-Magic Zone', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 51052}
raidDefensives[97462] = {name = 'Rallying Cry', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 97462}
raidDefensives[196718] = {name = 'Darkness', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 196718}
raidDefensives[363534] = {name = 'Rewind', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 363534}
raidDefensives[374227] = {name = 'Zephyr', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 374227}
raidDefensives[115310] = {name = 'Revival', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 115310}
raidDefensives[31821] = {name = 'Aura Mastery', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 31821}
raidDefensives[265202] = {name = 'Holy Word: Salvation', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 265202}
raidDefensives[62618] = {name = 'Power Word: Barrier', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 62618}
raidDefensives[98008] = {name = 'Spirit Link Totem', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 98008}
raidDefensives[15286] = {name = 'Vampiric Embrace', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 15286}
raidDefensives[47536] = {name = 'Rapture', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 47536}
raidDefensives[124974] = {name = 'Nature\'s Vigil', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 124974}
raidDefensives[108281] = {name = 'Ancestral Guidance', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 108281}

-- Targeted Utility

SPELL_TABLE['targetedUtility'] = {}
local targetedUtility = SPELL_TABLE['targetedUtility']

targetedUtility[328282] = {name = 'Blessing of Spring', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 328282}
targetedUtility[328622] = {name = 'Blessing of Autumn', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 328622}
targetedUtility[328281] = {name = 'Blessing of Winter', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 328281}
targetedUtility[328620] = {name = 'Blessing of Summer', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 328620}
targetedUtility[73325] = {name = 'Leap of Faith', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 73325}
targetedUtility[10060] = {name = 'Power Infusion', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 10060}
targetedUtility[29166] = {name = 'Innervate', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 29166}
targetedUtility[2908] = {name = 'Soothe', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 2908}
targetedUtility[374251] = {name = 'Cauterizing Flame', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 374251}
targetedUtility[19801] = {name = 'Tranquilizing Shot', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 19801}
targetedUtility[370665] = {name = 'Rescue', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 370665}
targetedUtility[1044] = {name = 'Blessing of Freedom', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 1044}
targetedUtility[116841] = {name = 'Tiger\'s Lust', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 116841}

-- Targeted Control

SPELL_TABLE['targetedControl'] = {}
local targetedControl = SPELL_TABLE['targetedControl']

targetedControl[115078] = {name = 'Paralysis', class = 'Monk', subEvent = 'SPELL_AURA_APPLIED', spellID = 115078}
targetedControl[710] = {name = 'Banish', class = 'Warlock', subEvent = 'SPELL_AURA_APPLIED', spellID = 710}
targetedControl[277784] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 277784}
targetedControl[211004] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 211004}
targetedControl[61780] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 61780}
targetedControl[217832] = {name = 'Imprison', class = 'Demon Hunter', subEvent = 'SPELL_AURA_APPLIED', spellID = 217832}
targetedControl[61721] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 61721}
targetedControl[161353] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 161353}
targetedControl[20066] = {name = 'Repentance', class = 'Paladin', subEvent = 'SPELL_AURA_APPLIED', spellID = 20066}
targetedControl[277787] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 277787}
targetedControl[115268] = {name = 'Mesmerize', class = 'Warlock', subEvent = 'SPELL_AURA_APPLIED', spellID = 115268}
targetedControl[6358] = {name = 'Seduction', class = 'Warlock', subEvent = 'SPELL_AURA_APPLIED', spellID = 6358}
targetedControl[28271] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 28271}
targetedControl[161354] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 161354}
targetedControl[161355] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 161355}
targetedControl[28272] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 28272}
targetedControl[277792] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 277792}
targetedControl[161372] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 161372}
targetedControl[277778] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 277778}
targetedControl[51514] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 51514}
targetedControl[287712] = {name = 'Haymaker', class = 'Racial', subEvent = 'SPELL_AURA_APPLIED', spellID = 287712}
targetedControl[5782] = {name = 'Fear', class = 'Warlock', subEvent = 'SPELL_AURA_APPLIED', spellID = 5782}
targetedControl[339] = {name = 'Entangling Roots', class = 'Druid', subEvent = 'SPELL_AURA_APPLIED', spellID = 339}
targetedControl[107079] = {name = 'Quaking Palm', class = 'Racial', subEvent = 'SPELL_AURA_APPLIED', spellID = 107079}
targetedControl[126819] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 126819}
targetedControl[3355] = {name = 'Freezing Trap', class = 'Hunter', subEvent = 'SPELL_AURA_APPLIED', spellID = 3355}
targetedControl[61305] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 61305}
targetedControl[118] = {name = 'Polymorph', class = 'Mage', subEvent = 'SPELL_AURA_APPLIED', spellID = 118}
targetedControl[2094] = {name = 'Blind', class = 'Rogue', subEvent = 'SPELL_AURA_APPLIED', spellID = 2094}
targetedControl[269352] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 269352}
targetedControl[6770] = {name = 'Sap', class = 'Rogue', subEvent = 'SPELL_AURA_APPLIED', spellID = 6770}
targetedControl[211010] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 211010}
targetedControl[211015] = {name = 'Hex', class = 'Shaman', subEvent = 'SPELL_AURA_APPLIED', spellID = 211015}
targetedControl[221562] = {name = 'Asphyxiate', class = 'Death Knight', subEvent = 'SPELL_AURA_APPLIED', spellID = 221562}
targetedControl[360806] = {name = 'Sleep Walk', class = 'Evoker', subEvent = 'SPELL_AURA_APPLIED', spellID = 360806}
targetedControl[205364] = {name = 'Dominate Mind', class = 'Priest', subEvent = 'SPELL_AURA_APPLIED', spellID = 205364}
targetedControl[107570] = {name = 'Storm Bolt', class = 'Warrior', subEvent = 'SPELL_AURA_APPLIED', spellID = 107570}
targetedControl[385952] = {name = 'Shield Charge', class = 'Warrior', subEvent = 'SPELL_AURA_APPLIED', spellID = 385952}
targetedControl[22570] = {name = 'Maim', class = 'Druid', subEvent = 'SPELL_AURA_APPLIED', spellID = 22570}
targetedControl[211881] = {name = 'Fel Eruption', class = 'Demon Hunter', subEvent = 'SPELL_AURA_APPLIED', spellID = 211881}
targetedControl[853] = {name = 'Hammer of Justice', class = 'Paladin', subEvent = 'SPELL_AURA_APPLIED', spellID = 853}
targetedControl[1776] = {name = 'Gouge', class = 'Rogue', subEvent = 'SPELL_AURA_APPLIED', spellID = 1776}
targetedControl[408] = {name = 'Kidney Shot', class = 'Rogue', subEvent = 'SPELL_AURA_APPLIED', spellID = 408}
targetedControl[1833] = {name = 'Cheap Shot', class = 'Rogue', subEvent = 'SPELL_AURA_APPLIED', spellID = 1833}
targetedControl[64044] = {name = 'Psychic Horror', class = 'Priest', subEvent = 'SPELL_AURA_APPLIED', spellID = 64044}

-- Group Utility

SPELL_TABLE['groupUtility'] = {}
local groupUtility = SPELL_TABLE['groupUtility']

groupUtility[205636] = {name = 'Force of Nature', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 205636}
groupUtility[192077] = {name = 'Wind Rush Totem', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 192077}
groupUtility[106898] = {name = 'Stampeding Roar', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 106898}
groupUtility[77761] = {name = 'Stampeding Roar', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 77761}
groupUtility[77764] = {name = 'Stampeding Roar', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 77764}
groupUtility[114018] = {name = 'Shroud of Concealment', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 114018}
groupUtility[64901] = {name = 'Symbol of Hope', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 64901}
groupUtility[374968] = {name = 'Time Spiral', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 374968}
groupUtility[198103] = {name = 'Earth Elemental', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 198103}

-- Slows

SPELL_TABLE['slows'] = {}
local slows = SPELL_TABLE['slows']

slows[260364] = {name = 'Arcane Pulse', class = 'Racial', subEvent = 'SPELL_CAST_SUCCESS', spellID = 260364}
slows[45524] = {name = 'Chains of Ice', class = 'Death Knight', subEvent = 'SPELL_AURA_APPLIED', spellID = 45524}
slows[12323] = {name = 'Piercing Howl', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 12323}
slows[334275] = {name = 'Curse of Exhaustion', class = 'Warlock', subEvent = 'SPELL_AURA_APPLIED', spellID = 334275}
slows[1715] = {name = 'Hamstring', class = 'Warrior', subEvent = 'SPELL_AURA_APPLIED', spellID = 1715}
slows[2484] = {name = 'Earthbind Totem', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 2484}
slows[187698] = {name = 'Tar Trap', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 187698}

-- Battle Res

SPELL_TABLE['battleRes'] = {}
local battleRes = SPELL_TABLE['battleRes']

battleRes[20484] = {name = 'Rebirth', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 20484}
battleRes[61999] = {name = 'Raise Ally', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 61999}
battleRes[20707] = {name = 'Soulstone', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 20707}
battleRes[391054] = {name = 'Intercession', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 391054}
battleRes[393795] = {name = 'Arclight Vital Correctors', class = 'Item', subEvent = 'SPELL_CAST_SUCCESS', spellID = 393795}

-- Bloodlust/Heroism

SPELL_TABLE['lust'] = {}
local lust = SPELL_TABLE['lust']

lust[160452] = {name = 'Netherwinds', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 160452}
lust[80353] = {name = 'Time Warp', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 80353}
lust[381301] = {name = 'Feral Hide Drums', class = 'Item', subEvent = 'SPELL_CAST_SUCCESS', spellID = 381301}
lust[32182] = {name = 'Heroism', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 32182}
lust[264667] = {name = 'Primal Rage', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 264667}
lust[90355] = {name = 'Ancient Hysteria', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 90355}
lust[2825] = {name = 'Bloodlust', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 2825}
lust[390386] = {name = 'Fury of the Aspects', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 390386}

-- Interrupts

SPELL_TABLE['interrupts'] = {}
local interrupts = SPELL_TABLE['interrupts']

interrupts[187707] = {name = 'Muzzle', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 187707}
interrupts[96231] = {name = 'Rebuke', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 96231}
interrupts[171138] = {name = 'Shadow Lock', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 171138}
interrupts[6552] = {name = 'Pummel', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 6552}
interrupts[57994] = {name = 'Wind Shear', class = 'Shaman', subEvent = 'SPELL_CAST_SUCCESS', spellID = 57994}
interrupts[1766] = {name = 'Kick', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 1766}
interrupts[116705] = {name = 'Spear Hand Strike', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 116705}
interrupts[183752] = {name = 'Disrupt', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 183752}
interrupts[147362] = {name = 'Counter Shot', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 147362}
interrupts[47528] = {name = 'Mind Freeze', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 47528}
interrupts[171140] = {name = 'Shadow Lock', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 171140}
interrupts[15487] = {name = 'Silence', class = 'Priest', subEvent = 'SPELL_CAST_SUCCESS', spellID = 15487}
interrupts[347008] = {name = 'Axe Toss', class = 'Warlock', subEvent = 'SPELL_CAST_SUCCESS', spellID = 347008}
interrupts[97547] = {name = 'Solar Beam', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 97547}
interrupts[2139] = {name = 'Counterspell', class = 'Mage', subEvent = 'SPELL_CAST_SUCCESS', spellID = 2139}
interrupts[106839] = {name = 'Skull Bash', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 106839}
interrupts[351338] = {name = 'Quell', class = 'Evoker', subEvent = 'SPELL_CAST_SUCCESS', spellID = 351338}
interrupts[147362] = {name = 'Counter Shot', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 147362}

-- Taunts

SPELL_TABLE['taunts'] = {}
local taunts = SPELL_TABLE['taunts']

taunts[62124] = {name = 'Hand of Reckoning', class = 'Paladin', subEvent = 'SPELL_CAST_SUCCESS', spellID = 62124}
taunts[49576] = {name = 'Death Grip', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 49576}
taunts[56222] = {name = 'Dark Command', class = 'Death Knight', subEvent = 'SPELL_CAST_SUCCESS', spellID = 56222}
taunts[115546] = {name = 'Provoke', class = 'Monk', subEvent = 'SPELL_CAST_SUCCESS', spellID = 115546}
taunts[6795] = {name = 'Growl', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 6795}
taunts[2649] = {name = 'Growl', class = 'Druid', subEvent = 'SPELL_CAST_SUCCESS', spellID = 2649}
taunts[185245] = {name = 'Torment', class = 'Demon Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 185245}
taunts[355] = {name = 'Taunt', class = 'Warrior', subEvent = 'SPELL_CAST_SUCCESS', spellID = 355}

-- Nuisances/Toys

SPELL_TABLE['toys'] = {}
local toys = SPELL_TABLE['toys']

toys[61551] = {name = 'Toy Train Set', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 61551}
toys[62943] = {name = 'Wind-Up Train Wrecker', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 62943}
toys[135253] = {name = 'Jaina\'s Locket', class = 'Item', subEvent = 'SPELL_CAST_SUCCESS', spellID = 135253}
toys[384911] = {name = 'Atomic Recalibrator', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 384911}
toys[161399] = {name = 'Swapblaster', class = 'Item', subEvent = 'SPELL_CAST_SUCCESS', spellID = 161399}
toys[297571] = {name = 'Transmorpher Beacon', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 297571}
toys[302750] = {name = 'Brewfest Chowdown Trophy', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 302750}
toys[376664] = {name = 'Ohuna Perch', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 376664}
toys[261602] = {name = 'Katy\'s Stampwhistle', class = 'Toy', subEvent = 'SPELL_CAST_SUCCESS', spellID = 261602}

-- Other

SPELL_TABLE['others'] = {}
local others = SPELL_TABLE['others']

others[57934] = {name = 'Tricks of the Trade', class = 'Rogue', subEvent = 'SPELL_CAST_SUCCESS', spellID = 57934}
others[34477] = {name = 'Misdirection', class = 'Hunter', subEvent = 'SPELL_CAST_SUCCESS', spellID = 34477}

function ADDON:GetSpellsForCategory(category)
  return SPELL_TABLE[category]
end

function ADDON:GetSpellData(category, spellID)
	return SPELL_TABLE[category][spellID]
end
