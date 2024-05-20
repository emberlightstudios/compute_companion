@icon("res://addons/compute_companion/gpu_uniforms/gpu_uniform_icon.png")

extends Resource
class_name GPUUniform


## Base class for uniforms used with ComputeWorker. 
## Contains functions used for serializing Godot data types to and from GLSL equivalents.

## User-defined name for the uniform. Used for accessing the GPUUniform object via ComputeWorker.
@export var alias: String = ""
## The shader binding for this uniform
@export var binding: int = 0

var data_rid: RID = RID()
var rd_uniform: RDUniform = RDUniform.new()
var rd: RenderingDevice = null


func _init(data, _binding: int, _alias: String = '') -> void:
	set(&'data', data)
	alias = _alias
	binding = _binding

## Set up uniform buffer and register with RenderingDevice. Returns the resulting RDUniform.
func initialize(_rd: RenderingDevice) -> RDUniform:
	rd = _rd
	# Create the buffer using our initial data
	data_rid = _create_rid()
	# Create RDUniform object using the provided binding id and data
	return _create_rd_uniform()
	
func _create_rd_uniform(): pass
func _create_rid(): pass

func serialize_data():
	pass	
func deserialize_data(bytes: PackedByteArray): 
	pass

func set_uniform_data(value) -> void:
	set(&'data', value)
	var sb_data = serialize_data()
	rd.buffer_update(data_rid, 0, sb_data.size(), sb_data)

func get_uniform_data():
	return deserialize_data(rd.buffer_get_data(data_rid))
