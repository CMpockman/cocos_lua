--=======================================================================
-- File Name    : move_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 14:20:03
-- Description  : make obj can move
-- Modify       :
--=======================================================================

local MoveNode = ComponentMgr:GetComponent("MOVE")
if not MoveNode then
    MoveNode = ComponentMgr:CreateComponent("MOVE")
end

MoveNode.MAX_SPEED = 2000
MoveNode.interval = nil

function MoveNode:SetMoveInterval(interval)
    self.interval = interval
end
local move_offset = {
    left       = {-1, 0},
    right      = {1, 0},
    up         = {0, 1},
    down       = {0, -1},
    left_up    = {-1, 1},
    right_up   = {1, 1},
    left_down  = {-1, -1},
    right_down = {1, -1},
}

MoveNode.forbid_move_state = {}
function MoveNode:SetForbidState(key, value)
    self.forbid_move_state[key] = value
end
function MoveNode:_Uninit()
    self.jump_target_x = nil
    self.jump_target_y = nil
    self.jump_method   = nil
    self.position  = nil
    self.speed     = nil

    self.next_pos   = nil
    self.target_pos = nil

    return 1
end

function MoveNode:_Init(position, speed)
    self.position    = position
    self.speed       = speed
    if self.speed > self.MAX_SPEED then
        self.speed = self.MAX_SPEED
    end
    self.cur_speed_x = 0
    self.cur_speed_y = 0
    self.interval_frame = math.floor(self.interval * GameMgr:GetFPS())

    self.next_pos   = {x = nil, y = nil}
    self.target_pos = {x = nil, y = nil}
    self.jump_target_x = nil
    self.jump_target_y = nil
    self.jump_method   = nil
    return 1
end

function MoveNode:OnActive(frame)
    if self:IsArriveTarget() == 1 then
        return
    end
    if self:IsHaveNextPos() ~= 1 then
        return
    end
    local fun = Stat:GetStatFunc("move active")
    if (frame - self.move_frame) >= self.interval_frame then
        self:MoveToTarget()
    end
    if fun then
        fun()
    end
end

function MoveNode:StopMove()
    self.target_pos.x = nil
    self.target_pos.y = nil
    self.next_pos.x   = nil
    self.next_pos.y   = nil
    self.cur_speed_x  = 0
    self.cur_speed_y  = 0
    self.move_frame = nil
end

function MoveNode:Stop()
    local owner = self:GetParent()
    if owner:TryCall("SetActionState", Def.STATE_NORMAL) ~= 1 then
        return 0
    end
    self:StopMove()
    local event_name = owner:GetClassName()..".STOP"
    Event:FireEvent(event_name, owner:GetId())
    return 1
end

function MoveNode:MoveTo(x, y)
    local fun = Stat:GetStatFunc("move to")

    x = math.floor(x)
    y = math.floor(y)
    local owner = self:GetParent()
    local can_move = 1
    for state, _ in pairs(self.forbid_move_state) do
        if owner:TryCall("GetBuffState", state) then
            can_move = 0
            break
        end
    end
    local state = owner:TryCall("GetActionState")
    if state == Def.STATE_DEAD or state == Def.STATE_HIT then
        can_move = 0
    end
    if can_move == 1 then
        -- local event_name = owner:GetClassName()..".MOVETO"
        -- Event:FireEvent(event_name, owner:GetId(), x, y)
        local scene = SceneMgr:GetCurrentScene()
        if scene.OnCharacterMove then
            scene:OnCharacterMove(owner:GetId(), x, y)
        end
        Map:OnCharacterMove(owner:GetId(), x, y)
        local old_speed_x = self.cur_speed_x
        local old_speed_y = self.cur_speed_y
        self.cur_speed_x = x - self.position.x
        self.cur_speed_y = y - self.position.y

        if old_speed_x == 0 and old_speed_y == 0 then
            local event_name = owner:GetClassName()..".RUN"
            Event:FireEvent(event_name, owner:GetId())
        end
        if self.cur_speed_x > 0 then
            owner:SetDirection("right")
        elseif self.cur_speed_x < 0 then
            owner:SetDirection("left")
        end
        self.position.x = x
        self.position.y = y
    else
        self.cur_speed_x = 0
        self.cur_speed_y = 0
    end
    self.move_frame = GameMgr:GetCurrentFrame()
    if fun then
        fun()
    end
end

function MoveNode:GoTo(x, y, call_back)
    x = math.floor(x)
    y = math.floor(y)
    local owner = self:GetParent()
    if self.position.x == x and self.position.y == y then
        return
    end
    if owner:TryCall("SetActionState", Def.STATE_RUN) ~= 1 then
        return
    end
    local event_name = owner:GetClassName()..".GOTO"
    Event:FireEvent(event_name, owner:GetId(), x, y)
    self.target_pos.x = x
    self.target_pos.y = y
    self:GenerateNextPos()
    self.call_back = call_back
    if not self.move_frame then
        self:MoveToTarget()
    end
end

function MoveNode:MoveToTarget()
    self:MoveTo(self.next_pos.x, self.next_pos.y)
    if self:IsArriveTarget() == 1 then
        self:Stop()
        if self.call_back then
            Lib:SafeCall(self.call_back)
        end
    else
        self:GenerateNextPos()
    end
end

function MoveNode:GenerateNextPos()
    if self:IsHaveTarget() ~= 1 then
        return
    end
    local x, y = self.position.x, self.position.y
    local distance = Lib:GetDistance(x, y, self.target_pos.x, self.target_pos.y)
    if distance <= self.speed then
        self.next_pos.x = self.target_pos.x
        self.next_pos.y = self.target_pos.y
        return
    end
    local rate = self.speed / distance
    local offset_x = math.ceil((self.target_pos.x - x) * rate)
    local offset_y = math.ceil((self.target_pos.y - y) * rate)

    self.next_pos.x = x + offset_x
    self.next_pos.y = y + offset_y
end

function MoveNode:MoveByDirection(direction)
    self:SetDirection(direction)
    local offset_x, offset_y = unpack(move_offset[direction])

    self:MoveTo(self.position.x + (offset_x * self.speed), self.position.y + (offset_y * self.speed))
end

function MoveNode:DirectMove(x, y)
    local owner = self:GetParent()
    if owner:TryCall("SetActionState", Def.STATE_MOVE) ~= 1 then
        return 0
    end
    self:StopMove()
    local event_name = owner:GetClassName()..".DIRECT_MOVE"
    Event:FireEvent(event_name, owner:GetId(), x, y)
    self.position.x = x
    self.position.y = y
    return 1
end

function MoveNode:TransportTo(x, y)
    self:StopMove()
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".TRANSPORT"
    Event:FireEvent(event_name, owner:GetId(), x, y)
    self.position.x = x
    self.position.y = y
end

function MoveNode:GetPosition()
    return self.position
end

function MoveNode:GetMoveSpeed()
    return self.speed
end

function MoveNode:SetMoveSpeed(speed)
    local old_speed = self.speed
    self.speed = speed
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".SET_MOVE_SPEED"
    Event:FireEvent(event_name, owner:GetId(), speed, old_speed)
end

function MoveNode:GetCurSpeed()
    return self.cur_speed_x, self.cur_speed_y
end

function MoveNode:IsHaveTarget()
    if not self.target_pos.x or not self.target_pos.y then
        return 0
    end
    return 1
end

function MoveNode:IsHaveNextPos()
    if not self.next_pos.x or not self.next_pos.y then
        return 0
    end
    return 1
end

function MoveNode:IsArriveTarget()
    if self:IsHaveTarget() ~= 1 then
        return 0
    end
    if self.position.x ~= self.target_pos.x or self.position.y ~= self.target_pos.y then
        return 0
    end
    return 1
end

function MoveNode:SetMaxSpeed(max_speed)
    self.MAX_SPEED = max_speed
end

function MoveNode:Jump(target_x, target_y, method)
    local owner = self:GetParent()
    local can_move = 1
    for state, _ in pairs(self.forbid_move_state) do
        if owner:TryCall("GetBuffState", state) then
            can_move = 0
            break
        end
    end
    local state = owner:TryCall("GetActionState")
    if state == Def.STATE_DEAD or state == Def.STATE_HIT then
        can_move = 0
    end
    if can_move ~= 1 then
        return 0
    end
    if owner:TryCall("SetActionState", Def.STATE_JUMP) ~= 1 then
        return 0
    end
    self:StopMove()
    self.jump_target_x = target_x
    self.jump_target_y = target_y
    self.jump_method = method
    local event_name = owner:GetClassName()..".JUMP"
    Event:FireEvent(event_name, owner:GetId(), target_x, target_y, method)

    if method ~= Def.JUMP_WAIT then
        self:JumpToTarget()
    end
    return 1
end

function MoveNode:JumpToTarget()
    if not self.jump_target_x or not self.jump_target_y or not self.jump_method then
        return 0
    end
    local owner = self:GetParent()
    self:StopMove()
    local event_name = owner:GetClassName()..".JUMP_TO_TARGET"
    Event:FireEvent(event_name, owner:GetId(), self.jump_target_x, self.jump_target_y, self.jump_method)
    self.position.x = self.jump_target_x
    self.position.y = self.jump_target_y
    self.jump_target_x = nil
    self.jump_target_y = nil
    self.jump_method = nil
    return 1
end
