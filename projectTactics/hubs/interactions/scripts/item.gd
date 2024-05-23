@tool
extends Node

var interactionType : String = "item"
@export_category("Item Data")
@export_enum("Part", "Misc") var itemType : int = 0 :
	set(value):
		itemType = value
		notify_property_list_changed()
		refreshItem()
@export var part : Part : 
	set(value):
		part = value
		refreshItem()
@export var misc : int

@export var refresh : bool = false :
	set = refreshItem

func _validate_property(property: Dictionary):
	if property.name == "part" and itemType != 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "misc" and itemType != 1:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func refreshItem(_refreshValue = false):
	for child in self.get_children(): child.queue_free();
	if itemType == 0:
		if part != null:
			if part.model != null:
				var newModel = part.model.instantiate()
				self.add_child(newModel)
				newModel.position = Vector3()
				for mesh in getAllChildren(newModel):
					if mesh is MeshInstance3D:
						mesh.create_trimesh_collision()
				for collision in getAllChildren(newModel):
					if collision is CollisionShape3D:
						collision.get_parent().remove_child(collision)
						self.add_child(collision)
				for staticBody in getAllChildren(newModel):
					if staticBody is StaticBody3D:
						staticBody.queue_free()
				return

func getAllChildren(node):
	var nodes : Array = []

	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(getAllChildren(N))
		else:
			nodes.append(N)
	return nodes

func setOverlay(overlay:Material):
	for child in self.get_children(true):
		if child is MeshInstance3D:
			child.material_overlay = overlay
