extends Node2D

## 打砖块

## 游戏规则
# 通过键盘控制滑板的移动
# 滑板承接小球反弹不让小球掉落下去
# 小球通过不断反弹撞击顶部方块，全部击碎即获胜，掉落下去即失败
# 滑板对小球存在摩擦力，因此可以些微改变小球的速度

## 设计思路
# 1.点击开始，即可开始游戏
# 	1.1 初始化游戏数据，包括小球速度，小球于是可以运动
# 2.通过监听键盘事件，控制滑板的左右移动
# 3.当每帧绘制时候，判断当小球和周围物体发生碰撞时
#	3.1 如果小球掉落出编辑，则 game over
# 	3.2 如果小球碰撞到墙壁，则小球反弹
# 	3.3 小球碰撞到砖块，小球反弹，且砖块消失
# 	3.4 小球碰撞到滑板，小球反弹（有发生碰撞那一刻滑板的速度决定反弹的角度和速度）
# 4.小球和滑板的每帧绘制
# 5.砖块和墙壁的绘制
# 	4.1 通过底层方法直接永久绘制墙壁
#	4.2 通过底层方法直接永久绘制砖块
# 6.游戏结束重新开始，init 游戏数据，清楚通过底层方法生成的墙壁和砖块

var is_launched = false # 小球是否发射

func _ready() -> void:
	get_tree().paused = false
	EventBus.ball_over.connect(_on_ball_over)

# 按键触发开始
func _unhandled_key_input(event: InputEvent) -> void:
	if is_launched:
		return
	if event.is_action_pressed("launch"):
		start_game() # 开始游戏

# 游戏开始
func start_game() -> void:
	# 游戏开始
	$Ball.launch()
	is_launched = true

# 按钮重新开始点击时
func _on_button_pressed() -> void:
	$CanvasLayer.visible = false # 重新开始按钮消失
	# 清理所有砖块和墙体
	for brick: Brick in $BrickAndWall.bricks.values():
		brick.hit()
	for wall: Wall in $BrickAndWall.walls:
		wall.release()
	# 释放当前旧的场景的所有内容
	for child in get_children():
		child.queue_free()
	# 延迟一帧后再切换场景
	await get_tree().create_timer(0.1).timeout
	# 切换场景后，paused = true 会传递到新场景中，因为其属于 SceneTree 的全局属性
	get_tree().change_scene_to_file("res://main.tscn") # 重新切到主场景中

# 游戏结束时
func _on_ball_over():
	get_tree().paused = true # 游戏暂停
	$CanvasLayer.visible = true # 重新开始 btn 可见
	
