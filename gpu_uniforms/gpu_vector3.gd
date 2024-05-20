# GLSL data type encoding: `vec3`

extends GPUUniformSingle
class_name GPU_Vector3

const glsl_type = 'vec3'
@export var data: Vector3 = Vector3()


static func _create(data: Vector3, alias: String = '') -> GPU_Vector3:
	var uniform := GPU_Vector3.new(alias)
	uniform.data = data
	return uniform

func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data.x, data.y, data.z]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> PackedVector3Array:
	var dup = array.duplicate()
	dup.to_float32_array()
	var vec = Vector3()
	vec.x = dup.decode_float(0)
	vec.y = dup.decode_float(4)
	vec.z = dup.decode_float(8)
	return vec
