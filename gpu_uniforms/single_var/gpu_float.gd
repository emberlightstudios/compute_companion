# GLSL data type encoding: `double`, `float`

extends GPUUniformSingle
class_name GPU_Float

const glsl_type = 'float'
@export var data: float = 0.0


func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> float:
	return array.decode_float(0)




