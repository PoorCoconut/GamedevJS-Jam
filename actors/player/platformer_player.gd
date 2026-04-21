extends Player
class_name PlayerPlatformer

@export var MAX_FUEL : float = 100.0
var fuel : float = MAX_FUEL

const FUEL_JUMP_DRAIN : float = 15.0
const FUEL_MOVE_DRAIN : float = 8.0

@export var JUMP_VELOCITY : float = -50
@export var GRAVITY : float = 300
const TURN_FRICTION = 67.0
const JUMP_MAX_VELOCITY = -320.0
const JUMP_ACCELERATION = 225.0
const AIR_FRICTION = 169.0

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
