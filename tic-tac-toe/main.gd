extends Node

## 井字棋小游戏 Tic-Tac-Toe

## 游戏规则
# 分别 2 人进行游戏，轮流进行
# 谁能先让自己拥有的图案形成 3 连的场景，谁获胜
# 格子大小 3 * 3

## 设计思路
# 1.游戏开始先初始化数据，包括白板界面，玩家数据
# 2.监听鼠标点击事件，每次点击后触发逻辑执行
# 	2.1 先 check 如果点击区域超出，或者点击了已经点过的区域，则不执行逻辑
#   2.2 如果点击的单元格没点过，再点击的 postion 位置贴图
#   2.3 判定是否获胜，获胜游戏结束，否则往下走（判断是否获胜需要计算下）
#   2.4 判定是否平局，平局游戏结束，否则往下走（判断是否平局需要计算下）
#   2.5 玩家更新成新的一位
# 3.游戏结束时候，出现弹窗，弹窗中点击按钮游戏重新开始

@export var circle_scene : PackedScene # 圈圈
@export var cross_scene : PackedScene # 红叉

var grid_data : Array # 方格二维数组，0 表示没有点击过
var board_size : float # 白板尺码
var cell_size : float # 白板单元格尺码
var moves : int # 记录当前是第几步
var player : int # 玩家

var panelMark: Node # panel 上记录的红叉还是圈圈

func _ready():
	board_size = $Board.texture.get_width()
	cell_size = board_size / 3
	# 初始化游戏
	new_game()

## 初始化游戏
func new_game():
	# 删除圈圈和红叉
	# 对所有属于名为 "mark" 的组的节点调用 queue_free() 方法，从而批量销毁这些节点
	get_tree().call_group("mark", "queue_free") # todo
	# 隐藏 GameOverMenu
	$GameOverMenu.hide()
	# 方格初始化
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	moves = 0 # 0 步
	player = 1 # 玩家 1
	# 更新 panel
	update_panel(player, $PlayerPanel.get_position() + Vector2(cell_size, cell_size) / 2)
	get_tree().paused = false

## 监听点击
func _input(event):
	# 不是点击事件不用管
	if not event.is_action_pressed("click_action"):
		return
	event = event as InputEventMouseButton
	# check
	if event.position.x > board_size || event.position.y > board_size:
		return
	# 计算点击的区域是 x 方向第几个格子，以及 y 方向第几个格子
	var grid_pos: Vector2i = Vector2i(event.position / cell_size)
	# 方格点击过就不用管了
	if grid_data[grid_pos.y][grid_pos.x] != 0:
		return
	
	# 方格设置成该玩家
	grid_data[grid_pos.y][grid_pos.x] = player
	# 创建此格子内的贴图
	create_marker(player, grid_pos)
	# 步数加一
	moves += 1
	
	# 如果获胜了
	if check_win(player):
		# 游戏结束绘制
		end_game(player)
	# 如果是平局
	elif moves == 9:
		end_game(null)
		
	# 更换另一个玩家
	player = 2 if player == 1 else 1
	# 更新 panel 面板贴图
	update_panel(player, $PlayerPanel.get_position() + Vector2(cell_size, cell_size) / 2)

## 将玩家贴图到方格内
func create_marker(player: int, position: Vector2i):
	# 计算真实坐标
	var realPostion = position * cell_size + Vector2(cell_size, cell_size) / 2
	# 玩家 1
	if player == 1: # todo 为什么是把场景添加进去而不是节点添加进去
		var circle = circle_scene.instantiate() # 初始化场景
		circle.position = realPostion # 设置圈圈的位置
		add_child(circle) # 添加孩子
	# 玩家 2
	else:
		var cross = cross_scene.instantiate() # 初始化场景
		cross.position = realPostion # 设置红叉的位置
		add_child(cross) # 添加孩子

## 更新 panel 区域
func update_panel(player: int, position: Vector2):
	if panelMark != null: panelMark.queue_free()
	if player == 1:
		panelMark = circle_scene.instantiate() # 初始化场景
		panelMark.position = position # 设置圈圈的位置
		add_child(panelMark) # 添加孩子
	else:
		panelMark = cross_scene.instantiate() # 初始化场景
		panelMark.position = position # 设置红叉的位置
		add_child(panelMark) # 添加孩子

## 检查当前 player 是否获胜
func check_win(player: int) -> bool: 
	# 检查斜边 \
	if grid_data[0][0] == player && grid_data[1][1] == player && grid_data[2][2] == player:
		return true
	# 检查斜边 /
	if grid_data[2][0] == player && grid_data[1][1] == player && grid_data[0][2] == player:
		return true
	# 检查每一行和每一列
	for i in grid_data.size():
		if grid_data[i][0] == player && grid_data[i][1] == player && grid_data[i][2] == player:
			return true
		if grid_data[0][i] == player && grid_data[1][i] == player && grid_data[2][i] == player:
			return true
	return false

## 绘制游戏结束
func end_game(player):
	get_tree().paused = true # 游戏停止
	$GameOverMenu.show() # 结束界面展现
	$GameOverMenu.get_node("ResultLabel").text = (
		"玩家 " + str(player) + " 获胜！" if player != null 
		else "平局！"
	)
		
## 当重新按钮点击触发
func _on_game_over_menu_restart():
	new_game()
