# GLSL data type encoding: `vec4`

extends GPUUniformSingle
class_name GPU_Vector4

const glsl_type = 'vec4'
@export var data: Vector4 = Vector4()


func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data.x, data.y, data.z, data.w]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> Vector4:
	var vec = Vector4()
	vec.x = array.decode_float(0)
	vec.y = array.decode_float(4)
	vec.z = array.decode_float(8)
	vec.w = array.decode_float(12)
	return vec
