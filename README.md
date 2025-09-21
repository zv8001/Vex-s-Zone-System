# Vex's ZoneSystem Made by VexTheProtgen (4071774573) ROBLOX:z3ck200
My take on zone+

█░█ █▀▀ ▀▄▀ ▀ █▀   ▀█ █▀█ █▄░█ █▀▀ █▀ █▄█ █▀ ▀█▀ █▀▀ █▀▄▀█
▀▄▀ ██▄ █░█ ░ ▄█   █▄ █▄█ █░▀█ ██▄ ▄█ ░█░ ▄█ ░█░ ██▄ █░▀░█

I was extremely tired of Zone Plus being an unreliable piece of crap. I'm sorry, Forever HD, you make really good stuff, but please update Zone Plus 🙏. It's full of weird bugs and is just annoying to work with.

I recreated it. This version is experimental and pretty primitive for now, using Region3. It can only detect players at this point, but I'm looking to change that.


The zone container can be a single base part or a Folder/Model of a bunch of different parts that will all react as if one trigger.
Update: I need to redo the code for grouped items so I disabled that functionality temporarily



API:

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
