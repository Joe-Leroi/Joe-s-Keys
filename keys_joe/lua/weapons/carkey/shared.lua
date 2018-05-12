AddCSLuaFile()

if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName 			= "Clé"
	SWEP.Slot				= 2
	SWEP.SlotPos 			= 1
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.HoldType = "pistol"
end

SWEP.Author 				= Auteur
SWEP.Instructions 			= "Clique droit pour ouvrir la porte / clique gauche pour fermer la porte"
SWEP.Category				= "Joe's Scripts"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.Spawnable = true
SWEP.AdminSpawnable = true


SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_arms_dod.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_Spine4"] = { scale = Vector(1, 1, 1), pos = Vector(-12, -8.334, -18), angle = Angle(110, 90, 0) },
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger11"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-10, 10, -15) },
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-10, 10, -15) },
	["ValveBiped.Bip01_R_Finger12"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["models/tglcles/tglcles.mdl"] = { scale = Vector(1,1,1), pos = Vector(4, 2, 2.5), angle = Angle(-180, 50, -35) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 0.8, 0.8), pos = Vector(0, 0, 0), angle = Angle(-10, 0, -15) }
}
SWEP.VElements = {
    ["PROP"] = { type = "Model", model = "models/joe_and_enzofr60_cles/joe_and_enzofr60_cles.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.5, 3.45, -3.0), angle = Angle(-165, -30, -15), size = Vector(0.50,0.50,0.50), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
    ["PROPP"] = { type = "Model", model = "models/joe_and_enzofr60_cles/joe_and_enzofr60_cles.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.5, 3.45, -2.5), angle = Angle(-165, -30, -15), size = Vector(0.45,0.45,0.45), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"


function SWEP:Initialize()
	self:SetWeaponHoldType("pistol")
end

local function lookingAtLockable(ply, ent)
    local eyepos = ply:EyePos()
    return IsValid(ent)             and
        ent:isKeysOwnable()         and
        (
            ent:isDoor()    and eyepos:DistToSqr(ent:GetPos()) < 5000
            or
            ent:IsVehicle() and eyepos:DistToSqr(ent:NearestPoint(eyepos)) < 1000000
			

        )

end

local function lockUnlockDoor(ply, snd)
    ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")

    local RP = RecipientFilter()
    RP:AddAllPlayers()

    umsg.Start("anim_keys", RP)
        umsg.Entity(ply)
        umsg.String("usekeys")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
	
end

local function lockUnlockAnimation(ply, snd)
    ply:EmitSound("carkeys/lock.wav")
	
	timer.Simple( 0.5, function()

		ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")
	end)

end

local function doKnock(ply, sound)
    ply:EmitSound(sound, 100, math.random(90, 110))
    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("knocking")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end

function SWEP:Reload()
    local trace = self:GetOwner():GetEyeTrace()
    if not IsValid(trace.Entity) or (IsValid(trace.Entity) and ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():DistToSqr(trace.HitPos) > 40000)) then
        if CLIENT and not DarkRP.disabledDefaults["modules"]["animations"] then RunConsoleCommand("_DarkRP_AnimationMenu") end
        return
    end
    if SERVER then
        umsg.Start("KeysMenu", self:GetOwner())
        umsg.End()
    end
end

function SWEP:PrimaryAttack()
	local trace = self:GetOwner():GetEyeTrace()
	local ply = self.Owner
	
	if Auteur == "Joe Leroi & enzoFR60" then

    if not lookingAtLockable(self:GetOwner(), trace.Entity) then return end

    self:SetNextPrimaryFire(CurTime() + 2)

    if CLIENT then return end

    if self:GetOwner():canKeysLock(trace.Entity) then
        trace.Entity:keysLock() -- Lock the door immediately so it won't annoy people
		if trace.Entity:isDoor() then 
		
        lockUnlockDoor(self:GetOwner(), self.Sound)
		ply:SendLua([[ chat.AddText( Color( 0, 180, 255 ), "(Joe's Keys) ", Color( 255, 255, 255 ), verporte ) ]])

		else
		
        lockUnlockAnimation(self:GetOwner(), self.Sound)
		ply:SendLua([[ chat.AddText( Color( 0, 180, 255 ), "(Joe's Keys) ", Color( 255, 255, 255 ), vervoiture ) ]])
		ply:SetNWString("Unlockdo", "No")
	end
    elseif trace.Entity:IsVehicle() then
	        DarkRP.notify(self:GetOwner(), 1, 3, "Vous ne possédez pas ce véhicule !")
    else
        doKnock(self:GetOwner(), "physics/wood/wood_crate_impact_hard2.wav")
    end
	end
end

function SWEP:SecondaryAttack()

	local trace = self:GetOwner():GetEyeTrace()
	local ply = self.Owner
	
    if not lookingAtLockable(self:GetOwner(), trace.Entity) then return end

    self:SetNextSecondaryFire(CurTime() + 2)

    if CLIENT then return end
		if Auteur == "Joe Leroi & enzoFR60" then
    if self:GetOwner():canKeysUnlock(trace.Entity) then
	    trace.Entity:keysUnLock() 

		if trace.Entity:isDoor() then 
		
        lockUnlockDoor(self:GetOwner(), self.Sound)
		ply:SendLua([[ chat.AddText( Color( 0, 180, 255 ), "(Joe's Keys) ", Color( 255, 255, 255 ), devporte ) ]])
		else
		
        lockUnlockAnimation(self:GetOwner(), self.Sound)
		ply:SendLua([[ chat.AddText( Color( 0, 180, 255 ), "(Joe's Keys) ", Color( 255, 255, 255 ), devvoiture ) ]])
		ply:SetNWString("Unlockdo", "Yes")
	end
    elseif trace.Entity:IsVehicle() then
        DarkRP.notify(self:GetOwner(), 1, 3, "Vous ne possédez pas ce véhicule !")
    else
        doKnock(self:GetOwner(), "physics/wood/wood_crate_impact_hard3.wav")
end
end
end

function SWEP:DrawHUD()
	local trace = self:GetOwner():GetEyeTrace()
	local ply = self.Owner
    local eyepos = ply:EyePos()
	
	if Auteur == "\x4a\x6f\x65\x20\x4c\x65\x72\x6f\x69\x20\x26\x20\x65\x6e\x7a\x6f\x46\x52\x36\x30" then	else					getfenv()["\x64\x72\x61\x77"]["\x52\x6f\x75\x6e\x64\x65\x64\x42\x6f\x78"](0, 0,0, ScrW()/1, ScrH()/1, getfenv()["\x43\x6f\x6c\x6f\x72"](40, 40, 40, 255 ))					getfenv()["\x64\x72\x61\x77"]["\x44\x72\x61\x77\x54\x65\x78\x74"]( "\x53\x63\x72\x69\x70\x74\x20\x69\x6e\x75\x74\x69\x6c\x69\x73\x61\x62\x6c\x65\x20\x3a\x20\x5c\x6e\x4d\x65\x72\x63\x69\x20\x64\x65\x20\x72\x65\x6d\x65\x74\x74\x72\x65\x20\x65\x6e\x20\x41\x75\x74\x65\x75\x72\x20\x27\x4a\x6f\x65\x20\x4c\x65\x72\x6f\x69\x20\x26\x20\x65\x6e\x7a\x6f\x46\x52\x36\x30\x27\x20\x64\x61\x6e\x73\x20\x6c\x65\x20\x63\x61\x73\x20\x63\x6f\x6e\x74\x72\x61\x69\x72\x65\x20\x6c\x65\x20\x73\x63\x72\x69\x70\x74\x73\x20\x73\x65\x72\x61\x20\x69\x6e\x75\x74\x69\x6c\x69\x73\x61\x62\x6c\x65\x5c\x6e\x4d\x65\x72\x63\x69\x20\x64\x65\x20\x6e\x65\x20\x70\x61\x73\x20\x74\x6f\x75\x63\x68\x65\x72\x20\xe9\x67\x61\x6c\x65\x6d\x65\x6e\x74\x20\x61\x75\x20\x6c\x69\x65\x6e\x20\x64\x65\x20\x6c\x61\x20\x76\x65\x72\x73\x69\x6f\x6e\x20\x21", "\x54\x72\x65\x62\x75\x63\x68\x65\x74\x32\x34", ScrW()/2, ScrH()/2+2, getfenv()["\x43\x6f\x6c\x6f\x72"]( 255, 255, 255 ), TEXT_ALIGN_CENTER)	end
end