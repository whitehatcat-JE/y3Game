extends CharacterBody3D
# Signals
signal interacted(interactionName:String)
# Constants
const PLAYER_SPEED:float = 6.0
const PLAYER_SPRINT:float = 1.5  
const MOUSE_SENSITIVITY:float = 0.003
const DECELERATION:float = 20.0

const JUMP_VELOCITY:float = 4.0
const GRAVITY:float = 10.5
const TERMINAL_VELOCITY:float = 7.0
# State variables
var cameraAngle:float = 0
var unlockedKeys:Array[String] = ["general"]

var verticalVel:float = 0.0

var storedDirection:Vector3 = Vector3()
var isSprinting:bool = false

var itemMenuDisplayed:bool = false
var currentlySelected : Node = null
@onready var outlineMaterial : ShaderMaterial = preload("res://hubs/interactions/shaders/outlineMat.tres")

func _ready() -> void: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(delta):
	if Input.is_action_just_pressed("quit"): get_tree().quit()
	if %interactRay.is_colliding():
		if %interactRay.get_collider() != currentlySelected:
			if currentlySelected != null and currentlySelected.has_node("mesh"):
				currentlySelected.get_node("mesh").material_overlay = null
				if currentlySelected.interactionType == "item" and itemMenuDisplayed:
					%itemMenuAnims.play("disappear")
					itemMenuDisplayed = false
			currentlySelected = %interactRay.get_collider()
			if currentlySelected.interactionType == "item":
				%interactIcon.visible = true
				%itemMenuInteractionTimer.start()
				currentlySelected.get_node("mesh").material_overlay = outlineMaterial
	elif currentlySelected != null:
		%interactIcon.visible = false
		%itemMenuInteractionTimer.stop()
		if currentlySelected.interactionType == "item" and itemMenuDisplayed:
			itemMenuDisplayed = false
			%itemMenuAnims.play("disappear")
		if currentlySelected.has_node("mesh"):
			currentlySelected.get_node("mesh").material_overlay = null
		currentlySelected = null

func _physics_process(delta):
	move(delta)

#region Movement
func _input(event) -> void:
	if event is InputEventMouseMotion: # Used for mouse movement detection
		event.relative *= -MOUSE_SENSITIVITY
		rotate_y(event.relative.x)
		%playerCam.rotation.x = clamp(%playerCam.rotation.x + event.relative.y, -PI / 2.0, PI / 2.0)
		if !%itemMenuInteractionTimer.is_stopped(): %itemMenuInteractionTimer.start();

func move(delta):
	# Add the gravity.
	if !is_on_floor():
		verticalVel -= GRAVITY * delta
		verticalVel = clamp(verticalVel, -TERMINAL_VELOCITY, INF)
	elif Input.is_action_pressed("moveJump"): verticalVel = JUMP_VELOCITY;
	else: verticalVel = 0;
	
	var aim:Vector3 = Vector3(1, 0, 1)
	var direction:Vector3 = Vector3(0, -1, 0)
	
	if is_on_floor():
		var inputVec:Vector2 = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
		if inputVec.x != 0 and inputVec.y != 0: inputVec *= 0.709;
		direction.x = aim.x * inputVec.x
		direction.z = aim.z * inputVec.y
		direction = direction.rotated(Vector3.UP, rotation.y)
		storedDirection = direction
	else: direction = storedDirection;
	
	# Move player in calculated direction
	if direction.dot(velocity) == 0 and velocity.length() > 0.1:
		velocity *= DECELERATION * delta
	else:
		velocity = direction.normalized() * PLAYER_SPEED
		if is_on_floor(): isSprinting = Input.is_action_pressed("moveSprint");
		else: velocity *= 0.8;
		if isSprinting: velocity *= PLAYER_SPRINT;
		
		if !is_on_floor(): %bobAnim.speed_scale = 0.0;
		else: %bobAnim.speed_scale = direction.dot(velocity) - 5.0;
		
		velocity.y = verticalVel
	move_and_slide()
#endregion

func triggerItemMenu():
	itemMenuDisplayed = true
	%itemMenuName.text = currentlySelected.part.name
	%itemMenuCost.set_text("[center][color=#f8f644][u]" + str(currentlySelected.part.cost
		) + " [img=12]placeholder/goldIcon.png[/img]")
	%itemMenuDamage.text = str(currentlySelected.part.damage)
	%itemMenuArmor.text = str(currentlySelected.part.armorRating)
	%itemMenuSpeed.text = str(currentlySelected.part.speedRating)
	%itemMenuRange.text = str(currentlySelected.part.range)
	%itemMenuSplash.text = str(currentlySelected.part.splash)
	%itemMenuSplashIcon.visible = currentlySelected.part.splash > 0
	%itemMenuAnims.play("appear")
