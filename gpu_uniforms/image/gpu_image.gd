# GLSL data type encoding: `image2D`
extends GPUImageBase
class_name GPU_Image

const glsl_type = 'image2D'
@export var data: Image = Image.create(1, 1, false, Image.FORMAT_RGBAF)


func get_glsl_data_format() -> String:
	return 'rgba32f'

func get_width() -> int:
	return data.get_width()

func get_height() -> int:
	return data.get_height()

func initialize(rd: RenderingDevice) -> RDUniform:
	rd_format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	if data.has_mipmaps():
		data.clear_mipmaps()
	var img_format = Image.FORMAT_RGBAF
	if data.get_format() != img_format:
		data.convert(img_format)
	return super(rd)

func serialize_data() -> PackedByteArray:
	return data.get_data()

func deserialize_data(value: PackedByteArray) -> Image:
	return Image.create_from_data(data.get_width(), data.get_height(), false, Image.FORMAT_RGBAF, value)
