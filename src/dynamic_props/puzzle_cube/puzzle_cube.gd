class_name PuzzleCube
extends MeshInstance3D

@export var scramble_length: int = 20

# F = Vector3.RIGHT, 90 degrees
var front_layer: Array[Vector3] = [
	Vector3(-1.0, 1.0, -1.0), Vector3(-1.0, 1.0, 0.0), Vector3(-1.0, 1.0, 1.0),
	Vector3(-1.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0), Vector3(-1.0, 0.0, 1.0),
	Vector3(-1.0, -1.0, -1.0), Vector3(-1.0, -1.0, 0.0), Vector3(-1.0, -1.0, 1.0)
	]

# B = Vector3.RIGHT, -90 degrees
var back_layer: Array[Vector3] = [
	Vector3(1.0, 1.0, 1.0), Vector3(1.0, 1.0, 0.0), Vector3(1.0, 1.0, -1.0),
	Vector3(1.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0), Vector3(1.0, 0.0, -1.0),
	Vector3(1.0, -1.0, 1.0), Vector3(1.0, -1.0, 0.0), Vector3(1.0, -1.0, -1.0)
]

# L = Vector3.BACK, 90 degrees
var left_layer: Array[Vector3] = [
	Vector3(1.0, 1.0, -1.0), Vector3(0.0, 1.0, -1.0), Vector3(-1.0, 1.0, -1.0),
	Vector3(1.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0), Vector3(-1.0, 0.0, -1.0),
	Vector3(1.0, -1.0, -1.0), Vector3(0.0, -1.0, -1.0), Vector3(-1.0, -1.0, -1.0),
]

# R = Vector3.BACK, -90 degrees
var right_layer: Array[Vector3] = [
	Vector3(-1.0, 1.0, 1.0), Vector3(0.0, 1.0, 1.0), Vector3(1.0, 1.0, 1.0),
	Vector3(-1.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 1.0),
	Vector3(-1.0, -1.0, 1.0), Vector3(0.0, -1.0, 1.0), Vector3(1.0, -1.0, 1.0)
]

# U = Vector3.DOWN, 90 degrees
var top_layer: Array[Vector3] = [
	Vector3(-1.0, 1.0, -1.0), Vector3(-1.0, 1.0, 0.0), Vector3(-1.0, 1.0, 1.0),
	Vector3(0.0, 1.0, -1.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 1.0, 1.0),
	Vector3(1.0, 1.0, -1.0), Vector3(1.0, 1.0, 0.0), Vector3(1.0, 1.0, 1.0),
]

# D = Vector3.DOWN, -90 degrees
var bottom_layer: Array[Vector3] = [
	Vector3(-1.0, -1.0, -1.0), Vector3(-1.0, -1.0, 0.0), Vector3(-1.0, -1.0, 1.0),
	Vector3(0.0, -1.0, -1.0), Vector3(0.0, -1.0, 0.0), Vector3(0.0, -1.0, 1.0),
	Vector3(1.0, -1.0, -1.0), Vector3(1.0, -1.0, 0.0), Vector3(1.0, -1.0, 1.0)
]

var moves = {
	"front": [front_layer, Vector3.RIGHT, 90],
	"back": [back_layer, Vector3.RIGHT, -90],
	"left": [left_layer, Vector3.BACK, 90],
	"right": [right_layer, Vector3.BACK, -90],
	"up": [top_layer, Vector3.DOWN, 90],
	"down": [bottom_layer, Vector3.DOWN, -90]
}

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	_scramble_cube(scramble_length)

func _input(event: InputEvent) -> void:
	for action in moves:
		if event.is_action_pressed(action):
			var move = moves[action]

			var layer = move[0]
			var axis = move[1]
			var degrees = move[2]
			
			# Let's us handle counterclockwise moves without any more effort
			if Input.is_key_pressed(KEY_SHIFT):
				degrees *= -1
			
			_rotate_layer(layer, axis, degrees)

# Finds and returns all MeshInstance3D nodes whose positions match
# the positions specified in the given layer.
func _get_nodes_by_layer(layer: Array[Vector3]) -> Array[MeshInstance3D]:
	var nodes: Array[MeshInstance3D] = []
	
	# Check every position in the layer against every child node.
	for position_coordinate in layer:
		for node in get_children():
			# Use .is_equal_approx due to some floating point precision issues
			if node.position.is_equal_approx(position_coordinate):
				nodes.append(node)
				
	return nodes

# Rotates all nodes belonging to a layer around the layer's centre.
func _rotate_layer(layer: Array[Vector3], axis: Vector3, degrees: int) -> void:
	# Get the actual nodes corresponding to the positions in the layer.
	var nodes: Array[MeshInstance3D] = _get_nodes_by_layer(layer)
	
	# Calculate the index of the node in the middle of the layer.
	# Integer division is intentional because we need an array index.
	@warning_ignore("integer_division")
	var center_index: int = floor(nodes.size() / 2)
	var pivot_node: MeshInstance3D = nodes[center_index]
	
	# Save original owner to reverse the reparenting to the pivot after the transform
	var original_owner_node: MeshInstance3D = pivot_node.get_parent()
	
	# Reparent every node to the centre node so that the centre
	# node becomes the pivot for the rotation.
	for node in nodes:
		if node == pivot_node: 
			continue
		
		node.reparent(pivot_node)
	
	# Rotate the pivot and all of its children around the given axis.
	var tween: Tween = create_tween()
	
	var start_rotation := pivot_node.rotation
	
	tween.tween_method(
		func(angle): 
			# Reset the rotation each time 
			# and then you rotate it a partial amount of the rotation again
			# the rendered frame only cares where it ends, so it shows the smooth rotation
			# and NOT the snapping back to prevent over-rotation from accumulating angles
			pivot_node.rotation = start_rotation
			pivot_node.rotate_object_local(axis, angle),
		0.0,
		deg_to_rad(degrees),
		0.5
	)

	await tween.finished

	for node in nodes:
		# Orthonormalize the transforms to avoid precision errors
		node.transform = node.transform.orthonormalized()
		
		if node == pivot_node: 
			continue
		
		# Reparent back to the root of the PuzzleCube
		node.reparent(original_owner_node)

# Scrambles the puzzle cube out of the completed state
func _scramble_cube(sequence_length: int) -> void:
	rng.randomize()
		
	var previous_move: int = -1
	var previous_direction: int = 0
	
	for i in sequence_length: 
		var move: int
		var direction: int

		while true:
			move = rng.randi_range(0, 5)
			direction = 1 if rng.randi_range(0, 1) == 0 else -1

			# Don't immediately undo the previous move.
			if move != previous_move or direction != -previous_direction:
				break
			
		match move: 
			0: await _rotate_layer(front_layer, Vector3.RIGHT, 90 * direction) 
			1: await _rotate_layer(back_layer, Vector3.RIGHT, -90 * direction) 
			2: await _rotate_layer(left_layer, Vector3.BACK, 90 * direction) 
			3: await _rotate_layer(right_layer, Vector3.BACK, -90 * direction) 
			4: await _rotate_layer(top_layer, Vector3.DOWN, 90 * direction)
			5: await _rotate_layer(bottom_layer, Vector3.DOWN, -90 * direction)
	
		previous_move = move
		previous_direction = direction
