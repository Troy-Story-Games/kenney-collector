tool
extends StaticBody
class_name GUIPanel

onready var viewport = $Viewport
onready var meshInstance = $MeshInstance
# warning-ignore:unused_class_variable
onready var collisionShape = $CollisionShape


func _ready():
    # Get the viewport and wait two frames
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")

    # Get the texture
    var gui_img = viewport.get_texture()

    # Make a new material and set the viewport texture as the texture, then set
    # the material for this MeshInstance to the newly created material.
    var material = SpatialMaterial.new()
    material.flags_unshaded = true
    material.albedo_texture = gui_img
    meshInstance.set_surface_material(0, material)
