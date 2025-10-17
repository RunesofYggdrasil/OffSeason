extends Selector

@export var box_x: float = 52.0
@export var box_y: float = 246.0
@export var box_width: float = 536.0
@export var box_height: float = 144.0

const MINIMUM_WIDTH: float = 32.0
const MINIMUM_HEIGHT: float = 112.0

var is_dialogue_active: bool = false
var is_typing_dialogue: bool = false
var total_typed_characters: int = 0
var current_typed_characters: int = 0
var dialogue_resource: DialogueResource = null
var dialogue_line: DialogueLine = null
var node_names: Array[String] = ["BoxContainer", "SpeakerText", "MainText", "GridResponseContainer", "ResponseText"]
var named_children: Array[Node] = []
var box_container: Node = null
var speaker_text: Node = null
var main_text: Node = null
var grid_container: Node = null
var highlighted_response: Control = null

func _ready() -> void:
	super()
	setup_nodes()

# Region: Node Gathering and Resizing Methods
func find_highest_control_parent(node: Node = self) -> Node:
	var parent: Node = node.get_parent()
	if parent != null and parent is Control:
		return find_highest_control_parent(parent)
	else:
		if node is Control:
			return node
		else:
			return null

func find_named_children(names: Array[String], node: Node = self) -> Array[Node]:
	var named_child_nodes: Array[Node] = []
	if node.name in names:
		named_child_nodes.append(node)
	for child in node.get_children():
		named_child_nodes.append_array(find_named_children(names, child))
	return named_child_nodes

func find_node(node_name: String, node_list: Array[Node], parent_node: Node = self) -> Node:
	for node in node_list:
		if node.name == node_name and is_child_of(node, parent_node):
			return node
	return null

func find_margins(node: Node = self) -> Dictionary:
	var margin_size: Dictionary = {"top": 0.0, "bottom": 0.0, "left": 0.0, "right": 0.0}
	if node is MarginContainer:
		margin_size.top += node.get_theme_constant("margin_top")
		margin_size.bottom += node.get_theme_constant("margin_bottom")
		margin_size.left += node.get_theme_constant("margin_left")
		margin_size.right += node.get_theme_constant("margin_right")
	var parent: Node = node.get_parent()
	if parent != null and parent is Control:
		var parent_margin_size: Dictionary = find_margins(parent)
		margin_size.top += parent_margin_size.top
		margin_size.bottom += parent_margin_size.bottom
		margin_size.left += parent_margin_size.left
		margin_size.right += parent_margin_size.right
	return margin_size

func is_child_of(node: Node, parent_node: Node = self) -> bool:
	node = node.get_parent()
	if node != null:
		if node == parent_node:
			return true
		else:
			return is_child_of(node, parent_node)
	else:
		return false

func resize(node: Node = self) -> void:
	var control: Node = find_highest_control_parent(node)
	var margin_size: Dictionary = find_margins(node)
	var minimum_box_width: float = MINIMUM_WIDTH + margin_size.left + margin_size.right
	var minimum_box_height: float = MINIMUM_HEIGHT + margin_size.top + margin_size.bottom
	if box_width >= minimum_box_width and box_height >= minimum_box_height:
		control.size.x = box_width
		control.size.y = box_height
	control.queue_sort()

func reposition(node: Node = self) -> void:
	var control: Node = find_highest_control_parent(node)
	var maximum_box_x: float = 640.0 - control.size.x
	var maximum_box_y: float = 360.0 - control.size.y
	if box_x <= maximum_box_x and box_y <= maximum_box_y:
		control.position.x = box_x
		control.position.y = box_y

func setup_nodes() -> void:
	named_children = find_named_children(node_names)
	box_container = find_node("BoxContainer", named_children)
	speaker_text = find_node("SpeakerText", named_children)
	main_text = find_node("MainText", named_children)
	grid_container = find_node("GridResponseContainer", named_children)
	resize(box_container)
	reposition(box_container)
# End Region: Node Gathering and Resizing Methods

func start_dialogue(dialogue_source: DialogueResource, dialogue_start: String) -> void:
	dialogue_resource = dialogue_source
	dialogue_line = await DialogueManager.get_next_dialogue_line(dialogue_resource, dialogue_start)
	is_dialogue_active = true
