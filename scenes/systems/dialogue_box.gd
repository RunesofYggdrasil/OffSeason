extends Node2D

@export var box_width: float = 536.0
@export var box_height: float = 114.0

func _ready() -> void:
	$BoxCanvas/BoxContainer.resize(box_width, box_height)
