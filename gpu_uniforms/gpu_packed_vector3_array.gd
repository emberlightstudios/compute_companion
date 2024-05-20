# GLSL data type encoding: `vec3[]`

extends GPUUniformSingle
class_name GPU_PackedVector3Array

const glsl_type = 'vec3[]'
@export var data: PackedVector3Array = PackedVector3Array()


func serialize_data() -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	for vector in data:
		var vec: Vector3 = Vector3()
		vec.x = vector.x
		vec.y = vector.y
		vec.z = vector.z
		var float_arr = PackedFloat32Array([vector.x, vector.y, vector.z]).to_byte_array()
		bytes.append_array(float_arr)
	return bytes

func deserialize_data(array: PackedByteArray) -> PackedVector3Array:
	var arr: PackedVector3Array = PackedVector3Array()
	for v in range(array.size() / 16.0):
		var vec = Vector3()
		vec.x = array.decode_float(0 + (v * 16))
		vec.y = array.decode_float(4 + (v * 16))
		vec.z = array.decode_float(8 + (v * 16))
		arr.append(vec)
	return arr
	
