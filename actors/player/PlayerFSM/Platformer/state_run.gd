extends State

func enterState():
	pass
func updateState(delta : float):
	movement(delta)
	
	if !PLAYER.is_on_floor():
		transition.emit(self, "Fall")
	
	if Input.is_action_just_pressed("dash") and PLAYER.has_skill("dash"):
		transition.emit(self, "Dash")
	
	if Input.is_action_just_pressed("move_up"):
		transition.emit(self, "Jump")

func movement(delta : float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0.0:
		var opposing = (direction > 0 and PLAYER.velocity.x < 0) or (direction < 0 and PLAYER.velocity.x > 0)
		
		if opposing:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.TURN_FRICTION * delta)
		elif PLAYER.use_fuel("move", delta):
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, direction * PLAYER.MAX_SPEED, PLAYER.ACCELERATION * delta)
		else:
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, direction * PLAYER.MAX_SPEED * 0.15, PLAYER.ACCELERATION * 0.3 * delta)
	else:
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.FRICTION * delta)
	
	if PLAYER.velocity.length() <= .1 and PLAYER.is_on_floor() and not direction:
		transition.emit(self, "Idle")
	
	PLAYER.move_and_slide()
