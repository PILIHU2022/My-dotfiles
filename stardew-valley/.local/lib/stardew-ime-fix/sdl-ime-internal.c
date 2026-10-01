/*
 * sdl-ime-internal.c - let fcitx5 paint its own preedit inside SDL2 apps.
 *
 * Why
 * ---
 * SDL2 2.30.x tells fcitx5 over D-Bus that the application can render the
 * composition (preedit) string itself:
 *
 *   SDL_Fcitx_Init() registers
 *       SDL_AddHintCallback("SDL_IME_INTERNAL_EDITING", Fcitx_SetCapabilities)
 *   Fcitx_SetCapabilities() then calls
 *       SetCapability(org.freedesktop.portal.Fcitx,
 *                     org.fcitx.Fcitx.InputContext1,
 *                     capabilities = 0x12)   // PREEDIT | FORMATTED_PREEDIT
 *
 * (verified by disassembling the libSDL2-2.0.so.0 shipped with Stardew
 *  Valley: Fcitx_SetCapabilities sits at .text+0x189170, loads size 0x74
 *  and method "SetCapability".)
 *
 * fcitx5 honours that flag: instead of drawing the pinyin string next to
 * the candidates it hands the composition to the client and expects the
 * client to paint it. MonoGame / Stardew Valley never paint it, so the
 * player sees the candidate window but no pinyin.
 *
 * What
 * ----
 * When the hint is "1", SDL sends SetCapability(capabilities = 0), fcitx5
 * takes the preedit back and draws it in its own window again. Committed
 * text (SDL_TEXTINPUT) is not affected.
 *
 * The hint is set from the interposed SDL_StartTextInput, which is always
 * called after the fcitx D-Bus client has been created - setting the hint
 * any earlier would make SDL's own callback dereference a NULL client.
 *
 * Build: cc -shared -fPIC -O2 -o sdl-ime-internal.so sdl-ime-internal.c -ldl
 * Use:   LD_PRELOAD=/path/sdl-ime-internal.so <game>
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define HINT_NAME "SDL_IME_INTERNAL_EDITING"

typedef int  (*SDL_SetHint_fn)(const char *, const char *);
typedef void (*SDL_StartTextInput_fn)(void);

static void dbg(const char *msg)
{
    if (getenv("SDL_IME_INTERNAL_DEBUG")) {
        (void)!write(2, "[sdl-ime-internal] ", 19);
        (void)!write(2, msg, strlen(msg));
        (void)!write(2, "\n", 1);
    }
}

/* Resolve a symbol from the already-mapped libSDL2. */
static void *sdl_sym(const char *name)
{
    void *h = dlopen("libSDL2-2.0.so.0", RTLD_NOW | RTLD_NOLOAD);
    if (!h)
        return NULL;
    return dlsym(h, name);
}

static void force_internal_editing(const char *where)
{
    /* An explicit environment setting always wins. */
    if (getenv(HINT_NAME) != NULL) {
        dbg("skipped: SDL_IME_INTERNAL_EDITING is set in the environment");
        return;
    }
    SDL_SetHint_fn set_hint = (SDL_SetHint_fn)sdl_sym("SDL_SetHint");
    if (!set_hint) {
        dbg("skipped: SDL_SetHint not reachable (SDL2 not loaded yet)");
        return;
    }
    if (set_hint(HINT_NAME, "1")) {
        dbg(where);
    } else {
        dbg("SDL_SetHint reported failure");
    }
}

void SDL_StartTextInput(void)
{
    static SDL_StartTextInput_fn real;

    if (!real)
        real = (SDL_StartTextInput_fn)dlsym(RTLD_NEXT, "SDL_StartTextInput");

    if (real)
        real();

    /* Re-fires SDL's own hint callback -> SetCapability(capabilities = 0). */
    force_internal_editing("SDL_StartTextInput: hint forced to 1 (SetCapability(0))");
}
