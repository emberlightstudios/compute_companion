#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) restrict readonly uniform image2D inputImage;
layout(set = 0, binding = 1, rgba32f) restrict writeonly uniform image2D outputImage;


// Simple color inversion shader
void main() {
	ivec2 id = ivec2(gl_GlobalInvocationID.xy);
	vec4 color = imageLoad(inputImage, id);
	color.rgb = vec3(1.) - color.rgb;
	imageStore(outputImage, id, color);
}

