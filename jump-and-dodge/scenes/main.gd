extends Node

## jump and dodge 跳跃和躲避

## 游戏规则
# 1.随机产生障碍物
# 2.恐龙需要跳跃或者下蹲来躲避
# 3.恐龙行走的距离越远得分越高

## 游戏逻辑
# 1.准备开始。监听按键开始
# 2.游戏进行中
#	2.1 每帧计算恐龙速度，达到一定时候恐龙速度 +1，但是有最大值
#		2.1.1 恐龙每帧运动，判断未开始，播放站立
#		2.1.2 恐龙每帧运动，判断 run，播放 run
#		2.1.3 恐龙每帧运动，判断跳跃，播放跳跃，和音效
#		2.1.4 恐龙每帧运动，判断下蹲，播放下蹲，更改碰撞检测区域
#	2.2 注意 camera 跟随着也要跟着角色一起移动
#	2.3 背景图片可使用 ParallaxLayer 不断更新
#	2.4 地面位置也要更新
#	2.5 生成障碍物（时机可自己定义）
#		2.5.1 生成碰撞基础物体
#		2.5.2 生成碰撞小鸟（一定概率）
#		2.5.3 生成后注意 connect 上指定方法，方法内做游戏结束处理
# 	2.6 移除消失的障碍物
# 3.游戏结束。计算最高分，界面绘制，游戏暂停

# 预先加载障碍物
var stump_scene: PackedScene = preload("res://scenes/stump.tscn")
var rock_scene: PackedScene = preload("res://scenes/rock.tscn")
var barrel_scene: PackedScene = preload("res://scenes/barrel.tscn")
var bird_scene: PackedScene = preload("res://scenes/bird.tscn")

# 游戏组件的属性值
var screen_size : Vector2i # 屏幕 size
var ground_height : int # 地面高度

# 游戏的属性
const MAX_SPEED : int = 1500 # 恐龙最大速度
var game_running : bool # 游戏状态
var speed : int # 恐龙速度
var score: int # 恐龙运动的距离得分
var high_score : int # 最高分
var obstacle_types: Array[PackedScene] = [stump_scene, rock_scene, barrel_scene] # 障碍物类型
var obstacles : Array[Node2D] = [] # 障碍物数组

@onready var hud: CanvasLayer = $HUD # 游戏界面 hud
@onready var dino: CharacterBody2D = $Dino # 小恐龙
@onready var ground: StaticBody2D = $Ground # 地面
@onready var game_over_menu: CanvasLayer = $GameOver # 游戏结束界面
@onready var camera_2d: Camera2D = $Camera2D
func _ready():
	screen_size = get_window().size # 窗口宽度
	ground_height = ground.get_ground_height() # 获取地面高度
	
	game_over_menu.get_node("Button").pressed.connect(new_game)
	
	# 开始游戏
	new_game()

func _physics_process(delta: float) -> void:
	# 游戏如果没有开始，就需要监听开始按钮
	if not game_running:
		if Input.is_action_pressed("ui_accept"):
			hud.hide_start_btn() # 隐藏开始按钮
			game_running = true # 游戏开始
		return
	
	# 游戏如果是进行中
	
	# 恐龙速度改变
	dino.velocity.x = (10 + score / 1000) / delta
	dino.velocity.x = MAX_SPEED if dino.velocity.x > MAX_SPEED else dino.velocity.x # 限制最大恐龙速度
	camera_2d.position.x += (10 + score / 1000)
	
	# 更新分数
	score += 1
	hud.update_score(score / 60) # 分数更新
	
	# 更新地面位置
	if camera_2d.position.x - ground.position.x >= screen_size.x * 1.5:
		ground.position.x += screen_size.x
		
	# 生成障碍物
	if obstacles.is_empty():
		generate_obs()
		
	# 移除消失的障碍物
	for obs in obstacles:
		if obs.position.x < (camera_2d.position.x - screen_size.x):
			remove_obs(obs)

## 初始游戏
func new_game():
	# 处理上局游戏的残余
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear() # 障碍物数组移除所有
	game_over_menu.hide() # 隐藏游戏结束界面
	
	# init
	game_running = false # 游戏未开始
	score = 0 # 分数初始化
	hud.update_score(0) # 分数更新
	speed = 10 # 恐龙速度
	dino.position = Vector2i(150, 485) # 恐龙起始位置 todo
	dino.velocity = Vector2i.ZERO # 恐龙速度 0
	# 地面位置是 0，0 是因为地面自己设置了 offset
	ground.position = Vector2i.ZERO # 初始地面位置
	camera_2d.position = screen_size / 2
	# 展示开始按钮
	hud.show_start_btn() # hud 展示开始按钮
	get_tree().paused = false

## 游戏结束
func game_over():
	game_running = false
	get_tree().paused = true
	check_high_score() # 核查最高分
	game_over_menu.show() # 结束界面展示

## 障碍物生成
func generate_obs():
	# 随机生成一个障碍物
	var obs: Node2D = obstacle_types.pick_random().instantiate() # 随机一个障碍物
	var obs_height: int = obs.get_node("Sprite2D").texture.get_height() # 障碍物的高度
	var obs_scale: Vector2 = obs.get_node("Sprite2D").scale # 障碍物的尺寸
	# 障碍物位置
	var obs_vect = Vector2(
		camera_2d.position.x + screen_size.x / 2 + (100 if randi() % 2 == 0 else 250),
		screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
	)
	# 障碍物添加到游戏中
	add_obs(obs, obs_vect)
	
	# 1/5 概率随机逻辑去生成障碍物小鸟
	if randi() % 2 == 0:
		# 生成小鸟障碍物
		obs = bird_scene.instantiate()
		# 小鸟的位置
		obs_vect = Vector2(
			camera_2d.position.x + screen_size.x / 2 + 100,
			screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - (300 if randi_range(0, 1) == 0 else 115)
		)
		add_obs(obs, obs_vect)

## 障碍物添加到游戏中
func add_obs(obs: Node2D, vect: Vector2i):
	obs.position = vect
	obs.body_entered.connect(hit_obs) # 障碍物触碰连接上 hit_obs 方法
	obstacles.append(obs)
	add_child(obs)

## 清除障碍物
func remove_obs(obs: Node):
	obstacles.erase(obs)
	obs.queue_free()

## 检查最高分
func check_high_score():
	if score > high_score:
		high_score = score # 最高分 每次开始游戏时都不清除，以实现保存最高分的目的
		hud.update_high_score(high_score / 60)

#################
# 信号连接
#################

## 触碰到障碍物信号发出后承接
func hit_obs(body):
	if body == dino:
		game_over() # 游戏结束
