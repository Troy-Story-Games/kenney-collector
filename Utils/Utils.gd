extends Node

var interface: XRInterface
var vr_initialized := false
var mobile_vr := false
var mobile_vr_runtime_initialized := false
var kenney_assets : Array = []


func initialize_vr():
	if vr_initialized:
		return
	
	Engine.max_fps = 90
	Engine.physics_ticks_per_second = 90
	
	interface = XRServer.find_interface("OpenXR")
	if interface:
		interface.initialize()
	
	if interface and interface.is_initialized():
		print("OpenXR initialized successfully")
	
		# Turn off v-sync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
		# Tell the viewport to use XR
		get_viewport().use_xr = true

	load_kenney_assets()
	vr_initialized = true


func load_kenney_assets():
	# Load the kenney assets
	kenney_assets = []
	var kenney_asset_dir = DirAccess.open("res://Objects/CrateContents")
	kenney_asset_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var asset = kenney_asset_dir.get_next()
	while asset != "":
		kenney_assets.append(load("res://Objects/CrateContents/" + asset))
		asset = kenney_asset_dir.get_next()


func get_random_kenney_asset() -> PackedScene:
	kenney_assets.shuffle()
	return kenney_assets[0]


func instance_scene_on_main(packed_scene: PackedScene, position) -> Node:
	var main := get_tree().current_scene
	var instance : Node3D = packed_scene.instantiate()
	main.add_child(instance)

	if position is Transform3D:
		instance.global_transform = position
	elif position is Vector3:
		instance.global_transform.origin = position

	return instance


func get_main_instances() -> Resource:
	return ResourceLoader.load("res://Utils/MainInstances.tres")


func get_player_stats() -> Resource:
	return ResourceLoader.load("res://Player/PlayerStats.tres")
