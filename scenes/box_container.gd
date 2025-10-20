extends Container

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for child in get_children():
			fit_child_in_rect(child, Rect2(Vector2(), size))
