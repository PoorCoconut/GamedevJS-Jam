extends Node

var CURRENT_WORLD_STATE : String = "Nothing"
const SAVE_PATH : String = "user://savegame.json"

#Environmental Variables
var wind_speed : float = 100.0

func _ready() -> void:
	print("GAME MANAGER LOADED!")


##SAVE FILE LOGIC
func save_player_data(player_pos: Vector2, player_fuel: float) -> void:
	var save_data = {
		"player_x": player_pos.x,
		"player_y": player_pos.y,
		"fuel": player_fuel
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	print("Game Saved!")

func load_player_data():
	# Check if the player has ever saved the game before
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting from the bottom!")
		return null 
		
	# Open the file and read the text
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()
	
	# Parse the JSON back into a dictionary
	var save_data = JSON.parse_string(json_text)
	
	# Extract the coordinates and fuel, then return them as a dictionary
	if save_data and save_data.has("player_x") and save_data.has("player_y") and save_data.has("fuel"):
		var loaded_pos = Vector2(save_data["player_x"], save_data["player_y"])
		var loaded_fuel = float(save_data["fuel"]) # Cast to float just to be safe
		
		print("Save loaded! Teleporting player to: ", loaded_pos)
		
		return {
			"position": loaded_pos,
			"fuel": loaded_fuel
		}
	
	print("Something weird happened! Player data not loaded.")
	return null

##Next Level Helper Functions
func load_next_level(next_level_path : String) -> void:
	await ScreenTransition.trans_in().finished
	LoadingScreen.load_level(next_level_path)

##Camera Helper Functions
func do_camera_shake(intensity:float, time:float):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		var camera_tween = get_tree().create_tween()
		camera_tween.tween_method(camera.startCameraShake, intensity, 1.0, time)
		camera.startCameraShake(intensity)
		await get_tree().create_timer(time).timeout
		camera.resetCameraOffset()

func move_camera_to_player(player_pos : Vector2):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		camera.moveCameraToEntity(player_pos)
