extends RigidBody2D

var screen_size: Vector2

signal fruit_missed # furit miss 信号

func _ready():
	screen_size = get_viewport_rect().size
	# x 位置出现 [64, screen_size - 64]
	position.x = randi() % int(screen_size.x - 128) + 64
	# rigid 物体的旋转弧度 [-20, 20]
	angular_velocity = (randi() % 40) - 20

## 监听到从屏幕出去时，发送 fruit_missed 信号
func _on_visible_on_screen_notifier_2d_screen_exited():
	fruit_missed.emit()
	queue_free() # 销毁
