extends Line2D

@export var max_flag_length: float = 40.0
@export var segments: int = 10
@export var gravity: float = 20.0
@export var max_wave_amplitude: float = 4.0
@export var max_wave_speed: float = 12.0
@export var max_wind_reference: float = 100.0

# Array to store the delayed wind value for each individual point
var point_winds: Array[float] = [] 
var time_passed: float = 0.0

@onready var visibility_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier

#Testing purposes...
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		GameManager.wind_speed = lerp(GameManager.wind_speed, GameManager.wind_speed - 50, 1)
	elif Input.is_action_just_pressed("move_right"):
		GameManager.wind_speed = lerp(GameManager.wind_speed, GameManager.wind_speed + 50, 1)
	print(GameManager.wind_speed)

func _ready():
	time_passed = randf() * 100 #This makes it so that flag props don't synchronize with each other
	
	clear_points()
	for i in range(segments):
		add_point(Vector2.ZERO)
		point_winds.append(0.0)

func _process(delta):
	if not visibility_notifier.is_on_screen():
		return
		
	var target_wind = GameManager.wind_speed 
	
	point_winds[0] = lerpf(point_winds[0], target_wind, delta * 2.0)
	for i in range(1, segments):
		point_winds[i] = lerpf(point_winds[i], point_winds[i-1], delta * 10.0)
	
	# Use the head's wind intensity for scaling the visuals
	var wind_intensity = clamp(abs(point_winds[0]) / max_wind_reference, 0.0, 1.0)
	
	var current_length = lerpf(max_flag_length * 0.4, max_flag_length, wind_intensity)
	var current_amplitude = lerpf(0.5, max_wave_amplitude, wind_intensity)
	var current_speed = lerpf(2.0, max_wave_speed, wind_intensity)

	time_passed += delta * current_speed
	var segment_dist = current_length / segments

	set_point_position(0, Vector2.ZERO)
	var current_base_pos = Vector2.ZERO

	for i in range(1, segments):
		var t = float(i) / float(segments - 1)
		
		#Calculate direction uniquely for THIS specific segment
		var flag_vector = Vector2(point_winds[i], gravity)
		if flag_vector.length() == 0:
			flag_vector = Vector2(0, 1) 
			
		var normalized_dir = flag_vector.normalized()
		
		#Build the position cumulatively from the previous segment's base position
		current_base_pos += normalized_dir * segment_dist
		
		var flutter_offset = sin(time_passed - (i * 1.2)) * (current_amplitude * t)
		var perpendicular = Vector2(-normalized_dir.y, normalized_dir.x)
		
		#Apply flutter to the final render position, but keep the base position clean for the next loop
		var final_pos = current_base_pos + (perpendicular * flutter_offset)
		set_point_position(i, final_pos)
