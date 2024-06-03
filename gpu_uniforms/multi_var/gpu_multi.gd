## GLSL data type encoding multi-variable buffer
## Data is input as a list of single var GPUUniform objects
## If using an array of indeterminate length in a storage buffer,
## it MUST be the last element in the list

class_name GPU_Multi
extends GPUUniformSingle

## The structure of the buffer defined inside the shader.
## Add data types to the array that correspond to the data types defined in the shader, in the same order.
@export var data: Array[GPUUniformSingle] = []

var var_buffer_sizes: Array = []


func serialize_data() -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	var_buffer_sizes.resize(len(data))
	for i in len(data):
		var bytes = data[i].serialize_data()
		var_buffer_sizes[i] = len(bytes)
		## Vector types must be 16 byte aligned
		## Adjust previous alignment if prior varibales dont
		## align to 16 bytes
		if data[i] is GPU_PackedByteArray or \
			data[i] is GPU_PackedFloat64Array or \
			data[i] is GPU_PackedVector3Array or \
			data[i] is GPU_Vector2 or \
			data[i] is GPU_Vector3 or \
			data[i] is GPU_Vector4 or \
			data[i] is GPU_Vector3i or \
			data[i] is GPU_Color:
				while len(arr) % 16 != 0:
					arr.append(0)
					var_buffer_sizes[i-1] += 1
		arr.append_array(bytes)

	if data_rid.is_valid():
		if rd_uniform.uniform_type == RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER:
			if pad_byte_array(arr).size() != bytes_size:
				printerr("Data for uniform: " + str(alias) + " does not match struct requirements. Needs: " + str(bytes_size) + " was given: " + str(arr.size()))
	return pad_byte_array(arr)

func deserialize_data(array: PackedByteArray) -> Array:
	var offset: int = 0
	var result: Array = []
	for i in len(data):
		var new_data = data[i].deserialize_data(array.slice(offset))
		offset += var_buffer_sizes[i]
		result.append(new_data)
	return result


