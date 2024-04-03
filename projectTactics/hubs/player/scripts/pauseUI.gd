extends Control

@export var playerInfo : PlayerData

func _input(event):
	if Input.is_action_just_pressed("pause"): unpause();
	if Input.is_action_just_pressed("quit"): get_tree().quit();

func unpause():
	get_tree().paused = false
	await get_tree().process_frame
	self.visible = false
	%inventory.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func openInventory():
	%inventory.visible = true
	%inventory.clear()
	for item in playerInfo.inventory.values():
		%inventory.add_item("x" + str(playerInfo.itemCounts[item]), item.icon)

func openSettings():
	%inventory.visible = false

func openQuit():
	get_tree().quit()
