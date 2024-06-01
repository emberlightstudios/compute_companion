# GLSL data type encoding: `double[]`

extends GPUUniformSingle
class_name GPU_PackedFloat64Array

const glsl_type = 'double[]'
@export var data: PackedFloat64Array = PackedFloat64Array()


func serialize_data() -> PackedByteArray:
	return data.to_byte_array()

func deserialize_data(value: PackedByteArray) -> PackedFloat64Array:
	return 	value.to_float64_array()

## Is this necessary for uniform buffers?
func pad_byte_array_std140(arr: PackedByteArray) -> PackedByteArray:
	
	arr.resize(arr.size() * 2)
	var next_offset = 0
	
	for i in range(arr.size()):
		if next_offset + 8 > arr.size():
			break
		arr.encode_double(next_offset + 8, 0.0)
		next_offset += 16
	
	return arr
