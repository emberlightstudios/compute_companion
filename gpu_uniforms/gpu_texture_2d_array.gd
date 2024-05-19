# GLSL data type encoding: `image2DArray`

extends GPUUniform
class_name GPU_Texture2DArray

## The initial data supplied to the uniform
@export var data: Array[Image]
## The dimensions to initialize the texture array with
@export var texture_array_size: Vector3i = Vector3i(1,1,1)
## The shader binding for this uniform
@export var binding: int = 0
## Image.FORMAT_* enum values only
@export var image_format: int = Image.FORMAT_RGBAF

var data_rid: RID = RID()
var uniform: RDUniform = RDUniform.new()
var uniform_texture_format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
var texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
var uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE


func initialize(rd: RenderingDevice) -> RDUniform:
	if data == null or data.size() == 0:
		# Generate the initial Texture2DArray using the provided `texture_array_size`
		var images: Array[Image] = []
		for layer in texture_array_size.z:
			var image = Image.new()
			var empty = PackedByteArray()
			empty.resize(16 * texture_array_size.x * texture_array_size.y)
			image.set_data(texture_array_size.x, texture_array_size.y, false, Image.FORMAT_RGBAF, empty)
			images.push_back(image)
		data = images
	data_rid = create_rid(rd)
	# Create RDUniform object using the provided binding id and data
	return create_uniform()

func create_rid(rd: RenderingDevice) -> RID:
	var texture_format = RDTextureFormat.new()
	texture_format.texture_type = texture_type
	texture_format.format = uniform_texture_format
	texture_format.width = data[0].get_width()
	texture_format.height = data[0].get_height()
	texture_format.array_layers = data.size()
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
								RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | \
								RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | \
								RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	var bytes = []
	for image in data:
		if image.has_mipmaps():
			image.clear_mipmaps()
		if image.get_format() != Image.FORMAT_RGBAF:
			image.convert(Image.FORMAT_RGBAF)
		bytes.append(image.get_data())
	var tex = rd.texture_create(texture_format, RDTextureView.new(), bytes)
	return tex

func create_uniform() -> RDUniform:
	uniform.uniform_type = uniform_type
	uniform.binding = binding
	uniform.add_id(data_rid)
	return uniform
	
func get_uniform_data(rd: RenderingDevice) -> Array[Image]:
	var images: Array[Image] = []
	for layer in data.size():
		var t_data = rd.texture_get_data(data_rid, layer)
		var image = Image.create_from_data(data[0].get_width(), data[0].get_height(), false, image_format, t_data)
		images.push_back(image)
	return images

func set_uniform_data(rd: RenderingDevice, images: Array[Image]) -> void:
	for layer in images.size():
		var img = images[layer]
		if img.has_mipmaps():
			img.clear_mipmaps()
		if img.get_format() != Image.FORMAT_RGBAF:
			img.convert(Image.FORMAT_RGBAF)
		rd.texture_update(data_rid, layer, images[layer].get_data())

