extends Node2D

# Drag Sonic into this slot in the Inspector
@export var sonic: Node2D
# How close Sonic must be (in pixels) to collect the coin
@export var pickup_distance := 20.0

@onready var sprite: AnimatedSprite2D = $Sprite
var collecting := false


func _ready():
	var frames := SpriteFrames.new()

	# Spin: 7 frames, loops foreverS
	add_frames(frames, "spin", "res://coin/gold_spin.png", 7, true, 10)
	# Collect: 6 frames, plays once
	add_frames(frames, "collect", "res://coin/gold_collect.png", 6, false, 12)

	sprite.sprite_frames = frames
	sprite.animation_finished.connect(_on_collect_finished)
	sprite.play("spin")


# Cuts a spritesheet into frames. Every frame is 25 pixels wide.
func add_frames(frames: SpriteFrames, anim_name: String, path: String,
		count: int, loop: bool, fps: float):
	var sheet: Texture2D = load(path)
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, loop)
	frames.set_animation_speed(anim_name, fps)
	for i in count:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * 25, 0, 25, 25)
		frames.add_frame(anim_name, atlas)


func _process(_delta):
	if collecting or sonic == null:
		return
	if global_position.distance_to(sonic.global_position) < pickup_distance:
		collect()


func collect():
	collecting = true
	sprite.play("collect")


# Runs when the collect animation finishes its last frame
func _on_collect_finished():
	if sprite.animation == "collect":
		queue_free()   # removes the coin from the game
