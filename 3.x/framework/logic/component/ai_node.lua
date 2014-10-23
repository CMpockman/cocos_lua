--=======================================================================
-- File Name    : ai_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 15:26:47
-- Description  : make a obj owns AI
-- Modify       : 
--=======================================================================

local AINode = ComponentMgr:GetComponent("AI")
if not AINode then
	AINode = ComponentMgr:CreateComponent("AI")
end

function AINode:_Uninit( ... )
	self.param       = nil
	self.ai_list     = nil
	self.order_list  = nil
	self.ai_order    = nil
	self.brain_data  = nil

	return 1
end

function AINode:_Init()
	self.ai_list    = {}
	self.ai_order   = {}
	self.order_list = {}
	self.brain_data = {}
	self.param 		= {}
	return 1
end

function AINode:AddAI(ai_name, order)
	local ai_class = AI:GetClass(ai_name)
	if not ai_class then
		assert(false, "No AI [%s]", ai_name)
		return 0
	end
	self.ai_list[ai_name] = {class = Class:New(ai_class), order = order}
	self:GenerateOrderList()
	return 1
end

function AINode:RemoveAI(ai_name)
	self.ai_list[ai_name] = nil
	self:GenerateOrderList()
end

function AINode:ClearAI()
	self.ai_list = {}
end

function AINode:GenerateOrderList()
	self.order_list = {}
	local sort_table = {}
	for ai_name, ai_group in pairs(self.ai_list) do
		table.insert(sort_table, ai_name)
	end
	local function cmp(ai_1, ai_2)
		return self.ai_list[ai_1].order < self.ai_list[ai_2].order
	end
	table.sort(sort_table, cmp)
	for _, ai_name in ipairs(sort_table) do
		table.insert(self.order_list, self.ai_list[ai_name].class)
	end
end

function AINode:OnLoop()
	return self:OnActive()
end

function AINode:OnActive(frame)
	if not self.ai_list then
		return
	end
	if self:GetParent():TryCall("GetActionState") == Def.STATE_DEAD then
		return
	end
	if self:IsDebug() == 1 then
		print("================================")
	end
	for _, ai_class in ipairs(self.order_list) do
		if self:IsDebug() == 1 then
			local t = os.date("*t",time)
			local time = string.format("%02d:%02d:%02d",t.hour, t.min, t.sec)
			print(string.format("%s [AI]...[%d] %s  Active", time, self:GetParent():GetId(), ai_class:GetClassName()))
		end
		if ai_class:OnActive(frame, self:GetParent(), self) == 0 then
			return
		end
	end
end

function AINode:SetParam(param)
	self.param = param
end

function AINode:GetParam(key)
	return self.param[key]
end

function AINode:SetBrainValue(key, value)
	if self:IsDebug() == 1 then
		print(string.format("SetBrainValue key[%s] value[%s]", tostring(key), tostring(value)))
	end
	self.brain_data[key] = value
end

function AINode:GetBrainValue(key)
	return self.brain_data[key]
end

function AINode:ClearBrain()
	self.brain_data = {}
end