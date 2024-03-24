extends CharacterBody3D
# Signals
signal interacted(interactionName:String)
# Constants
@export var PLAYER_SPEED:float = 6.0
@export var PLAYER_SPRINT:float = 1.5  
@export var MOUSE_SENSITIVITY:float = 0.15
@export var DECELERATION:float = 20.0

@export var JUMP_VELOCITY:float = 5.0
@export var GRAVITY:float = 15.0
@export var TERMINAL_VELOCITY:float = 5.5
# State variables
var cameraAngle:float = 0
var unlockedInteractions:Array[String] = ["monitor", "passcode", "crt", "piano"]
var currentGroundType:int = 0

var verticalVel:float = 0.0

var storedDirection:Vector3 = Vector3()
var isSprinting:bool = false
var inAir:bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _input(event) -> void:
	if event is InputEventMouseMotion: # Used for mouse movement detection
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		var change:float = -event.relative.y * MOUSE_SENSITIVITY
		if abs(change + cameraAngle) < 90:
			cameraAngle += change
			%playerCam.rotate_x(deg_to_rad(change))
		elif change + cameraAngle > 90:
			%playerCam.rotate_x(deg_to_rad(90 - cameraAngle))
			cameraAngle = 90
		elif change + cameraAngle < -90:
			%playerCam.rotate_x(deg_to_rad(-(cameraAngle + 90)))
			cameraAngle = -90

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		verticalVel -= GRAVITY * delta
		verticalVel = clamp(verticalVel, -TERMINAL_VELOCITY, INF)
		if verticalVel < 0.0 and !inAir:
			$head/neck/movementAnims.play("fall")
			inAir = true
	elif Input.is_action_pressed("moveJump"):
		verticalVel = JUMP_VELOCITY
	else:
		verticalVel = 0
		if inAir:
			$head/neck/movementAnims.play("land")
			inAir = false
	
	var aim:Basis = get_global_transform().basis
	var direction:Vector3 = Vector3(0, -1, 0)
	
	if is_on_floor():
		if Input.is_action_pressed("moveLeft"): direction -= aim.x
		if Input.is_action_pressed("moveRight"): direction += aim.x
		if Input.is_action_pressed("moveUp"): direction -= aim.z
		if Input.is_action_pressed("moveDown"): direction += aim.z
		storedDirection = direction
	else:
		direction = storedDirection
	
	# Move player in calculated direction
	if direction.dot(velocity) == 0 and velocity.length() > 0.1:
		velocity.x -= velocity.x * DECELERATION * delta
		velocity.z -= velocity.z * DECELERATION * delta
	else:
		if direction.dot(velocity) > 0:
			if isSprinting: $bobAnim.speed_scale = 6.0;
			else: $bobAnim.speed_scale = 4.0;
		else: $bobAnim.speed_scale = 1.0;
		velocity = direction.normalized() * PLAYER_SPEED
		if !is_on_floor(): velocity *= 0.8
		velocity.y = verticalVel
		if is_on_floor(): isSprinting = Input.is_action_pressed("moveSprint");
		if isSprinting: velocity *= PLAYER_SPRINT;
	move_and_slide()
