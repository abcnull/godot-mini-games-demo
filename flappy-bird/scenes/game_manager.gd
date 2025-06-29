extends Node

## 飞翔的小鸟
# 管理游戏：开始，暂停，结束，重新开始
# 负责统一对各个场景发送游戏中的重要信号

## 游戏规则
# 通过鼠标或者键盘点击的频率控制小鸟上飞，否则小鸟会因为重力自动下落
# 小鸟掉落地面或者碰撞到树干会导致 game over
# 小鸟每通过一个障碍会得 1 分
# 游戏结束后会统计当局得分并且会存储最高得分

## 设计逻辑
# 1.游戏开始初始化：游戏音乐，得分系统，按钮等初始化，发送游戏开始信号
# 2.游戏开始后，触发背景，障碍物运动
# 	2.1 背景不断的运动，到一定时候滚动回来
#	2.2 障碍物不断运动，到一定时候逃出界面的障碍物销毁释放，在一定时候在新的位置生成
# 	2.3 地板障碍物不断运动，到一定时候滚动回来
# 3.小鸟监听键盘鼠标线上飞，否则下落
# 4.障碍物进行碰撞检测
# 	4.1 小鸟逃出障碍物得分，最高分需要刷记录
#	4.2 小鸟碰撞上树枝，game over
#	4.3 小鸟碰撞上地板，game over
# 5.游戏结束
# 	5.1 触发结束界面展示和游戏暂停（得分和最高分）
#	5.2 重新开始游戏

# 分数
var now_score: int = 0 # 游戏当局得分
var highest_score: int = 0 # 游戏历史最高分
# 音乐
var earn_music: AudioStreamPlayer2D # 获取得分的音乐
var die_music: AudioStreamPlayer2D # 死亡的音乐
# 音乐是否开启
var is_music_on: bool = true

func _ready():
	earn_music = AudioStreamPlayer2D.new()
	add_child(earn_music)
	earn_music.stream = GlobalVarGd.EARN_SCORE_MUSIC
	die_music = AudioStreamPlayer2D.new()
	add_child(die_music)
	die_music.stream = GlobalVarGd.DIE_MUSIC
	process_mode = Node.PROCESS_MODE_ALWAYS

## 初始化的游戏数据
func init_game():
	now_score = 0
	highest_score = 0

## 开始游戏
func start_game():
	init_game() # 初始化数值
	get_tree().paused = false # 场景开始动起来
	SignalBusGd.start_game_singal.emit() # 发送开始游戏动信号
	
## 游戏结束
func end_game():
	#SignalBusGd.end_game_signal.emit() # 发送游戏结束信号,后续可能播放结束动画
	get_tree().quit()
	
## 游戏重新开始，其实是进入开始界面
func restart_game():
	get_tree().change_scene_to_file(GlobalVarGd.MAIN_SCENE)
	is_music_on = true

## 游戏暂停
func pause_game():
	get_tree().paused = true # 游戏暂停

## 角色死亡后...
func on_bird_died():
	if GameManagerGd.is_music_on == true:
		die_music.playing = true
	pause_game() # 游戏暂停
	save_score(now_score) # 存储本局得分
	SignalBusGd.died_signal.emit() # 向各个场景发送角色死亡的信号

## 若最高分则保存到磁盘
func save_score(score: int): 
	var h_score = load_highest_score() # 获取磁盘的历史最高分
	if h_score < score:
		h_score = score
		# 用于向用户设备文件中存储数据
		var scorefile = FileAccess.open(GlobalVarGd.SAVE_FILE, FileAccess.WRITE)
		var content = {"highest_score" : h_score}
		scorefile.store_var(content)
	highest_score = h_score # 最高分

## 读取磁盘中的最高分
func load_highest_score():
	if FileAccess.file_exists(GlobalVarGd.SAVE_FILE):
		var scorefile = FileAccess.open(GlobalVarGd.SAVE_FILE, FileAccess.READ)
		return (scorefile.get_var())["highest_score"]
	return 0

## 得分了 
func add_score(): 
	if GameManagerGd.is_music_on == true:
		earn_music.playing = true
	now_score += 1
	SignalBusGd.score_signal.emit(now_score) # 发射得分信号
