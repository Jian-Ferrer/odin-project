package main

import "base:runtime"
import sdl "vendor:sdl3"
import "core:log"

sdl_check :: proc{sdl_check_bool, sdl_check_ptr}

// Check a boolean return from SDL
sdl_check_bool :: proc (ok: bool, loc := #caller_location) -> bool {
        if !ok do sdl_fatal(loc)
        return ok
}

// Check a pointer return from SDL
sdl_check_ptr :: proc(ptr: ^$T, loc := #caller_location) -> ^T {
        if ptr == nil do sdl_fatal(loc)
        return ptr
}

// Log the SDL error and caller location, then exit.
@private
sdl_fatal :: proc(loc: runtime.Source_Code_Location) {
        err := sdl.GetError()
        log.fatalf("%v", err, location = loc)
}