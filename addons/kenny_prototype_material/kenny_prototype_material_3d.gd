@tool
class_name KennyPrototypeMaterial3D extends StandardMaterial3D


@export_enum("dark", "green", "light", "orange", "purple", "red") var texture_color := "dark":
	set(value):
		texture_color = value
		set_albedo_texture()

@export_range(1, 13) var type := 1:
	set(value):
		type = value
		set_albedo_texture()


func _init() -> void:
	super()
	uv1_triplanar = true
	set_albedo_texture()


func set_albedo_texture() -> void:
	var dir: String = get_script().resource_path.get_base_dir()
	albedo_texture = load("/".join([dir, "textures", texture_color, "texture_%02d.png" % type]))
