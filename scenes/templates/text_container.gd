extends Selectable

@export var textbox_border_texture: Texture2D

var border_sprites: Array[TextureRect] = []

func _ready() -> void:
	super()
	for border_node in get_node("SizeContainer/BorderMarginContainer/BorderContainer").get_children():
		if !border_node.name.contains("Gap"):
			border_sprites.append(border_node)
	for border_sprite in border_sprites:
		border_sprite.texture = textbox_border_texture
