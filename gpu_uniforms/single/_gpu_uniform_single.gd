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

func _init(data, _alias: String = '' , _binding: int = -1, storage_buffer: bool = true):
	super(data, _binding, _alias)
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
	bytes_size = bytes.size()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			while bytes.size() % 16 != 0:
				bytes.append(0)
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	return buffer
