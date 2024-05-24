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

func assembleUnit(_trigger):
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
