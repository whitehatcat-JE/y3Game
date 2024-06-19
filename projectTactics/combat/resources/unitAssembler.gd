@tool
extends Node3D
# Enumerators
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
# Unit to assemble
@export var unitParts:Unit
@export var assemble:bool : set = assembleUnit;
# Generates unit model
func assembleUnit(_trigger=true):
	# Clear previous unit stats
	if "damage" in unitParts:
		unitParts.damage = 0
		unitParts.armorRating = 0
		unitParts.speedRating = 0
		unitParts.range = 0
		unitParts.splash = 0
	# Clear previous unit model
	for childPart in get_children(): childPart.free()
	# Confirm unit isn't empty
	if unitParts.chest != null:
		# Create unit parts
		var chest:Node3D = createChild(unitParts.chest)
		var head:Node3D = createChild(
			unitParts.head, chest.get_node("headPos"))
		var lArm:Node3D = createChild(
			unitParts.arm, chest.get_node("lArmPos"))
		var rArm:Node3D = createChild(
			unitParts.arm, chest.get_node("rArmPos"), true)
		var lLeg:Node3D = createChild(
			unitParts.leg, chest.get_node("lLegPos"))
		var rLeg:Node3D = createChild(
			unitParts.leg, chest.get_node("rLegPos"), true)
		var core:Node3D = createChild(
			unitParts.core, chest.get_node("corePos"))
		# Calculate total unit stats
		if "damage" in unitParts:
			for part in [unitParts.head, unitParts.arm, unitParts.leg, unitParts.core, unitParts.chest]:
				unitParts.damage += part.damage
				unitParts.armorRating += part.armorRating
				unitParts.speedRating += part.speedRating
				unitParts.range += part.range
				unitParts.splash += part.splash
# Generates part as child of given parent
func createChild(childScene, parent=self, inverted:bool = false):
	# Creates part instance
	var newChild = childScene.model.instantiate()
	# Assigns instance to parent
	parent.add_child(newChild)
	makeLocal(newChild)
	newChild.set_owner(owner)
	newChild.position = Vector3()
	# Check whether child is inverted variant (E.G left vs right arm)
	if newChild.get_node_or_null("inverted") != null:
		if inverted: # Replace model with inverted variant
			var replacementName:String = newChild.get_child(0).name
			newChild.get_child(0).free()
			newChild.get_child(0).name = replacementName
		else: # Remove inverted variant
			newChild.get_child(1).free()
	return newChild
# Reparent all children of node to sceneTree
func makeLocal(node: Node):
	node.scene_file_path = ""
	node.owner = owner
	for childNode in node.get_children():
		childNode = makeLocal(childNode)
	return node
# Calculates visibilty rect of unit
func getAABB():
	# Finds all child meshes
	var meshes:Array[MeshInstance3D] = []
	for mesh in getAllChildren(self):
		if mesh is MeshInstance3D:
			meshes.append(mesh)
	if len(meshes) == 0: return AABB();
	# Finds visibilty rect of first mesh
	var posA:Vector3 = meshes[0].get_aabb().position + localPosition(meshes[0])
	var posB:Vector3 = posA + meshes[0].get_aabb().size
	# Enlarges visibilty rect to fit any additional meshes
	for mesh in meshes:
		var meshPosA:Vector3 = mesh.get_aabb().position + localPosition(mesh)
		posA.x = min(posA.x, meshPosA.x)
		posA.y = min(posA.y, meshPosA.y)
		posA.z = min(posA.z, meshPosA.z)
	return AABB(posA, posB - posA)
# Calculates position of node adjusted to item scaling
func localPosition(node): return node.global_position - self.global_position;
# Recursively gets all children of given node
func getAllChildren(node):
	var nodes : Array = []
	for N in node.get_children():
		nodes.append(N)
		if N.get_child_count() > 0: nodes.append_array(getAllChildren(N));
	return nodes
