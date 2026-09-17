class_name PuzzleCube
extends MeshInstance3D

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
	pivot_node.rotate_object_local(axis, deg_to_rad(degrees))
	
	for node in nodes:
		# Orthonormalize the transforms to avoid precision errors
		node.transform = node.transform.orthonormalized()
		
		if node == pivot_node: 
			continue
		
		# Reparent back to the root of the PuzzleCube
		node.reparent(original_owner_node)
