# PR Hub

Roblox script loader — **rebranded from Miranda Hub**.

All files mirrored from `miirandahub/loader` with brand strings changed:
- `MIRANDA` → `PR HUB`
- `Miranda` → `PR Hub`
- `MirandaUpdatedUI` (ScreenGui) → `PRHubUI`
- `miirandahub/loader` → `lomigg/pr-hub`
- Discord link swapped to `https://discord.gg/bluezygpt`

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lomigg/pr-hub/main/main.lua"))()
```

## Files (mirror of miirandahub/loader)

| File | Size | Type | Description |
|---|---|---|---|
| `main.lua` | 541B | readable | PR Hub loader (auto-routes by PlaceId/GameId) |
| `afkk` | 415B | readable | Anti-AFK entry — loads antiafk + luarmor |
| `antiafk` | 222KB | Luraph v15.0 | Anti-AFK script (obfuscated) |
| `gag2.lua` | 584KB | Luraph v14.7 | Grow A Garden 2 script |
| `prhubafk.lua` | 5.2KB | readable | PR Hub Anti-AFK popup GUI |
| `stealaegg` | 236KB | Luraph v15.0 | Steal An Egg script |
| `stealaeggs` | 5.2KB | readable | PR Hub popup GUI for SAE |
| `stealeggies` | 108B | readable | Loads luarmor SAE loader |
| `test.lua` | 441KB | Luraph v15.0 | Universal/test script |

## Routes

| Game | PlaceId / GameId | Loads |
|---|---|---|
| Steal An Egg | PlaceId 107778070777162 | `stealaegg` (Luraph) |
| Grow A Garden 2 | GameId 10200395747 | `gag2.lua` (Luraph) |
| Other (default) | any | `test.lua` (Luraph) |

## Rebrand caveats

- Big files (antiafk, gag2.lua, stealaegg, test.lua) are **Luraph-obfuscated** — string
  literals inside are encrypted and not editable. Brand strings inside their GUIs will
  still show "Miranda" at runtime.
- Only readable files (afkk, stealaeggs, prhubafk.lua, stealeggies) were rebranded.
- The luarmor URLs in `afkk` and `stealeggies` still point to Miranda's luarmor scripts
  (can't be rebranded without losing functionality).

