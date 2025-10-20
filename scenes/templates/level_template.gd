extends Selector

signal trigger_dialogue(dialogue_source: DialogueResource, dialogue_start: String)

@export var background_image: Texture2D

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("SELECT"):
		var selected_item: Selectable = get_highlighted_item()
		if selected_item != null:
			if selected_item.has_resource("dialogue_file"):
				var dialogue_source: DialogueResource = selected_item.dialogue_file
				var dialogue_start: String = selected_item.get_dialogue_start()
				if dialogue_source.get_titles().has(dialogue_start):
					trigger_dialogue.emit(dialogue_source, dialogue_start)
					selected_item.interact()
