@header package shaders
@header import sg "shared:sokol/gfx"
@header import "core:math/linalg"

@ctype mat4 linalg.Matrix4f32

@vs terrain_vs
in vec2 position;
out vec3 frag_pos;
out vec3 view_pos;

uniform terrain_vs_params{
  mat4 mvp;
  vec3 cam_pos;
};

uniform texture2D tex;
uniform sampler smp;

void main() {
    int terrain_size = 8;

    vec2 offset = vec2(gl_InstanceIndex%terrain_size, gl_InstanceIndex/terrain_size);
    vec2 pos = vec2(position.x + offset.x, position.y + offset.y);

    float height = texture(sampler2D(tex,smp), vec2(pos.x/8, pos.y/8)).r;

    gl_Position = mvp * vec4(pos.x, height, pos.y, 1);

    frag_pos = vec3(position.x +  offset.x,0,position.y + offset.y);
    view_pos = cam_pos;
}
@end

@fs terrain_fs
in vec3 frag_pos;
in vec3 view_pos;

out vec4 frag_color;

void main() {
  vec3 colour = vec3(0.2,0.8,0.4);

  float specStrength = 0.5;

  vec3 normal = vec3(0,1,0);
  vec3 light_pos = vec3(0,4,0);

  vec3 lightDir = normalize(light_pos - frag_pos);
  float diff = max(dot(normal, lightDir), 0.0);
  vec3 diffuse = diff * vec3(0.1,0.1,0.1);

  vec3 viewDir = normalize(view_pos - frag_pos);
  vec3 reflectDir = reflect(-lightDir, normal);

  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 2);
  vec3 specular = specStrength * spec * vec3(1,1,1);

  vec3 result = (diffuse + specular) * colour;

  frag_color = vec4(result,1);
}
@end

@program terrain terrain_vs terrain_fs
