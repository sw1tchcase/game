package main

import skl_gfx "shared:sokol/gfx"

import shd "shaders"

@(private = "file")
pipeline: skl_gfx.Pipeline
@(private = "file")
bindings: skl_gfx.Bindings

@(private = "file")
vertices := [?][2]f32{{-0.5, 0.5}, {0.5, 0.5}, {-0.5, -0.5}, {0.5, -0.5}}

@(private = "file")
uniform: shd.Terrain_Vs_Params

init_terrain :: proc() {
	bindings.vertex_buffers[0] = skl_gfx.make_buffer(
		{data = {ptr = &vertices, size = size_of(vertices)}},
	)

	pip_desc: skl_gfx.Pipeline_Desc
	pip_desc.shader = skl_gfx.make_shader(shd.terrain_shader_desc(skl_gfx.query_backend()))
	pip_desc.depth.write_enabled = true
	pip_desc.depth.compare = .LESS_EQUAL
	pip_desc.layout.attrs = {
		shd.ATTR_vs_position = {format = .FLOAT2},
	}
	pip_desc.primitive_type = .TRIANGLE_STRIP

	pipeline = skl_gfx.make_pipeline(pip_desc)
}

draw_terrain :: proc() {
	uniform.mvp = camera.projection * camera.view
	uniform.cam_pos = camera.position
	skl_gfx.apply_pipeline(pipeline)
	skl_gfx.apply_bindings(bindings)
	skl_gfx.apply_uniforms(.VS, 0, {ptr = &uniform, size = size_of(uniform)})
	skl_gfx.draw(0, len(vertices), 8 * 8)
}
