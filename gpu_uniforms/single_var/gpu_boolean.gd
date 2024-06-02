# GLSL data type encoding: `bool`

extends GPUUniformSingle
class_name GPU_Boolean

const glsl_type: String = 'bool'
@export var data: bool


func serialize_data() -> PackedByteArray:
	var arr = PackedByteArray([0, 0, 0, 0])
	arr.encode_s32(0, 1 if data else 0)
	return arr

func deserialize_data(array: PackedByteArray) -> bool:
	return array.decode_u32(0) != 0
