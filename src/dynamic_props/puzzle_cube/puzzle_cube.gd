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
