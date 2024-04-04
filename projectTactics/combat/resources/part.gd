@tool
extends Resource
class_name Part

@export var name : String = ""
@export_enum("Arm", "Leg", "Chest", "Core", "Head") var type = 0
var strType : Array = ["Arm", "Leg", "Chest", "Core", "Head"]
@export var model : Mesh
@export var icon : Texture2D
@export var cost : int = 0

@export_subgroup("Flavour Text")
@export_multiline var description : String = ""

@export_subgroup("Durability")
@export_range(0, 10000) var maxDurability : int: 
	get: return maxDurability;
	set(newValue):
		maxDurability = newValue
		currentDurability = newValue
@export var currentDurability : int:
	get: return currentDurability;
	set(newValue): currentDurability = clamp(newValue, 0, maxDurability);
	
@export_subgroup("Combat")
@export var damage : int = 0
@export var armorRating : int = 0
@export var speedRating : int = 0
@export_range(0, 10000) var range : int = 0
@export_range(0, 10000) var splash : int = 0
