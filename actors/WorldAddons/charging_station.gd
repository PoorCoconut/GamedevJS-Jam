extends Area2D

@export var REFUEL_RATE : float = 40.0

var player_in_range : Player = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if player_in_range:
		player_in_range.refuel(REFUEL_RATE * delta)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		%Smoke.emitting = true
		player_in_range = body

func _on_body_exited(body: Node) -> void:
	if body is Player:
		%Smoke.emitting = false
		player_in_range = null
