extends Node2D

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var camera_shake_timer: Timer = $CameraShakeTimer
@onready var restart_timer: Timer = $restartTimer

var shakeAvailable: bool = false

func _on_player_camera_shake() -> void:
	shakeAvailable = true
	camera_shake_timer.start()
	
func _process(delta: float) -> void:
	var SHAKE_AMOUNT: float = randf_range(0.5, 1)
	if shakeAvailable:
		camera_2d.set_offset(Vector2( \
			randf_range(-1.0, 1.0) * SHAKE_AMOUNT, \
			randf_range(-1.0, 1.0) * SHAKE_AMOUNT \
		))
	
func _on_camera_shake_timer_timeout() -> void:
	shakeAvailable = false


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	restart_timer.start()
	


func _on_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()
