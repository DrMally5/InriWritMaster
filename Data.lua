-- Inri's WritMaster: static data
-- Writs, item IDs, rep and known customers were decoded from QuestieDB (Forever build).
-- Values marked nil are unconfirmed; the addon fills some of them in as you play.
local _, WM = ...

WM.FACTION = { Alliance = 2586, Horde = 2587 }          -- Azeroth Commerce Authority / Durotar Supply and Logistics
WM.FAVOR_CURRENCY = 3402                                 -- Merchant's Favor
WM.SEALED = { J = 262888, E = 262889, A = 262890 }       -- Sealed Journeyman's / Expert's / Artisan's Writ
WM.TIER_NAME = { J = "Journeyman", E = "Expert", A = "Artisan" }
WM.TIER_REP  = { J = 75, E = 125, A = 200 }
WM.PROF_NAME = { AL = "Alchemy", BL = "Blacksmithing", EN = "Engineering", LW = "Leatherworking", TA = "Tailoring" }

-- Rep needed from Neutral 0 (guide figures, excluding bonuses)
WM.REP_GOALS = { {"Friendly", 3000}, {"Honored", 9000}, {"Revered", 21000}, {"Exalted", 42000} }

WM.CAMP = {
  Alliance = { name = "Azeroth Commerce Authority", where = "Three Corners, Redridge Mountains", map = 1433, x = 9.7, y = 70.9, intake = "Marcy Baker" },
  Horde    = { name = "Durotar Supply and Logistics", where = "West of the Crossroads, The Barrens", map = 1413, x = 50.1, y = 29.4, intake = "Dokimi" },
}

WM.ZONES = { [1418]="Badlands", [1431]="Duskwood", [1437]="Wetlands", [1434]="Stranglethorn Vale", [1416]="Alterac Mountains",
  [1417]="Arathi Highlands", [1424]="Hillsbrad Foothills", [1440]="Ashenvale", [1441]="Thousand Needles", [1442]="Stonetalon Mountains",
  [1433]="Redridge Mountains", [1413]="The Barrens",
  [1448]="Felwood", [1445]="Dustwallow Marsh", [1451]="Silithus", [1450]="Moonglade", [1444]="Feralas" }

-- Craftsman's Writs.  q=quest, w=named writ item, i=requested item, n=qty, t=tier, p=profession, s=skill, r=rep,
-- zh=zone hint only. c={customer, uiMapID, x, y} (nil = not confirmed yet; learned automatically when you turn the writ in), ao=Alliance-only
WM.WRITS = {
  {q=94004, w=264011, i=3391, n=1, t="J", p="AL", s=175, r=75, c={"Sos'mol", 1416, 38.3, 61.1}}, -- Elixir of Ogre's Strength
  {q=94212, w=264012, i=3383, n=1, t="J", p="AL", s=120, r=75, c={"Muggol Breezebeard", 1417, 48.6, 55.8}}, -- Elixir of Wisdom
  {q=94213, w=264013, i=3385, n=1, t="J", p="AL", s=145, r=75, c={"Ash'alari", 1440, 59.9, 72.1}}, -- Lesser Mana Potion
  {q=94214, w=264014, i=6048, n=1, t="J", p="AL", s=160, r=75, c={"Kzixx", 1431, 81.8, 19.8}, ao=true}, -- Shadow Protection Potion
  {q=94215, w=264015, i=5634, n=1, t="J", p="AL", s=175, r=75, c={"Webbed Mudsnout Gnoll", 1424, 62.4, 67.2}}, -- Free Action Potion
  {q=94216, w=264016, i=3390, n=1, t="J", p="AL", s=165, r=75, c={"Ziz Fizziks", 1442, 59.0, 62.6}}, -- Elixir of Lesser Agility
  {q=94217, w=264017, i=3388, n=1, t="J", p="AL", s=150, r=75, c={"Short John Mithril", 1434, 29.6, 47.4}}, -- Strong Troll's Blood Potion
  {q=94218, w=264018, i=8951, n=1, t="J", p="AL", s=215, r=75, c={"Rizzle Brassbolts", 1441, 77.2, 77.4}}, -- Elixir of Greater Defense
  {q=94219, w=264019, i=5996, n=1, t="J", p="AL", s=120, r=75, c={"Kixxle", 1437, 50.2, 37.7}}, -- Elixir of Water Breathing
  {q=94220, w=264020, i=5540, n=1, t="J", p="BL", s=115, r=75, c={"Alan Sneeks", 1416, 30.4, 61.2}}, -- Pearl-handled Dagger
  {q=94221, w=264021, i=11128, n=1, t="J", p="BL", s=130, r=75, c={"Muggol Breezebeard", 1417, 48.6, 55.8}}, -- Golden Rod
  {q=94222, w=264022, i=5541, n=1, t="J", p="BL", s=145, r=75, c={"Cowardly Peon", 1440, 78.2, 69.1}}, -- Iridescent Hammer
  {q=94223, w=264023, i=15869, n=1, t="J", p="BL", s=75, r=75, c={"Battered Trunk", 1431, 26.2, 36.3}}, -- Silver Skeleton Key
  {q=94224, w=264024, i=3491, n=1, t="J", p="BL", s=135, r=75, c={"Gorgrash", 1424, 80.0, 48.2}}, -- Heavy Bronze Mace
  {q=94225, w=264025, i=2865, n=1, t="J", p="BL", s=120, r=75, c={"Ziz Fizziks", 1442, 59.0, 62.6}}, -- Rough Bronze Leggings
  {q=94226, w=264026, i=3485, n=1, t="J", p="BL", s=155, r=75, c={"\"Sea Wolf\" MacKinley", 1434, 27.7, 77.1}}, -- Green Iron Gauntlets
  {q=94227, w=264027, i=3848, n=1, t="J", p="BL", s=110, r=75, c={"\"Plucky\" Johnson", 1441, 79.6, 75.6}}, -- Big Bronze Knife
  {q=94228, w=264028, i=3484, n=1, t="J", p="BL", s=150, r=75, c={"Kixxle", 1437, 50.2, 37.7}}, -- Green Iron Boots
  {q=94229, w=264029, i=5507, n=1, t="J", p="EN", s=160, r=75, c={"Alan Sneeks", 1416, 30.6, 61.0}}, -- Ornate Spyglass
  {q=94230, w=264030, i=4384, n=1, t="J", p="EN", s=175, r=75, c={"Alyce", 1417, 34.0, 23.2}}, -- Explosive Sheep
  {q=94231, w=264031, i=4383, n=1, t="J", p="EN", s=170, r=75, c={"Grembly", 1440, 82.1, 51.0}}, -- Moonsight Rifle
  {q=94232, w=264032, i=4381, n=1, t="J", p="EN", s=165, r=75, c={"Kzixx", 1431, 81.7, 19.9}}, -- Minor Recombobulator
  {q=94233, w=264033, i=6712, n=1, t="J", p="EN", s=115, r=75, c={"Gorgrash", 1424, 80.0, 48.2}}, -- Practice Lock
  {q=94234, w=264034, i=4373, n=1, t="J", p="EN", s=145, r=75, c={"Ziz Fizziks", 1442, 59.0, 62.6}}, -- Shadow Goggles
  {q=94235, w=264035, i=7506, n=1, t="J", p="EN", s=150, r=75, c={"Scooty", 1434, 27.6, 77.5}}, -- Gnomish Universal Remote
  {q=94236, w=264036, i=4380, n=1, t="J", p="EN", s=140, r=75, c={"Razzeric", 1441, 80.3, 76.1}}, -- Big Bronze Bomb
  {q=94237, w=264037, i=8069, n=200, t="J", p="EN", s=125, r=75, c={"Kixxle", 1437, 50.1, 37.7}}, -- Crafted Solid Shot
  {q=94238, w=264038, i=18662, n=1, t="J", p="LW", s=125, r=75, c={"Sos'mol", 1416, 38.4, 61.3}}, -- Heavy Leather Ball
  {q=94239, w=264039, i=5958, n=1, t="J", p="LW", s=105, r=75, c={"Alyce", 1417, 34.0, 23.2}}, -- Fine Leather Pants
  {q=94240, w=264040, i=7349, n=1, t="J", p="LW", s=135, r=75, c={"Murache", 1440, 64.5, 79.2}}, -- Herbalist's Gloves
  {q=94241, w=264041, i=2317, n=1, t="J", p="LW", s=100, r=75, c={"Kzixx", 1431, 81.8, 19.8}}, -- Dark Leather Tunic
  {q=94242, w=264042, i=7358, n=1, t="J", p="LW", s=140, r=75, c={"Kris Legace", 1424, 80.1, 38.9}}, -- Pilferer's Gloves
  {q=94243, w=264043, i=7371, n=1, t="J", p="LW", s=145, r=75, c={"Ziz Fizziks", 1442, 59.0, 62.6}}, -- Heavy Quiver
  {q=94244, w=264044, i=4252, n=1, t="J", p="LW", s=140, r=75, c={"Narkk", 1434, 28.2, 74.5}}, -- Dark Leather Shoulders
  {q=94245, w=264045, i=4254, n=1, t="J", p="LW", s=150, r=75, c={"Goblin Pit Boss", 1441, 79.9, 76.7}}, -- Barbaric Gloves
  {q=94246, w=264046, i=7284, n=1, t="J", p="LW", s=120, r=75, c={"Kixxle", 1437, 50.1, 37.7}}, -- Red Whelp Gloves
  {q=94247, w=264047, i=5766, n=1, t="J", p="TA", s=130, r=75, c={"Alan Sneeks", 1416, 30.6, 61.0}}, -- Lesser Wizard's Robe
  {q=94248, w=264048, i=6263, n=1, t="J", p="TA", s=100, r=75, c={"Alyce", 1417, 34.0, 23.2}}, -- Blue Overalls
  {q=94249, w=264049, i=7048, n=1, t="J", p="TA", s=130, r=75, c={"Cowardly Peon", 1440, 78.2, 69.1}}, -- Azure Silk Hood
  {q=94250, w=264050, i=4245, n=1, t="J", p="TA", s=145, r=75, c={"Kzixx", 1431, 81.7, 19.9}}, -- Small Silk Pack
  {q=94251, w=264051, i=4317, n=1, t="J", p="TA", s=125, r=75, c={"Bath'rah the Windwatcher", 1416, 80.5, 66.9}}, -- Phoenix Pants
  {q=94252, w=264052, i=4313, n=1, t="J", p="TA", s=80, r=75, c={"Ziz Fizziks", 1442, 59.0, 62.6}}, -- Red Woolen Boots
  {q=94253, w=264053, i=10048, n=1, t="J", p="TA", s=95, r=75, c={"Hekshi", 1434, 50.6, 19.2}}, -- Colorful Kilt
  {q=94254, w=264054, i=6264, n=1, t="J", p="TA", s=115, r=75, c={"Magus Tirth", 1441, 78.4, 75.7}}, -- Greater Adept's Robe
  {q=94255, w=264055, i=4321, n=1, t="J", p="TA", s=135, r=75, c={"Kixxle", 1437, 50.2, 37.7}}, -- Spider Silk Slippers
  {q=94256, w=264056, i=6050, n=1, t="E", p="AL", s=205, r=125, c={"Lotwil Veriatus", 1418, 25.9, 44.9}}, -- Frost Protection Potion
  {q=94257, w=264057, i=3823, n=1, t="E", p="AL", s=185, r=125, c=nil}, -- Lesser Invisibility Potion
  {q=94258, w=264058, i=4623, n=1, t="E", p="AL", s=230, r=125, c=nil, zh=1451}, -- Lesser Stoneshield Potion
  {q=94259, w=264059, i=6052, n=1, t="E", p="AL", s=210, r=125, c={"Greta Mosshoof", 1448, 51.1, 82.2}}, -- Nature Protection Potion
  {q=94260, w=264060, i=10592, n=1, t="E", p="AL", s=220, r=125, c={"Customer (see quest marker)", 1444, 72.7, 52.1}}, -- Catseye Elixir
  {q=94261, w=264061, i=5633, n=1, t="E", p="AL", s=195, r=125, c={"Dendrite Starblaze (unconfirmed)", 1450, 56.2, 30.6}}, -- Great Rage Potion
  {q=94262, w=264062, i=3827, n=1, t="E", p="AL", s=180, r=125, c=nil}, -- Mana Potion
  {q=94263, w=264063, i=6049, n=1, t="E", p="AL", s=210, r=125, c=nil}, -- Fire Protection Potion
  {q=94264, w=264064, i=3824, n=1, t="E", p="AL", s=190, r=125, c=nil}, -- Shadow Oil
  {q=94265, w=264065, i=9061, n=1, t="E", p="AL", s=225, r=125, c=nil}, -- Goblin Rocket Fuel
  {q=94266, w=264066, i=8949, n=1, t="E", p="AL", s=205, r=125, c=nil}, -- Elixir of Agility
  {q=94267, w=264067, i=9144, n=1, t="E", p="AL", s=225, r=125, c=nil}, -- Wildvine Potion
  {q=94268, w=264068, i=7922, n=1, t="E", p="BL", s=210, r=125, c=nil}, -- Steel Plate Helm
  {q=94269, w=264069, i=9060, n=1, t="E", p="BL", s=200, r=125, c=nil}, -- Inlaid Mithril Cylinder
  {q=94270, w=264070, i=6041, n=1, t="E", p="BL", s=190, r=125, c={"Ugbert", 1445, 40.9, 28.0}}, -- Steel Weapon Chain
  {q=94271, w=264071, i=7928, n=1, t="E", p="BL", s=220, r=125, c=nil}, -- Ornate Mithril Shoulder
  {q=94272, w=264072, i=7942, n=1, t="E", p="BL", s=220, r=125, c=nil}, -- Blue Glittering Axe
  {q=94273, w=264073, i=3853, n=1, t="E", p="BL", s=180, r=125, c=nil}, -- Moonsteel Broadsword
  {q=94274, w=264074, i=3837, n=1, t="E", p="BL", s=190, r=125, c=nil}, -- Golden Scale Coif
  {q=94275, w=264075, i=7964, n=1, t="E", p="BL", s=175, r=125, c=nil}, -- Solid Sharpening Stone
  {q=94276, w=264076, i=7943, n=1, t="E", p="BL", s=225, r=125, c=nil}, -- Wicked Mithril Blade
  {q=94277, w=264077, i=11144, n=1, t="E", p="BL", s=180, r=125, c=nil}, -- Truesilver Rod
  {q=94278, w=264078, i=9366, n=1, t="E", p="BL", s=200, r=125, c=nil}, -- Golden Scale Gauntlets
  {q=94279, w=264079, i=7941, n=1, t="E", p="BL", s=210, r=125, c=nil}, -- Heavy Mithril Axe
  {q=94280, w=264080, i=4396, n=1, t="E", p="EN", s=220, r=125, c=nil}, -- Mechanical Dragonling
  {q=94281, w=264081, i=4392, n=1, t="E", p="EN", s=185, r=125, c=nil}, -- Advanced Target Dummy
  {q=94282, w=264082, i=4393, n=1, t="E", p="EN", s=205, r=125, c=nil}, -- Craftsman's Monocle
  {q=94283, w=264083, i=4395, n=1, t="E", p="EN", s=215, r=125, c=nil}, -- Goblin Land Mine
  {q=94284, w=264084, i=10501, n=1, t="E", p="EN", s=240, r=125, c=nil}, -- Catseye Ultra Goggles
  {q=94285, w=264085, i=10560, n=1, t="E", p="EN", s=200, r=125, c={"Narianna (unconfirmed)", 1450, 53.3, 42.7}}, -- Unstable Trigger
  {q=94286, w=264086, i=4852, n=1, t="E", p="EN", s=185, r=125, c=nil}, -- Flash Bomb
  {q=94287, w=264087, i=10500, n=1, t="E", p="EN", s=225, r=125, c=nil}, -- Fire Goggles
  {q=94288, w=264088, i=10514, n=1, t="E", p="EN", s=215, r=125, c=nil}, -- Mithril Frag Bomb
  {q=94289, w=264089, i=10498, n=1, t="E", p="EN", s=175, r=125, c=nil}, -- Gyromatic Micro-Adjustor
  {q=94290, w=264090, i=11590, n=1, t="E", p="EN", s=200, r=125, c=nil}, -- Mechanical Repair Kit
  {q=94291, w=264091, i=16005, n=1, t="E", p="EN", s=305, r=125, c=nil}, -- Dark Iron Bomb
  {q=94292, w=264092, i=8174, n=1, t="E", p="LW", s=195, r=125, c=nil}, -- Comfortable Leather Hat
  {q=94293, w=264093, i=5965, n=1, t="E", p="LW", s=180, r=125, c=nil}, -- Guardian Cloak
  {q=94294, w=264094, i=7378, n=1, t="E", p="LW", s=180, r=125, c=nil}, -- Dusky Bracers
  {q=94295, w=264095, i=8214, n=1, t="E", p="LW", s=220, r=125, c=nil}, -- Wild Leather Helmet
  {q=94296, w=264096, i=8210, n=1, t="E", p="LW", s=215, r=125, c=nil}, -- Wild Leather Shoulders
  {q=94297, w=264097, i=8217, n=1, t="E", p="LW", s=220, r=125, c={"Narianna (unconfirmed)", 1450, 53.3, 42.7}}, -- Quickdraw Quiver
  {q=94298, w=264098, i=7391, n=1, t="E", p="LW", s=195, r=125, c=nil}, -- Swift Boots
  {q=94299, w=264099, i=8192, n=1, t="E", p="LW", s=205, r=125, c=nil}, -- Nightscape Shoulders
  {q=94300, w=264100, i=8201, n=1, t="E", p="LW", s=215, r=125, c=nil}, -- Big Voodoo Mask
  {q=94301, w=264101, i=8200, n=1, t="E", p="LW", s=210, r=125, c=nil}, -- Big Voodoo Robe
  {q=94302, w=264102, i=8189, n=1, t="E", p="LW", s=205, r=125, c=nil}, -- Turtle Scale Breastplate
  {q=94303, w=264103, i=8218, n=1, t="E", p="LW", s=220, r=125, c=nil}, -- Thick Leather Ammo Pouch
  {q=94304, w=264104, i=10050, n=1, t="E", p="TA", s=205, r=125, c=nil}, -- Mageweave Bag
  {q=94305, w=264105, i=10023, n=1, t="E", p="TA", s=205, r=125, c=nil}, -- Shadoweave Gloves
  {q=94306, w=264106, i=7063, n=1, t="E", p="TA", s=185, r=125, c=nil}, -- Crimson Silk Robe
  {q=94307, w=264107, i=10004, n=1, t="E", p="TA", s=195, r=125, c=nil}, -- Shadoweave Robe
  {q=94308, w=264108, i=22246, n=1, t="E", p="TA", s=205, r=125, c=nil}, -- Enchanted Mageweave Pouch
  {q=94309, w=264109, i=4329, n=1, t="E", p="TA", s=185, r=125, c=nil}, -- Star Belt
  {q=94310, w=264110, i=9998, n=1, t="E", p="TA", s=185, r=125, c=nil}, -- Black Mageweave Vest
  {q=94311, w=264111, i=10009, n=1, t="E", p="TA", s=195, r=125, c=nil}, -- Red Mageweave Pants
  {q=94312, w=264112, i=10052, n=1, t="E", p="TA", s=190, r=125, c=nil}, -- Orange Martial Shirt
  {q=94313, w=264113, i=10008, n=1, t="E", p="TA", s=185, r=125, c=nil}, -- White Bandit Mask
  {q=94314, w=264114, i=10042, n=1, t="E", p="TA", s=205, r=125, c=nil}, -- Cindercloth Robe
  {q=94315, w=264115, i=7061, n=1, t="E", p="TA", s=180, r=125, c=nil}, -- Earthen Silk Belt
  {q=94316, w=264116, i=9224, n=1, t="A", p="AL", s=265, r=200, c=nil, zh=1451}, -- Elixir of Demonslaying
  {q=94317, w=264117, i=12190, n=1, t="A", p="AL", s=245, r=200, c=nil}, -- Dreamless Sleep Potion
  {q=94318, w=264118, i=13457, n=1, t="A", p="AL", s=305, r=200, c=nil}, -- Greater Fire Protection Potion
  {q=94319, w=264119, i=9233, n=1, t="A", p="AL", s=265, r=200, c=nil}, -- Elixir of Detect Demon
  {q=94320, w=264120, i=9088, n=1, t="A", p="AL", s=255, r=200, c=nil}, -- Gift of Arthas
  {q=94321, w=264121, i=13513, n=1, t="A", p="AL", s=315, r=200, c=nil}, -- Flask of Chromatic Resistance
  {q=94322, w=264122, i=3387, n=1, t="A", p="AL", s=275, r=200, c=nil}, -- Limited Invulnerability Potion
  {q=94323, w=264123, i=18253, n=1, t="A", p="AL", s=310, r=200, c=nil}, -- Major Rejuvenation Potion
  {q=94324, w=264124, i=246948, n=1, t="A", p="AL", s=260, r=200, c=nil}, -- Distilled Firewater
  {q=94325, w=264125, i=12417, n=1, t="A", p="BL", s=290, r=200, c=nil}, -- Radiant Circlet
  {q=94326, w=264126, i=12416, n=1, t="A", p="BL", s=255, r=200, c=nil}, -- Radiant Belt
  {q=94327, w=264127, i=7929, n=1, t="A", p="BL", s=225, r=200, c=nil}, -- Orcish War Leggings
  {q=94328, w=264128, i=7969, n=1, t="A", p="BL", s=230, r=200, c=nil}, -- Mithril Spurs
  {q=94329, w=264129, i=12422, n=1, t="A", p="BL", s=295, r=200, c=nil}, -- Imperial Plate Chest
  {q=94330, w=264130, i=20549, n=1, t="A", p="BL", s=320, r=200, c=nil}, -- Darkrune Gauntlets
  {q=94331, w=264131, i=12775, n=1, t="A", p="BL", s=280, r=200, c=nil}, -- Huge Thorium Battleaxe
  {q=94332, w=264132, i=15872, n=1, t="A", p="BL", s=250, r=200, c=nil}, -- Arcanite Skeleton Key
  {q=94333, w=264133, i=7947, n=1, t="A", p="BL", s=255, r=200, c=nil}, -- Ebon Shiv
  {q=94334, w=264134, i=16023, n=1, t="A", p="EN", s=295, r=200, c=nil}, -- Masterwork Target Dummy
  {q=94335, w=264135, i=10504, n=1, t="A", p="EN", s=265, r=200, c=nil}, -- Green Lens
  {q=94336, w=264136, i=15996, n=1, t="A", p="EN", s=285, r=200, c=nil}, -- Lifelike Mechanical Toad
  {q=94337, w=264137, i=18645, n=1, t="A", p="EN", s=275, r=200, c=nil}, -- Alarm-O-Bot
  {q=94338, w=264138, i=18587, n=1, t="A", p="EN", s=285, r=200, c=nil}, -- Goblin Jumper Cables XL
  {q=94339, w=264139, i=18232, n=1, t="A", p="EN", s=320, r=200, c=nil}, -- Field Repair Bot 74A
  {q=94340, w=264140, i=18631, n=1, t="A", p="EN", s=270, r=200, c=nil}, -- Truesilver Transformer
  {q=94341, w=264141, i=10548, n=1, t="A", p="EN", s=260, r=200, c=nil}, -- Sniper Scope
  {q=94342, w=264142, i=21277, n=1, t="A", p="EN", s=320, r=200, c=nil}, -- Tranquil Mechanical Yeti
  {q=94343, w=264143, i=15087, n=1, t="A", p="LW", s=285, r=200, c=nil}, -- Wicked Leather Pants
  {q=94344, w=264144, i=18258, n=1, t="A", p="LW", s=285, r=200, c=nil}, -- Gordok Ogre Suit
  {q=94345, w=264145, i=15053, n=1, t="A", p="LW", s=280, r=200, c=nil}, -- Volcanic Breastplate
  {q=94346, w=264146, i=15094, n=1, t="A", p="LW", s=285, r=200, c=nil}, -- Runic Leather Headband
  {q=94347, w=264147, i=15084, n=1, t="A", p="LW", s=260, r=200, c=nil}, -- Wicked Leather Bracers
  {q=94348, w=264148, i=15075, n=1, t="A", p="LW", s=285, r=200, c=nil}, -- Chimeric Vest
  {q=94349, w=264149, i=15080, n=1, t="A", p="LW", s=290, r=200, c=nil}, -- Heavy Scorpid Helm
  {q=94350, w=264150, i=15092, n=1, t="A", p="LW", s=270, r=200, c=nil}, -- Runic Leather Bracers
  {q=94351, w=264151, i=15071, n=1, t="A", p="LW", s=270, r=200, c=nil}, -- Frostsaber Boots
  {q=94352, w=264152, i=14130, n=1, t="A", p="TA", s=275, r=200, c=nil}, -- Wizardweave Turban
  {q=94353, w=264153, i=14046, n=1, t="A", p="TA", s=230, r=200, c=nil}, -- Runecloth Bag
  {q=94354, w=264154, i=13864, n=1, t="A", p="TA", s=250, r=200, c=nil}, -- Runecloth Boots
  {q=94355, w=264155, i=10036, n=1, t="A", p="TA", s=155, r=200, c=nil}, -- Tuxedo Jacket
  {q=94356, w=264156, i=14108, n=1, t="A", p="TA", s=255, r=200, c=nil}, -- Felcloth Boots
  {q=94357, w=264157, i=22251, n=1, t="A", p="TA", s=245, r=200, c=nil}, -- Cenarion Herb Bag
  {q=94358, w=264158, i=10025, n=1, t="A", p="TA", s=215, r=200, c=nil}, -- Shadoweave Mask
  {q=94359, w=264159, i=14141, n=1, t="A", p="TA", s=240, r=200, c=nil}, -- Ghostweave Vest
  {q=94360, w=264160, i=21340, n=1, t="A", p="TA", s=230, r=200, c=nil}, -- Soul Pouch
}

-- Waylaid crates. favor = Merchant's Favor for a plain (white) crate; Artisan values unconfirmed.
WM.CRATES = {
  {id=248685, name="Apprentice Curiosities", tier="Apprentice", lvl=10, favor=5, opts={{10940, 20}, {10939, 4}, {10978, 6}, {11084, 2}}}, -- 20 Strange Dust / 4 Greater Magic Essence / 6 Small Glimmering Shard / 2 Large Glimmering Shard
  {id=248702, name="Apprentice Fabrics", tier="Apprentice", lvl=10, favor=10, opts={{4231, 2}, {2996, 20}}}, -- 2 Cured Light Hide / 20 Bolt of Linen Cloth
  {id=248682, name="Apprentice Herbs", tier="Apprentice", lvl=10, favor=5, opts={{2447, 20}, {765, 20}, {2449, 10}, {785, 10}, {2450, 10}}}, -- 20 Peacebloom / 20 Silverleaf / 10 Earthroot / 10 Mageroyal / 10 Briarthorn
  {id=248703, name="Apprentice Ingots", tier="Apprentice", lvl=10, favor=5, opts={{2840, 20}, {3576, 20}, {2841, 10}}}, -- 20 Copper Bar / 20 Tin Bar / 10 Bronze Bar
  {id=248683, name="Apprentice Ore", tier="Apprentice", lvl=10, favor=5, opts={{2770, 20}, {2771, 20}}}, -- 20 Copper Ore / 20 Tin Ore
  {id=248704, name="Apprentice Parts", tier="Apprentice", lvl=10, favor=5, opts={{4359, 16}, {4361, 16}, {4363, 4}}}, -- 16 Handful of Copper Bolts / 16 Copper Tube / 4 Copper Modulator
  {id=248684, name="Apprentice Textiles", tier="Apprentice", lvl=10, favor=5, opts={{2589, 40}, {2318, 20}}}, -- 40 Linen Cloth / 20 Light Leather
  {id=248689, name="Journeyman Curiosities", tier="Journeyman", lvl=10, favor=10, opts={{11083, 20}, {11082, 4}, {11138, 6}, {11139, 2}}}, -- 20 Soul Dust / 4 Greater Astral Essence / 6 Small Glowing Shard / 2 Large Glowing Shard
  {id=248705, name="Journeyman Fabrics", tier="Journeyman", lvl=10, favor=20, opts={{2997, 6}, {4305, 10}, {4233, 2}}}, -- 6 Bolt of Woolen Cloth / 10 Bolt of Silk Cloth / 2 Cured Medium Hide
  {id=248686, name="Journeyman Herbs", tier="Journeyman", lvl=10, favor=10, opts={{3820, 10}, {2453, 10}, {3355, 10}, {3369, 10}, {3356, 10}}}, -- 10 Stranglekelp / 10 Bruiseweed / 10 Wild Steelbloom / 10 Grave Moss / 10 Kingsblood
  {id=248706, name="Journeyman Ingots", tier="Journeyman", lvl=10, favor=20, opts={{2842, 10}, {3575, 20}}}, -- 10 Silver Bar / 20 Iron Bar
  {id=248687, name="Journeyman Ore", tier="Journeyman", lvl=10, favor=10, opts={{2775, 10}, {2772, 20}}}, -- 10 Silver Ore / 20 Iron Ore
  {id=248707, name="Journeyman Parts", tier="Journeyman", lvl=10, favor=20, opts={{4371, 8}, {4375, 7}, {4382, 4}, {10558, 45}}}, -- 8 Bronze Tube / 7 Whirring Bronze Gizmo / 4 Bronze Framework / 45 Gold Power Core
  {id=248688, name="Journeyman Textiles", tier="Journeyman", lvl=10, favor=10, opts={{2592, 20}, {4306, 40}, {2319, 20}}}, -- 20 Wool Cloth / 40 Silk Cloth / 20 Medium Leather
  {id=248694, name="Expert Curiosities", tier="Expert", lvl=20, favor=15, opts={{11137, 20}, {11135, 4}, {11177, 6}, {11178, 2}}}, -- 20 Vision Dust / 4 Greater Mystic Essence / 6 Small Radiant Shard / 2 Large Radiant Shard
  {id=248690, name="Earthly Expert Herbs", tier="Expert", lvl=20, favor=15, opts={{3357, 20}, {3818, 10}, {3821, 10}, {3358, 10}}}, -- 20 Liferoot / 10 Fadeleaf / 10 Goldthorn / 10 Khadgar's Whisker
  {id=248708, name="Expert Fabrics", tier="Expert", lvl=20, favor=30, opts={{4339, 8}, {4236, 2}}}, -- 8 Bolt of Mageweave / 2 Cured Heavy Hide
  {id=248691, name="Flowering Expert Herbs", tier="Expert", lvl=20, favor=15, opts={{3819, 10}, {4625, 10}, {8831, 20}, {8836, 10}}}, -- 10 Wintersbite / 10 Firebloom / 20 Purple Lotus / 10 Arthas' Tears
  {id=248709, name="Expert Ingots", tier="Expert", lvl=20, favor=30, opts={{3860, 20}, {3859, 15}, {3577, 10}}}, -- 20 Mithril Bar / 15 Steel Bar / 10 Gold Bar
  {id=248692, name="Expert Ore", tier="Expert", lvl=20, favor=15, opts={{2776, 10}, {3858, 20}}}, -- 10 Gold Ore / 20 Mithril Ore
  {id=248710, name="Expert Parts", tier="Expert", lvl=20, favor=30, opts={{4387, 8}, {10559, 5}, {10560, 12}, {10561, 5}}}, -- 8 Iron Strut / 5 Mithril Tube / 12 Unstable Trigger / 5 Mithril Casing
  {id=248693, name="Expert Textiles", tier="Expert", lvl=20, favor=15, opts={{4338, 40}, {4234, 20}}}, -- 40 Mageweave Cloth / 20 Heavy Leather
  {id=248699, name="Artisan Curiosities", tier="Artisan", lvl=35, favor=nil, opts={{11176, 20}, {11175, 4}, {14343, 6}, {14344, 2}}}, -- 20 Dream Dust / 4 Greater Nether Essence / 6 Small Brilliant Shard / 2 Large Brilliant Shard
  {id=248695, name="Earthly Artisan Herbs", tier="Artisan", lvl=35, favor=nil, opts={{13464, 10}, {8838, 20}, {8839, 10}, {8845, 10}, {8846, 10}}}, -- 10 Golden Sansam / 20 Sungrass / 10 Blindweed / 10 Ghost Mushroom / 10 Gromsblood
  {id=248711, name="Artisan Fabrics", tier="Artisan", lvl=35, favor=nil, opts={{14048, 8}, {8172, 2}}}, -- 8 Bolt of Runecloth / 2 Cured Thick Hide
  {id=248696, name="Flowering Artisan Herbs", tier="Artisan", lvl=35, favor=nil, opts={{13463, 20}, {13465, 20}, {13466, 20}, {13467, 20}}}, -- 20 Dreamfoil / 20 Mountain Silversage / 20 Plaguebloom / 20 Icecap
  {id=248712, name="Artisan Ingots", tier="Artisan", lvl=35, favor=nil, opts={{11371, 2}, {6037, 10}, {12359, 20}}}, -- 2 Dark Iron Bar / 10 Truesilver Bar / 20 Thorium Bar
  {id=248697, name="Artisan Ore", tier="Artisan", lvl=35, favor=nil, opts={{7911, 10}, {10620, 20}, {11370, 20}}}, -- 10 Truesilver Ore / 20 Thorium Ore / 20 Dark Iron Ore
  {id=248713, name="Artisan Parts", tier="Artisan", lvl=35, favor=nil, opts={{15994, 5}, {18631, 5}, {16000, 2}}}, -- 5 Thorium Widget / 5 Truesilver Transformer / 2 Thorium Tube
  {id=248698, name="Artisan Textiles", tier="Artisan", lvl=35, favor=nil, opts={{14047, 40}, {4304, 20}, {8170, 20}}}, -- 40 Runecloth / 20 Thick Leather / 20 Rugged Leather
}

-- Recipe vendors: items = {itemID, favorCost, repRequired (F/H/R/E), skill [, faction]}
WM.VENDORS = {
  { prof="Alchemy", ally={"Nina Surefire", 10.8, 72.6}, horde={"Apothecary Durelle", 49.8, 29.6}, items={
    {250364, 180, "H", 275}, -- Recipe: Elixir of Cunning
    {250365, 180, "H", 250}, -- Recipe: Elixir of the Phalanx
    {250367, 45, nil, 95}, -- Recipe: Lesser Cleric's Elixir
    {250369, 120, "F", 195}, -- Recipe: Greater Cleric's Elixir
    {250371, 120, "F", 200}, -- Recipe: Elixir of Greater Fortitude
    {250372, 180, "H", 285}, -- Recipe: Elixir of Wicked Regeneration
    {250373, 180, "H", 280}, -- Recipe: Elixir of the Owl
    {250374, 180, "H", 275}, -- Recipe: Elixir of Sages
    {250376, 45, nil, 75}, -- Recipe: Lesser Mageblood Elixir
    {250377, 120, "F", 175}, -- Recipe: Greater Mageblood Elixir
    {250378, 45, nil, 120}, -- Recipe: Lesser Arcane Elixir
    {250379, 180, "H", 285}, -- Recipe: Elixir of Nature Power
    {250381, 45, nil, 65}, -- Recipe: Elixir of Lesser Spirit
    {250383, 120, "F", 165}, -- Recipe: Elixir of Greater Spirit
    {250384, 180, "H", 275}, -- Recipe: Elixir of the Whale
    {250386, 180, "H", 275}, -- Recipe: Elixir of Ferocity
    {250387, 240, "H", 300}, -- Recipe: Elixir of the Grizzly
    {250388, 45, nil, 95}, -- Recipe: Elixir of Lesser Intellect
    {250978, 45, nil, 135}, -- Recipe: Spellblasting Potion
    {250981, 180, "H", 285}, -- Recipe: Major Spellblasting Potion
    {250984, 45, nil, 140}, -- Recipe: Frenzy Potion
    {250987, 240, "H", 290}, -- Recipe: Major Frenzy Potion
    {250990, 45, nil, 130}, -- Recipe: Mender's Potion
    {250993, 180, "H", 280}, -- Recipe: Major Mender's Potion
    {250994, 180, "H", 275}, -- Recipe: Potion of Venomous Blood
    {250995, 180, "H", 265}, -- Recipe: Caustic Smog Potion
    {250996, 120, "F", 180, nil, "Favor cost unconfirmed"}, -- Recipe: Disorienting Smog Potion (Friendly, Alchemy 180 per Wowhead; cost assumed like other Friendly alchemy recipes)
    {250997, 120, "F", 245}, -- Recipe: Dragonfire Potion
    {250998, 180, "H", 280}, -- Recipe: Potion of Elemental Purging
    {271621, 1000, nil, 300}, -- Alchemy Certification
  }},
  { prof="Blacksmithing", ally={"Stondry Darkhammer", 10.4, 74.6}, horde={"Gor'mak", 49.8, 29.6}, items={
    {251355, 30, nil, 85}, -- Plans: Veteran's Boots
    {251356, 30, nil, 85}, -- Plans: Guard's Boots
    {251357, 30, nil, 85}, -- Plans: Protector's Boots
    {251358, 30, nil, 85}, -- Plans: Acolyte's Boots
    {251359, 30, nil, 85}, -- Plans: Crusader's Boots
    {251360, 30, nil, 80}, -- Plans: Veteran's Gloves
    {251361, 30, nil, 80}, -- Plans: Guard's Gloves
    {251362, 30, nil, 80}, -- Plans: Protector's Gloves
    {251363, 30, nil, 80}, -- Plans: Acolyte's Gloves
    {251364, 30, nil, 80}, -- Plans: Crusader's Gloves
    {251365, 30, nil, 45}, -- Plans: Veteran's Chain Belt
    {251366, 30, nil, 45}, -- Plans: Guard's Chain Belt
    {251367, 30, nil, 45}, -- Plans: Protector's Chain Belt
    {251368, 30, nil, 45}, -- Plans: Acolyte's Chain Belt
    {251369, 30, nil, 45}, -- Plans: Crusader's Chain Belt
    {251370, 30, nil, 110}, -- Plans: Veteran's Silvered Chain Shirt
    {251371, 30, nil, 110}, -- Plans: Guard's Silvered Chain Shirt
    {251372, 30, nil, 110}, -- Plans: Protector's Silvered Chain Shirt
    {251373, 30, nil, 110}, -- Plans: Acolyte's Silvered Chain Shirt
    {251374, 30, nil, 110}, -- Plans: Crusader's Silvered Chain Shirt
    {251375, 30, nil, 125}, -- Plans: Veteran's Silvered Chain Leggings
    {251376, 30, nil, 125}, -- Plans: Guard's Silvered Chain Leggings
    {251377, 30, nil, 125}, -- Plans: Protector's Silvered Chain Leggings
    {251378, 30, nil, 125}, -- Plans: Acolyte's Silvered Chain Leggings
    {251379, 30, nil, 125}, -- Plans: Crusader's Silvered Chain Leggings
    {251380, 30, nil, 95}, -- Plans: Veteran's Silvered Chain Helm
    {251381, 30, nil, 95}, -- Plans: Guard's Silvered Chain Helm
    {251382, 30, nil, 95}, -- Plans: Protector's Silvered Chain Helm
    {251383, 30, nil, 95}, -- Plans: Acolyte's Silvered Chain Helm
    {251384, 30, nil, 95}, -- Plans: Crusader's Silvered Chain Helm
    {251413, 90, "H", 240}, -- Plans: Officer's Sabatons
    {251414, 90, "H", 240}, -- Plans: Sentinel's Sabatons
    {251415, 90, "H", 240}, -- Plans: Warder's Sabatons
    {251416, 90, "H", 240}, -- Plans: Prefect's Sabatons
    {251417, 90, "H", 240}, -- Plans: Justicar's Sabatons
    {251418, 60, "F", 175}, -- Plans: Officer's Gauntlet
    {251419, 60, "F", 175}, -- Plans: Sentinel's Gauntlet
    {251420, 60, "F", 175}, -- Plans: Warder's Gauntlet
    {251421, 60, "F", 175}, -- Plans: Prefect's Gauntlet
    {251422, 60, "F", 175}, -- Plans: Justicar's Gauntlet
    {251423, 90, "H", 250}, -- Plans: Officer's Waistguard
    {251424, 90, "H", 250}, -- Plans: Sentinel's Waistguard
    {251425, 90, "H", 250}, -- Plans: Warder's Waistguard
    {251426, 90, "H", 250}, -- Plans: Prefect's Waistguard
    {251427, 90, "H", 250}, -- Plans: Justicar's Waistguard
    {251428, 60, "F", 210}, -- Plans: Officer's Pauldrons
    {251429, 60, "F", 210}, -- Plans: Sentinel's Pauldrons
    {251430, 60, "F", 210}, -- Plans: Warder's Pauldrons
    {251431, 60, "F", 210}, -- Plans: Prefect's Pauldrons
    {251432, 60, "F", 210}, -- Plans: Justicar's Pauldrons
    {251433, 90, "H", 225}, -- Plans: Officer's Wristguard
    {251434, 90, "H", 225}, -- Plans: Sentinel's Wristguard
    {251435, 90, "H", 225}, -- Plans: Warder's Wristguard
    {251436, 90, "H", 225}, -- Plans: Prefect's Wristguard
    {251437, 90, "H", 225}, -- Plans: Justicar's Wristguards
    {251447, 120, "H", 300}, -- Plans: Enriched Thorium Breastplate
    {251448, 120, "H", 300}, -- Plans: Enriched Thorium Leggings
    {251449, 120, "H", 300}, -- Plans: Enriched Thorium Helm
    {251465, 90, "H", 250}, -- Plans: Thorium Greatmace
    {251466, 90, "H", 250}, -- Plans: Thorium Cestus
    {251471, 120, "H", 300}, -- Plans: Legionite Glaive
    {271622, 1000, nil, 300}, -- Blacksmithing Certification
  }},
  { prof="Enchanting", ally={"Alynsia", 11.2, 71.4}, horde={"Beneris", 49.6, 29.8}, items={
    {249476, 45, nil, 130}, -- Formula: Mystic Mushroom
    {249477, 45, nil, 130}, -- Formula: Tenets of the Silver Hand
    {249478, 45, nil, 130}, -- Formula: Polished Driftwood Icon
    {249479, 45, nil, 140}, -- Formula: Enchant Weapon - Insight
    {249480, 45, nil, 140}, -- Formula: Enchant Weapon - Recovery
    {249481, 45, nil, 140}, -- Formula: Enchant Weapon - Revelation
    {249482, 45, nil, 140}, -- Formula: Glimmering Staff
    {249483, 45, nil, 140}, -- Formula: Soulstaff
    {249484, 45, nil, 140}, -- Formula: Orb of Mystic Insight
    {249485, 45, nil, 140}, -- Formula: Orb of Souls
    {249493, 120, "F", 210}, -- Formula: Talons of Wrath
    {249494, 120, "F", 210}, -- Formula: Libram of Invocation
    {249495, 120, "F", 210}, -- Formula: Totem of Ancestral Protection
    {249496, 120, "F", 210}, -- Formula: Enchant Necklace - Strength
    {249502, 120, "F", 210}, -- Formula: Enchant Necklace - Spell Power
    {249503, 120, "F", 210}, -- Formula: Enchant Necklace - Healing Power
    {249504, 120, "F", 210}, -- Formula: Enchant Necklace - Agility
    {249505, 120, "F", 210}, -- Formula: Enchant Necklace - Deflection
    {249506, 120, "F", 220}, -- Formula: Radiant Staff
    {249507, 120, "F", 220}, -- Formula: Dreamstaff
    {249508, 120, "F", 220}, -- Formula: Truesilver Conduit
    {249509, 120, "F", 220}, -- Formula: Twisting Essence Jar
    {249510, 120, "F", 220}, -- Formula: Enchant Chest - Absorption
    {249525, 240, "H", 300}, -- Formula: Enchant 2H Weapon - Mighty Spell Power
    {249526, 240, "H", 300}, -- Formula: Enchant 2H Weapon - Mighty Healing Power
    {249529, 240, "H", 300}, -- Formula: Idol of the Dream
    {249530, 240, "H", 300}, -- Formula: Libram of Holy Alacrity
    {249532, 240, "H", 300}, -- Formula: Totem of Thunder
    {249534, 240, "H", 300}, -- Formula: Enchant Gloves - Arcane Power
    {249535, 240, "H", 300}, -- Formula: Enchant Gloves - Natural Power
    {249536, 240, "H", 300}, -- Formula: Enchant Gloves - Holy Power
    {249537, 180, "H", 275}, -- Formula: Brilliant Wand
    {249538, 240, "H", 300}, -- Formula: Enchant Bracer - Superior Intellect
    {249539, 240, "H", 300}, -- Formula: Enchant Bracer - Superior Deflection
    {271624, 1000, nil, 300}, -- Enchanting Certification
    {274393, 240, "H", 300}, -- Formula: Enchant Off-Hand - Wisdom
    {274394, 240, "H", 300}, -- Formula: Enchant 2H Weapon - Spellblasting
    {274398, 240, "H", 300}, -- Formula: Enchant Gloves - Superior Strength
    {274399, 240, "H", 300}, -- Formula: Enchant Cloak - Agility
    {274401, 240, "H", 300}, -- Formula: Enchant Bracer - Greater Spellpower
    {289560, 180, "H", 280}, -- Formula: Enchant Boots - Speed (180 Favor per foreverdb.net; Honored per Wowhead tooltip)
  }},
  { prof="Engineering", ally={"Fritz Fizzle", 10.4, 74.6}, horde={"Fizzlefuse", 49.8, 29.6}, items={
    {264201, 45, nil, 25}, -- Schematic: SAF-T Tabs
    {264202, 45, nil, 25}, -- Schematic: SAF-T Dynamite
    {264203, 45, nil, 55}, -- Schematic: SAF-T Copper Bomb
    {264204, 45, nil, 100}, -- Schematic: EZ-Thro Wrap
    {264205, 45, nil, 130}, -- Schematic: EZ-Thro Copper Bomb XL
    {264206, 45, nil, 145}, -- Schematic: No Slip SAF-T Padding
    {264209, 180, "F", 175}, -- Schematic: SAF-T Bell
    {264211, 180, "F", 190}, -- Schematic: EZ-Thro Fireproof Fuse
    {264216, 270, "H", 225}, -- Schematic: Emergency Field Cloak
    {264217, 270, "H", 225}, -- Schematic: Compact Critter Carrier
    {264220, 270, "H", 250}, -- Schematic: SAF-T Disposable Parachute
    {264221, 270, "H", 250, nil, "Favor cost unconfirmed"}, -- Schematic: Gnomish Army Knife (Honored, Engineering 250 per Wowhead; wow.gg counts 7 Honored schematics at 270)
    {264222, 270, "H", 275, nil, "Favor cost unconfirmed"}, -- Schematic: Loot-A-Rang (Honored, Engineering 275 per Wowhead)
    {264232, 360, "H", 300}, -- Schematic: Ultrasafe Rechargeable Battery
    {264234, 360, "H", 300}, -- Schematic: Gnomish Poultryizer
    {264235, 360, "H", 300}, -- Schematic: Ultralight Goblin Glider
    {264237, 360, "H", 300}, -- Schematic: Stealthman 52
    {271625, 1000, nil, 300}, -- Engineering Certification
    {280321, 180, "F", 175}, -- Schematic: Whimsical Waistwrap
    {280322, 180, "F", 175}, -- Schematic: Gizmo Girdle
    {280323, 180, "F", 175}, -- Schematic: Clanking Cord
    {280325, 180, "F", 200}, -- Schematic: Floppy Goggles
    {280326, 180, "F", 200}, -- Schematic: Bent Goggles
    {280327, 180, "F", 200}, -- Schematic: Stuckbutton Goggles
    {280328, 180, "F", 200}, -- Schematic: Dented Goggles
    {285285, 45, nil, 85}, -- Schematic: Satchel of Copper Bombs
    {285286, 180, "F", 165}, -- Schematic: Satchel of Bronze Bombs
    {285287, 270, "H", 230}, -- Schematic: Satchel of Iron Bombs
    {285288, 270, "H", 285}, -- Schematic: Satchel of Dark Iron Bombs
  }},
  { prof="Leatherworking", ally={"Daniel Stitchsong", 10.0, 72.6}, horde={"Pawani", 49.6, 29.6}, items={
    {252765, 30, nil, 60}, -- Pattern: Brawler's Leather Belt
    {252766, 30, nil, 60}, -- Pattern: Trapper's Leather Belt
    {252767, 30, nil, 60}, -- Pattern: Defender's Leather Belt
    {252768, 30, nil, 60}, -- Pattern: Totemic Leather Belt
    {252769, 30, nil, 60}, -- Pattern: Stormrider's Leather Belt
    {252770, 30, nil, 60}, -- Pattern: Wisdom's Leather Belt
    {252777, 30, nil, 75}, -- Pattern: Brawler's Leather Gloves
    {252778, 30, nil, 75}, -- Pattern: Trapper's Leather Gloves
    {252779, 30, nil, 75}, -- Pattern: Defender's Leather Gloves
    {252780, 30, nil, 75}, -- Pattern: Totemic Leather Gloves
    {252781, 30, nil, 75}, -- Pattern: Stormrider's Leather Gloves
    {252782, 30, nil, 75}, -- Pattern: Wisdom's Leather Gloves
    {252786, 30, nil, 85}, -- Pattern: Brawler's Leather Boots
    {252787, 30, nil, 85}, -- Pattern: Trapper's Leather Boots
    {252788, 30, nil, 85}, -- Pattern: Defender's Leather Boots
    {252789, 30, nil, 85}, -- Pattern: Totemic Leather Boots
    {252790, 30, nil, 85}, -- Pattern: Stormrider's Leather Boots
    {252791, 30, nil, 85}, -- Pattern: Wisdom's Leather Boots
    {252798, 30, nil, 100}, -- Pattern: Brawler's Leather Hood
    {252799, 30, nil, 100}, -- Pattern: Trapper's Leather Hood
    {252800, 30, nil, 100}, -- Pattern: Defender's Leather Hood
    {252801, 30, nil, 100}, -- Pattern: Totemic Leather Hood
    {252802, 30, nil, 100}, -- Pattern: Stormrider's Leather Hood
    {252803, 30, nil, 100}, -- Pattern: Wisdom's Leather Hood
    {252805, 30, nil, 110}, -- Pattern: Brawler's Leather Tunic
    {252806, 30, nil, 110}, -- Pattern: Trapper's Leather Tunic
    {252807, 30, nil, 110}, -- Pattern: Defender's Leather Tunic
    {252808, 30, nil, 110}, -- Pattern: Totemic Leather Tunic
    {252809, 30, nil, 110}, -- Pattern: Stormrider's Leather Tunic
    {252810, 30, nil, 110}, -- Pattern: Wisdom's Leather Tunic
    {252820, 30, nil, 125}, -- Pattern: Brawler's Leather Legguards
    {252821, 30, nil, 125}, -- Pattern: Trapper's Leather Legguards
    {252822, 30, nil, 125}, -- Pattern: Defender's Leather Kilt
    {252823, 30, nil, 125}, -- Pattern: Totemic Leather Leggings
    {252824, 30, nil, 125}, -- Pattern: Stormrider's Leather Kilt
    {252825, 30, nil, 125}, -- Pattern: Wisdom's Leather Leggings
    {252834, 60, "F", 185}, -- Pattern: Forceful Thick Armor Kit
    {252836, 60, "F", 175}, -- Pattern: Prowler's Leather Gloves
    {252837, 60, "F", 175}, -- Pattern: Skulker's Leather Gloves
    {252838, 60, "F", 175}, -- Pattern: Stalker's Leather Gloves
    {252839, 60, "F", 175}, -- Pattern: Warden's Leather Gloves
    {252840, 60, "F", 175}, -- Pattern: Skirmisher's Leather Gloves
    {252841, 60, "F", 175}, -- Pattern: Skycaller's Leather Gloves
    {252842, 60, "F", 175}, -- Pattern: Mender's Leather Gloves
    {252848, 60, "F", 210}, -- Pattern: Prowler's Leather Shoulders
    {252849, 60, "F", 210}, -- Pattern: Skulker's Leather Shoulder
    {252850, 60, "F", 210}, -- Pattern: Warden's Leather Shoulders
    {252851, 60, "F", 210}, -- Pattern: Skycaller's Leather Shoulders
    {252852, 60, "F", 210}, -- Pattern: Mender's Leather Shoulders
    {252853, 90, "H", 225}, -- Pattern: Prowler's Leather Bracers
    {252854, 90, "H", 225}, -- Pattern: Skulker's Leather Bracers
    {252855, 90, "H", 225}, -- Pattern: Warden's Leather Bracers
    {252856, 90, "H", 225}, -- Pattern: Skycaller's Leather Bracers
    {252857, 90, "H", 225}, -- Pattern: Mender's Leather Bracers
    {252860, 90, "H", 235}, -- Pattern: Prowler's Leather Boots
    {252861, 90, "H", 235}, -- Pattern: Skulker's Leather Boots
    {252862, 90, "H", 235}, -- Pattern: Warden's Leather Boots
    {252863, 90, "H", 235}, -- Pattern: Skycaller's Leather Boots
    {252864, 90, "H", 235}, -- Pattern: Mender's Leather Boots
    {252872, 90, "H", 250}, -- Pattern: Prowler's Leather Waistguard
    {252873, 90, "H", 250}, -- Pattern: Skulker's Leather Waistguard
    {252874, 90, "H", 250}, -- Pattern: Warden's Leather Waistguard
    {252875, 90, "H", 250}, -- Pattern: Skycaller's Leather Waistguard
    {252876, 90, "H", 250}, -- Pattern: Mender's Leather Waistguard
    {252900, 60, "F", 210}, -- Pattern: Stalker's Mail Shoulders
    {252901, 60, "F", 210}, -- Pattern: Skycaller's Mail Shoulders
    {252902, 60, "F", 210}, -- Pattern: Skirmisher's Mail Shoulders
    {252903, 60, "F", 210}, -- Pattern: Mender's Mail Shoulders
    {252904, 90, "H", 225}, -- Pattern: Stalker's Mail Bracers
    {252905, 90, "H", 225}, -- Pattern: Skycaller's Mail Bracers
    {252906, 90, "H", 225}, -- Pattern: Skirmisher's Mail Bracers
    {252907, 90, "H", 225}, -- Pattern: Mender's Mail Bracers
    {252910, 90, "H", 235}, -- Pattern: Stalker's Mail Sabatons
    {252911, 90, "H", 235}, -- Pattern: Skycaller's Mail Sabatons
    {252912, 90, "H", 235}, -- Pattern: Skirmisher's Mail Sabatons
    {252913, 90, "H", 235}, -- Pattern: Mender's Mail Sabatons
    {252922, 90, "H", 250}, -- Pattern: Stalker's Mail Belt
    {252923, 90, "H", 250}, -- Pattern: Skycaller's Mail Belt
    {252924, 90, "H", 250}, -- Pattern: Skirmisher's Mail Belt
    {252925, 90, "H", 250}, -- Pattern: Mender's Mail Belt
    {252941, 90, "H", 235}, -- Pattern: Mystic Rugged Armor Kit
    {271626, 1000, nil, 300}, -- Leatherworking Certification
  }},
  { prof="Tailoring", ally={"Mivin Shadowweave", 10.0, 72.8}, horde={"Jim'bek", 49.6, 29.6}, items={
    {253890, 30, nil, 60}, -- Pattern: Pristine Boots
    {253892, 30, nil, 60}, -- Pattern: Silky Boots
    {253894, 30, nil, 60}, -- Pattern: Flame Boots
    {253896, 30, nil, 60}, -- Pattern: Shadow Boots
    {253898, 30, nil, 60}, -- Pattern: Pearly Boots
    {253900, 30, nil, 60}, -- Pattern: Shining Boots
    {253914, 30, nil, 75}, -- Pattern: Pristine Gloves
    {253916, 30, nil, 75}, -- Pattern: Silky Gloves
    {253918, 30, nil, 75}, -- Pattern: Flame Gloves
    {253920, 30, nil, 75}, -- Pattern: Shadow Gloves
    {253922, 30, nil, 75}, -- Pattern: Pearly Gloves
    {253924, 30, nil, 75}, -- Pattern: Shining Gloves
    {253926, 30, nil, 85}, -- Pattern: Pristine Sash
    {253928, 30, nil, 85}, -- Pattern: Silky Sash
    {253930, 30, nil, 85}, -- Pattern: Flame Sash
    {253932, 30, nil, 85}, -- Pattern: Shadow Sash
    {253934, 30, nil, 85}, -- Pattern: Pearly Sash
    {253936, 30, nil, 85}, -- Pattern: Shining Sash
    {253950, 30, nil, 100}, -- Pattern: Pristine Circlet
    {253952, 30, nil, 100}, -- Pattern: Silky Circlet
    {253954, 30, nil, 100}, -- Pattern: Flame Circlet
    {253956, 30, nil, 100}, -- Pattern: Shadow Circlet
    {253958, 30, nil, 100}, -- Pattern: Pearly Circlet
    {253960, 30, nil, 100}, -- Pattern: Shining Circlet
    {253962, 30, nil, 110}, -- Pattern: Pristine Gown
    {253964, 30, nil, 110}, -- Pattern: Silky Gown
    {253966, 30, nil, 110}, -- Pattern: Flame Gown
    {253968, 30, nil, 110}, -- Pattern: Shadow Gown
    {253970, 30, nil, 110}, -- Pattern: Pearly Gown
    {253972, 30, nil, 110}, -- Pattern: Shining Gown
    {253988, 30, nil, 125}, -- Pattern: Pristine Leggings
    {253990, 30, nil, 125}, -- Pattern: Silky Leggings
    {253992, 30, nil, 125}, -- Pattern: Flame Leggings
    {253994, 30, nil, 125}, -- Pattern: Shadow Leggings
    {253996, 30, nil, 125}, -- Pattern: Pearly Leggings
    {253998, 30, nil, 125}, -- Pattern: Shining Leggings
    {254024, 60, "F", 165}, -- Pattern: Frothing Handwraps
    {254026, 60, "F", 165}, -- Pattern: Fiery Handwraps
    {254028, 60, "F", 165}, -- Pattern: Black Handwraps
    {254030, 60, "F", 165}, -- Pattern: Golden Handwraps
    {254032, 60, "F", 165}, -- Pattern: Radiant Handwraps
    {254036, 60, "F", 190}, -- Pattern: Mageweave Reagent Bag
    {254050, 60, "F", 195}, -- Pattern: Nethergeld Shoulders
    {254052, 60, "F", 195}, -- Pattern: Netherfroth Shoulders
    {254054, 60, "F", 195}, -- Pattern: Netherflame Shoulders
    {254056, 60, "F", 195}, -- Pattern: Netherpearl Shoulders
    {254058, 60, "F", 195}, -- Pattern: Nethershine Shoulders
    {254060, 60, "F", 195}, -- Pattern: Netherlight Shoulders
    {254062, 60, "F", 205}, -- Pattern: Nethergeld Cuffs
    {254064, 60, "F", 205}, -- Pattern: Netherfroth Cuffs
    {254066, 60, "F", 205}, -- Pattern: Netherflame Cuffs
    {254068, 60, "F", 205}, -- Pattern: Netherpearl Cuffs
    {254070, 60, "F", 205}, -- Pattern: Nethershine Cuffs
    {254072, 60, "F", 205}, -- Pattern: Netherlight Cuffs
    {254080, 60, "F", 215}, -- Pattern: Runecloth Reagent Bag
    {254082, 60, "F", 215}, -- Pattern: Gilded Waistcord
    {254084, 60, "F", 215}, -- Pattern: Frothing Waistcord
    {254086, 60, "F", 215}, -- Pattern: Fiery Waistcord
    {254088, 60, "F", 215}, -- Pattern: Black Waistcord
    {254090, 60, "F", 215}, -- Pattern: Golden Waistcord
    {254092, 60, "F", 215}, -- Pattern: Radiant Waistcord
    {254108, 90, "H", 235}, -- Pattern: Gilded Sandals
    {254110, 90, "H", 235}, -- Pattern: Frothing Sandals
    {254112, 90, "H", 235}, -- Pattern: Fiery Sandals
    {254114, 90, "H", 235}, -- Pattern: Black Sandals
    {254116, 90, "H", 235}, -- Pattern: Golden Sandals
    {254118, 90, "H", 235}, -- Pattern: Radiant Sandals
    {271627, 1000, nil, 300}, -- Tailoring Certification
  }},
  { prof="Cooking", ally={"Kalsey Sanden", 10.8, 72.6}, horde={"Aza'bek", 49.6, 29.4}, items={
    {249885, 30, nil, 25}, -- Recipe: Venomous Smoothie
    {249886, 30, nil, 100}, -- Recipe: Slimy Smoothie
    {249887, 30, nil, 125}, -- Recipe: Mrrggl Smrrthle
    {249888, 60, "F", 180}, -- Recipe: Calcified Smoothie
    {249889, 60, "F", 200}, -- Recipe: Spicy Smoothie
    {249890, 90, "H", 250}, -- Recipe: Wicked Smoothie
  }},
  { prof="Supply Officer", ally={"Tamelyn Aldridge", 10.6, 71.6}, horde={"Gishah", 49.4, 29.4}, items={
    {262765, 200, "E", nil, "A"}, -- Azeroth Commerce Authority Tabard
    {262764, 200, "E", nil, "H"}, -- Durotar Supply and Logistics Tabard
    {270888, 1200, "H", nil, "A"}, -- Advertising License Application
    {284664, 1500, "R", nil}, -- Packmule Treat
    {270887, 1200, "H", nil, "H"}, -- Advertising License Application (Horde)
  }},
  { prof="Mount", ally={"Huey Sunnydale", 8.6, 71.8}, horde={"Okamache", 49.6, 28.8}, items={
    {262766, 6000, "E", nil}, -- Reins of the Pack Kodo (rep gate reported as Exalted; some say Honored)
  }},
  { prof="Uncertified Scribe", ally={"Dianne Softstep", 8.2, 73.4}, horde={"Kurvelk Shadowhoof", 49.8, 30.2}, items={
    {262902, 15, "F", nil}, -- Forged Delivery Receipt (turns an empty crate into a Notarized Shipping Container: 50 rep)
    {262896, 15, "H", nil}, -- Forger's Quill (rerolls a writ to another of the same tier)
  }},
}

-- Merchant's Favor info shown on the Favor tab
WM.FAVOR_INFO = {
  "Merchant's Favor is a currency. Waylaid crates give Favor (and a little silver), not reputation.",
  "Reputation comes from Craftsman's Writs: Journeyman 75, Expert 125, Artisan 200. Each writ once per day.",
  "First crate turn-in gives a Shipping Label: 2,000 rep + 50 Favor, once per character.",
  "After Friendly: Forged Delivery Receipt (15 Favor) turns an empty crate into a Notarized Shipping Container worth 50 rep.",
  "Crates drop from mobs and chests and sell on the AH. Fill a crate with any ONE of its listed options.",
  "Writs drop as Sealed Journeyman's/Expert's/Artisan's Writs (tradeable). Opening gives a random order of that tier.",
  "Forger's Quill (Honored, 15 Favor) rerolls an order into another of the same tier.",
}
