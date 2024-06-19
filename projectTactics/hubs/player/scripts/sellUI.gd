extends Control
# Enumerators
enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}
# Merchant identifer, for unique merchant options
var merchantIdentifer:String = ""
# Sell menu variables
var selectedItem
var selectedItemType:ItemTypes = ItemTypes.ALL

var spawnedItems:Array[Button] = []
var spawnedSales:Array[Button] = []
var salesQueue:Dictionary = {}

var isActive:bool = false
# Player inventory
@export var playerInfo : PlayerData
# Sell menu initalization
func _ready():
	# Finds player inventory
	playerInfo = FM.playerData
	# Connects buttons to relevant functions
	%sellAllFilter.button_up.connect(setItemType.bind(ItemTypes.ALL))
	%sellPartsFilter.button_up.connect(setItemType.bind(ItemTypes.PART))
	%sellFishFilter.button_up.connect(setItemType.bind(ItemTypes.FISH))
	
	FM.gameSaved.connect(refreshItems)
# Show sell menu
func enable(identifier:String):
	merchantIdentifer = identifier
	isActive = true
	visible = true
	SFX.playCloseMenu()
	refreshItems()
# Hide sell menu
func disable():
	# Clear transactions
	for item in spawnedItems: item.queue_free()
	for item in spawnedSales: item.queue_free()
	salesQueue.clear()
	spawnedItems.clear()
	spawnedSales.clear()
	# Hide menu
	isActive = false
	visible = false
	SFX.playCloseMenu()
# Cancels transaction
func cancelPressed():
	disable()
	GS.emit_signal("triggerDialogue", merchantIdentifer + "Denied")
# Completes transaction
func confirmPressed():
	# Sells chosen items
	for item in salesQueue.keys():
		# Increases player balance
		if item.itemType in [ItemTypes.PART, ItemTypes.UNIT]:
			playerInfo.balance += (item.cost / 2) * salesQueue[item]
		else:
			playerInfo.balance += (item.cost) * salesQueue[item]
		# Remove item from inventory
		playerInfo.inventory[item] -= salesQueue[item]
		if playerInfo.inventory[item] <= 0:
			playerInfo.inventory.erase(item)
	# Hide UI
	disable()
	# Notify player of successful transaction
	GS.emit_signal("triggerDialogue", merchantIdentifer + "Sold")
# Updates displayed items
func refreshItems():
	# Removes currently displayed items
	for item in spawnedItems: item.queue_free();
	spawnedItems.clear()
	# Finds all items in player inventory
	var allItems:Array = playerInfo.inventory.keys()
	var filteredItems:Array = []
	# Filters items to only include ones that match given filter
	if selectedItemType == ItemTypes.ALL: # Show all items
		for item in allItems:
			if item.itemType in [ItemTypes.FISH, ItemTypes.PART]:
				filteredItems.append(item)
	else: # Show specific type
		for item in allItems:
			if item.itemType == selectedItemType:
				filteredItems.append(item)
	# Clears previous transaction state
	var salesAmt:int = 0
	for item in salesQueue.keys():
		if item not in playerInfo.inventory.keys():
			salesQueue.erase(item)
	# Calculates total sales profit
	for item in salesQueue.keys():
		# Removes items if none remain
		if playerInfo.inventory[item] - salesQueue[item] <= 0:
			filteredItems.erase(item)
		# Increase profit by half item value if not fish
		if item.itemType in [ItemTypes.PART, ItemTypes.UNIT]:
			salesAmt += salesQueue[item] * (item.cost / 2)
		else:
			salesAmt += salesQueue[item] * (item.cost)
	# Update displayed profit
	%salesTotalAmt.text = "[p align=right]" + str(playerInfo.balance + salesAmt) + "G"
	%salesProfitAmt.text = "(+" + str(salesAmt) + "G)"
	# Displays all items still in player inventory
	for item in filteredItems:
		# Create new sellable item
		var newItem:Button = %sellItemTemplate.duplicate()
		%sellItemGrid.add_child(newItem)
		# Name item
		newItem.text = item.name
		# Add amount to name
		if item in salesQueue.keys():
			if playerInfo.inventory[item] - salesQueue[item] > 1:
				newItem.text += " (" + str(playerInfo.inventory[item] - salesQueue[item]) + ")"
		else:
			if playerInfo.inventory[item] > 1:
				newItem.text += " (" + str(playerInfo.inventory[item]) + ")"
		# Add value to name
		if item.itemType in [ItemTypes.PART, ItemTypes.UNIT]:
			newItem.text += " (" + str(int(item.cost / 2.0)) + "G)"
		else:
			newItem.text += " (" + str(int(item.cost)) + "G)"
		# Connect item to self
		newItem.visible = true
		newItem.button_up.connect(inventoryItemSelected.bind(item))
		spawnedItems.append(newItem)
	# Removes all displayed items in inventory
	for item in spawnedSales: item.queue_free();
	spawnedSales.clear()
	# Displays all items player is attempting to sell
	for item in salesQueue.keys():
		# Create new selling item
		var newItem:Button = %salesItemTemplate.duplicate()
		%salesItemGrid.add_child(newItem)
		# Name item
		newItem.text = item.name
		# Add amount to name
		if salesQueue[item] > 1:
			newItem.text += " (" + str(salesQueue[item]) + ")"
		# Add value to name
		if item.itemType in [ItemTypes.PART, ItemTypes.UNIT]:
			newItem.text += " (" + str(int(item.cost / 2.0)) + "G)"
		else:
			newItem.text += " (" + str(int(item.cost)) + "G)"
		# Connect item to self
		newItem.visible = true
		newItem.button_up.connect(salesItemSelected.bind(item))
		spawnedSales.append(newItem)
	SFX.connectAllButtons()
# Add instance of item to sales queue
func inventoryItemSelected(item):
	if item in salesQueue.keys(): salesQueue[item] += 1;
	else: salesQueue[item] = 1;
	refreshItems()
# Remove instance of item from sales queue
func salesItemSelected(item):
	salesQueue[item] -= 1
	if salesQueue[item] <= 0:
		salesQueue.erase(item)
	refreshItems()
# Update item filter
func setItemType(type:ItemTypes):
	selectedItemType = type
	refreshItems()
