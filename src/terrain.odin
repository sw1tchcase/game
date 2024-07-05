package main

import "core:fmt"

import "core:math"
import "core:math/noise"

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

TERRAIN_TEX_SIZE :: 32
TERRAIN_TEX_PASSES :: 4
terrain_texture: [TERRAIN_TEX_SIZE][TERRAIN_TEX_SIZE]u32

gen_pass :: proc(lower, upper: [2]int, pass: u32) {
	pass := pass
	if pass == 0 do return

	value := u32(
		noise.noise_2d(
			0,
			{f64((upper.x - lower.x) / 2 + lower.x), f64((upper.y - lower.y) / 2 + lower.y)},
		) *
		0xFF,
	)

	for i in lower.y ..< upper.y {
		for j in lower.x ..< upper.x {
			terrain_texture[i][j] = value
		}
	}

	gen_pass(lower, (upper - lower) / 2 + lower, pass - 1)
	gen_pass(
		{(upper.x - lower.x) / 2 + lower.x, lower.y},
		{upper.x, (upper.y - lower.y) / 2 + lower.y},
		pass - 1,
	)
	gen_pass(
		{lower.x, (upper.y - lower.y) / 2 + lower.y},
		{(upper.x - lower.x) / 2 + lower.x, upper.y},
		pass - 1,
	)
	gen_pass((upper - lower) / 2 + lower, upper, pass - 1)

}

gen_texture :: proc() {
	gen_pass({}, [2]int{TERRAIN_TEX_SIZE, TERRAIN_TEX_SIZE}, TERRAIN_TEX_PASSES)
}

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

	gen_texture()

	img_desc: skl_gfx.Image_Desc
	img_desc.width = TERRAIN_TEX_SIZE
	img_desc.height = TERRAIN_TEX_SIZE
	img_desc.data.subimage[0][0] = skl_gfx.Range {
		ptr  = &terrain_texture,
		size = size_of(terrain_texture),
	}

	img := skl_gfx.make_image(img_desc)

	bindings.vs.images[shd.SLOT_tex] = img
	bindings.vs.samplers[shd.SLOT_smp] = skl_gfx.make_sampler({})
}

draw_terrain :: proc() {
	uniform.mvp = camera.projection * camera.view
	uniform.cam_pos = camera.position
	skl_gfx.apply_pipeline(pipeline)
	skl_gfx.apply_bindings(bindings)
	skl_gfx.apply_uniforms(.VS, 0, {ptr = &uniform, size = size_of(uniform)})
	skl_gfx.draw(0, len(vertices), 8 * 8)
}
