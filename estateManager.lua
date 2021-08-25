--
-- Estate Manager Trigger
-- by Blacky_BPG
-- 
--
-- Version 1.9.0.2   | 25.08.2021 - simplified functions for disable buy/sell farmlands
-- Version 1.9.0.1   | 03.05.2021 - fix for precision farming
-- Version 1.9.0.0   | 31.03.2021 - initial Version for FS19
--
-- No script change without my permission
-- 

EstateAgent = {}
EstateAgent.version = "1.9.0.2"
EstateAgent.date = "25.08.2021"
EstateAgent_mt = Class(EstateAgent)

function EstateAgent.onCreate(id)
	local object = EstateAgent:new(id)
	g_currentMission:addNonUpdateable(object)
	g_currentMission.inGameMenu.pageMapOverview.buttonSellFarmland:setDisabled(true)
	g_currentMission.inGameMenu.pageMapOverview.buttonBuyFarmland:setDisabled(true)
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

function EstateAgent:onClickSellFarmland(superFunc, varA, varB, varC, varD, varE, varF, varG)
	if self.isClient or g_client ~= nil or g_currentMission.player.isClient then
		if g_currentMission.estateAgentActive == true then
			return superFunc(self, varA, varB, varC, varD, varE, varF, varG)
		end
	end
	return nil
end
InGameMenuMapFrame.onClickSellFarmland = Utils.overwrittenFunction(InGameMenuMapFrame.onClickSellFarmland, EstateAgent.onClickSellFarmland)

function EstateAgent:onClickBuyFarmland(superFunc, varA, varB, varC, varD, varE, varF, varG)
	if self.isClient or g_client ~= nil or g_currentMission.player.isClient then
		if g_currentMission.estateAgentActive == true then
			return superFunc(self, varA, varB, varC, varD, varE, varF, varG)
		end
	end
	return nil
end
InGameMenuMapFrame.onClickBuyFarmland = Utils.overwrittenFunction(InGameMenuMapFrame.onClickBuyFarmland, EstateAgent.onClickBuyFarmland)

function EstateAgent:delete()
	for _, estateAgentTrigger in pairs(self.estateAgentTrigger) do
		removeTrigger(estateAgentTrigger)
	end
end

function EstateAgent:triggerCallback(triggerId, otherId, onEnter, onLeave, onStay)
	if onEnter then
		if g_currentMission.player ~= nil and otherId == g_currentMission.player.rootNode and g_currentMission.controlPlayer then
			g_currentMission.estateAgentActive = true
			g_currentMission.inGameMenu.pageMapOverview.buttonSellFarmland:setDisabled(false)
			g_currentMission.inGameMenu.pageMapOverview.buttonBuyFarmland:setDisabled(false)
		end
	else
		if g_currentMission.player ~= nil and otherId == g_currentMission.player.rootNode and g_currentMission.controlPlayer then
			g_currentMission.estateAgentActive = false
			g_currentMission.inGameMenu.pageMapOverview.buttonSellFarmland:setDisabled(true)
			g_currentMission.inGameMenu.pageMapOverview.buttonBuyFarmland:setDisabled(true)
		end
	end
end

g_onCreateUtil.addOnCreateFunction("EstateAgent", EstateAgent.onCreate)

print(" ++ loading EstateAgent Trigger V "..tostring(EstateAgent.version).." - "..tostring(EstateAgent.date).." (by Blacky_BPG)")
