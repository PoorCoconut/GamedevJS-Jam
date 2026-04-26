extends State

var dash_speed : float = 0.0
var dash_accel : float = 0.0
var dash_direction : float = 1.0
var bursting : bool = false
var burst_timer : float = 0.0

const DASH_SPEED_MULTIPLIER : float = 5.0
const DASH_ACCEL_MULTIPLIER : float = 8.0
const DASH_DECAY : float = 40.0
const BURST_DURATION : float = 0.12

func enterState():
	if not PLAYER.has_skill("dash"):
		transition.emit(self, "Idle")
		return
	
	if not PLAYER.use_fuel_flat("dash"):
		transition.emit(self, "Idle")
		return
	
	dash_direction = sign(PLAYER.velocity.x) if PLAYER.velocity.x != 0 else sign(PLAYER.scale.x)
	dash_speed = PLAYER.MAX_SPEED * DASH_SPEED_MULTIPLIER
	dash_accel = PLAYER.ACCELERATION * DASH_ACCEL_MULTIPLIER
	bursting = true
	burst_timer = 0.0

func updateState(delta : float):
	if bursting:
		burst_timer += delta
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, dash_direction * dash_speed, dash_accel * delta)
		
		if burst_timer >= BURST_DURATION:
			bursting = false
	else:
		# Decay phase — bleed back to normal
		dash_speed = move_toward(dash_speed, PLAYER.MAX_SPEED, DASH_DECAY * delta)
		dash_accel = move_toward(dash_accel, PLAYER.ACCELERATION, DASH_DECAY * delta)
		movement(delta)
	
	PLAYER.move_and_slide()
	
	if not PLAYER.is_on_floor():
		transition.emit(self, "Fall")
	
	if Input.is_action_just_pressed("move_up"):
		transition.emit(self, "Jump")
	
	if not bursting and dash_speed <= PLAYER.MAX_SPEED and dash_accel <= PLAYER.ACCELERATION:
		transition.emit(self, "Run")

func movement(delta : float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0.0:
		var opposing = (direction > 0 and PLAYER.velocity.x < 0) or (direction < 0 and PLAYER.velocity.x > 0)
		
		if opposing:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.TURN_FRICTION * delta)
		elif PLAYER.use_fuel("move", delta):
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, dash_direction * dash_speed, dash_accel * delta)
		else:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, dash_direction * dash_speed * 0.15, dash_accel * 0.15 * delta)
	else:
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.FRICTION * 0.1 * delta)
	
	if PLAYER.velocity.length() <= .1 and PLAYER.is_on_floor() and not direction:
		transition.emit(self, "Idle")
