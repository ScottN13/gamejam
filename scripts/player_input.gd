extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0
@export var jump_velocity: float = -450.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("character_jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("character_left", "character_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()
	#update_animation(direction)

func update_animation(direction: float) -> void:
	if direction != 0.0:
		anim.flip_h = direction < 0.0

	if not is_on_floor():
		anim.play("jump")
	elif absf(velocity.x) > 10.0:
		anim.play("run")
	else:
		anim.play("idle")
