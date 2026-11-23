# Watch Dogs 6 — lightweight CachyOS visual pack

A vkBasalt post-process for Watch Dogs 2 under CachyOS/Proton. It combines a restrained pink/gold sunrise/sunset tint with a softer, more natural grade and gentle highlight rolloff. The game profile uses the game’s native fog toggle and reflection settings. Fog Volumes is off to keep daytime city views clear; Watch Dogs 2 only exposes this fog as an on/off option, not a density slider. It uses one shader pass and one game-frame sample per pixel; it adds no textures, glow taps, or extra render targets, keeping memory and GPU cost low.

## Installed paths

The per-user vkBasalt config and shader locations are:

- `~/.config/vkBasalt/vkBasalt.conf`
- `~/.config/vkBasalt/reshade-shaders/Shaders/WatchDogs6.fx`
- `~/.config/vkBasalt/reshade-shaders/Shaders/ReShade.fxh`

Enable the layer for Watch Dogs 2 by setting this in Steam → Watch Dogs 2 → Properties → General → Launch Options:

```text
ENABLE_VKBASALT=1 %command%
```

## Visual limits

The shader makes the scene feel more cinematic through restrained color separation, softer contrast, gentle highlight rolloff, and a pink-to-gold sunrise/sunset gradient. Fog Volumes is disabled in the active profile (`FogVolumesEnabled="0"`) because its only game setting is on/off. The profile raises approximated reflections one step and screen space reflections one step. Those effects use the game renderer and can increase GPU load, especially on wet roads. It cannot create true reflections, new shadow geometry, or upgraded volumetric lighting: those require scene/depth information and changes to the game's renderer. It loads no texture or LUT assets and adds no extra render targets or neighboring frame samples.

The sunset color is gated by warm source colors in the upper part of the frame, so ordinary blue daytime skies remain untinted. A warm-colored object near the top of the image can still pick up a little tint because this lightweight post-process does not use scene depth. To tune the look, edit `SkyTintStrength` or `CinematicStrength` near the top of `WatchDogs6.fx`, then restart the game.

The shader adds no textures, lookup tables, or render targets, so its additional VRAM allocation is effectively zero. Raising in-game reflections can add GPU work; lower Screen Space Reflections in VIDEO if performance drops. This pack cannot reduce Watch Dogs 2’s own RAM or VRAM use. This visual pack does not add impact-triggered camera shake: that needs a ScriptHook runtime, which is not present in this game install. vkBasalt's Home-key toggle works on X11; its docs note that this hotkey does not work on pure Wayland. It cannot add a toggle to the game's native VIDEO menu.
