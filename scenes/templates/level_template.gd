class_name Level

extends Selector

signal trigger_dialogue(dialogue_source: DialogueResource, dialogue_start: String)

@export var background_image: Texture2D

func _ready() -> void:
	super()
	Player.get_scene_level()

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("SELECT"):
		var selected_item: Selectable = get_highlighted_item()
		if selected_item != null and selected_item is Item and selected_item.dialogue_start_exists():
			var dialogue_source: DialogueResource = selected_item.dialogue_file
			var dialogue_start: String = selected_item.dialogue_start
			Player.current_interaction_item = selected_item
			trigger_dialogue.emit(dialogue_source, dialogue_start)
			selected_item.interact()
