@tool
extends Node

var interactionType : String = "item"
# Item data
@export_category("Item Data")
@export_enum("Part", "Misc") var itemType : int = 0 :
	set(value):
		itemType = value
		notify_property_list_changed()
		refreshItem()
@export var part : Part : 
	set(value):
		part = value
		part.partUpdated.connect(refreshItem)
		refreshItem()
@export var misc : int
# Refresh button
@export var refresh : bool = false :
	set = refreshItem

var meshes:Array[MeshInstance3D] = []
# Filters displayed variables to only include ones associated with set item type
func _validate_property(property: Dictionary):
	if property.name == "part" and itemType != 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "misc" and itemType != 1:
		property.usage = PROPERTY_USAGE_NO_EDITOR
# Updates displayed item with current item data
func refreshItem(_refreshValue = false):
	# Prevents item from being loaded before scene tree
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	# Removes pre-existing item
	for child in self.get_children(): child.queue_free();
	meshes.clear()
	# Checks whether item is displayable type
	if itemType == 0:
		if part != null:
			if part.model != null:
				# Displays item model
				var newModel = part.model.instantiate()
				self.add_child(newModel)
				if newModel.get_node_or_null("inverted") != null:
					if newModel.invertedVariant: newModel.get_child(0).free();
					else: newModel.get_child(1).free();
				newModel.position = Vector3()
				# Creates interaction collisions
				for mesh in getAllChildren(newModel):
					if mesh is MeshInstance3D and mesh.mesh != null:
						var newMeshCollision:CollisionShape3D = CollisionShape3D.new()
						self.add_child(newMeshCollision)
						newMeshCollision.set_owner(self)
						newMeshCollision.shape = mesh.mesh.create_trimesh_shape()
						newMeshCollision.global_transform = mesh.global_transform
						meshes.append(mesh)
				self.name = part.name
# Recursively gets all children of given node
func getAllChildren(node):
	var nodes : Array = []
	for N in node.get_children():
		nodes.append(N)
		if N.get_child_count() > 0: nodes.append_array(getAllChildren(N));
	return nodes
# Updates mesh materials
func setOverlay(overlay:Material):
	for child in self.get_children(true):
		if child is MeshInstance3D:
			child.material_overlay = overlay
# Calculates visibilty rect of displayed item
func getAABB():
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
func localPosition(node): return (node.global_position - self.global_position) / self.scale;
