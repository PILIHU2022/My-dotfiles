/*
 * sdl-ime-debug.c - preload helper that makes SDL2 log which input-method
 * backend it selected (fcitx D-Bus / ibus / XIM) and what it receives.
 *
 * Build: cc -shared -fPIC -O2 -o sdl-ime-debug.so sdl-ime-debug.c -ldl
 * Use:   LD_PRELOAD=/path/sdl-ime-debug.so SDL_IME_DEBUG=1 <app>
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>

typedef int (*SDL_Init_fn)(unsigned int);
typedef void (*SDL_LogSetAllPriority_fn)(int);

void SDL_Init(unsigned int flags)
{
    static SDL_Init_fn real;
    if (!real)
        real = (SDL_Init_fn)dlsym(RTLD_NEXT, "SDL_Init");

    if (real)
        real(flags);

    if (getenv("SDL_IME_DEBUG")) {
        SDL_LogSetAllPriority_fn setp =
            (SDL_LogSetAllPriority_fn)dlsym(RTLD_NEXT, "SDL_LogSetAllPriority");
        if (setp)
            setp(2 /* SDL_LOG_PRIORITY_VERBOSE */);
    }
}
