class_name Paddle
extends CharacterBody2D

## 描述滑板运动的逻辑

const WIDTH = 100 # 滑板宽度
const HEIGHT = 10 # 滑板高度
const INIT_SPEED = 700 # 滑板速度

const rect_size = Rect2(-WIDTH / 2.0, -HEIGHT / 2.0, WIDTH, HEIGHT) # 滑板位置

# 每隔一定时间执行，监听输入，控制滑板真实速度
func _physics_process(delta: float) -> void:
	# 监听键盘，返回一个虚拟轴的输入值，该值对应 [-1, 1]，表示左右的强度情况
	var xAxis = Input.get_axis("left", "right")
	# 改变滑板速度
	velocity = Vector2(xAxis * INIT_SPEED, 0)
	# 滑板移动
	move_and_collide(velocity * delta)

# 每帧绘制
func _draw() -> void:
	draw_rect(rect_size, Color.BURLYWOOD)
	
