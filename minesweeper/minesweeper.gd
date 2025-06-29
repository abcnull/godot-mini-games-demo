extends TileMap

## 扫雷游戏主逻辑

## 游戏规则：
# 扫雷方格底层隐藏的可能是地雷，区域空，或者 1-8 的数字。区域空表示周围一圈没地雷，1-8 表示周围一圈地雷的个数
# 扫雷方格如果是没有被翻开的，可以被用户左键点击，表示翻牌，右键点击表示设置红旗，红旗标记表示此处有地雷
# 扫雷方格如果是被红旗标记的，点击则会取消红旗标记
# 扫雷方格如果是被翻开了，右键点击设置红旗没有效果，左键点击，如果点击是空白区域，则没有效果，如果点击的是数字区域，则会判定该数字周围一圈的红旗数量和数字是否一样，如果一样则该数字周围一圈区域全部打开，但是如果周围有地雷，游戏就结束
# 当左键点击的未翻开的区域为数字时，该方格直接展现
# 当左键点击的未翻开的区域为地雷时，游戏结束，并显示出所有的地雷和检查所有的红旗标记是否准确
# 当左键点击的未翻开的区域为空白区域时，则会再次遍历周围一圈的每个方格（但是会过滤掉地雷的方格），如果又存在方格为空白区域时候在走一遍类似的逻辑，直到小方格代表一个 1-8 的数字
# 把所有地雷找出来即算获胜

## 游戏设计：
# 1.首先给游戏设置众多方格，为一个数组，使用 TileMap
#	1.1 方格数组中，底层隐藏着地雷或者数字，同时还得有一个属性表示它是否被翻开，所以使用 Vector2i(x, y)，x 表示底部隐藏的是什么，y 表示翻开与否
#	1.2 方格最开始需要被初始化一定的地雷，通过 shuffle 进行地雷随机分布
#	1.3 每个方格都会有默认贴图，初始化时候当翻开单元格时候，本质是做了新的贴图操作
# 2.点击 _input 需要翻开一些单元格
#	2.1 当右键点击，最简单，设置红旗或者红旗消失，右键仅可操作未翻开的区域或者红旗标记的区域
# 	2.2 当左键点击，此处为关键逻辑
# 		2.2.1 当左键点击红旗，红旗消失
#		2.2.2 当左键点击未翻开的区域
#			2.2.2.1 未翻开的区域是地雷，game over
#			2.2.2.2 未翻开的区域是 1-8 数字，直接翻开该数字
#			2.2.2.3 未翻开的区域是空区域 0，则判断周围一圈方格，当不为地雷同也没有被翻开时候走递归
# 		2.2.3 当左键点击的是翻开的区域
# 			2.2.3.1 翻开的区域是地雷，不存在此情况
# 			2.2.3.2 翻开的区域是 1-8 数字，则判断周围一圈方格，当周围一圈方格的红旗数量等于当前翻开的区域的数字时候，则翻开周围一圈没有被翻开的方格,此处的翻开周围一圈其实也是走了递归
#			2.2.3.3 翻开的区域是空区域 0，界面无任何效果
# 	2.3 当右键点击
#		2.3.1 当右键点击红旗，红旗消失
# 		2.3.2 当右键点击未翻开的区域，出现红旗
#		2.3.3 当右键点击翻开的区域，无任何效果
# 3.游戏结束逻辑
#	3.1 游戏失败结束：踩中地雷触发
# 	2.3 游戏胜利结束：剩余地雷数量 == 0 && 标记的红旗数量 == 初始的地雷数量

# 游戏界面
const GRID_ROWS := 16 # 行数
const GRID_COLUMNS := 30 # 列数

# 游戏状态，默认游戏结束
var game_status = false

# x: [-1, 8]，-1 表示有地雷，0 表示周围一圈 0 个地雷，1-8 表示周围一圈 1-8 个地雷
# y: [0, 2]，0 表示没有翻开，1 表示翻开了，2 表示标记了旗帜
# 每个单元格，x 表示底层隐藏着内容，y 表示上层否翻开了
var cells_info: Array[Vector2i]
# 单元格的底部隐藏值: [-1, 8]，-1 表示有地雷，0 表示周围一圈 0 个地雷，1-8 表示周围一圈 1-8 个地雷
enum HIDDEN_VAL {MINE = -1, ZERO = 0, ONE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5, SIX = 6, SEVEN = 7, EIGHT = 8}
# 单元格的是否翻开: [0, 2]，0 表示没有翻开，1 表示翻开了，2 表示标记了旗帜
enum REVEAL_VAL {UNREVEAL = 0, REVEALED = 1, FLAGGED = 2}
# 单元格翻开后展示的图集，每个底部隐藏值对应着一个图片，即翻开后应该显示的图片
const ATLAS_DIC: Dictionary = {
	HIDDEN_VAL.MINE: Vector2i(0, 3), # 翻开的地雷
	HIDDEN_VAL.ZERO: Vector2i(3, 0), # 翻开的 0 的区域
	HIDDEN_VAL.ONE: Vector2i(0, 1), # 翻开的数字 1
	HIDDEN_VAL.TWO: Vector2i(1, 1), # 翻开的数字 2
	HIDDEN_VAL.THREE: Vector2i(2, 1), # 翻开的数字 3
	HIDDEN_VAL.FOUR: Vector2i(3, 1), # 翻开的数字 4
	HIDDEN_VAL.FIVE: Vector2i(0, 2), # 翻开的数字 5
	HIDDEN_VAL.SIX: Vector2i(1, 2), # 翻开的数字 6
	HIDDEN_VAL.SEVEN: Vector2i(2, 2), # 翻开的数字 7
	HIDDEN_VAL.EIGHT: Vector2i(3, 2) # 翻开的数字 8
}
# 额外的一些图集，在特定时候展现此图集
enum UNHIDDEN_VAL {NORMAL_MINE, CROSS_MINE, RED_FLAG}
const EXTRA_ATLAS_DIC: Dictionary = {
	UNHIDDEN_VAL.NORMAL_MINE: Vector2i(2, 0), # 普通的地雷
	UNHIDDEN_VAL.CROSS_MINE: Vector2i(1, 3), # 被标记错误的地雷
	UNHIDDEN_VAL.RED_FLAG: Vector2i(1, 0) # 红旗
}

# 地雷数量
const MINE_COUNT := 60
# 还剩下的地雷数量
var remain_mines_count: int = MINE_COUNT

# 已经设置了的旗子的数量
var flag_count: int = 0

@onready var button: Button = $CanvasLayer/VBoxContainer/Button
@onready var label: Label = $CanvasLayer/VBoxContainer/Label
func _ready() -> void:
	button.visible = false
	newGame() # 开始游戏

## 开始一个新游戏，初始化的过程 done
func newGame() -> void:
	cells_info.clear()
	remain_mines_count = MINE_COUNT
	flag_count = 0
	# 遍历每个单元格，初始化
	for i in range(GRID_ROWS):
		for j in range(GRID_COLUMNS):
			# 给 Vector2i(j, i) 单元格设置 Vector2i(0, 0) 这个图片
			set_cell(0, Vector2i(j, i), 0, Vector2i(0, 0)) # todo
			# 初始化每个单元格的信息
			cells_info.append(Vector2i(0, 0))
	# 给地雷随机安插在单元格中
	for i in range(MINE_COUNT):
		cells_info[i].x = HIDDEN_VAL.MINE
	# 整个界面把这些地雷随机打乱
	cells_info.shuffle()
	# 给每个非雷的单元格计算数字
	for i in range(GRID_ROWS):
		for j in range(GRID_COLUMNS):
			var cell_coord = Vector2i(j, i) # 当前单元格的坐标
			var cell_index = getIndexOfCell(cell_coord) # cell index
			# 如果该单元格底层不是地雷，就需要计算该单元格的数字（否则该单元格还是 -1 表示地雷）
			if cells_info[cell_index].x != HIDDEN_VAL.MINE:
				# 统计周边地雷数量
				var mineCount: int = getSurroundMineCount(cell_coord)
				# 如果地雷计数 > 0，设置当前单元格的值是数字，否则单元格还是 0
				if mineCount > 0:
					cells_info[cell_index].x = mineCount
	# 设置游戏开始
	game_status = true
				
## 监听左右键点击 done
func _input(event: InputEvent) -> void:
	# 游戏结束则不处理
	if game_status == false:
		return
	# 左键点击
	if event.is_action_pressed("reveal"):
		# 获取点击时候单元格的坐标
		# CanvasItem: get_local_mouse_position()
		# TileMap: local_to_map()
		var cell_coord: Vector2i = local_to_map(get_local_mouse_position())
		var cell_index: int = getIndexOfCell(cell_coord)
		# 不管何种点击，如果被点击区域是旗帜，则旗子消失
		if cells_info[cell_index].y == REVEAL_VAL.FLAGGED:
			# 如果是点击的是旗子，则旗子消失
			set_cell(0, cell_coord, 0, Vector2i(0, 0))
			cells_info[cell_index].y = REVEAL_VAL.UNREVEAL
			flag_count -= 1
			if cells_info[cell_index].x == HIDDEN_VAL.MINE: # 如果该单元底层是地雷
				remain_mines_count += 1
		# 如果左键点击的是没有掀开的单元格，则需要按照某种逻辑掀开
		elif cells_info[cell_index].y == REVEAL_VAL.UNREVEAL:
			# 掀开单元格和其周边区域
			revealCellAndSurround(cell_coord)
		# 如果左键点击的是一个掀开的单元格，则需要按照一定逻辑再判定要不要掀开周边
		elif cells_info[cell_index].y == REVEAL_VAL.REVEALED:
			# 掀开单元格和其周边区域
			revealCellAndSurround(cell_coord)
		# 最后一个地雷被找出即为取胜
		if remain_mines_count == 0 && flag_count == MINE_COUNT:
			# 游戏结束
			end_game()
 	# 右键点击
	elif event.is_action_pressed("flag"): 
		# 获取点击时候单元格的坐标
		# CanvasItem: get_local_mouse_position()
		# TileMap: local_to_map()
		var cell_coord: Vector2i = local_to_map(get_local_mouse_position())
		var cell_index: int = getIndexOfCell(cell_coord)
		# 不管何种点击，如果被点击区域是旗帜，则旗子消失
		if cells_info[cell_index].y == REVEAL_VAL.FLAGGED:
			# 如果是点击的是旗子，则旗子消失
			set_cell(0, cell_coord, 0, Vector2i(0, 0))
			cells_info[cell_index].y = REVEAL_VAL.UNREVEAL
			flag_count -= 1
			if cells_info[cell_index].x == HIDDEN_VAL.MINE: # 如果该单元底层是地雷
				remain_mines_count += 1
		# 如果右键点击的单元格是没有被掀开的，则需要打上旗帜
		elif cells_info[cell_index].y == REVEAL_VAL.UNREVEAL:
			set_cell(0, cell_coord, 0, EXTRA_ATLAS_DIC[UNHIDDEN_VAL.RED_FLAG])
			cells_info[cell_index].y = REVEAL_VAL.FLAGGED
			flag_count += 1
			if cells_info[cell_index].x == HIDDEN_VAL.MINE: # 如果该单元底层是地雷
				remain_mines_count -= 1
		# 最后一个地雷被找出即为取胜
		if remain_mines_count == 0 && flag_count == MINE_COUNT:
			# 游戏结束
			end_game()
			

## 核心逻辑：揭开 cellCoord 位置的单元格和周边的单元格（最开始一次的点击是 cellCoord 尚未揭开）
# 出口：如果 cellCoord 是数字 1-8，则直接揭开 cellCoord 即可结束，递归出口
# 如果 cellCoord 是数字 0，则遍历周围一圈每个单元格，再分别按照 revealCellAndSurround 方法去揭开
func revealCellAndSurround(cell_coord : Vector2i):
	var cell_index = getIndexOfCell(cell_coord)
	
	# 如果该单元格没有揭开
	if cells_info[cell_index].y == REVEAL_VAL.UNREVEAL:

		# 如果单元格底层数字 >= 1，就应该直接揭开这一个就结束
		if cells_info[cell_index].x >= HIDDEN_VAL.ONE:
			# 获取底层数字对应哪个图片
			var atlas_coord = ATLAS_DIC[cells_info[cell_index].x]
			set_cell(0, cell_coord, 0, atlas_coord)
			cells_info[cell_index].y = REVEAL_VAL.REVEALED
			return
		# 如果单元格底层是一个地雷，揭开它游戏就结束了
		elif cells_info[cell_index].x == HIDDEN_VAL.MINE:
			var atlas_coord = ATLAS_DIC[cells_info[cell_index].x]
			set_cell(0, cell_coord, 0, atlas_coord)
			cells_info[cell_index].y = REVEAL_VAL.REVEALED
			# 循环把所有地雷都掀开，并标记错误的旗帜，游戏结束
			revealAllMinesAndMarkFlag()
			# 游戏结束
			end_game()
			return
		# 如果单元格底层是 0，则需要循环揭开周边那些底层不是地雷的单元格
		elif cells_info[cell_index].x == HIDDEN_VAL.ZERO:
			# 底层为 0 的当前单元格置为揭开
			var atlas_coord = ATLAS_DIC[cells_info[cell_index].x]
			set_cell(0, cell_coord, 0, atlas_coord)
			cells_info[cell_index].y = REVEAL_VAL.REVEALED
			# 获取周围一共 9 个单元格
			for i in range(-1, 2):
				for j in range(-1, 2):
					var offset_coord: Vector2i = cell_coord + Vector2i(j, i)
					if not isCoordInside(offset_coord): # 如果 offset_coord 不在 grid 中就 continue
						continue
					# 如果 offset_coord 底层不是一个地雷，并且 offset_coord 是一个没有揭开的单元格，才会触发递归逻辑
					# offset_coord 如果不判断没有揭开，那么就会陷入无限的递归导致 stackoverflow，因为 a,b 其中 a 揭开了已经，找到 b，b 假如揭开了，陷入递归又会找到 a，然后又会找到 b...
					# offset_coord 如果不判断底层不是一个地雷，offset_coord 当等于一个地雷时候，会导致游戏直接结束
					if cells_info[getIndexOfCell(offset_coord)].x != HIDDEN_VAL.MINE && cells_info[getIndexOfCell(offset_coord)].y == REVEAL_VAL.UNREVEAL:
						# 递归执行
						revealCellAndSurround(offset_coord)
	# 如果单元格被标记成小红旗
	elif cells_info[cell_index].y == REVEAL_VAL.FLAGGED:
		# 小红旗的单元格就不管它
		return
	# 如果单元格已经被揭开
	elif cells_info[cell_index].y == REVEAL_VAL.REVEALED: 
		# 如果 cell_coord 底层是 1-9 数字，且 cell_coord 一圈的小红旗数量和数字是相等的，则对 cell_index 周边做递归执行
		if cells_info[cell_index].x >= HIDDEN_VAL.ONE && getSurroundFlagCount(cell_coord) == cells_info[cell_index].x:
			# 获取周围一共 9 个单元格
			for i in range(-1, 2):
				for j in range(-1, 2):
					var offset_coord: Vector2i = cell_coord + Vector2i(j, i)
					if not isCoordInside(offset_coord): # 如果 offset_coord 不在 grid 中就 continue
						continue
				 	# 如果 offset_coord 展示的是没有揭开的就需要递归
					# 没有揭开的底层的值可能是一个 地雷，就触发游戏结束了（合乎游戏规则）
					# 没有揭开的底层的值可能是一个 数值，就正常走到函数出口了（合乎逻辑）
					# 没有揭开的底层的值可能是一个 0，就又进行递归了（合乎逻辑）
					if cells_info[getIndexOfCell(offset_coord)].y == REVEAL_VAL.UNREVEAL:
						# 递归执行
						revealCellAndSurround(offset_coord)

## 获取周边一圈区域地雷数量 done
func getSurroundMineCount(cell_coord : Vector2i) -> int:
	var count: int = 0 # 地雷数量
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset_coord: Vector2i = cell_coord + Vector2i(j, i)
			# 超出边界就 continue
			if not isCoordInside(offset_coord):
				continue
			# 如果是地雷
			if cells_info[getIndexOfCell(offset_coord)].x == HIDDEN_VAL.MINE:
				count += 1
	return count

## 揭开所有的地雷，和把错误的旗帜标记正确 done			
func revealAllMinesAndMarkFlag():
	# 遍历所有没有被揭开区域和旗帜标记的区域
	var index: int = 0
	for item in cells_info:
		# 把 cells_info 数组下标转化成单元格坐标
		var cell_coord: Vector2i = convertIndex2Coord(index)
		# 如果该单元格是未揭开的区域
		if item.y == REVEAL_VAL.UNREVEAL:
			if item.x == HIDDEN_VAL.MINE: # 如果未揭开的区域是地雷，则展示地雷
				set_cell(0, cell_coord, 0, EXTRA_ATLAS_DIC[UNHIDDEN_VAL.NORMAL_MINE])
		# 如果该单元格是标记过的旗帜
		elif item.y == REVEAL_VAL.FLAGGED:
			if item.x != HIDDEN_VAL.MINE: # 如果是标记过的旗帜底层其实不是地雷
				set_cell(0, cell_coord, 0, EXTRA_ATLAS_DIC[UNHIDDEN_VAL.CROSS_MINE])
		index += 1
	
## 处理游戏结束流程
func end_game():
	game_status = false # 游戏结束
	get_tree().paused = true
	button.visible = true
	if remain_mines_count == 0 && flag_count == MINE_COUNT: # 游戏获胜需要额外展示
		label.visible = true

	
## 获取单元格 index done
func getIndexOfCell(cell_coord: Vector2i) -> int:
	return cell_coord.y * GRID_COLUMNS + cell_coord.x
	
## 根据 cells_info 的 index 获取单元格的坐标 done
func convertIndex2Coord(index: int) -> Vector2i:
	var i: int = index / GRID_COLUMNS
	var j: int = index % GRID_COLUMNS
	return Vector2i(j, i)

## 判断单元格坐标是否在界面单元格坐标区域内部 done
func isCoordInside(cell_coord: Vector2i) -> bool:
	if cell_coord.x >= 0 && cell_coord.x < GRID_COLUMNS && cell_coord.y >= 0 && cell_coord.y < GRID_ROWS:
		return true
	return false
	
## 获取周边一圈小红旗数量 done
func getSurroundFlagCount(cell_coord: Vector2i) -> int:
	var count: int = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset_coord: Vector2i = cell_coord + Vector2i(j, i)
			if not isCoordInside(offset_coord):
				continue
			# count + 1
			count = (count + 1) if cells_info[getIndexOfCell(offset_coord)].y == REVEAL_VAL.FLAGGED else count
	return count

## 当 重新开始 点击时
func _on_button_pressed() -> void:
	button.visible = false # 重新开始隐藏
	label.visible = false
	newGame() # 初始化游戏
	get_tree().paused = false
