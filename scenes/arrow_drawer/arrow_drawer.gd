extends Node2D
class_name ArrowDrawer

var _start_node: Card
var start_node: Card:
	get:
		return _start_node
	set(value):
		if start_node != null:
				start_node.attack_icon_sprite.visible = false
		if value != null:
			value.attack_icon_sprite.visible = true
		_start_node = value
		end_node = null
		queue_redraw()
		if start_node != null:
			sync_start_node.rpc(start_node.get_path())
		else:
			sync_start_node.rpc("")

var _end_node: Node2D
var end_node: Node2D:
	get:
		return _end_node
	set(value):
		_end_node = value
		queue_redraw()
		if end_node != null:
			sync_end_node.rpc(end_node.get_path())
		else:
			sync_end_node.rpc("")

@export var arrow_color: Color = Color.RED
@export var line_width: float = 4.0
@export var head_size: float = 15.0

@rpc("any_peer", "call_remote", "reliable")
func sync_start_node(start_node_path: String) -> void:
	if start_node != null:
		start_node.attack_icon_sprite.visible = false
	if !start_node_path.is_empty():
		_start_node = get_node(start_node_path)
		start_node.attack_icon_sprite.visible = true
	else:
		_start_node = null
	_end_node = null
	queue_redraw()

@rpc("any_peer", "call_remote", "reliable")
func sync_end_node(end_node_path: String) -> void:
	if !end_node_path.is_empty():
		_end_node = get_node(end_node_path)
	else: 
		_end_node = null
	queue_redraw()

func _draw() -> void:
	if not start_node or not end_node:
		return
	# Get positions relative to this node's coordinate space
	var local_start = to_local(start_node.global_position)
	var local_end = to_local(end_node.global_position)
	
	# Calculate direction and length
	var direction: Vector2 = (local_end - local_start).normalized()
	
	# Draw the main shaft of the arrow
	draw_line(local_start, local_end, arrow_color, line_width)
	
	# Calculate arrowhead points
	var arrow_hook_1: Vector2 = local_end - direction.rotated(deg_to_rad(30)) * head_size
	var arrow_hook_2: Vector2 = local_end - direction.rotated(deg_to_rad(-30)) * head_size
	
	# Draw the arrowhead using a packed array of points
	var arrow_head_points: PackedVector2Array = PackedVector2Array([local_end, arrow_hook_1, arrow_hook_2])
	draw_colored_polygon(arrow_head_points, arrow_color)
