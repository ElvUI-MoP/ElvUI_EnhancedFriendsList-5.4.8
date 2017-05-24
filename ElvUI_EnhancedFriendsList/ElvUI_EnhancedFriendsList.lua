local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0");
local addonName = ...;
local LSM = LibStub("LibSharedMedia-3.0", true)

local pairs = pairs
local format = format

local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
local LEVEL = LEVEL
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local EnhancedOnline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Online"
local EnhancedOffline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Offline"
local EnhancedAfk = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Away"
local EnhancedDnD = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-DnD"

local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	["enhancedTextures"] = true,
	["enhancedName"] = true,
	["enhancedZone"] = false,
	["hideClass"] = true,
	["levelColor"] = false,
	["shortLevel"] = false,
	["sameZone"] = true,
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE"
};

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName);
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 51.1,
		type = "group",
		name = ColorizeSettingName(L["Enhanced Friends List"]),
		get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
		set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Enhanced Friends List"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					enhancedTextures = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Status"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedTextures = value; EFL:EnhanceFriends() EFL:FriendDropdownUpdate() end
					},
					enhancedName = {
						order = 2,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value; EFL:EnhanceFriends() end
					},
					enhancedZone = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value; EFL:EnhanceFriends() end
					},
					hideClass = {
						order = 4,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value; EFL:EnhanceFriends() end
					},
					levelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value; EFL:EnhanceFriends() end
					},
					shortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value; EFL:EnhanceFriends() end
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone Color"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value; EFL:EnhanceFriends() end
					}
				}
			},
			nameFont = {
				order = 3,
				type = "group",
				name = L["Name Text Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value; EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value; EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value; EFL:EnhanceFriends() end
					}
				}
			},
			zoneFont = {
				order = 4,
				type = "group",
				name = L["Zone Text Font"],
				guiInline = true,
				args = {
					zoneFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value; EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value; EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						set = function(info, value) E.db.enhanceFriendsList.zoneFontOutline = value; EFL:EnhanceFriends() end
					}
				}
			}
		}
	}
end

local function ClassColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end
	local color = RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

function EFL:EnhanceFriends()
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local playerZone = GetRealZoneText()

	for i = 1, numButtons do
		local Cooperate = false
		local button = buttons[i]
		local nameText, nameColor, infoText, broadcastText

		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			local name, level, class, area, connected, status = GetFriendInfo(button.id)
			if not name then return end

			broadcastText = nil
			if connected then
				if status == "" then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOnline or FRIENDS_TEXTURE_ONLINE)
				elseif status == CHAT_FLAG_AFK then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedAfk or FRIENDS_TEXTURE_AFK)
				elseif status == CHAT_FLAG_DND then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedDnD or FRIENDS_TEXTURE_DND)
				end
				local diff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or "|cFFFFFFFF"
				local shortLevel = E.db.enhanceFriendsList.shortLevel and L["SHORT_LEVEL"] or LEVEL

				if E.db.enhanceFriendsList.enhancedName then
					if E.db.enhanceFriendsList.hideClass then
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s%s - %s %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
						else
							nameText = format("%s%s - %s %s", ClassColorCode(class), name, shortLevel, level)
						end
					else
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s%s - %s %s%s|r %s%s", ClassColorCode(class), name, shortLevel, diff, level, ClassColorCode(class), class)
						else
							nameText = format("%s%s - %s %s %s", ClassColorCode(class), name, shortLevel, level, class)
						end
					end
				else
					if E.db.enhanceFriendsList.hideClass then
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s, %s %s%s|r", name, shortLevel, diff, level)
						else
							nameText = format("%s, %s %s", name, shortLevel, level)
						end

					else
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s, %s %s%s|r %s", name, shortLevel, diff, level, class)
						else
							nameText = format("%s, %s %s %s", name, shortLevel, level, class)
						end
					end
				end
				nameColor = FRIENDS_WOW_NAME_COLOR
				Cooperate = true
			else
				button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOffline or FRIENDS_TEXTURE_OFFLINE)
				nameText = name
				nameColor = FRIENDS_GRAY_COLOR
			end
			infoText = area
		end

		if nameText then
			button.name:SetText(nameText)
			button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
			button.info:SetText(infoText)
			button.info:SetTextColor(0.49, 0.52, 0.54)
			if Cooperate then
				if E.db.enhanceFriendsList.enhancedZone then
					if E.db.enhanceFriendsList.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(0, 1, 0)
						else
							button.info:SetTextColor(1, 0.96, 0.45)
						end
					else
						button.info:SetTextColor(1, 0.96, 0.45)
					end
				else
					if E.db.enhanceFriendsList.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(0, 1, 0)
						else
							button.info:SetTextColor(0.49, 0.52, 0.54)
						end
					else
						button.info:SetTextColor(0.49, 0.52, 0.54)
					end
				end
			end
			button.name:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.nameFont), E.db.enhanceFriendsList.nameFontSize, E.db.enhanceFriendsList.nameFontOutline)
			button.info:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.zoneFont), E.db.enhanceFriendsList.zoneFontSize, E.db.enhanceFriendsList.zoneFontOutline)
		end
	end
end

function EFL:FriendDropdownUpdate()
	local status
	if IsChatAFK() then
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedAfk or FRIENDS_TEXTURE_AFK
	elseif IsChatDND() then
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedDnD or FRIENDS_TEXTURE_DND
	else
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedOnline or FRIENDS_TEXTURE_ONLINE
	end

	FriendsFrameStatusDropDownStatus:SetTexture(status)
end

function EFL:FriendListUpdate()
	hooksecurefunc("HybridScrollFrame_Update", EFL.EnhanceFriends)
	hooksecurefunc("FriendsFrame_UpdateFriends", EFL.EnhanceFriends)
	hooksecurefunc("FriendsFrameStatusDropDown_Update", EFL.FriendDropdownUpdate)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions);

	EFL:FriendListUpdate()
end

E:RegisterModule(EFL:GetName())