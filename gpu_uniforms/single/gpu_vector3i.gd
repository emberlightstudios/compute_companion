# GLSL data type encoding: `ivec3`, `ivec4`

extends GPUUniformSingle
class_name GPU_Vector3i

const glsl_type = 'ivec3'
@export var data: Vector3i = Vector3i()


func serialize_data() -> PackedByteArray:
	return PackedInt32Array([data.x, data.y, data.z]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> Vector3i:
	var dup = array.duplicate()
	var vec = Vector3i()
	vec.x = dup.decode_s32(0)
	vec.y = dup.decode_s32(4)
	vec.z = dup.decode_s32(8)
	return vec

