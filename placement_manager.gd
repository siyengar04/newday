class_name PlacementManager
extends Node3D

@export var grid_size: float = 1.0
@export var floor_collision_mask: int = 2  # Layer 2 = Floor
@export var furniture_collision_mask: int = 1  # Layer 1 = Furniture
@export var furniture_container: Node3D

var current_item: FurnitureItem = null
var current_scene: PackedScene = null
var current_rotation_step: int = 0
var selected_item: FurnitureItem = null


func _unhandled_input(event: InputEvent) -> void:
	var hovered_control := get_viewport().gui_get_hovered_control()
	if hovered_control != null and hovered_control.is_visible_in_tree():
		return

	if current_item != null:
		_handle_placement_input(event)
	else:
		_handle_select_input(event)


func _handle_placement_input(event: InputEvent) -> void:
	if event.is_action_pressed("item_place_rotate") \
			or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed):
		rotate_current_item(1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		rotate_current_item(-1)

	if event.is_action_pressed("item_place"):
		try_place_current_item()
	elif event.is_action_pressed("item_place_cancel"):
		cancel_placement()


func _handle_select_input(event: InputEvent) -> void:
	if event.is_action_pressed("item_place"):  # left click in select mode = select
		var hit := raycast_furniture()
		select_placed_item(hit)
	elif event.is_action_pressed("item_place_cancel"):
		select_placed_item(null)
	elif event.is_action_pressed("item_rotate") and selected_item != null:
		selected_item.rotate_y(PI / 2.0)
	elif event.is_action_pressed("item_delete") and selected_item != null:
		_delete_selected()


func _process(_delta: float) -> void:
	if current_item == null:
		return
	var hit_pos = get_floor_mouse_position()
	if hit_pos != null:
		current_item.global_position = snap_to_grid(hit_pos)
		_update_ghost_feedback()


# --- Placement API ---

func select_item_to_place(item_scene: PackedScene) -> void:
	if item_scene == null:
		push_error("PlacementManager: null PackedScene.")
		return

	var instance := item_scene.instantiate()
	if not (instance is FurnitureItem):
		push_error("PlacementManager: '%s' root is '%s', not FurnitureItem." % [
			item_scene.resource_path, instance.get_class()
		])
		instance.queue_free()
		return

	select_placed_item(null)
	_cancel_ghost()
	current_scene = item_scene
	current_item = instance as FurnitureItem
	current_item.is_placed = false
	furniture_container.add_child(current_item)
	current_rotation_step = 0
	current_item.rotation_degrees.y = 0.0

	var hit_pos = get_floor_mouse_position()
	if hit_pos != null:
		current_item.global_position = snap_to_grid(hit_pos)

func try_place_current_item() -> void:
	if current_item == null or not current_item.can_place():
		return
	var placed := current_item
	placed.is_placed = true
	placed.monitoring = false
	placed.monitorable = true
	placed.set_selected(false)

	var next_scene := current_scene
	current_item = null
	select_item_to_place(next_scene)


func rotate_current_item(dir: int) -> void:
	if current_item == null:
		return
	current_rotation_step = posmod(current_rotation_step + sign(dir), 4)
	current_item.rotation_degrees.y = current_rotation_step * 90.0


func cancel_placement() -> void:
	_cancel_ghost()


func _cancel_ghost() -> void:
	if current_item != null:
		current_item.queue_free()
		current_item = null


# --- Selection API ---

func raycast_furniture() -> FurnitureItem:
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	if camera == null:
		return null
	var mouse := viewport.get_mouse_position()
	var from := camera.project_ray_origin(mouse)
	var to := from + camera.project_ray_normal(mouse) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to, furniture_collision_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider = result.collider
	if collider is FurnitureItem:
		return collider
	# Fallback: walk up to find a FurnitureItem ancestor.
	var node = collider
	while node != null:
		if node is FurnitureItem:
			return node
		node = node.get_parent()
	return null


func select_placed_item(item: FurnitureItem) -> void:
	if selected_item == item:
		return
	if selected_item != null and is_instance_valid(selected_item):
		selected_item.set_selected(false)
	selected_item = item
	if selected_item != null:
		selected_item.set_selected(true)


func _delete_selected() -> void:
	if selected_item == null:
		return
	var to_free := selected_item
	selected_item = null
	to_free.queue_free()


# --- Geometry helpers ---

func get_floor_mouse_position():
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	if camera == null:
		return null
	var mouse_pos := viewport.get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var to := from + dir * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to, floor_collision_mask)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	return result.position


func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		snapped(pos.x, grid_size),
		pos.y,
		snapped(pos.z, grid_size)
	)


func _update_ghost_feedback() -> void:
	if current_item == null:
		return
	current_item.set_preview_valid(current_item.can_place())
