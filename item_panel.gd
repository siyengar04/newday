extends PanelContainer

@export var placement_manager: PlacementManager

@export var chair_scene: PackedScene
@export var table_scene: PackedScene

@export var chair_button: Button
@export var table_button: Button
@export var cancel_button: Button

var _chair_btn: Button
var _table_btn: Button
var _cancel_btn: Button


func _ready() -> void:
	_chair_btn = chair_button if chair_button else get_node_or_null("%ChairButton") as Button
	_table_btn = table_button if table_button else get_node_or_null("%TableButton") as Button
	_cancel_btn = cancel_button if cancel_button else get_node_or_null("%CancelButton") as Button

	if _chair_btn:
		_chair_btn.pressed.connect(func(): _select_item(chair_scene, _chair_btn))
	else:
		push_warning("ItemPanel: ChairButton not found.")

	if _table_btn:
		_table_btn.pressed.connect(func(): _select_item(table_scene, _table_btn))
	else:
		push_warning("ItemPanel: TableButton not found.")

	if _cancel_btn:
		_cancel_btn.pressed.connect(_on_cancel)
	else:
		pass


func _select_item(scene: PackedScene, source_btn: Button) -> void:
	if placement_manager == null:
		push_error("ItemPanel: placement_manager is not assigned.")
		return
	if scene == null:
		push_error("ItemPanel: PackedScene not assigned.")
		return
	placement_manager.select_item_to_place(scene)
	_set_active_button(source_btn)


func _on_cancel() -> void:
	if placement_manager == null:
		return
	placement_manager.cancel_placement()
	placement_manager.select_placed_item(null)
	_set_active_button(null)


func _set_active_button(active: Button) -> void:
	for btn in [_chair_btn, _table_btn]:
		if btn == null:
			continue
		btn.set_pressed_no_signal(btn == active)
