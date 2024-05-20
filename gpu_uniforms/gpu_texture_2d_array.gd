# GLSL data type encoding: `image2DArray`

extends GPUImageBase
class_name GPU_Texture2DArray

const glsl_type = 'image2DArray'
@export var data: Array[Image] = [Image.create(1, 1, false, Image.FORMAT_RGBAF)]


static func create_uniform(data: Array[Image], binding: int, alias: String = '') -> GPU_Texture2DArray:
	var uniform := GPU_Texture2DArray.new(alias)
	uniform.data = data
	uniform.binding = binding
	return uniform

func get_width():
	return data[0].get_width()

func get_height():
	return data[0].get_height()

func _get_rd_texture_format() -> RDTextureFormat:
	var format := super()
	format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	format.array_layers = data.size()
	return format

func initialize(rd: RenderingDevice) -> RDUniform:
	for image in data:
		if image.has_mipmaps():
			image.clear_mipmaps()
		var img_format = image_formats[rd_format]
		if image.get_format() != img_format:
			image.convert(img_format)
	return super(rd)
	
func serialize_data() -> Array:
	var bytes = []
	for img in data:
		bytes.append(img.get_data())
	return bytes

func deserialize_data(value: PackedByteArray) -> Array[Image]:
	var images: Array[Image] = []
	for layer in range(data.size()):
		var t_data = rd.texture_get_data(data_rid, layer)
		var image = Image.create_from_data(get_width(), get_height(), false, image_formats[rd_format], t_data)
		images.append(image)
	return images
