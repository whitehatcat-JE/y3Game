extends Resource
class_name PlayerData

const INVENTORY_SIZE:int = 100

@export var balance:int = 12500

var inventory:Dictionary = {}
var itemCounts:Dictionary = {}

func addToInventory(item):
	if inventory.find_key(item) != null:
		itemCounts[item] += 1
		return
	for idx in range(INVENTORY_SIZE):
		if idx not in inventory:
			inventory[idx] = item
			itemCounts[item] = 1
			return

func removeFromInventory(item, amt = 1000000):
	if inventory.find_key(item) == null:
		printerr("Item not found")
		return
	itemCounts[item] -= amt
	if itemCounts[item] <= 0:
		itemCounts.erase(item)
		inventory.erase(inventory.find_key(item))

func getInventoryCount(item):
	if item in itemCounts: return itemCounts[item];
	else: return 0;
