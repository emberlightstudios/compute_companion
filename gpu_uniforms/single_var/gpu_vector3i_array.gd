# GLSL data type encoding: `vec3[]`

extends GPUUniformSingle
class_name GPU_PackedVector3iArray

const glsl_type = 'ivec3[]'
@export var data: PackedInt32Array


## To get compatible with ivec3 we have to pad to align to 16 bytes
func serialize_data() -> PackedByteArray:
	var packed := PackedInt32Array()
	for i_vec in data.size() / 3:
		var vector = data.slice(3 * i_vec, 3 * (i_vec + 1))
		packed.append_array(vector)
		packed.append(0)
	return packed.to_byte_array()

## Note the return type is not the same type as data input
func deserialize_data(array: PackedByteArray) -> Array[Vector3i]:
	var arr = [] as Array[Vector3i]
	for v in range(array.size() / 16):
		var vec = Vector3i()
		vec.x = array.decode_s32(0 + (v * 16))
		vec.y = array.decode_s32(4 + (v * 16))
		vec.z = array.decode_s32(8 + (v * 16))
		arr.append(vec)
	return arr
	
