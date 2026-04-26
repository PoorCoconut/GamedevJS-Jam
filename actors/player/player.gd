extends CharacterBody2D
class_name Player

@export_category("PLAYER MOVEMENT")
@export var MAX_SPEED : float = 75
@export var ACCELERATION : float = 25
@export var FRICTION : float = 5
@export var TURN_FRICTION : float = 40.0
@export var AIR_FRICTION : float = 80.0

@export_category("JUMP")
@export var JUMP_VELOCITY : float = -50
@export var JUMP_MAX_VELOCITY : float = -200.0
@export var JUMP_ACCELERATION : float = 250.0
@export var JUMP_MAX_DURATION : float = 0.6
var jump_timer : float = 0.0

@export_category("GRAVITY")
@export var GRAVITY : float = 175

@export_category("FUEL")
@export var MAX_FUEL : float = 250.0
var fuel : float = MAX_FUEL
const FUEL_COST = {
	"jump":    15.0,
	"move":    8.0,
	"dash":    25.0,
	"grapple": 20.0,
	"instant": 30.0
}

var skills = {
	"dash":    true,
	"grapple": false,
	"instant": false,
}

var CUR_DIR : Vector2

func _ready() -> void:
	Events.player_fuel_updated.emit(fuel, MAX_FUEL)

func _physics_process(delta: float) -> void:
	if velocity.x != 0:
		$Sprite.flip_h = velocity.x < 0
	
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
	Events.player_fuel_updated.emit(fuel, MAX_FUEL)
	return true

func use_fuel_flat(action: String) -> bool:
	if not FUEL_COST.has(action):
		return true
	if fuel <= 0:
		return false
	fuel = max(fuel - FUEL_COST[action], 0)
	Events.player_fuel_updated.emit(fuel, MAX_FUEL)
	return true

func has_fuel() -> bool:
	return fuel > 0

func refuel(amount: float) -> void:
	fuel = min(fuel + amount, MAX_FUEL)
	Events.player_fuel_updated.emit(fuel, MAX_FUEL)
