# Inri's WritMaster

## v1.0.8 (2026-11-18)

- Opening a profession window no longer prints "Priced N writ recipes you know" every time. It only appears when WritMaster finds a recipe it didn't know about yet.
- Writ customers in Riverglades can now be learned from quest map markers too.
- Window size setting: 90%, 100%, 110% or 125% on the Info tab, or any size from 80 to 150 with `/writ scale`.
- Less chat spam: the "loaded" message only shows the first time, and the automatic shopping list refresh at the Auction House is silent. The login summary of writs ready to deliver can be turned off on the Info tab.
- Cleaned up leftover settings from older versions.

## v1.0.7 (2026-11-17)

- Profession filter on the Writs tab: All, Mine, Alch, Smith, Eng, LW, Tail. "Mine" is the default and shows only writs for the crafting professions your character knows (or all writs if you have none of the five).
- Search box on the Writs, Crates and Vendors tabs. On Writs it matches item, customer, zone and profession. Esc clears it.
- The Rep/gold column is coloured from red (worst value) to green (best value), compared against every writ you can do.
- The price age warning no longer says "1d old" right after midnight for a scan you did late the evening before. Auctionator only records the day an item was seen, so it now says "prices from yesterday" and only turns orange at 2 days or more.
- The sorted column is highlighted with an arrow showing the direction. A newly clicked column starts in its natural order: best rep per gold first, otherwise A-Z or cheapest first.
- Cleaner look: clearer alternating rows, a tinted header row, framed title bar and footer. The Writ and Item price columns are slightly faded so Total and Rep/gold stand out, and Qty is blank unless it is more than 1.
- Footer buttons are grouped (Drop all, Do today, Shop list | Waypoint, Search AH, Route), and Shop list is highlighted as the main action.
- The Rep/gold numbers no longer touch the zone names, and the footer text is shorter so it no longer wraps.

## v1.0.6 (2026-11-17)

- 38 more Expert writ customers with name, zone and coordinates, so 45 of the 60 Expert writs now show where to deliver. Includes the new Riverglades zone. This matters because the game doesn't show writ customers on the map.
- Four Expert customers that were marked "unconfirmed" or "see quest marker" are now confirmed.
- New zones in the delivery route: Swamp of Sorrows, The Hinterlands, Searing Gorge, Desolace, Tanaris, Un'Goro Crater and Riverglades.

## v1.0.5 (2026-11-14)

- "Drop all" button at the bottom of the Writs and Crates tabs clears today's list in one click.
- Costs of 1g or more now show the silver too (1g 04s instead of 1g).
- Writs and crates are now always priced at full AH value, even if the writ, item or crate is already in your bags. The "Free writs" filter is gone.
- Vendors tab: items you can afford but don't have the reputation for yet now say "needs Honored" (or Revered/Exalted) instead of "affordable".
- `/writ clear` now updates the open window on the Crates tab too.
- `/writ vendor` is listed in `/writ help` and on the Info tab.

## v1.0.4 (2026-11-13)

- All 259 Merchant's Favor prices checked against the live camp vendors: every listed price is correct. Gnomish Army Knife, Loot-A-Rang and Disorienting Smog Potion are in the game files but not sold by the camp vendors yet, and are marked that way.
- Vendor Favor prices are read again a moment after opening the vendor, in case item data loads late. New `/writ vendor` command shows what the vendor scan sees.
- Crates tab: filling options are always priced at full AH value, even if you already have the materials, so the truly cheapest material wins.
- Crates tab: the cheapest fill shows how many of the items you already have.

## v1.0.3 (2026-11-12)

- Prices refresh the moment Auctionator records new data, instead of when the window is reopened.
- The title bar warns when your AH prices are a day or more old.
- Formula: Enchant Boots - Speed now shows its Honored requirement.
- Gnomish Army Knife and Loot-A-Rang schematics (Honored) and Disorienting Smog Potion (Friendly) are now listed with their skill and reputation requirements. Their Favor cost is confirmed automatically the first time you open the vendor.

## v1.0.2 (2026-11-12)

- Crates tab can plan your day too: Shift-click or Ctrl-click crates and press Do today. Planned crates (and the cheapest way to fill them) go into the WritMaster shopping list with your writs.
- About section on the Info tab with version and credits. Development is done by a hardworking AI (& 1 lazy human).

## v1.0.1 (2026-11-12)

- New "AH auto: on/off" button in the title bar to choose whether WritMaster opens by itself at the Auction House.

## v1.0.0 (2026-11-12)

First public release for WoW: Forever 1.60.1.

- Writs tab: all 150 Craftsman's Writs sorted by rep per gold, priced with Auctionator (named writ or sealed writ, plus item or crafting materials).
- Customer locations for every known Journeyman writ, waypoints (TomTom or the built-in map pin) and a delivery route for the writs in your bags. Customers for Expert and Artisan writs are learned automatically from quest markers and turn-ins.
- Plan your day: Shift-click or Ctrl-click writs and press "Do today". Planned writs are tinted gold and the plan clears at daily reset.
- Auctionator shopping list "WritMaster" for today's writs, refreshed whenever you open the Auction House.
- Item tooltips in bags and on the AH with rep, cost and a BUY / SKIP verdict for writs.
- Crates tab: Waylaid Supplies crates and the Merchant's Favor they pay.
- Vendors tab: 326 Merchant's Favor items with cost, rep requirement and how much Favor you still need.
- Minimap button, addon compartment entry, auto-open at the Auction House and camp NPCs, daily reset timer.
