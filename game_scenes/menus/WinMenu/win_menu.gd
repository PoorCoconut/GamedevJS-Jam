extends Control

@export_file("*.tscn") var next_level_path : String
var input : bool = false

func _unhandled_input(_event: InputEvent) -> void:
	if not input:
		GameManager.load_next_level(next_level_path)
		input = true
