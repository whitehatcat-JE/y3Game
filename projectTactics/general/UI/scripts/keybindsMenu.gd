extends GridContainer
# Hardcoded keybinds
var lockedKeybinds : Array = [
	"pause",
	"quit",
	"interact"
]
# Editable keybinds
@onready var keybindButtons : Dictionary = {
	"moveUp":$forwardButton,
	"moveDown":$backwardButton,
	"moveLeft":$leftButton,
	"moveRight":$rightButton,
	"moveJump":$jumpButton,
	"moveSprint":$sprintButton
}
# Keybind currently changing
var keybindSelected : String = ""
# Updates keybinds to previous session keybinds
func _ready():
	updateAllKeybinds()
	refreshKeybinds()
	FM.globalLoaded.connect(refreshKeybinds)
# Loads last saved keybinds
func refreshKeybinds():
	for keybind in FM.loadedGlobalData.updatedKeybinds.keys():
		InputMap.action_erase_events(keybind)
		InputMap.action_add_event(keybind, FM.loadedGlobalData.updatedKeybinds[keybind])
	updateAllKeybinds()
# Updates selected keybind with new value
func _input(event):
	# Checks if inputted value is valid
	if !visible or !get_parent().get_parent().visible or keybindSelected == "": return;
	if !InputMap.action_has_event(keybindSelected, event):
		for action in keybindButtons.keys() + lockedKeybinds:
			if InputMap.action_has_event(action, event):
				%inUseAnim.play("fade")
				return
	# Finds name of value
	if event is InputEventKey:
		keybindButtons[keybindSelected].text = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton and event.button_index > 5:
		keybindButtons[keybindSelected].text = "Mouse " + str(event.button_index)
	else: return;
	# Set keybind to new value
	get_viewport().set_input_as_handled()
	InputMap.action_erase_events(keybindSelected)
	InputMap.action_add_event(keybindSelected, event)
	# Save updated keybinds
	FM.loadedGlobalData.updatedKeybinds[keybindSelected] = event
	FM.saveGlobal()
	keybindSelected = ""
	%clearSelectionButton.grab_focus()
# Updates displayed keybinds
func updateAllKeybinds():
	for button in keybindButtons.keys():
		# Checks whether keybind is mouse or keyboard input
		if InputMap.action_get_events(button)[0] is InputEventKey: # Keyboard
			var event = InputMap.action_get_events(button)[0].as_text()
			event = event.rsplit(" (")[0]
			keybindButtons[button].text = event
		else: # Mouse
			keybindButtons[button].text = "Mouse " + str(
				InputMap.action_get_events(button)[0].button_index)
# Selects keybind to change
func focusKeybind(keybind):
	unfocusKeybind()
	keybindSelected = keybind
	keybindButtons[keybind].text = "[ ]"
# Cancels currently selected keybind
func unfocusKeybind():
	if keybindSelected == "": return;
	keybindButtons[keybindSelected].text = InputMap.action_get_events(
		keybindSelected)[0].as_text().rsplit(" (")[0]
	keybindSelected = ""
