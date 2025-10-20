extends RichTextLabel

@export var font_size: int = 16

var theme_override_names: Array[String] = ["margin_top", "margin_bottom", "margin_left", "margin_right"]
var font_override_names: Array[String] = ["normal_font_size", "bold_font_size", "bold_italics_font_size", "italics_font_size", "mono_font_size"]

func _ready() -> void:
	scroll_active = false

func is_correct_size() -> bool:
	var margin_parent: MarginContainer = get_parent()
	var margin_size: int = (int) (margin_parent.size.y / 3.75)
	var margin_correct: bool = true
	for theme_name in theme_override_names:
		if margin_parent.get_theme_constant(theme_name) != margin_size:
			margin_correct = false
			break
	var font_correct: bool = true
	for font_name in font_override_names:
		if get_theme_font_size(font_name) != font_size:
			font_correct = false
			break
	return margin_correct and font_correct

func setup_size() -> void:
	var margin_parent: MarginContainer = get_parent()
	var margin_size: int = (int) (margin_parent.size.y / 3.75)
	for theme_name in theme_override_names:
		margin_parent.add_theme_constant_override(theme_name, margin_size)
	setup_font_size()

func setup_font_size() -> void:
	for font_name in font_override_names:
		add_theme_font_size_override(font_name, font_size)
