extends Node

const SAVE_FILE := "user://rotation_station_save_data.json"

var custom_data := {
	"version": "0.0.1",
	"high_score": 0
}


func save_game():
	var save_game = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	save_game.store_line(JSON.new().stringify(custom_data))
	save_game.close()


func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return

	var save_game = FileAccess.open(SAVE_FILE, FileAccess.READ)

	if not save_game.eof_reached():
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_game.get_line())
		custom_data = test_json_conv.get_data()

	save_game.close()
