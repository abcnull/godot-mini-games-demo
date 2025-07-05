extends StaticBody2D

const PADDLE_SPEED : float = 500 # 滑板速度

@onready var ball: CharacterBody2D = $"../Ball" # 小球
@onready var color_rect: ColorRect = $ColorRect # 显示单色的矩形控件
func _ready():
	init_paddle()

## 初始化 paddle
func init_paddle():
	constant_linear_velocity = Vector2.ZERO

## 通过改变 position 来使得 StaticBody 运动
# 每帧 根据小球的位置，决定右侧滑板移动到什么位置
func _physics_process(delta: float): 
	# 此帧，右侧滑板中心点和小球的纵轴差距
	var dist : float = position.y - ball.position.y
	var move_by: float # 滑板移动距离
	var old_position: Vector2 = position
	
	# 经过 delta 时间后，如果右侧滑板没有赶上了 dist 这段距离
	var paddle_speed: float
	if abs(dist) > PADDLE_SPEED * delta:
		# 滑板需要移动的距离
		move_by = PADDLE_SPEED * delta * (dist / abs(dist))
		paddle_speed = PADDLE_SPEED
	# 经过 delta 时间后，赶上了 dist 这段距离
	else:
		# 滑板需要移动，使得小球和滑板中心点对齐，所以 dist 赋值给它
		move_by = dist
		paddle_speed = abs(dist) / delta
	
	# 滑板移动
	position.y -= move_by
	
	# 限制 position.y 在 [p_height / 2, win_height - p_height / 2] 之间
	position.y = clamp(
		position.y, 
		color_rect.size.y / 2, 
		get_viewport_rect().size.y - color_rect.size.y / 2
	)
	
	# 维护此值 constant_linear_velocity
	constant_linear_velocity = Vector2(
		0, 
		(position.y - old_position.y) / delta
	)
