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
	if !has_node("mesh"): return;
	if itemType == 0:
		if part != null:
			if part.model != null:
				$mesh.mesh = part.model
				$hitbox.shape = $mesh.mesh.create_trimesh_shape()
				return
		$mesh.mesh = BoxMesh.new()
		$hitbox.shape = $mesh.mesh.create_trimesh_shape()
