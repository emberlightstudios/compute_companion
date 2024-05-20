# GLSL data type encoding: `int`

extends GPUUniformSingle
class_name GPU_UInt

const glsl_type = 'uint'
@export var data: int = 0


static func _create(data: int, alias: String = '') -> GPU_UInt:
	var uniform := GPU_UInt.new(alias)
	if data < 0:
		push_warning("Passing negative int to uint uniform can result in unpredictable behavior")
	uniform.data = data
	return uniform

func serialize_data() -> PackedByteArray:
	return PackedInt32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> int:
	return array.decode_u32(0)
