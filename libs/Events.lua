local ADDON_NAME, ADDON = ...

--[[
local VERSION = 1
if AstralEvents and AstralEvents.version >= VERSION then
	return
end
]]

function mixin(D, T, force)
	for k,v in pairs(T) do
		if (type(v) == "function") and (force or (D[k] == nil)) then
			D[k] = v;
		end
	end
end

Event = {}

local EventPrototype = {}
local EventMeta = {}
EventMeta.__index = EventPrototype

-- Creates new event object
-- @param f Function to be called on event
-- @param name Name for the function for identification
-- @return Event object with method to be called on event fire
function EventPrototype:NewObject(f, name)
	local obj = {}
	obj.name = name or 'anonymous'
	obj.method = f

	return obj
end

-- Registers function to an event
-- @param event Event that is fired when function is to be called
-- @param f Function to be called when event is fired
-- @param name Name of function, used as an identifier
function EventPrototype:Register(event, f, name)
	if self:IsRegistered(event, name) then return end -- Event already registered with same name, bail out
	local obj = self:NewObject(f, name)

	if not self.dtbl[event] then 
		self.dtbl[event] = {}
		self:RegisterEvent(event)
	end
	self.dtbl[event][name] = obj
end

-- Unregisters function from being called on event
-- @param event Event the object's method is to be removed from
-- @name The name of the object to be removed
function EventPrototype:Unregister(event, name)
	--local objs = self.dtbl[event]
	if not self.dtbl[event] then return end
	self.dtbl[event][name] = nil
	if next(self.dtbl[event]) == nil then
		self.dtbl[event] = nil
		self:UnregisterEvent(event)
	end
end

-- Checks to see if an object is registered for an event
-- @param event The event the object is to be called on
-- @param name The name of the object that is to be checked
-- @return True or false if the object is bound to an event
function EventPrototype:IsRegistered(event, name)
	--local objs = self.dtbl[event]
	if not self.dtbl[event] then return false end

	if self.dtbl[event][name] then
		return true
	else
		return false
	end
end

-- Gets function bound to event
-- @param event Event to be queried
-- @param handler Object name to be retrieved
-- @return function The function pertaining to the given handler for said event
function EventPrototype:GetRegisteredFunction(event, handler)
	--local objs = self.dtbl[event]
	if not self.dtbl[event] then return end

	if self.dtbl[event][handler] then
		return self.dtbl[event][handler].method
	else
		return nil
	end
end

-- On event handler passes arguements onto methods to each function
-- @param event Event that was fired
-- @param ... Arguments for said event
function EventPrototype:OnEvent(event, ...)
	--local objs = self.dtbl[event]
	if not self.dtbl[event] then return end
	for _, obj in pairs(self.dtbl[event]) do
		obj.method(...)
	end
end

function EventPrototype:UnregisterAll()
	--local objs = self.dtbl
	for event in next(self.dtbl) do
		print(event)
	end
end

function Event:New(name)
	local self = CreateFrame('FRAME', name)
	self.dtbl = {}
	mixin(self, EventPrototype)
	self:SetScript('OnEvent', self.OnEvent)
	return self;
end