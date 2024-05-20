# Base class for GLSL buffer objects wrapping a single variable

extends GPUUniform
class_name GPUUniformSingle

enum UNIFORM_TYPES{
	UNIFORM_BUFFER,
	STORAGE_BUFFER
}

## Type of uniform to create. `UNIFORM_BUFFER`s cannot be altered from within the shader
@export var uniform_type: UNIFORM_TYPES = UNIFORM_TYPES.UNIFORM_BUFFER


static func create_uniform_buffer(data, binding: int, alias: String = '') -> GPUUniformSingle:
	var uniform: GPUUniformSingle = _create(data, alias)
	uniform.uniform_type = UNIFORM_TYPES.UNIFORM_BUFFER
	uniform.binding = binding
	return uniform
	
static func create_storage_buffer(data, binding: int, alias: String = '') -> GPUUniformSingle:
	var uniform: GPUUniformSingle = _create(data, alias)
	uniform.uniform_type = UNIFORM_TYPES.STORAGE_BUFFER
	uniform.binding = binding
	return uniform
	
static func _create(data, alias) -> GPUUniform:
	return GPUUniform.new()

func _create_rd_uniform() -> RDUniform:
	rd_uniform = super()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			rd_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		UNIFORM_TYPES.STORAGE_BUFFER:
			rd_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	return rd_uniform
	
func _create_rid() -> RID:
	var buffer: RID = super()
	var bytes = serialize_data()
	match uniform_type:
		UNIFORM_TYPES.UNIFORM_BUFFER:
			buffer = rd.uniform_buffer_create(bytes.size(), bytes)
		UNIFORM_TYPES.STORAGE_BUFFER:
			buffer = rd.storage_buffer_create(bytes.size(), bytes)
	return buffer
