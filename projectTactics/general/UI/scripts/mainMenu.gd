extends Control

func newGamePressed():
	get_tree().change_scene_to_file("res://hubs/city/city.tscn")

func loadGamePressed():
	%settingsMenu.visible = false

func settingsPressed():
	%settingsMenu.visible = true

func quitPressed(): get_tree().quit();
