package main

import "core:math"
import "core:math/linalg"

Camera :: struct {
	projection, view: linalg.Matrix4f32,
	fov, aspect:      f32,
	position, target: [3]f32,
	update:           bit_set[enum {
		Projection,
		View,
	}],
}

camera: Camera

make_camera :: proc(fov, aspect: f32, position, target: [3]f32) {
	camera.fov = fov
	camera.aspect = aspect
	camera.position = position
	camera.target = target
	camera.update = {.Projection, .View}
	update_camera()
}

update_camera :: proc() {
	if .Projection in camera.update {
		camera.projection = linalg.matrix4_perspective_f32(camera.fov, camera.aspect, 0.1, 100)
	}
	if .View in camera.update {
		camera.view = linalg.matrix4_look_at_f32(camera.position, camera.target, {0, 1, 0})
	}

	camera.update = {}
}

set_fov_camera :: proc(fov: f32) {
	camera.fov = fov
	camera.update += {.Projection}
}

set_aspect_camera :: proc(aspect: f32) {
	camera.aspect = aspect
	camera.update += {.Projection}
}

set_position_camera :: proc(position: [3]f32) {
	camera.position = position
	camera.update += {.View}
}

set_target_camera :: proc(target: [3]f32) {
	camera.target = target
	camera.update += {.View}
}
