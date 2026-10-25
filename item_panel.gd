extends GridContainer

@export var placement_manager: Node3D

@export var chair_scene: PackedScene
@export var table_scene: PackedScene

func _ready() -> void:
	$ChairButton.pressed.connect(func(): placement_manager.select_item_to_place(chair_scene))
	$TableButton.pressed.connect(func(): placement_manager.select_item_to_place(table_scene))
