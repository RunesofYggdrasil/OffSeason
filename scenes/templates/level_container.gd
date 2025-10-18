extends Selector

signal trigger_dialogue(dialogue_source: DialogueResource, dialogue_start: String)

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("SELECT"):
		var selected_item: Selectable = get_highlighted_item()
		if selected_item != null:
			if selected_item.has_resource("dialogue_file") and selected_item.has_resource("dialogue_start"):
				trigger_dialogue.emit(selected_item.dialogue_file, selected_item.dialogue_start)
