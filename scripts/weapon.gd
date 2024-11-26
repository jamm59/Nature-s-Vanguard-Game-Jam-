class_name BaseWeapon
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var originalScale: Vector2 = scale
var originalPosition: Vector2 = global_position
var weaponEquip: bool = false
var directionLeftOrRight: int = 1
var isAttacking: bool = false

func _ready() -> void:
	if not weaponEquip:
		self.hide()
	else:
		self.show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		handleWeaponAttackAnimation()
		
	if Input.is_action_just_pressed("Equip"):
		if not weaponEquip:
			self.show()
			weaponEquip = true
		else:
			self.hide()
			weaponEquip = false
	
	var dir: int = Input.get_axis("left", "right")
	if dir != 0:
		directionLeftOrRight = dir
	
	sprite_2d.flip_h = false if directionLeftOrRight == 1 else true

func handleWeaponAttackAnimation() -> void:
	
	if isAttacking:
		return 

	isAttacking = true
	var AttackPower = 40
	var stab_time_thrust: float = 0.07  # Time for forward thrust
	var stab_time_return: float = 0.07  # Time to return
	var stab_offset: Vector2 = Vector2(AttackPower, 0) if directionLeftOrRight == 1 else Vector2(-AttackPower, 0)  # Forward thrust offset
	# Create the Tween
	var attack_tween = get_tree().create_tween()
	attack_tween.tween_property(self, "position", position + stab_offset, stab_time_thrust).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_tween.chain().tween_property(self, "position", position, stab_time_return).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	attack_tween.finished.connect(_on_attack_animation_finished)
	
	
func _on_attack_animation_finished():
	isAttacking = false
