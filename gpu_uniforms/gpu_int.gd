# GLSL data type encoding: `int`

extends GPUUniformSingle
class_name GPU_Int

const glsl_type = 'int'
@export var data: int = 0


func serialize_data() -> PackedByteArray:
	return PackedInt32Array([data]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> int:
	return array.decode_s32(0)
