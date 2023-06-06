extends StaticBody3D
class_name InfoScreen

@onready var introUI = $IntroUI3D
@onready var scoreUI = $ScoreUI3D


func toggle():
	introUI.visible = !introUI.visible
	scoreUI.visible = !scoreUI.visible
