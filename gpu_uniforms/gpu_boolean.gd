# GLSL data type encoding: `bool`

extends GPUUniformSingle
class_name GPU_Boolean

const glsl_type: String = 'bool'
@export var data: bool


static func _create(data: bool, alias: String = '') -> GPU_Boolean:
	var uniform = GPU_Boolean.new(alias)
	uniform.data = data
	return uniform

func serialize_data() -> PackedByteArray:
	var arr = PackedByteArray([0, 0, 0, 0])
	arr.encode_s32(0, 1 if data else 0)
	return arr

func deserialize_data(array: PackedByteArray) -> bool:
	return array.decode_u32(0) != 0
