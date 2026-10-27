# bzhar_makeup

Makeup and lifestyle shop for RedM on VORP: 167 styles in 14 sections and the full 64 colour makeup palette, sold at the barber chair in 7 towns

## Features

- 2 menus: Makeup (lipstick, blush, eyeshadow, eyeliner, foundation) and Lifestyle (complexion, ageing, freckles, moles, acne, discoloration, spots, scars, grime)
- 167 styles plus a None option in every section
- 64 colours on lipstick, blush, eyeshadow, eyeliner, foundation and grime
- Strength bar on every style, 0 to 100% in steps of 5
- Live preview while browsing, nothing is charged until Save Look
- Own price for each of the 14 sections, setting a section back to None can be free
- Pay with cash or gold
- Sits the player in the barber chair with a face camera, rotate with Q and R
- Tick on the chosen style and on every section in use, running total on Save Look
- Saved per character, stays after rc, relog and server restart
- Optional 2 line patch to show the makeup on the vorp_character selection screen
- Database table is made on first start, no SQL to import
- Makeup and Lifestyle menus can each be turned off
- 7 shops with blips: Valentine, Blackwater, Saint Denis, Annesburg, Armadillo, Tumbleweed, Strawberry

## Requirements

- vorp_core
- jo_libs
- oxmysql

## Installation

1. Put `bzhar_makeup` in your resources folder
2. Add `ensure bzhar_makeup` to your `server.cfg` after `jo_libs`, `vorp_core` and `oxmysql`
3. Restart the server, the `bzhar_makeup` table is made on first start
4. Optional: follow `INSTALL_SELECTION_SCREEN.md` to show the makeup on the character selection screen


## Exports

Client side

| Export | Returns | What it does |
|---|---|---|
| `exports.bzhar_makeup:applyToPed(ped, charIdentifier)` | boolean | Paints a character's saved makeup on a ped, used by the selection screen patch |
| `exports.bzhar_makeup:refresh()` | nothing | Puts the player's saved makeup back on |
| `exports.bzhar_makeup:getLook()` | table | The player's saved look, one entry per section |

