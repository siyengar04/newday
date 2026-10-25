extends Area3D
class_name FurnitureItem

@export var item_id: String = "chair"
@export var grid_size: Vector2i = Vector2i(1, 1)

var is_placed: bool = false
var overlapping_count: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_or_area_entered)
	body_exited.connect(_on_body_or_area_exited)
	area_entered.connect(_on_body_or_area_entered)
	area_exited.connect(_on_body_or_area_exited)

func _on_body_or_area_entered(_other) -> void:
	if not is_placed:
		overlapping_count += 1
		_update_preview_material()

func _on_body_or_area_exited(_other) -> void:
	if not is_placed:
		overlapping_count = max(0, overlapping_count - 1)
		_update_preview_material()

func can_place() -> bool:
	return overlapping_count == 0

func _update_preview_material() -> void:
	# Optional: Swap mesh material or albedo color (Green = Valid, Red = Blocked)
	pass
