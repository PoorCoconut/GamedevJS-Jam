extends CharacterBody2D
class_name Player

@export_category("PLAYER MOVEMENT")
@export var MAX_SPEED : float = 75
@export var ACCELERATION : float = 25
@export var FRICTION : float = 5

var CUR_DIR : Vector2

@export var MAX_FUEL : float = 100.0
var fuel : float = MAX_FUEL

const FUEL_JUMP_DRAIN : float = 15.0
const FUEL_MOVE_DRAIN : float = 8.0

@export var JUMP_VELOCITY : float = -50
@export var GRAVITY : float = 175
const JUMP_MAX_DURATION = 0.8
var jump_timer : float = 0.0
const TURN_FRICTION = 40.0
const JUMP_MAX_VELOCITY = -200.0
const JUMP_ACCELERATION = 250.0
const AIR_FRICTION = 80.0

const FUEL_COST = {
	"jump":     15.0,
	"move":     8.0,
	"dash":     25.0,
	"grapple":  20.0,
	"instant":  30.0
}

var skills = {
	"dash":     false,
	"grapple":  false,
	"instant":  false,
}

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

func unlock_skill(skill: String) -> void:
	if skills.has(skill):
		skills[skill] = true
		print("Skill unlocked: ", skill)
	else:
		print("Unknown skill: ", skill)

func has_skill(skill: String) -> bool:
	return skills.get(skill, false)

func use_fuel(action: String, delta: float) -> bool:
	if not FUEL_COST.has(action):
		return true
	
	if fuel <= 0:
		return false
	
	fuel = max(fuel - FUEL_COST[action] * delta, 0)
	return true

func has_fuel() -> bool:
	return fuel > 0

func refuel(amount: float) -> void:
	fuel = min(fuel + amount, MAX_FUEL)
