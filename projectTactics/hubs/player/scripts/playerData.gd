extends Resource
class_name PlayerData
# Enumerators
enum Locations {
	CAVE,
	CITY,
	WORKSHOP
}
# Constants
const INVENTORY_SIZE:int = 100
# Player metadata
@export var balance:int = 50000

@export var inventory:Dictionary = {}

@export var playerName:String = "Player"
@export var playTime:int = 0

@export var currentLocation:Locations = Locations.CAVE
@export var hasFishingRod:bool = false
# Possible player locations
var locationStrToEnum:Dictionary = {
	"cave":Locations.CAVE,
	"city":Locations.CITY,
	"workshop":Locations.WORKSHOP
}
# Updates player metadata with loaded data
func constructor(values : PlayerData):
	balance = values.balance
	inventory = values.inventory
	playerName = values.playerName
	playTime = values.playTime
	currentLocation = values.currentLocation
	hasFishingRod = values.hasFishingRod
# Adds given item to inventory
func addToInventory(item, count:int = 1):
	if item in inventory.keys(): inventory[item] += count;
	else: inventory[item] = count;
	FM.saveGame()
# Removes item from inventory
func removeFromInventory(item, amt = 1000000):
	if item in inventory:
		inventory[item] -= amt
		if inventory[item] <= 0: inventory.erase(item);
	FM.saveGame()
# Returns the amount of a given item in inventory
func getInventoryCount(item):
	if item in inventory.keys(): return inventory[item];
	return 0
# Updates stored player location
func changeLocation(newLocation:String):
	if newLocation in locationStrToEnum.keys():
		currentLocation = locationStrToEnum[newLocation]
		FM.saveGame()
