--=======================================================================
-- File Name    : module_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 16:16:44 2014
-- Description  :
-- Modify       :
--=======================================================================

if not ModuleMgr then
    ModuleMgr = {
        module_list = {},
        active_module = {},
        real_active_module = {}
    }
end

if not ModuleBase then
    ModuleBase = Class:New(LogicNode, "MODULE")
end

function ModuleBase:AddLogNode(log_level, view_level)
    self:AddComponent("log", "LOG", self:GetClassName(), log_level, view_level)
end

function ModuleMgr:NewModule(module_name)
    assert(not self.module_list[module_name])
    local class_module = Class:New(ModuleBase, module_name)
    self.module_list[module_name] = class_module
    return class_module
end

function ModuleMgr:GetModule(module_name)
    return self.module_list[module_name]
end

function ModuleMgr:ForEachActiveModule(func)
    for module, active_func in pairs(self.active_module) do
        func(module, active_func)
    end
end

function ModuleMgr:ForEachRealActiveModule(func)
    for module, real_active_func in pairs(self.real_active_module) do
        func(module, real_active_func)
    end
end

function ModuleMgr:RegisterUpdate(module_name, fun_name)
    local l_module = self.module_list[module_name]
    assert(l_module)

    local active_function = l_module[fun_name]
    assert(active_function)

    assert(not self.active_module[l_module])
    self.active_module[l_module] = active_function
end

function ModuleMgr:UnregisterUpdate(module_name)
    local l_module = self.module_list[module_name]
    assert(l_module)

    self.active_module[l_module] = nil
end

function ModuleMgr:RegisterRealUpdate(module_name, fun_name)
    local l_module = self.module_list[module_name]
    assert(l_module)

    local real_active_func = l_module[fun_name]
    assert(real_active_func)

    assert(not self.real_active_module[l_module])
    self.real_active_module[l_module] = real_active_func
end

function ModuleMgr:UnregisterRealUpdate(module_name)
    local l_module = self.module_list[module_name]
    assert(l_module)

    self.real_active_module[l_module] = nil
end


