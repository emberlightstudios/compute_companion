# Base class for GLSL buffer objects wrapping a single variable

extends GPUUniform
class_name GPUUniformSingle

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## Type of uniform to create. `UNIFORM_BUFFER`s cannot be altered from within the shader
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.STORAGE_BUFFER


func _init(data, _binding: int, storage_buffer: bool = true, _alias: String = ''):
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
	var bytes = serialize_data()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	return buffer
