# GLSL data type encoding: `image2D`
extends GPUImage
class_name GPUSharedImage

func _create_rid() -> RID:
	var texture_format = _get_rd_texture_format()
	var tex = rd.texture_create_shared(RDTextureView.new(), data)
	return tex
