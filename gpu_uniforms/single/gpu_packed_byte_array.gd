# Standard buffer object, can be used for custom encoding

extends GPUUniformSingle
class_name GPU_PackedByteArray

const glsl_type = 'uint[]'
@export var data: PackedByteArray = PackedByteArray()


func serialize_data() -> PackedByteArray:
	return data

func deserialize_data(value: PackedByteArray) -> PackedByteArray:
	return value
