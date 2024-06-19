extends CharacterBody3D
# Signals
signal interacted(interactionName:String)

# Enumurators
enum FISHING_STATES {
	inactive,
	cast,
	idle,
	reel,
	transitioning
}

# Constants
const PLAYER_SPEED:float = 6.0
const PLAYER_SPRINT:float = 1.5  
const MOUSE_SENSITIVITY:float = 0.003
const DECELERATION:float = 20.0

const JUMP_VELOCITY:float = 4.0
const GRAVITY:float = 10.5
const TERMINAL_VELOCITY:float = 7.0

const BUY_SPEED:float = 150.0
const BULK_INCREASE:float = 0.1
const MAX_BULK_INCREASE:float = 2.0

const MIN_FISHING_ANGLE:float = -PI / 4.0
const MAX_FISHING_ANGLE:float = 0.0
const FISH_INDICATOR_ACCELERATION:float = 10.0
const FISH_MAX_INDICATOR_SPEED:float = 10.0
const FISH_DECREASE_SPEED:float = 150.0
const FISH_INCREASE_SPEED:float = 125.0
const FISH_TURN_SPEED:float = 5.0

# Movement variables
var cameraAngle:float = 0

var verticalVel:float = 0.0

var storedDirection:Vector3 = Vector3()
var isSprinting:bool = false
var isStopped:bool = false
# Item variables
var itemMenuDisplayed:bool = false
var itemBuyProgress:float = 0.0
var purchaseCount : int = 0
var bulkSpeed:float = 1.0
var currentlySelected:Node = null

var unlockedKeys:Array[String] = ["general"]
# Fishing variables
var fishingState:FISHING_STATES = FISHING_STATES.inactive
var currentBobber:RigidBody3D = null
var camTween:Tween = null
var reelingFish:bool = false
var fishCapturing:Fish = null
var fishIndicatorSpeed:float = 0.0
var timeTillDirectionChange:float = 0.0
var movingClockwise:bool = true
var fishSpeed:float = 0.0

# Hub specific variables
@onready var outlineMaterial:ShaderMaterial = preload("res://hubs/interactions/shaders/outlineMat.tres")
@onready var bobberScene:PackedScene = preload("res://hubs/player/scenes/fishingBobber.tscn")

@export var playerInfo:PlayerData
@export var secondaryEntrances:Node3D = null

@export var fishingPool:Array[Fish] = []

# Player initialization
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	playerInfo = FM.playerData
	# Reposition self if teleported
	if secondaryEntrances != null and secondaryEntrances.get_node_or_null(GS.entranceName) != null:
		var targetNode:Node3D = secondaryEntrances.get_node(GS.entranceName)
		global_position = targetNode.global_position + Vector3(0.0, 1.0, 0.0)
		global_rotation = targetNode.global_rotation
	# Connect dialogue event listener
	GS.event.connect(eventTriggered)
	# Update SFX volumes
	SFX.connectAllButtons()
	FM.globalLoaded.connect(updateSFXVolume)
# Input events
func _input(event):
	# Move camera
	if event is InputEventMouseMotion and !isStopped and fishingState == FISHING_STATES.inactive: updateCam(event);
	# Show pause menu
	if Input.is_action_just_pressed("pause"): pause();
	# Trigger fishing system
	if Input.is_action_just_pressed("interact") and !reelingFish and !%interactRay.is_colliding() and !%itemRay.is_colliding() and playerInfo.hasFishingRod:
		match fishingState:
			FISHING_STATES.inactive: # Start fishing
				# Execute fishing cast event
				%reelSFX.play()
				fishingState = FISHING_STATES.transitioning
				%fishingLine.visible = true
				%fishingAnims.play("cast")
				# Spawn in bobber
				var newBobber:RigidBody3D = bobberScene.instantiate()
				get_parent().add_child(newBobber)
				newBobber.global_transform.origin = %bobberSpawnPoint.global_transform.origin + Vector3(0.0, 0.1, 0.0)
				newBobber.apply_impulse(Vector3(10, clamp(%playerCam.rotation.x * 5.0, 0.0, 5.0), 0).rotated(Vector3.UP, rotation.y + PI * 0.5))
				# Connect bobber events to self
				currentBobber = newBobber
				currentBobber.floorContacted.connect(bobberFloorContacted)
				currentBobber.waterContacted.connect(bobberWaterContacted)
				currentBobber.pulling.connect(fishPulling)
				currentBobber.surfacing.connect(fishSurfacing)
				# Transition player to fishing state
				%bobAnim.speed_scale = 0.5
				if %playerCam.rotation.x > MAX_FISHING_ANGLE or %playerCam.rotation.x < MIN_FISHING_ANGLE:
					camTween = get_tree().create_tween()
					camTween.tween_property(%playerCam, "rotation", Vector3(
						0, %playerCam.rotation.y, %playerCam.rotation.z), 1.0
						).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			FISHING_STATES.idle: # Attempt to reel in fish
				if currentBobber.isPulling: # Start fishing minigame
					# Update fishing state
					fishingState = FISHING_STATES.transitioning
					currentBobber.isReeling = true
					fishCapturing = getFish()
					# Reset minigame values
					%fishingProgress.value = 90.0
					%fishingIndicatorPivot.rotation_degrees = randf_range(0.0, 359.0)
					%fishingTargetPivot.rotation_degrees = %fishingIndicatorPivot.rotation_degrees
					%fishingTarget.value = fishCapturing.size
					# Initiate minigame
					reelingFish = true
					%fishing.visible = true
					%fishingAnims.speed_scale = 1.0
					%fishingAnims.play("startReel")
					%reelSFX.play()
				else: # Fail state
					disconnectBobber()
					%fishingAnims.play("withdraw")
# Main player process
func _process(delta):
	# Fishing process
	if currentBobber != null:
		# Updates fishing line
		%fishingLine.global_transform.origin = %bobberSpawnPoint.global_transform.origin
		if %fishingLine.global_transform.origin != currentBobber.getBobber().global_transform.origin:
			%fishingLine.look_at(currentBobber.getBobber().global_transform.origin + Vector3(0, 0.05, 0))
		%fishingLine.scale.z = %fishingLine.global_transform.origin.distance_to(
			currentBobber.getBobber().global_transform.origin)
		# Cancels fishing if fishing rod collides with terrain
		if %floorCast.is_colliding():
			disconnectBobber()
			%fishingAnims.play("withdraw")
		# Fish reeling minigame
		if reelingFish:
			# Adjust indicator position
			if Input.is_action_pressed("interact"):
				fishIndicatorSpeed += delta * FISH_INDICATOR_ACCELERATION
			else:
				fishIndicatorSpeed -= delta * FISH_INDICATOR_ACCELERATION
			# Adjust fish direction
			timeTillDirectionChange -= delta
			if timeTillDirectionChange <= 0:
				movingClockwise = randf() > 0.5
				timeTillDirectionChange = fishCapturing.predictability * randf_range(0.75, 1.25)
			# Change fish position
			fishIndicatorSpeed = clamp(fishIndicatorSpeed, -FISH_MAX_INDICATOR_SPEED, FISH_MAX_INDICATOR_SPEED)
			%fishingIndicatorPivot.rotation += fishIndicatorSpeed * delta
			fishSpeed = clamp(fishSpeed + fishCapturing.speed * delta * FISH_TURN_SPEED * (
				1.0 if movingClockwise else -1.0), -fishCapturing.speed, fishCapturing.speed)
			%fishingTargetPivot.rotation += fishSpeed * delta
			# Calculate whether fish is within indicator
			var indicatorAngle:int = wrapf(%fishingIndicatorPivot.rotation_degrees, 0.0, 360.0)
			var targetAngle:int = wrapf(%fishingTargetPivot.rotation_degrees, 0.0, 360.0)
			var angleDifferenceA:int = abs((indicatorAngle - targetAngle + 180) % 360 - 180)
			var angleDifferenceB:int = abs((targetAngle - indicatorAngle + 180) % 360 - 180)
			var smallestAngleDifference:int = angleDifferenceA
			if angleDifferenceB < angleDifferenceA: smallestAngleDifference = angleDifferenceB;
			# Update fishing process bar
			if smallestAngleDifference < %fishingTarget.value / 2.0:
				%fishingProgress.value += FISH_INCREASE_SPEED * delta / fishCapturing.captureTime
			else:
				%fishingProgress.value -= FISH_DECREASE_SPEED * delta
			# Checks whether fishing has reached end state
			if %fishingProgress.value >= 360.0: # Win state
				endReeling()
				startCustomDialogue([fishCapturing.descriptiveName + " caught!"])
				playerInfo.addToInventory(fishCapturing)
			elif %fishingProgress.value <= 0.0: # Lose state
				endReeling()
	elif !isStopped: interact(delta); # Scans for valid interactions
	else: # Hides interaction HUD
		%interactIcon.visible = false
		%deniedIcon.visible = false
# Main player physics process
func _physics_process(delta): move(delta);
# Updates camera position based on mouse movement
func updateCam(event):
	event.relative *= -MOUSE_SENSITIVITY
	rotate_y(event.relative.x)
	%playerCam.rotation.x = clamp(%playerCam.rotation.x + event.relative.y, -PI / 2.0, PI / 2.0)
	# Checks how long player has been looking at item
	if !%itemMenuInteractionTimer.is_stopped(): %itemMenuInteractionTimer.start();
# Player movement
func move(delta):
	# Vertical velocity
	if !is_on_floor(): # Fall
		verticalVel -= GRAVITY * delta
		verticalVel = clamp(verticalVel, -TERMINAL_VELOCITY, INF)
	elif Input.is_action_pressed("moveJump") and !isStopped and fishingState == FISHING_STATES.inactive: # Jump
		verticalVel = JUMP_VELOCITY
	else: verticalVel = 0;
	# Walk direction variables
	var aim:Vector3 = Vector3(1, 0, 1)
	var direction:Vector3 = Vector3(0, -1, 0)
	# Check whether player has control over body
	if is_on_floor() and !isStopped and fishingState == FISHING_STATES.inactive:
		# Calculates movement vector
		var inputVec:Vector2 = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
		# Prevents player from exceeding max speed by moving diagonally by reducing speed by hypotenuse
		if inputVec.x != 0 and inputVec.y != 0: inputVec *= 0.709;
		# Manages footstep SFX
		if inputVec.x != 0 or inputVec.y != 0:
			if !%footstepsSFX.playing:
				%footstepsSFX.play()
		else: %footstepsSFX.stop();
		# Rotates direction vector by camera rotation
		direction.x = aim.x * inputVec.x
		direction.z = aim.z * inputVec.y
		direction = direction.rotated(Vector3.UP, rotation.y)
		storedDirection = direction
	else: # Applies direction of last input
		direction = storedDirection
		%footstepsSFX.stop()
	
	# Check whether player has stopped
	if (direction.dot(velocity) == 0 and velocity.length() > 0.1) or isStopped or fishingState != FISHING_STATES.inactive:
		velocity *= DECELERATION * delta
	else:
		# Apply direction vector to velocity
		velocity = direction.normalized() * PLAYER_SPEED
		# Increase velocity if sprinting
		if is_on_floor(): isSprinting = Input.is_action_pressed("moveSprint");
		else: velocity *= 0.8;
		if isSprinting: velocity *= PLAYER_SPRINT;
		# Update head bobbing speed based on movement speed
		if !is_on_floor(): %bobAnim.speed_scale = 0.0;
		else: %bobAnim.speed_scale = direction.dot(velocity) - 5.0;
	# Apply velocity to player
	velocity.y = verticalVel
	move_and_slide()
# Scans for valid interactions
func interact(delta):
	# Check if player can interact with event field
	if %interactRay.is_colliding():
		%interactIcon.visible = true
		%deniedIcon.visible = false
		if Input.is_action_just_pressed("interact"):
			# Trigger event specific code
			var interactionNode:Area3D = %interactRay.get_collider()
			match interactionNode.type:
				0: # Dialogue
					startDialogue(interactionNode.getIdentifier())
				1: # Teleport
					self.global_position = interactionNode.teleportNode.global_position
					self.global_rotation = interactionNode.teleportNode.global_rotation
					self.position.y += 1.0
				2: # Map
					GS.entranceName = interactionNode.exitPoint
					changeScene(interactionNode.map)
				3: # Change scene
					GS.entranceName = interactionNode.entranceName
					changeScene(interactionNode.scene)
		return
	# Check if player can interact with item
	if %itemRay.is_colliding():
		if %itemRay.get_collider() != currentlySelected:
			# Reset item interaction HUD
			if currentlySelected != null:
				currentlySelected.setOverlay(null)
				if currentlySelected.interactionType == "item" and itemMenuDisplayed:
					%itemMenuAnims.play("disappear")
					itemMenuDisplayed = false
					itemBuyProgress = 0
					bulkSpeed = 1.0
			# Check whether item is of valid type
			currentlySelected = %itemRay.get_collider()
			if currentlySelected.interactionType == "item":
				%interactIcon.visible = false
				%deniedIcon.visible = false
				if playerInfo.balance >= currentlySelected.part.cost:
					%interactIcon.visible = true
				else:
					%deniedIcon.visible = true
				%itemMenuInteractionTimer.start()
				currentlySelected.setOverlay(outlineMaterial)
		elif itemMenuDisplayed:
			# Increase item buy progress
			if Input.is_action_pressed("interact") and playerInfo.balance >= currentlySelected.part.cost:
				itemBuyProgress += BUY_SPEED * delta * bulkSpeed
				# Buy item
				if itemBuyProgress >= 100.0:
					if bulkSpeed == 1.0: itemBuyProgress = -50.0;
					else: itemBuyProgress = 0;
					bulkSpeed = clamp(bulkSpeed + BULK_INCREASE, 0.0, MAX_BULK_INCREASE)
					buyItem()
			else: # Reset buy progress
				bulkSpeed = 1.0
				itemBuyProgress = 0
			%itemMenuBuyBar.value = itemBuyProgress
		return
	# Reset interaction HUDs if no valid interaction is found
	if currentlySelected != null:
		%itemMenuInteractionTimer.stop()
		# Resets item HUD
		if currentlySelected.interactionType == "item" and itemMenuDisplayed:
			itemMenuDisplayed = false
			itemBuyProgress = 0
			%itemMenuAnims.play("disappear")
		currentlySelected.setOverlay(null)
		currentlySelected = null
	%interactIcon.visible = false
	%deniedIcon.visible = false
# Changes current scene to given scene
func changeScene(newScene):
	# Pause game loop
	get_tree().paused = true
	%fade.visible = true
	isStopped = true
	# Play transition animation
	var fadeTween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	%fadeRect.color = "00000000"
	fadeTween.tween_property(%fadeRect, "color", Color.BLACK, 1.0)
	fadeTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await fadeTween.finished
	# Change scene
	get_tree().paused = false
	%fade.visible = false
	get_tree().change_scene_to_file(newScene)
# Trigger dialogue event
func startDialogue(identifier:String):
	# Update player state
	isStopped = true
	%bobAnim.speed_scale = 0.1
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Display dialogue
	%dialogueMenu.startDialogue(identifier)
	%dialogueMenu.process_mode = Node.PROCESS_MODE_PAUSABLE
# Trigger custom dialogue
func startCustomDialogue(customDialogue:Array[String]):
	# Update player data
	isStopped = true
	%bobAnim.speed_scale = 0.1
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Display dialogue
	%dialogueMenu.startCustomDialogue(customDialogue)
	%dialogueMenu.process_mode = Node.PROCESS_MODE_PAUSABLE
# Buys item player is currently interacting with
func buyItem():
	# Purchase item
	playerInfo.balance -= currentlySelected.part.cost
	if purchaseCount + playerInfo.getInventoryCount(currentlySelected.part) == 0:
		%itemMenuInventoryCount.visible_ratio = 0.0
		%itemMenuAnims.play("revealInventory")
	playerInfo.addToInventory(currentlySelected.part)
	purchaseCount += 1
	# Update displayed item count
	if playerInfo.getInventoryCount(currentlySelected.part) == 0:
		%itemMenuInventoryCount.text = str(
			purchaseCount) + " In Inventory"
	else:
		%itemMenuInventoryCount.text = str(playerInfo.getInventoryCount(currentlySelected.part)
		) + " In Inventory (+" + str(purchaseCount) + ")"
	# Update inventory
	%itemMenuBank.text = "[center][color=#f8c53a]" + str(playerInfo.balance) + " [img=12]placeholder/goldIcon.png[/img]"
	# Update interaction HUD
	%interactIcon.visible = false
	if playerInfo.balance < currentlySelected.part.cost:
		%interactIcon.visible = false
		%deniedIcon.visible = true
		%itemMenuBank.self_modulate = Color.RED
# Display item purchase HUD
func triggerItemMenu():
	# Display HUD
	itemMenuDisplayed = true
	# Display cost
	if playerInfo.balance >= currentlySelected.part.cost: %itemMenuBank.self_modulate = Color.WHITE;
	else: %itemMenuBank.self_modulate = Color.RED;
	%itemMenuBank.text = "[center][color=#f8c53a]" + str(playerInfo.balance) + " [img=12]placeholder/goldIcon.png[/img]"
	# Display name
	%itemMenuName.text = currentlySelected.part.name
	# Display amount in inventory
	purchaseCount = 0
	%itemMenuInventoryCount.text = "" if playerInfo.getInventoryCount(currentlySelected.part) == 0 else str(
		playerInfo.getInventoryCount(currentlySelected.part)) + " In Inventory"
	%itemMenuCost.set_text("[center][color=#f8f644][u]" + str(currentlySelected.part.cost
		) + " [img=12]placeholder/goldIcon.png[/img]")
	# Display item stats
	%itemMenuDamage.text = str(currentlySelected.part.damage)
	%itemMenuArmor.text = str(currentlySelected.part.armorRating)
	%itemMenuSpeed.text = str(currentlySelected.part.speedRating)
	%itemMenuRange.text = str(currentlySelected.part.range)
	%itemMenuSplash.text = str(currentlySelected.part.splash)
	%itemMenuSplashIcon.visible = currentlySelected.part.splash > 0
	# Play HUD reveal animation
	%itemMenuAnims.play("appear")
# Show pause menu
func pause():
	if %pauseMenu.visible: return;
	# Update player state
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	# Display menu
	%pauseMenu.visible = true
	%pauseMenu.openInventory()
	# Hide general HUD
	%interactIcon.visible = false
	%deniedIcon.visible = false
	%itemMenuInteractionTimer.stop()
	SFX.playCloseMenu()
	# Hide item HUD
	if currentlySelected != null:
		if currentlySelected.interactionType == "item" and itemMenuDisplayed:
			itemMenuDisplayed = false
			itemBuyProgress = 0
			%itemMenuAnims.play("disappear")
		currentlySelected.setOverlay(null)
		currentlySelected = null
# Re-enable player once dialogue ends
func dialogueEnded():
	isStopped = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Fishing animation state manager
func fishingAnimFinished(anim_name):
	match anim_name:
		"cast":
			%fishingAnims.play("idle")
			fishingState = FISHING_STATES.idle
		"startReel":
			%fishingAnims.play("reeling")
			fishingState = FISHING_STATES.reel
		"reelComplete":
			fishingState = FISHING_STATES.inactive
		"withdraw":
			fishingState = FISHING_STATES.inactive
			%reelSFX.stop()
# Change fishing idle speed
func fishPulling(): %fishingAnims.speed_scale = 1.5;
func fishSurfacing(): %fishingAnims.speed_scale = 1.0;
# Cancel fishing if collides with terrain
func bobberFloorContacted():
	disconnectBobber()
	%fishingAnims.play("withdraw")
# Event trigger for when fishing bobber collides with water
func bobberWaterContacted(): pass;
# Disconnects bobber from fishing rod
func disconnectBobber():
	# Deletes bobber node
	if currentBobber != null: currentBobber.queue_free();
	currentBobber = null
	# Hides fishing line
	%fishingLine.visible = false
	%fishingLine.scale.z = 1.0
	# Resets fishing state
	fishingState = FISHING_STATES.transitioning
	%fishingAnims.speed_scale = 1.0
	if camTween != null: camTween.kill();
# Ends fishing reeling event
func endReeling():
	# Resets fishing minigame state
	%fishingIndicatorPivot.rotation = 0.0
	%fishingTargetPivot.rotation = 0.0
	fishIndicatorSpeed = 0
	# Destroy bobber
	disconnectBobber()
	# Play fishing end animation
	%fishingAnims.play("reelComplete")
	%fishing.visible = false
	reelingFish = false
# Selects random fish
func getFish():
	# Calculates total fish pool size
	var totalFishChance:float = 0.0
	for fish in fishingPool: totalFishChance += fish.chance;
	# Randomly selects fish from pool
	for fish in fishingPool:
		var minFishChance:float = totalFishChance - fish.chance
		var selectedChance:float = randf_range(0.0, totalFishChance)
		# Returns selected fish
		if selectedChance > minFishChance:
			var newFish:Fish = fish
			newFish.spawn()
			return newFish
		totalFishChance -= fish.chance
	# Default fish selection if fishing pool errors
	var newFish = fishingPool[0]
	newFish.spawn()
	return newFish
# Dialogue events
func eventTriggered(identifier:String, value):
	if identifier == "buildUnit": # Display unit assembly menu
		%unitAssembler.startBuilding()
		GS.emit_signal("eventFinished")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		isStopped = true
	elif identifier == "deconstructUnit": # Display unit disassembly menu
		%unitDisassembler.openDisassembler()
		GS.emit_signal("eventFinished")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		isStopped = true
# Exit menu
func uiClosed():
	isStopped = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SFX.playCloseMenu()
# Exit unit assembly / disassembly menus
func unitAssemblyComplete(): uiClosed();
func unitDisassemblyComplete(): uiClosed();
# Update volume of player SFX
func updateSFXVolume():
	if FM.loadedGlobalData.ambientVolume > 0:
		%footstepsSFX.volume_db = 6 * FM.loadedGlobalData.ambientVolume - 44
		%reelSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 15
	else: # Mutes SFX
		%footstepsSFX.volume_db = -80
		%reelSFX.volume_db = -80
