# GLSL data type encoding: `struct`

extends GPUUniform
class_name GPUUniformMulti

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## The structure of the Struct defined inside the shader.
## Add data types to the array that correspond to the data types defined in the shader, in the same order.
@export var data: Array = []
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.STORAGE_BUFFER

var bytes: PackedByteArray = PackedByteArray()
var byte_length: int = 0

func _create_rd_uniform() -> RDUniform:
	rd_uniform = super()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			rd_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		UNIFORM_TYPES.STORAGE_BUFFER:
			rd_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	return rd_uniform

func _create_rid() -> RID:
	var buffer: RID = RID()
	bytes = serialize_data(data)
	byte_length = bytes.size()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	return buffer

func get_uniform_data():
	var out := rd.buffer_get_data(data_rid)
	return deserialize_data(out)
	
func set_uniform_data(_data: Array) -> void:
	data = _data
	var sb_data = serialize_data(data)
	rd.buffer_update(data_rid, 0 , sb_data.size(), sb_data)

## Encode the contents of the passed in `data` Array to PackedByteArray. 
func serialize_data(_data) -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	var i: int = 0
	for obj in _data:
		match typeof(obj):
			TYPE_BOOL:
				arr.append_array(serialize_bool(data[i]))
			TYPE_FLOAT:
				arr.append_array(serialize_float(data[i]))
			TYPE_INT:
				arr.append_array(serialize_int(data[i]))
			TYPE_VECTOR2:
				arr.append_array(serialize_vector2(data[i]))
			TYPE_VECTOR3:
				arr.append_array(serialize_vector3(data[i]))
			TYPE_VECTOR3I:
				arr.append_array(serialize_vector3i(data[i]))
			TYPE_VECTOR4:
				arr.append_array(serialize_vector4(data[i]))
			TYPE_COLOR:
				arr.append_array(serialize_color(data[i]))
			TYPE_PACKED_FLOAT64_ARRAY:
				arr.append_array(serialize_packedfloat64array(data[i]))
			TYPE_PACKED_VECTOR3_ARRAY:
				arr.append_array(serialize_packedvector3array(data[i]))
			TYPE_PACKED_BYTE_ARRAY:
				arr.append_array(data[i])
		i += 1
	if data_rid.is_valid():
		if pad_byte_array(arr).size() != byte_length:
			if rd_uniform.uniform_type == RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER:
				printerr("Data for uniform: " + str(alias) + " does not match struct requirements. Needs: " + str(byte_length) + " was given: " + str(arr.size()))
	return pad_byte_array(arr)

## Decode the contents of the passed in PackedByteArray to an Array matching
## the order and data types defined in `struct_data`. 
func deserialize_data(data: PackedByteArray) -> Array:
	var arr: Array = []
	var offset: int = 0
	for i in range(data.size()):
		match typeof(data[i]):
			TYPE_BOOL:
				var b := deserialize_bool(data.slice(offset, offset + 4))
				arr.push_back(b)
				offset += 4
			TYPE_FLOAT:
				var flo := deserialize_float(data.slice(offset, offset + 4))
				arr.push_back(flo)
				offset += 8
			TYPE_INT:
				var integer := deserialize_int(data.slice(offset, offset + 4))
				arr.push_back(integer)
				offset += 4
			TYPE_VECTOR2:
				var vec := deserialize_vector2(data.slice(offset, offset + 8))
				arr.push_back(vec)
				offset += 16
			TYPE_VECTOR3:
				var vec := deserialize_vector3(data.slice(offset, offset + 16))
				arr.push_back(vec)
				offset += 32
			TYPE_VECTOR3I:
				var vec := deserialize_vector3i(data.slice(offset, offset + 16))
				arr.push_back(vec)
				offset += 32
			TYPE_COLOR:
				var col := deserialize_color(data.slice(offset, offset + 16))
				arr.push_back(col)
				offset += 32
			TYPE_PACKED_FLOAT64_ARRAY:
				var float_array := deserialize_packedfloat64array(data.slice(offset))
				arr.push_back(float_array)
			TYPE_PACKED_VECTOR3_ARRAY:
				var vec_array := deserialize_packedvector3array(data.slice(offset))
				arr.push_back(vec_array)
			TYPE_PACKED_BYTE_ARRAY:
				arr.push_back(data.slice(offset))
	return arr


