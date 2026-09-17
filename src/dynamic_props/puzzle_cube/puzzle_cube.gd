class_name PuzzleCube
extends MeshInstance3D

var front_layer: Array[Vector3] = [
	Vector3(-1.0, 1.0, -1.0), Vector3(-1.0, 1.0, 0.0), Vector3(-1.0, 1.0, 1.0),
	Vector3(-1.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0), Vector3(-1.0, 0.0, 1.0),
	Vector3(-1.0, -1.0, -1.0), Vector3(-1.0, -1.0, 0.0), Vector3(-1.0, -1.0, 1.0)
	]

func _get_nodes_by_layer(layer: Array[Vector3]) -> Array[MeshInstance3D]:
	var nodes: Array[MeshInstance3D] = []
	
	for position_coordinate in layer:
		for node in get_children():
			if node.position.is_equal_approx(position_coordinate):
				nodes.append(node)
				
	return nodes

func _rotate_layer(layer: Array[Vector3], axis: Vector3, degrees: int) -> void:
	var nodes: Array[MeshInstance3D] = _get_nodes_by_layer(layer)
	
	@warning_ignore("integer_division")
	var center_index: int = floor(nodes.size() / 2)
	var pivot_node: MeshInstance3D = nodes[center_index]
	
	for node in nodes:
		if node == pivot_node: 
			continue
		
		node.reparent(pivot_node)
	
	pivot_node.rotate_object_local(axis, deg_to_rad(degrees))
