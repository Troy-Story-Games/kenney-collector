extends Node

# Auto-load singleton to play game music

var song_path = "res://Music/songs/"

export(Dictionary) var music_dict := {
    "Menu": [
        load(song_path + "Man_Down.mp3")
    ],
    "Game": [
        load(song_path + "Deuces.mp3"),
        load(song_path + "Apero_Hour.mp3")
    ]
}

var music_list = null
var music_list_index := 0

onready var musicPlayer : AudioStreamPlayer = $AudioStreamPlayer


func _ready():
    randomize()


func play(category : String):
    musicPlayer.stop()
    music_list = music_dict[category].duplicate()
    music_list.shuffle()
    list_play()


func list_play():
    musicPlayer.stream = music_list[music_list_index]
    musicPlayer.play()
    music_list_index += 1
    if music_list_index == music_list.size():
        music_list.shuffle()
        music_list_index = 0


func list_stop():
    musicPlayer.stop()


func _on_AudioStreamPlayer_finished():
    list_play()
