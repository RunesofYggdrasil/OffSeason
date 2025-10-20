extends Selectable

@export var textbox_border_texture: Texture2D

var border_sprites: Array[TextureRect] = []

@onready var box_text_margin: MarginContainer = $SizeContainer/BackgroundMarginContainer/TextMarginContainer
@onready var box_text: RichTextLabel = $SizeContainer/BackgroundMarginContainer/TextMarginContainer/TextBox

func _ready() -> void:
	super()
	box_text_margin.add_theme_constant_override("margin_top", textbox_border_texture.get_height())
	box_text_margin.add_theme_constant_override("margin_bottom", textbox_border_texture.get_height())
	box_text_margin.add_theme_constant_override("margin_left", textbox_border_texture.get_width())
	box_text_margin.add_theme_constant_override("margin_right", textbox_border_texture.get_width())
	for border_node in get_node("SizeContainer/BorderMarginContainer/BorderContainer").get_children():
		if !border_node.name.contains("Gap"):
			border_sprites.append(border_node)
	for border_sprite in border_sprites:
		border_sprite.texture = textbox_border_texture

func correct_size() -> void:
	if !box_text.is_correct_size():
		box_text.setup_size()

func set_text(text: String) -> void:
	if !box_text.is_correct_size():
		box_text.setup_size()
	box_text.text = text
