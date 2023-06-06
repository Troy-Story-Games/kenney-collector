@tool
extends StaticBody3D
class_name GUIPanel

@onready var viewport = $SubViewport
@onready var meshInstance = $MeshInstance3D
# warning-ignore:unused_class_variable
@onready var collisionShape = $CollisionShape3D


func _ready():
	# Get the texture
	var gui_img = viewport.get_texture()

	# Make a new material and set the viewport texture as the texture, then set
	# the material for this MeshInstance to the newly created material.
	var material = StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_texture = gui_img
	meshInstance.set_surface_override_material(0, material)
