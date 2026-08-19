package main

import "core:log"
import sdl "vendor:sdl3"

main :: proc() {
        context.logger = log.create_console_logger()
        defer log.destroy_console_logger(context.logger)

        sdl_check(sdl.Init({.VIDEO}))
        defer sdl.Quit()

        window := sdl_check(sdl.CreateWindow("minecraft", 1280, 780, {}))
        fake_file := sdl_check(sdl.LoadBMP("ginger cute pics"))
}
