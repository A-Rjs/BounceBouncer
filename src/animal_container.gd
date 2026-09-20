extends Node2D

var Player = preload("res://src/scenes/player.tscn")
var AnimalScene = preload("res://src/scenes/animal.tscn")
@onready var OBtn = $"UI/OutButton/StaticBody2D/Sprite2D"
@export var correct_sfx: AudioStreamPlayer
@export var incorrect_sfx: AudioStreamPlayer

var species_data = {
	"bunny": {
		"type": "prey"
	},
	"fox": {
		"type": "predators"
	},
	"bear" : {
		"type" : "predators"
	}
}

var hats = ["none", "red", "blue"]

var fashions = ["normal", "hime", "punk"]

var rules = []
# types of rules:
# ALLOW PREY, DISALLOW PREDATORS
# but DISALLOW X (red hAts)
# but ALLOW X (red hAts)

var active_animal = null
var plr = null

var day = 0
var time_left = 0
var rent = 0
var money = 0
var money_per_animal_correct = 5
var money_per_animal_wrong = -15
var ruleset = [
	[
		{
			"rule":"allow", 
			"type":"prey",
			"label" : "PREY\nONLY"
		}, 
		{
			"rule":"disallow",
			"type":"predators"
		}
	],
	[
		{
			"rule":"allow", 
			"type":"predators",
			"label" : "PREDATORS\nONLY"
		}, 
		{
			"rule":"disallow",
			"type":"prey"
		}
	],
	[
		{
			"rule":"allow", 
			"hat":"red",
			"label" : "REDCAPS\nONLY"
		}, 
		{
			"rule":"disallow",
			"hat":"none"
		}, 
		{
			"rule":"disallow",
			"hat":"blue"
		}
	],
	[
		{
			"rule":"disallow", 
			"hat":"red",
			"label" : "NO\nHATS"
		}, 
		{
			"rule":"allow",
			"hat":"none"
		}, 
		{
			"rule":"disallow",
			"hat":"blue"
		}
	],
	[
		{
			"rule":"disallow", 
			"hat":"red", 
			"label" : "bluecpas\nONly"
		}, 
		{
			"rule":"disallow",
			"hat":"none"
		}, 
		{
			"rule":"allow",
			"hat":"blue"
		}
	],
	[
		{
			"rule":"allow", 
			"hat":"red",
			"label" : "HATS\nREQUIRED"
		}, 
		{
			"rule":"disallow",
			"hat":"none"
		}, 
		{
			"rule":"allow",
			"hat":"blue"
		}
	],
	[
		{
			"rule":"allow", 
			"fashion":"punk",
			"label" : "punks\nonly"
		}, 
		{
			"rule":"disallow",
			"fashion":"hime"
		}, 
		{
			"rule":"disallow",
			"fashion":"normal"
		}
	],
	[
		{
			"rule":"disallow", 
			"fashion":"punk",
			"label" : "hime\nonly"
		}, 
		{
			"rule":"allow",
			"fashion":"hime"
		}, 
		{
			"rule":"disallow",
			"fashion":"normal"
		}
	],
	[
		{
			"rule":"allow", 
			"fashion":"punk", 
			"label" : "no normies\nallowed"
		}, 
		{
			"rule":"allow",
			"fashion":"hime"
		}, 
		{
			"rule":"disallow",
			"fashion":"normal"
		}
	],
	
]

func _ready() -> void:
	start_game()
func start_game():
	day = 0
	rent = 30
	money = 0
	#rules = [
		#{
			#"rule": "allow",
			#"type": "prey",
		#},
		#{
			#"rule": "disallow",
			#"type": "predators",
		#},
		#{
			#"rule": "dissallow",
			#"hat" : "blue"
		#},
		#{
			#"rule": "dissallow",
			#"hat" : "red"
		#}
		#,
		#{
			#"rule": "allow",
			#"hat" : "none"
		#}
	#]
	$"../UI/Rules".visible = false
	start_day()
func start_day():
	if day != 0:
		rent += 5
	rules = ruleset.pick_random()
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
	var hat = hats[randi_range(0, hats.size() - 1)]
	var fashion = fashions[randi_range(0, fashions.size() - 1)]
	var should_be_allowed_in = false
	
	for rule in rules:
		if rule.has('type') and rule.type != null and rule.type == species_data[species].type:
			should_be_allowed_in = rule.rule == "allow"
		if rule.has('hat') and rule.hat != null and rule.hat == hat:
			should_be_allowed_in = rule.rule == "allow"
		if rule.has('fashion') and rule.fashion != null and rule.fashion == fashion:
			should_be_allowed_in = rule.rule == "allow"
	
	scene.setup(species, hat, fashion, should_be_allowed_in)
	add_child(scene)
	
	active_animal = scene

func spawn_player():
	var player = Player.instantiate()
	add_child(player)
	plr = player
	plr.global_position = Vector2(1152/2,0)
	
func press_out():
	
	if active_animal == null:
		return
	
	if not active_animal.should_be_allowed_in:
		# correct
		money += money_per_animal_correct
		correct_sfx.play()
	else:
		money += money_per_animal_wrong
		incorrect_sfx.play()
	
	
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
		correct_sfx.play()
	else:
		money += money_per_animal_wrong
		incorrect_sfx.play()
	
	update_money()
	
	active_animal.enter_bar()
	if time_left > 0:
		spawn_animal()
	else:
		show_day_over_screen()


	


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
	$"../UI/Money".text = "$" + str(money)
func update_time():
	$"../UI/Time".text = "" + str(round(time_left) as int) + "s"

func update_rules():
	var rules_text = ""
	if rules[0].label != null:
		rules_text += rules[0].label.to_upper()
	#for rule in rules:
		#rules_text += "\n"
		#rules_text += rule.rule.to_upper() + " "
		#if rule.has('type') and rule.type!= null:
			#rules_text += rule.type.to_upper()
		#if rule.has('hat') and rule.hat!= null:
			#rules_text += rule.hat.to_upper()
		#if rule.has('fashion') and rule.fashion!= null:
			#rules_text += rule.fashion.to_upper()
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
	$"../UI/Rules".visible = true
	spawn_animal()
	spawn_player()
	time_left = 35
	update_time()
