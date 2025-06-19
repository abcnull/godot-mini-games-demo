extends MarginContainer

## 管理分数

@onready var score_text: Label = %ScoreText
func _ready():
	score_text.visible = false
	SignalBusGd.score_signal.connect(set_score)
	SignalBusGd.start_game_singal.connect(_on_start_game)

## 得分展现
func set_score(score: int):
	score_text.text = "得分 : " + str(score)

## 设置游戏开始后分数可见
func _on_start_game():
	score_text.visible = true
