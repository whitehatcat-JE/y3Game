@tool
extends Node3D

enum PartTypes {
	ARM,
	LEG,
	CHEST,
	CORE,
	HEAD
}

@export var type:PartTypes = PartTypes.ARM :
	get: return type;
	set(value):
		type = value

@export var updateChildren:bool = false : set = regenerateChildren;

func regenerateChildren(_update):
	for child in self.get_children(): child.queue_free();
	match type:
		PartTypes.ARM:
			createChild(MeshInstance3D, "lowerArm",
			createChild(Node3D, "lowerArmPivot",
			createChild(MeshInstance3D, "upperArm")))
		PartTypes.LEG:
			createChild(MeshInstance3D, "lowerLeg",
			createChild(Node3D, "lowerLegPivot",
			createChild(MeshInstance3D, "upperLeg")))
		PartTypes.CHEST:
			createChild(MeshInstance3D, "chest")
			createChild(Node3D, "corePos")
			createChild(Node3D, "headPos")
			createChild(Node3D, "lArmPos")
			createChild(Node3D, "rArmPos")
			createChild(Node3D, "lLegPos")
			createChild(Node3D, "rLegPos")
		PartTypes.CORE:
			createChild(MeshInstance3D, "core")
		PartTypes.HEAD:
			createChild(MeshInstance3D, "head")

func getAABB():
	var meshes:Array[MeshInstance3D] = []
	for mesh in getAllChildren(self):
		if mesh is MeshInstance3D:
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

func createChild(childType, childName, parent=self):
	var newChild = childType.new()
	parent.add_child(newChild)
	newChild.set_owner(self)
	newChild.position = Vector3()
	newChild.name = childName
	return newChild
