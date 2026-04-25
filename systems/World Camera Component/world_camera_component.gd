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

var cameraShakeNoise : FastNoiseLite
var viewport_width : float
var viewport_height : float

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

	var target_lookahead = Vector2.ZERO
	
	#Horizontal
	if target.velocity.x > 10:
		target_lookahead.x = lookahead_distance.x
	elif target.velocity.x < -10:
		target_lookahead.x = -lookahead_distance.x
		
	#Vertical
	if target.velocity.y > 10: # Falling down
		target_lookahead.y = lookahead_distance.y
	elif target.velocity.y < -10: # Jumping up
		target_lookahead.y = -lookahead_distance.y
		
	current_lookahead.x = lerpf(current_lookahead.x, target_lookahead.x, delta * lookahead_speed)
	current_lookahead.y = lerpf(current_lookahead.y, target_lookahead.y, delta * lookahead_speed)
	
	var target_pos = focus_position + current_lookahead

	var half_w = (viewport_width / 2.0) / zoom.x
	var half_h = (viewport_height / 2.0) / zoom.y
	
	target_pos.x = clamp(target_pos.x, target_limit_left + half_w, target_limit_right - half_w)
	target_pos.y = clamp(target_pos.y, target_limit_top + half_h, target_limit_bottom - half_h)

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
