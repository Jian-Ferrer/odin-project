package main

import "core:log"
import sdl "vendor:sdl3"

frag_shader_code := #load("../shader.frag.spv")
vert_shader_code := #load("../shader.vert.spv")

main :: proc() {
        context.logger = log.create_console_logger()
        defer log.destroy_console_logger(context.logger)

        sdl_check(sdl.Init({.VIDEO}))
        defer sdl.Quit()

        window := sdl_check(sdl.CreateWindow("minecraft", 1280, 780, {}))
        defer sdl.DestroyWindow(window)

        gpu := sdl_check(sdl.CreateGPUDevice({.SPIRV}, true , nil))
        defer sdl.DestroyGPUDevice(gpu)
        
        sdl_check(sdl.ClaimWindowForGPUDevice(gpu, window))
        defer sdl.ReleaseWindowFromGPUDevice(gpu, window)
        
        vert_shader := load_shader(vert_shader_code, gpu, .VERTEX)
        defer sdl.ReleaseGPUShader(gpu, vert_shader)
        
        frag_shader := load_shader(frag_shader_code, gpu, .FRAGMENT)
        defer sdl.ReleaseGPUShader(gpu, frag_shader)
        
        pipeline := sdl_check(sdl.CreateGPUGraphicsPipeline(gpu, {
                vertex_shader = vert_shader,
                fragment_shader = frag_shader,
                primitive_type = .TRIANGLELIST,
                target_info = {
                        num_color_targets = 1,
                        color_target_descriptions = &(sdl.GPUColorTargetDescription {
                                format = sdl.GetGPUSwapchainTextureFormat(gpu, window)
                        })
                }
                
        }))
        defer sdl.ReleaseGPUGraphicsPipeline(gpu, pipeline)

        main_loop: for {

                ev: sdl.Event
                for sdl.PollEvent(&ev) {
                        #partial switch ev.type {
                        case .QUIT:
                                break main_loop
                        case .KEY_DOWN:
                                if ev.key.scancode == .ESCAPE do break main_loop
                        }
                }
                cmd_buf := sdl.AcquireGPUCommandBuffer(gpu)
                swapchain_tex: ^sdl.GPUTexture
                sdl_check(sdl.WaitAndAcquireGPUSwapchainTexture(cmd_buf, window, &swapchain_tex, nil, nil))

                color_target := sdl.GPUColorTargetInfo {
                        texture = swapchain_tex,
                        load_op = .CLEAR,
                        clear_color = {0, 0.2, 0.4 ,1},
                        store_op = .STORE
                }
                render_pass :=  sdl.BeginGPURenderPass(cmd_buf, &color_target, 1 , nil)

                sdl.BindGPUGraphicsPipeline(render_pass, pipeline)
                
                sdl.DrawGPUPrimitives(render_pass, 3, 1 ,0, 0)
                
                sdl.EndGPURenderPass(render_pass)
                
                sdl_check(sdl.SubmitGPUCommandBuffer(cmd_buf))
        } 
}

load_shader :: proc(code: []u8, device: ^sdl.GPUDevice, stage: sdl.GPUShaderStage) -> ^sdl.GPUShader {
        return sdl_check(sdl.CreateGPUShader(device, {
                        code_size = cast(uint)len(code),
                        code = raw_data(code),
                        entrypoint = "main",
                        format = {.SPIRV},
                        stage = stage
                }))
}