extends StaticBody2D

const PADDLE_SPEED : float = 500 # 滑板速度

@onready var color_rect: ColorRect = $ColorRect # 显示单色的矩形控件
func _ready():
	init_paddle()

## 初始化 paddle
func init_paddle():
	constant_linear_velocity = Vector2.ZERO

## 通过改变 position 来使得 StaticBody 运动
func _physics_process(delta):
	var old_position: Vector2 = position
	if Input.is_action_pressed("ui_up"): # ⬆
		# 通过每帧改变 position 来移动 StaticBody
		position.y -= PADDLE_SPEED * delta
	elif Input.is_action_pressed("ui_down"): # ⬇️
		# 通过每帧改变 position 来移动 StaticBody
		position.y += PADDLE_SPEED * delta
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
