extends Node

## 管理游戏：开始，暂停，结束，重新开始
## 负责统一对各个场景发送游戏中的重要信号

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
