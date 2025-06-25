class_name Ball
extends CharacterBody2D

## 描述小球的运动逻辑

const MIN_SPEED = 300 # 小球最小速度
const MAX_SPEED = 500 # 小球最大速度

const RADIUS = 5 # 小球半径

# 游戏开始，小球获得了速度
func launch() -> void:
	velocity = Vector2(0, -MIN_SPEED)

# 每一定时间执行，执行运动并检测是否碰撞，如果碰撞就发出信号
func _physics_process(delta: float) -> void:
	# 小球超出边界，发结束信号
	if not get_viewport_rect().has_point(global_position):
		EventBus.ball_over.emit()
		return
	
	# 移动，并如果发生碰撞获取被碰撞物体的属性；如果没有发生碰撞，返回 null
	var collision = move_and_collide(velocity * delta) # 移动
	# 如果发生碰撞
	if collision:
		# 这里其实有两种情况，如果是方块 get_collider_velocity 为 0，如果是滑板 get_collider_velocity 是有移动速度的
		# 因为被碰撞的滑板是 CharacterBody2D，因此 get_collider_velocity 不会影响滑板的速度！get_collider_velocity 获得的是滑板那一刻的速度
		# 如果是滑板移动时候，它的运动需要影响球的速度，这样才能显得滑板表面有摩擦力，被小球碰撞时影响小球的移动
		velocity += collision.get_collider_velocity() / 4
		
		# 计算反弹速度（速度是矢量），并且如果速率大于最大值，就取最大值
		velocity = velocity.bounce(collision.get_normal()).limit_length(MAX_SPEED)
		# 如果速率小于最小值，就取最小值
		if velocity.length() < MIN_SPEED:
			velocity = velocity.normalized() * MIN_SPEED
		
		# 发出球碰撞的信号，带上被碰撞物体的 RID
		EventBus.ball_collided.emit(collision.get_collider_rid())
	

# 每帧绘制
func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.SKY_BLUE)
