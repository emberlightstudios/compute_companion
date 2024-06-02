# GLSL data type encoding: `struct[]`

class_name GPUUniformStructArray
extends GPUUniformSingle


## The size of the Struct array defined in the shader.
@export var data: Array[GPUUniformStruct]

var struct_buffer_sizes = []


func serialize_data() -> PackedByteArray:
	var arr := PackedByteArray()
	for struct in data:
		var struct_bytes = struct.serialize_data()
		while len(struct_bytes) % 16 != 0:
			struct_bytes.append(0)
		arr.append_array(struct_bytes)
		struct_buffer_sizes.append(len(struct_bytes))
	return arr

func deserialize_data(array: PackedByteArray) -> Array:
	var structs = []
	var offset := 0
	for i in data.size():
		structs.append(data[i].deserialize_data(array.slice(offset)))
		offset += struct_buffer_sizes[i]
	return structs
	
