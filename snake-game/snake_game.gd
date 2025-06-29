extends Node2D

## 贪吃蛇游戏

## 游戏规则
# 通过减胖控制蛇头移动，减胖控制的移动方向只能与蛇头移动方向垂直
# 如果键盘移动方向和蛇头方向相同，则后加快蛇头运动
# 食物随机出现
# 食物被吃掉，蛇身长度增加 1
# 蛇不能碰到边界，也不能碰到自己的身体，否则算游戏结束

## 设计思路
# 1.先初始化蛇身体和食物位置
# 2.每帧执行逻辑
# 	2.1 每帧监听键盘动作，是要加速，还是改变蛇的方向
# 	2.2 蛇的运动速度通过全局变量控制，到一定时间蛇头会运动，本质是绘制
# 	2.3 判定蛇头吃到食物与否，若吃到，蛇尾部不减少，若没吃到蛇尾减少；只要当蛇触发一次绘制时候，不论蛇尾是否减少，蛇头都会新绘制一个方格
# 	2.4 如果蛇头吃到食物，食物重新随机生成，注意不能生成到蛇身处
# 	2.5 如果蛇头碰到边界或者蛇头碰到身体，game over
# 3._draw 逻辑
#	3.1 绘制网格
#	3.2 绘制蛇身
#	3.3 绘制食物


## grid
const grid_size: Vector2 = Vector2(30, 30) # grid size
const cell_size: int     = 30 # cell size
## snake
var snake_body: Array[Vector2]    = [] # snake body
var snake_last_direction: Vector2 = Vector2.ZERO # 上一幕蛇的真实方向（多个 delta 组成一幕）
var snake_now_direction: Vector2  = Vector2.ZERO # 每个 delta 时间间隔中，蛇的方向因为按键操作而被更新，这个值会不断被刷新，并不真是蛇移动的方向，每一幕后要把 snake_now_direction 刷进 snake_last_direction
## food
var food_position: Vector2 = Vector2.ZERO
## time
const time_interval: float = 0.3 # 固定 0.3s 蛇移动
var timer: float           = 0 # 计时器


func _ready():
	init_snake()
	init_food()
	print("Press the arrow keys to start the game")


func init_snake():
	snake_body.append( \
		Vector2( \
			float(randi() % (int(grid_size.x) + 1)), \
			float(randi() % (int(grid_size.y) + 1)) \
		) \
	)


func init_food() -> void:
	# 可以放置食物有效区域
	var valid_cell: Array[Variant] = []
	for i in range(grid_size.x + 1):
		for j in range(grid_size.y + 1):
			if not snake_body.has(Vector2(i, j)):
				valid_cell.append(Vector2(i, j))
	if    valid_cell == []:
		food_position = Vector2.ZERO
		return
	# 随机一个有效区域
	food_position = valid_cell.pick_random()


func _physics_process(delta: float) -> void:
	# 监听动作，决定此刻贪吃蛇的方向
	decide_now_direction()

	# 若游戏开始一直没有动作，则不用绘制
	if snake_now_direction == Vector2.ZERO:
		return

	# 当触发了 action 立即让游戏进行，而不是再等待 time_interval 的时间
	if snake_last_direction == Vector2.ZERO && snake_last_direction != snake_now_direction:
		print("Game Start!")
		timer = time_interval

	# 当按键方向和前进方向相同时，贪吃蛇加速
	var real_time_interval: float = time_interval
	if snake_last_direction == snake_now_direction && \
	(Input.is_action_pressed("turn_up") || Input.is_action_pressed("turn_down") || Input.is_action_pressed("turn_right") || Input.is_action_pressed("turn_left")):
		real_time_interval = time_interval / 2

	timer += delta
	# 到时间，蛇头需要前进一格
	if timer >= real_time_interval:
		timer = 0 # reset timer
		# 蛇头碰撞检测
		if not check_snake_head():
			# 游戏结束
			game_ending()
		# 更新蛇位置
		update_snake()
		snake_last_direction = snake_now_direction
		# 更新食物位置
		update_food()
		# 绘制游戏，触发 _draw()
		queue_redraw()
		# 检测是否游戏获胜
		if snake_body.size() == (grid_size.x + 1) * (grid_size.y + 1):
			# 游戏获胜
			game_success()


# decide snake direction
func decide_now_direction():
	if Input.is_action_just_pressed("turn_up") && snake_last_direction != Vector2.DOWN:
		snake_now_direction = Vector2.UP
	elif Input.is_action_just_pressed("turn_down") && snake_last_direction != Vector2.UP:
		snake_now_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("turn_right") && snake_last_direction != Vector2.LEFT:
		snake_now_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("turn_left") && snake_last_direction != Vector2.RIGHT:
		snake_now_direction = Vector2.LEFT


# 蛇头碰撞检测
func check_snake_head() -> bool:
	var snake_head: Vector2 = snake_now_direction + snake_body.get(0)
	# 边界碰撞检测
	if (snake_head.x < 0 || snake_head.x > grid_size.x || snake_head.y < 0 || snake_head.y > grid_size.y):
		return false
	# 蛇身碰撞检测
	if (snake_body.has(snake_head)):
		return false
	return true


# 更新蛇
func update_snake():
	var snake_head: Vector2 = snake_now_direction + snake_body.get(0)
	# 增加头部
	snake_body.insert(0, snake_head)
	# 尾部删除
	if snake_head != food_position:
		snake_body.pop_back()


# 更新食物
func update_food() -> void:
	# 蛇占满了所有区域就不生成食物了
	if snake_body.size() == (grid_size.x + 1) * (grid_size.y + 1):
		return
	if snake_body.get(0) == food_position:
		# 随机位置产生食物
		init_food()


# 绘制游戏界面
func _draw():
	for i in range(grid_size.x + 1):
		for j in range(grid_size.y + 1):
			draw_rect(Rect2(Vector2(i, j) * cell_size, Vector2(cell_size, cell_size)), Color.BLACK, false)
	# draw food
	draw_rect(Rect2(food_position * cell_size, Vector2(cell_size, cell_size)), Color.RED)
	# draw snake body
	for item in snake_body:
		draw_rect(Rect2(item * cell_size, Vector2(cell_size, cell_size)), Color.GREEN)


# 游戏结束
func game_ending():
	print("Game Over!")
	get_tree().paused = true


# 游戏成功
func game_success():
	print("You Win!")
	get_tree().paused = true
