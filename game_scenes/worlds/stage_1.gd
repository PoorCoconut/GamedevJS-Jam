extends Node2D

@export var PLAYER : Player

func _ready() -> void:
	PLAYER.global_position = GameManager.load_player_position()
