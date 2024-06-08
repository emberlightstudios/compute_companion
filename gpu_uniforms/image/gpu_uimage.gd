# GLSL data type encoding: `image2D`
extends GPUImageBase
class_name GPU_UImage

const glsl_type = 'uimage2D'
@export var data: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)


func get_glsl_data_format() -> String:
	return 'rgba8ui'

func get_width() -> int:
	return data.get_width()

func get_height() -> int:
	return data.get_height()

func initialize(rd: RenderingDevice) -> RDUniform:
	rd_format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT
	if data.has_mipmaps():
		data.clear_mipmaps()
	var img_format = Image.FORMAT_RGBA8
	if data.get_format() != img_format:
		data.convert(img_format)
	return super(rd)

func serialize_data() -> PackedByteArray:
	return data.get_data()

func deserialize_data(value: PackedByteArray) -> Image:
	return Image.create_from_data(data.get_width(), data.get_height(), false, Image.FORMAT_RGBA8, value)

