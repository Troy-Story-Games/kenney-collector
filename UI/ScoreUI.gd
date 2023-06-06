extends Control

var playerStats = Utils.get_player_stats()
var viewport : SubViewport = null

@onready var scoreLabel = $CenterContainer/VBoxContainer/HBoxContainer/CenterContainer2/ScoreLabel
@onready var highScoreLabel = $CenterContainer/VBoxContainer/HighScoreLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	playerStats.connect("score_changed", Callable(self, "_on_PlayerStats_score_changed"))
	playerStats.connect("high_score_changed", Callable(self, "_on_PlayerStats_high_score_changed"))
	viewport = get_parent()
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER


func _on_PlayerStats_score_changed(result):
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	scoreLabel.text = str(result)


func _on_PlayerStats_high_score_changed(result):
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	highScoreLabel.text = "HIGH SCORE: " + str(result)
