extends Node

const SAVE_FILE := "user://rotation_station_save_data.json"

var custom_data := {
    "version": "0.0.1",
    "high_score": 0
}


func save_game():
    var save_game := File.new()
    # warning-ignore:return_value_discarded
    save_game.open(SAVE_FILE, File.WRITE)
    save_game.store_line(to_json(custom_data))
    save_game.close()


func load_game():
    var save_game := File.new()
    if not save_game.file_exists(SAVE_FILE):
        return

    # warning-ignore:return_value_discarded
    save_game.open(SAVE_FILE, File.READ)

    if not save_game.eof_reached():
        custom_data = parse_json(save_game.get_line())

    save_game.close()
