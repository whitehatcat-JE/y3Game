extends Resource
class_name PlayerData

const INVENTORY_SIZE:int = 100

@export var balance:int = 12500

@export var inventory:Dictionary = {}
@export var itemCounts:Dictionary = {}

@export var playerName:String = "Player"
@export var playTime:int = 0


func constructor(values : PlayerData):
	balance = values.balance
	inventory = values.inventory
	itemCounts = values.itemCounts
	playerName = values.playerName
	playTime = values.playTime

func addToInventory(item):
	if inventory.find_key(item) != null:
		itemCounts[item] += 1
		return
	for idx in range(INVENTORY_SIZE):
		if idx not in inventory:
			inventory[idx] = item
			itemCounts[item] = 1
			return
	
	FM.saveGame()

func removeFromInventory(item, amt = 1000000):
	if inventory.find_key(item) == null:
		printerr("Item not found")
		return
	itemCounts[item] -= amt
	if itemCounts[item] <= 0:
		itemCounts.erase(item)
		inventory.erase(inventory.find_key(item))
	
	FM.saveGame()

func getInventoryCount(item):
	if item in itemCounts: return itemCounts[item];
	else: return 0;
