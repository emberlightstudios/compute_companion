#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
layout(set = 0, binding = 0, rgba32f) restrict uniform image2D output_texture;
layout(set = 0, binding = 1, rgba32f) restrict uniform image2DArray t_array;

void main() {

    ivec2 id = ivec2(gl_GlobalInvocationID.xy);
    vec4 color1 = imageLoad(t_array, ivec3(id, 0));
    vec4 color2 = imageLoad(t_array, ivec3(id, 1));
    imageStore(output_texture, id, (color1 + color2)*0.5);
}

