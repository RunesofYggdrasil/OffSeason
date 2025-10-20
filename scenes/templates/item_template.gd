extends Selectable

@export var dialogue_file: DialogueResource

var dialogue_start: String = "interact_dialogue_0"
var interact_count: int = 0

func get_dialogue_start() -> String:
	var interact_index: int = dialogue_start.rfind("_") + 1
	dialogue_start = dialogue_start.substr(0, interact_index) + str(interact_count)
	return dialogue_start

func interact() -> void:
	interact_count += 1
