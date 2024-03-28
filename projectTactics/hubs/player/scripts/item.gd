extends Node

const INTERACTION_TYPE : String = "item"
@export_category("Item")
@export_subgroup("Flavour")
@export var itemName : String = ""
@export var description : String = ""
@export_subgroup("Traits")
@export var armor : int = 0
@export var effects : Array[int] = [] 
