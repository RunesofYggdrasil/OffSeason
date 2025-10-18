extends Selector

@export var box_x: float = 52.0
@export var box_y: float = 160.0
@export var box_width: float = 536.0
@export var box_height: float = 200.0

const MINIMUM_WIDTH: float = 32.0
const MINIMUM_HEIGHT: float = 112.0
const TYPING_SPEED: float = 20.0

# Dialogue Variables
var is_dialogue_active: bool = false
var is_typing_dialogue: bool = false
var is_awaiting_response: bool = false
var total_typed_characters: int = 0
var current_typed_characters: int = 0
var current_typing_progress: float = 0.0
var dialogue_resource: DialogueResource = null
var dialogue_line: DialogueLine = null
# Node Variables
var node_names: Array[String] = ["BoxCanvas", "BoxContainer", "SpeakerText", "MainText", "GridResponseContainer"]
var named_children: Array[Node] = []
var box_canvas: CanvasLayer = null
var box_container: Node = null
var speaker_text: RichTextLabel = null
var main_text: RichTextLabel = null
var grid_container: Node = null
var response_boxes: Array[Node] = []
var highlighted_response: Control = null

func _ready() -> void:
	super()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	setup_nodes()

func _process(delta: float) -> void:
	if is_dialogue_active:
		progress_typing(delta)

func _input(event: InputEvent) -> void:
	if is_dialogue_active:
		if event.is_action_pressed("SELECT"):
			if dialogue_line != null:
				# If the dialogue is currently typing, expedite the typing. Otherwise, progress the dialogue.
				if is_typing_dialogue:
					current_typing_progress = (float) (dialogue_line.text.length())
					progress_typing()
				else:
					progress_dialogue()
			else:
				end_dialogue()

# Start Region: Node Gathering and Resizing Methods
func setup_nodes() -> void:
	named_children = find_named_children(node_names)
	box_canvas = find_node("BoxCanvas", named_children)
	box_container = find_node("BoxContainer", named_children)
	speaker_text = find_node("SpeakerText", named_children)
	main_text = find_node("MainText", named_children)
	grid_container = find_node("GridResponseContainer", named_children)
	response_boxes = grid_container.get_children()
	box_canvas.hide()
	resize(box_container)
	reposition(box_container)

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
# End Region: Node Gathering and Resizing Methods

# Start Region: Dialogue Methods
func start_dialogue(dialogue_source: DialogueResource, dialogue_start: String) -> void:
	get_tree().paused = true 
	box_canvas.show()
	dialogue_resource = dialogue_source
	dialogue_line = await DialogueManager.get_next_dialogue_line(dialogue_resource, dialogue_start)
	is_dialogue_active = true

func setup_dialogue() -> void:
	if dialogue_line != null:
		current_typing_progress = 0.0
		current_typed_characters = (int) (current_typing_progress)
		total_typed_characters = dialogue_line.text.length()
		main_text.visible_characters = current_typed_characters
		main_text.setup_size()
		speaker_text.setup_size()
		main_text.text = dialogue_line.text
		speaker_text.text = dialogue_line.character
		for child in response_boxes:
			if child is Selectable:
				child.visible = false
				child.set_text("")
			else:
				child.visible = true
	else:
		end_dialogue()

func progress_dialogue() -> void:
	if dialogue_line != null:
		var next_id: String
		if is_awaiting_response:
			var response_index: int = get_highlighted_item_index()
			# If a dialogue response is currently selected, use that response index to progress. Otherwise, do nothing and wait for a response.
			if response_index != -1:
				next_id = dialogue_line.responses[response_index].next_id
		else:
			next_id = dialogue_line.next_id
		dialogue_line = await DialogueManager.get_next_dialogue_line(dialogue_resource, next_id)
		setup_dialogue()
	else:
		end_dialogue()

func progress_typing(delta: float = 0.0) -> void:
	if dialogue_line != null:
		if main_text.text.length() > 0:
			current_typing_progress += TYPING_SPEED * delta
			current_typed_characters = (int) (current_typing_progress)
			main_text.visible_characters = current_typed_characters
			if current_typed_characters < total_typed_characters:
				is_typing_dialogue = true
			else:
				is_typing_dialogue = false
				setup_response_dialogue()
		else:
			setup_dialogue()
	else:
		end_dialogue()

func setup_response_dialogue() -> void:
	if dialogue_line != null:
		if dialogue_line.responses.size() > 0:
			var dialogue_responses: Array[DialogueResponse] = dialogue_line.responses
			is_awaiting_response = true
			for i in dialogue_responses.size():
				var dialogue_response: DialogueResponse = dialogue_responses[i]
				var response_node: Node = response_boxes[i]
				var gap_node: Node = response_boxes[i + 4]
				response_node.set_text(dialogue_response.text)
				response_node.visible = true
				gap_node.visible = false
		else:
			is_awaiting_response = false
	else:
		end_dialogue()

func end_dialogue() -> void:
	box_canvas.hide()
	get_tree().paused = false 
	main_text.text = ""
	main_text.visible_characters = 0
	speaker_text.text = ""
	for child in response_boxes:
		if child is Selectable:
			child.visible = false
			child.set_text("")
		else:
			child.visible = true
	is_dialogue_active = false
	is_typing_dialogue = false
	total_typed_characters = 0
	current_typed_characters = 0
# End Region: Dialogue Methods

# Start Region: Signals
func trigger_dialogue(dialogue_source: DialogueResource, dialogue_start: String):
	if !is_dialogue_active:
		start_dialogue(dialogue_source, dialogue_start)
# End Region: Signals
