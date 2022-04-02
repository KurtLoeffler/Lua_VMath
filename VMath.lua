local math = math
local pi, radian = math.pi, math.pi*2
local VMath = {}

-- general

VMath.epsilon = 0.000001

---@param value number
---@param min number (optional) defaults to 0.
---@param max number (optional) defaults to 1.
---@return number clampedValue
function VMath.clamp(value, min, max)
	min, max = min or 0, max or 1
	return math.min(math.max(value, min), max)
end

---@param maxValue number (optional) defaults to 1.
---@return number wrappedValue
function VMath.wrap(value, maxValue)
	maxValue = maxValue or 1
	return VMath.clamp(value-math.floor(value/maxValue)*maxValue, 0, maxValue)
end

---@return number wrappedValue
function VMath.wrapRad(value)
	return VMath.wrap(value, radian)
end

---@return number wrappedValue
function VMath.wrapDeg(value)
	return VMath.wrap(value, 360)
end

---@param zeroValue number (optional) what to return if value is 0. defaults to 0.
---@return number sign
function VMath.sign(value, zeroValue)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	end
	return zeroValue or 0
end

---linear interpolation.
---@param current number the value to lerp from.
---@param target number the value to lerp to.
---@param amount number the interpolation ratio value (0-1).
---@return number
function VMath.lerp(current, target, amount)
	return current+(target-current)*VMath.clamp(amount)
end

---linear interpolation without clamping amount.
---@param current number the value to lerp from.
---@param target number the value to lerp to.
---@param amount number the interpolation ratio value (0-1). numbers < 0 or > 1 will extrapolate from current and target.
---@return number
function VMath.lerpUnclamped(current, target, amount)
	return current+(target-current)*amount
end

---linear interpolation of an angle in radians.
---@param current number the value to lerp from in radians.
---@param target number the value to lerp to in radians.
---@param amount number the interpolation ratio value (0-1).
---@return number newAngle in radians
function VMath.lerpAngle(current, target, amount)
	local delta = VMath.deltaAngle(current, target)
	return current+delta*VMath.clamp(amount)
end

---linear interpolation of an angle in degrees.
---@param current number the value to lerp from in degrees.
---@param target number the value to lerp to in degrees.
---@param amount number the interpolation ratio value (0-1).
---@return number newAngle in degrees
function VMath.lerpAngleDeg(current, target, amount)
	local delta = VMath.deltaAngleDeg(current, target)
	return current+delta*VMath.clamp(amount)
end

---moves a value closer to a target value by a given amount.
---@param current number the value to move from
---@param target number the value to move to
---@param amount number maximum amount to move
---@return number newAngle
function VMath.moveTowards(current, target, amount)
	local delta = target-current
	if math.abs(delta) <= amount then
		return target
	end
	return current+VMath.sign(delta)*amount
end

---moves an angle in radians closer to a target angle by a given amount.
---@param current number the angle in radians to move from
---@param target number the angle in radians to move to
---@param amount number maximum amount to move in radians
---@return number newAngle in radians
function VMath.moveTowardsAngle(current, target, amount)
	local delta = VMath.deltaAngle(current, target)
	if math.abs(delta) <= amount then
		return target
	end
	return VMath.wrapRad(VMath.moveTowards(current, current+delta, amount))
end

---moves an angle in degrees closer to a target angle by a given amount.
---@param current number the angle in degrees to move from
---@param target number the angle in degrees to move to
---@param amount number maximum amount to move in degrees
---@return number newAngle in degrees
function VMath.moveTowardsAngleDeg(current, target, amount)
	local delta = VMath.deltaAngleDeg(current, target)
	if math.abs(delta) <= amount then
		return target
	end
	return VMath.wrapDeg(VMath.moveTowards(current, current+delta, amount))
end

-- 2d functions

---@return number x, number y
function VMath.angleToVector(angle)
	return math.cos(angle), math.sin(angle)
end

---@return number x, number y
function VMath.angleToVectorDeg(angle)
	return VMath.angleToVector(math.rad(angle))
end

---@return number angle in radians
function VMath.vectorToAngle(x, y)
	return math.atan2(y, x)
end

---@return number angle in degrees
function VMath.vectorToAngleDeg(x, y)
	return math.deg(VMath.vectorToAngle(x, y))
end

---@return number x, number y
function VMath.rotate(x, y, angle, px, py)
	if px and py then
		x = x-px
		y = y-py
	end

	local ca = math.cos(angle)
	local sa = math.sin(angle)
	x, y = ca*x-sa*y, sa*x+ca*y

	if px and py then
		x = x+px
		y = y+py
	end
	return x, y
end

---@return number x, number y
function VMath.rotateDeg(x, y, angle, px, py)
	return VMath.rotate(x, y, math.rad(angle), px, py)
end

---@return number squaredLength
function VMath.sqrLength(x, y)
	return x*x+y*y
end

---@return number length
function VMath.length(x, y)
	return math.sqrt(VMath.sqrLength(x, y))
end

---@return number x, number y
function VMath.normalize(x, y)
	local length = VMath.length(x, y)
	if length <= 0 then
		return 0, 0
	end
	x = x/length
	y = y/length
	return x, y
end

---@return number dotProduct
function VMath.dot(ax, ay, bx, by)
	return ax*bx+ay*by
end

---@return number x, number y
function VMath.perpendicular(x, y)
	return -y, x
end

--- calculate the signed delta angle in radians between two 2d vectors.
--- if vector "a" is rotated by the result, it will align with vector "b".
---@return number deltaAngle
function VMath.vectorDeltaAngle(ax, ay, bx, by)
	local sin = ax*by-bx*ay
	local cos = ax*bx+ay*by
	return math.atan2(sin, cos)
end

--- calculate the signed delta angle in degrees between two 2d vectors.
--- if vector "a" is rotated by the result, it will align with vector "b".
---@return number deltaAngle
function VMath.vectorDeltaAngleDeg(ax, ay, bx, by)
	return math.deg(VMath.vectorDeltaAngle(ax, ay, bx, by))
end

--- calculate the signed delta angle in radians between two angles.
--- adding the result to angle "a" will result in an angle approximately equaling angle b.
---@return number deltaAngle
function VMath.deltaAngle(a, b)
	local result = b-a
	result = (result+pi)%radian-pi
	return result
end

--- calculate the signed delta angle in degrees between two angles.
--- adding the result to angle "a" will result in an angle approximately equaling angle b.
---@return number deltaAngle
function VMath.deltaAngleDeg(a, b)
	return math.deg(VMath.deltaAngle(math.rad(a), math.rad(b)))
end

---@return number normalX, number normalY, number planeDistance
function VMath.planeFromNormalAndPoint(normalX, normalY, pointX, pointY)
	local planeDistance = VMath.dot(normalX, normalY, pointX, pointY)
	return normalX, normalY, planeDistance
end

--- calculate the signed distance from a point to a plane.
---@return number distance
function VMath.distanceToPlane(planeNormalX, planeNormalY, planeDistance, x, y)
	local dot = VMath.dot(planeNormalX, planeNormalY, x, y)
	return planeDistance-dot
end

---@return number x, number y
function VMath.negate(x, y)
	return -x, -y
end

---@return number x, number y
function VMath.add(x, y, mx, my)
	my = my or mx
	return x+mx, y+my
end

---@return number x, number y
function VMath.subtract(x, y, mx, my)
	my = my or mx
	return x-mx, y-my
end

---@return number x, number y
function VMath.multiply(x, y, mx, my)
	my = my or mx
	return x*mx, y*my
end

---@return number x, number y
function VMath.divide(x, y, mx, my)
	my = my or mx
	return x/mx, y/my
end

-- 3d functions

--- calculate a 3d unit vector along the "view" direction of yaw and pitch angles in radians.
--- the to the resulting z axis corresponds to the input pitch angle.
---@param yaw number yaw angle in radians
---@param pitch number pitch angle in radians
---@return number x, number y, number z
function VMath.angleToVector3(yaw, pitch)
	local zLen = math.cos(pitch)
	local x = zLen*math.cos(yaw)
	local y = zLen*math.sin(yaw)
	local z = math.sin(pitch)
	return x, y, z
end

--- calculate a 3d unit vector along the "view" direction of yaw and pitch angles in degrees.
--- the to the resulting z axis corresponds to the input pitch angle.
---@param yaw number yaw angle in degrees
---@param pitch number pitch angle in degrees
---@return number x, number y, number z
function VMath.angleToVectorDeg3(yaw, pitch)
	return VMath.angleToVector3(math.rad(yaw), math.rad(pitch))
end

---@return number squaredLength
function VMath.sqrLength3(x, y, z)
	return x*x+y*y+z*z
end

---@return number length
function VMath.length3(x, y, z)
	return math.sqrt(VMath.sqrLength3(x, y, z))
end

---@return number x, number y, number z
function VMath.normalize3(x, y, z)
	local length = VMath.length3(x, y, z)
	if length <= 0 then
		return 0, 0, 0
	end
	x = x/length
	y = y/length
	z = z/length
	return x, y, z
end

---@return number dotProduct
function VMath.dot3(ax, ay, az, bx, by, bz)
	return ax*bx+ay*by+az*bz
end

return VMath
