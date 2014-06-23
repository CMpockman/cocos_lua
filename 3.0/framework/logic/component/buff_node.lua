--=======================================================================
-- File Name    : buff_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/16 11:37:10
-- Description  : buff node
-- Modify       : 
--=======================================================================

if not BuffNode then
	BuffNode = NewLogicNode("BUFF")
end

function BuffNode:_Uninit( ... )
	self.buff_list = nil
	self.buff_state_pool = nil
end

function BuffNode:_Init()
	self.buff_list = {}
	self.buff_state_pool = {}
	return 1
end

function BuffNode:OnActive(frame)
	if not self.buff_list then
		return
	end
	local copy_buff_list = Lib:CopyTB1(self.buff_list)
	for buff_id, buff in pairs(copy_buff_list) do
		local is_need_remove = buff:OnActive(frame)
		if is_need_remove == 1 then
			self:RemoveBuff(buff_id)
		end
	end
end

function BuffNode:AddBuff(buff_id, luancher_id, count)
	local buff = self.buff_list[buff_id]
	local is_add = 0
	local owner_id = self:GetParent():GetId()
	if not buff then
		local config = BuffMgr:GetBuffConfig(buff_id)
		if not config then
			assert(false, "Add Buff : No Buff[%s]", tostring(buff_id))
			return 0
		end
		buff = BuffMgr:NewBuff(buff_id, config.template_id)
		if buff:Init(buff_id, owner_id, config) ~= 1 then
			assert(false)
			return 0
		end

		if luancher_id then
			buff:SetLuancherId(luancher_id)
		end
		self.buff_list[buff_id] = buff
		if buff.state then
			self:AddBuffState(buff.state)
		end
		if buff.OnAdd then
			buff:OnAdd()
		end
		Event:FireEvent("BUFF.ADD", buff_id, owner_id, luancher_id, count)
	end
	buff:ChangeCount(count or 1)
	return 1
end

function BuffNode:RemoveBuff(buff_id, count)
	local buff = self.buff_list[buff_id]
	if not buff then
		assert(false, "Remove Buff : No Buff[%s]", tostring(buff_id))
		return
	end
	if not count then
		count = buff:GetCount()
	end
	buff:ChangeCount(-count)

	if buff:GetCount() <= 0 then
		local owner_id = self:GetParent():GetId()
		Event:FireEvent("BUFF.REMOVE", buff_id, owner_id)
		if buff.state then
			self:RemoveBuffState(buff.state)
		end
		if buff.OnRemove then						
			buff:OnRemove()
		end
		buff:Uninit()
		self.buff_list[buff_id] = nil
	end
end

function BuffNode:GetBuffCount(buff_id)
	local buff = self.buff_list[buff_id]
	if not buff then
		return 0
	end

	return buff:GetCount()
end

function BuffNode:GetBuffList()
	return self.buff_list
end

function BuffNode:AddBuffState(state)
	if not self.buff_state_pool[state] then
		self.buff_state_pool[state] = 0
	end
	self.buff_state_pool[state] = self.buff_state_pool[state] + 1
	return 1
end

function BuffNode:GetBuffState(state)
	return self.buff_state_pool[state]
end

function BuffNode:RemoveBuffState(state)
	if not self.buff_state_pool[state] then
		assert(false)
		return 0
	end
	self.buff_state_pool[state] = self.buff_state_pool[state] - 1
	if self.buff_state_pool[state] <= 0 then
		self.buff_state_pool[state] = nil
	end
	return 1
end