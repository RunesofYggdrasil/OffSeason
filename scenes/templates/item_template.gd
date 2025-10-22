class_name Item

extends Selectable

@export var dialogue_file: DialogueResource
@export var selectable_object: GlobalEnums.SELECTABLE_OBJECT

var is_active: bool = true
var has_dialogue_start: bool = true
var dialogue_start: String = "gawain_english_interact_dialogue_0"
var interact_count: int = 0

func _ready() -> void:
	super()
	if is_active:
		self.visible = true
	else:
		self.visible = false

func get_dialogue_start() -> String:
	var character_index: int = dialogue_start.find("_")
	var language_index: int = dialogue_start.find("_", character_index + 1)
	var interact_index: int = dialogue_start.rfind("_")
	var interact_length: int = (interact_index + 1) - language_index
	var current_dialogue_start: String = Player.get_player_character_name() + "_" + Player.get_player_language_name() + dialogue_start.substr(language_index, interact_length) + str(interact_count)
	return current_dialogue_start

func dialogue_start_exists() -> bool:
	if dialogue_file != null:
		dialogue_start = get_dialogue_start()
		has_dialogue_start = dialogue_file.get_titles().has(dialogue_start)
	else:
		has_dialogue_start = false
	return has_dialogue_start

func interact() -> void:
	interact_count += 1

func deactivate() -> void:
	self.visible = false
	is_active = false
