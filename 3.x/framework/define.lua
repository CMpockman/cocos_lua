--===================================================
-- File Name    : define.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:59
-- Description  :
-- Modify       :
--===================================================

if not Def then
    Def = {}
end

Def.DEFAULT_FPS = 25

Def.TYPE_NONE    = 0
Def.TYPE_HERO    = 1
Def.TYPE_MONSTER = 2

Def.CAMP_NONE  = 0
Def.CAMP_WHITE = 1
Def.CAMP_BLACK = 2
Def.CAMP_GRAY  = 3
Def.CAMP_RED   = 4
Def.CAMP_BLUE  = 5
Def.CAMP_GREEN = 6

Def.STATE_NORMAL = "S_NORMAL"
Def.STATE_RUN    = "S_RUN"
Def.STATE_MOVE   = "S_MOVE"
Def.STATE_JUMP   = "S_JUMP"
Def.STATE_HIT    = "S_HIT"
Def.STATE_SKILL  = "S_SKILL"
Def.STATE_DEAD   = "S_DEAD"
Def.STATE_REBORN   = "S_REBORN"

Def.JUMP_WAIT    = 1
Def.JUMP_NO_WAIT = 2
Def.JUMP_ASSIST  = 3
Def.JUMP_OUT     = 4

--DEBUFF
Def.BUFF_SLEEP     = "sleep"
Def.BUFF_STUN      = "stun"
Def.BUFF_FREEZE    = "freeze"  --冰冻
Def.BUFF_CHAOS     = "chaos"   --混乱
Def.BUFF_FEAR      = "fear"    --恐惧
Def.BUFF_CHARM     = "charm"   --魅惑
Def.BUFF_ANGRY     = "angry"   --被嘲讽，使目标生气攻击对方
Def.BUFF_SLOW_MOVE = "slow_move"
Def.BUFF_FAST_MOVE = "fast_move"
Def.BUFF_POISON    = "poison"
Def.BUFF_ON_FIRE   = "on_fire"

--BUFF
Def.BUFF_GOD       = "god"

if not cc then
    return
end


Def.ZOOM_LEVEL_WORLD = 1
Def.ZOOM_LEVEL_BULLET = 2
Def.ZOOM_LEVEL_TITLE = 3
Def.ZOOM_LEVEL_PERFORMANCE = 4
Def.ZOOM_LEVEL_MENU = 5
Def.ZOOM_LEVEL_SUB_MENU = 6

Def.ZOOM_LEVEL_SYSMSG = 1000

Def.color_list = {
    ["black"] = cc.c3b(0, 0, 0),
    ["red"]   = cc.c3b(255, 0, 0),
    ["green"] = cc.c3b(0, 255, 0),
    ["blue"]  = cc.c3b(0, 0, 255),
    ["white"] = cc.c3b(255, 255, 255),
    ["yellow"] = cc.c3b(255, 255, 0),
    ["gray"] = cc.c3b(96, 96, 96)
}

Def.MOVE_INTERVAL = 0.1

Def.TAG_MOVE_ACTION  = 1
Def.TAG_SCALE_ACTION = 2
Def.TAG_ATTACK_ACTION = 3

function Def:GetColor(color_name)
    return self.color_list[color_name]
end
