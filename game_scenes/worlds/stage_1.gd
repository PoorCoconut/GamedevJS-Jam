extends Node2D

@export_file("*.tscn") var next_level_path : String


func _on_area_2d_body_entered(body: Node2D) -> void:
	GameManager.load_next_level(next_level_path)
