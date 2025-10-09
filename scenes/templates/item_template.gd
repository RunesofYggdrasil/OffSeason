extends Node2D

signal mouse_hover(item: Node2D, hover: bool)

@export var item_base_texture: Texture2D
@export var item_hover_texture: Texture2D

func _ready() -> void:
	$ItemSprite.texture = item_base_texture

func set_hover(hover: bool) -> void:
	if hover:
		$ItemSprite.texture = item_hover_texture
	else:
		$ItemSprite.texture = item_base_texture


func _on_item_area_mouse_entered() -> void:
	mouse_hover.emit(self, true)


func _on_item_area_mouse_exited() -> void:
	mouse_hover.emit(self, false)
