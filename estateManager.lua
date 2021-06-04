--
-- Estate Manager Trigger
-- by Blacky_BPG
-- 
--
-- Version 1.9.0.1   | 03.05.2021 - fix for precision farming
-- Version 1.9.0.0   | 31.03.2021 - initial Version for FS19
--
-- No script change without my permission
-- 

EstateAgent = {}
EstateAgent.version = "1.9.0.1"
EstateAgent.date = "03.05.2021"
EstateAgent_mt = Class(EstateAgent)

function EstateAgent.onCreate(id)
	local object = EstateAgent:new(id)
	g_currentMission:addNonUpdateable(object)
end

function EstateAgent:new(id)
	local self = {}
	setmetatable(self, EstateAgent_mt)
	self.estateAgent = id
	self.estateAgentTrigger = {}
	local num = getNumOfChildren(self.estateAgent)
	for i = 0, num - 1 do
		local estateAgentTriggerId = getChildAt(self.estateAgent, i)
		addTrigger(estateAgentTriggerId, "triggerCallback", self)
		table.insert(self.estateAgentTrigger, estateAgentTriggerId)
	end
	if g_currentMission.estateAgentActive == nil then
		g_currentMission.estateAgentActive = false
	end
	return self
end

function EstateAgent:getFarmlandOwner(superFunc, farmlandId)
	if self.isClient or g_client ~= nil or g_currentMission.player.isClient then
		local override = false
		if g_gui.currentGui ~= nil and g_gui.currentGui.target ~= nil and g_gui.currentGui.target.currentPage ~= nil and g_gui.currentGui.target.currentPage.isPrecisionFarmingPage then
			override = true
		end
		if not override and g_currentMission.estateAgentActive == false and g_gui.currentGui ~= nil and g_gui.currentGuiName == "InGameMenu" then
			return FarmlandManager.NOT_BUYABLE_FARM_ID
		else
			return superFunc(self, farmlandId)
		end
	else
		return superFunc(self, farmlandId)
	end
end
FarmlandManager.getFarmlandOwner = Utils.overwrittenFunction(FarmlandManager.getFarmlandOwner, EstateAgent.getFarmlandOwner)

function EstateAgent:delete()
	for _, estateAgentTrigger in pairs(self.estateAgentTrigger) do
		removeTrigger(estateAgentTrigger)
	end
end

function EstateAgent:triggerCallback(triggerId, otherId, onEnter, onLeave, onStay)
	if onEnter then
		if g_currentMission.player ~= nil and otherId == g_currentMission.player.rootNode and g_currentMission.controlPlayer then
			g_currentMission.estateAgentActive = true
		end
	else
		g_currentMission.estateAgentActive = false
	end
end

g_onCreateUtil.addOnCreateFunction("EstateAgent", EstateAgent.onCreate)

print(" ++ loading EstateAgent Trigger V "..tostring(EstateAgent.version).." - "..tostring(EstateAgent.date).." (by Blacky_BPG)")
