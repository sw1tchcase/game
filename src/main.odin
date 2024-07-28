package main

import "base:runtime"

import "core:fmt"

import "core:math"
import "core:math/linalg"

import skl_app "shared:sokol/app"
import skl_gfx "shared:sokol/gfx"
import skl_glue "shared:sokol/glue"
import skl_log "shared:sokol/log"

import shd "shaders"

BACKGROUND_COLOUR :: skl_gfx.Color{0.1, 0.1, 0.1, 1}

pipeline: skl_gfx.Pipeline
bindings: skl_gfx.Bindings
pass_action: skl_gfx.Pass_Action

uniform: shd.Triangle_Vs_Params

vertices := [?][3]f32{{0, 0.5, 0}, {0.5, -0.5, 0}, {-0.5, -0.5, 0}}

main :: proc() {
	app_desc: skl_app.Desc
	app_desc.width = 800
	app_desc.height = 600
	app_desc.init_cb = init
	app_desc.frame_cb = frame
	app_desc.event_cb = event
	app_desc.cleanup_cb = cleanup
	skl_app.run(app_desc)
}

init :: proc "c" () {
	context = runtime.default_context()

	skl_gfx.setup({environment = skl_glue.environment(), logger = {func = skl_log.func}})

	bindings.vertex_buffers[0] = skl_gfx.make_buffer(
		{data = {ptr = &vertices, size = size_of(vertices)}},
	)

	pip_desc: skl_gfx.Pipeline_Desc
	pip_desc.shader = skl_gfx.make_shader(shd.triangle_shader_desc(skl_gfx.query_backend()))
	pip_desc.layout.attrs = {
		shd.ATTR_vs_position = {format = .FLOAT3},
	}
	pipeline = skl_gfx.make_pipeline(pip_desc)

	pass_action = {
		colors = {0 = {load_action = .CLEAR, clear_value = BACKGROUND_COLOUR}},
	}

	make_camera(1.5, 800 / 600, {0, 0, 1}, {0, 0, 0})
}

frame :: proc "c" () {
	context = runtime.default_context()

	@(static)
	cam_roatation: f32 = 0

	cam_roatation += 0.01
	set_position_camera({math.sin_f32(cam_roatation), 0, math.cos_f32(cam_roatation)})
	update_camera()
	uniform.mvp = camera.projection * camera.view

	skl_gfx.begin_pass({action = pass_action, swapchain = skl_glue.swapchain()})
	skl_gfx.apply_pipeline(pipeline)
	skl_gfx.apply_bindings(bindings)
	skl_gfx.apply_uniforms(.VS, shd.ATTR_vs_position, {ptr = &uniform, size = size_of(uniform)})
	skl_gfx.draw(0, len(vertices), 1)
	skl_gfx.end_pass()
	skl_gfx.commit()
}

event :: proc "c" (event: ^skl_app.Event) {
}

cleanup :: proc "c" () {
	context = runtime.default_context()
	skl_gfx.shutdown()
}
