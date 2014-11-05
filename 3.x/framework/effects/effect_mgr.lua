--=======================================================================
-- File Name    : EffectMgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/18 16:49:38
-- Description  : Manage Effects(Particles and SpriteSheets) in Game
-- Modify       : 
--=======================================================================
if not EffectMgr then
	EffectMgr = {}
end

function EffectMgr:Uninit()
	self.effect_list = nil
end

function EffectMgr:Init()
	self.effect_list = {}
	return 1
end

function EffectMgr:LoadEffect(effect_name, effect_type)
	if self.effect_list[effect_name] then
		assert(false)
		return
	end
	self.effect_list[effect_name] = effect_type
end

function EffectMgr:GetEffectType(effect_name)
	return self.effect_list[effect_name]
end


local GenearteFuncion = {
	["particles"] = function(particles_name)
		return Particles:CreateParticles(particles_name)
	end,
	["sprite_sheets"] = function(animation_name, loop_count)
		local effect = cc.Sprite:createWithSpriteFrameName(string.format("%s%d.png", animation_name, 1))
		SpriteSheets:RunAnimation(effect, animation_name, nil, loop_count)
		return effect
	end,
	["skelton"] = function(skelton_name, animation_name)
		local skelton = NewSkelton(skelton_name, nil, {})
		if animation_name then
			skelton:PlayAnimation(animation_name)
		end
		return skelton:GetSprite(), skelton
	end,
}

function EffectMgr:GenerateEffect(effect_name, ...)
	local effect_type = self:GetEffectType(effect_name)
	if not effect_type then
		assert(false, "No Effect[%s]", effect_name)
		return
	end
	return self:GenerateEffectByType(effect_name, effect_type, ...)
end

function EffectMgr:GenerateEffectByType(effect_name, effect_type, ...)
	local func = GenearteFuncion[effect_type]
	if not func then
		assert(false, "No Effect Type[%s]", effect_type)
		return
	end
	return func(effect_name, ...)
end

