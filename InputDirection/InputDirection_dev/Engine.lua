Engine = {

}

function Engine.getEffectiveAngle(angle)
	return angle - (angle % 16)
end

function Engine.getNearestAngle(angle)
	if (angle % 16 < 8) then
		return angle - (angle % 16)
	end
	return angle - (angle % 16) + 16
end

function Engine.getDyaw(angle)
	if Settings.Layout.Button.strain_button.left == true and Settings.Layout.Button.strain_button.right == false then
		return Memory.Mario.FacingYaw + angle
	elseif Settings.Layout.Button.strain_button.left == false and Settings.Layout.Button.strain_button.right == true then
		return Memory.Mario.FacingYaw - angle
	elseif Settings.Layout.Button.strain_button.left == true and Settings.Layout.Button.strain_button.right == true then
		return Memory.Mario.FacingYaw + angle * (math.pow(-1, Memory.Mario.GlobalTimer % 2))
	else
		return angle
	end
end

function Engine.getDyawsign()
	if Settings.Layout.Button.strain_button.left == true and Settings.Layout.Button.strain_button.right == false then
		return 1
	elseif Settings.Layout.Button.strain_button.left == false and Settings.Layout.Button.strain_button.right == true then
		return -1
	elseif Settings.Layout.Button.strain_button.left == true and Settings.Layout.Button.strain_button.right == true then
		return math.pow(-1, Memory.Mario.GlobalTimer)
	else
		return 0
	end
end

function Engine.getgoal(targetspd) -- getting angle for target speed
	if (targetspd >= 0) then
		return math.floor(math.acos((targetspd + 0.35 -Memory.Mario.FSpeed) / 1.5) * 32768 / math.pi)
	elseif (targetspd < 0) then
		return math.floor(math.acos((targetspd - 0.35 -Memory.Mario.FSpeed) / 1.5) * 32768 / math.pi)
	end
end

local ENABLE_REVERSE_ANGLE_ON_WALLKICK = 1

function Engine.wallKickReverse()
	return (Memory.Mario.Action == 0x000008A7 or Memory.Mario.Action == 0x010208B6 or Memory.Mario.Action == 0x010208B0 or Memory.Mario.Action == 0x08100340 or Memory.Mario.Action == 0x00100343) and ENABLE_REVERSE_ANGLE_ON_WALLKICK
end

function Engine.inputsForAngle()
	local goal              = Settings.goalAngle
	local offset            = 0
	local speedsign         = 0
	local targetspeed       = 0
	local actionflag        = 0
	local enableTargetSpeed = 0
	
	-- Note that the only case we don't check is regular "Match angle" which just uses Settings.goalAngle and does not do wallkick reversal.
	if (Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW) then
		goal = Memory.Mario.FacingYaw
		if (Engine.wallKickReverse()) then goal = goal + 32768 end
	elseif (Settings.Layout.Button.selectedItem == Settings.Layout.Button.REVERSE_ANGLE) then
		goal = Memory.Mario.FacingYaw + 32768
		if (Engine.wallKickReverse()) then goal = goal + 32768 end
	elseif (Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_ANGLE and Settings.Layout.Button.strain_button.dyaw == true) then
		goal = Engine.getDyaw(goal)
		if (Engine.wallKickReverse()) then goal = goal + 32768 end
	end
	-- Set up target speed
	if (Settings.Layout.Button.strain_button.target_strain == true) then
		enableTargetSpeed = 1
	end
	if (Settings.Layout.Button.strain_button.always == true) then
		offset = 3
	end
	-- Note that we only match target speed (= .99 trick) when in MATCH_YAW or REVERSE_ANGLE mode.
	if (enableTargetSpeed == 1) then
		if Memory.Mario.Action == 0x04000440 or Memory.Mario.Action == 0x0400044A or Memory.Mario.Action == 0x08000239 or Memory.Mario.Action == 0x0C000232 or Memory.Mario.Action == 0x04000442 or Memory.Mario.Action == 0x04000443 or Memory.Mario.Action == 0x010208B7 or Memory.Mario.Action == 0x04000445 or Memory.Mario.Action == 0x00840454 or Memory.Mario.Action == 0x00840452 or (Memory.Mario.Action > 0x0400046F and Memory.Mario.Action < 0x04000474) or (Memory.Mario.Action > 0x00000473 and Memory.Mario.Action < 0x00000478) then
			actionflag = 1
		else
			actionflag = 0
		end
		if (Memory.Mario.FSpeed > 937 / 30 and Memory.Mario.FSpeed < 31.9 + offset * 3000000 and (Memory.Mario.Action == 0x04808459 or Memory.Mario.Action == 0x00000479) and Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW) then
			targetspeed = 48 - Memory.Mario.FSpeed / 2
			if (Memory.Mario.FSpeed > 32) then targetspeed = Memory.Mario.FSpeed end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.Mario.FSpeed > -337 / 30 - offset / 1.5 and Memory.Mario.FSpeed < -9.9 and Memory.Mario.Action == 0x00000479 and Settings.Layout.Button.selectedItem == Settings.Layout.Button.REVERSE_ANGLE) then
			targetspeed = -16 - Memory.Mario.FSpeed / 2
			if (Memory.Mario.FSpeed < -11.9) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.Mario.FSpeed > 46.85 and Memory.Mario.FSpeed < 47.85 + offset and Memory.Mario.Action == 0x03000888 and Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW) then
			targetspeed = 48
			if (Memory.Mario.FSpeed > 49.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.Mario.FSpeed > 30.85 and Memory.Mario.FSpeed < 31.85 + offset and actionflag == 0 and Memory.Mario.Action ~= 0x03000888 and Memory.Mario.Action ~= 0x00000479 and Memory.Mario.Action ~= 0x04808459 and Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW) then
			targetspeed = 32
			if (Memory.Mario.FSpeed > 33.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			if (Memory.Mario.Action == 0x000008A7 or Memory.Mario.Action == 0x010208B6 or Memory.Mario.Action == 0x010208B0 or Memory.Mario.Action == 0x08100340 or Memory.Mario.Action == 0x00100343) then
				goal = goal + 32768
			end
		elseif ( Memory.Mario.FSpeed > -16.85 - offset and Memory.Mario.FSpeed < -14.85 and Memory.Mario.Action ~= 0x00000479 and actionflag == 0 and Settings.Layout.Button.selectedItem == Settings.Layout.Button.REVERSE_ANGLE) then
			targetspeed = -16
			if ( Memory.Mario.FSpeed < -17.85) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.Mario.FSpeed > -21.0625 - offset / 0.8 and Memory.Mario.FSpeed < -18.5625 and Memory.Mario.Action ~= 0x00000479 and (actionflag == 1 or Memory.Mario.Action == 0x04808459) and Settings.Layout.Button.selectedItem == Settings.Layout.Button.REVERSE_ANGLE ) then
			targetspeed = -16 + Memory.Mario.FSpeed / 5
			if (Memory.Mario.FSpeed < -22.3125) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.Mario.FSpeed > 38.5625 and Memory.Mario.FSpeed < 39.8125 + offset / 0.9 and Memory.Mario.Action ~= 0x00000479 and Memory.Mario.Action ~= 0x03000888 and actionflag == 1 and Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW) then
			targetspeed = 32 + Memory.Mario.FSpeed / 5
			if (Memory.Mario.FSpeed > 42.3125) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		else
			speedsign = 0
		end
		-- TODO: This seems to be here to avoid overshooting the .99 trick. Maybe we can get away with 16.
		goal = goal + 32 * speedsign * Engine.getDyawsign()
	end
	
	goal = Engine.getNearestAngle(goal)
	goal = goal % 65536 - 65536
	while (Engine.getEffectiveAngle(Memory.Camera.Angle) > goal) do
		goal = goal + 65536
	end
	
	--print(string.format("Prep input for frame %d curSpd %f goal %d", emu.samplecount() + 1, Memory.Mario.FSpeed, goal % 65536))
	
	-- Set up binary search
	local minang = 1
	local maxang = Angles.COUNT
	local midang = math.floor((minang + maxang) / 2)
	-- Binary search
	while (minang <= maxang) do
		if (Engine.getEffectiveAngle(Angles.ANGLE[midang].angle + Memory.Camera.Angle) < goal) then
			minang = midang + 1
		elseif (Engine.getEffectiveAngle(Angles.ANGLE[midang].angle + Memory.Camera.Angle) == goal) then
			minang = midang
			maxang = midang - 1
		else
			maxang = midang - 1
		end
		midang = math.floor((minang + maxang) / 2)
	end
	-- If binary search fails, optimal angle is between Angles.Count and 1. Checks which one is closer.
	if minang > Angles.COUNT then
		minang = 1
		if math.abs(Engine.getEffectiveAngle(Angles.ANGLE[1].angle + Memory.Camera.Angle) - (goal - 65536)) > math.abs(Engine.getEffectiveAngle(Angles.ANGLE[Angles.COUNT].angle + Memory.Camera.Angle) - goal) then
			minang = Angles.COUNT
		end
	end
	--[[if ((math.cos((Engine.getEffectiveAngle(Angles.ANGLE[minang].angle - Memory.Mario.FacingYaw))*math.pi/32768)*1.5 + Memory.Mario.FSpeed - 0.35) > targetspeed and speedsign == 1) then
		minang = minang + 1
	elseif ((math.cos((Engine.getEffectiveAngle(Angles.ANGLE[minang].angle - Memory.Mario.FacingYaw))*math.pi/32768)*1.5 + Memory.Mario.FSpeed + 0.35) < -16 and speedsign == -1 ) then
			minang = minang - 1
	end--]]
	--[[if (Angles.ANGLE[minang].angle + Memory.Camera.Angle) % 65536 < goal and speedsign == 1 then
		minang = minang + 1
		if minang > Angles.COUNT then
			minang = 1
		end
	elseif (Angles.ANGLE[minang].angle + Memory.Camera.Angle) % 65536 > goal and  speedsign == -1 then
		minang = minang - 1
		if minang < 1 then
			minang = Angles.COUNT 
		end
	end--]]
	return {
		angle = (Angles.ANGLE[minang].angle + Memory.Camera.Angle) % 65536,
		X = Angles.ANGLE[minang].X,
		Y = Angles.ANGLE[minang].Y
	}	
end

function Engine.GetQFs(Mariospeed)
	-- print(math.sqrt(math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.PreviousPos.X))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.Mario.X)))) ^ 2 + math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.PreviousPos.Z))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.Mario.Z)))) ^ 2))
	-- return math.floor(4 * (math.sqrt(math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.PreviousPos.X))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.Mario.X)))) ^ 2 + math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.PreviousPos.Z))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.Mario.Z)))) ^ 2)) / math.abs(Mariospeed))
end

function Engine.GetSpeedEfficiency()
	if Memory.Mario.XSlideSpeed + Memory.Mario.ZSlideSpeed > 0 then
		return MoreMaths.Round(Engine.GetDistMoved() / math.abs(math.sqrt(MoreMaths.DecodeDecToFloat(Memory.Mario.XSlideSpeed) ^ 2 + MoreMaths.DecodeDecToFloat(Memory.Mario.ZSlideSpeed) ^ 2)) * 100, 5)
	else
		return 0
	end
end

function Engine.GetDistMoved()
	return math.sqrt((MoreMaths.DecodeDecToFloat(Memory.PreviousPos.X) - MoreMaths.DecodeDecToFloat(Memory.Mario.X)) ^ 2 + (MoreMaths.DecodeDecToFloat(Memory.PreviousPos.Z) - MoreMaths.DecodeDecToFloat(Memory.Mario.Z)) ^ 2)
end

function Engine.GetCurrentAction()
	for i = 1, Actions.COUNT, 1 do
		if Actions.ACTION[i].value == Memory.Mario.Action then
			return Actions.ACTION[i].name
		end
	end
	return "INVALID ACTION"
end

function Engine.GetTotalDistMoved()
	local eckswhy = (Settings.Layout.Button.dist_button.axis.x - MoreMaths.DecodeDecToFloat(Memory.Mario.X)) ^ 2 + (Settings.Layout.Button.dist_button.axis.z - MoreMaths.DecodeDecToFloat(Memory.Mario.Z)) ^ 2
	if (Settings.Layout.Button.dist_button.ignore_y == false) then
		eckswhy = eckswhy + (Settings.Layout.Button.dist_button.axis.y - MoreMaths.DecodeDecToFloat(Memory.Mario.Y)) ^ 2
	end
	return math.sqrt(eckswhy)
end

function Engine.GetHSlidingSpeed()
	return math.sqrt(MoreMaths.DecodeDecToFloat(Memory.Mario.XSlideSpeed) ^ 2 + MoreMaths.DecodeDecToFloat(Memory.Mario.ZSlideSpeed) ^ 2)
end