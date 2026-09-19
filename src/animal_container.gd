extends Node2D

var Player = preload("res://src/scenes/player.tscn")
var AnimalScene = preload("res://src/scenes/animal.tscn")

var species_data = {
	"bunny": {
		"type": "prey"
	},
	"fox": {
		"type": "predator"
	},
}

var rules = []
# types of rules:
# ALLOW PREY, DISALLOW PREDATORS
# but DISALLOW X (red hAts)
# but ALLOW X (red hAts)

var active_animal = null
var plr = null

var day = 0
var time_left = 0
var rent = 30
var money = 0
var money_per_animal_correct = 5
var money_per_animal_wrong = -15

func _ready() -> void:
	start_game()
func start_game():
	day = 0
	rent = 30
	money = 0
	rules = [
		{
			"rule": "allow",
			"type": "prey",
		},
		{
			"rule": "disallow",
			"type": "predators",
		}
	]
	start_day()
func start_day():
	if day != 0:
		rent += 5
	update_money()
	update_time()
	update_rules()
	$"../UI/DayOverScreen".visible = false
	$"../UI/DayStartScreen".visible = true
	$"../UI/DayStartScreen/Label".text = "Day " + str(day + 1)
	$"../UI/DayStartScreen/Label2".text = "Rent Increased to $" + str(rent)
func _process(delta: float) -> void:
	time_left -= delta
	if time_left < 0:
		time_left = 0
	update_time()

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

func spawn_player():
	var player = Player.instantiate()
	add_child(player)
	plr = player
	
func press_out():
	if active_animal == null:
		return
	
	if not active_animal.should_be_allowed_in:
		# correct
		money += money_per_animal_correct
	else:
		money += money_per_animal_wrong
	
	update_money()
	
	active_animal.exit_bar()
	if time_left > 0:
		spawn_animal()
	else:
		show_day_over_screen()

func press_in():
	if active_animal == null:
		return
	
	if active_animal.should_be_allowed_in:
		# correct
		money += money_per_animal_correct
	else:
		money += money_per_animal_wrong
	
	update_money()
	
	active_animal.enter_bar()
	if time_left > 0:
		spawn_animal()
	else:
		show_day_over_screen()

func _on_in_button_button_down() -> void:
	press_in()
	
func _on_out_button_button_down() -> void:
	press_out()
	


func show_day_over_screen():
	$"../UI/DayOverScreen".visible = true
	if money >= rent:
		$"../UI/DayOverScreen/Label".text = "Day " + str(day + 1) + " Over"
		$"../UI/DayOverScreen/Button".text = "Pay Rent ($" + str(rent) + ")"
		plr.die()
	else:
		$"../UI/DayOverScreen/Label".text = "Game Over (Day " + str(day + 1) + ")"
		$"../UI/DayOverScreen/Button".text = "Restart"
		plr.die()
func update_money():
	$"../UI/Money".text = "Money: " + str(money) + "€"
func update_time():
	$"../UI/Time".text = "Time: " + str(round(time_left) as int) + "s"	
func update_rules():
	var rules_text = "RULES:"
	for rule in rules:
		rules_text += "\n"
		rules_text += rule.rule.to_upper() + " "
		if rule.type != null:
			rules_text += rule.type.to_upper()
	$"../UI/Rules".text = rules_text
func _on_button_button_down() -> void:
	if money < rent:
		start_game()
	else:
		money -= rent
		day += 1
		start_day()


func _on_in_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	press_in()


func _on_out_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	press_out()


func _on_button_button2_down() -> void:
	$"../UI/DayStartScreen".visible = false
	spawn_animal()
	spawn_player()
	time_left = 35
	update_time()
