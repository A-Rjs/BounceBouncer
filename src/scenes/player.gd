extends CharacterBody2D


const SPEED = 600.0
const JUMP_VELOCITY = -400.0
const BOUNCE_VELOCITY = -750.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_up"):
		#velocity.y = JUMP_VELOCITY
	if is_on_floor():
		velocity.y = BOUNCE_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
func die():
	queue_free()
