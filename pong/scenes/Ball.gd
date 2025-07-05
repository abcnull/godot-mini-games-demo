extends CharacterBody2D

const START_SPEED: float = 500 # 球刚开始发射的速度

@onready var player: StaticBody2D = $"../Player"
@onready var robot_player: StaticBody2D = $"../RobotPlayer"

## 产生一个新球发射
func new_ball():
	# 产生新球，从正中心发射
	position = get_viewport_rect().size / 2
	# 速度
	velocity = Vector2([1, -1].pick_random() * START_SPEED, 0)

## 每帧绘制球的移动
func _physics_process(delta):
	# 移动
	var collision = move_and_collide(velocity * delta)
	if collision == null:
		return
	# 如果碰撞发生了，获取被碰撞体
	var collider: StaticBody2D = collision.get_collider()
	# 如果球撞击了滑板 StaticBody
	if collider == player or collider == robot_player:
		# 由于滑板在移动，会给小球一个滑板移动方向的速度加成，像有摩擦力一样
		velocity += (collider.constant_linear_velocity / 3)
		# 限制最小和最大速度
		velocity = clamp(
			velocity, 
			velocity.normalized() * START_SPEED * 0.5, # min
			velocity.normalized() * START_SPEED * 1.5 # max
		)
		# 反弹的速度
		velocity = velocity.bounce(collision.get_normal())
	# 如果球撞击了墙壁 StaticBody
	else:
		velocity = velocity.bounce(collision.get_normal())
		return
