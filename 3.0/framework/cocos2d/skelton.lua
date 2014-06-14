--=======================================================================
-- File Name    : skelton.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/22 13:57:33
-- Description  : 对 cocostudio skelton 进行的封装
-- Modify       : 
--=======================================================================

if not Skelton then
	Skelton = Class:New(nil, "SKELTON")
	Skelton.DEFAULT_NAME = {
		skill = "attack",
		normal = "loading",
		hit    = "smitten",
		death  = "death",
		run    = "run",
	}

end

function NewSkelton(skelton_name, orgin_direction, param)
	if not skelton_name then
		assert(false, "skelton_name is nil")
		return
	end
	local skelton = Class:New(Skelton)
	if skelton:Init(skelton_name, orgin_direction, param) ~= 1 then
		return 
	end
	return skelton
end

function Skelton:_Uninit()
	self.orgin_direction        = nil
	self.armature               = nil
	self.animation_replace_name = nil	
	self.animation_func         = nil
	self.frame_func             = nil
	self.current_animation      = nil
	self.scale 					= nil
end

function Skelton:_Init(skelton_name, orgin_direction, param)
	local armature = ccs.Armature:create(skelton_name)
	if not armature then
		return 0
	end
	self.skelton_name = skelton_name
	self.scale = 1
	if param and param.scale then
		self.scale = param.scale
	end
	self.orgin_direction = orgin_direction
	self.armature = armature
	self.animation_replace_name = {}

	self.animation_func = {}
	local function animationEvent(armature, movement_type, movement_id)
		if not self.animation_func[movement_id] then
			return
		end

		local func = self.animation_func[movement_id][movement_type]
		if not func then
			return
		end
		func(self, armature)
    end
	armature:getAnimation():setMovementEventCallFunc(animationEvent)

	self.frame_func = {}
	local function frameEvent(bone, event_name, origin_frame_index,current_frame_index)
		local func = self.frame_func[event_name]
		if not func then
			return
		end

		func(self, bone, origin_frame_index, current_frame_index)
	end
	armature:getAnimation():setFrameEventCallFunc(frameEvent)

	if param then
		if param.speed_scale then
			armature:getAnimation():setSpeedScale(param.speed_scale)
		end

		if param.replace_animation_name then
			self.animation_replace_name = param.replace_animation_name
		end

		if param.scale then
			self.scale = param.scale
		end
	end

	self:PlayAnimation("normal")
	return 1
end

function Skelton:GetArmature()
	return self.armature
end

function Skelton:SetAnimationFunc(movement_type, movement_id, func)
	if not self.animation_func[movement_id] then
		self.animation_func[movement_id] = {}
	end
	self.animation_func[movement_id][movement_type] = func
end

function Skelton:SetFrameFunc(event_name, func)
	self.frame_func[event_name] = func
end

function Skelton:GetAnimationResourceName(animation_name)
	local resource_name = self.animation_replace_name[animation_name]
	if resource_name then
		return resource_name
	end

	return self.DEFAULT_NAME[animation_name]
end

function Skelton:PlayAnimation(animation_name, duration_frame, is_loop)
	local resource_name = self:GetAnimationResourceName(animation_name)
	if not resource_name then
		cclog("No Animation[%s]", animation_name)
		return
	end
	self.armature:getAnimation():play(resource_name, duration_frame or -1, is_loop or -1)
	self.current_animation = animation_name
end

function Skelton:GetCurrentAnimation()
	return self.current_animation
end

function Skelton:SetDirection(direction)
	if direction == self.orgin_direction then
		self.armature:setScaleX(self.scale)
	else
		self.armature:setScaleX(-self.scale)
	end
	self.armature:setScaleY(self.scale)
end

function Skelton:AddParticles(bone_name, particles_name, scale)
	local bone = self.armature:getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end

	local particles_bone_name = bone_name.."_"..particles_name

	if not self.bone_particles then
		self.bone_particles = {}
	end
	if self.bone_particles[particles_bone_name] then
		assert(false, "Particles[%s] already Exists!!!", self.bone_particles[particles_bone_name])
		return
	end

	local particles = Particles:CreateParticles(particles_name)		
	local particles_bone = ccs.Bone:create(particles_bone_name)
    particles_bone:addDisplay(particles, 0)
    particles_bone:changeDisplayWithIndex(0, true)
    particles_bone:setIgnoreMovementBoneData(true)
    particles_bone:setLocalZOrder(100)
    if scale then
    	particles_bone:setScale(scale)
    end

    self.armature:addBone(particles_bone, bone_name)
    self.bone_particles[particles_bone_name] = particles_bone

    return 1
end

function Skelton:RemoveParticles(bone_name, particles_name)
	local bone = self.armature:getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end
	if not self.bone_particles then
		assert(false, "no bone particles")
		return
	end
	local particles_bone_name = bone_name.."_"..particles_name

	if not self.bone_particles[particles_bone_name] then
		assert(false, "no particles bone[%s]", particles_bone_name)
		return
	end


	local particles_bone = self.bone_particles[particles_bone_name]
	self.armature:removeBone(particles_bone, true)
	self.bone_particles[particles_bone_name] = nil
end