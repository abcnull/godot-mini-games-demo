extends TileMap

## tetris 俄罗斯方块

## 游戏规则
# - 左右键控制左右移动
# - 上控制方块转向
# - 下控制方块向下加速
# - 空格控制方块直接下落
# - 方块每隔一定时间自动下落
# - 堆积满了一行即可消除一行，并且获得 10 积分
# - 方块被占满就会失败
# - 方块随着清除的行越来越多，游戏速度也会加快

## 游戏设计
# - 1.游戏初始化
# 	- 1.1 游戏定义好各个方块的坐标，以及旋转后的坐标
# 	- 1.2 定义其他的变量，包括速度，初始位置，当前运动的方块等
# - 2.使用 TileMap 来布置，设置 active 和 board 两层，active 层放运动的方块，board 层放堆积好的方块
# - 3.每帧循环绘制
# 	- 3.1 监听键盘事件，左右下事件 step 增加
# 	- 3.2 监听键盘事件，空格事件，直接将 active 的方块绘制到下方
#	- 3.3 不管监听到什么事件，step 自动向下增加一定步数
#	- 3.4 某个方向的 step 增加到一定数值时，真的移动一格子，去绘制它
#		- 3.4.1 真的可以移动这一格，就正常移动
#		- 3.4.2 移动不了这一格，判断是否是正在向下移动，如果不是向下移动最简单，什么都不管
#			3.4.2.1 如果是向下移动，向下移动就触发检测该行是否满了，没有满不用做什么操作
#				3.4.2.2.1 从满了的最底下的那一行开始，自动从上面一行向下面一行赋值，从而实现满行的被覆盖
#			3.4.2.2 创建新的方块在游戏中，设定位置和颜色还有方块种类
#			3.4.2.3 创建下一个方块在 panel 中
#			3.4.2.4 判断游戏结束，即创建的方块有没有和 board 重合
#	4.TileMap 绘制的几个重要的函数
#		4.1 在指定图层，设置 srouce_id 以及图集 set_cell(active_layer, pos + unit_pos, TILE_ID, atlas)
#		4.2 在指定图层，清除 source_id 以及图集 erase_cell(active_layer, cur_pos + unit_pos)
#		4.3 获取指定图层的 source_id，如果为空则返回 -1 get_cell_source_id(board_layer, pos)

# tetrominoes
# 对应 "I"
const i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
const i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
const i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
const i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
const i := [i_0, i_90, i_180, i_270]
# 对应 "T"
const t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
const t := [t_0, t_90, t_180, t_270]
# 对应 "O"
const o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const o := [o_0, o_90, o_180, o_270]
# 对应 "Z"
const z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
const z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
const z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
const z := [z_0, z_90, z_180, z_270]
# 对应 "S"
const s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
const s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
const s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
const s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
const s := [s_0, s_90, s_180, s_270]
# 对应 "L"
const l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
const l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
const l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
const l := [l_0, l_90, l_180, l_270]
# 对应 "J"
const j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
const j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
const j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
const j := [j_0, j_90, j_180, j_270]

# 当前方块是 i, t, o, z, s, l, j
var piece_type: Array # 当前方块类型，比如 var j := [j_0, j_90, j_180, j_270]
 # 当前方块旋转度的索引 0，1，2，3 => 0，90，180，270
var rotation_index := 0
# 方块所属颜色的在图集上的位置，即方块的颜色
var piece_atlas: Vector2i
# 有这几种图形
const shapes_solid := [i, t, o, z, s, l, j] # 固定 todo
var shapes := [i, t, o, z, s, l, j] # 可不停的被打乱顺序

# 下一个方块
var next_piece_type: Array # 当前方块类型
var next_rotation_index := 0 # 下一个方块方向
var next_piece_atlas: Vector2i # 下一个方块颜色

# grid size，可移动的区域
const COLS := 10
const ROWS := 20
# layer variables
var board_layer := 0 # tailMap 的 board 图层
var active_layer := 1 # tailMap 的 active 图层

# 游戏基础设置
var score := 0 # 记录游戏总得分
const REWARD := 10 # 每次消除一行加 10 分
var speed := 1.0 # 游戏方块当前每帧的下落速度
const ACCEL := 0.1 # 每次得分后固定要加的速度
var steps := [0, 0, 0] # index 0，1，2 对应 左，右下
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN] # 方向
const STEPS_LIMIT := 45 # step 超过 50 就需要真实移动
const START_POS := Vector2i(5, 1) # 方块的起始位置
var cur_pos := START_POS # 方块当前位置
const NEXT_PANEL_POS := Vector2i(15, 6) # 下一个方块 panel 的位置
const TILE_ID := 0 # source id
var game_running := false # 判断游戏是否在运行

@onready var hud: CanvasLayer = $HUD
func _ready():
	new_game() # 开始新游戏
	hud.start_btn_pressed.connect(new_game) # 重新开始游戏 connect 某方法

## 每帧循环执行
# is_action_pressed 判断当前帧是否被按下，按键按压下的整个过程返回 true
# is_action_just_pressed 判断按键按下的动作的那一帧返回 true
func _process(delta):
	if !game_running: 
		return

	if Input.is_action_pressed("ui_left"):
		steps[0] += 10 # 左
	elif Input.is_action_pressed("ui_right"):
		steps[1] += 10 # 右
	elif Input.is_action_pressed("ui_down"):
		steps[2] += 10 # 下
	elif Input.is_action_just_pressed("ui_up"):
		# 旋转方块并绘制
		rotate_piece()
	elif Input.is_action_just_pressed("ui_accept"):
		fall_piece() # 空格或者回车，方块直接掉落
		steps[2] = STEPS_LIMIT
	
	# 每帧要加一定速率向下
	# step：0 左，1 右，2 下
	steps[2] += speed # 下落
	
	# 每个方向算 step 值
	for i in range(steps.size()):
		# 超过这个限度，才会移动，一般按住键，会经历好多帧
		if steps[i] >= STEPS_LIMIT:
			move_piece(DIRECTIONS[i]) # 朝指定方向移动
			steps[i] = 0

# 开始新游戏
func new_game():
	# clear
	clear_piece() # 清除 tailMap 中的 active 图层中的方块
	clear_board() # 清除 tailMap 中的 board 图层中固定好的方块
	clear_panel() # 清除 tailMap 中下一个方块展示的区域
	# reset
	score = 0 # 分数重置
	speed = 1.0 # 方块速度重置
	steps = [0, 0, 0] # 步数重置 0:left, 1:right, 2:down
	rotation_index = 0 # 旋转初始化
	cur_pos = START_POS # 当前方块位置
	# 界面 reset
	hud.hide_gameover_label()
	hud.set_score(score)
	# 清除一些操作，以及绘制新的方块，以及绘制下一个方块到 panel 区域
	create_piece()
	# game start
	game_running = true # 游戏开始
	get_tree().paused = false

## 选择出一个方块类型，比如是 i, t, o, z, s, l, j 任意一个，它本身又是一个数组
func pick_piece() -> Array:
	# 随机一个 i, t, o, z, s, l, j
	shapes.shuffle()
	return shapes[0]

## reset 以及创建并且绘制一个方块类型，以及 panel 绘制下一个方块
func create_piece():
	# reset
	steps = [0, 0, 0] # 0:left, 1:right, 2:down
	cur_pos = START_POS # 当前方块位置
	rotation_index = 0 # 初始旋转
	
	# 创建新的下落方块
	if next_piece_type == null || next_piece_type.is_empty(): # 一开始没有下一个方块
		piece_type = pick_piece() # 选出一个方块类型
		rotation_index = randi() % 4 # 随机的方块方向
	else:  # 存在下一个方块
		piece_type = next_piece_type # 下一个方块赋过来
		rotation_index = next_rotation_index # 下一个方块方向赋过来
	piece_atlas = find_atlas_from_piece_type(piece_type) # 指定方块类型对应指定的颜色
	draw_piece(piece_type[rotation_index], cur_pos, piece_atlas) # 绘制方块
	
	# 创建 panel 区域中下一个方块
	next_piece_type = pick_piece() # 选出下一个方块类型
	next_rotation_index = randi() % 4
	next_piece_atlas = find_atlas_from_piece_type(next_piece_type) # 下一个方块类型对应指定的颜色
	draw_piece(next_piece_type[next_rotation_index], NEXT_PANEL_POS, next_piece_atlas) # 展示下一个方块类型

## 根据指定 piece 类型，找到对应图集坐标
func find_atlas_from_piece_type(piece: Array) -> Vector2i:
	return Vector2i(shapes_solid.find(piece), 0)

## 清除 tailMap 中的 active 图层中的方块
func clear_piece(): 
	if piece_type == null || piece_type.is_empty():
		return
	for unit_pos in piece_type[rotation_index]:
		# 擦除图层 layer 上位于 coords 坐标的单元格
		erase_cell(active_layer, cur_pos + unit_pos)
		
## 清除 tailMap 中的 board 图层
func clear_board():
	for i in range(ROWS):
		for j in range(COLS):
			erase_cell(board_layer, Vector2i(j + 1, i + 1))

## 清除 panel 区域
func clear_panel():
	for row in range(5, 10):
		for col in range(14, 19):
			erase_cell(active_layer, Vector2i(col, row))

## 绘制 piece 方块
## peice 方块类型每个方格的相较于 pos 的位置 arr
## pos 新位置
## atlas 使用的是图集哪个颜色
func draw_piece(piece: Array, pos: Vector2i, atlas: Vector2i):
	for unit_pos in piece:
		set_cell(active_layer, pos + unit_pos, TILE_ID, atlas)

## 旋转方块并且绘制
func rotate_piece():
	if not can_rotate(): 
		return
	# 如果可以正常旋转
	clear_piece() # 清除当前的被控制下落的方块
	rotation_index = (rotation_index + 1) % 4 # 获取新的旋转索引
	draw_piece(piece_type[rotation_index], cur_pos, piece_atlas) # 绘制新的
		
## 移动方块，入参是超哪个方向移动
func move_piece(dir: Vector2i):
	if can_move(dir): # 如果可以移动
		clear_piece() # 清除当前控制的方块
		cur_pos += dir # 计算新的位置
		draw_piece(piece_type[rotation_index], cur_pos, piece_atlas) # 绘制新的
	else:
		# 如果不能移动且方向还是向下的
		# 这说明触底了！
		if dir == Vector2i.DOWN:
			land_piece() # 触底操作 active_layer => board_layer
			check_and_deal_rows() # 从 row 行开始每一行被上面一行 copy 下来
			
			clear_panel() # 清除 panel
			create_piece() # 创建新的方块
			
			check_game_over() # 检查游戏是否结束

## 方块直接瞬移到底部
func fall_piece(): 
	var temp_pos: Vector2i = cur_pos
	# 逐行向下
	for i in range(1, ROWS + 1):
		# 逐个单元格
		for unit_pos in piece_type[rotation_index]:
			if !is_free(cur_pos + Vector2i.DOWN * i + unit_pos):
				# 清除当前位置的方块
				clear_piece()
				draw_piece(piece_type[rotation_index], temp_pos, piece_atlas)
				# 如果单元格存在重合，直接返回上一次的 temp_pos
				cur_pos = temp_pos
				return
		temp_pos = cur_pos + Vector2i.DOWN * i

## 判断是否可以移动
func can_move(dir: Vector2i) -> bool:
	for unit_pos in piece_type[rotation_index]:
		if not is_free(unit_pos + cur_pos + dir):
			return false
	return true

## 判断当前的方块是否能被旋转
func can_rotate() -> bool:
	var temp_rotation_index = (rotation_index + 1) % 4 # 当前旋转索引
	for unit_pos in piece_type[temp_rotation_index]:
		if not is_free(unit_pos + cur_pos):
			return false # 返回不能旋转
	return true # 返回可以旋转

## 当前 board 层该位置单元格是否存在，如果为空返回 true
func is_free(pos) -> bool:
	# 判断该位置单元格 source_id（TILE_ID） 是否存在，-1 表示不存在
	# 不存在的情况是之前没有通过 set_cell 给它设置 source_id
	return get_cell_source_id(board_layer, pos) == -1

## 方块触底操作 layer 改变
func land_piece():
	# 触底时候，从 active 层设置到 board 层
	for unit_pos in piece_type[rotation_index]:
		# active_layer => board_layer
		erase_cell(active_layer, cur_pos + unit_pos)
		set_cell(board_layer, cur_pos + unit_pos, TILE_ID, piece_atlas)

## 检查行是不是要减少，以及得分
func check_and_deal_rows():
	var is_delayed = false # 是否已经延迟过了
	var row: int = ROWS
	while row > 0:
		var count = 0 # 一行中 board 层累计存在堆积的单元格的数量
		# 一列列遍历
		for i in range(COLS):
			# 如果该 board 层该单元格存在
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		# 如果该行中的每列都有堆积方格，那么需要处理堆积满的那些行
		# 并且下次还是从 row 行算，row 行不变（从底行向顶行遍历）
		if count == COLS:
			if !is_delayed:
				# 延迟 200ms
				await get_tree().create_timer(0.2).timeout
				is_delayed = true
			# 所有行的转变 以及 得分
			shift_rows(row)
			# 每次得分后游戏速度增加 0.25
			speed += ACCEL
		else: # 如果该行没有格子堆积满，就下一行（向顶上遍历一行）
			row -= 1

## 处理变换当前行 以及 得分
func shift_rows(row):
	var count = 1 # 被消除的行数
	# [row -> 1) 每次 -1
	for i in range(row, 1, -1):
		var flag: bool = true
		# [0 -> COLS)
		for j in range(COLS):
			# 返回 row 行上一行的，同一列的，单元格的图集坐标
			var atlas = get_cell_atlas_coords(board_layer, Vector2i(j + 1, i - 1))
			# 如果返回 Vector2i(-1, -1) 其实表示该单元格图集是不存在的
			if atlas == Vector2i(-1, -1): # 上一行单元格是空图集
				# 清除 row 行的单元格；相当于把上一行的单元格 copy 到下一行
				erase_cell(board_layer, Vector2i(j + 1, i))
				flag = false
			else: # 上一行单元格不是空图集
				# 上一行单元格 copy 到 row 行里
				set_cell(board_layer, Vector2i(j + 1, i), TILE_ID, atlas)
		if flag:
			count += 1
	# 因为顶部有灰色的墙体 todo 顶部灰色墙体取消
	count = 1 if count == 1 else count - 1
	# 得分
	score += (REWARD * count)
	hud.set_score(score)

## 核查游戏是否结束
func check_game_over():
	for unit_pos in piece_type[rotation_index]:
		if not is_free(unit_pos + cur_pos): # 超出了
			land_piece() # 触底操作 active_layer => board_layer
			hud.show_gameover_label() # 游戏结束展示
			game_running = false # 游戏结束
			get_tree().paused = true
