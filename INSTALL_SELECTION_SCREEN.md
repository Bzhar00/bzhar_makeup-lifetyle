# Show the makeup on the character selection screen

The selection screen is drawn by `vorp_character`, not by this script, so it needs two small additions
Both go inside `StartSwapCharacters`, in the `for key, value in pairs(myChars) do` loop

Open `vorp_character/client/client.lua`

## Call 1, before the ped is copied

Find these lines:

```lua
		FaceOverlay("grime", value.skin.grime_visibility, value.skin.grime_tx_id, 0, 0, 0, 1.0, 0, 1, 0, 0, 0, 1, value.skin.grime_opacity)
		Wait(500)

		data.PedHandler = ClonePed(playerPed, false, false, false, false)
```

Put the loop between them so it looks like this:

```lua
		FaceOverlay("grime", value.skin.grime_visibility, value.skin.grime_tx_id, 0, 0, 0, 1.0, 0, 1, 0, 0, 0, 1, value.skin.grime_opacity)
		Wait(500)

		for _ = 1, 40 do -- bzhar_makeup
			if GetResourceState("bzhar_makeup") == "started"
				and pcall(function() exports.bzhar_makeup:applyToPed(playerPed, value.charIdentifier) end) then
				break
			end
			Wait(50)
		end

		data.PedHandler = ClonePed(playerPed, false, false, false, false)
```

## Call 2, on the copy

A few lines below, find the end of the block that makes `data.PedHandler`:

```lua
		if not data.PedHandler or not DoesEntityExist(data.PedHandler) then
			data.PedHandler = CreatePed(modelHash, data.spawn.x, data.spawn.y, data.spawn.z, data.spawn.w, false, false, false, false)
			LoadCharacterSelect(data.PedHandler, value.skin, value.components)
		else
			SetEntityCoords(data.PedHandler, data.spawn.x, data.spawn.y, data.spawn.z, false, false, false, false)
			SetEntityHeading(data.PedHandler, data.spawn.w)
		end
```

Add one line under that `end`:

```lua
		end

		pcall(function() exports.bzhar_makeup:applyToPed(data.PedHandler, value.charIdentifier) end) -- bzhar_makeup
```

Save the file and restart `vorp_character`


## If it still does not show

Set `Config.Debug = true` and read the F8 console while the selection screen loads
The script prints one line per step, the last one tells you where it stopped


## If you skip this

The script still works and the makeup shows in game as normal, only the selection screen will not show it
