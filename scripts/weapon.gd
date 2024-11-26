class_name BaseWeapon
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var originalScale: Vector2 = scale
var originalPosition: Vector2 = global_position
var l = false
var r = true
var weaponEquip = false
var directionLeftOrRight: int = 1
func _ready() -> void:
		pass
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
	
	if Input.is_action_just_pressed("left"):
		sprite_2d.flip_v = true
		if not l:
			self.position.x -= 25
			l = true
			r = false
	if Input.is_action_just_pressed("right"):
		sprite_2d.flip_v = false
		if not r:
			self.position.x += 25
			r = true
			l = false
	var dir: int = Input.get_axis("left", "right")
	if dir != 0:
		directionLeftOrRight = dir

	
func handleWeaponAttackAnimation():
	var stab_time_thrust: float = 0.1  # Time for forward thrust
	var stab_time_return: float = 0.1  # Time to return
	var stab_offset: Vector2 = Vector2(10 * directionLeftOrRight, 0)  # Forward thrust offset

	# Create the Tween
	var attack_tween = get_tree().create_tween()

	# Step 1: Thrust forward
	attack_tween.tween_property(self, "global_position", global_position + stab_offset, stab_time_thrust).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "scale", Vector2(1.5, 0.8), stab_time_thrust).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Step 2: Return to original position and size (chained)
	attack_tween.chain().tween_property(self, "global_position", originalPosition, stab_time_return).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	attack_tween.chain().tween_property(self, "scale", Vector2(1, 1), stab_time_return).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Wait for the final tween to complete
	await attack_tween.finished
