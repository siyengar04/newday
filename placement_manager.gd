extends Node3D

@export var grid_size: float = 1.0
@export var floor_collision_mask: int = 2 # Matches Layer 2 (Floor)
@export var furniture_container: Node3D

var current_item: FurnitureItem = null
var current_rotation_step: int = 0 # 0, 1, 2, 3 (0°, 90°, 180°, 270°)

func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var hovered_control = get_viewport().gui_get_hovered_control()
	if hovered_control != null and hovered_control.is_visible_in_tree():
		return
	if current_item == null:
		return

	# Rotate item on R or Mouse Wheel
	if event.is_action_pressed("item_place_rotate") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed):
		rotate_current_item(1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		rotate_current_item(-1)

	# Place item on Left Click
	if event.is_action_pressed("item_place"):
		try_place_current_item()

	# Cancel item on Right Click
	if event.is_action_pressed("item_place_cancel"):
		cancel_placement()

func _process(_delta: float) -> void:
	if current_item == null:
		return

	var hit_pos = get_floor_mouse_position()
	if hit_pos != null:
		var snapped_pos = snap_to_grid(hit_pos)
		current_item.global_position = snapped_pos

func get_floor_mouse_position():
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	var mouse_pos = viewport.get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var to = from + dir * 1000.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, floor_collision_mask)
	
	# Optional: Set to true if your floor uses an Area3D instead of a StaticBody3D
	# query.collide_with_areas = false
	# query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	return null

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		snapped(pos.x, grid_size),
		pos.y,
		snapped(pos.z, grid_size)
	)

func select_item_to_place(item_scene: PackedScene) -> void:
	if current_item != null:
		current_item.queue_free()

	current_item = item_scene.instantiate() as FurnitureItem
	current_item.is_placed = false
	furniture_container.add_child(current_item)
	current_rotation_step = 0

func rotate_current_item(dir: int) -> void:
	current_rotation_step = (current_rotation_step + dir) % 4
	current_item.rotation_degrees.y = current_rotation_step * 90.0

func try_place_current_item() -> void:
	if current_item.can_place():
		current_item.is_placed = true
		# Optionally keep spawning same item or clear reference:
		var scene_to_reinstantiate = load(current_item.scene_file_path)
		current_item = null
		select_item_to_place(scene_to_reinstantiate)

func cancel_placement() -> void:
	if current_item != null:
		current_item.queue_free()
		current_item = null
		
func _ready() -> void:
	var test_scene = preload("res://FurnitureItem.tscn")
	select_item_to_place(test_scene)
