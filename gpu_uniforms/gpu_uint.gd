# GLSL data type encoding: `int`

extends GPUUniformSingle
class_name GPU_UInt

const glsl_type = 'uint'
@export var data: int = 0


func serialize_data() -> PackedByteArray:
	return PackedInt32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> int:
	return array.decode_u32(0)
