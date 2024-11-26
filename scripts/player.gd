extends CharacterBody2D

enum PLAYER_STATE {IDLE, JUMP, DASH, DASH_ATTACK, FALL, LAND, ATTACK, MOVING_LEFT, MOVING_RIGHT}

var Ghost_Sprite = preload("res://scenes/ghostSprite.tscn")

@onready var hurt_box: CollisionShape2D = $HurtBox
@onready var attack_timer: Timer = $AttackTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var TEMP_FALL_GRAVITY = FALL_GRAVITY


# WEAPON
@onready var left_weapon_position: Node2D = $LeftWeaponPosition
@onready var right_weapon_position: Node2D = $RightWeaponPosition
@onready var base_weapon: BaseWeapon = $BaseWeapon


signal cameraShake

const SPEED = 120.0
const SPEED_MULTIPLIER = 10
var PlayerDirection = 1
#var JUMP_VELOCITY = -400
var friction: float = 40
var acceleration: float = 50
var currentPlayerState: PLAYER_STATE = PLAYER_STATE.IDLE
var spriteInitialPosition: float
var isAttacking: bool = false
var playerDirection: int = 0
var wasOnFloor: bool = false
var prevState: PLAYER_STATE

func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
func ghosting(ghostSprite: GhostSprite, time: float) -> void:
	var tweenFade = get_tree().create_tween()
	tweenFade.tween_property(ghostSprite, "modulate", Color(1, 1, 1, 0), time )
	await tweenFade.finished
	ghostSprite.queue_free()
	
func handlePlayerDashAnimation() -> void:
	
	for index in range(5, -1, -1):
		
		var ghostSprite: GhostSprite = Ghost_Sprite.instantiate()
		var playerSprite: Sprite2D
		var xOffset = -5
		var yOffset = 2
		add_child(ghostSprite)
		
		match animated_sprite_2d.name:
			"primaryPlayerSprite":
				playerSprite = ghostSprite.get_child(0)
				ghostSprite.get_child(1).hide()				
			_:
				playerSprite = ghostSprite.get_child(1)
				ghostSprite.get_child(0).hide()
				
		match playerDirection:
			1: 
				playerSprite.flip_h = false
			-1:
				playerSprite.flip_h = true
				xOffset = 25
				
		ghostSprite.global_position.x = (global_position.x + xOffset) - ((5 - index) * 5)
		ghostSprite.global_position.y = global_position.y - yOffset
		var time: float = (0.75 * index) / 5
		ghosting(ghostSprite, time)
	
func handleInput(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	
	if not is_on_floor():
		velocity.y += getGravity() * delta
		
	if dir == 0 and velocity.y < 1:
		currentPlayerState = PLAYER_STATE.IDLE
		
	if Input.is_action_just_pressed("attack"):
		currentPlayerState = PLAYER_STATE.ATTACK
		
	if Input.is_action_pressed("left"):
		currentPlayerState = PLAYER_STATE.MOVING_LEFT
		playerDirection = -1
	
	if Input.is_action_pressed("right"):
		currentPlayerState = PLAYER_STATE.MOVING_RIGHT
		playerDirection = 1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		currentPlayerState = PLAYER_STATE.JUMP
	
	if Input.is_action_just_pressed("dash"): # DASH IS INDEPENDENT OF OTHER EVENTS
		currentPlayerState = PLAYER_STATE.DASH
		
	if not is_on_floor() and velocity.y > 0:
		currentPlayerState = PLAYER_STATE.FALL
	
	if is_on_floor() and not wasOnFloor:
		currentPlayerState = PLAYER_STATE.LAND
		
	wasOnFloor = is_on_floor()
		
func handleAnimationStateUpdate() -> void:
	match currentPlayerState:
		PLAYER_STATE.JUMP:
			animated_sprite_2d.play("Jump")
			velocity.y = JUMP_VELOCITY
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("Fall")
		PLAYER_STATE.LAND:
			animated_sprite_2d.play("Land")
		PLAYER_STATE.MOVING_RIGHT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, 1 * SPEED, acceleration)
			animated_sprite_2d.flip_h = false
		PLAYER_STATE.MOVING_LEFT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, -1 * SPEED, acceleration)
			animated_sprite_2d.flip_h = true
		PLAYER_STATE.DASH:
			audio_player.pitch_scale = randf_range(1, 1.5)
			audio_player.playing = true
			handlePlayerDashAnimation()
			velocity.x = playerDirection * SPEED * SPEED_MULTIPLIER
		PLAYER_STATE.IDLE:
			if not isAttacking:
				animated_sprite_2d.play("Idle")
			velocity.x = move_toward(velocity.x, 0, friction)
		
func handleWeaponPosition() -> void:
	var dir = Input.get_axis("left", "right")
	
	if dir == 1:
		base_weapon.position = right_weapon_position.position
	elif dir == -1:
		base_weapon.position = left_weapon_position.position
	
func _ready() -> void:
	base_weapon.position = right_weapon_position.position
	
	
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	handleInput(delta)
	handleAnimationStateUpdate()
	handleWeaponPosition()
	move_and_slide()
