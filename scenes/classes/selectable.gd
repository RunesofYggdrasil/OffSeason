class_name Selectable

extends Node

signal mouse_hover(selectable: Node, hover: bool)

@export var sprite_node: Node
@export var collision_node: Node
@export var base_texture: Texture2D
@export var hover_texture: Texture2D

var has_sprite_node: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if collision_node != null:
		collision_node.connect("mouse_entered", _on_mouse_entered)
		collision_node.connect("mouse_exited", _on_mouse_exited)
	
	if has_resource("texture", sprite_node):
		has_sprite_node = true
		sprite_node.texture = base_texture

func has_resource(resource_name: String, node: Node = self) -> bool:
	var resource_string_name: NodePath = "%s:%s" % [node.get_path(), resource_name]
	return has_node_and_resource(resource_string_name)

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
