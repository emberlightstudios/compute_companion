# Base class for GLSL buffer objects wrapping a single variable

extends GPUUniform
class_name GPUUniformSingle

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## Type of uniform to create. `UNIFORM_BUFFER`s cannot be altered from within the shader
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.STORAGE_BUFFER
## for storing the size of the packed byte array of serialized data
var bytes_size : int

func _init(_data, _alias: String = '' , _binding: int = -1, storage_buffer: bool = true):
	super(_data, _alias, _binding)
	uniform_type = UNIFORM_TYPES.STORAGE_BUFFER if storage_buffer else UNIFORM_TYPES.UNIFORM_BUFFER

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
	var bytes: PackedByteArray = serialize_data()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			bytes = pad_byte_array(bytes)
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	bytes_size = len(bytes)
	return buffer

func set_uniform_data(value) -> void:
	set(&'data', value)
	var buffer_data: PackedByteArray = serialize_data()
	if uniform_type == UNIFORM_TYPES.UNIFORM_BUFFER:
		buffer_data = pad_byte_array(buffer_data)
	rd.buffer_update(data_rid, 0, len(buffer_data), buffer_data)
