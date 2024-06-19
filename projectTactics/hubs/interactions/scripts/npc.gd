@tool
extends Area3D
# Interaction metadata
@export_category("General")
@export_enum("Dialogue", "Teleport", "Map", "Switch Scene") var type:int = 0 :
	set(value):
		type = value
		notify_property_list_changed()
		updateChildren()
# Teleport specific metadata
@export_category("Scene")
@export_file() var scene:String = ""
@export var entranceName:String = ""
# Dialogue specific metadata
@export_category("Dialogue Identifiers")
@export var introduction:String = ""
@export var standard:String = ""
# Map specific metadata
@export_category("Map")
@export_file() var map:String = ""
@export var exitPoint:String = ""
# Caches any interaction player has had with self
var hasIntroduced:bool = false
# Stores location to teleport player to
var teleportPos:Vector3 = Vector3()
var teleportNode:Node3D = null
# Shows only interaction specific metadata
func _validate_property(property: Dictionary):
	if property.name == "introduction" and type != 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "standard" and type != 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "scene" and type != 3:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "entranceName" and type != 3:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "map" and type != 2:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "exitPoint" and type != 2:
		property.usage = PROPERTY_USAGE_NO_EDITOR
# Changes children based on selected interaction type
func updateChildren():
	# Removes pre-existing children
	if teleportNode != null:
		teleportNode.queue_free()
		teleportNode = null
	match type:
		1: # Creates teleport specific children
			teleportNode = Node3D.new()
			teleportNode.name = "teleportPosition"
			self.add_child(teleportNode)
			teleportNode.set_owner(self)
			teleportNode.position = Vector3()
			
			var pointer:RayCast3D = RayCast3D.new()
			teleportNode.add_child(pointer)
			pointer.set_owner(teleportNode)
			pointer.enabled = false
			pointer.target_position = Vector3(0, 0, -10)
# Returns dialogue metadata
func getIdentifier():
	if hasIntroduced: return standard;
	hasIntroduced = true
	return introduction if introduction != "" else standard
