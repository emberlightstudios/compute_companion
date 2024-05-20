# GLSL data type encoding: `double`, `float`

extends GPUUniformSingle
class_name GPU_Float

const glsl_type = 'float'
@export var data: float = 0.0


static func _create(data: float, alias: String = '') -> GPU_Float:
	var uniform := GPU_Float.new(alias)
	uniform.data = data
	return uniform

func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> float:
	return array.decode_float(0)




