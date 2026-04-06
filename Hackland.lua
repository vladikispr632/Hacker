-- =========================
-- 👑 KINGHUB V6 AUTO SYSTEM
-- =========================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

-- 🔥 Create Remotes
local event = RS:FindFirstChild("KingHubEvent") or Instance.new("RemoteEvent")
event.Name = "KingHubEvent"
event.Parent = RS

local combat = RS:FindFirstChild("KingHubCombat") or Instance.new("RemoteEvent")
combat.Name = "KingHubCombat"
combat.Parent = RS

-- =========================
-- 🧠 SERVER LOGIC
-- =========================

event.OnServerEvent:Connect(function(plr, action, targetName)

	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")

	local target = targetName and Players:FindFirstChild(targetName)

	if action == "tp" and target and target.Character then
		root.CFrame = target.Character.HumanoidRootPart.CFrame
	end

	if action == "kill" and target and target.Character then
		target.Character.Humanoid.Health = 0
	end

	if action == "bring" and target and target.Character then
		target.Character.HumanoidRootPart.CFrame = root.CFrame
	end

	if action == "freeze" and target and target.Character then
		target.Character.HumanoidRootPart.Anchored = true
	end

	if action == "unfreeze" and target and target.Character then
		target.Character.HumanoidRootPart.Anchored = false
	end

	if action == "explode" and target and target.Character then
		local e = Instance.new("Explosion")
		e.Position = target.Character.HumanoidRootPart.Position
		e.BlastRadius = 10
		e.Parent = workspace
	end

	if action == "reset" and target then
		target:LoadCharacter()
	end

	if action == "masskill" then
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= plr and p.Character then
				local h = p.Character:FindFirstChild("Humanoid")
				if h then h.Health = 0 end
			end
		end
	end
end)

-- 🧲 KILL AURA SERVER
combat.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if dist < 8 then
				p.Character.Humanoid.Health = 0
			end
		end
	end
end)

-- =========================
-- 🖥️ CLIENT GUI AUTO
-- =========================

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()

		task.wait(1)

		local gui = Instance.new("ScreenGui")
		gui.Name = "KingHub"
		gui.Parent = plr:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 700, 0, 450)
		frame.Position = UDim2.new(0.5, -350, 0.5, -225)
		frame.Parent = gui

		-- 🌈 rainbow background
		task.spawn(function()
			while frame.Parent do
				for i=0,1,0.01 do
					frame.BackgroundColor3 = Color3.fromHSV(i,1,1)
					task.wait(0.02)
				end
			end
		end)

		-- INPUT
		local input = Instance.new("TextBox")
		input.Size = UDim2.new(1,-20,0,35)
		input.Position = UDim2.new(0,10,0,10)
		input.PlaceholderText = "player name..."
		input.Parent = frame

		local RS2 = game:GetService("ReplicatedStorage")
		local event2 = RS2:WaitForChild("KingHubEvent")
		local combat2 = RS2:WaitForChild("KingHubCombat")

		-- BUTTON CREATOR
		local function btn(txt,y,func)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0,200,0,35)
			b.Position = UDim2.new(0,10 + ((y%3)*210),0,60 + math.floor(y/3)*45)
			b.Text = txt
			b.Parent = frame
			b.MouseButton1Click:Connect(func)
		end

		local function t()
			return input.Text
		end

		-- ⚡ SERVER ACTIONS
		btn("TP",0,function() event2:FireServer("tp",t()) end)
		btn("Kill",1,function() event2:FireServer("kill",t()) end)
		btn("Bring",2,function() event2:FireServer("bring",t()) end)
		btn("Freeze",3,function() event2:FireServer("freeze",t()) end)
		btn("Unfreeze",4,function() event2:FireServer("unfreeze",t()) end)
		btn("Explode",5,function() event2:FireServer("explode",t()) end)
		btn("Reset",6,function() event2:FireServer("reset",t()) end)
		btn("MassKill",7,function() event2:FireServer("masskill") end)

		-- 🧲 KILL AURA
		local aura = false
		btn("Kill Aura",10,function()
			aura = not aura
			task.spawn(function()
				while aura do
					combat2:FireServer()
					task.wait(0.2)
				end
			end)
		end)

		-- 🤖 AUTO FARM (Coins)
		btn("Auto Farm",11,function()
			task.spawn(function()
				while true do
					for _,v in pairs(workspace:GetDescendants()) do
						if v:IsA("Part") and v.Name == "Coin" then
							plr.Character:MoveTo(v.Position)
							task.wait(0.1)
						end
					end
					task.wait(0.5)
				end
			end)
		end)

		-- 🧠 SELF FEATURES
		btn("Speed",20,function()
			plr.Character.Humanoid.WalkSpeed = 80
		end)

		btn("Jump",21,function()
			plr.Character.Humanoid.JumpPower = 120
		end)

		btn("Heal",22,function()
			plr.Character.Humanoid.Health = 100
		end)

		btn("Fly",23,function()
			local bv = Instance.new("BodyVelocity", plr.Character.HumanoidRootPart)
			bv.Velocity = Vector3.new(0,80,0)
		end)

		btn("NoClip",24,function()
			game:GetService("RunService").Stepped:Connect(function()
				for _,v in pairs(plr.Character:GetDescendants()) do
					if v:IsA("BasePart") then v.CanCollide = false end
				end
			end)
		end)

		btn("ESP",25,function()
			for _,p in pairs(Players:GetPlayers()) do
				if p ~= plr and p.Character then
					Instance.new("Highlight", p.Character)
				end
			end
		end)

		btn("TP Random",26,function()
			local ps = Players:GetPlayers()
			local t = ps[math.random(1,#ps)]
			if t.Character then
				plr.Character:MoveTo(t.Character.HumanoidRootPart.Position)
			end
		end)

		btn("Invisible",27,function()
			for _,v in pairs(plr.Character:GetDescendants()) do
				if v:IsA("BasePart") then v.Transparency = 1 end
			end
		end)

		btn("Sit",28,function()
			plr.Character.Humanoid.Sit = true
		end)

		btn("God Mode",29,function()
			plr.Character.Humanoid.MaxHealth = math.huge
			plr.Character.Humanoid.Health = math.huge
		end)

	end)
end)
