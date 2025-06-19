extends MarginContainer

## 管理开始菜单

@onready var start_button: Button = %StartButton
@onready var check_button: CheckButton = %CheckButton
func _ready():
	get_tree().paused = true
	start_button.pressed.connect(_on_start_button_pressed)
	check_button.toggled.connect(_on_check_button_toggled)

## 开始按钮被点击
func _on_start_button_pressed():
	GameManagerGd.start_game() # 游戏管理开始游戏
	queue_free()

## 开启/关闭音乐
func _on_check_button_toggled(is_toggled: bool):
	GameManagerGd.is_music_on = is_toggled
