@header package shaders
@header import sg "shared:sokol/gfx"
@header import "core:math/linalg"

@ctype mat4 linalg.Matrix4f32

@vs vs
in vec3 position;

uniform triangle_vs_params{
  mat4 mvp;
};

void main() {
    gl_Position = mvp * vec4(position,1);
}
@end

@fs fs
out vec4 frag_color;

void main() {
    frag_color = vec4(1,1,1,1);
}
@end

@program triangle vs fs
