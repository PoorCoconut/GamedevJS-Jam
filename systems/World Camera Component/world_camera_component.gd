extends Camera2D

enum CameraMode { 
	##The Camera is fixed in a room. When the target moves out of the room, it moves 1 "room" towards the target's direction.
	ROOM_BASED , 
	##The Camera is fixed to the target. If your room has a CameraLimitZoneCompnent, the camera will automatically stop following when it reaches its limit.
	ENTITY_ATTACHED,
	##The Camera behaves like an ENTITY_BASED + ROOM_BASED fusion. Good for platformers.
	PLATFORMER 
}
##Camera Mode Options
@export var camera_mode: CameraMode = CameraMode.ENTITY_ATTACHED
@export var target : CharacterBody2D
@export var following : bool = true

@export_group("Platformer Settings")
## How far the camera looks ahead in the facing direction
@export var lookahead_distance: Vector2 = Vector2(60.0, 40.0) 
## How fast the camera shifts its lookahead
@export var lookahead_speed: float = 3.0
## The box where the player can move without moving the camera anchor
@export var deadzone_size: Vector2 = Vector2(30, 20)
## How fast the camera catches up to the target and glides between rooms
@export var camera_speed: float = 5.0

##How far the player must move UP before the camera commits to looking up
@export var vertical_shift_threshold: float = 80.0
##How many seconds the player must fall before the camera commits to looking down
@export var fall_time_threshold: float = 0.4

var cameraShakeNoise : FastNoiseLite
var viewport_width : float
var viewport_height : float

var vertical_anchor_y: float
var fall_timer: float = 0.0
var target_lookahead_y: float = 0.0

# Platformer State Variables
var focus_position: Vector2
var current_lookahead: Vector2

# Target limits for smooth gliding
var target_limit_left: float = -10000000
var target_limit_right: float = 10000000
var target_limit_top: float = -10000000
var target_limit_bottom: float = 10000000

func _ready() -> void:
	viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	cameraShakeNoise = FastNoiseLite.new()
	
	if target:
		focus_position = target.global_position
		global_position = target.global_position
		vertical_anchor_y = target.global_position.y
	
	if camera_mode == CameraMode.ROOM_BASED:
		anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	else:
		anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
		
	# Disable native smoothing for platformer mode so our custom glide lerp takes priority
	if camera_mode == CameraMode.PLATFORMER:
		position_smoothing_enabled = false

func _process(delta: float) -> void:
	if following and target != null:
		# Pass delta to update functions for smooth lerping
		_update_camera_position(delta)

func _update_camera_position(delta: float) -> void:
	match camera_mode:
		CameraMode.ROOM_BASED:
			moveCameraToEntity(target.global_position)
		CameraMode.ENTITY_ATTACHED:
			global_position = target.global_position
		CameraMode.PLATFORMER:
			_update_platformer_camera(delta)

func _update_platformer_camera(delta: float) -> void:
	#Camera Deadzone
	var dist_x = target.global_position.x - focus_position.x
	if abs(dist_x) > deadzone_size.x:
		focus_position.x += dist_x - (sign(dist_x) * deadzone_size.x)
		
	var dist_y = target.global_position.y - focus_position.y
	if abs(dist_y) > deadzone_size.y:
		focus_position.y += dist_y - (sign(dist_y) * deadzone_size.y)

	#Horizontal Lookahead (Velocity Based)
	var target_lookahead_x = 0.0
	if target.velocity.x > 10:
		target_lookahead_x = lookahead_distance.x
	elif target.velocity.x < -10:
		target_lookahead_x = -lookahead_distance.x

	#Vertical Lookahead (State Based)
	var y_diff = target.global_position.y - vertical_anchor_y

	#Track how long the player has been falling
	if target.velocity.y > 0 and not target.is_on_floor():
		fall_timer += delta
	else:
		fall_timer = 0.0

	#Climbing: Check if player moved significantly UP from the anchor
	if y_diff < -vertical_shift_threshold:
		target_lookahead_y = -lookahead_distance.y
		vertical_anchor_y = target.global_position.y # Drag the anchor up with them
		
	#Falling: Check if player has fallen for a sustained time
	elif fall_timer > fall_time_threshold:
		target_lookahead_y = lookahead_distance.y
		vertical_anchor_y = target.global_position.y # Sync anchor so it doesn't snap later

	#Grounded Reset: Slowly normalize the camera if running flat
	if target.is_on_floor():
		#Pull the anchor back to the player's feet
		vertical_anchor_y = lerpf(vertical_anchor_y, target.global_position.y, delta * 3.0)
		
		#If the anchor has caught up to the player, slowly recenter the Y lookahead
		if abs(target.global_position.y - vertical_anchor_y) < 5.0:
			target_lookahead_y = lerpf(target_lookahead_y, 0.0, delta * 2.0)

	#Apply the smooth lerp to current lookaheads
	current_lookahead.x = lerpf(current_lookahead.x, target_lookahead_x, delta * lookahead_speed)
	current_lookahead.y = lerpf(current_lookahead.y, target_lookahead_y, delta * lookahead_speed)
	
	var target_pos = focus_position + current_lookahead

	#Apply Room Limits Manually to the Target Position
	var half_w = (viewport_width / 2.0) / zoom.x
	var half_h = (viewport_height / 2.0) / zoom.y
	
	target_pos.x = clamp(target_pos.x, target_limit_left + half_w, target_limit_right - half_w)
	target_pos.y = clamp(target_pos.y, target_limit_top + half_h, target_limit_bottom - half_h)

	#Smoothly Glide
	global_position = global_position.lerp(target_pos, delta * camera_speed)

func apply_room_limits(left: int, right: int, top: int, bottom: int) -> void:
	if camera_mode == CameraMode.PLATFORMER:
		target_limit_left = left
		target_limit_right = right
		target_limit_top = top
		target_limit_bottom = bottom
		
		limit_left = -10000000
		limit_right = 10000000
		limit_top = -10000000
		limit_bottom = 10000000
	else:
		limit_left = left
		limit_right = right
		limit_top = top
		limit_bottom = bottom

func moveCameraToEntity(entity_global_pos : Vector2):
	var grid_x = floor(entity_global_pos.x / viewport_width)
	var grid_y = floor(entity_global_pos.y / viewport_height)
	
	global_position.x = grid_x * viewport_width
	global_position.y = grid_y * viewport_height

func startCameraShake(intensity:float):
	var time = Time.get_ticks_msec()
	offset.x = cameraShakeNoise.get_noise_1d(time) * intensity
	offset.y = cameraShakeNoise.get_noise_1d(time + 10000) * intensity

func resetCameraOffset():
	offset.x = 0
	offset.y = 0
