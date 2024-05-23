extends Node3D

func getAABB():
	var meshes:Array[MeshInstance3D] = []
	for mesh in getAllChildren(self):
		if mesh is MeshInstance3D:
			mesh.create_trimesh_collision()
			meshes.append(mesh)
	if len(meshes) == 0: return AABB();
	
	var posA:Vector3 = meshes[0].get_aabb().position + localPosition(meshes[0])
	var posB:Vector3 = posA + meshes[0].get_aabb().size
	
	for mesh in meshes:
		var meshPosA:Vector3 = mesh.get_aabb().position + localPosition(mesh)
		posA.x = min(posA.x, meshPosA.x)
		posA.y = min(posA.y, meshPosA.y)
		posA.z = min(posA.z, meshPosA.z)
	return AABB(posA, posB - posA)

func localPosition(node):
	return node.global_position - self.global_position

func getAllChildren(node):
	var nodes : Array = []

	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(getAllChildren(N))
		else:
			nodes.append(N)
	return nodes
