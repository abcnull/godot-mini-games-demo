extends Node2D

var screen_size: Vector2

signal hit # 物体击中此 area 的信号

func _ready():
	screen_size = get_viewport_rect().size

func _input(event):
	# 鼠标移动事件
	if event is InputEventMouseMotion:
		position.x = event.position.x
		# 限制 min 和 max
		position.x = clamp(position.x, 64, screen_size.x - 64)

## 当 area 有物体进入，发送 hit 信号
func _on_body_entered(body):
	hit.emit() # 信号
	# 被掉落进来的物体进行释放
	body.queue_free()
