<div align=left>
  <a href="https://godotengine.org/" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/godot engine-4.x-blue"/>
  </a>
  <a href="https://godotengine.org/" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/GDScript-green"/>
  </a>
  <img src="https://img.shields.io/badge/game-demo-white"/>
</div>

# 简介
godot 制作的小游戏合集demo

Classic mini-games demo through godot using GDscript.
Under continuous development

# snake game 贪吃蛇
游戏介绍：复刻经典贪吃蛇小游戏
- 随机食物与随机 snake 开始位置
- 固定网格大小
- 方向键可操控蛇的移动
- 按键与蛇运动方向相同会让蛇以 2 倍速度移动
- 碰撞墙壁和蛇身检测
- 吃到食物后蛇身增长 1 格

demo锻炼：
- GDScript 语法
- 图形绘制
- 逻辑思维

<img src="https://github.com/abcnull/Image-Resources/blob/master/godot-mini-games-demo/snake_game.gif" width="150" height="150" alt="图片描述">


# flappy bird 飞翔的小鸟
游戏介绍：复刻经典飞翔的小鸟小游戏
- 随机管道位置
- 固定网格大小
- 点击屏幕可控制小鸟向上飞
- 碰撞检测
- 小鸟飞得分与存储最高分

demo锻炼：
- GDScript 语法
- 碰撞检测
- 信号的用法
- 场景树的知识
- 界面绘制
- 初识图片添加
- 初识动画添加
- 初识音乐添加

<img src="https://github.com/abcnull/Image-Resources/blob/master/godot-mini-games-demo/flappy_bird.gif" width="120" height="200" alt="图片描述">

# brick breaker 打砖块
游戏介绍：复刻经典大砖块小游戏
- 砖块，墙体，小球以及挡板
- 小球与挡板，小球与墙体的碰撞检测
- 小球的速度的改变与反弹

demo锻炼：
- GDScript 语法
- 碰撞检测
- 图形绘制

<img src="https://github.com/abcnull/Image-Resources/blob/master/godot-mini-games-demo/brick_breaker.gif" width="150" height="150" alt="图片描述">

# minesweeper 扫雷
游戏介绍：复刻经典扫雷小游戏
- 扫雷方格底层隐藏的可能是地雷，区域空，或者 1-8 的数字。区域空表示周围一圈没地雷，1-8 表示周围一圈地雷的个数
- 扫雷方格如果是没有被翻开的，可以被用户左键点击，表示翻牌，右键点击表示设置红旗，红旗标记表示此处有地雷
- 扫雷方格如果是被红旗标记的，点击则会取消红旗标记
- 扫雷方格如果是被翻开了，右键点击设置红旗没有效果，左键点击，如果点击是空白区域，则没有效果，如果点击的是数字区域，则会判定该数字周围一圈的红旗数量和数字是否一样，如果一样则该数字周围一圈区域全部打开，但是如果周围有地雷，游戏就结束
- 当左键点击的未翻开的区域为数字时，该方格直接展现
- 当左键点击的未翻开的区域为地雷时，游戏结束，并显示出所有的地雷和检查所有的红旗标记是否准确
- 当左键点击的未翻开的区域为空白区域时，则会再次遍历周围一圈的每个方格（但是会过滤掉地雷的方格），如果又存在方格为空白区域时候在走一遍类似的逻辑，直到小方格代表一个 1-8 的数字
- 把所有地雷找出来即算获胜

demo锻炼：
- GDScript 语法
- 逻辑思维

设计思路：
- 1.首先给游戏设置众多方格，为一个数组，使用 TileMap
    - 1.1 方格数组中，底层隐藏着地雷或者数字，同时还得有一个属性表示它是否被翻开，所以使用 Vector2i(x, y)，x 表示底部隐藏的是什么，y 表示翻开与否
    - 1.2 方格最开始需要被初始化一定的地雷，通过 shuffle 进行地雷随机分布
    - 1.3 每个方格都会有默认贴图，初始化时候当翻开单元格时候，本质是做了新的贴图操作
- 2.点击 _input 需要翻开一些单元格
    - 2.1 当右键点击，最简单，设置红旗或者红旗消失，右键仅可操作未翻开的区域或者红旗标记的区域
    - 2.2 当左键点击，此处为关键逻辑
        - 2.2.1 当左键点击红旗，红旗消失
        - 2.2.2 当左键点击未翻开的区域
            - 2.2.2.1 未翻开的区域是地雷，game over
            - 2.2.2.2 未翻开的区域是 1-8 数字，直接翻开该数字
            - 2.2.2.3 未翻开的区域是空区域 0，则判断周围一圈方格，当不为地雷同也没有被翻开时候走递归
        - 2.2.3 当左键点击的是翻开的区域
            - 2.2.3.1 翻开的区域是地雷，不存在此情况
            - 2.2.3.2 翻开的区域是 1-8 数字，则判断周围一圈方格，当周围一圈方格的红旗数量等于当前翻开的区域的数字时候，则翻开周围一圈没有被翻开的方格,此处的翻开周围一圈其实也是走了递归
            - 2.2.3.3 翻开的区域是空区域 0，界面无任何效果
    - 2.3 当右键点击
        - 2.3.1 当右键点击红旗，红旗消失
        - 2.3.2 当右键点击未翻开的区域，出现红旗
        - 2.3.3 当右键点击翻开的区域，无任何效果
- 3.游戏结束逻辑
    - 3.1 游戏失败结束：踩中地雷触发
    - 2.3 游戏胜利结束：剩余地雷数量 == 0 && 标记的红旗数量 == 初始的地雷数量

