# Inri's WritMaster

## v1.0.4 (2026-11-13)

- All 259 Merchant's Favor prices checked against the live camp vendors: every listed price is correct. Gnomish Army Knife, Loot-A-Rang and Disorienting Smog Potion are in the game files but not sold by the camp vendors yet, and are marked that way.
- Vendor Favor prices are read again a moment after opening the vendor, in case item data loads late. New `/writ vendor` command shows what the vendor scan sees.
- Crates tab: filling options are now priced at full AH value by default, so the truly cheapest material wins. Turn on the new "Use my bags" toggle to count materials you already have as free.
- Crates tab: the cheapest fill now says how many of the items you already have, since those are subtracted from the fill cost.

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
