class_name Selectable

extends Node

signal mouse_hover(selectable: Node, hover: bool)

@export var sprite_node: Node
@export var collision_node: Node
@export var base_texture: Texture2D
@export var hover_texture: Texture2D

var has_sprite_node: bool = false

func _ready() -> void:
	if collision_node != null:
		collision_node.connect("mouse_entered", _on_mouse_entered)
		collision_node.connect("mouse_exited", _on_mouse_exited)
	
	if has_node_and_resource("%s:texture" % sprite_node.get_path()):
		has_sprite_node = true
		sprite_node.texture = base_texture

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
