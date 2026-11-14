extends ColorRect

func _ready() -> void:
	var count := 12
	var data: Array[Vector4] = []
	for i in count:
		data.append(Vector4(
			randf(),                    # x position
			randf_range(0.05, 0.11),    # radius
			randf_range(0.4, 1.4),      # speed
			randf() * TAU               # phase
		))
	material.set_shader_parameter("blob_count", count)
	material.set_shader_parameter("blob_data", data)