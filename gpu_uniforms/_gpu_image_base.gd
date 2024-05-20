# GLSL data type encoding: `image2D`
extends GPUUniform
class_name GPUImageBase

## RenderingDevice DATA_FORMAT enum values only
@export var rd_format: int = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT

# Map of RenderingDevice formats to compatible image format
var image_formats = {
	RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT: Image.FORMAT_RGBAF,
}
var texture_type = RenderingDevice.TEXTURE_TYPE_2D


func get_width() -> int:
	return 1

func get_height() -> int:
	return 1

func _create_rid() -> RID:
	var texture_format = _get_rd_texture_format()
	var image_data = serialize_data()
	var tex = rd.texture_create(texture_format, RDTextureView.new(), image_data)
	return tex

func _get_rd_texture_format() -> RDTextureFormat:
	var texture_format = RDTextureFormat.new()
	texture_format.texture_type = texture_type
	texture_format.format = rd_format
	texture_format.width = get_width()
	texture_format.height = get_height()
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
								RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | \
								RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | \
								RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	return texture_format

func _create_rd_uniform() -> RDUniform:
	rd_uniform = super()
	rd_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	return rd_uniform

func get_uniform_data():
	var t_data = rd.texture_get_data(data_rid, 0)
	return deserialize_data(t_data)

func set_uniform_data(image):
	set(&'data', image)
	var image_data = serialize_data()
	rd.texture_update(data_rid, 0, image_data)
