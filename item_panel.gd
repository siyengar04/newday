extends PanelContainer

@export var placement_manager: Node3D

@export var chair_scene: PackedScene
@export var table_scene: PackedScene

@export var chair_button: Button
@export var table_button: Button

func _ready() -> void:
	# Priority 1: Use exported button variables if assigned in Inspector
	# Priority 2: Fall back to Scene Unique Names (%ChairButton / %TableButton)
	var btn_chair: Button = chair_button if chair_button else get_node_or_null("%ChairButton") as Button
	var btn_table: Button = table_button if table_button else get_node_or_null("%TableButton") as Button

	if btn_chair:
		btn_chair.pressed.connect(func(): _select_item(chair_scene))
	else:
		push_warning("ChairButton not found via @export or %ChairButton unique name.")

	if btn_table:
		btn_table.pressed.connect(func(): _select_item(table_scene))
	else:
		push_warning("TableButton not found via @export or %TableButton unique name.")

func _select_item(scene: PackedScene) -> void:
	if not placement_manager:
		push_error("PlacementManager is not assigned on ItemPanel!")
		return
	if not scene:
		push_error("Item PackedScene is not assigned on ItemPanel!")
		return
		
	placement_manager.select_item_to_place(scene)
