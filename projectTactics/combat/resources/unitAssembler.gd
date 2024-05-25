@tool
extends Node3D

enum PartTypes {
	ARM,
	LEG,
	CHEST,
	CORE,
	HEAD,
	LEFTARM,
	RIGHTARM,
	LEFTLEG,
	RIGHTLEG
}

@export var unitParts:Unit

@export var assemble:bool : set = assembleUnit;

func assembleUnit(_trigger=true):
	unitParts.damage = 0
	unitParts.armorRating = 0
	unitParts.speedRating = 0
	unitParts.range = 0
	unitParts.splash = 0
	
	for childPart in get_children(): childPart.free()
	if unitParts.chest != null:
		var chest:Node3D = createChild(unitParts.chest, unitParts.chest.name)
		var head:Node3D = createChild(
			unitParts.head, unitParts.head.name, chest.get_node("headPos"))
		var lArm:Node3D = createChild(
			unitParts.arm, "l" + unitParts.arm.name.capitalize(), chest.get_node("lArmPos"))
		var rArm:Node3D = createChild(
			unitParts.arm, "r" + unitParts.arm.name.capitalize(), chest.get_node("rArmPos"))
		var lLeg:Node3D = createChild(
			unitParts.leg, "l" + unitParts.leg.name.capitalize(), chest.get_node("lLegPos"))
		var rLeg:Node3D = createChild(
			unitParts.leg, "r" + unitParts.leg.name.capitalize(), chest.get_node("rLegPos"))
		var core:Node3D = createChild(
			unitParts.core, unitParts.core.name, chest.get_node("corePos"))
		
		for part in [unitParts.head, unitParts.arm, unitParts.leg, unitParts.core, unitParts.chest]:
			unitParts.damage += part.damage
			unitParts.armorRating += part.armorRating
			unitParts.speedRating += part.speedRating
			unitParts.range += part.range
			unitParts.splash += part.splash

func createChild(childScene, childName, parent=self):
	var newChild = childScene.model.instantiate()
	parent.add_child(newChild)
	makeLocal(newChild)
	newChild.set_owner(owner)
	newChild.position = Vector3()
	newChild.name = childName
	return newChild

func makeLocal(node: Node):
	node.scene_file_path = ""
	node.owner = owner
	for childNode in node.get_children():
		childNode = makeLocal(childNode)
	return node

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
