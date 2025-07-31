__COVER_TABLE_DYNAMIC__, __COVER_TABLE_STATIC__ = __COVER_TABLE_DYNAMIC__ || {}, __COVER_TABLE_STATIC__ || {}
local __COVER_TABLE_DYNAMIC__, __COVER_TABLE_STATIC__ = __COVER_TABLE_DYNAMIC__, __COVER_TABLE_STATIC__

local __REGISTRY__ = debug.getregistry()
local CActorCover = __REGISTRY__.CActorCover || {}
__REGISTRY__.CActorCover = CActorCover

CActorCover.__index = CActorCover

function CActorCover:GetPos() return self.m_Vector end
function CActorCover:SetPos( v ) self.m_Vector = v end

function CActorCover:GetForward() return self.m_vForward end
function CActorCover:SetForward( a ) self.m_vForward = a end

COVER_COLOR_PICKER = Color( 0, 128, 255 )
COVER_COLOR_STATIC = Color( 0, 255, 255 )
COVER_COLOR_DYNAMIC = Color( 255, 255, 0 )

function CActorCover:Update()
	local area = navmesh.GetNearestNavArea( self.m_Vector )
	if area then
		local Identifier = area:GetID()
		self.m_Area = Identifier
		local t = __COVER_TABLE_STATIC__[ Identifier ]
		if t then t[ self ] = true else __COVER_TABLE_STATIC__[ Identifier ] = { [ self ] = true } end
	else self:Remove() end
end

function CActorCover:Remove()
	local area = self.m_Area
	if area then
		local Identifier = self.m_Area
		local t = __COVER_TABLE_STATIC__[ Identifier ]
		if t then
			t[ self ] = nil
			if table.IsEmpty( t ) then __COVER_TABLE_STATIC__[ Identifier ] = nil end
		end
	end
end

function CreateStaticCover( vec, dir )
	local self = setmetatable( { m_Vector = vec, m_vForward = dir, m_bStatic = true }, CActorCover )
	self:Update()
	return self
end

local concommand_Add = concommand.Add
local player_Iterator = player.Iterator
concommand_Add( "Node_BuildCovers", function( ply )
	if IsValid( ply ) && !ply:IsSuperAdmin() then
		ply:SendLua "chat.AddText(Color(128,255,128),\"Node_BuildCovers: You are Not The Super Admin, Trying to Notify The Super Admin...\")"
		for _, p in player_Iterator() do
			if p:IsSuperAdmin() then
				p:SendLua( "chat.AddText(Color(255,255,255),\"A Non-Super Admin Player has Tried to Run Node_BuildCovers\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"Name: " .. ply:GetName() .. "\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"SteamID64: " .. ply:SteamID64() .. "\")" )
				ply:SendLua( "chat.AddText(Color(128,255,128),\"Notified The Super Admin ( " .. p:SteamID64() .. " | " .. p:GetName() " )\")" )
				return
			end
		end
		ply:SendLua "chat.AddText(Color(255,128,128),\"Failed to Notify The Super Admin\")"
		return
	end
	file.CreateDir "ActorCoverBase"
	local t = {}
	for i, d in pairs( __COVER_TABLE_STATIC__ ) do
		local tbl = {}
		t[ i ] = tbl
		for Cover in pairs( d ) do table.insert( tbl, { Cover.m_Vector, Cover.m_vForward } ) end
	end
	local sPath = "ActorCoverBase/" .. game.GetMap() .. ".json"
	file.Write( sPath, util.TableToJSON( t ) )
	for _, p in player_Iterator() do
		if p:IsSuperAdmin() then
			p:SendLua( "chat.AddText(Color(255,255,255),\"Created a Base Actor Cover File at\")" )
			p:SendLua( "chat.AddText(Color(255,255,255),\"" .. sPath .. "\")" )
			return
		end
	end
end, nil, "Builds All Current Covers" )
concommand_Add( "Node_KillCurrentCoverFile", function( ply )
	if IsValid( ply ) && !ply:IsSuperAdmin() then
		ply:SendLua "chat.AddText(Color(128,255,128),\"Node_KillCurrentCoverFile: You are Not The Super Admin, Trying to Notify The Super Admin...\")"
		for _, p in player_Iterator() do
			if p:IsSuperAdmin() then
				p:SendLua( "chat.AddText(Color(255,255,255),\"A Non-Super Admin Player has Tried to Run Node_KillCurrentCoverFile\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"Name: " .. ply:GetName() .. "\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"SteamID64: " .. ply:SteamID64() .. "\")" )
				ply:SendLua( "chat.AddText(Color(128,255,128),\"Notified The Super Admin ( " .. p:SteamID64() .. " | " .. p:GetName() " )\")" )
				return
			end
		end
		ply:SendLua "chat.AddText(Color(255,128,128),\"Failed to Notify The Super Admin\")"
		return
	end
	local sPath = "ActorCover/" .. game.GetMap() .. ".json"
	if file.Exists( sPath, "DATA" ) then
		file.Delete( sPath )
		for _, p in player_Iterator() do
			if p:IsSuperAdmin() then
				p:SendLua( "chat.AddText(Color(255,255,255),\"Killed an Actor Cover File at\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"" .. sPath .. "\")" )
				return
			end
		end
	end
end, nil, "Deletes The Current Cover File" )
concommand_Add( "Node_KillCurrentBaseCoverFile", function( ply )
	if IsValid( ply ) && !ply:IsSuperAdmin() then
		ply:SendLua "chat.AddText(Color(128,255,128),\"Node_KillCurrentCoverFile: You are Not The Super Admin, Trying to Notify The Super Admin...\")"
		for _, p in player_Iterator() do
			if p:IsSuperAdmin() then
				p:SendLua( "chat.AddText(Color(255,255,255),\"A Non-Super Admin Player has Tried to Run Node_KillCurrentBaseCoverFile\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"Name: " .. ply:GetName() .. "\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"SteamID64: " .. ply:SteamID64() .. "\")" )
				ply:SendLua( "chat.AddText(Color(128,255,128),\"Notified The Super Admin ( " .. p:SteamID64() .. " | " .. p:GetName() " )\")" )
				return
			end
		end
		ply:SendLua "chat.AddText(Color(255,128,128),\"Failed to Notify The Super Admin\")"
		return
	end
	local sPath = "ActorCoverBase/" .. game.GetMap() .. ".json"
	if file.Exists( sPath, "DATA" ) then
		//TODO: Kill The Directory if There are No More Files Left?
		file.Delete( sPath )
		for _, p in player_Iterator() do
			if p:IsSuperAdmin() then
				p:SendLua( "chat.AddText(Color(255,255,255),\"Killed an Actor Cover Base File at\")" )
				p:SendLua( "chat.AddText(Color(255,255,255),\"" .. sPath .. "\")" )
				return
			end
		end
	end
end, nil, "Deletes The Current Base Cover File" )

if !__COVER_TABLE_LOADED__ then
	//Load Static Cover Nodes if They were Already Set
	if file.Exists( "ActorCover/" .. game.GetMap() .. ".json", "DATA" ) then
		local t = util.JSONToTable( file.Read( "ActorCover/" .. game.GetMap() .. ".json" ), true )
		//The Timer is Required. Dont Ask Why. It Just is. I have No Idea Why
		//Just Kidding I Do have an Idea Why It's Probably Just Some Loading Quirks
		timer.Simple( 0, function()
			for _, d in pairs( t ) do for _, d in ipairs( d ) do CreateStaticCover( d[ 1 ], d[ 2 ] ) end end
		end )
	elseif file.Exists( "ActorCoverBase/" .. game.GetMap() .. ".json", "DATA" ) then
		local t = util.JSONToTable( file.Read( "ActorCoverBase/" .. game.GetMap() .. ".json" ), true )
		//The Timer is Required. Dont Ask Why. It Just is. I have No Idea Why
		//Just Kidding I Do have an Idea Why It's Probably Just Some Loading Quirks
		timer.Simple( 0, function()
			for _, d in pairs( t ) do for _, d in ipairs( d ) do CreateStaticCover( d[ 1 ], d[ 2 ] ) end end
		end )
	end
	__COVER_TABLE_LOADED__ = true
end

//Save Static Cover Nodes
hook.Add( "Think", "ActorCover", function()
	if file.Exists( "ActorCover/" .. game.GetMap() .. ".json", "DATA" ) then
		local t = {}
		for i, d in pairs( __COVER_TABLE_STATIC__ ) do
			if d.m_bCreatedByMap then continue end //NodeCover
			local tbl = {}
			t[ i ] = tbl
			for Cover in pairs( d ) do table.insert( tbl, { Cover.m_Vector, Cover.m_vForward } ) end
		end
		file.Write( "ActorCover/" .. game.GetMap() .. ".json", util.TableToJSON( t ) )
	else file.CreateDir "ActorCover" file.Write( "ActorCover/" .. game.GetMap() .. ".json", "" ) end
end )
