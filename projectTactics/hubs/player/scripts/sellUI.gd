extends Control

enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}

var merchantIdentifer:String = ""

var selectedItem
var selectedItemType:ItemTypes = ItemTypes.ALL

var spawnedItems:Array[Button] = []
var spawnedSales:Array[Button] = []
var salesQueue:Dictionary = {}

var isActive:bool = false

@export var playerInfo : PlayerData

func _ready():
	playerInfo = FM.playerData
	
	%sellAllFilter.button_up.connect(setItemType.bind(ItemTypes.ALL))
	%sellPartsFilter.button_up.connect(setItemType.bind(ItemTypes.PART))
	%sellUnitsFilter.button_up.connect(setItemType.bind(ItemTypes.UNIT))
	%sellFishFilter.button_up.connect(setItemType.bind(ItemTypes.FISH))
	
	FM.gameSaved.connect(refreshItems)

func enable(identifier:String):
	merchantIdentifer = identifier
	isActive = true
	visible = true
	refreshItems()

func disable():
	for item in spawnedItems: item.queue_free()
	for item in spawnedSales: item.queue_free()
	salesQueue.clear()
	spawnedItems.clear()
	spawnedSales.clear()
	isActive = false
	visible = false

func cancelPressed():
	disable()
	GS.emit_signal("triggerDialogue", merchantIdentifer + "Denied")

func confirmPressed():
	for item in salesQueue.keys():
		playerInfo.balance += (item.cost / 2) * salesQueue[item]
		playerInfo.inventory[item] -= salesQueue[item]
		if playerInfo.inventory[item] <= 0:
			playerInfo.inventory.erase(item)
	disable()
	GS.emit_signal("triggerDialogue", merchantIdentifer + "Sold")

func refreshItems():
	for item in spawnedItems: item.queue_free();
	spawnedItems.clear()
	
	var allItems:Array = playerInfo.inventory.keys()
	var filteredItems:Array = []
	
	if selectedItemType == ItemTypes.ALL: filteredItems = allItems;
	else:
		for item in allItems:
			if item.itemType == selectedItemType:
				filteredItems.append(item)
	
	var salesAmt:int = 0
	
	for item in salesQueue.keys():
		if item not in playerInfo.inventory.keys():
			salesQueue.erase(item)
	
	for item in salesQueue.keys():
		if playerInfo.inventory[item] - salesQueue[item] <= 0:
			filteredItems.erase(item)
		salesAmt += salesQueue[item] * (item.cost / 2)
	
	%salesTotalAmt.text = "[p align=right]" + str(playerInfo.balance + salesAmt) + "G"
	%salesProfitAmt.text = "(+" + str(salesAmt) + "G)"
	
	for item in filteredItems:
		var newItem:Button = %sellItemTemplate.duplicate()
		%sellItemGrid.add_child(newItem)
		newItem.text = item.name
		if item in salesQueue.keys():
			if playerInfo.inventory[item] - salesQueue[item] > 1:
				newItem.text += " (" + str(playerInfo.inventory[item] - salesQueue[item]) + ")"
		else:
			if playerInfo.inventory[item] > 1:
				newItem.text += " (" + str(playerInfo.inventory[item]) + ")"
		newItem.text += " (" + str(item.cost / 2.0) + "G)"
		newItem.visible = true
		newItem.button_up.connect(inventoryItemSelected.bind(item))
		spawnedItems.append(newItem)
	
	for item in spawnedSales: item.queue_free();
	spawnedSales.clear()
	
	for item in salesQueue.keys():
		var newItem:Button = %salesItemTemplate.duplicate()
		%salesItemGrid.add_child(newItem)
		newItem.text = item.name
		if salesQueue[item] > 1:
			newItem.text += " (" + str(salesQueue[item]) + ")"
		newItem.text += " (" + str(item.cost / 2.0) + "G)"
		newItem.visible = true
		newItem.button_up.connect(salesItemSelected.bind(item))
		spawnedSales.append(newItem)

func inventoryItemSelected(item):
	if item in salesQueue.keys(): salesQueue[item] += 1;
	else: salesQueue[item] = 1;
	refreshItems()

func salesItemSelected(item):
	salesQueue[item] -= 1
	if salesQueue[item] <= 0:
		salesQueue.erase(item)
	refreshItems()

func setItemType(type:ItemTypes):
	selectedItemType = type
	refreshItems()
