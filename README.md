<img src="media/logo.png" width="128" align="right" alt="">

# Inri's WritMaster

Get Azeroth Commerce Authority (Alliance) and Durotar Supply and Logistics (Horde) reputation for the least gold in **WoW: Forever**.

WritMaster prices every Craftsman's Writ with Auctionator, sorts them by rep per gold, tells you where each customer stands, and builds your Auction House shopping list for the day.

Type `/writ` to open it, or click the minimap button.

## Features

**Writs**
- All 150 Craftsman's Writs (Journeyman 75 rep, Expert 125, Artisan 200), sorted by rep per gold.
- Cost = the writ (named writ, or a sealed writ as an estimate) + the requested item, bought on the AH or crafted from materials, whichever is cheaper. Open your profession window once so it can price crafting.
- Writs you already turned in today are dimmed, and the daily reset timer is in the header.

**Customers and routes**
- Customer name and coordinates for every known writ, with a waypoint on right-click (TomTom if installed, otherwise the built-in map pin).
- `/writ route` lists a delivery route for the writs in your bags, grouped by zone.
- Expert and Artisan customers are not published yet. WritMaster learns them from quest map markers and turn-ins and remembers them on your account.

**Plan your day**
- Shift-click a writ, or Ctrl-click several and press **Do today**. Planned writs are tinted gold.
- **Shop list** creates an Auctionator shopping list called "WritMaster" with everything still missing for today's writs. It refreshes automatically when you open the Auction House.

**Tooltips**
- Writs in your bags and on the AH show rep, total cost, rep per gold, the customer and a **BUY / SKIP** verdict.
- Hold Shift over a row in the WritMaster window to see its full breakdown.

**Merchant's Favor**
- Crates tab: Waylaid Supplies crates, what they take and the Favor they pay.
- Vendors tab: all Merchant's Favor items with their cost, the reputation they need and how much more Favor you need.

**Quality of life**
- Opens itself at the Auction House and at camp vendors (you can turn this off on the Info tab).
- Minimap button and addon compartment entry.

## Commands

| Command | What it does |
| --- | --- |
| `/writ` | Open or close the window |
| `/writ route` | Delivery route for writs in your bags |
| `/writ list` | Build the Auctionator shopping list |
| `/writ clear` | Clear today's plan |
| `/writ mm` | Show or hide the minimap button |

`/writmaster` and `/iwm` work too.

## Requirements

- WoW: Forever (Interface 16001)
- [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for prices and shopping lists (strongly recommended)
- TomTom (optional) for arrow waypoints

## Data and accuracy

Writ quests, items and Journeyman customer locations come from game data and community sources. Expert and Artisan customers, Artisan crate payouts and a few vendor prices are not confirmed yet. The addon learns customers as you play, and the static data will be updated as more becomes known. Corrections are welcome in [Issues](../../issues).

## Credits

Development is done by a hardworking AI (& 1 lazy human).

## License

MIT, see [LICENSE](LICENSE).
