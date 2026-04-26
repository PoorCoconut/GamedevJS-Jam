extends CanvasLayer

@onready var WhiteBar = %WhiteBar
@onready var BarChaser = %BarChaser
var style

var target_fuel: float = 0.0
var chase_speed: float = 30.0 

var hang_timer: float = 0.0
var hang_duration: float = 0.4 

var is_initialized: bool = false 

func _ready():
	style = WhiteBar.get_theme_stylebox("fill") as StyleBoxFlat
	Events.player_fuel_updated.connect(_on_player_fuel_updated)

func _on_player_fuel_updated(current_fuel: float, max_fuel: float):
	WhiteBar.max_value = max_fuel
	BarChaser.max_value = max_fuel
	target_fuel = current_fuel
	
	style.bg_color = Color.RED.lerp(Color.CYAN, target_fuel / max_fuel)
	if not is_initialized:
		WhiteBar.value = current_fuel
		BarChaser.value = current_fuel
		is_initialized = true
		return
	
	#Draining
	if target_fuel < WhiteBar.value:
		WhiteBar.value = target_fuel
		hang_timer = hang_duration
		
	#Refueling
	elif target_fuel > BarChaser.value:
		BarChaser.value = target_fuel

func _process(delta: float):
	if hang_timer > 0:
		hang_timer -= delta
		return
		
	if BarChaser.value > target_fuel:
		BarChaser.value = move_toward(BarChaser.value, target_fuel, chase_speed * delta)
			
	elif WhiteBar.value < target_fuel:
		WhiteBar.value = move_toward(WhiteBar.value, target_fuel, chase_speed * delta)
