extends Node
# Constants
const MIN_VOLUME:float = -20.0
# Estabish button connections to playClick function
func connectAllButtons():
	# Recursively scans all nodes for button types
	var allNodes:Array = getAllChildren(get_tree().root)
	for curNode in allNodes:
		if curNode is Button and !curNode.is_connected("button_up", playClick):
			# Connect button to playerClick function
			curNode.button_up.connect(playClick)
# SFX audio events
func playClick(): $click.play();
func playCloseMenu(): $closeMenu.play(0.2);
# Recursively find all children of node
func getAllChildren(node):
	var nodes:Array = []
	for N in node.get_children():
		nodes.append(N)
		if N.get_child_count() > 0: nodes.append_array(getAllChildren(N));
	return nodes
# Update SFX volumes
func changeVolume(newVolume:float):
	if newVolume <= MIN_VOLUME: newVolume = -80; # Mute SFX
	$click.volume_db = newVolume
	$closeMenu.volume_db = newVolume
