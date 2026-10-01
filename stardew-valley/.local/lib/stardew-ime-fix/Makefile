# Build the SDL2/fcitx5 input-method shims used by stardew-valley-launch.
#
#   make          build both shims next to the sources
#   make clean    remove the build artefacts

CC      ?= cc
CFLAGS  ?= -shared -fPIC -O2 -Wall -Wextra
LDLIBS  ?= -ldl

TARGETS := sdl-ime-internal.so sdl-ime-debug.so

.PHONY: all clean
all: $(TARGETS)

sdl-ime-internal.so: sdl-ime-internal.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

sdl-ime-debug.so: sdl-ime-debug.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f $(TARGETS)
