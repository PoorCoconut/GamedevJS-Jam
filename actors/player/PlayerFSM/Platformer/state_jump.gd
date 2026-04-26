extends State
func enterState():
	SoundBank.play_global_sfx("button")
	PLAYER.velocity.y = PLAYER.JUMP_VELOCITY
	PLAYER.jump_timer = 0.0
	PLAYER.velocity.x *= 0.5

func updateState(delta : float):
	if Input.is_action_pressed("move_up") and PLAYER.jump_timer < PLAYER.JUMP_MAX_DURATION:
		PLAYER.jump_timer += delta
		if PLAYER.use_fuel("jump", delta):
			PLAYER.velocity.y = move_toward(PLAYER.velocity.y, PLAYER.JUMP_MAX_VELOCITY, PLAYER.JUMP_ACCELERATION * delta)
		else:
			PLAYER.velocity.y = move_toward(PLAYER.velocity.y, PLAYER.JUMP_MAX_VELOCITY * 0.15, PLAYER.JUMP_ACCELERATION * 0.1 * delta)
	
	if Input.is_action_just_released("move_up") and PLAYER.velocity.y < 0:
		PLAYER.velocity.y *= 0.5
	
	if PLAYER.is_on_ceiling():
		PLAYER.velocity.y = 1
	
	movement(delta)
	PLAYER.move_and_slide()
	
	if PLAYER.velocity.y > 0 and not PLAYER.is_on_floor():
		transition.emit(self, "Fall")

func movement(delta : float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0.0:
		var opposing = (direction > 0 and PLAYER.velocity.x < 0) or (direction < 0 and PLAYER.velocity.x > 0)
		
		if opposing:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.TURN_FRICTION * delta)
		elif PLAYER.use_fuel("move", delta):
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, direction * PLAYER.MAX_SPEED, PLAYER.ACCELERATION * delta)
		else:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, direction * PLAYER.MAX_SPEED * 0.15, PLAYER.ACCELERATION * 0.15 * delta)
	else:
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.AIR_FRICTION * delta)
	
	PLAYER.move_and_slide()
