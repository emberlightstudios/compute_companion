#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer multi_var_buffer {
	bool a_bool;
	int an_int;
	float a_float;
	vec3 a_vector;
	double[] d_array;
};

// An example of using a multi variable buffer
void main() {
	a_bool = !a_bool;
	an_int *= 10;
	a_float *= 2.0;
	a_vector += vec3(0.1, 0.1, 0.1);

	// There is no length() method on arrays
	// you can pass the length as a separate int in the buffer though
	for (int i = 0; i < 7; i++)
		d_array[i] *= 2;
}

