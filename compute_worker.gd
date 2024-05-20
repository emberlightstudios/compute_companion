@icon("res://addons/compute_companion/compute_worker_icon.png")

extends Node
class_name ComputeWorker


## The GLSL shader file to execute
@export var shader_file: String = ''
## The uniform sets to bind to the compute pipeline. Must be UniformSet resources.
@export var uniform_sets: Array[UniformSet] = []
## The size of the global work group to dispatch.
@export var work_group_size: Vector3i = Vector3i(1, 1, 1)
## If `true`, the worker will use the global rendering pipeline.
@export var use_global_device: bool = false

var rd: RenderingDevice = null
var compute_pipeline: RID = RID()
var shader_rid: RID = RID()

var initialized = false

signal compute_begin
signal compute_end


## Factory for creating from code
static func create(shader: String) -> ComputeWorker:
	var compute = ComputeWorker.new()
	compute.shader_file = shader
	# Can't set on compute object directly or it complains about the type
	var uset: Array[UniformSet] = [UniformSet.new(0)]
	compute.uniform_sets = uset
	return compute

## Call this to initialize and dispatch the compute list. 
## Initial uniform data can be set by getting the uniform using `get_uniform_by_binding()` or `get_uniform_by_alias()`,
## and setting the uniform data directly before calling this.
func initialize(x: int = work_group_size.x, y: int = work_group_size.y, z: int = work_group_size.z) -> void:
	if not FileAccess.file_exists(shader_file):
		generate_stub()
		push_warning('Shader file did not exist so I created a stub for you.  Fill out the main method.')
		return
	if !rd:
		if use_global_device:
			rd = RenderingServer.get_rendering_device()
		else:
			rd = RenderingServer.create_local_rendering_device()
	# Load GLSL shader
	var shader_spirv: RDShaderSPIRV = load(shader_file).get_spirv()
	shader_rid = rd.shader_create_from_spirv(shader_spirv)
	# Generate uniform set from provided `GPU_*.tres` uniforms
	for i in range(uniform_sets.size()):
		uniform_sets[i].initialize(rd, shader_rid)
	# Create the RenderingDevice compute pipeline
	compute_pipeline = _create_compute_pipeline(shader_rid)
	# Bind uniform set and pipeline to compute list and dispatch
	work_group_size = Vector3i(x, y, z)
	dispatch_compute_list()
	initialized = true

## Fetch the data from a uniform by binding id
func get_uniform_data(binding: int, set_id: int = 0) -> Variant:
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	var uniform = get_uniform_by_binding(binding, set_id)
	if !uniform:
		printerr("Uniform at binding `" + str(binding) + "` not found in set " + str(set_id) + ".")
		return
	return uniform.get_uniform_data()

## Fetch the data from a uniform by alias
func get_uniform_data_by_alias(alias: String, set_id: int = 0) -> Variant:
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	var uniform = get_uniform_by_alias(alias, set_id)
	if !uniform:
		printerr("Uniform `" + alias + "` not found in set " + str(set_id) + ".")
		return
	return uniform.get_uniform_data()

## Set the data of a uniform by binding. If `dispatch` is true, the shader is executed and uniforms are updated immediately.
## `initialize()` must be called before setting uniform data with this function.
## To set uniform data before `initialized()` is called,
## get the GPU_* uniform object with `get_uniform_by_*()` and set the data directly.
func set_uniform_data(data: Variant, binding: int, set_id: int = 0, dispatch: bool = true) -> void:
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	var uniform = get_uniform_by_binding(binding, set_id)
	uniform.set_uniform_data(data)
	# Must dispatch new compute list with updated uniforms to take effect
	if dispatch:
		dispatch_compute_list()
		execute_compute_shader()

## Same as `set_uniform_data`, except it searches by the uniform's `alias`
func set_uniform_data_by_alias(data: Variant, alias: String, set_id: int = 0, dispatch: bool = true) -> void:
	if !initialized:
		printerr("ComputeWorker must be initialized before accessing uniform data")
		return
	var uniform = get_uniform_by_alias(alias, set_id)
	uniform.set_uniform_data(data)
	# Must dispatch new compute list with updated uniforms to take effect
	if dispatch:
		dispatch_compute_list()
		execute_compute_shader()

## Submit current compute list and wait for sync to update uniform values
func execute_compute_shader() -> void:
	if use_global_device:
		return
	compute_begin.emit()
	rd.submit()
	rd.sync()
	compute_end.emit()

## Internal. Create the compute pipeline for the RenderingDevice, returns pipeline RID
func _create_compute_pipeline(shader: RID) -> RID:
	var pipeline := rd.compute_pipeline_create(shader)
	return pipeline

## Binds and dispatches the compute list using the current uniform set and pipeline
func dispatch_compute_list() -> void:
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)
	for u_set in uniform_sets:
		rd.compute_list_bind_uniform_set(compute_list, u_set.uniform_set_rid, u_set.set_id)
	rd.compute_list_dispatch(compute_list, work_group_size.x, work_group_size.y, work_group_size.z)
	rd.compute_list_end()

## Get a UniformSet resource by its set id
func get_uniform_set_by_id(id: int) -> UniformSet:
	for u_set in uniform_sets:
		if u_set.set_id == id:
			return u_set
	return null

## Get GPU_* uniform object in `set` by binding id
func get_uniform_by_binding(binding: int, set_id: int = 0) -> GPUUniform:
	for uniform in get_uniform_set_by_id(set_id).uniforms:
		if uniform.binding == binding:
			return uniform
	return null

## Get the GPUUniform object in `set` by its user-defined `alias`
func get_uniform_by_alias(alias: String, set_id: int = 0) -> GPUUniform:
	for uniform in get_uniform_set_by_id(set_id).uniforms:
		if uniform.alias == alias:
			return uniform
	return null

## Get the binding id of the GPU_* uniform in `set` by user-defined `alias`
func get_uniform_binding_by_alias(alias: String, set_id: int = 0) -> int:
	for uniform in get_uniform_set_by_id(set_id).uniforms:
		if uniform.alias == alias:
			return uniform.binding
	return -1

## Frees all RenderingDevice-created resources, then the RenderingDevice itself.
## Can be used to stop execution and change shaders, uniforms, etc.
## `initialize()` must be called again to resume operation.
func destroy() -> void:
	if !rd: 
		return
	for u_set in uniform_sets:
		u_set.destroy(rd)
	rd.free_rid(compute_pipeline)
	rd.free_rid(shader_rid)
	if !use_global_device:
		rd.free()
	rd = null
	initialized = false

func _exit_tree():
	destroy()

func generate_stub() -> void:
	var version = '450'
	var layout: Vector3i = Vector3i.ONE
	var fl = FileAccess.open(shader_file, FileAccess.WRITE)
	fl.store_line('#[compute]')
	fl.store_line('#version ' + version)
	fl.store_line('')
	
	fl.store_line('layout(local_size_x = {x}, local_size_y = {y}, local_size_z = {z}) in;'.format(
		{'x': layout.x, 'y': layout.y, 'z': layout.z}))
	for uniform_set in uniform_sets:
		for uniform: GPUUniform in uniform_set.uniforms:
			var qual: String = ''
			var buffer_type: String = ''
			if uniform is GPUImageBase:
				qual = 'rgba32f'
				fl.store_line('layout(set = {s}, binding = {b}, {q}) restrict uniform {t} {a};'.format(
					{'s': uniform_set.set_id, 'b': uniform.binding, 'q': qual, 't': uniform.glsl_type ,'a': uniform.alias}))
			elif uniform is GPUUniformSingle:
				if uniform.uniform_type == GPUUniformSingle.UNIFORM_TYPES.STORAGE_BUFFER:
					qual = 'std430'
					buffer_type = 'buffer'
				elif uniform.uniform_type == GPUUniformSingle.UNIFORM_TYPES.UNIFORM_BUFFER:
					qual = 'std140'
					buffer_type = 'readonly uniform'
				fl.store_line('layout(set = {s}, binding = {b}, {q}) restrict {t} {a} {'.format(
					{'s': uniform_set.set_id, 'b': uniform.binding, 'q': qual, 't': buffer_type, 'a': uniform.alias + '_buffer'}
				))
				fl.store_line('\t{t} {a};'.format({'t': uniform.glsl_type, 'a': uniform.alias }))
				fl.store_line('};')
		
	fl.store_line('')
	fl.store_line('void main() {')
	fl.store_line('')
	fl.store_line('}')
	fl.store_line('')
	fl.close()
