local addonName, addon = ...
addon.addonTitle = GetAddOnMetadata(addonName, "Title")

local _G = _G
local animations = {}
local animationNum = 1
local texture, animationGroup, alpha1, scale1, scale2, rotation2
local EventFrame = CreateFrame("frame", "EventFrame")

local textures = {
    [[Interface\Cooldown\star4]], -- Default White
    [[Interface\AddOns\SnowfallKeyPressAnimation\Colors\lightbluestar4]], -- Light Blue
    [[Interface\AddOns\SnowfallKeyPressAnimation\Colors\darkbluestar4]],-- Dark Blue
    [[Interface\AddOns\SnowfallKeyPressAnimation\Colors\greenstar4]], -- Green
    [[Interface\AddOns\SnowfallKeyPressAnimation\Colors\purplestar4]], -- Purple
    [[Interface\AddOns\SnowfallKeyPressAnimation\Colors\pinkstar4]] -- Pink
}

local textureToASCII = {
    "White",
    "Light Blue",
    "Dark Blue",
    "Green",
    "Purple",
    "Pink"
}

local function UpdateAnimations()
    wipe(animations)
    animationNum = 1

    for i = 1, addon.db.profile.animationCount do
        local frame = CreateFrame("Frame")

        texture = frame:CreateTexture()

        texture:SetTexture(textures[addon.db.profile.style])

        texture:SetAlpha(0)
        texture:SetAllPoints()
        texture:SetBlendMode("ADD")
        animationGroup = texture:CreateAnimationGroup()

        alpha1 = animationGroup:CreateAnimation("Alpha")
        alpha1:SetToAlpha(1)
        alpha1:SetDuration(0)
        alpha1:SetOrder(1)

        scale1 = animationGroup:CreateAnimation("Scale")
        scale1:SetScale(1.7, 1.7)
        scale1:SetDuration(0)
        scale1:SetOrder(1)

        scale2 = animationGroup:CreateAnimation("Scale")
        scale2:SetScale(0, 0)
        scale2:SetDuration(0.25)
        scale2:SetOrder(2)

        rotation2 = animationGroup:CreateAnimation("Rotation")
        rotation2:SetDegrees(90)
        rotation2:SetDuration(0.25)
        rotation2:SetOrder(2)

        animations[i] = { frame = frame, animationGroup = animationGroup }
    end
end

addon.defaultSettings = {
    profile = {
        animationCount = 5,
        style = 1,
    }
}

addon.optionsTable = {
    name = addon.addonTitle,
    type = "group",
    args = {
        break1 = {
            order = 2,
            type = "header",
            name = "",
        },
        style = {
            order = 3,
            type = "select",
            name = "Style",
            values = textureToASCII,
            get = function()
                return addon.db.profile.style
            end,
            set = function(_, value)
                addon.db.profile.style = value
                UpdateAnimations()
            end,
        },
        animationsCount = {
            order = 4,
            name = "Count animations",
            type = "range",
            min = 3,
            max = 10,
            step = 1,
            get = function()
                return addon.db.profile.animationCount
            end,
            set = function(_, value)
                addon.db.profile.animationCount = value
                UpdateAnimations()
            end,
        },
    }
}

local function animate(button)
    local animation = animations[animationNum]
    local frame = animation.frame
    local _animationGroup = animation.animationGroup

    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(button:GetFrameLevel() + 10)
    frame:SetAllPoints(button)
    _animationGroup:Stop()
    _animationGroup:Play()
    animationNum = (animationNum % addon.db.profile.animationCount) + 1

    return true
end

local function configButton(name, command)
    local button = _G[name]

    if button ~= nil and not button.hooked then
        local key = GetBindingKey(command)

        if key then
            button:RegisterForClicks("AnyDown")
            SetOverrideBinding(button, true, key, 'CLICK ' .. button:GetName() .. ':LeftButton')
        end

        button.AnimateThis = animate
        SecureHandlerWrapScript(button, "OnClick", button, [[ control:CallMethod("AnimateThis", self) ]])

        button.hooked = true
    end
end

local function configDefaultUiPetBar()
    for i = 1, 10, 1 do
        local button_command = ("BONUSACTIONBUTTON%d"):format(i)
        local button_name = ("PetActionButton%d"):format(i)

        configButton(button_name, button_command)
    end
end

local function configBartenderPetBar()
    for i = 1, 10, 1 do
        local button_command = ("BONUSACTIONBUTTON%d"):format(i)
        local bt4_button_name = ("BT4PetButton%d"):format(i)

        configButton(bt4_button_name, button_command)
    end
end

local function configDefaultUiBarOne()
    for i = 1, 12, 1 do
        local button_command = ("ACTIONBUTTON%d"):format(i)
        local bt4_button_name = ("BT4Button%d"):format(i)

        configButton(bt4_button_name, button_command)
    end
end

local function configDefaultUiButtons()
    for i = 1, 12, 1 do
        local button_commands = {
            { ("ActionButton%d"):format(i), ("ACTIONBUTTON%d"):format(i) },
            { ("MultiBarBottomLeftButton%d"):format(i), ("MULTIACTIONBAR1BUTTON%d"):format(i) },
            { ("MultiBarBottomRightButton%d"):format(i), ("MULTIACTIONBAR2BUTTON%d"):format(i) },
            { ("MultiBarLeftButton%d"):format(i), ("MULTIACTIONBAR4BUTTON%d"):format(i) },
            { ("MultiBarRightButton%d"):format(i), ("MULTIACTIONBAR3BUTTON%d"):format(i) }
        }
        for j = 1, 5, 1 do
            configButton(button_commands[j][1], button_commands[j][2])
        end
    end
end

local function configBartenderButtons()
    for i = 13, 120, 1 do
        local button_command = "CLICK BT4Button" .. i .. ":LeftButton"
        local button_name = ("BT4Button%d"):format(i)

        configButton(button_name, button_command)
    end
end

local function configDominosButtons()
    for i = 1, 60, 1 do
        local button_command = "CLICK DominosActionButton" .. i .. ":HOTKEY"
        local button_name = ("DominosActionButton%d"):format(i)

        configButton(button_name, button_command)
    end
end

local function init()
    local bartender_loaded = IsAddOnLoaded("Bartender4")
    local dominos_loaded = IsAddOnLoaded("Dominos")

    if bartender_loaded and dominos_loaded then
        print("Bartender4 and Dominos loaded, stopping sKeyPress")
        return
    end

    if bartender_loaded then
        configDefaultUiBarOne()
        configBartenderButtons()
        configBartenderPetBar()
    elseif dominos_loaded then
        configDefaultUiButtons()
        configDefaultUiPetBar()
        configDominosButtons()
    else
        configDefaultUiButtons()
        configDefaultUiPetBar()
    end
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= addonName then return end

        addon.db = LibStub("AceDB-3.0"):New(addonName.."DB", addon.defaultSettings, true)
        addon.optionsTable.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db)

        LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, addon.optionsTable)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addon.addonTitle)
        LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 650, 500)

        UpdateAnimations()
        init()
    end
end

EventFrame:SetScript("OnEvent", OnEvent)
EventFrame:RegisterEvent("ADDON_LOADED")
