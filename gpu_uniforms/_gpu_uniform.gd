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


func _init(data, _alias: String = '', _binding: int = -1) -> void:
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
	
func _create_rd_uniform(): 
	var rd_uniform := RDUniform.new()
	rd_uniform.binding = binding
	rd_uniform.add_id(data_rid)
	return rd_uniform
	
func _create_rid(): pass
func serialize_data(): pass
func deserialize_data(bytes: PackedByteArray): pass

func get_uniform_data():
	return deserialize_data(rd.buffer_get_data(data_rid))

## Per the alignment spec for SPIR-V structs, struct alignments must be rounded to a multiple of 16.
func pad_byte_array(arr: PackedByteArray):
	var copy = arr.duplicate()
	while copy.size() % 16 != 0:
		copy.append(0)
	return copy
