extends Button

# Path to your game scene
@export var game_scene_path: String = "res://src/main.tscn"

func _ready():
	# Connect the button's pressed signal to a function
	pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	# Validate that the scene exists before loading
	if ResourceLoader.exists(game_scene_path):
		get_tree().change_scene_to_file(game_scene_path)
	else:
		push_error("Game scene not found at: " + game_scene_path)
