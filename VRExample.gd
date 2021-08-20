extends Spatial


func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false
		OS.vsync_enabled = false
		Engine.target_fps = 90
		# Physics FPS set to 90 in project setttings for smooth interactions
		# Tweak this back to the default of 60 if not making a VR game.
