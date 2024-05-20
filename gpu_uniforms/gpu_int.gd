# GLSL data type encoding: `int`

extends GPUUniformSingle
class_name GPU_Int

const glsl_type = 'int'
@export var data: int = 0


static func _create(data: int, alias: String = '') -> GPU_Int:
	var uniform := GPU_Int.new(alias)
	uniform.data = data
	return uniform

func serialize_data() -> PackedByteArray:
	return PackedInt32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> int:
	return array.decode_s32(0)
