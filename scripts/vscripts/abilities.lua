
vPlayerIlluminate = {}
vPlayerProjectiles = {}
vPlayerDummies = {}


function warpToPoint(keys)
  local target = keys.Target
  local caster = keys.caster
  
  if caster == nil then
		return
	end

  local point = nil
	if target == "POINT" and keys.target_points[1] then
		point = keys.target_points[1]
	else
    return
  end
  
  --print(tostring(point))
  -- prevent top left
  if point.x < -2700 and point.y > 2200 then
    point = Vector(-2180, 1368, 0)
  end
  
  -- prevent top right
  if point.x > 2700 and point.y > 2200 then
    point = Vector(2180, 1368, 0)
  end

  FindClearSpaceForUnit(caster, point, true)
end

function dangerIndicator(keys)
  local target = keys.Target
  local caster = keys.caster
  local duration = keys.duration or 1.5
  
  if caster == nil or keys.Radius == nil then
		return
	end
  
  local radius = tonumber(keys.Radius)
  
  local targetEntity = nil
    
  local attach = PATTACH_ABSORIGIN_FOLLOW
  
  local point = nil
	if target == "POINT" and keys.target_points[1] then
		point = keys.target_points[1]
    targetEntity = CreateUnitByName("npc_dota_danger_indicator", point, false, nil, nil, DOTA_TEAM_NOTEAM)
    targetEntity:AddNewModifier(unit, nil, "modifier_invulnerable", {})
    targetEntity:AddNewModifier(unit, nil, "modifier_phased", {})
	end
	if keys.target_entities[1] then
		targetEntity = keys.target_entities[1]
    attach = PATTACH_ABSORIGIN_FOLLOW
	end
	if target == "CASTER" then
		targetEntity = caster
    attach = PATTACH_ABSORIGIN_FOLLOW
	end
  
  local team = caster:GetTeam()
  --print ('team: ' .. team)
  
  ReflexGameMode:LoopOverPlayers(function(ply, plyID)
    local particle = ParticleManager:CreateParticleForPlayer("generic_aoe_shockwave_1", attach, targetEntity, PlayerResource:GetPlayer(plyID))--cmdPlayer:GetAssignedHero())
    ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) -- something
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0)) -- radius
    ParticleManager:SetParticleControl(particle, 2, Vector(6,0,1)) -- something
    if ply.nTeam == team then
      ParticleManager:SetParticleControl(particle, 3, Vector(0,200,0)) -- color
    else
      ParticleManager:SetParticleControl(particle, 3, Vector(200,0,0)) -- color
    end
    ParticleManager:SetParticleControl(particle, 4, Vector(0,0,0)) -- something
  end)
  -- Test Lua-particle generation

  -- Bots
  for k,v in pairs(ReflexGameMode.vBots) do
    local particle = ParticleManager:CreateParticleForPlayer("generic_aoe_shockwave_1", attach, targetEntity, ReflexGameMode.vUserIds[k])--cmdPlayer:GetAssignedHero())
    ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) -- something
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0)) -- radius
    ParticleManager:SetParticleControl(particle, 2, Vector(6,0,1)) -- something
    if team == DOTA_TEAM_GOODGUYS then
      ParticleManager:SetParticleControl(particle, 3, Vector(0,200,0)) -- color
    else
      ParticleManager:SetParticleControl(particle, 3, Vector(200,0,0)) -- color
    end
    ParticleManager:SetParticleControl(particle, 4, Vector(0,0,0)) -- something
  end
  
  -- Broadcasters
  for k,v in pairs(ReflexGameMode.vBroadcasters) do
    local particle = ParticleManager:CreateParticleForPlayer("generic_aoe_shockwave_1", attach, targetEntity, ReflexGameMode.vUserIds[k])--cmdPlayer:GetAssignedHero())
    ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) -- something
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0)) -- radius
    ParticleManager:SetParticleControl(particle, 2, Vector(6,0,1)) -- something
    if team == DOTA_TEAM_GOODGUYS then
      ParticleManager:SetParticleControl(particle, 3, Vector(0,200,0)) -- color
    else
      ParticleManager:SetParticleControl(particle, 3, Vector(200,0,0)) -- color
    end
    ParticleManager:SetParticleControl(particle, 4, Vector(0,0,0)) -- something
  end
  
  if target == "POINT" then
    ReflexGameMode:CreateTimer(DoUniqueString("danger"), {
      endTime = GameRules:GetGameTime() + 0.5,
      useGameTime = true,
      callback = function(reflex, args)
        targetEntity:Destroy()
      end
    })
  end
end

function itemSpellStart (keys)
	--PrintTable(keys)
  
	local target = keys.Target
	local caster = keys.caster
	local abilityName = keys.Ability
	local itemName = keys.ability:GetAbilityName()
	local chargeModifier = keys.ChargeModifier
	
	local chargeType = keys.ChargeType or "UNLINKED"
	
	if caster == nil or itemName == nil then
		return
	end
	
	--PrintTable(caster)
	--PrintTable(getmetatable(caster))
  --print(caster:GetMana())
	
	local item = getItemByName(caster, itemName )
	--print ('Item')
	--PrintTable(item)
	--PrintTable(getmetatable(item))
	--print(item:GetLevel())
	if item == nil then
    item = caster:FindAbilityByName(itemName)
    if item == nil then 
      return
    end
	end
	
		
	if string.find(itemName, "item_reflex_dash") ~= nil then
		--print (tostring(caster:HasModifier("modifier_hamstring")))
		if caster:HasModifier("modifier_hamstring") or caster:HasModifier("modifier_hamstring_2") or caster:HasModifier("modifier_hamstring_3") or caster:HasModifier("modifier_hamstring_4") then
			local charges = item:GetCurrentCharges()
			local maxCharges = item:GetInitialCharges()
	
      if charges + 1 <= maxCharges then
        item:SetCurrentCharges(charges + 1)
      end
      
      EmitSoundOnClient("General.CantAttack" , caster:GetPlayerOwner())
			
      local mana = caster:GetMana() + 80
      if mana > caster:GetMaxMana() then
        caster:SetMana(caster:GetMaxMana())
      else
        caster:SetMana(mana)
      end
			return
		end
	end
	
	local abilityLevel = keys.AbilityLevel or item:GetLevel()
	
	local point = nil
	if keys.target_points[1] then
		point = keys.target_points[1]
	end
	--if point == nil then
	--	return	
	--end
	
	local targetEntity = nil
	if keys.target_entities[1] then
		targetEntity = keys.target_entities[1]
	end
	if target == "CASTER" then
		targetEntity = caster
	end
	
	if chargeModifier ~= nil then
		--print (chargeModifier .. ": " .. tostring(caster:HasModifier(chargeModifier)))
		if chargeType == "UNLINKED" then
		
		elseif chargeType == "HALF" then
			--print(' HALF ')
			if caster:HasModifier(chargeModifier) == false then
				--print (" doesn't have mod " )
				callModApplier(caster, chargeModifier)
			end
		elseif chargeType == "FULL" then
			caster:RemoveModifierByName(chargeModifier)
			callModApplier(caster, chargeModifier)
		elseif chargeType == "ALL" then
			--print(' ALL ')
			if caster:HasModifier(chargeModifier) == false then
				--print (" doesn't have mod " )
				callModApplier(caster, chargeModifier)
			end
		end
	end
	
	if abilityName ~= nil then
    if string.find(abilityName, "reflex_illuminate") ~= nil then
      local plyID = caster:GetPlayerOwner():GetPlayerID()
      if (plyID ~= nil) then
        if vPlayerIlluminate[plyID] == nil then
          vPlayerIlluminate[plyID] = 1
        else
          vPlayerIlluminate[plyID] = (vPlayerIlluminate[plyID] % 4) + 1
        end
        
        abilityName = "reflex_illuminate_" .. vPlayerIlluminate[plyID]
      end
    end
		local ability = caster:FindAbilityByName( abilityName )
		if ability == nil then
			caster:AddAbility(abilityName)
			ability = caster:FindAbilityByName( abilityName )
		end
		--print(ability:GetLevel())
		
		ability:SetLevel( abilityLevel )
		
		if not ability:IsFullyCastable() then
			local charges = item:GetCurrentCharges()
			item:SetCurrentCharges(charges + 1)
			return
		end
		
		-- print ("[REFLEX] " ..target .. " -- " ..abilityName  .. " -- " .. tostring(point))
		-- PrintTable(ability)
		if target == nil then
			caster:CastAbilityNoTarget (ability, -1 )
		elseif target == "POINT" then
			caster:CastAbilityOnPosition ( point, ability, 1 )
		else
			caster:CastAbilityOnTarget (targetEntity, ability, -1 )
		end
	end
	
	--print ( '[REFLEX] removing dash ability' )
	--caster:RemoveAbility('reflex_dash')
	
	--local charges = item:GetCurrentCharges()
	--if charges ~= 0 then
	--	item:EndCooldown()
	--end
end

--[[
	"RunScript"
			{
				"ScriptFile"			"scripts/vscripts/abilities.lua"
				"Function"				"itemChargeThink"
				"Item"					"item_reflex_dash"
				"ChargeModifier"		"modifier_item_reflex_dash" // Optional for UNLINKED/ALL
				"ChargeType"			"UNLINKED" 	// Optional: "UNLINKED", "HALF", "FULL", "ALL"
			}
]]
function itemChargeThink (keys)
	--print ('[REFLEX] itemChargeThink called')
	--PrintTable(keys)
	local chargeType = keys.ChargeType or "UNLINKED"
	--print ('[REFLEX] ' .. (keys.ChargeModifier or "nil") .. " -- " .. keys.Item .. " -- " .. chargeType)

	local itemName = keys.Item
	local caster = keys.caster
	local chargeModifier = keys.ChargeModifier
	
	if caster == nil or itemName == nil then
		return
	end

	local item = getItemByName(caster, itemName )
	if item == nil then
		return
	end	
	
	local charges = item:GetCurrentCharges()
	local maxCharges = item:GetInitialCharges()
	
	if charges + 1 <= maxCharges then
		item:SetCurrentCharges(charges + 1)
	end
	
	if chargeType == "UNLINKED" then
		
	elseif chargeType == "HALF" or chargeType == "FULL" then
		if charges + 1 ~= maxCharges then
			callModApplier(caster, chargeModifier)
		end
	elseif chargeType == "ALL" then
		item:SetCurrentCharges(maxCharges)
	end
	
	--item:EndCooldown()
end

channelTable = {}
channelTimeTable = {}

function itemChannelStart( keys )
	local now = GameRules:GetGameTime()
	-- print ('[REFLEX] itemChannelStart called: ' .. now)
	-- PrintTable(keys)
	
	local caster = keys.caster
	local itemName = keys.ability:GetAbilityName()
	
	if caster == nil or itemName == nil then
		return
	end
	
	local ID = tostring(caster:GetPlayerID()) .. itemName
	channelTable[ID] = now
end

function itemChannelEnd( keys )
	local now = GameRules:GetGameTime()
	--print ('[REFLEX] itemChannelEnd called: ' .. now)
	--PrintTable(keys)
	
	local caster = keys.caster
	local itemName = keys.ability:GetAbilityName()
	
	if caster == nil or itemName == nil then
		return
	end
	
	local item = keys.ability--getItemByName(caster, itemName )
	--if item == nil then
--		return
--	end
	local abilityLevel = keys.AbilityLevel or item:GetLevel()
	
	local point = nil
	if keys.target_points[1] then
		point = keys.target_points[1]
	end
	
	local targetEntity = nil
	if keys.target_entities[1] then
		targetEntity = keys.target_entities[1]
	end
	if target == "CASTER" then
		targetEntity = caster
	end
	
	local ID = tostring(caster:GetPlayerID()) .. itemName
	
	local start = channelTable[ID]
	channelTable[ID] = nil
	
	if start == nil then
		start = now + 0.3
	end
	
	local channelTime = now - start
  channelTimeTable[ID] = channelTime
  
	if string.find(itemName, "item_reflex_meteor_cannon") ~= nil then
		itemMeteorCannon(channelTime, point, keys.ability, caster)
	end
end

function projectileHit(keys)
  --PrintTable(keys)
  local caster = keys.caster
  local ability = keys.ability
  local projectiles = vPlayerProjectiles[caster:GetPlayerID()]
  local dummies = vPlayerDummies[caster:GetPlayerID()]
  local projID = projectiles[ability:GetAbilityName()]
  local dummy = dummies[ability:GetAbilityName()]
  
  ReflexGameMode:RemoveTimer(caster:GetPlayerID() .. ability:GetAbilityName() .. "grip_dummy")
  
  local targetEntity = keys.target_entities[1]
  if caster == nil or targetEntity == nil or targetEntity == caster then
    return
  end
  
  --local dummy = CreateUnitByName("npc_reflex_dummy_grip", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
  --dummy:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
  --dummy:AddNewModifier(dummy, nil, "modifier_phased", {})
  
  local grip = dummy:FindAbilityByName("reflex_grip")
  grip:SetLevel(ability:GetLevel())
  local burst = dummy:FindAbilityByName("reflex_magnetic_burst")
  burst:SetLevel(ability:GetLevel())
  
  local diff = targetEntity:GetAbsOrigin() - dummy:GetAbsOrigin()
  diff.z = 0
  dummy:SetAbsOrigin(caster:GetAbsOrigin())
  dummy:SetForwardVector(diff:Normalized())
  
  local point = targetEntity:GetAbsOrigin()
  dummy:CastAbilityOnTarget(targetEntity, grip, 0 )
  dummy:CastAbilityOnPosition(point, burst, 0)
  
  local particle = ParticleManager:CreateParticle("nian_roar_prj_gasexplode_shockwave", PATTACH_POINT_FOLLOW, targetEntity)
  ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0))
  ParticleManager:SetParticleControl(particle, 1, Vector(100,5,1)) -- radius, thickness, speed
  ParticleManager:SetParticleControl(particle, 3, targetEntity:GetAbsOrigin()) -- position
  
  ReflexGameMode:CreateTimer(DoUniqueString("grip"), {
    endTime = GameRules:GetGameTime() + 5,
    useGameTime = true,
    callback = function(reflex, args)
      --dummy:CastAbilityOnTarget(caster, grip, 0 )
      dummy:Destroy()
    end
  })
  
  ProjectileManager:DestroyLinearProjectile(projID)
  
end

--[["Target"				"POINT"
        "EffectName"			"nian_roar_projectile_no_explode"
				"MoveSpeed"				"%speed"
				"StartPosition"			"attach_attack1"
        "FixedDistance"   "%distance"
				"StartRadius"			"%radius"
				"EndRadius"				"%radius"
				"TargetTeams"			"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
				"TargetTypes"			"DOTA_UNIT_TARGET_HERO"
				"TargetFlags"			"DOTA_UNIT_TARGET_FLAG_NONE"
        "ExcludeFlags"    "DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED"
				"HasFrontalCone"		"0"
				"ProvidesVision"		"0"
				"VisionRadius"			"0"]]
                

function makeProjectile(keys)
  --PrintTable(keys)
  local caster = keys.caster
  local ability = keys.ability
  local origin = caster:GetOrigin()
  origin.z = origin.z + 60
  local projectiles = vPlayerProjectiles[caster:GetPlayerID()]
  if projectiles == nil then
    projectiles = {}
    vPlayerProjectiles[caster:GetPlayerID()] = projectiles
  end
  
  local dummies = vPlayerDummies[caster:GetPlayerID()]
  if dummies == nil then
    dummies = {}
    vPlayerDummies[caster:GetPlayerID()] = dummies
  end 
  
  local info = {
		EffectName = keys.EffectName,
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = tonumber(keys.FixedDistance),
		fStartRadius = tonumber(keys.StartRadius),
		fEndRadius = tonumber(keys.EndRadius),
		Source = caster,
		bHasFrontalCone = false,
    iMoveSpeed = tonumber(keys.MoveSpeed),
    bReplaceExisting = true,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		--iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		--iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		--iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,
		--fMaxSpeed = 5200,
		fExpireTime = GameRules:GetGameTime() + 8.0,
	}
  
  --print ('0-------------0')
  --PrintTable(info)
  --print ('0--------------0')
  local speed = keys.MoveSpeed
  
  local point = keys.target_points[1]
  point.z = 0
	local pos = caster:GetAbsOrigin()
  pos.z = 0
	--print ('[REFLEX] ' .. tostring(pos))
	local diff = point - pos
  
  info.vVelocity = diff:Normalized() * speed
  
  local dummy = CreateUnitByName("npc_reflex_dummy_grip", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
  dummy:AddNewModifier(dummy, nil, "modifier_phased", {})
  
  ReflexGameMode:CreateTimer(tostring(caster:GetPlayerID()) .. ability:GetAbilityName() .. "grip_dummy", {
    endTime = GameRules:GetGameTime() + 10,
    useGameTime = true,
    callback = function(reflex, args)
      --dummy:CastAbilityOnTarget(caster, grip, 0 )
      dummy:Destroy()
    end
  })
  
  dummies[ability:GetAbilityName()] = dummy
  projectiles[ability:GetAbilityName()] = ProjectileManager:CreateLinearProjectile( info )
end

function itemMeteorCannon( channelTime, point, item , caster)
	--print ('[REFLEX] itemMeteorCannon called: ' .. channelTime .. " -- point: " .. tostring(point) .. " -- item: " ..item:GetAbilityName())
	
	local info = {
		EffectName = "invoker_chaos_meteor",
		Ability = item,
		vSpawnOrigin = caster:GetOrigin(),
		fDistance = 5000,
		fStartRadius = 125,
		fEndRadius = 125,
		Source = caster,
		bHasFrontalCone = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,
		--fMaxSpeed = 5200,
		fExpireTime = GameRules:GetGameTime() + 8.0,
	}

	local speed = tonumber(item:GetSpecialValueFor("speed")) + (item:GetLevel() - 1) * 100 --1000
  --print ('[REFLEX] Meteor Speed: ' .. tostring(speed))
	--print ('[REFLEX] ' .. tostring(point))
	--PrintTable(point)
	--PrintTable(getmetatable(point))	
	-- caster:GetAngles() .y is angle with 270 being straight down i think
	--local angles = caster:GetAngles()
	--print ('[REFLEX] ' .. tostring(angles))
	--PrintTable(angles)
	--PrintTable(getmetatable(angles))
	
	-- x pos is left
	-- y pos is down
	
	point.z = 0
	local pos = caster:GetAbsOrigin()
  pos.z = 0
	--print ('[REFLEX] ' .. tostring(pos))
	local diff = point - pos
	--print ('[REFLEX] ' .. tostring(diff))
	
	--point = point:Normalized()
	info.vVelocity = diff:Normalized() * speed * channelTime
	--info.vVelocity = point:Normalized() * speed * channelTime--( RotatePosition( Vec3( 0, 0, 0 ), angle, Vec3( 1, 0, 0 ) ) ) * speed
	--info.vAcceleration = info.vVelocity * -0.15

	ProjectileManager:CreateLinearProjectile( info )
end

function itemApplyChannelDamage(keys)
  --print('[REFLEX] itemApplyChannelDamage')
  --PrintTable(keys)
  
  local now = GameRules:GetGameTime()
	
	local caster = keys.caster
	local itemName = keys.ability:GetAbilityName()
	
	if caster == nil or itemName == nil or keys.target == nil then
		return
	end
	
	local item = keys.ability
  
  local ID = tostring(caster:GetPlayerID()) .. itemName
	
	local channelTime = channelTimeTable[ID]
  if channelTime == nil then
    channelTime = 0.3
  end
  --print(channelTime)
  
  local damage = item:GetSpecialValueFor("damage") + (item:GetLevel() - 1) * 40
  local minDamage = damage / 2
  --print('[REFLEX] meteoer damage: ' .. damage)
  local mult = channelTime / 1.5
  if mult > 1 then
    mult = 1
  end
  
  damage = mult * (minDamage) + minDamage
  print('[REFLEX] meteor damage: ' .. damage)
  
  dealDamage(caster, keys.target, damage)
  --keys.target:AddNewModifier(caster, nil, "modifier_kunkka_ghost_ship_damage_delay", {damage = damage, duration = 1})--, duration = 0})
  --keys.target:AddNewModifier(caster, nil, "modifier_item_orb_of_venom_slow", {damage = damage, slow = 0, duration = 1})--, duration = 0})
  --keys.target:AddNewModifier(caster, nil, "modifier_invoker_chaos_meteor_burn", {burn_dps = damage, freeze_damage = damage, damage = damage, hero_slow_duration = 2, duration = 1})--, duration = 0})
  --keys.target:AddNewModifier(caster, nil, "modifier_invoker_chaos_meteor_burn", {burn_dps = damage, freeze_damage = damage, damage = damage, hero_slow_duration = 2, duration = 1})--, duration = 0})
  --keys.target:AddNewModifier(caster, nil, "modifier_roshan_halloween_apocalypse", {damage = damage, duration = 0})
  --keys.target:AddNewModifier(caster, nil, "modifier_invoker_tornado", {land_damage = damage, duration = 0} )
end

function dealDamage(source, target, damage)
  local unit = nil
  if source ~= nil then
    unit = CreateUnitByName("npc_dota_danger_indicator", target:GetAbsOrigin(), false, source, source, source:GetTeamNumber())
  else
    unit = CreateUnitByName("npc_dota_danger_indicator", target:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NOTEAM)
  end
  unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
  unit:AddNewModifier(unit, nil, "modifier_phased", {})
  
  local abilityName = "modifier_damage_applier"
  unit:AddAbility(abilityName)
  ability = unit:FindAbilityByName( abilityName )
  
  local abilityName2 = "modifier_damage_applier2"
  unit:AddAbility(abilityName2)
  ability2 = unit:FindAbilityByName( abilityName2 )
  
  local maxTimesTwo = math.floor(damage / 400)
  local twoLevel = math.floor((damage % 400) / 20)
  local level = math.floor(damage % 20)
  
  local diff = nil
  
  local hp = target:GetHealth()
  
  local i = 0
  while i < maxTimesTwo do
    ability2:SetLevel( 20 )
    diff = target:GetAbsOrigin() - unit:GetAbsOrigin()
    diff.z = 0
    unit:SetForwardVector(diff:Normalized())
    unit:CastAbilityOnTarget(target, ability2, 0 )
    i = i + 1
  end
  
  ability2:SetLevel( twoLevel )
  if twoLevel > 0 then
    diff = target:GetAbsOrigin() - unit:GetAbsOrigin()
    diff.z = 0
    unit:SetForwardVector(diff:Normalized())
    unit:CastAbilityOnTarget(target, ability2, 0)
  end

  ability:SetLevel( level)
  if level > 0 then
    diff = target:GetAbsOrigin() - unit:GetAbsOrigin()
    diff.z = 0
    unit:SetForwardVector(diff:Normalized())
    unit:CastAbilityOnTarget(target, ability, 0 )
  end
  
  ReflexGameMode:CreateTimer(DoUniqueString("damage"), {
    endTime = GameRules:GetGameTime() + 0.2,
    useGameTime = true,
    callback = function(reflex, args)
      if target:GetHealth() == hp and hp ~= 0 then
        print ("[REFLEX] WARNING: dealDamage did no damage: " .. hp)
      end
      unit:Destroy()
    end
  })
end

function getItemByName( hero, name )
	if not hero:HasItemInInventory ( name ) then
		return nil
	end
	
	--print ( '[REFLEX] find item in inventory' )
	-- Find item by slot
	for i=0,11 do
		--print ( '\t[REFLEX] finding item ' .. i)
		local item = hero:GetItemInSlot( i )
		--print ( '\t[REFLEX] item: ' .. tostring(item) )
		if item ~= nil then
			--print ( '\t[REFLEX] getting ability name' .. i)
			local lname = item:GetAbilityName()
			--print ( string.format ('[REFLEX] item slot %d: %s', i, lname) )
			if lname == name then
				return item
			end
		end
	end
	
	return nil
end
