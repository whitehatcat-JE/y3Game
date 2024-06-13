extends Resource
class_name PlayerData

enum Locations {
	CAVE,
	CITY,
	WORKSHOP
}

const INVENTORY_SIZE:int = 100

@export var balance:int = 50000

@export var inventory:Dictionary = {}

@export var playerName:String = "Player"
@export var playTime:int = 0

@export var currentLocation:Locations = Locations.CAVE

var locationStrToEnum:Dictionary = {
	"cave":Locations.CAVE,
	"city":Locations.CITY,
	"workshop":Locations.WORKSHOP
}

func constructor(values : PlayerData):
	balance = values.balance
	inventory = values.inventory
	playerName = values.playerName
	playTime = values.playTime
	currentLocation = values.currentLocation

func addToInventory(item):
	if item in inventory.keys(): inventory[item] += 1;
	else: inventory[item] = 1;
	FM.saveGame()

func removeFromInventory(item, amt = 1000000):
	if item in inventory:
		inventory[item] -= amt
		if inventory[item] <= 0: inventory.erase(item);
	FM.saveGame()

func getInventoryCount(item):
	if item in inventory.keys(): return inventory[item];
	return 0

func changeLocation(newLocation:String):
	if newLocation in locationStrToEnum.keys():
		currentLocation = locationStrToEnum[newLocation]
		FM.saveGame()
