class_name Selector

extends Node

enum INPUT_DIRECTION {PREV, NEXT, UP, DOWN, LEFT, RIGHT}

@export var selectable_container: Node

var selectable_children: Array[Selectable] = []
var highlighted_item: Selectable = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	setup_selectables()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("INVERSE_TAB"):
		navigate_to_next_item(INPUT_DIRECTION.PREV)
	elif event.is_action_pressed("TAB"):
		navigate_to_next_item(INPUT_DIRECTION.NEXT)
	else:
		if event.is_action_pressed("RIGHT"):
			navigate_to_next_item(INPUT_DIRECTION.RIGHT)
		elif event.is_action_pressed("DOWN"):
			navigate_to_next_item(INPUT_DIRECTION.DOWN)
		elif event.is_action_pressed("LEFT"):
			navigate_to_next_item(INPUT_DIRECTION.LEFT)
		elif event.is_action_pressed("UP"):
			navigate_to_next_item(INPUT_DIRECTION.UP)

# Start Region: Accessing Selections
func setup_selectables() -> void:
	get_item_children()
	for child in selectable_children:
		var has_connection: bool = false
		for connection in get_incoming_connections():
			if connection.signal == child.mouse_hover:
				has_connection = true
		if !has_connection:
			child.mouse_hover.connect(set_highlighted_item)

func get_highlighted_item() -> Selectable:
	return highlighted_item

func get_highlighted_item_index() -> int:
	if highlighted_item == null:
		return -1
	else:
		return selectable_children.find(highlighted_item)
# End Region: Accessing Selections

# Start Region: Navigation and Selection Methods
func navigate_to_next_item(direction: INPUT_DIRECTION) -> void:
	get_item_children()
	var next_item: Selectable = null
	if direction == INPUT_DIRECTION.PREV or direction == INPUT_DIRECTION.NEXT:
		next_item = get_next_tab_item(direction)
	else:
		next_item = get_next_item(direction)
	if next_item != null:
		set_highlighted_item(next_item, true)

func is_tab_next(a: Selectable, b: Selectable) -> bool:
	if a.position.y < b.position.y:
		return true
	elif a.position.y > b.position.y:
		return false
	else:
		if a.position.x < b.position.x:
			return true
		else:
			return false

# Gets all children of the level that are currently selectable items.
func get_item_children() -> void:
	var item_children: Array[Selectable] = []
	if selectable_container != null:
		for child in selectable_container.get_children():
			if child is Selectable and child.visible:
				item_children.append(child)
	selectable_children = item_children

# Gets the items in the direction of the INPUT_DIRECTION, should not be used for PREV and NEXT.
func get_items_in_direction(direction: INPUT_DIRECTION) -> Array[Dictionary]:
	var item_distances: Array[Dictionary] = []
	for item in selectable_children:
		var x_difference: float = 0.0
		var y_difference: float = 0.0
		# Checks if the highlighted_item has been set.
		if highlighted_item == null:
			x_difference = item.position.x
			y_difference = item.position.y
		else:
			x_difference = (item.position.x) - highlighted_item.position.x
			y_difference = item.position.y - highlighted_item.position.y
		var total_distance: float = sqrt(x_difference ** 2 + y_difference ** 2)
		var item_data: Dictionary = {"node": item, "x": x_difference, "y": y_difference, "slope": y_difference / x_difference, "distance": total_distance}
		var is_in_direction: bool
		if direction == INPUT_DIRECTION.RIGHT:
			if item_data.x >= 0.0 and (item_data.slope <= 1 and item_data.slope >= -1):
				is_in_direction = true
			else:
				is_in_direction = false
		elif direction == INPUT_DIRECTION.DOWN:
			if item_data.y >= 0.0 and (item_data.slope >= 1 or item_data.slope <= -1):
				is_in_direction = true
			else:
				is_in_direction = false
		elif direction == INPUT_DIRECTION.LEFT:
			if item_data.x <= 0.0 and (item_data.slope <= 1 and item_data.slope >= -1):
				is_in_direction = true
			else:
				is_in_direction = false
		elif direction == INPUT_DIRECTION.UP:
			if item_data.y <= 0.0 and (item_data.slope >= 1 or item_data.slope <= -1):
				is_in_direction = true
			else:
				is_in_direction = false
		else:
			# If not in any of the four primary directions, the INPUT_DIRECTION is either PREV or NEXT,  which is not aallowed.
			is_in_direction = false
		# Checks if the item is in the right direction and is at a different position before appending it to the item distances.
		if is_in_direction and total_distance > 0.0:
			item_distances.append(item_data)
	return item_distances

# Gets the next item in the direction of the INPUT_DIRECTION, should not be used for PREV and NEXT.
func get_next_item(direction: INPUT_DIRECTION) -> Selectable:
	if direction == INPUT_DIRECTION.PREV or direction == INPUT_DIRECTION.NEXT:
		return null
	var items_in_direction: Array[Dictionary] = get_items_in_direction(direction)
	var nearest_item: Selectable = null
	var nearest_distance: float = 0.0
	for item in items_in_direction:
		if nearest_item == null or item.distance < nearest_distance:
			nearest_item = item.node
			nearest_distance = item.distance
	return nearest_item

# Gets the next item in the direction of the INPUT_DIRECTION, should only be used for PREV and NEXT.
func get_next_tab_item(direction: INPUT_DIRECTION) -> Selectable:
	if direction != INPUT_DIRECTION.PREV and direction != INPUT_DIRECTION.NEXT:
		return null
	selectable_children.sort_custom(is_tab_next)
	var next_item_index: int = 0
	var next_item: Selectable = null
	if highlighted_item != null:
		next_item_index = selectable_children.find(highlighted_item)
		if direction == INPUT_DIRECTION.PREV:
			next_item_index -= 1
		else:
			next_item_index += 1
	if selectable_children.size() > 0:
		next_item_index %= selectable_children.size()
		next_item = selectable_children[next_item_index]
	return next_item

func set_highlighted_item(new_item: Selectable, hover: bool) -> void:
	if hover:
		if highlighted_item != null:
			highlighted_item.set_hover(false)
		highlighted_item = new_item
	else:
		if highlighted_item == new_item:
			highlighted_item = null
	new_item.set_hover(hover)
# End Region: Navigation and Selection Methods
