# GLSL data type encoding: `double[]`

extends GPUUniformSingle
class_name GPU_PackedFloat64Array

const glsl_type = 'double[]'
@export var data: PackedFloat64Array = PackedFloat64Array()


func serialize_data() -> PackedByteArray:
	return data.to_byte_array()

func deserialize_data(value: PackedByteArray) -> PackedFloat64Array:
	return 	value.to_float64_array()
