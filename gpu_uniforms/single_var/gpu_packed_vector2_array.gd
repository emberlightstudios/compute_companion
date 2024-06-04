# GLSL data type encoding: `vec3[]`

extends GPUUniformSingle
class_name GPU_PackedVector2Array

const glsl_type = 'vec2[]'
@export var data := PackedVector2Array()
 

func serialize_data() -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	for vector in data:
		var vec: Vector2 = Vector2()
		vec.x = vector.x
		vec.y = vector.y
		var float_arr = PackedFloat32Array([vector.x, vector.y]).to_byte_array()
		bytes.append_array(float_arr)
	return bytes

func deserialize_data(array: PackedByteArray) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for v in range(array.size() / 8):
		var vec = Vector2()
		vec.x = array.decode_float(0 + (v * 8))
		vec.y = array.decode_float(4 + (v * 8))
		arr.append(vec)
	return arr
	
