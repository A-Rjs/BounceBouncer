extends Node2D

var AnimalScene = preload("res://src/scenes/animal.tscn")

var species_data = {
	"bunny": {
		"type": "prey"
	},
	"fox": {
		"type": "predator"
	},
}

var rules = [
	{
		"rule": "allow",
		"type": "prey",
	},
	{
		"rule": "disallow",
		"type": "predator",
	}
]
# types of rules:
# ALLOW PREY, DISALLOW PREDATORS
# but DISALLOW X (red hAts)
# but ALLOW X (red hAts)

var active_animal = null

var money = 0

func _ready() -> void:
	spawn_animal()

func spawn_animal():
	var scene = AnimalScene.instantiate()
	var species = species_data.keys()[randi_range(0, species_data.keys().size() - 1)]
	var should_be_allowed_in = false
	
	for rule in rules:
		if rule.type != null and rule.type == species_data[species].type:
			should_be_allowed_in = rule.rule == "allow"
	
	scene.setup(species, should_be_allowed_in)
	add_child(scene)
	
	active_animal = scene

func _on_in_button_button_down() -> void:
	if active_animal == null:
		return
	
	if active_animal.should_be_allowed_in:
		# correct
		money += 1
	else:
		money -= 1
	
	update_money()
	
	active_animal.enter_bar()
	spawn_animal()

func _on_out_button_button_down() -> void:
	if active_animal == null:
		return
	
	if not active_animal.should_be_allowed_in:
		# correct
		money += 1
	else:
		money -= 1
	
	update_money()
	
	active_animal.exit_bar()
	spawn_animal()

func update_money():
	$"../UI/Money".text = "Money: " + str(money)
