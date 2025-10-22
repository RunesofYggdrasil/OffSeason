extends Node

var player_language: GlobalEnums.LANGUAGE = GlobalEnums.LANGUAGE.ENGLISH
var player_character: GlobalEnums.PLAYABLE_CHARACTER = GlobalEnums.PLAYABLE_CHARACTER.GAWAIN
var current_level: Level = null
var current_interaction_item: Item = null
var inventory: Array[Dictionary] = []

func start_dialogue() -> void:
	get_tree().paused = true

func end_dialogue() -> void:
	get_tree().paused = false
	current_level.get_item_children()

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
	current_level = get_scene_level()

func get_scene_level(node: Node = get_tree().current_scene) -> Level:
	var level: Level = null
	if node is Level:
		level = node
	else:
		for child in node.get_children():
			var child_level: Level = get_scene_level(child)
			if child_level != null:
				level = child_level
				break
	if level != null:
		current_level = level
	return level

func pickup_item() -> void:
	if current_interaction_item != null:
		var item_name: String = GlobalEnums.get_selectable_object_name(current_interaction_item.selectable_object)
		inventory.append({"name": item_name, "item": current_interaction_item})
		current_interaction_item.deactivate()

func pickup_named_item(item_name: String) -> void:
	var selectable_object: GlobalEnums.SELECTABLE_OBJECT = GlobalEnums.get_selectable_object(item_name)
	if current_level != null:
		var selectable_children: Array[Selectable] = current_level.get_selectable_children()
		var item_child: Item = null
		for child in selectable_children:
			if child is Item and child.is_active and child.selectable_object == selectable_object:
				item_child = child
		if item_child != null:
			inventory.append({"name": item_name, "item": item_child})
			item_child.deactivate()

func pickup_selectable_item(selectable_object: GlobalEnums.SELECTABLE_OBJECT) -> void:
	var item_name: String = GlobalEnums.get_selectable_object_name(selectable_object)
	if current_level != null:
		var selectable_children: Array[Selectable] = current_level.get_selectable_children()
		var item_child: Item = null
		for child in selectable_children:
			if child is Item and child.is_active and child.selectable_object == selectable_object:
				item_child = child
		if item_child != null:
			inventory.append({"name": item_name, "item": item_child})
			item_child.deactivate()

func get_player_language_name() -> String:
	return GlobalEnums.get_language_name(player_language)

func get_player_character_name() -> String:
	return GlobalEnums.get_playable_character_name(player_character)
