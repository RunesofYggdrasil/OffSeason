class_name Selectable

extends Node

signal mouse_hover(selectable: Node, hover: bool)

@export var sprite_node: Node
@export var collision_node: Node
@export var base_texture: Texture2D
@export var hover_texture: Texture2D

var connection_names: Array[Dictionary] = [{"name": "mouse_entered", "callable": _on_mouse_entered}, {"name": "mouse_exited", "callable": _on_mouse_exited}]
var has_sprite_node: bool = false
var is_selectable: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	update_connections()
	
	if has_resource("texture", sprite_node):
		has_sprite_node = true
		sprite_node.texture = base_texture

func check_selectability(node: Node = self) -> bool:
	# Could be nested into a single line statement as commented out below but expanded for readability.
	# return node.visible and (node is not Item or node.dialogue_start_exists())
	if node.visible:
		if node is Item:
			if node.dialogue_start_exists():
				return true
			else:
				return false
		else:
			return true
	else:
		return false

func fix_selectability() -> void:
	var new_is_selectable: bool = check_selectability()
	if is_selectable != new_is_selectable:
		is_selectable = new_is_selectable
		update_connections(is_selectable)

func has_resource(resource_name: String, node: Node = self) -> bool:
	var resource_string_name: NodePath = "%s:%s" % [node.get_path(), resource_name]
	return has_node_and_resource(resource_string_name)

func has_connection(connection: Dictionary, connection_node: Node = collision_node) -> bool:
	var has_node_connection: bool = false
	var node_connection: Signal
	for node_signal in connection_node.get_signal_list():
		if node_signal.name == connection.name:
			for signal_connection in connection_node.get_signal_connection_list(node_signal.name):
				if signal_connection.callable == connection.callable:
					has_node_connection = true
					node_connection = signal_connection.signal
					break
			break
	if has_node_connection:
		var has_incoming_connection: bool = false
		for incoming_connection in get_incoming_connections():
			if incoming_connection.signal == node_connection:
				has_incoming_connection = true
				break
		return has_incoming_connection
	else:
		return false

func update_connections(is_connect: bool = true, connection_node: Node = collision_node) -> void:
	if connection_node != null:
		for connection_name in connection_names:
			var has_named_connection: bool = has_connection(connection_name)
			if is_connect and !has_named_connection:
				connection_node.connect(connection_name.name, connection_name.callable)
			elif !is_connect and has_named_connection:
				connection_node.disconnect(connection_name.name, connection_name.callable)

func set_hover(hover: bool) -> void:
	if has_sprite_node:
		if hover:
			sprite_node.texture = hover_texture
		else:
			sprite_node.texture = base_texture

func _on_mouse_entered() -> void:
	mouse_hover.emit(self, true)

func _on_mouse_exited() -> void:
	mouse_hover.emit(self, false)
