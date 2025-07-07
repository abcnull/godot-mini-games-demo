extends Node

## fruit-catcher 接水果

## 游戏规则
# 1.鼠标左右移动控制篮子移动
# 2.水果随机位置从空中掉落
# 3.接住水果的一分，水果没接住生命值扣除 1/5

## 逻辑设计
# 1.初始化游戏，包括得分，生命值，以及界面
# 2.开始游戏点击信号监听
# 	2.1 一些初始化逻辑
# 	2.2 游戏内篮子逻辑执行
#		2.2.1 篮子监听移动
#		2.2.2 篮子监听碰撞信号，并向上发出，场景树根节点承接后进行得分处理
# 	2.3 游戏内水果 rigid 逻辑执行
#		2.3.1 水果 rigit 是可以自动下落的，所以 ready 中设置其产生的随机位置
#		2.3.2 水果如果监听到超出视口，则销毁且发出信号，场景树根节点代码监听到后进行扣血
#		2.3.3 水果通过 Timer 每隔 1s 来生成
# 3.暂停游戏界面
#	3.1 通过监听 esc 触发
#	3.2 界面展现
#	3.3 重新开始游戏
#	3.4 退出游戏
# 4.游戏结束界面
# 	4.1 血条为 0 触发
#	4.2 重新开始
#	4.3 退出游戏


@export var fruit_scene: PackedScene # fruit 的场景

var game_started = false # 游戏是否开始
var score: int = 0 # 游戏得分
var health: int = 100 # 游戏生命值

@onready var pause_menu: CanvasLayer = $PauseMenu # 暂停界面
@onready var game_over_menu: CanvasLayer = $GameOverMenu # 游戏结束界面
@onready var hud: CanvasLayer = $HUD
@onready var fruit_timer: Timer = $FruitTimer # 水果掉落计时器
func _ready():
	# 游戏设置暂停
	get_tree().paused = true

func _process(_delta):
	# 游戏没开始，任何按键点击没有效果
	if not game_started:
		return
	# 按下 esc 暂停游戏
	if Input.is_action_just_pressed("toggle_pause"):
		pause_game()

## 开始游戏逻辑
func new_game():
	game_started = true # 游戏开始
	# 初始一些逻辑
	get_tree().call_group("fruits", "queue_free") # 清除
	score = 0
	health = 100
	fruit_timer.start() # 物品掉落的 timer 开始，timer 是不断循环的
	# 初始化一些界面效果
	game_over_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # 隐藏鼠标
	hud.show_hud(score,health) # 得分展示 血条展示
	get_tree().paused = false

## 暂停游戏
func pause_game():
	get_tree().paused = true # 游戏暂停
	pause_menu.show_pause_game() # 暂停菜单出现
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # 展现出鼠标光标
	
## 游戏结束
func game_over():
	get_tree().paused = true
	game_over_menu.show_game_over(score) # 结束菜单出现
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # 鼠标出现
	
## 重新开始游戏
func resume_game():
	get_tree().paused = false
	pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#####################
# 监听一些信号
#####################

## hud 中最初的“开始”按钮被点击，游戏开始
func _on_hud_start_game():
	# 开始游戏
	new_game()

## 当 fruit 延时时间到了，就会让 fruit 掉落
func _on_fruit_timer_timeout():
	# 让 fruit 的场景生成出来一个 fruit 实例
	var fruit = fruit_scene.instantiate()
	# 该 furit 实例的 fruit_missed 信号连接到 fruit_missed()
	fruit.fruit_missed.connect(fruit_missed)
	# fruit 实例挂在场景树中
	add_child(fruit)

## 当篮子接到 fruit（篮子传递信号过来）
func fruit_caught():
	# 更新得分
	score += 1
	hud.update_score(score)
	# 让 fruit 生成的越来越快
	fruit_timer.wait_time -= 0.01

## 当 fruit 被 miss（fruit 传递信号过来）
func fruit_missed():
	# 血量减少
	health -= 20
	hud.update_health(health)
	# 血量减少到 0 游戏结束
	if health <= 0:
		game_over() # 游戏结束

#####################
# 监听菜单上的各种按钮点击后
#####################

## 当点击暂停界面的继续游戏
func _on_pause_menu_resume():
	resume_game()

## 当点击结束界面的开始新游戏
func _on_game_over_menu_restart():
	new_game()

## 当点击暂停/游戏结束 界面的 exit
func _on_menu_exit():
	get_tree().quit()
