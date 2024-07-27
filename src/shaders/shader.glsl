@header package shaders
@header import sg "shared:sokol/gfx"

@vs vs
in vec4 position;

void main() {
    gl_Position = position;
}
@end

@fs fs
out vec4 frag_color;

void main() {
    frag_color = vec4(1,1,1,1);
}
@end

@program triangle vs fs
