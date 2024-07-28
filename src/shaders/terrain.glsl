@header package shaders
@header import sg "shared:sokol/gfx"
@header import "core:math/linalg"

@ctype mat4 linalg.Matrix4f32

@vs terrain_vs
in vec2 position;

uniform terrain_vs_params{
  mat4 mvp;
};

void main() {
    int terrain_size = 8;

    vec2 offset = vec2(gl_InstanceIndex%terrain_size, gl_InstanceIndex/terrain_size);

    gl_Position = mvp * vec4(position.x + offset.x, 0, position.y + offset.y,1);
}
@end

@fs terrain_fs
out vec4 frag_color;

void main() {
    frag_color = vec4(0.2,0.8,0.4,1);
}
@end

@program terrain terrain_vs terrain_fs
