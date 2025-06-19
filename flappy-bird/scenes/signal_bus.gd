extends Node

## 信号总线
## 横跨场景信号建议放于信号总线中，局部信号局部建议处理

signal start_game_singal # 开始游戏信号
signal end_game_signal # 游戏结束信号

signal died_signal # 角色死亡信号
signal score_signal # 角色得分信号
