extends CharacterBody2D

var sprite : Sprite2D = null

const SPEED = 600.0
const BOUNCE_VELOCITY = -840.0

func _ready() -> void:
	sprite = $"Sprite2D"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_up"):
		#velocity.y = JUMP_VELOCITY
	if is_on_floor():
		velocity.y = BOUNCE_VELOCITY
	if Input.is_action_just_pressed("down"):
		velocity.y = 2000
	
	if velocity.y >= 150:
		sprite.region_rect.position.x = 800
	elif velocity.y >= -150:
		sprite.region_rect.position.x = 600
	elif velocity.y >= -400:
		sprite.region_rect.position.x = 400
	else:
		sprite.region_rect.position.x = 200

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED/1.5
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_pressed("left"):
		velocity.x -= 300 * delta * 60
	if Input.is_action_pressed("right"):
		velocity.x += 300 * delta * 60
	velocity.x *= 0.8
		
	if velocity.x < 0:
		sprite.flip_h = false;
	elif velocity.x > 0:
		sprite.flip_h = true;

	move_and_slide()
func die():
	queue_free()
