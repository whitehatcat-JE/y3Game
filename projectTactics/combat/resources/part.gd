@tool
extends Resource
class_name Part

signal partUpdated
# Type Enumerators
enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}

enum PartTypes {
	ARM,
	LEG,
	CHEST,
	CORE,
	HEAD
}
# Item type
var itemType : ItemTypes = ItemTypes.PART
# General metadata
@export var name : String = ""
@export var type:PartTypes = PartTypes.ARM :
	get: return type;
	set(value):
		type = value
		emit_signal("partUpdated")
		
var strType : Array = ["Arm", "Leg", "Chest", "Core", "Head"]
@export var model : PackedScene :
	get: return model;
	set(value):
		emit_signal("partUpdated")
		model = value
@export var cost : int = 0
# Flavour text
@export_subgroup("Flavour Text")
@export_multiline var description : String = " "
# Initial durability
@export_subgroup("Durability")
@export_range(0, 10000) var maxDurability : int: 
	get: return maxDurability;
	set(newValue):
		maxDurability = newValue
		currentDurability = newValue
@export var currentDurability : int:
	get: return currentDurability;
	set(newValue): currentDurability = clamp(newValue, 0, maxDurability);
# Combat metadata
@export_subgroup("Combat")
@export var damage : int = 0
@export var armorRating : int = 0
@export var speedRating : int = 0
@export_range(0, 10000) var range : int = 0
@export_range(0, 10000) var splash : int = 0
