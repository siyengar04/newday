class_name FurnitureItem
extends Area3D

@export var item_id: String = "chair"

var is_placed: bool = false
var is_selected: bool = false

@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
@onready var _shape: CollisionShape3D = get_node_or_null("CollisionShape3D")


func _ready() -> void:
	monitoring = not is_placed
	monitorable = true


func can_place() -> bool:
	if _shape == null:
		return true
	var space := get_world_3d().direct_space_state
	if space == null:
		return true
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = _shape.shape
	params.transform = _shape.global_transform
	params.collision_mask = 1  # furniture layer
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.exclude = [get_rid()]
	return space.intersect_shape(params).is_empty()


func set_selected(v: bool) -> void:
	if is_selected == v:
		return
	is_selected = v
	_apply_highlight(v)


func set_preview_valid(valid: bool) -> void:
	if _mesh == null:
		return
	var color := Color(0.3, 1.0, 0.3, 0.7) if valid else Color(1.0, 0.3, 0.3, 0.7)
	var mat := _mesh.get_active_material(0)
	var dup: StandardMaterial3D
	if mat is StandardMaterial3D:
		dup = mat.duplicate() as StandardMaterial3D
	else:
		dup = StandardMaterial3D.new()
	dup.albedo_color = color
	dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dup.emission_enabled = false
	_mesh.set_surface_override_material(0, dup)


func _apply_highlight(v: bool) -> void:
	if _mesh == null:
		return
	if not v:
		_mesh.set_surface_override_material(0, null)
		return
	var mat := _mesh.get_active_material(0)
	var dup: StandardMaterial3D
	if mat is StandardMaterial3D:
		dup = mat.duplicate() as StandardMaterial3D
	else:
		dup = StandardMaterial3D.new()
	dup.emission_enabled = true
	dup.emission = Color(1.0, 0.8, 0.2)
	dup.emission_energy_multiplier = 0.6
	_mesh.set_surface_override_material(0, dup)
