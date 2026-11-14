extends Node2D

# ---- Sonic's numbers (from the Sonic Physics Guide, per frame) ----
const ACC := 0.046875
const DEC := 0.5
const FRC := 0.046875
const TOP := 6.0
const SLP := 0.125
const AIR_ACC := 0.09375
const GRAVITY := 0.21875
const MAX_FALL := 16.0
const JUMP_FORCE := 6.5
const JUMP_CUT := -4.0
const RADIUS := 16.0          # distance from Sonic's centre to his feet

# Results of probing for the floor
const HIT_FLOOR := 0
const HIT_WALL := 1
const HIT_NOTHING := 2

# ---- Sonic's state ----
var gsp := 0.0                # ground speed
var xsp := 0.0                # horizontal speed
var ysp := 0.0                # vertical speed
var on_ground := false
var floor_angle := 0.0        # slope in radians; positive = floor rises to the right


func _physics_process(_delta):
	var left := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")

	if on_ground:
		if Input.is_action_just_pressed("jump"):
			start_jump()
		else:
			ground_move(left, right)
	else:
		air_move(left, right)

	$Label.text = "gsp: %.2f\nxsp: %.2f\nysp: %.2f" % [gsp, xsp, ysp]


# ---------- GROUND ----------
func ground_move(left: bool, right: bool):
	if right and not left:
		if gsp < 0:
			gsp += DEC
		else:
			gsp += ACC
	elif left and not right:
		if gsp > 0:
			gsp -= DEC
		else:
			gsp -= ACC
	else:
		gsp -= min(abs(gsp), FRC) * sign(gsp)

	gsp = clamp(gsp, -TOP, TOP)
	gsp -= SLP * sin(floor_angle)

	xsp = gsp * cos(floor_angle)
	ysp = -gsp * sin(floor_angle)

	var motion := Vector2(xsp, ysp)
	var steps: int = max(1, int(ceil(motion.length())))
	var step := motion / steps

	for i in steps:
		if wall_ahead(step):
			gsp = 0
			xsp = 0
			ysp = 0
			return
		global_position += step

		var result := probe_floor()
		if result == HIT_WALL:
			gsp = 0
			xsp = 0
			ysp = 0
			return
		if result == HIT_NOTHING:
			on_ground = false   # walked off the edge: keep xsp and ysp and fall
			return


# ---------- JUMPING ----------
func start_jump():
	xsp = gsp * cos(floor_angle)
	ysp = -gsp * sin(floor_angle)
	xsp -= JUMP_FORCE * sin(floor_angle)
	ysp -= JUMP_FORCE * cos(floor_angle)
	on_ground = false


# ---------- AIR ----------
func air_move(left: bool, right: bool):
	if not Input.is_action_pressed("jump") and ysp < JUMP_CUT:
		ysp = JUMP_CUT

	if right and not left:
		xsp += AIR_ACC
	elif left and not right:
		xsp -= AIR_ACC
	xsp = clamp(xsp, -TOP, TOP)

	ysp = min(ysp + GRAVITY, MAX_FALL)

	var motion := Vector2(xsp, ysp)
	var steps: int = max(1, int(ceil(motion.length())))
	var step := motion / steps

	for i in steps:
		var s := step
		# Hitting a wall sideways stops horizontal movement only
		if s.x != 0 and wall_ahead(Vector2(s.x, 0)):
			xsp = 0
			s.x = 0
		global_position += s

		if ysp > 0 and probe_floor() == HIT_FLOOR:
			land()
			return


func land():
	var a: float = abs(floor_angle)
	var side: float = sign(sin(floor_angle))

	if a < deg_to_rad(22.5):
		gsp = xsp
	elif a < deg_to_rad(45):
		gsp = ysp * 0.5 * -side
	else:
		gsp = ysp * -side

	on_ground = true
	


# ---------- DETECTION ----------
# Looks straight down for a floor under Sonic's centre.
# Probes two points under Sonic's feet and uses the one that is most reliable.
func probe_floor() -> int:
	var space := get_world_2d().direct_space_state
	var offsets := [Vector2(-6, 0), Vector2(6, 0), Vector2(0, 0)]
	var best_hit := {}
	var best_dist := INF

	for off in offsets:
		var from: Vector2 = global_position + off + Vector2(0, -RADIUS)
		var to: Vector2 = global_position + off + Vector2(0, RADIUS + 20)
		var hit := space.intersect_ray(PhysicsRayQueryParameters2D.create(from, to))
		if hit.is_empty():
			continue
		var d: float = hit.position.distance_to(from)
		if d < best_dist:
			best_dist = d
			best_hit = hit

	if best_hit.is_empty():
		return HIT_NOTHING

	var n: Vector2 = best_hit.normal
	if n.y > -0.2:   # only near-vertical faces count as walls
		return HIT_WALL

	floor_angle = atan2(-n.x, -n.y)
	global_position = best_hit.position + n * RADIUS
	return HIT_FLOOR


# Looks sideways in the direction Sonic is moving for a near-vertical wall.
func wall_ahead(dir: Vector2) -> bool:
	var from := global_position
	var to := from + dir.normalized() * (RADIUS + 1)
	var hit := get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(from, to)
	)
	if hit.is_empty():
		return false
	var n: Vector2 = hit.normal
	return n.y > -0.2
