local TraitorGlowColor = Color(255, 0, 0)
local DetectiveGlowColor = Color(0, 0, 255)

CreateClientConVar("ttt_traitor_glow", "1", true, false)
CreateClientConVar("ttt_detective_glow", "0", true, false)

CreateClientConVar("ttt_traitor_wall", "1", true, false)
CreateClientConVar("ttt_detective_wall", "0", true, false)

local function GlowingMates()
	local client = LocalPlayer()
	if client:GetRole() == ROLE_INNOCENT or not client:IsActive() then return end
	
	if not ROLES then
		local traitors = {}
		local detectives = {}
		
		for _, v in ipairs(player.GetAll()) do
			if v ~= client then
				if v:IsActiveTraitor() then
					table.insert(traitors, v)
				elseif v:IsActiveDetective() then
					table.insert(detectives, v)
				end
			end
		end

		if client:IsActiveTraitor() then
			if GetConVar("ttt_traitor_glow"):GetBool() then
				halo.Add(traitors, TraitorGlowColor, 0, 0, 3, true, GetConVar("ttt_traitor_wall"):GetBool())
			end
		elseif client:IsActiveDetective() then
			if GetConVar("ttt_detective_glow"):GetBool() then
				halo.Add(detectives, DetectiveGlowColor, 0, 0, 3, true, GetConVar("ttt_detective_wall"):GetBool())
			end
		end
	else
		local tbl = {}
		
		local rd = client:GetRoleData()
		if rd.team == TEAM_INNO then return end
		
		for _, v in ipairs(player.GetAll()) do
			local roleData = v:GetRoleData()
		
			if v ~= client and v:IsActive() and v:IsTeamMember(client) then
				local role = v:GetRole()
				
				tbl[role] = tbl[role] or {}
				
				table.insert(tbl[role], v)
			end
		end

		for k, v in pairs(tbl) do
			local roleData = GetRoleByIndex(k)
			local cvar = GetConVar("ttt_" .. roleData.name .. "_glow")
			local cwall = GetConVar("ttt_" .. roleData.name .. "_wall")
		
			if cvar and cvar:GetBool() then
				halo.Add(v, roleData.color, 0, 0, 3, true, cwall and cwall:GetBool() or true)
			end
		end
	end
end

hook.Add("PostGamemodeLoaded", "PostGamemodeLoadedGlowingMates", function()
	if engine.ActiveGamemode() == "terrortown" then
		hook.Add("PreDrawHalos", "AddHalos", GlowingMates)
	end
end)

hook.Add("TTT2_FinishedSync", "TTTGlowingMates", function(ply, first)
	if first then
		for _, v in pairs(ROLES) do
			CreateClientConVar("ttt_" .. v.name .. "_glow", "1", true, false)
			CreateClientConVar("ttt_" .. v.name .. "_wall", "1", true, false)
		end
	end
end)
