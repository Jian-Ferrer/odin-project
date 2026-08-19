package main

import "base:runtime"
import sdl "vendor:sdl3"
import "core:log"

sdl_check :: proc{sdl_check_bool, sdl_check_ptr}

sdl_check_bool :: proc (ok: bool, loc := #caller_location) -> bool {
        if !ok do log_fatal(loc)
        return ok
}

sdl_check_ptr :: proc(ptr: ^$T, loc := #caller_location) -> ^T {
        if ptr == nil do log_fatal(loc)
        return ptr
}

@private
log_fatal :: proc(loc: runtime.Source_Code_Location) {
        err := sdl.GetError()
        log.fatalf("%v", err, location = loc)
}