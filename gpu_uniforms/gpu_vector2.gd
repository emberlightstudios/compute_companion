# GLSL data type encoding: `vec2`

extends GPUUniformSingle
class_name GPU_Vector2

const glsl_type = 'vec2'
@export var data: Vector2 = Vector2()


static func _create(data: Vector2, alias: String = '') -> GPU_Vector2:
	var uniform := GPU_Vector2.new(alias)
	uniform.data = data
	return uniform
	
func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data.x, data.y]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> Vector2:
	var dup = array.duplicate()
	dup.to_float32_array()
	var vec = Vector2()
	vec.x = dup.decode_float(0)
	vec.y = dup.decode_float(4)
	return vec

