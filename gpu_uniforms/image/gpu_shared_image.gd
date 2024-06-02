# GLSL data type encoding: `image2D`

class_name GPU_SharedImage
extends GPUImageBase

@export var data: Texture2D

func _create_rid() -> RID:
	var texture_format = _get_rd_texture_format()
	var tex = rd.texture_create_shared(view, data)
	return tex

func get_width() -> int:
	return data.get_width()

func get_height() -> int:
	return data.get_height()

func serialize_data() -> PackedByteArray:
	return data.get_image().get_data()

func deserialize_data(value: PackedByteArray) -> Image:
	return Image.create_from_data(data.get_width(), data.get_height(), false, image_formats[rd_format], value)
