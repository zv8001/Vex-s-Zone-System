--[[
██╗░░░██╗███████╗██╗░░██╗██╗░██████╗              
██║░░░██║██╔════╝╚██╗██╔╝╚█║██╔════╝              
╚██╗░██╔╝█████╗░░░╚███╔╝░░╚╝╚█████╗░              
░╚████╔╝░██╔══╝░░░██╔██╗░░░░░╚═══██╗              
░░╚██╔╝░░███████╗██╔╝╚██╗░░░██████╔╝              
░░░╚═╝░░░╚══════╝╚═╝░░╚═╝░░░╚═════╝░              

███████╗░█████╗░███╗░░██╗███████╗  ░██████╗██╗░░░██╗░██████╗████████╗███████╗███╗░░░███╗
╚════██║██╔══██╗████╗░██║██╔════╝  ██╔════╝╚██╗░██╔╝██╔════╝╚══██╔══╝██╔════╝████╗░████║
░░███╔═╝██║░░██║██╔██╗██║█████╗░░  ╚█████╗░░╚████╔╝░╚█████╗░░░░██║░░░█████╗░░██╔████╔██║
██╔══╝░░██║░░██║██║╚████║██╔══╝░░  ░╚═══██╗░░╚██╔╝░░░╚═══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║
███████╗╚█████╔╝██║░╚███║███████╗  ██████╔╝░░░██║░░░██████╔╝░░░██║░░░███████╗██║░╚═╝░██║
╚══════╝░╚════╝░╚═╝░░╚══╝╚══════╝  ╚═════╝░░░░╚═╝░░░╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝

Vex's ZoneSystem Made by VexTheProtgen (4071774573) ROBLOX:z3ck200

The zone container can be a single base part or a Folder/Model of a bunch of different parts that will all react as if one trigger.
Update: I need to redo the code for grouped items so I disabled that functionality temporarily



local Zone = require(game.ReplicatedStorage.ZoneSystem).new(workspace.aaaaa)


Zone:localPlayerEntered(function()

end)


Zone:localPlayerExited(function()

end)

Zone:PlayerExited(function()

end)

Zone:PlayerEntered(function()

end)

Zone:GetPlayers()


A simple system for detecting players within zones inspired by Zone+ but way more reliable

right now this system is pretty limited and uses Region 3 so orientation won't work correctly I plan on updating it in the future.
-VexTheProtogen

Please credit me if you use this!!!

LAST UPDATED: 9/20/2025 7:06PM

]]



local ZoneBB = {}
ZoneBB.__index = ZoneBB
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


ZoneBB.new = function(SystemName:Instance)
	local self = setmetatable({},ZoneBB)
	
	self.PlayersInZone = {}
	
	
	self.PlayerGEvents = {
		Instance.new("BindableEvent"); --Player Enter
		Instance.new("BindableEvent"); --Player Exit
	}
	
	self.PlayersT = {
		["PLAYERNAME"] = {}
	}
	
	local FuncRunCode = function(SystemName:BasePart)
		local function UpdateLoop()
			if SystemName then
				local PlayersInServer = Players:GetPlayers()
				local NewList = {}
				
				local region = Region3.new(
					SystemName.Position - SystemName.Size/2,
					SystemName.Position + SystemName.Size/2
				)
				
				local parts = workspace:FindPartsInRegion3(region, nil, math.huge)
				
				for _,Part in pairs(parts) do
					local Player = Players:GetPlayerFromCharacter(Part.Parent)
					if Player and not table.find(NewList,Player) then
						table.insert(NewList,Player)
					end
				end

				for _,Player in pairs(NewList) do
					if not table.find(self.PlayersInZone,Player) then
						self.PlayersT[Player][1]:Fire()
						self.PlayerGEvents[1]:Fire(Player)
					end
				end

				for _,Player in pairs(self.PlayersInZone) do
					if not table.find(NewList,Player) then
						self.PlayersT[Player][2]:Fire()
						self.PlayerGEvents[2]:Fire(Player)
					end
				end

				self.PlayersInZone = NewList
			end
			
		end
	
		task.spawn(function()
			while task.wait(0.1) do
				UpdateLoop()
			end
		end)
	end
	
	if SystemName:IsA("BasePart") then
		FuncRunCode(SystemName)
	elseif SystemName:IsA("Model") or SystemName:IsA("Folder") and false then
		for _,Item in pairs(SystemName:GetDescendants()) do
			if Item:IsA("BasePart") then
				FuncRunCode(Item)
			end
		end
	else
		error("Invalid input parameter 1 must be a base part")
	end
	
	local function AddCode(Player)
		if not self.PlayersT[Player] then
			self.PlayersT[Player] = {
				Instance.new("BindableEvent"); --PlayerEntered
				Instance.new("BindableEvent"); --PlayerExited
			}
		end
	end
	
	
	for i,Player in pairs(Players:GetPlayers()) do
		AddCode(Player)
	end
	
	Players.PlayerAdded:Connect(AddCode)
	
	Players.PlayerRemoving:Connect(function(Player)
		if self.PlayersT[Player] then
			self.PlayersT[Player][1]:Destroy()
			self.PlayersT[Player][2]:Destroy()
			self.PlayersT[Player] = nil
		end
	end)
	
	return self
end



function ZoneBB:localPlayerEntered(callback)
	if RunService:IsClient() then
		local LocalPlayer = Players.LocalPlayer
		self.PlayersT[LocalPlayer][1].Event:Connect(callback)
	else
		error("localPlayerEntered only works on the Client")
	end
end

function ZoneBB:localPlayerExited(callback)
	if RunService:IsClient() then
		local LocalPlayer = Players.LocalPlayer
		self.PlayersT[LocalPlayer][2].Event:Connect(callback)
	else
		error("localPlayerEntered only works on the Client")
	end
end


function ZoneBB:PlayerExited(callback)
	self.PlayerGEvents[2].Event:Connect(callback)
end

function ZoneBB:PlayerEntered(callback)
	self.PlayerGEvents[1].Event:Connect(callback)
end

function ZoneBB:GetPlayers()
	return self.PlayersInZone
end

return ZoneBB
