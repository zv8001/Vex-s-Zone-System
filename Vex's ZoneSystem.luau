

--[[

MIT License

Copyright (c) 2025 Ƶ V 8 0 0

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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


OR FOR PARTS:

Zone:PartEntered(function()

end)

Zone:PartExited(function()

end)

Zone:GetPartsInZone()



A simple system for detecting players within zones inspired by Zone+ but way more reliable

right now this system is pretty limited and uses Region 3 so orientation won't work correctly I plan on updating it in the future.
-VexTheProtogen

Please credit me if you use this!!!

LAST UPDATED: 9/20/2025 8:03PM

]]



local VexsZoneSystem = {}
VexsZoneSystem.__index = VexsZoneSystem
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")




VexsZoneSystem.new = function(SystemName,Size)
	
	if typeof(SystemName) == "Vector3" then
		if typeof(SystemName) == "Vector3" and typeof(Size) ~= "Vector3" then
			error("When using a Vector3 The second parameter size must be set to a vector 3.")
		end
	elseif typeof(SystemName) == "Instance" and SystemName:IsA("BasePart") then
	else
		error("Invalid input parameter one must be a base part or Vector3")
	end
	
	local self = setmetatable({},VexsZoneSystem)
	
	self.PlayersInZone = {}
	self.PartsInZone = {}
	
	self.PlayerGEvents = {
		Instance.new("BindableEvent"); --Player Enter
		Instance.new("BindableEvent"); --Player Exit
	}
	
	self.PartsGEvents = {
		Instance.new("BindableEvent"); --Part Enter
		Instance.new("BindableEvent"); --Part Exit
	}
	
	self.PlayersT = {
		["PLAYERNAME"] = {}
	}
	
	local function UpdateLoop()
		if SystemName then
			local PlayersInServer = Players:GetPlayers()
			local NewList = {}
			local PartsList = {}
			local region = nil
			
			local SysVect3 = nil
			local SysSize = nil
			
			if typeof(SystemName) == "Vector3" then
				SysVect3 = SystemName
				SysSize = Size
			else
				SysVect3 = SystemName.Position
				SysSize = SystemName.Size
			end
			
			local region = Region3.new(SysVect3 - SysSize/2,SysVect3 + SysSize/2)

			local parts = workspace:FindPartsInRegion3(region, nil, math.huge)

			for _,Part in pairs(parts) do
				local Player = Players:GetPlayerFromCharacter(Part.Parent)
				if Player and not table.find(NewList,Player) then
					table.insert(NewList,Player)
				elseif not Player and not table.find(PartsList,Part) then
					table.insert(PartsList,Part)
				end
			end

			local PartsLoop = function(StartT,FindT,callback)
				for _,Part in pairs(StartT) do
					if not table.find(FindT,Part) then
						callback(Part)
					end
				end
			end

			PartsLoop(PartsList,self.PartsInZone,function(Part)
				self.PartsGEvents[1]:Fire(Part)
			end)

			PartsLoop(self.PartsInZone,PartsList,function(Part)
				self.PartsGEvents[2]:Fire(Part)
			end)

			PartsLoop(NewList,self.PlayersInZone,function(Player)
				self.PlayersT[Player][1]:Fire()
				self.PlayerGEvents[1]:Fire(Player)
			end)

			PartsLoop(self.PlayersInZone,NewList,function(Player)
				self.PlayersT[Player][2]:Fire()
				self.PlayerGEvents[2]:Fire(Player)
			end)

			self.PartsInZone = PartsList
			self.PlayersInZone = NewList
		end

	end

	task.spawn(function()
		while task.wait(0.1) do
			UpdateLoop()
		end
	end)
	
	
	
	
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



function VexsZoneSystem:localPlayerEntered(callback)
	if RunService:IsClient() then
		local LocalPlayer = Players.LocalPlayer
		self.PlayersT[LocalPlayer][1].Event:Connect(callback)
	else
		error("localPlayerEntered only works on the Client")
	end
end

function VexsZoneSystem:localPlayerExited(callback)
	if RunService:IsClient() then
		local LocalPlayer = Players.LocalPlayer
		self.PlayersT[LocalPlayer][2].Event:Connect(callback)
	else
		error("localPlayerEntered only works on the Client")
	end
end


function VexsZoneSystem:PlayerExited(callback)
	self.PlayerGEvents[2].Event:Connect(callback)
end

function VexsZoneSystem:PlayerEntered(callback)
	self.PlayerGEvents[1].Event:Connect(callback)
end

function VexsZoneSystem:PartEntered(callback)
	self.PartsGEvents[1].Event:Connect(callback)
end

function VexsZoneSystem:PartExited(callback)
	self.PartsGEvents[2].Event:Connect(callback)
end

function VexsZoneSystem:GetPlayers()
	return self.PlayersInZone
end

function VexsZoneSystem:GetPartsInZone()
	return self.PartsInZone
end

return VexsZoneSystem

