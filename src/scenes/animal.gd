extends Sprite2D

var leaving = false
var move_to_target = false
var target_loc = Vector2(0, 0)


var species = "bunny"
var hat = "none"
var fashion = "normal"

var should_be_allowed_in = false

func setup(_species, _hat, _fashion, _should_be_allowed_in) -> void:
	species = _species
	hat = _hat
	fashion = _fashion
	should_be_allowed_in = _should_be_allowed_in
	$bod.texture = load("res://assets/art/species/" + species + "_species.png")
	$mod.texture = load("res://assets/art/fashion/" + fashion + "_fashion.png")
	$hat.texture = load("res://assets/art/hat/" + hat + "_hat.png")
	$Label.visible = false
	$Label.text = "s-" + species + " h-" + hat + " f-" + fashion + " in-" + str(should_be_allowed_in)
	
	move_onto_screen()

func _process(delta: float) -> void:
	if move_to_target:
		position += (target_loc - position) * 0.1 * delta * 45
		if (target_loc - position).length() < 2:
			if leaving:
				queue_free()

func move_onto_screen():
	position = Vector2(1250, 222)
	move_to_target = true
	target_loc = Vector2(540, 222)
	leaving = false

func move_enter_bar():
	move_to_target = true
	target_loc = Vector2(-240, 222)
	leaving = true

func move_exit_bar():
	$bod.texture = load("res://assets/art/species/" + species + "_species_out.png")
	move_to_target = true
	target_loc = Vector2(540, 640)
	leaving = true

func enter_bar():
	move_enter_bar()

func exit_bar():
	move_exit_bar()
