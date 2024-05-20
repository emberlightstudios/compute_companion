# GLSL data type encoding: `dvec4`

extends GPUUniformSingle
class_name GPU_Color

const glsl_type = 'vec4'
@export var data: Color = Color()


func serialize_data() -> PackedByteArray:
	return PackedFloat32Array([data.r, data.g, data.b, data.a]).to_byte_array()

func deserialize_data(array: PackedByteArray) -> Color:
	var col = Color()
	col.r = array.decode_float(0)
	col.g = array.decode_float(4)
	col.b = array.decode_float(8)
	col.a = array.decode_float(12)
	return col
