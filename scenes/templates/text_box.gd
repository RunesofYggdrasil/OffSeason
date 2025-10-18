extends RichTextLabel

@export var font_size_ratio: float = 0.75

func _ready() -> void:
	scroll_active = false

func setup_size() -> void:
	var margin_parent: MarginContainer = get_parent()
	var margin_size: int = (int) (margin_parent.size.y / 3.75)
	margin_parent.add_theme_constant_override("margin_top", margin_size)
	margin_parent.add_theme_constant_override("margin_bottom", margin_size)
	margin_parent.add_theme_constant_override("margin_left", margin_size)
	margin_parent.add_theme_constant_override("margin_right", margin_size)
	setup_font_size()

func setup_font_size() -> void:
	var font_size: int = (int) (size.y * font_size_ratio)
	add_theme_font_size_override("normal_font_size", font_size)
	add_theme_font_size_override("bold_font_size", font_size)
	add_theme_font_size_override("bold_italics_font_size", font_size)
	add_theme_font_size_override("italics_font_size", font_size)
	add_theme_font_size_override("mono_font_size", font_size)
