extends Node

## 全局的常量和变量

# 文件路径，游戏中需要使用的路径
const SAVE_FILE = "user://save_flappy_bird_game.dat" # 游戏存储文件
const MAIN_SCENE = "res://scenes/main.tscn" # 开始的场景
const OBSTACLE_SCENE = preload("res://scenes/obstacle.tscn") # 障碍物场景
const EARN_SCORE_MUSIC = preload("res://assets/earn_score_music.mp3")
const DIE_MUSIC = preload("res://assets/die_music.mp3")

# 游戏中背景的位置和速度
const BORD_X: float       = -750 # 背景边界
const PIC_MOVE_SPEED: int = -100 # 背景移动速度

# 鸟的属性
const GRAVITY = 750 # 重力加速度
const UP_ACC = 250 # 向上飞的加速度

# 柱状障碍物的位置和速度
const INIT_POSITION_X = 300 # 障碍物初始位置
const OBSTACLE_RAND_X_FROM = 300 # 障碍物 x 值最小
const OBSTACLE_RAND_X_TO = 750 # 障碍物 x 值最大
const OBSTACLE_RAND_Y_FROM = -160 # 障碍物 y 值最小
const OBSTACLE_RAND_Y_TO = 160 # 障碍物 y 值最大
const OBSTACLE_SPEED: int = -100
