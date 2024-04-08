extends GridContainer

var freezeButtons:bool = false

func _ready():
	freezeButtons = true
	%fullscreenButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	%vsyncButton.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	freezeButtons = false

func audioPressed():
	%audioMenu.visible = true
	%graphicsMenu.visible = false
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 0.75
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 1

func graphicsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = true
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 0.75
	%keybindsSettingsButton.self_modulate.a = 1

func keybindsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = false
	%keybindsMenu.visible = true
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 0.75

func masterAudioUpdated(value_changed): pass;
func musicAudioUpdated(value_changed): pass;
func combatAudioUpdated(value_changed): pass;
func uiAudioUpdated(value_changed): pass;
func ambientAudioUpdated(value_changed): pass;

func resetAudioPressed():
	%masterSlider.value = 100
	%musicSlider.value = 100
	%combatSlider.value = 100
	%uiSlider.value = 100
	%ambientSlider.value = 100

func fullscreenToggled(toggled_on):
	if freezeButtons: return;
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func vsyncToggled(toggled_on):
	if freezeButtons: return;
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
