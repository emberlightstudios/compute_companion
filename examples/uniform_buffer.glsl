#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) restrict readonly uniform ubuffer_buffer {
	vec3 ubuffer;
};

layout(set = 0, binding = 1, std430) restrict buffer sbuffer_buffer {
	vec3 sbuffer;
};

void main() {
	sbuffer *= ubuffer;
}

