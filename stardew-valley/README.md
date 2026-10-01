# stardew-valley — SDL2 / fcitx5 preedit fix

Fixes the Stardew Valley (Linux native, SDL2 2.30.4) input-method bug where the
sign editor shows the fcitx5 candidate window but no pinyin composition string.

## Root cause

The `libSDL2-2.0.so.0` shipped with the game is an **X11-only** build
(`SDL2-2.30.4`, no Wayland video driver, no IBus backend, fcitx D-Bus backend
compiled in). At startup SDL registers a hint callback with fcitx5:

```c
SDL_AddHintCallback("SDL_IME_INTERNAL_EDITING", Fcitx_SetCapabilities, ...);
```

and `Fcitx_SetCapabilities` calls

```
SetCapability(org.freedesktop.portal.Fcitx,
              org.fcitx.Fcitx.InputContext1,
              capabilities = 0x12)   /* PREEDIT | FORMATTED_PREEDIT */
```

Verified by disassembling the shipped library:

| symbol | address | evidence |
| --- | --- | --- |
| `Fcitx_SetCapabilities` | `.text+0x189170` | loads size `0x74`, loads method string `"SetCapability"`, interface `"org.fcitx.Fcitx.InputContext1"`, portal `"org.freedesktop.portal.Fcitx"` |
| hint callback registration | `.text+0x18945d` | `lea rdi, "SDL_IME_INTERNAL_EDITING"` → `call SDL_AddHintCallback` |
| capability value | `.text+0x189190` | `movq $0x12, (%rsp+8)` unless the hint value is `"1"` |

Because SDL advertises the preedit capability, fcitx5 stops drawing the
composition string itself and hands it to the application to render.
MonoGame / Stardew Valley never render it, so only the candidate window
remains visible. Pressing a candidate number still commits correctly — that is
why only the preedit is missing.

Setting the hint to `1` makes SDL send `SetCapability(capabilities = 0)`, so
fcitx5 takes the preedit back and paints it in its own window again.

## Contents

```
stardew-valley/
├── .local/bin/stardew-valley-launch          # wrapper used as the Steam launch option
└── .local/lib/stardew-ime-fix/
    ├── Makefile                              # builds the two shims
    ├── sdl-ime-internal.c                    # the actual fix
    └── sdl-ime-debug.c                       # optional SDL input-method logging
```

`.so` artefacts are not tracked; build them once after stowing:

```sh
cd ~/.local/lib/stardew-ime-fix
make
```

## Usage

Set the Steam launch option for Stardew Valley to:

```
/home/Spark/.local/bin/stardew-valley-launch %command%
```

The wrapper sets `SDL_IME_INTERNAL_EDITING=1`, preloads the shim and starts
`StardewModdingAPI` (or `Stardew Valley` when SMAPI is absent).

### Minimal alternative

The environment variable alone is usually enough:

```
SDL_IME_INTERNAL_EDITING=1 %command%
```

The shim additionally re-asserts the hint at every `SDL_StartTextInput()`, so
the setting survives anything that resets it.

## Verifying which input-method backend SDL picked

```sh
STARDEW_IME_DEBUG=1 stardew-valley-launch
```

With `SDL_IME_DEBUG=1` the debug shim raises SDL's log level to verbose, so
SDL prints whether it selected the fcitx D-Bus backend, IBus, or XIM. If SDL
reports XIM instead of fcitx, this fix cannot help (XIM never routes the
preedit through the D-Bus capability) and `SDL_IM_MODULE=fcitx` should be
added to the launch options.

## Environment overrides

| variable | effect |
| --- | --- |
| `SDL_IME_INTERNAL_EDITING` | if already set, the shim leaves it alone |
| `STARDEW_DIR` | game directory when it cannot be derived from `%command%` |
| `STARDEW_IME_FIX_DIR` | directory containing the compiled shims |
| `STARDEW_IME_DEBUG` | load the diagnostics shim and enable SDL verbose logs |

## Notes

* The game is the **native Linux** build (`SMAPI 4.5.2`, Stardew Valley
  `1.6.15`); it runs through XWayland because its SDL2 has no Wayland driver.
* `SDL_VIDEODRIVER=wayland` is present in the session environment. It is
  harmless here (SDL logs `wayland not available` and falls back to X11), but
  it is misleading — the game is never a Wayland client.
* `SDL_IM_MODULE=fcitx` forces the D-Bus backend explicitly if SDL ever
  prefers XIM.
