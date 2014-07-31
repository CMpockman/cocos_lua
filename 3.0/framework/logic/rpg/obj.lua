--=======================================================================
-- File Name    : obj.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/10 18:26:16
-- Description  : obj in rpg
-- Modify       : 
--=======================================================================

if not RpgObj then
	RpgObj = Class:New(ObjBase, "RPG_OBJ")
end


function RpgObj:_Uninit( ... )
	self.attack_speed = nil
	self.target_id    = nil
	self.template_id  = nil
	self.camp         = nil
	self.property     = nil
	self.position     = nil
	self.attack_skill = nil
	self.direction    = nil

	return 1
end

function RpgObj:_Init()
	self.camp         = Def.CAMP_NONE
	self.obj_type     = Def.TYPE_NONE
	self.template_id  = template_id
	self.property     = {}
	self.position     = {x = -1, y = -1}
	self.attack_skill = nil	
	self.direction    = "none"
	self.target_id    = 0
	self.attack_speed = 1

	return 1
end

function RpgObj:IsValid()
	if not self.template_id then
		return 0
	end
	if self.direction == "none" then
		return 0
	end
	return 1
end

function RpgObj:InitAI(ai_template_list, ai_param, id_debug)

	local ai_node = self:AddComponent("ai", "AI")
	if ai_template_list then
		for order, ai_name in pairs(ai_template_list) do
			ai_node:AddAI(ai_name, order)
		end
	end
	if ai_param then
		ai_node:SetParam(ai_param)
	end
	if id_debug == 1 then
		ai_node:EnableDebug(1)
	end
	return 1
end

function RpgObj:InitMove(move_speed)
	if not move_speed then
		return 0
	end
	self:AddComponent("move", "MOVE", self:GetPosition(), move_speed)
	return 1
end

function RpgObj:InitCommand( )
	self:AddComponent("cmd", "COMMAND")
	return 1
end

function RpgObj:InitSkill(attack_skill, extra_skill_list)
	self.attack_skill = attack_skill
	local skill_node = self:AddComponent("skill", "SKILL")
	if attack_skill then
		skill_node:SetAttackSkill(attack_skill)
	end
	if extra_skill_list then
		for _, skill_config in ipairs(extra_skill_list) do
			skill_node:AddSkill(skill_config.skill_id, skill_config.level)
		end
	end
	return 1
end

function RpgObj:InitBuff()
	self:AddComponent("buff", "BUFF")
end

function RpgObj:InitProperty(property)
	if not property then
		return 0
	end
	for key, value in pairs(property) do
		self.property[key] = value
	end
	return 1
end

function RpgObj:InitActionState(init_state)
	self:AddComponent("action", "ACTION", init_state)
end

function RpgObj:SetProperty(key, value)
	self.property[key] = value
end

function RpgObj:GetProperty(key)
	return self.property[key]
end

function RpgObj:SetCamp(camp)
	self.camp = camp
end

function RpgObj:GetCamp()
	return self.camp
end

function RpgObj:SetType(type)
	self.obj_type = type
end

function RpgObj:GetType()
	return self.obj_type
end

function RpgObj:SetTemplateId(template_id)
	self.template_id = template_id
end

function RpgObj:GetTemplateId()
	return self.template_id
end

function RpgObj:SetActionState(action_state)
	local result = self:GetChild("action"):SetState(action_state)
	return result
end

function RpgObj:GetActionState()
	return self:GetChild("action"):GetState()
end

function RpgObj:SetAttackSkillId(attack_skill)
	self.attack_skill = attack_skill
end

function RpgObj:GetAttackSkillId()
	return self.attack_skill
end

function RpgObj:GetAttackRange()
	return self:TryCall("GetSkillRange", self.attack_skill)
end

function RpgObj:SetTargetId(id)
	self.target_id = id
end

function RpgObj:GetTargetId()
	return self.target_id
end

function RpgObj:GetMoveSpeed()
	return self:GetChild("move"):GetMoveSpeed()
end

function RpgObj:RawSetAttackSpeed(attack_speed)
	if not attack_speed then
		return 0
	end
	self.attack_speed = attack_speed
	return 1
end

function RpgObj:SetAttackSpeed(attack_speed)
	self.attack_speed = attack_speed
	local event_name = self:GetClassName()..".SET_ATTACK_SPEED"
	Event:FireEvent(event_name, self:GetId(), attack_speed)
end

function RpgObj:GetAttackSpeed()
	return self.attack_speed
end

function RpgObj:InsertCommand(command, delay_frame)
	if self:IsInState(Def.STATE_DEAD) == 1 then
		return
	end
	local cmd_node = self:GetChild("cmd")
	assert(cmd_node)
	cmd_node:InsertCommand(command, delay_frame)
end

function RpgObj:SetPosition(x, y)
	self.position.x = x
	self.position.y = y
end

function RpgObj:GetPosition()
	return self.position
end

function RpgObj:SetDirection(direction)
	if self.direction ~= direction then
		self.direction = direction
		local event_name = self:GetClassName()..".CHANGE_DIRECTION"
		Event:FireEvent(event_name, self:GetId(), direction)
	end
end

function RpgObj:RawSetDirection(direction)
	self.direction = direction
end

function RpgObj:GetDirection()
	return self.direction
end

function RpgObj:GetLifePercentage()
	local life = self:GetProperty("life")
	local max_life = self:GetProperty("max_life")
	if not life or not max_life then
		return 0
	end
	local percentage = life * 100 / max_life
	return percentage
end

function RpgObj:ChangeProperty(key, change_value)
	local old_value = self:GetProperty(key)
	local new_value = old_value + change_value
	if new_value < 0 then
		new_value = 0
	end

	local max_key = "max_"..key
	local max_value = self:GetProperty(max_key)
	
	if max_value then
		if new_value > max_value then
			new_value = max_value
		end
	end
	if old_value == new_value then
		return
	end
	self:SetProperty(key, new_value)
	local event_name = self:GetClassName()..".CHANGE_PROPERTY"
	Event:FireEvent(event_name, self:GetId(), key, old_value, new_value)
	if key == "life" and new_value <= 0 then
		self:Dead()
	end
end

function RpgObj:CanAttack(target_id)
	local target = CharacterPool:GetById(target_id)
	if not target or target:IsValid() ~= 1 then
		return 0
	end
	local skill_id = self:GetAttackSkillId()
	return self:TryCall("CanCastSkill", skill_id, {target_id})
end

function RpgObj:IsTargetValid(target_id)
	if not target_id then
		return 0
	end
	local target = CharacterPool:GetById(target_id)
	if not target or target:IsValid() ~= 1 then
		return 0
	end
	local skill_id = self:GetAttackSkillId()
	return self:TryCall("IsSkillTargetValid", skill_id, target)
end

function RpgObj:Attack(target_id)
	local skill_id = self:GetAttackSkillId()
	if not skill_id then
		return 0
	end

	if self:CanAttack(target_id) ~= 1 then
		return 0
	end

	local target = CharacterPool:GetById(target_id)
	if not target or target:IsValid() ~= 1  then
		return 0
	end
	local self_position = self:GetPosition()
	local target_position = target:GetPosition()
	if target_position.x > self_position.x then
		self:SetDirection("right")
	elseif target_position.x < self_position.x then
		self:SetDirection("left")
	end

	self:SetTargetId(target_id)
	return self:TryCall("CastSkill", skill_id)
end

function RpgObj:BeHit(luancher)
	if self:TryCall("Stop") ~= 1 then
		return
	end
	if self:SetActionState(Def.STATE_HIT) ~= 1 then
		return
	end
	if self._Behit then
		self:_BeHit(luancher)
	end
	local luancher_id = nil
	if luancher then
		luancher_id = luancher:GetId()
	end
	local event_name = self:GetClassName()..".BEHIT"
	Event:FireEvent(event_name, self:GetId(), luancher_id)
end

function RpgObj:Dead()
	if self:TryCall("Stop") ~= 1 then
		return
	end
	assert(self:SetActionState(Def.STATE_DEAD) == 1)
	local buff_node = self:GetChild("buff")
	if buff_node then
		buff_node:ReceiveMessage("OnOwnerDead")
	end
	local event_name = self:GetClassName()..".DEAD"
	Event:FireEvent(event_name, self:GetId())
end