# GLSL data type encoding: `image2D`
extends GPUImageBase
class_name GPUImage

const glsl_type = 'image2D'
@export var data: Image = Image.create(1, 1, false, Image.FORMAT_RGBAF)


func get_width() -> int:
	return data.get_width()

func get_height() -> int:
	return data.get_height()

func initialize(compute: ComputeWorker) -> RDUniform:
	if data.has_mipmaps():
		data.clear_mipmaps()
	var img_format = image_formats[rd_format]
	if data.get_format() != img_format:
		data.convert(img_format)
	return super(compute)

func serialize_data() -> PackedByteArray:
	return data.get_data()

func deserialize_data(value: PackedByteArray) -> Image:
	return Image.create_from_data(data.get_width(), data.get_height(), false, image_formats[rd_format], value)
