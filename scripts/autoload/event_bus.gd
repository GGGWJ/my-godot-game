extends Node

signal play_cast_ability(ability: Ability)

# 玩家相关信号
signal player_ready(player: Player)
signal player_health_changed(current_health: float, max_health: float)
