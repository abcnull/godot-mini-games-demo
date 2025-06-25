class_name Wall
extends RefCounted

## 定义一个类并指定其继承自 RefCounted，这个类就可以在其他脚本中直接使用

var wall_rect: Rect2 # 墙 rect

const WALL_LAYER = 1 << 2 # 位掩码，表示设置第 2 层
const WALL_MASK = 1 << 0 # 位掩码，表示可与 0 层碰撞

var child_rid: RID
var child_body: RID
var child_collision_shape: RID

# 构造函数：初始化墙体 rect
func _init(_wall_rect: Rect2) -> void:
	self.wall_rect = _wall_rect

# 创建墙体这个物理体，绘制身体，且设置其碰撞区域
# 可以发现绘制图形是单独的代码；物理身体是和碰撞区域直接绑定的
func build_wall(parent_rid: RID, space: RID) -> void:
	## 矩形绘制（绘制部分很独立），确定了矩形要画在什么位置
	# 创建 CanvasItem 实例-底层方法
	child_rid = RenderingServer.canvas_item_create()
	# 设置父级节点为 parent_rid
	RenderingServer.canvas_item_set_parent(child_rid, parent_rid)
	# 绘制墙体 rect，持久化的资源，不需要 _draw 每帧绘制，由 RenderingServer 渲染服务持续管理
	RenderingServer.canvas_item_add_rect(child_rid, wall_rect, Color.BURLYWOOD)
	
	## 设置物理身体，后续需要和碰撞区域关联，但没有设置物理身体在什么位置
	# 创建物理身体-底层方法
	child_body = PhysicsServer2D.body_create()
	# 设置物理物体的运动模式
	PhysicsServer2D.body_set_mode(child_body, PhysicsServer2D.BODY_MODE_STATIC)
	# 用于将 物理身体（Body） 添加到指定的 物理空间（Space） 中，核心作用是让物理身体参与目标物理空间的模拟
	# 每个场景的物理模拟运行在独立的 物理空间（Physics Space） 中（通过 World2D 管理）
	# 调用 body_set_space() 后，物理身体会成为该空间的一部分，并开始参与该空间的物理计算（如碰撞、重力等）
	# 如果不将物理身体（Body）通过 PhysicsServer2D.body_set_space() 显式绑定到某个物理空间（Space），该物理身体将无法参与任何物理模拟
	PhysicsServer2D.body_set_space(child_body, space)
	# 设置物体所属的物理层，属于 2 层
	PhysicsServer2D.body_set_collision_layer(child_body, WALL_LAYER)
	# 设置该物体的碰撞层，允许与第 0 层碰撞，第 0 层只有小球
	PhysicsServer2D.body_set_collision_mask(child_body, WALL_MASK)
	
	## 设置碰撞区域为矩形，但没有设置物理身体在什么位置
	# 创建物理引擎的碰撞形状 2d 矩形-底层方法
	child_collision_shape = PhysicsServer2D.rectangle_shape_create()
	# 设置碰撞形状具体大小，设置它的半宽和半高
	# 仅设置碰撞形状的尺寸（如矩形的大小、圆形的半径等），而不设置碰撞形状的位置
	PhysicsServer2D.shape_set_data(child_collision_shape, wall_rect.size / 2)
	
	## 设置碰撞区域的偏移量
	# 是一个 2D 变换矩阵（Transform2D）的单位矩阵，表示没有任何变换（旋转、缩放、平移）的默认状态。它通常用于初始化或重置变换操作（缩放是指缩放的轴，如缩放 x 轴，缩放 y 轴）
	var transform2d = Transform2D.IDENTITY
	# origin 表示物体的 平移偏移量
	# 例子：transform.origin = Vector2(100, 50) 表示将物体移动到 (100, 50)，此时，节点的 position 属性也会变为 (100, 50)，因为 position 是 transform.origin 的快捷方式
	# 核心目的是确保物体的变换（旋转、缩放、位置）以墙体的几何中心为基准
	# 物理引擎通常使用半尺寸（half-extents） 来定义矩形，因为这能简化旋转、碰撞检测等计算； 而 UI 布局 Rect2 通常更倾向于直接使用 全尺寸
	transform2d.origin = (wall_rect.position + wall_rect.end) / 2
	
	## 绑定物理体和碰撞区域，同时设置物理体或者说碰撞区域 中心点的 偏移量(位置)
	# 物理体 child_body 绑定碰撞区域 child_collision_shape
	# 设置碰撞区域 child_collision_shape 中心位置距离原点 transform2d 的偏移量
	PhysicsServer2D.body_add_shape(child_body, child_collision_shape, transform2d)
	
func release():
	# 砖块释放 碰撞区域
	RenderingServer.free_rid(child_collision_shape)
	# 立即从物理空间移除碰撞体
	PhysicsServer2D.body_set_space(child_body, RID())
	# 砖块释放 物理体
	PhysicsServer2D.free_rid(child_body)
	# 砖块释放 canvas
	RenderingServer.free_rid(child_rid)
