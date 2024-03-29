scaleformUV = setmetatable({}, scaleformUV)
scaleformUV.__index = scaleformUV
scaleformUV.__call = function()
    return "scaleformUV"
end

---@class scaleformUV
---@field public CallFunction fun(self:scaleformUV, theFunction:string, returndata?:boolean, ...:any):nil|number
---@field public Dispose fun(self:scaleformUV):nil
---@field public IsLoaded fun(self:scaleformUV):boolean
---@field public IsValid fun(self:scaleformUV):boolean
---@field public Render2D fun(self:scaleformUV):nil
---@field public Render2DNormal fun(self:scaleformUV, x:number, y:number, width:number, height:number):nil
---@field public Render3D fun(self:scaleformUV, x:number, y:number, z:number, rx:number, ry:number, rz:number, scale:number):nil
---@field public Render3DAdditive fun(self:scaleformUV, x:number, y:number, z:number, rx:number, ry:number, rz:number, scale:number):nil
---@field public handle number

---Create a new scaleform instance
---@param Name string
---@return scaleformUV
function scaleformUV.Request(Name)
    assert(Name ~= "string",
        "^1ScaleformUI [ERROR]: ^7The first argument must be a string, not a ^1" .. type(Name) .. "^7.")
    local _scaleform = {
        name = Name,
        handle = RequestScaleformMovie(Name)
    }
    return setmetatable(_scaleform, scaleformUV)
end

---Create a new scaleform instance
---@param Name string
---@return scaleformUV
function scaleformUV.RequestWidescreen(Name)
    assert(Name ~= "string",
        "^1ScaleformUI [ERROR]: ^7The first argument must be a string, not a ^1" .. type(Name) .. "^7.")
    local _scaleform = {
        name = Name,
        handle = RequestScaleformMovieInstance(Name)
    }
    return setmetatable(_scaleform, scaleformUV)
end

---Call a function on the scaleform
---@param theFunction string -- The name of the function to call
---@param returndata? boolean -- If true, returns the return value of the function
---@vararg any -- The arguments to pass to the function
---@return nil|number -- If returndata is true, returns the return value of the function
function scaleformUV:CallFunction(theFunction, returndata, ...)
    BeginScaleformMovieMethod(self.handle, theFunction)
    local arg = { ... }
    if arg ~= nil then
        for i = 1, #arg do
            local sType = type(arg[i])
            if sType == "boolean" then
                ScaleformMovieMethodAddParamBool(arg[i])
            elseif sType == "number" then
                if math.type(arg[i]) == "integer" then
                    ScaleformMovieMethodAddParamInt(arg[i])
                else
                    ScaleformMovieMethodAddParamFloat(arg[i])
                end
            elseif sType == "table" then
                local type = arg[i].type
                if type == "label" then
                    local label = arg[i].data
                    BeginTextCommandScaleformString(label)
                    EndTextCommandScaleformString() -- END_TEXT_COMMAND_SCALEFORM_STRING
                elseif type == "literal" then
                    local label = arg[i].data
                    ScaleformMovieMethodAddParamTextureNameString_2(label) -- SCALEFORM_MOVIE_METHOD_ADD_PARAM_LITERAL_STRING
                else
                    assert(false, "^1ScaleformUI [ERROR]: ^7Unknown type ^1" .. type .. "^7.")
                end
            elseif sType == "string" then
                if arg[i]:find("^desc_{") or arg[i]:find("^menu_lobby_desc_{") or arg[i]:find("^PauseMenu_") or arg[i]:find("^menu_pause_playerTab{") then
                    BeginTextCommandScaleformString(arg[i])
                    EndTextCommandScaleformString_2()
                else
                    ScaleformMovieMethodAddParamTextureNameString(arg[i])
                end
            end
        end
    end

    if not returndata then
        EndScaleformMovieMethod()
    else
        return EndScaleformMovieMethodReturnValue()
    end
end

---Render the scaleform full screen
function scaleformUV:Render2D()
    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
end

---Render the scaleform in a rectangle
function scaleformUV:Render2DNormal(x, y, width, height)
    DrawScaleformMovie(self.handle, x, y, width, height, 255, 255, 255, 255, 0)
end

---Render the scaleform in a rectangle with screen space coordinates
function scaleformUV:Render2DScreenSpace(locx, locy, sizex, sizey)
    local Width, Height = GetScreenResolution()
    local x = locy / Width
    local y = locx / Height
    local width = sizex / Width
    local height = sizey / Height
    DrawScaleformMovie(self.handle, x + (width / 2.0), y + (height / 2.0), width, height, 255, 255, 255, 255, 0)
end

---Render the scaleform in 3D space
function scaleformUV:Render3D(x, y, z, rx, ry, rz, scalex, scaley, scalez)
    DrawScaleformMovie_3dSolid(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

---Render the scaleform in 3D space with additive blending
function scaleformUV:Render3DAdditive(x, y, z, rx, ry, rz, scalex, scaley, scalez)
    DrawScaleformMovie_3d(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

---Disposes the scaleform
function scaleformUV:Dispose()
    SetScaleformMovieAsNoLongerNeeded(self.handle)
    self = nil
end

---Returns true if the scaleform is valid
---@return boolean
function scaleformUV:IsValid()
    return self and true or false
end

---Returns true if the scaleform is loaded
---@return boolean
function scaleformUV:IsLoaded()
    return HasScaleformMovieLoaded(self.handle)
end








MenuPool = setmetatable({}, MenuPool)
MenuPool.__index = MenuPool
MenuPool.__call = function()
    return "MenuPool"
end

---@class MenuPool
---@field Menus table<UIMenu>
---@field PauseMenus table
---@field ableToDraw boolean

---Create a new MenuPool
---@return table
function MenuPool.New()
    local _MenuPool = {
        Menus = {} --[[@type table<UIMenu>]],
        PauseMenus = {},
        ableToDraw = false
    }
    return setmetatable(_MenuPool, MenuPool)
end

--- Add a new Submenu
---@param subMenu UIMenu
---@param text string
---@param description string
---@param keepPosition boolean
---@param keepBanner boolean
---@return UIMenu
function MenuPool:AddSubMenu(subMenu, text, description, keepPosition, keepBanner)
    assert(subMenu ~= "UIMenu",
        "^1ScaleformUI [ERROR]: ^7The first argument must be a UIMenu, not a ^1" .. type(subMenu) .. "^7.")

    ---@diagnostic disable-next-line: missing-parameter
    local item = UIMenuItem.New(tostring(text), description or "")
    subMenu:AddItem(item)
    local _subMenu
    if keepPosition then
        _subMenu = UIMenu.New(subMenu.Title, text, subMenu.Position.x, subMenu.Position.y, subMenu.Glare,
            subMenu.TxtDictionary,
            subMenu.TxtName, subMenu.AlternativeTitle)
    else
        _subMenu = UIMenu.New(subMenu.Title, text)
    end
    if keepBanner then
        if subMenu.Logo ~= nil then
            _subMenu.Logo = subMenu.Logo
        else
            _subMenu.Logo = nil
            _subMenu.Banner = subMenu.Banner
        end
    end

    _subMenu.Glare = subMenu.Glare
    _subMenu.Settings.MouseControlsEnabled = subMenu.Settings.MouseControlsEnabled
    _subMenu.Settings.MouseEdgeEnabled = subMenu.Settings.MouseEdgeEnabled
    _subMenu:MaxItemsOnScreen(subMenu:MaxItemsOnScreen())
    self:Add(_subMenu)
    subMenu:BindMenuToItem(_subMenu, item)
    return _subMenu
end

---Add
---@param Menu table
function MenuPool:Add(Menu)
    if Menu() == "UIMenu" then
        Menu.ParentPool = self
        self.Menus[#self.Menus + 1] = Menu
    end
end

function MenuPool:AddPauseMenu(Menu)
    if Menu() == "PauseMenu" or Menu() == "LobbyMenu" then
        Menu.ParentPool = self;
        table.insert(self.PauseMenus, Menu)
    end
end

---Toggle whether to rotate the camera when the mouse is at the edge of the screen
---@param bool boolean
function MenuPool:MouseEdgeEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MouseEdgeEnabled = ToBool(bool)
        end
    end
end

---Toggle whether to disable controls when a menu is open
---@param bool boolean
function MenuPool:ControlDisablingEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.ControlDisablingEnabled = ToBool(bool)
        end
    end
end

---Reset the cursors position when a menu is opened
---@param bool boolean
function MenuPool:ResetCursorOnOpen(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.ResetCursorOnOpen = ToBool(bool)
        end
    end
end

---MultilineFormats
---@param bool boolean
function MenuPool:MultilineFormats(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MultilineFormats = ToBool(bool)
        end
    end
end

---Audio
---@param Attribute number
---@param Setting table
function MenuPool:Audio(Attribute, Setting)
    if Attribute ~= nil and Setting ~= nil then
        for _, Menu in pairs(self.Menus) do
            if Menu.Settings.Audio[Attribute] then
                Menu.Settings.Audio[Attribute] = Setting
            end
        end
    end
end

---WidthOffset
---@param offset number
function MenuPool:WidthOffset(offset)
    if tonumber(offset) then
        for _, Menu in pairs(self.Menus) do
            Menu:SetMenuWidthOffset(tonumber(offset))
        end
    end
end

---CounterPreText
---@param preText string
function MenuPool:CounterPreText(preText)
    if preText ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.PageCounter.PreText = tostring(preText)
        end
    end
end

---DisableInstructionalButtons
---@param bool boolean
function MenuPool:DisableInstructionalButtons(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.InstructionalButtons = ToBool(bool)
        end
    end
end

---MouseControlsEnabled
---@param bool boolean
function MenuPool:MouseControlsEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MouseControlsEnabled = ToBool(bool)
        end
    end
end

---RefreshIndex
function MenuPool:RefreshIndex()
    for _, Menu in pairs(self.Menus) do
        Menu:RefreshIndex()
    end
end

function MenuPool:ProcessMenus(bool)
    self.ableToDraw = bool
    Citizen.CreateThread(function()
        while self.ableToDraw do
            Citizen.Wait(0)
            self:ProcessControl()
            self:Draw()
        end
        return
    end)
end

---ProcessControl
function MenuPool:ProcessControl()
    for _, Menu in pairs(self.Menus) do
        if Menu:Visible() then
            Menu:ProcessControl()
            Menu:ProcessMouse()
        end
    end

    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            Menu:ProcessControl()
            Menu:ProcessMouse()
        end
    end
end

---Draw
function MenuPool:Draw()
    for _, Menu in pairs(self.Menus) do
        if Menu:Visible() then
            Menu:Draw()
        end
    end
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            Menu:Draw()
        end
    end
end

---IsAnyMenuOpen
function MenuPool:IsAnyMenuOpen()
    for _, Menu in pairs(self.Menus) do
        if #Menu.Children > 0 then
            for k, v in pairs(Menu.Children) do
                if v:Visible() then
                    return true
                end
            end
        end
        if Menu:Visible() then
            return true
        end
    end
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            return true
        end
    end
    return false
end

function MenuPool:IsAnyPauseMenuOpen()
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            return true
        end
    end
    return false
end

---CloseAllMenus
function MenuPool:CloseAllMenus()
    for i=1, #self.Menus do
        local menu = self.Menus[#self.Menus + 1 - i]
        if menu:Visible() then
            menu:GoBack(false)
        end
    end
    ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
    if ScaleformUI.Scaleforms.InstructionalButtons:Enabled() then
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
    end
end

---SetBannerSprite
---@param sprite Sprite
---@see Sprite
function MenuPool:SetBannerSprite(sprite)
    if sprite() == "Sprite" then
        for _, Menu in pairs(self.Menus) do
            Menu:SetBannerSprite(sprite)
        end
    end
end

---SetBannerRectangle
---@param Rectangle table
function MenuPool:SetBannerRectangle(Rectangle)
    if Rectangle() == "Rectangle" then
        for _, Menu in pairs(self.Menus) do
            Menu:SetBannerRectangle(Rectangle)
        end
    end
end

---Will flush all menus from the pool
function MenuPool:FlushMenus()
    local countMenu = #self.Menus
    for i = 0, countMenu do
        if self.Menus[i] ~= nil and self.Menus[i]:Visible() then
            self.Menus[i]:Visible(false)
        end
        self.Menus[i] = nil
    end
end

---Will flush all pause menus from the pool
function MenuPool:FlushPauseMenus()
    local countPause = #self.PauseMenus
    for i = 0, countPause do
        if self.PauseMenus[i] ~= nil and self.PauseMenus[i]:Visible() then
            self.PauseMenus[i]:Visible(false)
        end
        self.PauseMenus[i] = nil
    end
end

---Will flush all menus and pause menus from the pool
function MenuPool:FlushAllMenus()
    local countMenu = #self.Menus
    local countPause = #self.PauseMenus
    for i = 0, countMenu do
        if self.Menus[i] ~= nil and self.Menus[i]:Visible() then
            self.Menus[i]:Visible(false)
        end
        self.Menus[i] = nil
    end
    for i = 0, countPause do
        if self.PauseMenus[i] ~= nil and self.PauseMenus[i]:Visible() then
            self.PauseMenus[i]:Visible(false)
        end
        self.PauseMenus[i] = nil
    end
end
UIMenu = setmetatable({}, UIMenu)
UIMenu.__index = UIMenu
UIMenu.__call = function()
    return "UIMenu"
end

---@class UIMenu
---@field public Title string -- Sets the menu title
---@field public Subtitle string -- Sets the menu subtitle
---@field public AlternativeTitle boolean -- Enable or disable the alternative title (default: false)
---@field public Position vector2 -- Sets the menu position (default: { X = 0.0, Y = 0.0 })
---@field public Pagination table -- Menu pagination settings (default: { Min = 0, Max = 7, Total = 7 })
---@field public Banner table -- Menu banner settings [Setting not fully understood or possibly not used]
---@field public Extra table -- {}
---@field public Description table -- {}
---@field public Items table<UIMenuItem> -- {}
---@field public Windows table -- {}
---@field public Children table -- {}
---@field public Glare boolean -- Sets if the glare animation is enabled or disabled (default: false)
---@field public Controls table -- { Back = { Enabled = true }, Select = { Enabled = true }, Up = { Enabled = true }, Down = { Enabled = true }, Left = { Enabled = true }, Right = { Enabled = true } }
---@field public TxtDictionary string -- Texture dictionary for the menu banner background (default: commonmenu)
---@field public TxtName string -- Texture name for the menu banner background (default: interaction_bgd)
---@field public Logo Sprite -- nil
---@field public Settings table -- Defines the menus settings
---@field public MaxItemsOnScreen fun(self: UIMenu, max: number?):number -- Maximum number of items that can be displayed (default: 7)
---@field public AddItem fun(self: UIMenu, item: UIMenuItem)
---@field public SetParentMenu fun(self: UIMenu, menu: UIMenu)
---@field public OnIndexChange fun(menu: UIMenu, newindex: number)
---@field public OnListChange fun(menu: UIMenu, list: UIMenuListItem, newindex: number)
---@field public OnSliderChange fun(menu: UIMenu, slider: UIMenuSliderItem, newindex: number)
---@field public OnProgressChange fun(menu: UIMenu, progress: UIMenuProgressItem, newindex: number)
---@field public OnCheckboxChange fun(menu: UIMenu, checkbox: UIMenuCheckboxItem, checked: boolean)
---@field public OnListSelect fun(menu: UIMenu, item: UIMenuItem, index: number)
---@field public OnSliderSelect fun(menu: UIMenu, item: UIMenuItem, index: number)
---@field public OnStatsSelect fun(menu: UIMenu, item: UIMenuItem, index: number)
---@field public OnItemSelect fun(menu: UIMenu, item: UIMenuItem, checked: boolean)
---@field public OnMenuChanged fun(oldmenu: UIMenu, newmenu: UIMenu, change: any)
---@field public BuildAsync fun(self: UIMenu, enabled: boolean?):boolean -- If the menu should be built async (default: false)
---@field public AnimationEnabled fun(self: UIMenu, enabled: boolean?):boolean -- If the menu animation is enabled or disabled (default: true)
---@field public AnimationType fun(self: UIMenu, type: MenuAnimationType?):MenuAnimationType -- Animation type for the menu (default: MenuAnimationType.LINEAR)
---@field public BuildingAnimation fun(self: UIMenu, type: MenuBuildingAnimation?):MenuBuildingAnimation -- Build animation type for the menu (default: MenuBuildingAnimation.LEFT)
---@field public BindMenuToItem fun(self: UIMenu, menu: UIMenu, item: UIMenuItem) -- Binds a menu to an item
---@field public Visible fun(self: UIMenu, visible: boolean?):boolean -- If the menu is visible or not (default: false)
---@field private counterColor Colours -- Set the counter color (default: Colours.HUD_COLOUR_FREEMODE)
---@field private enableAnimation boolean -- Enable or disable the menu animation (default: true)
---@field private animationType MenuAnimationType -- Sets the menu animation type (default: MenuAnimationType.LINEAR)
---@field private buildingAnimation MenuBuildingAnimation -- Sets the menu building animation type (default: MenuBuildingAnimation.NONE)
---@field private descFont table -- { "$Font2", 0 }

---Creates a new UIMenu.
---@param title string -- Menu title
---@param subTitle string -- Menu subtitle
---@param x number? -- Menu Offset X position
---@param y number? -- Menu Offset Y position
---@param glare boolean? -- Menu glare effect
---@param txtDictionary string? -- Custom texture dictionary for the menu banner background (default: commonmenu)
---@param txtName string? -- Custom texture name for the menu banner background (default: interaction_bgd)
---@param alternativeTitleStyle boolean? -- Use alternative title style (default: false)
function UIMenu.New(title, subTitle, x, y, glare, txtDictionary, txtName, alternativeTitleStyle)
    local X, Y = tonumber(x) or 0, tonumber(y) or 0
    if title ~= nil then
        title = tostring(title) or ""
    else
        title = ""
    end
    if subTitle ~= nil then
        subTitle = tostring(subTitle) or ""
    else
        subTitle = ""
    end
    if txtDictionary ~= nil then
        txtDictionary = tostring(txtDictionary) or "commonmenu"
    else
        txtDictionary = "commonmenu"
    end
    if txtName ~= nil then
        txtName = tostring(txtName) or "interaction_bgd"
    else
        txtName = "interaction_bgd"
    end
    if alternativeTitleStyle == nil then
        alternativeTitleStyle = false
    end
    local _UIMenu = {
        Title = title,
        Subtitle = subTitle,
        AlternativeTitle = alternativeTitleStyle,
        counterColor = Colours.HUD_COLOUR_FREEMODE,
        Position = { x = X, y = Y },
        Pagination = { Min = 0, Max = 7, Total = 7 },
        enableAnimation = true,
        animationType = MenuAnimationType.LINEAR,
        buildingAnimation = MenuBuildingAnimation.NONE,
        descFont = { "$Font2", 0 },
        Extra = {},
        Description = {},
        Items = {},
        Windows = {},
        Children = {},
        TxtDictionary = txtDictionary,
        TxtName = txtName,
        Glare = glare or false,
        Logo = nil,
        _keyboard = false,
        _changed = false,
        _maxItem = 7,
        _menuGlare = 0,
        _canBuild = true,
        _buildAsync = true,
        _isBuilding = false,
        _time = 0,
        _times = 0,
        _delay = 100,
        _delayBeforeOverflow = 350,
        _timeBeforeOverflow = 0,
        _canHe = true,
        _scaledWidth = (720 * GetAspectRatio(false)),
        Controls = {
            Back = {
                Enabled = true,
            },
            Select = {
                Enabled = true,
            },
            Left = {
                Enabled = true,
            },
            Right = {
                Enabled = true,
            },
            Up = {
                Enabled = true,
            },
            Down = {
                Enabled = true,
            },
        },
        ParentMenu = nil,
        ParentPool = nil,
        ParentItem = nil,
        _Visible = false,
        ActiveItem = 0,
        Dirty = false,
        ReDraw = true,
        InstructionalButtons = {
            InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 176, 176, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1)
        },
        OnIndexChange = function(menu, newindex)
        end,
        OnListChange = function(menu, list, newindex)
        end,
        OnSliderChange = function(menu, slider, newindex)
        end,
        OnProgressChange = function(menu, progress, newindex)
        end,
        OnCheckboxChange = function(menu, item, checked)
        end,
        OnListSelect = function(menu, list, index)
        end,
        OnSliderSelect = function(menu, slider, index)
        end,
        OnProgressSelect = function(menu, progress, index)
        end,
        OnStatsSelect = function(menu, progress, index)
        end,
        OnItemSelect = function(menu, item, index)
        end,
        OnMenuChanged = function(oldmenu, newmenu, change)
        end,
        OnColorPanelChanged = function(menu, item, index)
        end,
        OnPercentagePanelChanged = function(menu, item, index)
        end,
        OnGridPanelChanged = function(menu, item, index)
        end,
        Settings = {
            InstructionalButtons = true,
            MultilineFormats = true,
            ScaleWithSafezone = true,
            ResetCursorOnOpen = true,
            MouseControlsEnabled = true,
            MouseEdgeEnabled = true,
            ControlDisablingEnabled = true,
            Audio = {
                Library = "HUD_FRONTEND_DEFAULT_SOUNDSET",
                UpDown = "NAV_UP_DOWN",
                LeftRight = "NAV_LEFT_RIGHT",
                Select = "SELECT",
                Back = "BACK",
                Error = "ERROR",
            },
            EnabledControls = {
                Controller = {
                    { 0, 2 },  -- Look Up and Down
                    { 0, 1 },  -- Look Left and Right
                    { 0, 25 }, -- Aim
                    { 0, 24 }, -- Attack
                    { 0, 71 }, -- Accelerate Vehicle
                    { 0, 72 }, -- Vehicle Brake
                    { 0, 30 }, -- Move Left and Right
                    { 0, 31 }, -- Move Up and Down
                    { 0, 59 }, -- Move Vehicle Left and Right
                    { 0, 75 }, -- Exit Vehicle
                },
                Keyboard = {
                    { 0, 2 },   -- Look Up and Down
                    { 0, 1 },   -- Look Left and Right
                    { 0, 201 }, -- Select
                    { 0, 195 }, -- X axis
                    { 0, 196 }, -- Y axis
                    { 0, 187 }, -- Down
                    { 0, 188 }, -- Up
                    { 0, 189 }, -- Left
                    { 0, 190 }, -- Right
                    { 0, 202 }, -- Back
                    { 0, 217 }, -- Select
                    { 0, 242 }, -- Scroll down
                    { 0, 241 }, -- Scroll up
                    { 0, 239 }, -- Cursor X
                    { 0, 240 }, -- Cursor Y
                    { 0, 237 },
                    { 0, 238 },
                    { 0, 31 }, -- Move Up and Down
                    { 0, 30 }, -- Move Left and Right
                    { 0, 21 }, -- Sprint
                    { 0, 22 }, -- Jump
                    { 0, 23 }, -- Enter
                    { 0, 75 }, -- Exit Vehicle
                    { 0, 71 }, -- Accelerate Vehicle
                    { 0, 72 }, -- Vehicle Brake
                    { 0, 59 }, -- Move Vehicle Left and Right
                    { 0, 89 }, -- Fly Yaw Left
                    { 0, 9 },  -- Fly Left and Right
                    { 0, 8 },  -- Fly Up and Down
                    { 0, 90 }, -- Fly Yaw Right
                    { 0, 76 }, -- Vehicle Handbrake
                },
            },
        }
    }

    if subTitle ~= "" and subTitle ~= nil then
        _UIMenu.Subtitle = subTitle
    end
    if (_UIMenu._menuGlare == 0) then
        _UIMenu._menuGlare = scaleformUV.Request("mp_menu_glare")
    end
    return setmetatable(_UIMenu, UIMenu)
end

function UIMenu:Title(title)
    if title == nil then
        return self.Title
    else
        self.Title = title
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_TITLE_SUBTITLE", false, self.Title, self.Subtitle,
                self.alternativeTitle)
        end
    end
end

function UIMenu:DescriptionFont(fontTable)
    if fontTable == nil then
        return self.descFont
    else
        self.descFont = fontTable
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_DESC_FONT", false, self.descFont[1], self.descFont[2])
        end
    end
end

function UIMenu:Subtitle(sub)
    if sub == nil then
        return self.Subtitle
    else
        self.Subtitle = sub
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_TITLE_SUBTITLE", false, self.Title, self.Subtitle,
                self.alternativeTitle)
        end
    end
end

function UIMenu:CounterColor(color)
    if color == nil then
        return self.counterColor
    else
        self.counterColor = color
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_COUNTER_COLOR", false, self.counterColor)
        end
    end
end

---DisEnableControls
---@param bool boolean
function UIMenu:DisEnableControls(bool)
    if bool then
        EnableAllControlActions(2)
    else
        DisableAllControlActions(2)
    end

    if bool then
        return
    else
        if not IsUsingKeyboard(2) then
            for Index = 1, #self.Settings.EnabledControls.Controller do
                EnableControlAction(self.Settings.EnabledControls.Controller[Index][1],
                    self.Settings.EnabledControls.Controller[Index][2], true)
            end
        else
            for Index = 1, #self.Settings.EnabledControls.Keyboard do
                EnableControlAction(self.Settings.EnabledControls.Keyboard[Index][1],
                    self.Settings.EnabledControls.Keyboard[Index][2], true)
            end
        end
    end
end

--- Set's if the menu can build asynchronously.
---@param enabled boolean?
---@return boolean
function UIMenu:BuildAsync(enabled)
    if enabled ~= nil then
        self._buildAsync = enabled
    end
    return self._buildAsync
end

---InstructionalButtons
---@param enabled boolean?
---@return boolean
function UIMenu:HasInstructionalButtons(enabled)
    if enabled ~= nil then
        self.Settings.InstructionalButtons = ToBool(enabled)
    end
    return self.Settings.InstructionalButtons
end

--- Sets if the menu can be closed by the player.
---@param playerCanCloseMenu boolean?
---@return boolean
function UIMenu:CanPlayerCloseMenu(playerCanCloseMenu)
    if playerCanCloseMenu ~= nil then
        self._canHe = playerCanCloseMenu
    end
    return self._canHe
end

-- TODO: Refactor this method and process as its rather backwards.
---Sets if some controls (attack, game camera movement) are disabled when the menu is open. (Default: true) (set to false to disable default left click controls)
---@param enabled boolean?
---@return boolean
function UIMenu:ControlDisablingEnabled(enabled)
    if enabled ~= nil then
        self.Settings.ControlDisablingEnabled = ToBool(enabled)
    end
    return self.Settings.ControlDisablingEnabled
end

---Sets if the camera can be rotated when the mouse cursor is near the edges of the screen. (Default: true)
---@param enabled boolean?
---@return boolean
function UIMenu:MouseEdgeEnabled(enabled)
    if enabled ~= nil then
        self.Settings.MouseEdgeEnabled = ToBool(enabled)
    end
    return self.Settings.MouseEdgeEnabled
end

---Enables or disables mouse controls for the menu. (Default: true)
---@param enabled boolean?
---@return boolean
function UIMenu:MouseControlsEnabled(enabled)
    if enabled ~= nil then
        self.Settings.MouseControlsEnabled = ToBool(enabled)
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_MOUSE", false, self.Settings.MouseControlsEnabled)
        end
    end
    return self.Settings.MouseControlsEnabled
end

---SetBannerSprite
---@param sprite Sprite
---@param includeChildren boolean
---@see Sprite
function UIMenu:SetBannerSprite(sprite, includeChildren)
    if sprite() == "Sprite" then
        self.Logo = sprite
        self.Logo:Size(431 + self.WidthOffset, 107)
        self.Logo:Position(self.Position.X, self.Position.Y)
        self.Banner = nil
        if includeChildren then
            for item, menu in pairs(self.Children) do
                menu.Logo = sprite
                menu.Logo:Size(431 + self.WidthOffset, 107)
                menu.Logo:Position(self.Position.X, self.Position.Y)
                menu.Banner = nil
            end
        end
    end
end

--- Enables or disabls the menu's animations while the menu is visible.
---@param enable boolean?
---@return boolean
function UIMenu:AnimationEnabled(enable)
    if enable ~= nil then
        self.enableAnimation = enable
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_SCROLLING_ANIMATION", false, enable)
        end
    end
    return self.enableAnimation
end

--- Sets the menu's scrolling animationType while the menu is visible.
---@param menuAnimationType MenuAnimationType?
---@return number MenuAnimationType
---@see MenuAnimationType
function UIMenu:AnimationType(menuAnimationType)
    if menuAnimationType ~= nil then
        self.animationType = menuAnimationType
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("CHANGE_SCROLLING_ANIMATION_TYPE", false, menuAnimationType)
        end
    end

    return self.animationType
end

--- Enables or disables the menu's building animationType.
---@param buildingAnimationType MenuBuildingAnimation?
---@return MenuBuildingAnimation
---@see MenuBuildingAnimation
function UIMenu:BuildingAnimation(buildingAnimationType)
    if buildingAnimationType ~= nil then
        self.buildingAnimation = buildingAnimationType
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("CHANGE_BUILDING_ANIMATION_TYPE", false, buildingAnimationType)
        end
    end
    return self.buildingAnimation
end

---CurrentSelection
---@param value number?
function UIMenu:CurrentSelection(value)
    if value ~= nil then
        if #self.Items == 0 then
            self.ActiveItem = value
            return
        end
        self.Items[self:CurrentSelection()]:Selected(false)
        self.ActiveItem = 1000000 - (1000000 % #self.Items) + tonumber(value)
        self.Items[self:CurrentSelection()]:Selected(true)
        ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self:CurrentSelection() - 1)
    else
        if #self.Items == 0 then
            return 1
        else
            if self.ActiveItem % #self.Items == 0 then
                return 1
            else
                return (self.ActiveItem % #self.Items) + 1
            end
        end
    end
end

---AddWindow
---@param window table
function UIMenu:AddWindow(window)
    if window() == "UIMenuWindow" then
        window:SetParentMenu(self)
        self.Windows[#self.Windows + 1] = window
    end
end

---RemoveWindowAt
---@param Index number
function UIMenu:RemoveWindowAt(Index)
    if tonumber(Index) then
        if self.Windows[Index] then
            table.remove(self.Windows, Index)
        end
    end
end

--- Add a new item to the menu.
---@param item UIMenuItem
---@see UIMenuItem
function UIMenu:AddItem(item)
    if item() ~= "UIMenuItem" then
        return
    end
    item:SetParentMenu(self)
    self.Items[#self.Items + 1] = item
end

---RemoveItemAt
---@param Index number
function UIMenu:RemoveItemAt(Index)
    if tonumber(Index) then
        if self.Items[Index] then
            local SelectedItem = self:CurrentSelection()
            table.remove(self.Items, tonumber(Index))
            if self:Visible() then
                ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_ITEM", false, Index - 1) -- scaleform index starts at 0, better remove 1 to the index
            end
            self:CurrentSelection(SelectedItem)
        end
    end
end

---RemoveItem
---@param item table
function UIMenu:RemoveItem(item)
    local idx = 0
    for k, v in pairs(self.Items) do
        if v:Label() == item:Label() then
            idx = k
        end
    end
    if idx > 0 then
        self:RemoveItemAt(idx)
    end
end

---RefreshIndex
function UIMenu:RefreshIndex()
    if #self.Items == 0 then
        self.ActiveItem = 0
        self.Pagination.Max = self.Pagination.Total + 1
        self.Pagination.Min = 0
        return
    end
    self.Items[self:CurrentSelection()]:Selected(false)
    self.ActiveItem = 1000 - (1000 % #self.Items)
    self.Pagination.Max = self.Pagination.Total + 1
    self.Pagination.Min = 0
end

---Clear
function UIMenu:Clear()
    self.Items = {}
end

---MaxItemsOnScreen
---@param max number?
function UIMenu:MaxItemsOnScreen(max)
    if max == nil then
        return self._maxItem
    end

    self._maxItem = max
    self:RefreshIndex()
end

---Adds a submenu to the menu, and returns the submenu.
---@param subMenu UIMenu
---@param text string
---@param description string
---@param offset table?
---@param KeepBanner boolean?
---@return table UIMenu
function UIMenu:AddSubMenu(subMenu, text, description, offset, KeepBanner)
    assert(subMenu ~= self,
        "^1ScaleformUI [ERROR]: You're can't add a menu [" .. subMenu.Title .. "] as a redundant submenu to itself!")
    for k, v in pairs(self.Children) do
        assert(subMenu ~= v,
            "^1ScaleformUI [ERROR]: You can't add the same submenu [" .. subMenu.Title .. "] more than once!")
    end
    ---@diagnostic disable-next-line: missing-parameter
    local Item = UIMenuItem.New(tostring(text), description or "")
    self:AddItem(Item)
    if offset == nil then
        subMenu.Position = self.Position
    else
        subMenu.Position = offset
    end
    if KeepBanner then
        if self.Logo ~= nil then
            subMenu.Logo = self.Logo
        else
            subMenu.Logo = nil
            subMenu.Banner = self.Banner
        end
    end
    subMenu.Glare = self.Glare

    subMenu.Settings.MouseControlsEnabled = self.Settings.MouseControlsEnabled
    subMenu.Settings.MouseEdgeEnabled = self.Settings.MouseEdgeEnabled
    subMenu:MaxItemsOnScreen(self:MaxItemsOnScreen())
    subMenu:BuildAsync(self:BuildAsync())
    subMenu:AnimationEnabled(self:AnimationEnabled())
    subMenu:AnimationType(self:AnimationType())
    subMenu:BuildingAnimation(self:BuildingAnimation())
    self.ParentPool:Add(subMenu)
    self:BindMenuToItem(subMenu, Item)
    return subMenu
end

---Visible
---@param bool boolean?
function UIMenu:Visible(bool)
    if bool ~= nil then
        self._Visible = ToBool(bool)
        self.JustOpened = ToBool(bool)
        self.Dirty = ToBool(bool)

        if self.ParentMenu ~= nil then return end

        if #self.Children > 0 and self.Children[self.Items[self:CurrentSelection()]] ~= nil and self.Children[self.Items[self:CurrentSelection()]]:Visible() then return end
        if bool then
            ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.InstructionalButtons)
            self.OnMenuChanged(nil, self, "opened")
            if self:BuildAsync() then
                self:BuildUpMenuAsync()
            else
                self:BuildUpMenuSync()
            end
            self.ParentPool.currentMenu = self
            self.ParentPool:ProcessMenus(true)
        else
            self.OnMenuChanged(self, nil, "closed")
            ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
            self.ParentPool.currentMenu = nil
            self.ParentPool:ProcessMenus(false)
        end
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(bool)
        if self.Settings.ResetCursorOnOpen then
            local W, H = GetScreenResolution()
            SetCursorLocation(W / 2, H / 2)
        end
    else
        return self._Visible
    end
end

---BuildUpMenu
function UIMenu:BuildUpMenuAsync()
    Citizen.CreateThread(function()
        self._isBuilding = true
        local enab = self:AnimationEnabled()
        self:AnimationEnabled(false)
        while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
        ScaleformUI.Scaleforms._ui:CallFunction("CREATE_MENU", false, self.Title, self.Subtitle, self.Position.x, self.Position.y,
            self.AlternativeTitle, self.TxtDictionary, self.TxtName, self:MaxItemsOnScreen(), self:BuildAsync(),
            self:AnimationType(), self:BuildingAnimation(), self.counterColor, self.descFont[1], self.descFont[2])
        if #self.Windows > 0 then
            for w_id, window in pairs(self.Windows) do
                local Type, SubType = window()
                if SubType == "UIMenuHeritageWindow" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.Mom, window.Dad)
                elseif SubType == "UIMenuDetailsWindow" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.DetailBottom,
                        window.DetailMid, window.DetailTop, window.DetailLeft.Txd, window.DetailLeft.Txn,
                        window.DetailLeft.Pos.x, window.DetailLeft.Pos.y, window.DetailLeft.Size.x,
                        window.DetailLeft.Size.y)
                    if window.StatWheelEnabled then
                        for key, value in pairs(window.DetailStats) do
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false,
                                window.id, value.Percentage, value.HudColor)
                        end
                    end
                end
            end
        end
        local timer = GlobalGameTimer
        if #self.Items == 0 then
            while #self.Items == 0 do
                Citizen.Wait(0)
                if GlobalGameTimer - timer > 150 then
                    self.ActiveItem = 0
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self.ActiveItem)
                    return
                end
            end
        end
        local items = self.Items
        local it = 1
        while it <= #items do
            Citizen.Wait(0)
            if not self:Visible() then return end
            local item = items[it]
            local Type, SubType = item()
            AddTextEntry("desc_{" .. it .. "}", item:Description())

            if SubType == "UIMenuListItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), table.concat(item.Items, ","), item:Index() - 1,
                    item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor)
            elseif SubType == "UIMenuDynamicListItem" then -- dynamic list item are handled like list items in the scaleform.. so the type remains 1
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item:CurrentListItem(), 0, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuCheckboxItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 2, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item.CheckBoxStyle, item._Checked, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuSliderItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 3, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(),
                    item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor,
                    item._heritage)
            elseif SubType == "UIMenuProgressItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 4, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(),
                    item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor)
            elseif SubType == "UIMenuStatsItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 5, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item:Index(), item._Type, item._Color, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuSeperatorItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 6, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item.Jumpable, item.Base._mainColor,
                    item.Base._highlightColor,
                    item.Base._textColor, item.Base._highlightedTextColor)
            else
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 0, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._mainColor, item._highlightColor, item._textColor,
                    item._highlightedTextColor)
                ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", false, it - 1, item:RightLabel())
                if item._rightBadge ~= BadgeStyle.NONE then
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", false, it - 1, item._rightBadge)
                end
            end

            if (SubType == "UIMenuItem" and item._leftBadge ~= BadgeStyle.NONE) or (SubType ~= "UIMenuItem" and item.Base._leftBadge ~= BadgeStyle.NONE) then
                if SubType ~= "UIMenuItem" then
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false, it - 1, item.Base._labelFont
                        [1], item.Base._labelFont[2])
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item.Base._leftBadge)
                else
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false, it - 1, item._labelFont[1],
                        item._labelFont[2])
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item._leftBadge)
                end
            end
            if #item.Panels > 0 then
                for pan, panel in pairs(item.Panels) do
                    local pType, pSubType = panel()
                    if pSubType == "UIMenuColorPanel" then
                        if panel.CustomColors ~= nil then
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title,
                                panel.ColorPanelColorType, panel.value, table.concat(panel.CustomColors, ","))
                        else
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title,
                                panel.ColorPanelColorType, panel.value)
                        end
                    elseif pSubType == "UIMenuPercentagePanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 1, panel.Title, panel.Min,
                            panel.Max, panel.Percentage)
                    elseif pSubType == "UIMenuGridPanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 2, panel.TopLabel,
                            panel.RightLabel, panel.LeftLabel, panel.BottomLabel, panel._CirclePosition.x,
                            panel._CirclePosition.y, true, panel.GridType)
                    elseif pSubType == "UIMenuStatisticsPanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 3)
                        if #panel.Items then
                            for key, stat in pairs(panel.Items) do
                                ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", false, it - 1, pan - 1,
                                    stat['name'], stat['value'])
                            end
                        end
                    end
                end
            end
            if item.SidePanel ~= nil then
                if item.SidePanel() == "UIMissionDetailsPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 0,
                        item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title,
                        item.SidePanel.TitleColor,
                        item.SidePanel.TextureDict, item.SidePanel.TextureName)
                    for key, value in pairs(item.SidePanel.Items) do
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_MISSION_DETAILS_DESC_ITEM", false, it - 1,
                            value.Type, value.TextLeft, value.TextRight, value.Icon, value.IconColor, value.Tick)
                    end
                elseif item.SidePanel() == "UIVehicleColorPickerPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 1,
                        item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title,
                        item.SidePanel.TitleColor)
                end
            end
            it = it + 1
        end
        ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self:CurrentSelection() - 1)
        local type = self.Items[self.ActiveItem]
        if type == "UIMenuSeparatorItem" then
            if (self.Items[self.ActiveItem].Jumpable) then
                self:GoDown()
            end
        end
        ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_MOUSE", false, self.Settings.MouseControlsEnabled)
        self:AnimationEnabled(enab)
        self._isBuilding = false
    end)
end

---BuildUpMenuSync
function UIMenu:BuildUpMenuSync()
    Citizen.CreateThread(function()
        while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
        ScaleformUI.Scaleforms._ui:CallFunction("CREATE_MENU", false, self.Title, self.Subtitle, self.Position.x, self.Position.y,
            self.AlternativeTitle, self.TxtDictionary, self.TxtName, self:MaxItemsOnScreen(), self:BuildAsync(),
            self:AnimationType(), self:BuildingAnimation(), self.counterColor, self.descFont[1], self.descFont[2])
        if #self.Windows > 0 then
            for w_id, window in pairs(self.Windows) do
                local Type, SubType = window()
                if SubType == "UIMenuHeritageWindow" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.Mom, window.Dad)
                elseif SubType == "UIMenuDetailsWindow" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.DetailBottom,
                        window.DetailMid, window.DetailTop, window.DetailLeft.Txd, window.DetailLeft.Txn,
                        window.DetailLeft.Pos.x, window.DetailLeft.Pos.y, window.DetailLeft.Size.x,
                        window.DetailLeft.Size.y)
                    if window.StatWheelEnabled then
                        for key, value in pairs(window.DetailStats) do
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false,
                                window.id, value.Percentage, value.HudColor)
                        end
                    end
                end
            end
        end
        local timer = GlobalGameTimer
        if #self.Items == 0 then
            while #self.Items == 0 do
                Citizen.Wait(0)
                if GlobalGameTimer - timer > 150 then
                    self.ActiveItem = 0
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self.ActiveItem)
                    return
                end
            end
        end
        local items = self.Items

        for it, item in pairs(items) do
            local Type, SubType = item()
            AddTextEntry("desc_{" .. it .. "}", item:Description())

            if SubType == "UIMenuListItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), table.concat(item.Items, ","), item:Index() - 1,
                    item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor)
            elseif SubType == "UIMenuDynamicListItem" then -- dynamic list item are handled like list items in the scaleform.. so the type remains 1
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item:CurrentListItem(), 0, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuCheckboxItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 2, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item.CheckBoxStyle, item._Checked, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuSliderItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 3, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(),
                    item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor,
                    item._heritage)
            elseif SubType == "UIMenuProgressItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 4, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(),
                    item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor)
            elseif SubType == "UIMenuStatsItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 5, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item:Index(), item._Type, item._Color, item.Base._mainColor,
                    item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
            elseif SubType == "UIMenuSeperatorItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 6, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item.Jumpable, item.Base._mainColor,
                    item.Base._highlightColor,
                    item.Base._textColor, item.Base._highlightedTextColor)
            else
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 0, item:Label(), "desc_{" .. it .. "}",
                    item:Enabled(), item:BlinkDescription(), item._mainColor, item._highlightColor, item._textColor,
                    item._highlightedTextColor)
                ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", false, it - 1, item:RightLabel())
                if item._rightBadge ~= BadgeStyle.NONE then
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", false, it - 1, item._rightBadge)
                end
            end

            if (SubType == "UIMenuItem" and item._leftBadge ~= BadgeStyle.NONE) or (SubType ~= "UIMenuItem" and item.Base._leftBadge ~= BadgeStyle.NONE) then
                if SubType ~= "UIMenuItem" then
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false, it - 1, item.Base._labelFont
                        [1], item.Base._labelFont[2])
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item.Base._leftBadge)
                else
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false, it - 1, item._labelFont[1],
                        item._labelFont[2])
                    ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item._leftBadge)
                end
            end
            if #item.Panels > 0 then
                for pan, panel in pairs(item.Panels) do
                    local pType, pSubType = panel()
                    if pSubType == "UIMenuColorPanel" then
                        if panel.CustomColors ~= nil then
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title,
                                panel.ColorPanelColorType, panel.value, table.concat(panel.CustomColors, ","))
                        else
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title,
                                panel.ColorPanelColorType, panel.value)
                        end
                    elseif pSubType == "UIMenuPercentagePanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 1, panel.Title, panel.Min,
                            panel.Max, panel.Percentage)
                    elseif pSubType == "UIMenuGridPanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 2, panel.TopLabel,
                            panel.RightLabel, panel.LeftLabel, panel.BottomLabel, panel._CirclePosition.x,
                            panel._CirclePosition.y, true, panel.GridType)
                    elseif pSubType == "UIMenuStatisticsPanel" then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 3)
                        if #panel.Items then
                            for key, stat in pairs(panel.Items) do
                                ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", false, it - 1, pan - 1,
                                    stat['name'], stat['value'])
                            end
                        end
                    end
                end
            end
            if item.SidePanel ~= nil then
                if item.SidePanel() == "UIMissionDetailsPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 0,
                        item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title,
                        item.SidePanel.TitleColor,
                        item.SidePanel.TextureDict, item.SidePanel.TextureName)
                    for key, value in pairs(item.SidePanel.Items) do
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_MISSION_DETAILS_DESC_ITEM", false, it - 1,
                            value.Type, value.TextLeft, value.TextRight, value.Icon, value.IconColor, value.Tick)
                    end
                elseif item.SidePanel() == "UIVehicleColorPickerPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 1,
                        item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title,
                        item.SidePanel.TitleColor)
                end
            end
        end
        ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self:CurrentSelection() - 1)
        local type = self.Items[self.ActiveItem]
        if type == "UIMenuSeparatorItem" then
            if (self.Items[self.ActiveItem].Jumpable) then
                self:GoDown()
            end
        end
        ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_MOUSE", false, self.Settings.MouseControlsEnabled)
    end)
end

---ProcessControl
function UIMenu:ProcessControl()
    if not self._Visible then
        return
    end

    if self.JustOpened then
        self.JustOpened = false
        return
    end

    if UpdateOnscreenKeyboard() == 0 or IsWarningMessageActive() then return end

    if self.Controls.Back.Enabled then
        if IsDisabledControlJustReleased(0, 177) or IsDisabledControlJustReleased(1, 177) or IsDisabledControlJustReleased(2, 177) or IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(1, 199) or IsDisabledControlJustReleased(2, 199) then
            Citizen.CreateThread(function()
                self:GoBack()
                Citizen.Wait(125)
                return
            end)
        end
    end

    if #self.Items == 0 or self._isBuilding then return end

    if self.Controls.Up.Enabled then
        if IsDisabledControlJustPressed(0, 172) or IsDisabledControlJustPressed(1, 172) or IsDisabledControlJustPressed(2, 172) or IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(1, 241) or IsDisabledControlJustPressed(2, 241) or IsDisabledControlJustPressed(2, 241) then
            self._timeBeforeOverflow = GlobalGameTimer
            Citizen.CreateThread(function()
                self:GoUp()
                return
            end)
        elseif IsDisabledControlPressed(0, 172) or IsDisabledControlPressed(1, 172) or IsDisabledControlPressed(2, 172) or IsDisabledControlPressed(0, 241) or IsDisabledControlPressed(1, 241) or IsDisabledControlPressed(2, 241) or IsDisabledControlPressed(2, 241) then
            if GlobalGameTimer - self._timeBeforeOverflow > self._delayBeforeOverflow then
                if GlobalGameTimer - self._time > self._delay then
                    self:ButtonDelay()
                    Citizen.CreateThread(function()
                        self:GoUp()
                        return
                    end)
                end
            end
        end
    end

    if self.Controls.Down.Enabled then
        if IsDisabledControlJustPressed(0, 173) or IsDisabledControlJustPressed(1, 173) or IsDisabledControlJustPressed(2, 173) or IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(1, 242) or IsDisabledControlJustPressed(2, 242) then
            self._timeBeforeOverflow = GlobalGameTimer
            Citizen.CreateThread(function()
                self:GoDown()
                return
            end)
        elseif IsDisabledControlPressed(0, 173) or IsDisabledControlPressed(1, 173) or IsDisabledControlPressed(2, 173) or IsDisabledControlPressed(0, 242) or IsDisabledControlPressed(1, 242) or IsDisabledControlPressed(2, 242) then
            if GlobalGameTimer - self._timeBeforeOverflow > self._delayBeforeOverflow then
                if GlobalGameTimer - self._time > self._delay then
                    self:ButtonDelay()
                    Citizen.CreateThread(function()
                        self:GoDown()
                        return
                    end)
                end
            end
        end
    end

    if self.Controls.Left.Enabled then
        if IsDisabledControlJustPressed(0, 174) or IsDisabledControlJustPressed(1, 174) or IsDisabledControlJustPressed(2, 174) then
            self._timeBeforeOverflow = GlobalGameTimer
            Citizen.CreateThread(function()
                self:GoLeft()
                return
            end)
        elseif IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174) then
            if GlobalGameTimer - self._timeBeforeOverflow > self._delayBeforeOverflow then
                if GlobalGameTimer - self._time > self._delay then
                    self:ButtonDelay()
                    Citizen.CreateThread(function()
                        self:GoLeft()
                        return
                    end)
                end
            end
        end
    end

    if self.Controls.Right.Enabled then
        if IsDisabledControlJustPressed(0, 175) or IsDisabledControlJustPressed(1, 175) or IsDisabledControlJustPressed(2, 175) then
            self._timeBeforeOverflow = GlobalGameTimer
            Citizen.CreateThread(function()
                self:GoRight()
                return
            end)
        elseif IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175) then
            if GlobalGameTimer - self._timeBeforeOverflow > self._delayBeforeOverflow then
                if GlobalGameTimer - self._time > self._delay then
                    self:ButtonDelay()
                    Citizen.CreateThread(function()
                        self:GoRight()
                        return
                    end)
                end
            end
        end
    end

    if self.Controls.Select.Enabled and ((IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(1, 201) or IsDisabledControlJustPressed(2, 201)) or
    (IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(1, 24) or IsDisabledControlJustPressed(2, 24)) and not self.Settings.MouseControlsEnabled) then
        Citizen.CreateThread(function()
            self:SelectItem()
            Citizen.Wait(125)
            return
        end)
    end

    if (IsDisabledControlJustReleased(0, 172) or IsDisabledControlJustReleased(1, 172) or IsDisabledControlJustReleased(2, 172) or IsDisabledControlJustReleased(0, 241) or IsDisabledControlJustReleased(1, 241) or IsDisabledControlJustReleased(2, 241) or IsDisabledControlJustReleased(2, 241)) or
        (IsDisabledControlJustReleased(0, 173) or IsDisabledControlJustReleased(1, 173) or IsDisabledControlJustReleased(2, 173) or IsDisabledControlJustReleased(0, 242) or IsDisabledControlJustReleased(1, 242) or IsDisabledControlJustReleased(2, 242)) or
        (IsDisabledControlJustReleased(0, 174) or IsDisabledControlJustReleased(1, 174) or IsDisabledControlJustReleased(2, 174)) or
        (IsDisabledControlJustReleased(0, 175) or IsDisabledControlJustReleased(1, 175) or IsDisabledControlJustReleased(2, 175))
    then
        self._times = 0
        self._delay = 100
    end
end

function UIMenu:ButtonDelay()
    self._times = self._times + 1
    if self._times % 5 == 0 then
        self._delay = self._delay - 10
        if self._delay < 50 then
            self._delay = 50
        end
    end
    self._time = GlobalGameTimer
end

---GoUp
function UIMenu:GoUp()
    self.Items[self:CurrentSelection()]:Selected(false)
    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 8, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    self.ActiveItem = GetScaleformMovieMethodReturnValueInt(return_value)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

---GoDown
function UIMenu:GoDown()
    self.Items[self:CurrentSelection()]:Selected(false)
    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 9, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    self.ActiveItem = GetScaleformMovieMethodReturnValueInt(return_value)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

---GoLeft
function UIMenu:GoLeft()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuDynamicListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end

    if not Item:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 10) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local res = GetScaleformMovieMethodReturnValueInt(return_value)

    if subtype == "UIMenuListItem" then
        Item:Index(res + 1)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif (subtype == "UIMenuDynamicListItem") then
        local result = tostring(Item.Callback(Item, "left"))
        Item:CurrentListItem(result)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        self.OnStatsChanged(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---GoRight
function UIMenu:GoRight()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuDynamicListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end
    if not Item:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 11) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local res = GetScaleformMovieMethodReturnValueInt(return_value)

    if subtype == "UIMenuListItem" then
        Item:Index(res + 1)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif (subtype == "UIMenuDynamicListItem") then
        local result = tostring(Item.Callback(Item, "right"))
        Item:CurrentListItem(result)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        self.OnStatsChanged(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---SelectItem
---@param play boolean?
function UIMenu:SelectItem(play)
    if not self.Items[self:CurrentSelection()]:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end
    if play then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
    end

    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype == "UIMenuCheckboxItem" then
        Item:Checked(not Item:Checked())
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnCheckboxChange(self, Item, Item:Checked())
        Item.OnCheckboxChanged(self, Item, Item:Checked())
    elseif subtype == "UIMenuListItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnListSelect(self, Item, Item._Index)
        Item.OnListSelected(self, Item, Item._Index)
    elseif subtype == "UIMenuDynamicListItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnListSelect(self, Item, Item._currentItem)
        Item.OnListSelected(self, Item, Item._currentItem)
    elseif subtype == "UIMenuSliderItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnSliderSelect(self, Item, Item._Index)
        Item.OnSliderSelected(self, Item, Item._Index)
    elseif subtype == "UIMenuProgressItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnProgressSelect(self, Item, Item._Index)
        Item.OnProgressSelected(self, Item, Item._Index)
    elseif subtype == "UIMenuStatsItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnStatsSelect(self, Item, Item._Index)
        Item.OnStatsSelected(self, Item, Item._Index)
    else
        self.OnItemSelect(self, Item, self:CurrentSelection())
        Item:Activated(self, Item)
        if not self.Children[Item] then
            return
        end
        self._canBuild = false
        self._Visible = false
        self.OnMenuChanged(self, self.Children[self.Items[self:CurrentSelection()]], true)
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.Children
            [self.Items[self:CurrentSelection()]].InstructionalButtons)
        self.OnMenuChanged(self, self.Children[Item], "forwards")
        self.Children[Item].OnMenuChanged(self, self.Children[Item], "forwards")
        self.Children[Item]._canBuild = true
        self.Children[Item]:Visible(true)
        if self.Children[Item]:BuildAsync() then
            self.Children[Item]:BuildUpMenuAsync()
        else
            self.Children[Item]:BuildUpMenuSync()
        end
    end
end

---GoBack
function UIMenu:GoBack(boolean)
    local playSound = true
    if type(boolean) == "boolean" then
        playSound = boolean
    end
    if playSound then
        PlaySoundFrontend(-1, self.Settings.Audio.Back, self.Settings.Audio.Library, true)
    end
    if self.ParentMenu ~= nil then
        self._canBuild = false
        self:Visible(false)
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.ParentMenu.InstructionalButtons)
        self.ParentMenu._canBuild = true
        self.ParentMenu._Visible = true
        if self.ParentMenu:BuildAsync() then
            self.ParentMenu:BuildUpMenuAsync()
        else
            self.ParentMenu:BuildUpMenuSync()
        end
        self.OnMenuChanged(self, self.ParentMenu, "backwards")
        self.ParentMenu.OnMenuChanged(self, self.ParentMenu, "backwards")
    else
        if self:CanPlayerCloseMenu() then
            self:Visible(false)
        end
    end
end

---BindMenuToItem
---@param Menu table
---@param Item table
function UIMenu:BindMenuToItem(Menu, Item)
    if Menu() == "UIMenu" and Item() == "UIMenuItem" then
        Menu.ParentMenu = self
        Menu.ParentItem = Item
        self.Children[Item] = Menu
    end
end

---ReleaseMenuFromItem
---@param Item table
function UIMenu:ReleaseMenuFromItem(Item)
    if Item() == "UIMenuItem" then
        if not self.Children[Item] then
            return false
        end
        self.Children[Item].ParentMenu = nil
        self.Children[Item].ParentItem = nil
        self.Children[Item] = nil
        return true
    end
end

function UIMenu:UpdateDescription()
    ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_ITEM_DESCRIPTION", false, self:CurrentSelection() - 1,
        "desc_{" .. self:CurrentSelection() .. "}")
end

---Draw
function UIMenu:Draw()
    if not self._Visible or ScaleformUI.Scaleforms.Warning:IsShowing() then return end
    if not ScaleformUI.Scaleforms._ui:IsLoaded() then
        while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
    end

    HideHudComponentThisFrame(19)

    if self.Settings.ControlDisablingEnabled then
        self:DisEnableControls(false)
    end

    ScaleformUI.Scaleforms._ui:Render2D()

    if self.Glare then
        self._menuGlare:CallFunction("SET_DATA_SLOT", false, GetGameplayCamRelativeHeading())

        local gx = self.Position.x / 1280 + 0.4499
        local gy = self.Position.y / 720 + 0.449

        self._menuGlare:Render2DNormal(gx, gy, 1.0, 1.0)
    end

    if not IsUsingKeyboard(2) then
        if self._keyboard then
            self._keyboard = false
            self._changed = true
        end
    else
        if not self._keyboard then
            self._keyboard = true
            self._changed = true
        end
    end
    if self._changed then
        self:UpdateDescription()
        self._changed = false
    end
end

local cursor_pressed = false
local menuSound = -1
local success, event_type, context, item_id

function UIMenu:ProcessMouse()
    if not self._Visible or self.JustOpened or #self.Items == 0 or not IsUsingKeyboard(2) or not self.Settings.MouseControlsEnabled then
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 2, true)
        EnableControlAction(1, 1, true)
        EnableControlAction(1, 2, true)
        EnableControlAction(2, 1, true)
        EnableControlAction(2, 2, true)
        if self.Dirty then
            for _, Item in pairs(self.Items) do
                if Item:Hovered() then
                    Item:Hovered(false)
                end
            end
            self.Dirty = false
        end
        return
    end

    SetMouseCursorActiveThisFrame()
    SetInputExclusive(2, 239)
    SetInputExclusive(2, 240)
    SetInputExclusive(2, 237)
    SetInputExclusive(2, 238)

    success, event_type, context, item_id = GetScaleformMovieCursorSelection(ScaleformUI.Scaleforms._ui.handle)

    if success == 1 then
        if event_type == 5 then  --ON CLICK
            if context == 0 then -- normal menu items
                local item = self.Items[(item_id + 1)]
                if (item == nil) then return end
                if item:Selected() then
                    if item.ItemId == 0 or item.ItemId == 2 then
                        self:SelectItem(false)
                    elseif item.ItemId == 1 or item.ItemId == 3 or item.ItemId == 4 then
                        Citizen.CreateThread(function()
                            local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SELECT_ITEM", true, item_id) --[[@as number]]
                            while not IsScaleformMovieMethodReturnValueReady(return_value) do
                                Citizen.Wait(0)
                            end
                            local value = GetScaleformMovieMethodReturnValueInt(return_value)

                            local curr_select_item = self.Items[self:CurrentSelection()]
                            local item_type_curr, item_subtype_curr = curr_select_item()
                            if item.ItemId == 1 then
                                curr_select_item:Index(value)
                                self.OnListChange(self, curr_select_item, curr_select_item:Index())
                                curr_select_item.OnListChanged(self, curr_select_item, curr_select_item:Index())
                            elseif item.ItemId == 3 then
                                if (value ~= curr_select_item:Index()) then
                                    curr_select_item:Index(value)
                                    curr_select_item.OnSliderChanged(self, curr_select_item, curr_select_item:Index())
                                    self.OnSliderChange(self, curr_select_item, curr_select_item:Index())
                                end
                            elseif item.ItemId == 4 then
                                if (value ~= curr_select_item:Index()) then
                                    curr_select_item:Index(value)
                                    curr_select_item.OnProgressChanged(self, curr_select_item, curr_select_item:Index())
                                    self.OnProgressChange(self, curr_select_item, curr_select_item:Index())
                                end
                            end
                            return
                        end)
                    end
                    return
                end
                if (item.ItemId == 6 and item.Jumpable == true) or not item:Enabled() then
                    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    return
                end
                self:CurrentSelection(item_id)
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif context == 10 then -- panels (10 => context 1, panel_type 0) // ColorPanel
                Citizen.CreateThread(function()
                    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SELECT_PANEL", true,
                        self:CurrentSelection() - 1) --[[@as number]]
                    while not IsScaleformMovieMethodReturnValueReady(return_value) do
                        Citizen.Wait(0)
                    end
                    local res = GetScaleformMovieMethodReturnValueString(return_value)
                    local split = Split(res, ",")
                    local panel = self.Items[self:CurrentSelection()].Panels[tonumber(split[1]) + 1]
                    panel.value = tonumber(split[2]) + 1
                    self.OnColorPanelChanged(panel.ParentItem, panel, panel:CurrentSelection())
                    panel.OnColorPanelChanged(panel.ParentItem, panel, panel:CurrentSelection())
                end)
            elseif context == 11 then -- panels (11 => context 1, panel_type 1) // PercentagePanel
                cursor_pressed = true
            elseif context == 12 then -- panels (12 => context 1, panel_type 2) // GridPanel
                cursor_pressed = true
            elseif context == 2 then  -- sidepanel
                local panel = self.Items[self:CurrentSelection()].SidePanel
                if item_id ~= -1 then
                    panel.Value = item_id - 1
                    panel.PickerSelect(panel.ParentItem, panel, panel.Value)
                end
            end
        elseif event_type == 6 then -- ON CLICK RELEASED
            cursor_pressed = false
        elseif event_type == 7 then -- ON CLICK RELEASED OUTSIDE
            cursor_pressed = false
            SetMouseCursorSprite(1)
        elseif event_type == 8 then -- ON NOT HOVER
            cursor_pressed = false
            if context == 0 then
                self.Items[item_id + 1]:Hovered(false)
            end
            SetMouseCursorSprite(1)
        elseif event_type == 9 then -- ON HOVERED
            if context == 0 then
                self.Items[item_id + 1]:Hovered(true)
            end
            SetMouseCursorSprite(5)
        elseif event_type == 0 then -- DRAGGED OUTSIDE
            cursor_pressed = false
        elseif event_type == 1 then -- DRAGGED INSIDE
            cursor_pressed = true
        end
    end

    if cursor_pressed == true then
        if HasSoundFinished(menuSound) then
            menuSound = GetSoundId()
            PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        end

        Citizen.CreateThread(function()
            local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_MOUSE_EVENT_CONTINUE", true) --[[@as number]]
            while not IsScaleformMovieMethodReturnValueReady(return_value) do
                Citizen.Wait(0)
            end
            local value = GetScaleformMovieMethodReturnValueString(return_value)

            local split = Split(value, ",")
            local panel = self.Items[self:CurrentSelection()].Panels[tonumber(split[1]) + 1]
            local panel_type, panel_subtype = panel()

            if panel_subtype == "UIMenuGridPanel" then
                panel._CirclePosition = vector2(tonumber(split[2]) or 0, tonumber(split[3]) or 0)
                self.OnGridPanelChanged(panel.ParentItem, panel, panel._CirclePosition)
                panel.OnGridPanelChanged(panel.ParentItem, panel, panel._CirclePosition)
            elseif panel_subtype == "UIMenuPercentagePanel" then
                panel.Percentage = tonumber(split[2])
                self:OnPercentagePanelChanged(panel.ParentItem, panel, panel.Percentage)
                panel.OnPercentagePanelChange(panel.ParentItem, panel, panel.Percentage)
            end
        end)
    else
        if not HasSoundFinished(menuSound) then
            StopSound(menuSound)
            ReleaseSoundId(menuSound)
        end
    end
end

---AddInstructionButton
---@param button table
function UIMenu:AddInstructionButton(button)
    if type(button) == "table" and #button == 2 then
        self.InstructionalButtons[#self.InstructionalButtons + 1] = button
    end
end

---RemoveInstructionButton
---@param button table
function UIMenu:RemoveInstructionButton(button)
    if type(button) == "table" then
        for i = 1, #self.InstructionalButtons do
            if button == self.InstructionalButtons[i] then
                table.remove(self.InstructionalButtons, i)
                break
            end
        end
    else
        if tonumber(button) then
            if self.InstructionalButtons[tonumber(button)] then
                table.remove(self.InstructionalButtons, tonumber(button))
            end
        end
    end
end

---AddEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:AddEnabledControl(Inputgroup, Control, Controller)
    if tonumber(Inputgroup) and tonumber(Control) then
        table.insert(self.Settings.EnabledControls[(Controller and "Controller" or "Keyboard")], { Inputgroup, Control })
    end
end

---RemoveEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:RemoveEnabledControl(Inputgroup, Control, Controller)
    local Type = (Controller and "Controller" or "Keyboard")
    for Index = 1, #self.Settings.EnabledControls[Type] do
        if Inputgroup == self.Settings.EnabledControls[Type][Index][1] and Control == self.Settings.EnabledControls[Type][Index][2] then
            table.remove(self.Settings.EnabledControls[Type], Index)
            break
        end
    end
end
---@enum MenuAnimationType
MenuAnimationType = {
    LINEAR = 0,
    QUADRATIC_IN = 1,
    QUADRATIC_OUT = 2,
    QUADRATIC_INOUT = 3,
    CUBIC_IN = 4,
    CUBIC_OUT = 5,
    CUBIC_INOUT = 6,
    QUARTIC_IN = 7,
    QUARTIC_OUT = 8,
    QUARTIC_INOUT = 9,
    SINE_IN = 10,
    SINE_OUT = 11,
    SINE_INOUT = 12,
    BACK_IN = 13,
    BACK_OUT = 14,
    BACK_INOUT = 15,
    CIRCULAR_IN = 16,
    CIRCULAR_OUT = 17,
    CIRCULAR_INOUT = 18
}

---@enum MenuBuildingAnimation
MenuBuildingAnimation = {
    NONE = 0,
    LEFT = 1,
    RIGHT = 2,
    LEFT_RIGHT = 3,
}
---@enum BadgeStyle
BadgeStyle = {
    NONE = 0,
    LOCK = 1,
    STAR = 2,
    WARNING = 3,
    CROWN = 4,
    MEDAL_BRONZE = 5,
    MEDAL_GOLD = 6,
    MEDAL_SILVER = 7,
    CASH = 8,
    COKE = 9,
    HEROIN = 10,
    METH = 11,
    WEED = 12,
    AMMO = 13,
    ARMOR = 14,
    BARBER = 15,
    CLOTHING = 16,
    FRANKLIN = 17,
    BIKE = 18,
    CAR = 19,
    GUN = 20,
    HEALTH_HEART = 21,
    MAKEUP_BRUSH = 22,
    MASK = 23,
    MICHAEL = 24,
    TATTOO = 25,
    TICK = 26,
    TREVOR = 27,
    FEMALE = 28,
    MALE = 29,
    LOCK_ARENA = 30,
    ADVERSARY = 31,
    BASE_JUMPING = 32,
    BRIEFCASE = 33,
    MISSION_STAR = 34,
    DEATHMATCH = 35,
    CASTLE = 36,
    TROPHY = 37,
    RACE_FLAG = 38,
    RACE_FLAG_PLANE = 39,
    RACE_FLAG_BICYCLE = 40,
    RACE_FLAG_PERSON = 41,
    RACE_FLAG_CAR = 42,
    RACE_FLAG_BOAT_ANCHOR = 43,
    ROCKSTAR = 44,
    STUNT = 45,
    STUNT_PREMIUM = 46,
    RACE_FLAG_STUNT_JUMP = 47,
    SHIELD = 48,
    TEAM_DEATHMATCH = 49,
    VEHICLE_DEATHMATCH = 50,
    MP_AMMO_PICKUP = 51,
    MP_AMMO = 52,
    MP_CASH = 53,
    MP_RP = 54,
    MP_SPECTATING = 55,
    SALE = 56,
    GLOBE_WHITE = 57,
    GLOBE_RED = 58,
    GLOBE_BLUE = 59,
    GLOBE_YELLOW = 60,
    GLOBE_GREEN = 61,
    GLOBE_ORANGE = 62,
    INV_ARM_WRESTLING = 63,
    INV_BASEJUMP = 64,
    INV_MISSION = 65,
    INV_DARTS = 66,
    INV_DEATHMATCH = 67,
    INV_DRUG = 68,
    INV_CASTLE = 69,
    INV_GOLF = 70,
    INV_BIKE = 71,
    INV_BOAT = 72,
    INV_ANCHOR = 73,
    INV_CAR = 74,
    INV_DOLLAR = 75,
    INV_COKE = 76,
    INV_KEY = 77,
    INV_DATA = 78,
    INV_HELI = 79,
    INV_HEORIN = 80,
    INV_KEYCARD = 81,
    INV_METH = 82,
    INV_BRIEFCASE = 83,
    INV_LINK = 84,
    INV_PERSON = 85,
    INV_PLANE = 86,
    INV_PLANE2 = 87,
    INV_QUESTIONMARK = 88,
    INV_REMOTE = 89,
    INV_SAFE = 90,
    INV_STEER_WHEEL = 91,
    INV_WEAPON = 92,
    INV_WEED = 93,
    INV_RACE_FLAG_PLANE = 94,
    INV_RACE_FLAG_BICYCLE = 95,
    INV_RACE_FLAG_BOAT_ANCHOR = 96,
    INV_RACE_FLAG_PERSON = 97,
    INV_RACE_FLAG_CAR = 98,
    INV_RACE_FLAG_HELMET = 99,
    INV_SHOOTING_RANGE = 100,
    INV_SURVIVAL = 101,
    INV_TEAM_DEATHMATCH = 102,
    INV_TENNIS = 103,
    INV_VEHICLE_DEATHMATCH = 104,
    AUDIO_MUTE = 105,
    AUDIO_INACTIVE = 106,
    AUDIO_VOL1 = 107,
    AUDIO_VOL2 = 108,
    AUDIO_VOL3 = 109,
    COUNTRY_USA = 110,
    COUNTRY_UK = 111,
    COUNTRY_SWEDEN = 112,
    COUNTRY_KOREA = 113,
    COUNTRY_JAPAN = 114,
    COUNTRY_ITALY = 115,
    COUNTRY_GERMANY = 116,
    COUNTRY_FRANCE = 117,
    BRAND_ALBANY = 118,
    BRAND_ANNIS = 119,
    BRAND_BANSHEE = 120,
    BRAND_BENEFACTOR = 121,
    BRAND_BF = 122,
    BRAND_BOLLOKAN = 123,
    BRAND_BRAVADO = 124,
    BRAND_BRUTE = 125,
    BRAND_BUCKINGHAM = 126,
    BRAND_CANIS = 127,
    BRAND_CHARIOT = 128,
    BRAND_CHEVAL = 129,
    BRAND_CLASSIQUE = 130,
    BRAND_COIL = 131,
    BRAND_DECLASSE = 132,
    BRAND_DEWBAUCHEE = 133,
    BRAND_DILETTANTE = 134,
    BRAND_DINKA = 135,
    BRAND_DUNDREARY = 136,
    BRAND_EMPORER = 137,
    BRAND_ENUS = 138,
    BRAND_FATHOM = 139,
    BRAND_GALIVANTER = 140,
    BRAND_GROTTI = 141,
    BRAND_GROTTI2 = 142,
    BRAND_HIJAK = 143,
    BRAND_HVY = 144,
    BRAND_IMPONTE = 145,
    BRAND_INVETERO = 146,
    BRAND_JACKSHEEPE = 147,
    BRAND_LCC = 148,
    BRAND_JOBUILT = 149,
    BRAND_KARIN = 150,
    BRAND_LAMPADATI = 151,
    BRAND_MAIBATSU = 152,
    BRAND_MAMMOTH = 153,
    BRAND_MTL = 154,
    BRAND_NAGASAKI = 155,
    BRAND_OBEY = 156,
    BRAND_OCELOT = 157,
    BRAND_OVERFLOD = 158,
    BRAND_PED = 159,
    BRAND_PEGASSI = 160,
    BRAND_PFISTER = 161,
    BRAND_PRINCIPE = 162,
    BRAND_PROGEN = 163,
    BRAND_PROGEN2 = 164,
    BRAND_RUNE = 165,
    BRAND_SCHYSTER = 166,
    BRAND_SHITZU = 167,
    BRAND_SPEEDOPHILE = 168,
    BRAND_STANLEY = 169,
    BRAND_TRUFFADE = 170,
    BRAND_UBERMACHT = 171,
    BRAND_VAPID = 172,
    BRAND_VULCAR = 173,
    BRAND_WEENY = 174,
    BRAND_WESTERN = 175,
    BRAND_WESTERNMOTORCYCLE = 176,
    BRAND_WILLARD = 177,
    BRAND_ZIRCONIUM = 178,
    INFO = 179
}

function GetSpriteDictionary(icon)
    if icon == BadgeStyle.MALE or icon == BadgeStyle.FEMALE or icon == BadgeStyle.AUDIO_MUTE or icon == BadgeStyle.AUDIO_INACTIVE or icon == BadgeStyle.AUDIO_VOL1 or icon == BadgeStyle.AUDIO_VOL2 or icon == BadgeStyle.AUDIO_VOL3 then
        return "mpleaderboard"
    elseif icon == BadgeStyle.INV_ARM_WRESTLING or icon == BadgeStyle.INV_BASEJUMP or icon == BadgeStyle.INV_MISSION or icon == BadgeStyle.INV_DARTS or icon == BadgeStyle.INV_DEATHMATCH or icon == BadgeStyle.INV_DRUG or icon == BadgeStyle.INV_CASTLE or icon == BadgeStyle.INV_GOLF or icon == BadgeStyle.INV_BIKE or icon == BadgeStyle.INV_BOAT or icon == BadgeStyle.INV_ANCHOR or icon == BadgeStyle.INV_CAR or icon == BadgeStyle.INV_DOLLAR or icon == BadgeStyle.INV_COKE or icon == BadgeStyle.INV_KEY or icon == BadgeStyle.INV_DATA or icon == BadgeStyle.INV_HELI or icon == BadgeStyle.INV_HEORIN or icon == BadgeStyle.INV_KEYCARD or icon == BadgeStyle.INV_METH or icon == BadgeStyle.INV_BRIEFCASE or icon == BadgeStyle.INV_LINK or icon == BadgeStyle.INV_PERSON or icon == BadgeStyle.INV_PLANE or icon == BadgeStyle.INV_PLANE2 or icon == BadgeStyle.INV_QUESTIONMARK or icon == BadgeStyle.INV_REMOTE or icon == BadgeStyle.INV_SAFE or icon == BadgeStyle.INV_STEER_WHEEL or icon == BadgeStyle.INV_WEAPON or icon == BadgeStyle.INV_WEED or icon == BadgeStyle.INV_RACE_FLAG_PLANE or icon == BadgeStyle.INV_RACE_FLAG_BICYCLE or icon == BadgeStyle.INV_RACE_FLAG_BOAT_ANCHOR or icon == BadgeStyle.INV_RACE_FLAG_PERSON or icon == BadgeStyle.INV_RACE_FLAG_CAR or icon == BadgeStyle.INV_RACE_FLAG_HELMET or icon == BadgeStyle.INV_SHOOTING_RANGE or icon == BadgeStyle.INV_SURVIVAL or icon == BadgeStyle.INV_TEAM_DEATHMATCH or icon == BadgeStyle.INV_TENNIS or icon == BadgeStyle.INV_VEHICLE_DEATHMATCH then
        return "mpinventory"
    elseif icon == BadgeStyle.ADVERSARY or icon == BadgeStyle.BASE_JUMPING or icon == BadgeStyle.BRIEFCASE or icon == BadgeStyle.MISSION_STAR or icon == BadgeStyle.DEATHMATCH or icon == BadgeStyle.CASTLE or icon == BadgeStyle.TROPHY or icon == BadgeStyle.RACE_FLAG or icon == BadgeStyle.RACE_FLAG_PLANE or icon == BadgeStyle.RACE_FLAG_BICYCLE or icon == BadgeStyle.RACE_FLAG_PERSON or icon == BadgeStyle.RACE_FLAG_CAR or icon == BadgeStyle.RACE_FLAG_BOAT_ANCHOR or icon == BadgeStyle.ROCKSTAR or icon == BadgeStyle.STUNT or icon == BadgeStyle.STUNT_PREMIUM or icon == BadgeStyle.RACE_FLAG_STUNT_JUMP or icon == BadgeStyle.SHIELD or icon == BadgeStyle.TEAM_DEATHMATCH or icon == BadgeStyle.VEHICLE_DEATHMATCH then
        return "commonmenutu"
    elseif icon == BadgeStyle.MP_AMMO_PICKUP or icon == BadgeStyle.MP_AMMO or icon == BadgeStyle.MP_CASH or icon == BadgeStyle.MP_RP or icon == BadgeStyle.MP_SPECTATING then
        return "mphud"
    elseif icon == BadgeStyle.SALE then
        return "mpshopsale"
    elseif icon == BadgeStyle.GLOBE_WHITE or icon == BadgeStyle.GLOBE_RED or icon == BadgeStyle.GLOBE_BLUE or icon == BadgeStyle.GLOBE_YELLOW or icon == BadgeStyle.GLOBE_GREEN or icon == BadgeStyle.GLOBE_ORANGE then
        return "mprankbadge"
    elseif icon == BadgeStyle.COUNTRY_USA or icon == BadgeStyle.COUNTRY_UK or icon == BadgeStyle.COUNTRY_SWEDEN or icon == BadgeStyle.COUNTRY_KOREA or icon == BadgeStyle.COUNTRY_JAPAN or icon == BadgeStyle.COUNTRY_ITALY or icon == BadgeStyle.COUNTRY_GERMANY or icon == BadgeStyle.COUNTRY_FRANCE or icon == BadgeStyle.BRAND_ALBANY or icon == BadgeStyle.BRAND_ANNIS or icon == BadgeStyle.BRAND_BANSHEE or icon == BadgeStyle.BRAND_BENEFACTOR or icon == BadgeStyle.BRAND_BF or icon == BadgeStyle.BRAND_BOLLOKAN or icon == BadgeStyle.BRAND_BRAVADO or icon == BadgeStyle.BRAND_BRUTE or icon == BadgeStyle.BRAND_BUCKINGHAM or icon == BadgeStyle.BRAND_CANIS or icon == BadgeStyle.BRAND_CHARIOT or icon == BadgeStyle.BRAND_CHEVAL or icon == BadgeStyle.BRAND_CLASSIQUE or icon == BadgeStyle.BRAND_COIL or icon == BadgeStyle.BRAND_DECLASSE or icon == BadgeStyle.BRAND_DEWBAUCHEE or icon == BadgeStyle.BRAND_DILETTANTE or icon == BadgeStyle.BRAND_DINKA or icon == BadgeStyle.BRAND_DUNDREARY or icon == BadgeStyle.BRAND_EMPORER or icon == BadgeStyle.BRAND_ENUS or icon == BadgeStyle.BRAND_FATHOM or icon == BadgeStyle.BRAND_GALIVANTER or icon == BadgeStyle.BRAND_GROTTI or icon == BadgeStyle.BRAND_HIJAK or icon == BadgeStyle.BRAND_HVY or icon == BadgeStyle.BRAND_IMPONTE or icon == BadgeStyle.BRAND_INVETERO or icon == BadgeStyle.BRAND_JACKSHEEPE or icon == BadgeStyle.BRAND_JOBUILT or icon == BadgeStyle.BRAND_KARIN or icon == BadgeStyle.BRAND_LAMPADATI or icon == BadgeStyle.BRAND_MAIBATSU or icon == BadgeStyle.BRAND_MAMMOTH or icon == BadgeStyle.BRAND_MTL or icon == BadgeStyle.BRAND_NAGASAKI or icon == BadgeStyle.BRAND_OBEY or icon == BadgeStyle.BRAND_OCELOT or icon == BadgeStyle.BRAND_OVERFLOD or icon == BadgeStyle.BRAND_PED or icon == BadgeStyle.BRAND_PEGASSI or icon == BadgeStyle.BRAND_PFISTER or icon == BadgeStyle.BRAND_PRINCIPE or icon == BadgeStyle.BRAND_PROGEN or icon == BadgeStyle.BRAND_SCHYSTER or icon == BadgeStyle.BRAND_SHITZU or icon == BadgeStyle.BRAND_SPEEDOPHILE or icon == BadgeStyle.BRAND_STANLEY or icon == BadgeStyle.BRAND_TRUFFADE or icon == BadgeStyle.BRAND_UBERMACHT or icon == BadgeStyle.BRAND_VAPID or icon == BadgeStyle.BRAND_VULCAR or icon == BadgeStyle.BRAND_WEENY or icon == BadgeStyle.BRAND_WESTERN or icon == BadgeStyle.BRAND_WESTERNMOTORCYCLE or icon == BadgeStyle.BRAND_WILLARD or icon == BadgeStyle.BRAND_ZIRCONIUM then
        return "mpcarhud"
    elseif icon == BadgeStyle.BRAND_GROTTI2 or icon == BadgeStyle.BRAND_LCC or icon == BadgeStyle.BRAND_PROGEN2 or icon == BadgeStyle.BRAND_RUNE then
        return "mpcarhud2"
    elseif icon == BadgeStyle.INFO then
        return "shared"
    else
        return "commonmenu"
    end
end

function GetSpriteName(icon, selected)
    if icon == BadgeStyle.AMMO then
        if selected then return "shop_ammo_icon_b" else return "shop_ammo_icon_a" end
    elseif icon == BadgeStyle.ARMOR then
        if selected then return "shop_armour_icon_b" else return "shop_armour_icon_a" end
    elseif icon == BadgeStyle.BARBER then
        if selected then return "shop_barber_icon_b" else return "shop_barber_icon_a" end
    elseif icon == BadgeStyle.BIKE then
        if selected then return "shop_garage_bike_icon_b" else return "shop_garage_bike_icon_a" end
    elseif icon == BadgeStyle.CAR then
        if selected then return "shop_garage_icon_b" else return "shop_garage_icon_a" end
    elseif icon == BadgeStyle.CASH then
        return "mp_specitem_cash"
    elseif icon == BadgeStyle.CLOTHING then
        if selected then return "shop_clothing_icon_b" else return "shop_clothing_icon_a" end
    elseif icon == BadgeStyle.COKE then
        return "mp_specitem_coke"
    elseif icon == BadgeStyle.CROWN then
        return "mp_hostcrown"
    elseif icon == BadgeStyle.FRANKLIN then
        if selected then return "shop_franklin_icon_b" else return "shop_franklin_icon_a" end
    elseif icon == BadgeStyle.GUN then
        if selected then return "shop_gunclub_icon_b" else return "shop_gunclub_icon_a" end
    elseif icon == BadgeStyle.HEALTH_HEART then
        if selected then return "shop_health_icon_b" else return "shop_health_icon_a" end
    elseif icon == BadgeStyle.HEROIN then
        return "mp_specitem_heroin"
    elseif icon == BadgeStyle.LOCK then
        return "shop_lock"
    elseif icon == BadgeStyle.MAKEUP_BRUSH then
        if selected then return "shop_makeup_icon_b" else return "shop_makeup_icon_a" end
    elseif icon == BadgeStyle.MASK then
        if selected then return "shop_mask_icon_b" else return "shop_mask_icon_a" end
    elseif icon == BadgeStyle.MEDAL_BRONZE then
        return "mp_medal_bronze"
    elseif icon == BadgeStyle.MEDAL_GOLD then
        return "mp_medal_gold"
    elseif icon == BadgeStyle.MEDAL_SILVER then
        return "mp_medal_silver"
    elseif icon == BadgeStyle.METH then
        return "mp_specitem_meth"
    elseif icon == BadgeStyle.MICHAEL then
        if selected then return "shop_michael_icon_b" else return "shop_michael_icon_a" end
    elseif icon == BadgeStyle.STAR then
        return "shop_new_star"
    elseif icon == BadgeStyle.TATTOO then
        if selected then return "shop_tattoos_icon_b" else return "shop_tattoos_icon_a" end
    elseif icon == BadgeStyle.TICK then
        return "shop_tick_icon"
    elseif icon == BadgeStyle.TREVOR then
        if selected then return "shop_trevor_icon_b" else return "shop_trevor_icon_a" end
    elseif icon == BadgeStyle.WARNING then
        return "mp_alerttriangle"
    elseif icon == BadgeStyle.WEED then
        return "mp_specitem_weed"
    elseif icon == BadgeStyle.MALE then
        return "leaderboard_male_icon"
    elseif icon == BadgeStyle.FEMALE then
        return "leaderboard_female_icon"
    elseif icon == BadgeStyle.LOCK_ARENA then
        return "shop_lock_arena"
    elseif icon == BadgeStyle.ADVERSARY then
        return "adversary"
    elseif icon == BadgeStyle.BASE_JUMPING then
        return "base_jumping"
    elseif icon == BadgeStyle.BRIEFCASE then
        return "capture_the_flag"
    elseif icon == BadgeStyle.MISSION_STAR then
        return "custom_mission"
    elseif icon == BadgeStyle.DEATHMATCH then
        return "deathmatch"
    elseif icon == BadgeStyle.CASTLE then
        return "gang_attack"
    elseif icon == BadgeStyle.TROPHY then
        return "last_team_standing"
    elseif icon == BadgeStyle.RACE_FLAG then
        return "race"
    elseif icon == BadgeStyle.RACE_FLAG_PLANE then
        return "race_air"
    elseif icon == BadgeStyle.RACE_FLAG_BICYCLE then
        return "race_bicycle"
    elseif icon == BadgeStyle.RACE_FLAG_PERSON then
        return "race_foot"
    elseif icon == BadgeStyle.RACE_FLAG_CAR then
        return "race_land"
    elseif icon == BadgeStyle.RACE_FLAG_BOAT_ANCHOR then
        return "race_water"
    elseif icon == BadgeStyle.ROCKSTAR then
        return "rockstar"
    elseif icon == BadgeStyle.STUNT then
        return "stunt"
    elseif icon == BadgeStyle.STUNT_PREMIUM then
        return "stunt_premium"
    elseif icon == BadgeStyle.RACE_FLAG_STUNT_JUMP then
        return "stunt_race"
    elseif icon == BadgeStyle.SHIELD then
        return "survival"
    elseif icon == BadgeStyle.TEAM_DEATHMATCH then
        return "team_deathmatch"
    elseif icon == BadgeStyle.VEHICLE_DEATHMATCH then
        return "vehicle_deathmatch"
    elseif icon == BadgeStyle.MP_AMMO_PICKUP then
        return "ammo_pickup"
    elseif icon == BadgeStyle.MP_AMMO then
        return "mp_anim_ammo"
    elseif icon == BadgeStyle.MP_CASH then
        return "mp_anim_cash"
    elseif icon == BadgeStyle.MP_RP then
        return "mp_anim_rp"
    elseif icon == BadgeStyle.MP_SPECTATING then
        return "spectating"
    elseif icon == BadgeStyle.SALE then
        return "saleicon"
    elseif icon == BadgeStyle.GLOBE_WHITE or icon == BadgeStyle.GLOBE_RED or icon == BadgeStyle.GLOBE_BLUE or icon == BadgeStyle.GLOBE_YELLOW or icon == BadgeStyle.GLOBE_GREEN or icon == BadgeStyle.GLOBE_ORANGE then
        return "globe"
    elseif icon == BadgeStyle.INV_ARM_WRESTLING then
        return "arm_wrestling"
    elseif icon == BadgeStyle.INV_BASEJUMP then
        return "basejump"
    elseif icon == BadgeStyle.INV_MISSION then
        return "custom_mission"
    elseif icon == BadgeStyle.INV_DARTS then
        return "darts"
    elseif icon == BadgeStyle.INV_DEATHMATCH then
        return "deathmatch"
    elseif icon == BadgeStyle.INV_DRUG then
        return "drug_trafficking"
    elseif icon == BadgeStyle.INV_CASTLE then
        return "gang_attack"
    elseif icon == BadgeStyle.INV_GOLF then
        return "golf"
    elseif icon == BadgeStyle.INV_BIKE then
        return "mp_specitem_bike"
    elseif icon == BadgeStyle.INV_BOAT then
        return "mp_specitem_boat"
    elseif icon == BadgeStyle.INV_ANCHOR then
        return "mp_specitem_boatpickup"
    elseif icon == BadgeStyle.INV_CAR then
        return "mp_specitem_car"
    elseif icon == BadgeStyle.INV_DOLLAR then
        return "mp_specitem_cash"
    elseif icon == BadgeStyle.INV_COKE then
        return "mp_specitem_coke"
    elseif icon == BadgeStyle.INV_KEY then
        return "mp_specitem_cuffkeys"
    elseif icon == BadgeStyle.INV_DATA then
        return "mp_specitem_data"
    elseif icon == BadgeStyle.INV_HELI then
        return "mp_specitem_heli"
    elseif icon == BadgeStyle.INV_HEORIN then
        return "mp_specitem_heroin"
    elseif icon == BadgeStyle.INV_KEYCARD then
        return "mp_specitem_keycard"
    elseif icon == BadgeStyle.INV_METH then
        return "mp_specitem_meth"
    elseif icon == BadgeStyle.INV_BRIEFCASE then
        return "mp_specitem_package"
    elseif icon == BadgeStyle.INV_LINK then
        return "mp_specitem_partnericon"
    elseif icon == BadgeStyle.INV_PERSON then
        return "mp_specitem_ped"
    elseif icon == BadgeStyle.INV_PLANE then
        return "mp_specitem_plane"
    elseif icon == BadgeStyle.INV_PLANE2 then
        return "mp_specitem_plane2"
    elseif icon == BadgeStyle.INV_QUESTIONMARK then
        return "mp_specitem_randomobject"
    elseif icon == BadgeStyle.INV_REMOTE then
        return "mp_specitem_remote"
    elseif icon == BadgeStyle.INV_SAFE then
        return "mp_specitem_safe"
    elseif icon == BadgeStyle.INV_STEER_WHEEL then
        return "mp_specitem_steer_wheel"
    elseif icon == BadgeStyle.INV_WEAPON then
        return "mp_specitem_weapons"
    elseif icon == BadgeStyle.INV_WEED then
        return "mp_specitem_weed"
    elseif icon == BadgeStyle.INV_RACE_FLAG_PLANE then
        return "race_air"
    elseif icon == BadgeStyle.INV_RACE_FLAG_BICYCLE then
        return "race_bike"
    elseif icon == BadgeStyle.INV_RACE_FLAG_BOAT_ANCHOR then
        return "race_boat"
    elseif icon == BadgeStyle.INV_RACE_FLAG_PERSON then
        return "race_foot"
    elseif icon == BadgeStyle.INV_RACE_FLAG_CAR then
        return "race_land"
    elseif icon == BadgeStyle.INV_RACE_FLAG_HELMET then
        return "race_offroad"
    elseif icon == BadgeStyle.INV_SHOOTING_RANGE then
        return "shooting_range"
    elseif icon == BadgeStyle.INV_SURVIVAL then
        return "survival"
    elseif icon == BadgeStyle.INV_TEAM_DEATHMATCH then
        return "team_deathmatch"
    elseif icon == BadgeStyle.INV_TENNIS then
        return "tennis"
    elseif icon == BadgeStyle.INV_VEHICLE_DEATHMATCH then
        return "vehicle_deathmatch"
    elseif icon == BadgeStyle.AUDIO_MUTE then
        return "leaderboard_audio_mute"
    elseif icon == BadgeStyle.AUDIO_INACTIVE then
        return "leaderboard_audio_inactive"
    elseif icon == BadgeStyle.AUDIO_VOL1 then
        return "leaderboard_audio_1"
    elseif icon == BadgeStyle.AUDIO_VOL2 then
        return "leaderboard_audio_2"
    elseif icon == BadgeStyle.AUDIO_VOL3 then
        return "leaderboard_audio_3"
    elseif icon == BadgeStyle.COUNTRY_USA then
        return "vehicle_card_icons_flag_usa"
    elseif icon == BadgeStyle.COUNTRY_UK then
        return "vehicle_card_icons_flag_uk"
    elseif icon == BadgeStyle.COUNTRY_SWEDEN then
        return "vehicle_card_icons_flag_sweden"
    elseif icon == BadgeStyle.COUNTRY_KOREA then
        return "vehicle_card_icons_flag_korea"
    elseif icon == BadgeStyle.COUNTRY_JAPAN then
        return "vehicle_card_icons_flag_japan"
    elseif icon == BadgeStyle.COUNTRY_ITALY then
        return "vehicle_card_icons_flag_italy"
    elseif icon == BadgeStyle.COUNTRY_GERMANY then
        return "vehicle_card_icons_flag_germany"
    elseif icon == BadgeStyle.COUNTRY_FRANCE then
        return "vehicle_card_icons_flag_france"
    elseif icon == BadgeStyle.BRAND_ALBANY then
        return "albany"
    elseif icon == BadgeStyle.BRAND_ANNIS then
        return "annis"
    elseif icon == BadgeStyle.BRAND_BANSHEE then
        return "banshee"
    elseif icon == BadgeStyle.BRAND_BENEFACTOR then
        return "benefactor"
    elseif icon == BadgeStyle.BRAND_BF then
        return "bf"
    elseif icon == BadgeStyle.BRAND_BOLLOKAN then
        return "bollokan"
    elseif icon == BadgeStyle.BRAND_BRAVADO then
        return "bravado"
    elseif icon == BadgeStyle.BRAND_BRUTE then
        return "brute"
    elseif icon == BadgeStyle.BRAND_BUCKINGHAM then
        return "buckingham"
    elseif icon == BadgeStyle.BRAND_CANIS then
        return "canis"
    elseif icon == BadgeStyle.BRAND_CHARIOT then
        return "chariot"
    elseif icon == BadgeStyle.BRAND_CHEVAL then
        return "cheval"
    elseif icon == BadgeStyle.BRAND_CLASSIQUE then
        return "classique"
    elseif icon == BadgeStyle.BRAND_COIL then
        return "coil"
    elseif icon == BadgeStyle.BRAND_DECLASSE then
        return "declasse"
    elseif icon == BadgeStyle.BRAND_DEWBAUCHEE then
        return "dewbauchee"
    elseif icon == BadgeStyle.BRAND_DILETTANTE then
        return "dilettante"
    elseif icon == BadgeStyle.BRAND_DINKA then
        return "dinka"
    elseif icon == BadgeStyle.BRAND_DUNDREARY then
        return "dundreary"
    elseif icon == BadgeStyle.BRAND_EMPORER then
        return "emporer"
    elseif icon == BadgeStyle.BRAND_ENUS then
        return "enus"
    elseif icon == BadgeStyle.BRAND_FATHOM then
        return "fathom"
    elseif icon == BadgeStyle.BRAND_GALIVANTER then
        return "galivanter"
    elseif icon == BadgeStyle.BRAND_GROTTI then
        return "grotti"
    elseif icon == BadgeStyle.BRAND_HIJAK then
        return "hijak"
    elseif icon == BadgeStyle.BRAND_HVY then
        return "hvy"
    elseif icon == BadgeStyle.BRAND_IMPONTE then
        return "imponte"
    elseif icon == BadgeStyle.BRAND_INVETERO then
        return "invetero"
    elseif icon == BadgeStyle.BRAND_JACKSHEEPE then
        return "jacksheepe"
    elseif icon == BadgeStyle.BRAND_JOBUILT then
        return "jobuilt"
    elseif icon == BadgeStyle.BRAND_KARIN then
        return "karin"
    elseif icon == BadgeStyle.BRAND_LAMPADATI then
        return "lampadati"
    elseif icon == BadgeStyle.BRAND_MAIBATSU then
        return "maibatsu"
    elseif icon == BadgeStyle.BRAND_MAMMOTH then
        return "mammoth"
    elseif icon == BadgeStyle.BRAND_MTL then
        return "mtl"
    elseif icon == BadgeStyle.BRAND_NAGASAKI then
        return "nagasaki"
    elseif icon == BadgeStyle.BRAND_OBEY then
        return "obey"
    elseif icon == BadgeStyle.BRAND_OCELOT then
        return "ocelot"
    elseif icon == BadgeStyle.BRAND_OVERFLOD then
        return "overflod"
    elseif icon == BadgeStyle.BRAND_PED then
        return "ped"
    elseif icon == BadgeStyle.BRAND_PEGASSI then
        return "pegassi"
    elseif icon == BadgeStyle.BRAND_PFISTER then
        return "pfister"
    elseif icon == BadgeStyle.BRAND_PRINCIPE then
        return "principe"
    elseif icon == BadgeStyle.BRAND_PROGEN then
        return "progen"
    elseif icon == BadgeStyle.BRAND_SCHYSTER then
        return "schyster"
    elseif icon == BadgeStyle.BRAND_SHITZU then
        return "shitzu"
    elseif icon == BadgeStyle.BRAND_SPEEDOPHILE then
        return "speedophile"
    elseif icon == BadgeStyle.BRAND_STANLEY then
        return "stanley"
    elseif icon == BadgeStyle.BRAND_TRUFFADE then
        return "truffade"
    elseif icon == BadgeStyle.BRAND_UBERMACHT then
        return "ubermacht"
    elseif icon == BadgeStyle.BRAND_VAPID then
        return "vapid"
    elseif icon == BadgeStyle.BRAND_VULCAR then
        return "vulcar"
    elseif icon == BadgeStyle.BRAND_WEENY then
        return "weeny"
    elseif icon == BadgeStyle.BRAND_WESTERN then
        return "western"
    elseif icon == BadgeStyle.BRAND_WESTERNMOTORCYCLE then
        return "westernmotorcycle"
    elseif icon == BadgeStyle.BRAND_WILLARD then
        return "willard"
    elseif icon == BadgeStyle.BRAND_ZIRCONIUM then
        return "zirconium"
    elseif icon == BadgeStyle.BRAND_GROTTI2 then
        return "grotti_2"
    elseif icon == BadgeStyle.BRAND_LCC then
        return "lcc"
    elseif icon == BadgeStyle.BRAND_PROGEN2 then
        return "progen"
    elseif icon == BadgeStyle.BRAND_RUNE then
        return "rune"
    elseif icon == BadgeStyle.INFO then
        return "info_icon_32"
    else
        return ""
    end
end
---@enum Colours
Colours = {
    NONE = -1,
    HUD_COLOUR_PURE_WHITE = 0,
    HUD_COLOUR_WHITE = 1,
    HUD_COLOUR_BLACK = 2,
    HUD_COLOUR_GREY = 3,
    HUD_COLOUR_GREYLIGHT = 4,
    HUD_COLOUR_GREYDARK = 5,
    HUD_COLOUR_RED = 6,
    HUD_COLOUR_REDLIGHT = 7,
    HUD_COLOUR_REDDARK = 8,
    HUD_COLOUR_BLUE = 9,
    HUD_COLOUR_BLUELIGHT = 10,
    HUD_COLOUR_BLUEDARK = 11,
    HUD_COLOUR_YELLOW = 12,
    HUD_COLOUR_YELLOWLIGHT = 13,
    HUD_COLOUR_YELLOWDARK = 14,
    HUD_COLOUR_ORANGE = 15,
    HUD_COLOUR_ORANGELIGHT = 16,
    HUD_COLOUR_ORANGEDARK = 17,
    HUD_COLOUR_GREEN = 18,
    HUD_COLOUR_GREENLIGHT = 19,
    HUD_COLOUR_GREENDARK = 20,
    HUD_COLOUR_PURPLE = 21,
    HUD_COLOUR_PURPLELIGHT = 22,
    HUD_COLOUR_PURPLEDARK = 23,
    HUD_COLOUR_PINK = 24,
    HUD_COLOUR_RADAR_HEALTH = 25,
    HUD_COLOUR_RADAR_ARMOUR = 26,
    HUD_COLOUR_RADAR_DAMAGE = 27,
    HUD_COLOUR_NET_PLAYER1 = 28,
    HUD_COLOUR_NET_PLAYER2 = 29,
    HUD_COLOUR_NET_PLAYER3 = 30,
    HUD_COLOUR_NET_PLAYER4 = 31,
    HUD_COLOUR_NET_PLAYER5 = 32,
    HUD_COLOUR_NET_PLAYER6 = 33,
    HUD_COLOUR_NET_PLAYER7 = 34,
    HUD_COLOUR_NET_PLAYER8 = 35,
    HUD_COLOUR_NET_PLAYER9 = 36,
    HUD_COLOUR_NET_PLAYER10 = 37,
    HUD_COLOUR_NET_PLAYER11 = 38,
    HUD_COLOUR_NET_PLAYER12 = 39,
    HUD_COLOUR_NET_PLAYER13 = 40,
    HUD_COLOUR_NET_PLAYER14 = 41,
    HUD_COLOUR_NET_PLAYER15 = 42,
    HUD_COLOUR_NET_PLAYER16 = 43,
    HUD_COLOUR_NET_PLAYER17 = 44,
    HUD_COLOUR_NET_PLAYER18 = 45,
    HUD_COLOUR_NET_PLAYER19 = 46,
    HUD_COLOUR_NET_PLAYER20 = 47,
    HUD_COLOUR_NET_PLAYER21 = 48,
    HUD_COLOUR_NET_PLAYER22 = 49,
    HUD_COLOUR_NET_PLAYER23 = 50,
    HUD_COLOUR_NET_PLAYER24 = 51,
    HUD_COLOUR_NET_PLAYER25 = 52,
    HUD_COLOUR_NET_PLAYER26 = 53,
    HUD_COLOUR_NET_PLAYER27 = 54,
    HUD_COLOUR_NET_PLAYER28 = 55,
    HUD_COLOUR_NET_PLAYER29 = 56,
    HUD_COLOUR_NET_PLAYER30 = 57,
    HUD_COLOUR_NET_PLAYER31 = 58,
    HUD_COLOUR_NET_PLAYER32 = 59,
    HUD_COLOUR_SIMPLEBLIP_DEFAULT = 60,
    HUD_COLOUR_MENU_BLUE = 61,
    HUD_COLOUR_MENU_GREY_LIGHT = 62,
    HUD_COLOUR_MENU_BLUE_EXTRA_DARK = 63,
    HUD_COLOUR_MENU_YELLOW = 64,
    HUD_COLOUR_MENU_YELLOW_DARK = 65,
    HUD_COLOUR_MENU_GREEN = 66,
    HUD_COLOUR_MENU_GREY = 67,
    HUD_COLOUR_MENU_GREY_DARK = 68,
    HUD_COLOUR_MENU_HIGHLIGHT = 69,
    HUD_COLOUR_MENU_STANDARD = 70,
    HUD_COLOUR_MENU_DIMMED = 71,
    HUD_COLOUR_MENU_EXTRA_DIMMED = 72,
    HUD_COLOUR_BRIEF_TITLE = 73,
    HUD_COLOUR_MID_GREY_MP = 74,
    HUD_COLOUR_NET_PLAYER1_DARK = 75,
    HUD_COLOUR_NET_PLAYER2_DARK = 76,
    HUD_COLOUR_NET_PLAYER3_DARK = 77,
    HUD_COLOUR_NET_PLAYER4_DARK = 78,
    HUD_COLOUR_NET_PLAYER5_DARK = 79,
    HUD_COLOUR_NET_PLAYER6_DARK = 80,
    HUD_COLOUR_NET_PLAYER7_DARK = 81,
    HUD_COLOUR_NET_PLAYER8_DARK = 82,
    HUD_COLOUR_NET_PLAYER9_DARK = 83,
    HUD_COLOUR_NET_PLAYER10_DARK = 84,
    HUD_COLOUR_NET_PLAYER11_DARK = 85,
    HUD_COLOUR_NET_PLAYER12_DARK = 86,
    HUD_COLOUR_NET_PLAYER13_DARK = 87,
    HUD_COLOUR_NET_PLAYER14_DARK = 88,
    HUD_COLOUR_NET_PLAYER15_DARK = 89,
    HUD_COLOUR_NET_PLAYER16_DARK = 90,
    HUD_COLOUR_NET_PLAYER17_DARK = 91,
    HUD_COLOUR_NET_PLAYER18_DARK = 92,
    HUD_COLOUR_NET_PLAYER19_DARK = 93,
    HUD_COLOUR_NET_PLAYER20_DARK = 94,
    HUD_COLOUR_NET_PLAYER21_DARK = 95,
    HUD_COLOUR_NET_PLAYER22_DARK = 96,
    HUD_COLOUR_NET_PLAYER23_DARK = 97,
    HUD_COLOUR_NET_PLAYER24_DARK = 98,
    HUD_COLOUR_NET_PLAYER25_DARK = 99,
    HUD_COLOUR_NET_PLAYER26_DARK = 100,
    HUD_COLOUR_NET_PLAYER27_DARK = 101,
    HUD_COLOUR_NET_PLAYER28_DARK = 102,
    HUD_COLOUR_NET_PLAYER29_DARK = 103,
    HUD_COLOUR_NET_PLAYER30_DARK = 104,
    HUD_COLOUR_NET_PLAYER31_DARK = 105,
    HUD_COLOUR_NET_PLAYER32_DARK = 106,
    HUD_COLOUR_BRONZE = 107,
    HUD_COLOUR_SILVER = 108,
    HUD_COLOUR_GOLD = 109,
    HUD_COLOUR_PLATINUM = 110,
    HUD_COLOUR_GANG1 = 111,
    HUD_COLOUR_GANG2 = 112,
    HUD_COLOUR_GANG3 = 113,
    HUD_COLOUR_GANG4 = 114,
    HUD_COLOUR_SAME_CREW = 115,
    HUD_COLOUR_FREEMODE = 116,
    HUD_COLOUR_PAUSE_BG = 117,
    HUD_COLOUR_FRIENDLY = 118,
    HUD_COLOUR_ENEMY = 119,
    HUD_COLOUR_LOCATION = 120,
    HUD_COLOUR_PICKUP = 121,
    HUD_COLOUR_PAUSE_SINGLEPLAYER = 122,
    HUD_COLOUR_FREEMODE_DARK = 123,
    HUD_COLOUR_INACTIVE_MISSION = 124,
    HUD_COLOUR_DAMAGE = 125,
    HUD_COLOUR_PINKLIGHT = 126,
    HUD_COLOUR_PM_MITEM_HIGHLIGHT = 127,
    HUD_COLOUR_SCRIPT_VARIABLE = 128,
    HUD_COLOUR_YOGA = 129,
    HUD_COLOUR_TENNIS = 130,
    HUD_COLOUR_GOLF = 131,
    HUD_COLOUR_SHOOTING_RANGE = 132,
    HUD_COLOUR_FLIGHT_SCHOOL = 133,
    HUD_COLOUR_NORTH_BLUE = 134,
    HUD_COLOUR_SOCIAL_CLUB = 135,
    HUD_COLOUR_PLATFORM_BLUE = 136,
    HUD_COLOUR_PLATFORM_GREEN = 137,
    HUD_COLOUR_PLATFORM_GREY = 138,
    HUD_COLOUR_FACEBOOK_BLUE = 139,
    HUD_COLOUR_INGAME_BG = 140,
    HUD_COLOUR_DARTS = 141,
    HUD_COLOUR_WAYPOINT = 142,
    HUD_COLOUR_MICHAEL = 143,
    HUD_COLOUR_FRANKLIN = 144,
    HUD_COLOUR_TREVOR = 145,
    HUD_COLOUR_GOLF_P1 = 146,
    HUD_COLOUR_GOLF_P2 = 147,
    HUD_COLOUR_GOLF_P3 = 148,
    HUD_COLOUR_GOLF_P4 = 149,
    HUD_COLOUR_WAYPOINTLIGHT = 150,
    HUD_COLOUR_WAYPOINTDARK = 151,
    HUD_COLOUR_PANEL_LIGHT = 152,
    HUD_COLOUR_MICHAEL_DARK = 153,
    HUD_COLOUR_FRANKLIN_DARK = 154,
    HUD_COLOUR_TREVOR_DARK = 155,
    HUD_COLOUR_OBJECTIVE_ROUTE = 156,
    HUD_COLOUR_PAUSEMAP_TINT = 157,
    HUD_COLOUR_PAUSE_DESELECT = 158,
    HUD_COLOUR_PM_WEAPONS_PURCHASABLE = 159,
    HUD_COLOUR_PM_WEAPONS_LOCKED = 160,
    HUD_COLOUR_END_SCREEN_BG = 161,
    HUD_COLOUR_CHOP = 162,
    HUD_COLOUR_PAUSEMAP_TINT_HALF = 163,
    HUD_COLOUR_NORTH_BLUE_OFFICIAL = 164,
    HUD_COLOUR_SCRIPT_VARIABLE_2 = 165,
    HUD_COLOUR_H = 166,
    HUD_COLOUR_HDARK = 167,
    HUD_COLOUR_T = 168,
    HUD_COLOUR_TDARK = 169,
    HUD_COLOUR_HSHARD = 170,
    HUD_COLOUR_CONTROLLER_MICHAEL = 171,
    HUD_COLOUR_CONTROLLER_FRANKLIN = 172,
    HUD_COLOUR_CONTROLLER_TREVOR = 173,
    HUD_COLOUR_CONTROLLER_CHOP = 174,
    HUD_COLOUR_VIDEO_EDITOR_VIDEO = 175,
    HUD_COLOUR_VIDEO_EDITOR_AUDIO = 176,
    HUD_COLOUR_VIDEO_EDITOR_TEXT = 177,
    HUD_COLOUR_HB_BLUE = 178,
    HUD_COLOUR_HB_YELLOW = 179,
    HUD_COLOUR_VIDEO_EDITOR_SCORE = 180,
    HUD_COLOUR_VIDEO_EDITOR_AUDIO_FADEOUT = 181,
    HUD_COLOUR_VIDEO_EDITOR_TEXT_FADEOUT = 182,
    HUD_COLOUR_VIDEO_EDITOR_SCORE_FADEOUT = 183,
    HUD_COLOUR_HEIST_BACKGROUND = 184,
    HUD_COLOUR_VIDEO_EDITOR_AMBIENT = 185,
    HUD_COLOUR_VIDEO_EDITOR_AMBIENT_FADEOUT = 186,
    HUD_COLOUR_GB = 187,
    HUD_COLOUR_G = 188,
    HUD_COLOUR_B = 189,
    HUD_COLOUR_LOW_FLOW = 190,
    HUD_COLOUR_LOW_FLOW_DARK = 191,
    HUD_COLOUR_G1 = 192,
    HUD_COLOUR_G2 = 193,
    HUD_COLOUR_G3 = 194,
    HUD_COLOUR_G4 = 195,
    HUD_COLOUR_G5 = 196,
    HUD_COLOUR_G6 = 197,
    HUD_COLOUR_G7 = 198,
    HUD_COLOUR_G8 = 199,
    HUD_COLOUR_G9 = 200,
    HUD_COLOUR_G10 = 201,
    HUD_COLOUR_G11 = 202,
    HUD_COLOUR_G12 = 203,
    HUD_COLOUR_G13 = 204,
    HUD_COLOUR_G14 = 205,
    HUD_COLOUR_G15 = 206,
    HUD_COLOUR_ADVERSARY = 207,
    HUD_COLOUR_DEGEN_RED = 208,
    HUD_COLOUR_DEGEN_YELLOW = 209,
    HUD_COLOUR_DEGEN_GREEN = 210,
    HUD_COLOUR_DEGEN_CYAN = 211,
    HUD_COLOUR_DEGEN_BLUE = 212,
    HUD_COLOUR_DEGEN_MAGENTA = 213,
    HUD_COLOUR_STUNT_1 = 214,
    HUD_COLOUR_STUNT_2 = 215,
    HUD_COLOUR_SPECIAL_RACE_SERIES = 216,
    HUD_COLOUR_SPECIAL_RACE_SERIES_DARK = 217,
    HUD_COLOUR_CS = 218,
    HUD_COLOUR_CS_DARK = 219,
    HUD_COLOUR_TECH_GREEN = 220,
    HUD_COLOUR_TECH_GREEN_DARK = 221,
    HUD_COLOUR_TECH_RED = 222,
    HUD_COLOUR_TECH_GREEN_VERY_DARK = 223,
}
---@enum Font
Font = {
  CHALET_LONDON = 0,
  HOUSE_SCRIPT = 1,
  MONOSPACE = 2,
  CHALET_COMPRIME_COLOGNE = 4,
  PRICEDOWN = 7
}
---@enum JobIcon
JobIcon = {
  NONE = -1,
  GTAOMission = 0,
  Deathmatch = 1,
  RaceFinish = 2,
  GTAOSurvival = 3,
  TeamDeathmatch = 4,
  Castle = 6,
  Parachute = 8,
  VehicleDeathmatch = 9,
  RaceCar = 10,
  RaceFoot = 11,
  RaceSea = 12,
  RaceBike = 13,
  RaceAir = 14,
  LastTeamStanding = 15,
  Briefcase = 16,
  RaceStunt = 18
}
---@enum JobSelectionCardIcon
JobSelectionCardIcon = {
  NONE = -1,
  CUSTOM_MISSION = 0,
  DEATHMATCH = 1,
  RACE = 2,
  SURVIVAL = 3,
  TEAM_DEATHMATCH = 4,
  GANG_ATTACK = 6,
  BASE_JUMPING = 8,
  VEHICLE_DEATHMATCH = 9,
  RACE_LAND = 10,
  RACE_FOOT = 11,
  RACE_BICYCLE = 12,
  RACE_WATER = 13,
  RACE_AIR = 14,
  LAST_TEAM_STANDING = 15,
  CAPTURE_THE_FLAG = 16,
  HEIST_PREPARATION = 17,
  HEIST = 18,
  RACE_STUNT = 19,
}
---@enum MarkerType
MarkerType = {
    UpsideDownCone = 0,
    VerticalCylinder = 1,
    ThickChevronUp = 2,
    ThinChevronUp = 3,
    CheckeredFlagRect = 4,
    CheckeredFlagCircle = 5,
    VerticleCircle = 6,
    PlaneModel = 7,
    LostMCTransparent = 8,
    LostMC = 9,
    Number0 = 10,
    Number1 = 11,
    Number2 = 12,
    Number3 = 13,
    Number4 = 14,
    Number5 = 15,
    Number6 = 16,
    Number7 = 17,
    Number8 = 18,
    Number9 = 19,
    ChevronUpx1 = 20,
    ChevronUpx2 = 21,
    ChevronUpx3 = 22,
    HorizontalCircleFat = 23,
    ReplayIcon = 24,
    HorizontalCircleSkinny = 25,
    HorizontalCircleSkinnyArrow = 26,
    HorizontalSplitArrowCircle = 27,
    DebugSphere = 28,
    DollarSign = 29,
    HorizontalBars = 30,
    WolfHead = 31,
    QuestionMark = 32,
    PlaneSymbol = 33,
    HelicopterSymbol = 34,
    BoatSymbol = 35,
    CarSymbol = 36,
    MotorcycleSymbol = 37,
    BicycleSymbol = 38,
    TruckSymbol = 39,
    ParachuteSymbol = 40,
    JetpackSymbol = 41,
    SawbladeSymbol = 42,
    VerticalRectangle = 43,
}
-- There are more characters, just don't have the time to add them all. Feel free to add them yourself and make a pull request.

---@class NotificationCharacters @Enum for notification characters (used in ShowAdvancedNotification)
NotificationCharacters = {
  Abigail = "CHAR_ABIGAIL",
  Amanda = "CHAR_AMANDA",
  Ammunation = "CHAR_AMMUNATION",
  Andreas = "CHAR_ANDREAS",
  Antonia = "CHAR_ANTONIA",
  Ashley = "CHAR_ASHLEY",
  BankOfLiberty = "CHAR_BANK_BOL",
  BankFleeca = "CHAR_BANK_FLEECA",
  BankMaze = "CHAR_BANK_MAZE",
  Barry = "CHAR_BARRY",
  Beverly = "CHAR_BEVERLY",
  BikeSite = "CHAR_BIKESITE",
  BlankEntry = "CHAR_BLANK_ENTRY",
  Blimp = "CHAR_BLIMP",
  Blocked = "CHAR_BLOCKED",
  BoatSite = "CHAR_BOATSITE",
  BrokenDownGirl = "CHAR_BROKEN_DOWN_GIRL",
  BugStars = "CHAR_BUGSTARS",
  Call911 = "CHAR_CALL911",
  LegendaryMotorsport = "CHAR_CARSITE",
  SSASuperAutos = "CHAR_CARSITE2",
  Castro = "CHAR_CASTRO",
  ChatCall = "CHAR_CHAT_CALL",
  Chef = "CHAR_CHEF",
  Cheng = "CHAR_CHENG",
  ChengSenior = "CHAR_CHENGSR",
  Chop = "CHAR_CHOP",
  Cris = "CHAR_CRIS",
  Dave = "CHAR_DAVE",
  Default = "CHAR_DEFAULT",
  Denise = "CHAR_DENISE",
  DetonateBomb = "CHAR_DETONATEBOMB",
  DetonatePhone = "CHAR_DETONATEPHONE",
  Devin = "CHAR_DEVIN",
  SubMarine = "CHAR_DIAL_A_SUB",
  Dom = "CHAR_DOM",
  DomesticGirl = "CHAR_DOMESTIC_GIRL",
  Dreyfuss = "CHAR_DREYFUSS",
  DrFriedlander = "CHAR_DR_FRIEDLANDER",
  Epsilon = "CHAR_EPSILON",
  EstateAgent = "CHAR_ESTATE_AGENT",
  Facebook = "CHAR_FACEBOOK",
  FilmNoire = "CHAR_FILMNOIR",
  Floyd = "CHAR_FLOYD",
  Franklin = "CHAR_FRANKLIN",
  FranklinTrevor = "CHAR_FRANK_TREV_CONF",
  GayMilitary = "CHAR_GAYMILITARY",
  Hao = "CHAR_HAO",
  HitcherGirl = "CHAR_HITCHER_GIRL",
  Hunter = "CHAR_HUNTER",
  Jimmy = "CHAR_JIMMY",
  JimmyBoston = "CHAR_JIMMY_BOSTON",
  Joe = "CHAR_JOE",
  Josef = "CHAR_JOSEF",
  Josh = "CHAR_JOSH",
  LamarDog = "CHAR_LAMAR",
  Lester = "CHAR_LESTER",
  Skull = "CHAR_LESTER_DEATHWISH",
  LesterFranklin = "CHAR_LEST_FRANK_CONF",
  LesterMichael = "CHAR_LEST_MIKE_CONF",
  LifeInvader = "CHAR_LIFEINVADER",
  LsCustoms = "CHAR_LS_CUSTOMS",
  LSTI = "CHAR_LS_TOURIST_BOARD",
  Manuel = "CHAR_MANUEL",
  Marnie = "CHAR_MARNIE",
  Martin = "CHAR_MARTIN",
  MaryAnn = "CHAR_MARY_ANN",
  Maude = "CHAR_MAUDE",
  Mechanic = "CHAR_MECHANIC",
  Michael = "CHAR_MICHAEL",
  MichaelFranklin = "CHAR_MIKE_FRANK_CONF",
  MichaelTrevor = "CHAR_MIKE_TREV_CONF",
  WarStock = "CHAR_MILSITE",
  Minotaur = "CHAR_MINOTAUR",
  Molly = "CHAR_MOLLY",
  MorsMutual = "CHAR_MP_MORS_MUTUAL",
  ArmyContact = "CHAR_MP_ARMY_CONTACT",
  Brucie = "CHAR_MP_BRUCIE",
  FibContact = "CHAR_MP_FIB_CONTACT",
  RockStarLogo = "CHAR_MP_FM_CONTACT",
  Gerald = "CHAR_MP_GERALD",
  Julio = "CHAR_MP_JULIO",
  MechanicChinese = "CHAR_MP_MECHANIC",
  MerryWeather = "CHAR_MP_MERRYWEATHER",
  Unicorn = "CHAR_MP_STRIPCLUB_PR",
  Mom = "CHAR_MRS_THORNHILL",
  MrsThornhill = "CHAR_MRS_THORNHILL",
  PatriciaTrevor = "CHAR_PATRICIA",
  PegasusDelivery = "CHAR_PEGASUS_DELIVERY",
  ElitasTravel = "CHAR_PLANESITE",
  Sasquatch = "CHAR_SASQUATCH",
  Simeon = "CHAR_SIMEON",
  SocialClub = "CHAR_SOCIAL_CLUB",
  Solomon = "CHAR_SOLOMON",
  Taxi = "CHAR_TAXI",
  Trevor = "CHAR_TREVOR",
  YouTube = "CHAR_YOUTUBE",
  Wade = "CHAR_WADE",
}
---@enum NotificationIcon
NotificationIcon = {
  ChatBox = 1,
  Email = 2,
  AdDFriendRequest = 3,
  RightJumpingArrow = 7,
  RPIcon = 8,
  DollarIcon = 9
}
---@enum NotificationType
NotificationType = {
  Default = 0,
  Bubble = 1,
  Mail = 2,
  FriendRequest = 3,
  Default2 = 4,
  Reply = 7,
  ReputationPoints = 8,
  Money = 9
}
---@enum ScoreDisplayType
ScoreDisplayType = {
  NUMBER_ONLY = 0,
  ICON = 1,
  NONE = 2
}
---@enum ScoreRightIconType
ScoreRightIconType = {
  NONE = 0,
  INACTIVE_HEADSET = 48,
  MUTED_HEADSET = 49,
  ACTIVE_HEADSET = 47,
  RANK_FREEMODE = 65,
  KICK = 64,
  LOBBY_DRIVER = 79,
  LOBBY_CODRIVER = 80,
  SPECTATOR = 66,
  BOUNTY = 115,
  DEAD = 116,
  DPAD_GANG_CEO = 121,
  DPAD_GANG_BIKER = 122,
  DPAD_DOWN_TARGET = 123
}
Marker = setmetatable({}, Marker)
Marker.__index = Marker
Marker.__call = function()
    return "Marker"
end

---@class Marker
---@field public Type MarkerType
---@field public Position vector3
---@field public Scale vector3
---@field public Direction vector3
---@field public Rotation vector3
---@field public Distance number
---@field public Color table<number, number, number, number> -- {Red, Green, Blue, Alpha}
---@field public PlaceOnGround boolean
---@field public BobUpDown boolean
---@field public Rotate boolean
---@field public FaceCamera boolean
---@field public IsInMarker boolean
---@field public CheckZ boolean
---@field private _height number
---@field public Draw fun(self: Marker):nil
---@field public IsInRange fun(self: Marker):boolean

---Creates a new marker
---@param type MarkerType?
---@param position vector3
---@param scale vector3
---@param distance number
---@param color table<number, number, number, number> -- {R: Red, G: Green, B: Blue, A: Alpha}
---@param placeOnGround boolean
---@param bobUpDown boolean
---@param rotate boolean
---@param faceCamera boolean
---@param checkZ boolean
---@return Marker
function Marker.New(type, position, scale, distance, color, placeOnGround, bobUpDown, rotate, faceCamera, checkZ)
    local _marker = {
        Type = type or MarkerType.UpsideDownCone,
        Position = position or vector3(0, 0, 0),
        Scale = scale or vector3(1, 1, 1),
        Direction = vector3(0, 0, 0),
        Rotation = vector3(0, 0, 0),
        Distance = distance or 250.0,
        Color = color,
        PlaceOnGround = placeOnGround,
        BobUpDown = bobUpDown or false,
        Rotate = rotate or false,
        FaceCamera = faceCamera and not rotate or false,
        _height = 0,
        IsInMarker = false,
        CheckZ = checkZ or false,
    }
    return setmetatable(_marker, Marker)
end

function Marker:Draw()
    -- [Position.Z != _height] means that we make the check only if we change position
    -- but if we change position and the Z is still the same then we don't need to check again
    -- We draw it with _height + 0.1 to ensure marker drawing (like horizontal circles)

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped, true)
    if (self:IsInRange() and self.PlaceOnGround and self.Position.z ~= self._height + 0.1) then
        local success, height = GetGroundZFor_3dCoord(self.Position.x, self.Position.y, self.Position.z, false)
        self._height = height
        if (success) then
            self.Position = vector3(self.Position.x, self.Position.y, height + 0.03)
        end
    end

    DrawMarker(self.Type, self.Position.x, self.Position.y, self.Position.z, self.Direction.x, self.Direction.y,
        self.Direction.z, self.Rotation.x, self.Rotation.y, self.Rotation.z, self.Scale.x, self.Scale.y, self.Scale.z,
        ---@diagnostic disable-next-line: param-type-mismatch -- Texture dictionary and texture name have to be strings but cannot be empty strings
        self.Color.R, self.Color.G, self.Color.B, self.Color.A, self.BobUpDown, self.FaceCamera, 2, self.Rotate, nil, nil,
        false)
    local posDif = pedPos - self.Position
    local distanceSquared = (posDif.x * posDif.x) + (posDif.y * posDif.y) + (posDif.z * posDif.z)
    if (self.CheckZ) then
        -- unknown reason as to why this stopped working as well as it should.
        -- self.IsInMarker = distanceSquared <= (self.Scale.x / 2) ^ 2 or distanceSquared <= (self.Scale.y / 2) ^ 2 or
        --     distanceSquared <= (self.Scale.z / 2) ^ 2
        self.IsInMarker = IsVectorInsideSphere(pedPos, self.Position, self.Scale)
    else
        self.IsInMarker = distanceSquared <= (self.Scale.x / 2) ^ 2 or distanceSquared <= (self.Scale.y / 2) ^ 2
    end
end

---Returns true if the player is in range of the marker
---@return boolean
function Marker:IsInRange()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local dist = vector3(0, 0, 0)
    if (self.CheckZ) then
        dist = #(pos - self.Position) --[[@as vector3]]       -- Use Z
    else
        dist = #(pos.xy - self.Position.xy) --[[@as vector3]] -- Do not use Z
    end
    return dist <= self.Distance
end

---Sets the marker color
function Marker:SetColor(r, g, b, a)
    self.Color = { R = r, G = g, B = b, A = a }
end
Notifications = setmetatable({}, Notifications)
Notifications.__index = Notifications
Notifications.__call = function()
    return "Notifications", "Notifications"
end

---@class Notifications
---@field private _handle number
---@field public Type table<string, number>
---@field public Color table<string, number>
---@field public NotificationIcon table<string, number>
---@field public IconChars table<string, string>
---@field public Hide fun(self:Notifications):nil
---@field public ShowNotification fun(self:Notifications, msg:string, blink:boolean, showInBrief:boolean):nil
---@field public ShowNotificationWithColor fun(self:Notifications, msg:string, color:Colours, blink:boolean, showInBrief:boolean):nil
---@field public ShowHelpNotification fun(self:Notifications, helpText:string, duration:number):nil
---@field public ShowFloatingHelpNotification fun(self:Notifications, helpText:string, coords:vector3, duration:number):nil
---@field public ShowAdvancedNotification fun(self:Notifications, title:string, subtitle:string, body:string, character:NotificationCharacters, icon:NotificationIcon, backgroundColor:Colours, flashColoir:table<number, number, number>, blink:boolean, type:NotificationType, sound:string):nil
---@field public ShowStatNotification fun(self:Notifications, newProgress:number, oldProgress:number, title:string, blink:boolean, showInBrief:boolean):nil
---@field public ShowVSNotification fun(self:Notifications, ped1:number, ped2:number, colour1:Colours, colour2:Colours):nil
---@field public DrawText3D fun(self:Notifications, coords:vector3, colour:Colours, text:string, font:Font, size:number):nil
---@field public DrawText fun(self:Notifications, x:number, y:number, text:string, colour:Colours, font:Font, textAlignment:number, shadow:boolean, outline:boolean, wordWrap:number):nil
---@field public ShowSubtitle fun(self:Notifications, text:string, duration:number):nil

---Creates a new Notifications object
---@return Notifications
function Notifications.New()
    local _notif = {
        _handle = 0,
        Type = {
            Default = 0,
            Bubble = 1,
            Mail = 2,
            FriendRequest = 3,
            Default2 = 4,
            Reply = 7,
            ReputationPoints = 8,
            Money = 9
        },
        Color = {
            Red = 27,
            Yellow = 50,
            Gold = 12,
            GreenLight = 46,
            GreenDark = 47,
            Cyan = 48,
            Blue = 51,
            Purple = 49,
            Rose = 45
        },
        NotificationIcon = {
            ChatBox = 1,
            Email = 2,
            AdDFriendRequest = 3,
            RightJumpingArrow = 7,
            RPIcon = 8,
            DollarIcon = 9
        },
        IconChars = {
            Abigail = "CHAR_ABIGAIL",
            Amanda = "CHAR_AMANDA",
            Ammunation = "CHAR_AMMUNATION",
            Andreas = "CHAR_ANDREAS",
            Antonia = "CHAR_ANTONIA",
            Ashley = "CHAR_ASHLEY",
            BankOfLiberty = "CHAR_BANK_BOL",
            BankFleeca = "CHAR_BANK_FLEECA",
            BankMaze = "CHAR_BANK_MAZE",
            Barry = "CHAR_BARRY",
            Beverly = "CHAR_BEVERLY",
            BikeSite = "CHAR_BIKESITE",
            BlankEntry = "CHAR_BLANK_ENTRY",
            Blimp = "CHAR_BLIMP",
            Blocked = "CHAR_BLOCKED",
            BoatSite = "CHAR_BOATSITE",
            BrokenDownGirl = "CHAR_BROKEN_DOWN_GIRL",
            BugStars = "CHAR_BUGSTARS",
            Call911 = "CHAR_CALL911",
            LegendaryMotorsport = "CHAR_CARSITE",
            SSASuperAutos = "CHAR_CARSITE2",
            Castro = "CHAR_CASTRO",
            ChatCall = "CHAR_CHAT_CALL",
            Chef = "CHAR_CHEF",
            Cheng = "CHAR_CHENG",
            ChengSenior = "CHAR_CHENGSR",
            Chop = "CHAR_CHOP",
            Cris = "CHAR_CRIS",
            Dave = "CHAR_DAVE",
            Default = "CHAR_DEFAULT",
            Denise = "CHAR_DENISE",
            DetonateBomb = "CHAR_DETONATEBOMB",
            DetonatePhone = "CHAR_DETONATEPHONE",
            Devin = "CHAR_DEVIN",
            SubMarine = "CHAR_DIAL_A_SUB",
            Dom = "CHAR_DOM",
            DomesticGirl = "CHAR_DOMESTIC_GIRL",
            Dreyfuss = "CHAR_DREYFUSS",
            DrFriedlander = "CHAR_DR_FRIEDLANDER",
            Epsilon = "CHAR_EPSILON",
            EstateAgent = "CHAR_ESTATE_AGENT",
            Facebook = "CHAR_FACEBOOK",
            FilmNoire = "CHAR_FILMNOIR",
            Floyd = "CHAR_FLOYD",
            Franklin = "CHAR_FRANKLIN",
            FranklinTrevor = "CHAR_FRANK_TREV_CONF",
            GayMilitary = "CHAR_GAYMILITARY",
            Hao = "CHAR_HAO",
            HitcherGirl = "CHAR_HITCHER_GIRL",
            Hunter = "CHAR_HUNTER",
            Jimmy = "CHAR_JIMMY",
            JimmyBoston = "CHAR_JIMMY_BOSTON",
            Joe = "CHAR_JOE",
            Josef = "CHAR_JOSEF",
            Josh = "CHAR_JOSH",
            LamarDog = "CHAR_LAMAR",
            Lester = "CHAR_LESTER",
            Skull = "CHAR_LESTER_DEATHWISH",
            LesterFranklin = "CHAR_LEST_FRANK_CONF",
            LesterMichael = "CHAR_LEST_MIKE_CONF",
            LifeInvader = "CHAR_LIFEINVADER",
            LsCustoms = "CHAR_LS_CUSTOMS",
            LSTI = "CHAR_LS_TOURIST_BOARD",
            Manuel = "CHAR_MANUEL",
            Marnie = "CHAR_MARNIE",
            Martin = "CHAR_MARTIN",
            MaryAnn = "CHAR_MARY_ANN",
            Maude = "CHAR_MAUDE",
            Mechanic = "CHAR_MECHANIC",
            Michael = "CHAR_MICHAEL",
            MichaelFranklin = "CHAR_MIKE_FRANK_CONF",
            MichaelTrevor = "CHAR_MIKE_TREV_CONF",
            WarStock = "CHAR_MILSITE",
            Minotaur = "CHAR_MINOTAUR",
            Molly = "CHAR_MOLLY",
            MorsMutual = "CHAR_MP_MORS_MUTUAL",
            ArmyContact = "CHAR_MP_ARMY_CONTACT",
            Brucie = "CHAR_MP_BRUCIE",
            FibContact = "CHAR_MP_FIB_CONTACT",
            RockStarLogo = "CHAR_MP_FM_CONTACT",
            Gerald = "CHAR_MP_GERALD",
            Julio = "CHAR_MP_JULIO",
            MechanicChinese = "CHAR_MP_MECHANIC",
            MerryWeather = "CHAR_MP_MERRYWEATHER",
            Unicorn = "CHAR_MP_STRIPCLUB_PR",
            Mom = "CHAR_MRS_THORNHILL",
            MrsThornhill = "CHAR_MRS_THORNHILL",
            PatriciaTrevor = "CHAR_PATRICIA",
            PegasusDelivery = "CHAR_PEGASUS_DELIVERY",
            ElitasTravel = "CHAR_PLANESITE",
            Sasquatch = "CHAR_SASQUATCH",
            Simeon = "CHAR_SIMEON",
            SocialClub = "CHAR_SOCIAL_CLUB",
            Solomon = "CHAR_SOLOMON",
            Taxi = "CHAR_TAXI",
            Trevor = "CHAR_TREVOR",
            YouTube = "CHAR_YOUTUBE",
            Wade = "CHAR_WADE",
        }
    }
    return setmetatable(_notif, Notifications)
end

---Hide the notification
---@return nil
function Notifications:Hide()
    ThefeedRemoveItem(self._handle)
end

---Show a notification
---@param msg string @The message
---@param blink boolean @Should the notification blink?
---@param showInBrief boolean @Should the notification be saved in the brief?
---@return nil
function Notifications:ShowNotification(msg, blink, showInBrief)
    AddTextEntry("ScaleformUINotification", msg)
    BeginTextCommandThefeedPost("ScaleformUINotification")
    EndTextCommandThefeedPostTicker(blink, showInBrief)
end

---Show a notification with a color
---@param msg string @The message
---@param color Colours @The color
---@param blink boolean @Should the notification blink?
---@param showInBrief boolean @Should the notification be saved in the brief?
---@return nil
function Notifications:ShowNotificationWithColor(msg, color, blink, showInBrief)
    AddTextEntry("ScaleformUINotification", msg)
    BeginTextCommandThefeedPost("ScaleformUINotification")
    ThefeedSetNextPostBackgroundColor(color)
    EndTextCommandThefeedPostTicker(blink, showInBrief)
end

---Show a help notification
---@param helpText string @The help text
---@param duration number @The duration in milliseconds to display help notification, set this to nil if you want to control when it is shown
---@return nil
function Notifications:ShowHelpNotification(helpText, duration)
    AddTextEntry("ScaleformUIHelpText", helpText)
    if (duration ~= nil) then
        if (duration > 5000) then duration = 5000 end
        BeginTextCommandDisplayHelp("ScaleformUIHelpText")
        EndTextCommandDisplayHelp(0, false, true, duration)
    else
        DisplayHelpTextThisFrame("ScaleformUIHelpText", false)
    end
end

---Show a floating help notification
---@param msg string @The message
---@param coords vector3 @The coordinates of the notification
---@param duration number @The display duration in milliseconds (-1 for infinite)
---@return nil
function Notifications:ShowFloatingHelpNotification(msg, coords, duration)
    if (duration == nil) then duration = -1 end
    AddTextEntry("ScaleformUIFloatingHelpText", msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("ScaleformUIFloatingHelpText")
    EndTextCommandDisplayHelp(2, false, false, duration)
end

---Show an advanced notification
---@param title string @The title
---@param subtitle string @The subtitle
---@param text string @The body of the nofitication
---@param characterIcon string @The character to be displayed in the notification, use the NotificationCharacters
---@param notificationIcon NotificationIcon @The icon
---@param backgroundColour Colours @The background color
---@param flashColour {R:number, G:number, B:number, A:number} @The flash color (RGBA)
---@param blink boolean @Should the notification blink?
---@param notificationType NotificationType @The type of notification
---@param sound boolean @Should the notification play a sound?
---@see NotificationCharacters
---@see NotificationIcon
---@see Colours
---@see NotificationType
---@return nil
function Notifications:ShowAdvancedNotification(title, subtitle, text, characterIcon, notificationIcon, backgroundColour,
                                                flashColour, blink, notificationType,
                                                sound)
    if (notificationType == nil) then notificationType = self.Type.Default end
    if (characterIcon == nil) then characterIcon = self.IconChars.Default end
    if (notificationIcon == nil) then notificationIcon = self.NotificationIcon.Default end
    if (backgroundColour == nil) then backgroundColour = -1 end
    if (blink == nil) then blink = false end
    AddTextEntry("ScaleformUIAdvancedNotification", text)
    BeginTextCommandThefeedPost("ScaleformUIAdvancedNotification")
    AddTextComponentSubstringPlayerName(text)
    if (backgroundColour and backgroundColour ~= -1) then
        ThefeedSetNextPostBackgroundColor(backgroundColour)
    end
    if (flashColour and not blink) then
        ThefeedSetAnimpostfxColor(flashColour.R, flashColour.G, flashColour.B, flashColour.A)
    end
    if (sound) then PlaySoundFrontend(-1, "DELETE", "HUD_DEATHMATCH_SOUNDSET", true); end
    return EndTextCommandThefeedPostMessagetext(characterIcon, characterIcon, true, notificationType, title, subtitle)
end

-- TODO: Investigate if newProgress should be a boolean or a number for EndTextCommandThefeedPostStats
---Show a stat notification
---@param newProgress number @The new progress
---@param oldProgress number @The old progress
---@param title string @The title
---@param blink boolean @Should the notification blink?
---@param showInBrief boolean @Should the notification be saved in the brief?
---@return nil
function Notifications:ShowStatNotification(newProgress, oldProgress, title, blink, showInBrief)
    if (blink == nil) then blink = false end
    if (showInBrief == nil) then showInBrief = false end
    AddTextEntry("ScaleformUIStatsNotification", title)
    local handle = RegisterPedheadshot(PlayerPedId())
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do Citizen.Wait(0) end
    local txd = GetPedheadshotTxdString(handle)
    BeginTextCommandThefeedPost("PS_UPDATE")
    AddTextComponentInteger(newProgress)
    ---@diagnostic disable-next-line: param-type-mismatch -- newProgress is a number but the native wants a boolean
    EndTextCommandThefeedPostStats("ScaleformUIStatsNotification", 2, newProgress, oldProgress, false, txd, txd)
    EndTextCommandThefeedPostTicker(blink, showInBrief)
    UnregisterPedheadshot(handle)
end

---Show a versuses notification (2 heads)
---@param ped1 number @The first ped
---@param ped2 number @The second ped
---@param color1 Colours @The color of the first ped
---@param color2 Colours @The color of the second ped
---@see Colours
---@return nil
function Notifications:ShowVSNotification(ped1, ped2, color1, color2)
    local handle_1 = RegisterPedheadshot(ped1)
    while not IsPedheadshotReady(handle_1) or not IsPedheadshotValid(handle_1) do Citizen.Wait(0) end
    local txd_1 = GetPedheadshotTxdString(handle_1)

    local handle_2 = RegisterPedheadshot(ped2)
    while not IsPedheadshotReady(handle_2) or not IsPedheadshotValid(handle_2) do Citizen.Wait(0) end
    local txd_2 = GetPedheadshotTxdString(handle_2)

    BeginTextCommandThefeedPost("")
    ---@diagnostic disable-next-line: redundant-parameter -- This is a bug in the linter
    EndTextCommandThefeedPostVersusTu(txd_1, txd_1, 12, txd_2, txd_2, 1, color1, color2)

    UnregisterPedheadshot(handle_1)
    UnregisterPedheadshot(handle_2)
end

---Put floating text in the world
---@param coords vector3 @The coordinates of the text
---@param color {R:number, G:number, B:number, A:number} @The color of the text (RGBA)
---@param text string @The text
---@param font Font @The font
---@param size number @The size
---@see Font
---@return nil
function Notifications:DrawText3D(coords, color, text, font, size)
    local cam = GetGameplayCamCoord()
    local dist = #(coords - cam)
    local scaleInternal = (1 / dist) * size
    local fov = (1 / GetGameplayCamFov()) * 100
    local _scale = scaleInternal * fov
    SetTextScale(0.1 * _scale, 0.15 * _scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(color.R, color.G, color.B, color.A)
    SetTextDropshadow(5, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0, 0)
    ClearDrawOrigin()
end

---Draw text on the screen
---@param x number @The x position of the text (0-1)
---@param y number @The y position of the text (0-1)
---@param text string @The text
---@param color {R:number, G:number, B:number, A:number} @The color of the text (RGBA)
---@param font Font @The font
---@param textAlignment number @The text alignment
---@param shadow boolean @Should the text have a shadow?
---@param outline boolean @Should the text have an outline?
---@param wrap number @The wrap
---@see Font
---@return nil
function Notifications:DrawText(x, y, text, color, font, textAlignment, shadow, outline, wrap)
    if (color == nil) then color = { r = 255, g = 255, b = 255, a = 255 } end
    if (font == nil) then font = 4 end
    if (textAlignment == nil) then textAlignment = 1 end
    if (shadow == nil) then shadow = false end
    if (outline == nil) then outline = false end
    if (wrap == nil) then wrap = 0 end

    local screenw, screenh = GetActiveScreenResolution()
    local height = 1080
    local ratio = screenw / screenh
    local width = height * ratio

    SetTextFont(font)
    SetTextScale(0.0, 0.5)
    SetTextColour(color.r, color.g, color.b, color.a)
    if (shadow) then SetTextDropShadow() end
    if (outline) then SetTextOutline() end
    if (wrap ~= 0) then
        local xsize = (x + wrap) / width
        SetTextWrap(x, xsize)
    end
    if (textAlignment == 0) then
        SetTextCentre(true)
    elseif (textAlignment == 2) then
        SetTextRightJustify(true)
        SetTextWrap(0, x)
    end
    BeginTextCommandDisplayText("jamyfafi")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

---Add subtitle to the screen
---@param msg string @The message
---@param duration number @The duration of how long the subtitle will be displayed (in ms)
---@return nil
function Notifications:ShowSubtitle(msg, duration)
    if (duration == nil) then duration = 2500 end
    AddTextEntry("ScaleformUISubtitle", msg)
    BeginTextCommandPrint("ScaleformUISubtitle")
    EndTextCommandPrint(duration, true)
end
UIMenuCheckboxItem = setmetatable({}, UIMenuCheckboxItem)
UIMenuCheckboxItem.__index = UIMenuCheckboxItem
UIMenuCheckboxItem.__call = function() return "UIMenuItem", "UIMenuCheckboxItem" end

---@class UIMenuCheckboxItem : UIMenuItem
---@field public Base UIMenuItem

---New
---@param Text string
---@param Check boolean
---@param Description string
function UIMenuCheckboxItem.New(Text, Check, checkStyle, Description, color, highlightColor, textColor,
                                highlightedTextColor)
    local _UIMenuCheckboxItem = {
        Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        _Checked = ToBool(Check),
        Panels = {},
        SidePanel = nil,
        CheckBoxStyle = checkStyle or 0,
        ItemId = 2,
        OnCheckboxChanged = function(menu, item, checked)
        end,
    }
    return setmetatable(_UIMenuCheckboxItem, UIMenuCheckboxItem)
end

function UIMenuCheckboxItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

---SetParentMenu
---@param Menu table
function UIMenuCheckboxItem:SetParentMenu(Menu)
    if Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuCheckboxItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool boolean
function UIMenuCheckboxItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

function UIMenuCheckboxItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

---Hovered
---@param bool boolean
function UIMenuCheckboxItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuCheckboxItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

---Description
---@param str string
function UIMenuCheckboxItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

function UIMenuCheckboxItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---Text
---@param Text string
function UIMenuCheckboxItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuCheckboxItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuCheckboxItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuCheckboxItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuCheckboxItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---LeftBadge
function UIMenuCheckboxItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuCheckboxItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuCheckboxItem:RightLabel()
    error("This item does not support a right label")
end

function UIMenuCheckboxItem:Checked(bool)
    if bool ~= nil then
        self._Checked = ToBool(bool)
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            local it = IndexOf(self.Base.ParentMenu.Items, self) - 1
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false, it, self._Checked)
        end
    else
        return self._Checked
    end
end
UIMenuDynamicListItem = setmetatable({}, UIMenuDynamicListItem)
UIMenuDynamicListItem.__index = UIMenuDynamicListItem
UIMenuDynamicListItem.__call = function() return "UIMenuItem", "UIMenuDynamicListItem" end

---@class UIMenuDynamicListItem : UIMenuItem
---@field Base UIMenuItem
---@field Panels table
---@field SidePanel table
---@field _currentItem string
---@field Callback function
---@field ItemId number
---@field OnListSelected function

---New
---@param Text string
---@param Description string
---@param StartingItem string
---@param callback function
---@param color number|117
---@param highlightColor number|1
---@param textColor number|1
---@param highlightedTextColor number|2
function UIMenuDynamicListItem.New(Text, Description, StartingItem, callback, color, highlightColor, textColor,
                                   highlightedTextColor)
    local _UIMenuDynamicListItem = {
        Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        Panels = {},
        SidePanel = nil,
        _currentItem = StartingItem,
        Callback = callback,
        ItemId = 1,
        OnListSelected = function(menu, item, newindex)
        end,
    }
    return setmetatable(_UIMenuDynamicListItem, UIMenuDynamicListItem)
end

function UIMenuDynamicListItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

function UIMenuDynamicListItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

function UIMenuDynamicListItem:CurrentListItem(item)
    if item == nil then
        return tostring(self._currentItem)
    else
        self._currentItem = item
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_LISTITEM_LIST", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, tostring(self._currentItem), 0)
        end
    end
end

---SetParentMenu
---@param Menu table
function UIMenuDynamicListItem:SetParentMenu(Menu)
    if Menu ~= nil and Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuDynamicListItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool boolean
function UIMenuDynamicListItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

---Hovered
---@param bool boolean
function UIMenuDynamicListItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuDynamicListItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

---Description
---@param str string
function UIMenuDynamicListItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

function UIMenuDynamicListItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---Text
---@param Text string
function UIMenuDynamicListItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuDynamicListItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuDynamicListItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuDynamicListItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuDynamicListItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---LeftBadge
function UIMenuDynamicListItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuDynamicListItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuDynamicListItem:RightLabel()
    error("This item does not support a right label")
end

---AddPanel
---@param Panel table
function UIMenuDynamicListItem:AddPanel(Panel)
    if Panel() == "UIMenuPanel" then
        self.Panels[#self.Panels + 1] = Panel
        Panel:SetParentItem(self)
    end
end

---RemovePanelAt
---@param Index table
function UIMenuDynamicListItem:RemovePanelAt(Index)
    if tonumber(Index) then
        if self.Panels[Index] then
            table.remove(self.Panels, tonumber(Index))
        end
    end
end

---FindPanelIndex
---@param Panel table
function UIMenuDynamicListItem:FindPanelIndex(Panel)
    if Panel() == "UIMenuPanel" then
        for Index = 1, #self.Panels do
            if self.Panels[Index] == Panel then
                return Index
            end
        end
    end
    return nil
end

---FindPanelItem
function UIMenuDynamicListItem:FindPanelItem()
    for Index = #self.Items, 1, -1 do
        if self.Items[Index].Panel then
            return Index
        end
    end
    return nil
end
UIMenuItem = setmetatable({}, UIMenuItem)
UIMenuItem.__index = UIMenuItem
UIMenuItem.__call = function()
    return "UIMenuItem", "UIMenuItem"
end

---@alias UIMenuPanel
---| '"UIMenuGridPanel"' # Add a UIMenuGridPanel to the item
---| '"UIMenuPercentagePanel"' # Add a UIMenuPercentagePanel to the item
---| '"UIMenuStatisticsPanel"' # Add a UIMenuStatisticsPanel to the item
---| '"UIMenuColorPanel"' # Add a UIMenuColorPanel to the item

---@class UIMenuItem
---@field _label string
---@field _Description string
---@field _labelFont table
---@field _Selected boolean
---@field _Hovered boolean
---@field _Enabled boolean
---@field blinkDescription boolean
---@field _formatLeftLabel string
---@field _rightLabel string
---@field _formatRightLabel string
---@field _rightBadge number
---@field _leftBadge number
---@field _mainColor number
---@field _highlightColor number
---@field _textColor number
---@field _highlightedTextColor number
---@field _itemData table
---@field ParentMenu UIMenu
---@field Panels table<UIMenuGridPanel|UIMenuPercentagePanel|UIMenuStatisticsPanel|UIMenuColorPanel>
---@field SidePanel UIMenuPanel -- UIMenuGridPanel, UIMenuPercentagePanel, UIMenuStatisticsPanel, UIMenuColorPanel
---@field ItemId number
---@field Activated fun(self:UIMenuItem, menu:UIMenu, item:UIMenuItem):boolean
---@field SetParentMenu fun(self:UIMenuItem, menu:UIMenu?):UIMenu?

---New
---@param text string
---@param description string
---@param color number|117
---@param highlightColor number|1
---@param textColor number|1
---@param highlightedTextColor number|2
function UIMenuItem.New(text, description, color, highlightColor, textColor, highlightedTextColor)
    _UIMenuItem = {
        _label = tostring(text) or "",
        _Description = tostring(description) or "",
        _labelFont = { "$Font2", 0 },
        _Selected = false,
        _Hovered = false,
        _Enabled = true,
        blinkDescription = false,
        _formatLeftLabel = tostring(text) or "",
        _rightLabel = "",
        _formatRightLabel = "",
        _rightBadge = 0,
        _leftBadge = 0,
        _mainColor = color or 117,
        _highlightColor = highlightColor or 1,
        _textColor = textColor or 1,
        _highlightedTextColor = highlightedTextColor or 2,
        _itemData = {},
        ParentMenu = nil,
        Panels = {},
        SidePanel = nil,
        ItemId = 0,
        Activated = function(menu, item)
        end,
    }
    return setmetatable(_UIMenuItem, UIMenuItem)
end

function UIMenuItem:ItemData(data)
    if data == nil then
        return self._itemData
    else
        self._itemData = data
    end
end

-- not supported on Lobby and Pause menu yet
function UIMenuItem:LabelFont(fontTable)
    if fontTable == nil then
        return self._labelFont
    else
        self._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self._labelFont[1], self._labelFont[2])
        end
    end
end

---Set the Parent Menu of the Item
---@param menu UIMenu
---@return UIMenu? -- returns the parent menu if no menu is passed, if a menu is passed it returns the menu if it was set successfully
function UIMenuItem:SetParentMenu(menu)
    if menu == nil then
        return self.ParentMenu
    end

    if menu ~= nil and menu() == "UIMenu" then
        self.ParentMenu = menu
        return self.ParentMenu
    else
        print("^1ScaleformUI Error: ^7UIMenuItem:SetParentMenu(menu) - menu passed in is not a UIMenu");
        return nil
    end
end

function UIMenuItem:Selected(bool, item)
    if bool ~= nil then
        if item == nil then item = self end

        self._Selected = ToBool(bool)
        if self._Selected then
            if (self._highlightedTextColor == 2) then
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~l~")
                end
                if self._formatLeftLabel:find("~", 1, true) then
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~w~", "~l~")
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~s~", "~l~")
                end
                if not string.IsNullOrEmpty(self._formatRightLabel) then
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~l~")
                    end
                    if self._formatRightLabel:find("~", 1, true) then
                        self._formatRightLabel = self._formatRightLabel:gsub("~w~", "~l~")
                        self._formatRightLabel = self._formatRightLabel:gsub("~s~", "~l~")
                    end
                end
            end
        else
            if (self._textColor == 1) then
                self._formatLeftLabel = self._formatLeftLabel:gsub("~l~", "~s~")
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~s~")
                end
                if not string.IsNullOrEmpty(self._formatRightLabel) then
                    self._formatRightLabel = self._formatRightLabel:gsub("~l~", "~s~")
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~s~")
                    end
                end
            end
        end
        if self.ParentMenu ~= nil and self._textColor == 1 and self._highlightedTextColor == 2 and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABELS", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._formatLeftLabel, self._formatRightLabel)
        end
    else
        return self._Selected
    end
end

function UIMenuItem:Hovered(bool)
    if bool ~= nil then
        self._Hovered = ToBool(bool)
    else
        return self._Hovered
    end
end

function UIMenuItem:Enabled(bool, item)
    if bool ~= nil then
        if item == nil then item = self end
        self._Enabled = ToBool(bool)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_ITEM", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._Enabled)
        end
    else
        return self._Enabled
    end
end

function UIMenuItem:Activated(menu, item)
    self.Activated(menu, item)
end

function UIMenuItem:Description(str, item)
    if tostring(str) and str ~= nil then
        if item == nil then item = self end
        self._Description = tostring(str)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            AddTextEntry("desc_{" .. IndexOf(self.ParentMenu.Items, item) .. "}", str)
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_ITEM_DESCRIPTION", false, IndexOf(self.ParentMenu.Items, item) - 1, "desc_{" .. IndexOf(self.ParentMenu.Items, item) .. "}")
        end
    else
        return self._Description
    end
end

function UIMenuItem:MainColor(color, item)
    if (color) then
        if item == nil then item = self end
        self._mainColor = color
        if (self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._mainColor
    end
end

function UIMenuItem:TextColor(color, item)
    if (color) then
        if item == nil then item = self end
        self._textColor = color
        if (self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._textColor
    end
end

function UIMenuItem:HighlightColor(color, item)
    if (color) then
        if item == nil then item = self end
        self._highlightColor = color
        if (self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._highlightColor
    end
end

function UIMenuItem:HighlightedTextColor(color, item)
    if (color) then
        if item == nil then item = self end
        self._highlightedTextColor = color
        if (self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._highlightedTextColor
    end
end

function UIMenuItem:Label(Text, item)
    if tostring(Text) and Text ~= nil then
        if item == nil then item = self end
        self._label = (tostring(Text))
        self._formatLeftLabel = (tostring(Text))
        if self:Selected() then
            if (self._highlightedTextColor == 2) then
                if self._formatLeftLabel:find("~") then
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~w~", "~l~")
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~s~", "~l~")
                    if not self._formatLeftLabel:StartsWith("~") then
                        self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~l~")
                    end
                end
            end
        else
            if (self._textColor == 1) then
                self._formatLeftLabel = self._formatLeftLabel:gsub("~l~", "~s~")
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~s~")
                end
            end
        end
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() and self._textColor == 1 and self._highlightedTextColor == 2 then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_LABEL", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._formatLeftLabel)
        end
    else
        return self._label
    end
end

function UIMenuItem:RightLabel(Text)
    if tostring(Text) and Text ~= nil then
        self._rightLabel = tostring(Text)
        self._formatRightLabel = tostring(Text)
        if self:Selected() then
            if (self._highlightedTextColor == 2) then
                if self._formatRightLabel:find("~") then
                    self._formatRightLabel = self._formatRightLabel:gsub("~w~", "~l~")
                    self._formatRightLabel = self._formatRightLabel:gsub("~s~", "~l~")
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~l~")
                    end
                end
            end
        else
            if (self._textColor == 1) then
                self._formatRightLabel = self._formatRightLabel:gsub("~l~", "~s~")
                if not self._formatRightLabel:StartsWith("~") then
                    self._formatRightLabel = self._formatRightLabel:Insert(0, "~s~")
                end
            end
        end
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() and self._textColor == 1 and self._highlightedTextColor == 2 then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", false, IndexOf(self.ParentMenu.Items, self) - 1,
                self._formatRightLabel)
        end
    else
        return self._rightLabel
    end
end

function UIMenuItem:RightBadge(Badge, item)
    if tonumber(Badge) then
        if item == nil then item = self end
        self._rightBadge = tonumber(Badge)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._rightBadge)
        end
    else
        return self._rightBadge
    end
end

function UIMenuItem:LeftBadge(Badge, item)
    if tonumber(Badge) then
        if item == nil then item = self end
        self._leftBadge = tonumber(Badge)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self._leftBadge)
        end
    else
        return self._leftBadge
    end
end

function UIMenuItem:AddPanel(Panel)
    if Panel() == "UIMenuPanel" then
        self.Panels[#self.Panels + 1] = Panel
        Panel:SetParentItem(self)
    end
end

function UIMenuItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

function UIMenuItem:RemoveSidePanel()
    self.SidePanel = nil
    if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
        ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_SIDE_PANEL_TO_ITEM", false,
            IndexOf(self.ParentMenu.Items, self) - 1)
    end
end

function UIMenuItem:RemovePanelAt(Index)
    if tonumber(Index) then
        if self.Panels[Index] then
            table.remove(self.Panels, tonumber(Index))
            ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_PANEL", false, IndexOf(self.ParentMenu.Items, self) - 1,
                Index - 1)
        end
    end
end

function UIMenuItem:FindPanelIndex(Panel)
    if Panel() == "UIMenuPanel" then
        for Index = 1, #self.Panels do
            if self.Panels[Index] == Panel then
                return Index
            end
        end
    end
    return nil
end

function UIMenuItem:FindPanelItem()
    for Index = #self.Items, 1, -1 do
        if self.Items[Index].Panel then
            return Index
        end
    end
    return nil
end

function UIMenuItem:BlinkDescription(bool, item)
    if bool ~= nil then
        if item == nil then item = self end
        self.blinkDescription = bool
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_BLINK_DESC", false, IndexOf(self.ParentMenu.Items, item) - 1,
                self.blinkDescription)
        end
    else
        return self.blinkDescription
    end
end
UIMenuListItem = setmetatable({}, UIMenuListItem)
UIMenuListItem.__index = UIMenuListItem
UIMenuListItem.__call = function() return "UIMenuItem", "UIMenuListItem" end

---@class UIMenuListItem : UIMenuItem
---@field public Base UIMenuItem
---@field public AddPanel fun(self:UIMenuListItem, item:UIMenuStatisticsPanel|UIMenuPercentagePanel|UIMenuColorPanel|UIMenuGridPanel):nil

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
function UIMenuListItem.New(Text, Items, Index, Description, color, highlightColor, textColor, highlightedTextColor)
    if type(Items) ~= "table" then Items = {} end
    if Index == 0 then Index = 1 end
    local _UIMenuListItem = {
        Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        Items = Items,
        _Index = tonumber(Index) or 1,
        Panels = {},
        SidePanel = nil,
        ItemId = 1,
        OnListChanged = function(menu, item, newindex)
        end,
        OnListSelected = function(menu, item, newindex)
        end,
    }
    return setmetatable(_UIMenuListItem, UIMenuListItem)
end

function UIMenuListItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

---SetParentMenu
---@param Menu table
function UIMenuListItem:SetParentMenu(Menu)
    if Menu ~= nil and Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuListItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

function UIMenuListItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool boolean
function UIMenuListItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

---Hovered
---@param bool boolean
function UIMenuListItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuListItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

---Description
---@param str string
function UIMenuListItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(str, self)
    else
        return self.Base._Description
    end
end

function UIMenuListItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---Text
---@param Text string
function UIMenuListItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuListItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuListItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuListItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuListItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---Index
---@param Index table
function UIMenuListItem:Index(Index)
    if tonumber(Index) then
        if Index > #self.Items then
            self._Index = 1
        elseif Index < 1 then
            self._Index = #self.Items
        else
            self._Index = Index
        end
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, self._Index - 1)
        end
    else
        return self._Index
    end
end

---ItemToIndex
---@param Item table
function UIMenuListItem:ItemToIndex(Item)
    for i = 1, #self.Items do
        if type(Item) == type(self.Items[i]) and Item == self.Items[i] then
            return i
        elseif type(self.Items[i]) == "table" and (type(Item) == type(self.Items[i].Name) or type(Item) == type(self.Items[i].Value)) and (Item == self.Items[i].Name or Item == self.Items[i].Value) then
            return i
        end
    end
end

---IndexToItem
---@param Index number
function UIMenuListItem:IndexToItem(Index)
    if tonumber(Index) then
        if tonumber(Index) == 0 then Index = 1 end
        if self.Items[tonumber(Index)] then
            return self.Items[tonumber(Index)]
        end
    end
end

---LeftBadge
function UIMenuListItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuListItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuListItem:RightLabel()
    error("This item does not support a right label")
end

---AddPanel
---@param panel UIMenuStatisticsPanel|UIMenuPercentagePanel|UIMenuColorPanel|UIMenuGridPanel
function UIMenuListItem:AddPanel(panel)
    if panel() == "UIMenuPanel" then
        self.Panels[#self.Panels + 1] = panel
        ---@diagnostic disable-next-line: param-type-mismatch
        panel:SetParentItem(self)
    end
end

---RemovePanelAt
---@param Index table
function UIMenuListItem:RemovePanelAt(Index)
    if tonumber(Index) then
        if self.Panels[Index] then
            table.remove(self.Panels, tonumber(Index))
        end
    end
end

---FindPanelIndex
---@param Panel table
function UIMenuListItem:FindPanelIndex(Panel)
    if Panel() == "UIMenuPanel" then
        for Index = 1, #self.Panels do
            if self.Panels[Index] == Panel then
                return Index
            end
        end
    end
    return nil
end

---FindPanelItem
function UIMenuListItem:FindPanelItem()
    for Index = #self.Items, 1, -1 do
        if self.Items[Index].Panel then
            return Index
        end
    end
    return nil
end

function UIMenuListItem:ChangeList(list)
    if type(list) ~= "table" then return end
    self.Items = {}
    self.Items = list
    if self.Base.ParentMenu:Visible() then
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_LISTITEM_LIST", false,
            IndexOf(self.Base.ParentMenu.Items, self) - 1, table.concat(self.Items, ","), self._Index - 1)
    end
end
UIMenuProgressItem = setmetatable({}, UIMenuProgressItem)
UIMenuProgressItem.__index = UIMenuProgressItem
UIMenuProgressItem.__call = function() return "UIMenuItem", "UIMenuProgressItem" end

---@class UIMenuProgressItem : UIMenuItem
---@field public Base UIMenuItem

---New
---@param Text string
---@param Max number
---@param Index number
---@param Description string
---@param sliderColor number
---@param color number
---@param highlightColor number
---@param textColor number
---@param highlightedTextColor number
---@param backgroundSliderColor number
function UIMenuProgressItem.New(Text, Max, Index, Description, sliderColor, color, highlightColor, textColor,
                                highlightedTextColor, backgroundSliderColor)
    local _UIMenuProgressItem = {
        Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        _Max = Max or 100,
        _Multiplier = 5,
        _Index = Index or 0,
        Panels = {},
        SidePanel = nil,
        SliderColor = sliderColor or 116,
        BackgroundSliderColor = backgroundSliderColor or 117,
        ItemId = 4,
        OnProgressChanged = function(menu, item, newindex)
        end,
        OnProgressSelected = function(menu, item, newindex)
        end,
    }

    return setmetatable(_UIMenuProgressItem, UIMenuProgressItem)
end

function UIMenuProgressItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

function UIMenuProgressItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

---SetParentMenu
---@param Menu table
function UIMenuProgressItem:SetParentMenu(Menu)
    if Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuProgressItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool number
function UIMenuProgressItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

---Hovered
---@param bool boolean
function UIMenuProgressItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuProgressItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

---Description
---@param str string
function UIMenuProgressItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

---Text
---@param Text string
function UIMenuProgressItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuProgressItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuProgressItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuProgressItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuProgressItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuProgressItem:SliderColor(color)
    if (color) then
        self.SliderColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor,
                self.SliderColor)
        end
    else
        return self.SliderColor
    end
end

function UIMenuProgressItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---Index
---@param Index table
function UIMenuProgressItem:Index(Index)
    if tonumber(Index) then
        if Index > self._Max then
            self._Index = self._Max
        elseif Index < 0 then
            self._Index = 0
        else
            self._Index = Index
        end
        self.OnProgressChanged(self._Index)
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, self._Index)
        end
    else
        return self._Index
    end
end

---LeftBadge
function UIMenuProgressItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuProgressItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuProgressItem:RightLabel()
    error("This item does not support a right label")
end
UIMenuSeperatorItem = setmetatable({}, UIMenuSeperatorItem)
UIMenuSeperatorItem.__index = UIMenuSeperatorItem
UIMenuSeperatorItem.__call = function() return "UIMenuItem", "UIMenuSeperatorItem" end

---@class UIMenuSeperatorItem : UIMenuItem
---@field public Base UIMenuItem

---New
---@param Text string
---@param jumpable boolean
---@param mainColor number|117
---@param highlightColor number|1
---@param textColor number|1
---@param highlightedTextColor number|2
function UIMenuSeperatorItem.New(Text, jumpable, mainColor, highlightColor, textColor, highlightedTextColor)
    local _UIMenuSeperatorItem = {
        Base = UIMenuItem.New(Text or "", "", mainColor or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        Panels = {},
        SidePanel = nil,
        Jumpable = jumpable,
        ItemId = 6
    }
    return setmetatable(_UIMenuSeperatorItem, UIMenuSeperatorItem)
end

function UIMenuSeperatorItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

---SetParentMenu
---@param Menu table
function UIMenuSeperatorItem:SetParentMenu(Menu)
    if Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuSeperatorItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

---Description
---@param str string
function UIMenuSeperatorItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

---Text
---@param Text string
function UIMenuSeperatorItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuSeperatorItem:MainColor(color)
    if color ~= nil then
        self.Base._mainColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuSeperatorItem:TextColor(color)
    if color ~= nil then
        self.Base._textColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuSeperatorItem:HighlightColor(color)
    if color ~= nil then
        self.Base._highlightColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuSeperatorItem:HighlightedTextColor(color)
    if color ~= nil then
        self.Base._highlightedTextColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---Selected
---@param bool number
function UIMenuSeperatorItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

---Hovered
---@param bool boolean
function UIMenuSeperatorItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuSeperatorItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

function UIMenuSeperatorItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---LeftBadge
function UIMenuSeperatorItem:LeftBadge()
    error("This item does not support badges")
end

---RightBadge
function UIMenuSeperatorItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuSeperatorItem:RightLabel()
    error("This item does not support a right label")
end
UIMenuSliderItem = setmetatable({}, UIMenuSliderItem)
UIMenuSliderItem.__index = UIMenuSliderItem
UIMenuSliderItem.__call = function() return "UIMenuItem", "UIMenuSliderItem" end

---@class UIMenuSliderItem : UIMenuItem
---@field public Base UIMenuItem

---New
---@param Text string
---@param Max number
---@param Multiplier number|5
---@param Index number|0
---@param Heritage boolean|false
---@param Description string
---@param sliderColor number|116
---@param color number|117
---@param highlightColor number|1
---@param textColor number|1
---@param highlightedTextColor number|2
function UIMenuSliderItem.New(Text, Max, Multiplier, Index, Heritage, Description, sliderColor, color, highlightColor,
                              textColor, highlightedTextColor)
    local _UIMenuSliderItem = {
        Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        _Index = tonumber(Index) or 0,
        _Max = tonumber(Max) or 100,
        _Multiplier = Multiplier or 5,
        _heritage = Heritage or false,
        Panels = {},
        SidePanel = nil,
        SliderColor = sliderColor or 116,
        ItemId = 3,
        OnSliderChanged = function(menu, item, newindex)
        end,
        OnSliderSelected = function(menu, item, newindex)
        end,
    }
    return setmetatable(_UIMenuSliderItem, UIMenuSliderItem)
end

function UIMenuSliderItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

---SetParentMenu
---@param Menu table
function UIMenuSliderItem:SetParentMenu(Menu)
    if Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuSliderItem:LabelFont(fontTable)
    if fontTable == nil then
        return self.Base._labelFont
    else
        self.Base._labelFont = fontTable
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABEL_FONT", false,
                IndexOf(self.ParentMenu.Items, self) - 1, self.Base._labelFont[1], self.Base._labelFont[2])
        end
    end
end

function UIMenuSliderItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool table
function UIMenuSliderItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

function UIMenuSliderItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

function UIMenuSliderItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

function UIMenuSliderItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

function UIMenuSliderItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

function UIMenuSliderItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuSliderItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuSliderItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuSliderItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuSliderItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuSliderItem:SliderColor(color)
    if (color) then
        self.SliderColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor,
                self.SliderColor)
        end
    else
        return self.SliderColor
    end
end

function UIMenuSliderItem:Index(Index)
    if Index ~= nil then
        if tonumber(Index) > self._Max then
            self._Index = self._Max
        elseif tonumber(Index) < 0 then
            self._Index = 0
        else
            self._Index = tonumber(Index)
        end
        self.OnSliderChanged(self.ParentMenu, self, self._Index)
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, self._Index)
        end
    else
        return self._Index
    end
end

function UIMenuSliderItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

function UIMenuSliderItem:RightBadge()
    error("This item does not support badges")
end

function UIMenuSliderItem:RightLabel()
    error("This item does not support a right label")
end
UIMenuStatsItem = setmetatable({}, UIMenuStatsItem)
UIMenuStatsItem.__index = UIMenuStatsItem
UIMenuStatsItem.__call = function() return "UIMenuItem", "UIMenuStatsItem" end

---@class UIMenuStatsItem : UIMenuItem
---@field public Base UIMenuItem

---New
---@param Text string
---@param Description string
---@param Index number|0
---@param barColor number|116
---@param type number|0
---@param mainColor number|117
---@param highlightColor number|1
---@param textColor number|1
---@param highlightedTextColor number|2
function UIMenuStatsItem.New(Text, Description, Index, barColor, type, mainColor, highlightColor, textColor,
                             highlightedTextColor)
    local _UIMenuStatsItem = {
        Base = UIMenuItem.New(Text or "", Description or "", mainColor or 117, highlightColor or 1, textColor or 1,
            highlightedTextColor or 2),
        _Index = Index or 0,
        Panels = {},
        SidePanel = nil,
        _Color = barColor or 116,
        _Type = type or 0,
        ItemId = 5,
        OnStatsChanged = function(menu, item, newindex)
        end,
        OnStatsSelected = function(menu, item, newindex)
        end,
    }
    return setmetatable(_UIMenuStatsItem, UIMenuStatsItem)
end

function UIMenuStatsItem:ItemData(data)
    if data == nil then
        return self.Base._itemData
    else
        self.Base._itemData = data
    end
end

---SetParentMenu
---@param Menu table
function UIMenuStatsItem:SetParentMenu(Menu)
    if Menu() == "UIMenu" then
        self.Base.ParentMenu = Menu
    else
        return self.Base.ParentMenu
    end
end

function UIMenuStatsItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType,
                sidePanel.Title,
                sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false,
                IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title,
                sidePanel.TitleColor)
        end
    end
end

---Selected
---@param bool number
function UIMenuStatsItem:Selected(bool)
    if bool ~= nil then
        self.Base:Selected(ToBool(bool), self)
    else
        return self.Base._Selected
    end
end

---Hovered
---@param bool boolean
function UIMenuStatsItem:Hovered(bool)
    if bool ~= nil then
        self.Base._Hovered = ToBool(bool)
    else
        return self.Base._Hovered
    end
end

---Enabled
---@param bool boolean
function UIMenuStatsItem:Enabled(bool)
    if bool ~= nil then
        self.Base:Enabled(bool, self)
    else
        return self.Base._Enabled
    end
end

---Description
---@param str string
function UIMenuStatsItem:Description(str)
    if tostring(str) and str ~= nil then
        self.Base:Description(tostring(str), self)
    else
        return self.Base._Description
    end
end

---Text
---@param Text string
function UIMenuStatsItem:Label(Text)
    if tostring(Text) and Text ~= nil then
        self.Base:Label(tostring(Text), self)
    else
        return self.Base:Label()
    end
end

function UIMenuStatsItem:MainColor(color)
    if (color) then
        self.Base._mainColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuStatsItem:TextColor(color)
    if (color) then
        self.Base._textColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuStatsItem:HighlightColor(color)
    if (color) then
        self.Base._highlightColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuStatsItem:HighlightedTextColor(color)
    if (color) then
        self.Base._highlightedTextColor = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuStatsItem:SliderColor(color)
    if (color) then
        self._Color = color
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1,
                self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor,
                self._Color)
        end
    else
        return self._Color
    end
end

function UIMenuStatsItem:BlinkDescription(bool)
    if bool ~= nil then
        self.Base:BlinkDescription(bool, self)
    else
        return self.Base:BlinkDescription()
    end
end

---Index
---@param Index table
function UIMenuStatsItem:Index(Index)
    if tonumber(Index) then
        if Index > 100 then
            self._Index = 100
        elseif Index < 0 then
            self._Index = 0
        else
            self._Index = Index
        end
        self.OnStatsChanged(self._Index)
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false,
                IndexOf(self.Base.ParentMenu.Items, self) - 1, self._Index)
        end
    else
        return self._Index
    end
end

---LeftBadge
function UIMenuStatsItem:LeftBadge()
    error("This item does not support badges")
end

---RightBadge
function UIMenuStatsItem:RightBadge()
    error("This item does not support badges")
end

---RightLabel
function UIMenuStatsItem:RightLabel()
    error("This item does not support a right label")
end
PlayerListColumn = setmetatable({}, PlayerListColumn)
PlayerListColumn.__index = PlayerListColumn
PlayerListColumn.__call = function()
    return "Column", "PlayerListColumn"
end

---@class PlayerListColumn
---@field private _label string
---@field private _color number
---@field private _currentSelection number
---@field public Order number
---@field public Parent function
---@field public ParentTab number
---@field public Items table<FriendItem>
---@field public OnIndexChanged fun(index: number)
---@field public AddPlayer fun(self: PlayerListColumn, item: FriendItem)

---Creates a new PlayerListColumn.
---@param label string
---@param color number|116
---@return table
function PlayerListColumn.New(label, color)
    local _data = {
        _label = label or "",
        _color = color or 116,
        _currentSelection = 0,
        Order = 0,
        Parent = nil,
        ParentTab = 0,
        Items = {} --[[@type table<number, FriendItem>]],
        OnIndexChanged = function(index)
        end
    }
    return setmetatable(_data, PlayerListColumn)
end

---Sets or gets the current selection.
---@param idx number?
---@return number
function PlayerListColumn:CurrentSelection(idx)
    if idx == nil then
        if #self.Items == 0 then
            return 1
        else
            if self._currentSelection % #self.Items == 0 then
                return 1
            else
                return (self._currentSelection % #self.Items) + 1
            end
        end
    else
        if #self.Items == 0 then
            self._currentSelection = 0
        end
        if self.Items[self:CurrentSelection()] then
            self.Items[self:CurrentSelection()]:Selected(false)
        end
        if idx < 0 then
            self._currentSelection = 0
        elseif idx > #self.Items then
            self._currentSelection = #self.Items
        else
            if #self.Items > 0 then
                self._currentSelection = 1000000 - (1000000 % #self.Items) + tonumber(idx)
            end
        end
        if self.Items[self:CurrentSelection()] then
            self.Items[self:CurrentSelection()]:Selected(true)
        end
        if self.Parent ~= nil and self.Parent:Visible() then
            local pSubT = self.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYERS_SELECTION", false,
                    self:CurrentSelection() - 1)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYERS_SELECTION", false,
                    self.ParentTab, self:CurrentSelection() - 1)
            end
        end
    end
    return self:CurrentSelection() - 1;
end

---Adds a new player to the column.
---@param item FriendItem
function PlayerListColumn:AddPlayer(item)
    item.ParentColumn = self
    item.Handle = #self.Items + 1
    self.Items[item.Handle] = item
    if self.Parent ~= nil and self.Parent:Visible() then
        local Type, SubType = item()
        if SubType == "FriendItem" then
            local pSubT = self.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_PLAYER_ITEM", false, 1, 1, item:Label(),
                    item:ItemColor(), item:ColoredTag(), item._iconL, item._boolL, item._iconR, item._boolR,
                    item:Status(),
                    item:StatusColor(), item:Rank(), item:CrewTag())
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_PLAYER_ITEM", false,
                    self.ParentTab, 1, 1, item:Label(), item:ItemColor(), item:ColoredTag(), item._iconL, item._boolL,
                    item._iconR, item._boolR, item:Status(), item:StatusColor(), item:Rank(), item:CrewTag())
            end
        end
        -- if item.Panel ~= nil then
            -- item.Panel:UpdatePanel(true)
        -- end
    end
end

---Removes a player from the column.
---@param item FriendItem
function PlayerListColumn:RemovePlayer(item)
    if item == nil then
        print("^1[ERROR] PlayerListColumn:RemovePlayer() - item is nil");
        return
    end

    local id = item.Handle
    if self.Parent ~= nil and self.Parent:Visible() then
        local item = self.Items[id]
        local Type, SubType = item()
        if SubType == "FriendItem" then
            local pSubT = self.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("REMOVE_PLAYER_ITEM", false, id - 1)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("REMOVE_PLAYERS_TAB_PLAYER_ITEM", false,
                    self.ParentTab, id - 1)
            end
        end
        -- if item.Panel ~= nil then
            -- item.Panel:UpdatePanel(true)
        -- end
    end
    table.remove(self.Items, id)
end
SettingsListColumn = setmetatable({}, SettingsListColumn)
SettingsListColumn.__index = SettingsListColumn
SettingsListColumn.__call = function()
    return "Column", "SettingsListColumn"
end

---@class SettingsListColumn
---@field private _label string
---@field private _color number
---@field private _currentSelection number
---@field private _rightLabel string
---@field public Order number
---@field public Parent function
---@field public ParentTab number
---@field public Items table<number, UIMenuItem|UIMenuListItem|UIMenuCheckboxItem|UIMenuSliderItem|UIMenuProgressItem>
---@field public OnIndexChanged fun(index: number)
---@field public AddSettings fun(self: SettingsListColumn, item: SettingsListItem)

function SettingsListColumn.New(label, color)
    local _data = {
        _label = label or "",
        _color = color or 116,
        _currentSelection = 0,
        _rightLabel = "",
        Order = 0,
        Parent = nil,
        ParentTab = 0,
        Items = {} --[[@type table<number, UIMenuItem|UIMenuListItem|UIMenuCheckboxItem|UIMenuSliderItem|UIMenuProgressItem>]],
        OnIndexChanged = function(index)
        end
    }
    return setmetatable(_data, SettingsListColumn)
end

function SettingsListColumn:CurrentSelection(idx)
    if idx == nil then
        if #self.Items == 0 then
            return 1
        else
            if self._currentSelection % #self.Items == 0 then
                return 1
            else
                return (self._currentSelection % #self.Items) + 1
            end
        end
    else
        if #self.Items == 0 then
            self._currentSelection = 0
        end
        self.Items[self:CurrentSelection()]:Selected(false)
        self._currentSelection = 1000000 - (1000000 % #self.Items) + tonumber(idx)
        self.Items[self:CurrentSelection()]:Selected(true)
        if self.Parent ~= nil and self.Parent:Visible() then
            local pSubT = self.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_SELECTION", false,
                    self:CurrentSelection() - 1)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_SETTINGS_SELECTION", false,
                    self.ParentTab, self:CurrentSelection() - 1)
            end
        end
    end
end

---Add a new item to the column.
---@param item UIMenuItem|UIMenuListItem|UIMenuCheckboxItem|UIMenuSliderItem|UIMenuProgressItem
function SettingsListColumn:AddSettings(item)
    item.ParentColumn = self
    self.Items[#self.Items + 1] = item
end

function SettingsListColumn:UpdateItemLabels(index, leftLabel, rightLabel)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        self._label = leftLabel;
        self._rightLabel = rightLabel;
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("UPDATE_SETTINGS_ITEM_LABELS", false, index - 1,
                leftLabel, rightLabel)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("UPDATE_PLAYERS_TAB_SETTINGS_ITEM_LABELS", false,
                self.ParentTab, index - 1, self._label, self._rightLabel)
        end
    end
end

function SettingsListColumn:UpdateItemBlinkDescription(index, blink)
    if blink == 1 then blink = true elseif blink == 0 then blink = false end
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("UPDATE_SETTINGS_ITEM_BLINK_DESC", false, index - 1,
                blink)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("UPDATE_PLAYERS_TAB_SETTINGS_ITEM_BLINK_DESC", false,
                self.ParentTab, index - 1, self._label, self._rightLabel)
        end
    end
end

function SettingsListColumn:UpdateItemLabel(index, label)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        self._label = label;
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("UPDATE_SETTINGS_ITEM_LABEL", false, index - 1, label)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("UPDATE_PLAYERS_TAB_SETTINGS_ITEM_LABEL", false,
                self.ParentTab, index - 1, self._label)
        end
    end
end

function SettingsListColumn:UpdateItemRightLabel(index, label)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        self._rightLabel = label;
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("UPDATE_SETTINGS_ITEM_LABEL_RIGHT", false, index - 1,
                label)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("UPDATE_PLAYERS_TAB_SETTINGS_ITEM_LABEL_RIGHT", false,
                self.ParentTab, index - 1, self._rightLabel)
        end
    end
end

function SettingsListColumn:UpdateItemLeftBadge(index, badge)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_ITEM_LEFT_BADGE", false, index - 1, badge)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_SETTINGS_ITEM_LEFT_BADGE", false,
                self.ParentTab, index - 1, badge)
        end
    end
end

function SettingsListColumn:UpdateItemRightBadge(index, badge)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_ITEM_RIGHT_BADGE", false, index - 1,
                badge)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_SETTINGS_ITEM_RIGHT_BADGE", false,
                self.ParentTab, index - 1, badge)
        end
    end
end

function SettingsListColumn:EnableItem(index, enable)
    if self.Parent ~= nil then
        local pSubT = self.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ENABLE_SETTINGS_ITEM", false, index - 1, enable)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_PLAYERS_TAB_SETTINGS_ITEM", false,
                self.ParentTab, index - 1, enable)
        end
    end
end
PlayerStatsPanel = setmetatable({}, PlayerStatsPanel)
PlayerStatsPanel.__index = PlayerStatsPanel
PlayerStatsPanel.__call = function()
    return "ItemPanel", "PlayerStatsPanel"
end

---@class PlayerStatsPanel
---@field private _title string
---@field private _description string
---@field private _titleColor number
---@field private _hasPlane boolean
---@field private _hasVehicle boolean
---@field private _hasBoat boolean
---@field private _hasHeli boolean
---@field public ParentItem FriendItem
---@field public RankInfo UpperInformation
---@field public Items PlayerStatsPanelStatItem[]
---@field public UpdatePanel fun(self: PlayerStatsPanel, override: boolean?)
---@field public Description fun(self: PlayerStatsPanel, desc: string?): string
---@field public HasPlane fun(self: PlayerStatsPanel, bool: boolean?): boolean
---@field public HasHeli fun(self: PlayerStatsPanel, bool: boolean?): boolean
---@field public HasBoat fun(self: PlayerStatsPanel, bool: boolean?): boolean
---@field public HasVehicle fun(self: PlayerStatsPanel, bool: boolean?): boolean
---@field public AddStat fun(self: PlayerStatsPanel, statItem: PlayerStatsPanelStatItem)
---@field public OnItemChanged fun(item: PlayerStatsPanelStatItem)
---@field public OnItemActivated fun(item: PlayerStatsPanelStatItem)

---Creates a new PlayerStatsPanel.
---@param title string
---@param titleColor number
---@return PlayerStatsPanel
function PlayerStatsPanel.New(title, titleColor)
    local _data = {
        ParentItem = nil,
        _title = title or "",
        _description = "",
        _titleColor = titleColor or 116,
        _hasPlane = false,
        _hasVehicle = false,
        _hasBoat = false,
        _hasHeli = false,
        RankInfo = nil,
        Items = {}
    }
    local retVal = setmetatable(_data, PlayerStatsPanel)
    retVal.RankInfo = UpperInformation.New(retVal)
    return retVal
end

---Sets the title of the panel if supplied else it will return the current title.
---@param label string?
---@return string
function PlayerStatsPanel:Title(label)
    if label ~= nil then
        self._title = label
        self:UpdatePanel()
    end
    return self._title
end

---Sets the title color of the panel if supplied else it will return the current color.
---@param color number?
---@return number
function PlayerStatsPanel:TitleColor(color)
    if color ~= nil then
        self._titleColor = color
        self:UpdatePanel()
    end
    return self._titleColor
end

---Sets the description of the panel if supplied else it will return the current description.
---@param label string?
---@return string
function PlayerStatsPanel:Description(label)
    if label ~= nil then
        self._description = label
        self:UpdatePanel()
    end
    return self._description
end

---Sets whether the player has a plane or not, if parameter is nill, it will return the current value.
---@param bool boolean?
---@return boolean
function PlayerStatsPanel:HasPlane(bool)
    if bool ~= nil then
        self._hasPlane = bool
        self:UpdatePanel()
    end
    return self._hasPlane
end

---Sets whether the player has a helicopter or not, if parameter is nill, it will return the current value.
---@param bool boolean?
---@return boolean
function PlayerStatsPanel:HasHeli(bool)
    if bool ~= nil then
        self._hasHeli = bool
        self:UpdatePanel()
    end
    return self._hasHeli
end

---Sets whether the player has a boat or not, if parameter is nill, it will return the current value.
---@param bool boolean?
---@return boolean
function PlayerStatsPanel:HasBoat(bool)
    if bool ~= nil then
        self._hasBoat = bool
        self:UpdatePanel()
    end
    return self._hasBoat
end

---Sets whether the player has a vehicle or not, if parameter is nill, it will return the current value.
---@param bool boolean?
---@return boolean
function PlayerStatsPanel:HasVehicle(bool)
    if bool ~= nil then
        self._hasVehicle = bool
        self:UpdatePanel()
    end
    return self._hasVehicle
end

---Adds a new stat item to the panel.
---@param statItem PlayerStatsPanelStatItem
function PlayerStatsPanel:AddStat(statItem)
    statItem.Parent = self
    statItem.idx = #self.Items
    self.Items[#self.Items + 1] = statItem
    self:UpdatePanel()
end

---Triggers the panel to update.
---@param override boolean? If true, the panel will update regardless of the parent's visibility.
function PlayerStatsPanel:UpdatePanel(override)
    if override == nil then override = false end
    if ((self.ParentItem ~= nil and self.ParentItem.ParentColumn ~= nil and self.ParentItem.ParentColumn.Parent ~= nil and self.ParentItem.ParentColumn.Parent:Visible()) or override) then
        local idx = IndexOf(self.ParentItem.ParentColumn.Items, self.ParentItem) - 1
        local pSubT = self.ParentItem.ParentColumn.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_PANEL", false, idx, 0,
                self.ParentItem.ClonePed ~= nil and self.ParentItem.ClonePed ~= 0, self:Title(), self:Description(),
                self:TitleColor(), self.RankInfo:RankLevel(), self:HasPlane(), self:HasHeli(), self:HasBoat(),
                self:HasVehicle(), 0, self.RankInfo:LowLabel(), 0, 0, self.RankInfo:MidLabel(), 0, 0,
                self.RankInfo:UpLabel(),
                0, 0)
            if not self:Description():IsNullOrEmpty() then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_PANEL_DESCRIPTION", false, idx,
                    self:Description(), 0, "", self.ParentItem.ClonePed ~= nil and self.ParentItem.ClonePed ~= 0)
            end
            for k, stat in pairs(self.Items) do
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_PANEL_STAT", false, idx, stat.idx,
                    0, stat:Label(), stat:Description(), stat:Value())
            end
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_PANEL", false,
                self.ParentItem.ParentColumn.ParentTab, idx, 0,
                self.ParentItem.ClonePed ~= nil and self.ParentItem.ClonePed ~= 0, self:Title(), self:Description(),
                self:TitleColor(), self.RankInfo:RankLevel(), self:HasPlane(), self:HasHeli(), self:HasBoat(),
                self:HasVehicle(), 0, self.RankInfo:LowLabel(), 0, 0, self.RankInfo:MidLabel(), 0, 0,
                self.RankInfo:UpLabel(),
                0, 0)
            if not self:Description():IsNullOrEmpty() then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_PANEL_DESCRIPTION",
                    false, self.ParentItem.ParentColumn.ParentTab, idx, self:Description(), 0, "",
                    self.ParentItem.ClonePed ~= nil and self.ParentItem.ClonePed ~= 0)
            end
            for k, stat in pairs(self.Items) do
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_PANEL_STAT", false,
                    self.ParentItem.ParentColumn.ParentTab, idx, stat.idx, 0, stat:Label(), stat:Description(),
                    stat:Value())
            end
        end
    end
end
PlayerStatsPanelStatItem = setmetatable({}, PlayerStatsPanelStatItem)
PlayerStatsPanelStatItem.__index = PlayerStatsPanelStatItem
PlayerStatsPanelStatItem.__call = function()
    return "ItemPanel_item", "PlayerStatsPanelStatItem"
end

---@class PlayerStatsPanelStatItem
---@field Parent PlayerStatsPanel
---@field private _idx number
---@field private _value number
---@field private _description string
---@field private _label string
---@field public Label fun(self: PlayerStatsPanelStatItem, label: string?): string
---@field public Description fun(self: PlayerStatsPanelStatItem, desc: string?): string
---@field public Value fun(self: PlayerStatsPanelStatItem, value: number?): number

---Creates a new PlayerStatsPanelStatItem.
---@param label string
---@param desc string
---@param value number
---@return PlayerStatsPanelStatItem
function PlayerStatsPanelStatItem.New(label, desc, value)
    local _data = {
        Parent = nil,
        _idx = 0,
        _value = value or 0,
        _description = desc or "",
        _label = label or ""
    }
    return setmetatable(_data, PlayerStatsPanelStatItem)
end

---Sets the label of the item if supplied else it will return the current label.
---@param label string?
---@return string
function PlayerStatsPanelStatItem:Label(label)
    if label ~= nil then
        self._label = label
        self.Parent:UpdatePanel()
    end
    return self._label
end

---Sets the description of the item if supplied else it will return the current description.
---@param desc string?
---@return string
function PlayerStatsPanelStatItem:Description(desc)
    if desc ~= nil then
        self._description = desc
        self.Parent:UpdatePanel()
    end
    return self._description
end

---Sets the value of the item if supplied else it will return the current value.
---@param value number?
---@return number
function PlayerStatsPanelStatItem:Value(value)
    if value ~= nil then
        self._value = value
        self.Parent:UpdatePanel()
    end
    return self._value
end
UpperInformation = setmetatable({}, UpperInformation)
UpperInformation.__index = UpperInformation
UpperInformation.__call = function()
    return "ItemPanel_Info", "UpperInformation"
end

---@class UpperInformation
---@field private _parent UpperInformation
---@field private _rankLevel number
---@field private _upLabel string
---@field private _lowLabel string
---@field private _midLabel string
---@field public RankLevel fun(self: UpperInformation, rank: number?): number
---@field public UpLabel fun(self: UpperInformation, label: string?): string
---@field public MidLabel fun(self: UpperInformation, label: string?): string
---@field public LowLabel fun(self: UpperInformation, label: string?): string

---Creates a new UpperInformation.
---@param parent UpperInformation
---@return UpperInformation
function UpperInformation.New(parent)
    local _data = {
        _parent = parent,
        _rankLevel = 0,
        _upLabel = "",
        _lowLabel = "",
        _midLabel = "",
    }
    return setmetatable(_data, UpperInformation)
end

---Sets the rank level of the item if supplied else it will return the current rank level.
---@param rank number?
---@return number
function UpperInformation:RankLevel(rank)
    if rank ~= nil then
        self._rankLevel = rank
        self._parent:UpdatePanel()
    end
    return self._rankLevel
end

---Sets the up label of the item if supplied else it will return the current up label.
---@param label string?
---@return string
function UpperInformation:UpLabel(label)
    if label ~= nil then
        self._upLabel = label
        self._parent:UpdatePanel()
    end
    return self._upLabel
end

---Sets the middle label of the item if supplied else it will return the current middle label.
---@param label string?
---@return string
function UpperInformation:MidLabel(label)
    if label ~= nil then
        self._midLabel = label
        self._parent:UpdatePanel()
    end
    return self._midLabel
end

---Sets the low label of the item if supplied else it will return the current low label.
---@param label string?
---@return string
function UpperInformation:LowLabel(label)
    if label ~= nil then
        self._lowLabel = label
        self._parent:UpdatePanel()
    end
    return self._lowLabel
end
FriendItem = setmetatable({}, FriendItem)
FriendItem.__index = FriendItem
FriendItem.__call = function()
    return "LobbyItem", "FriendItem"
end

---@class FriendItem
---@field public Label string
---@field public ItemColor number
---@field public ColoredTag boolean
---@field public Rank number
---@field public Status string
---@field public StatusColor number
---@field public CrewTag string
---@field public _iconL number
---@field public _iconR number
---@field public _boolL boolean
---@field public _boolR boolean
---@field public ParentColumn PlayerListColumn
---@field public ClonePed number
---@field public Panel PlayerStatsPanel
---@field public Handle number
---@field public SetLeftIcon fun(self: FriendItem, icon: LobbyBadgeIcon|BadgeStyle, bool: boolean):nil
---@field public SetRightIcon fun(self: FriendItem, icon: LobbyBadgeIcon|BadgeStyle, bool: boolean):nil
---@field public AddPedToPauseMenu fun(self: FriendItem, ped: number):number
---@field public AddPanel fun(self: FriendItem, panel: PlayerStatsPanel)
---@field public Enabled fun(self: FriendItem, enabled: boolean):boolean

---Creates a new FriendItem.
---@param label string
---@param itemColor number
---@param coloredTag boolean
---@param rank number
---@param status string
---@param crewTag string
---@return FriendItem
function FriendItem.New(label, itemColor, coloredTag, rank, status, crewTag)
    if itemColor == -1 then itemColor = 9 end
    local _data = {
        _type = 1,
        _Enabled = true,
        _Selected = false,
        _Hovered = false,
        _label = label or "",
        _itemColor = itemColor or 9,
        _rank = rank or 0,
        _status = status or "",
        _statusColor = itemColor,
        _crewTag = crewTag or "",
        _iconL = 0,
        _iconR = 65,
        _boolL = false,
        _boolR = false,
        _coloredTag = coloredTag or true,
        ParentColumn = nil,
        ClonePed = 0,
        Panel = nil,
        Handle = nil,
    }
    return setmetatable(_data, FriendItem)
end

---Sets the label of the item if supplied else it will return the current label.
---@param label string?
---@return string
function FriendItem:Label(label)
    if label ~= nil then
        self._label = label
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_LABEL", false, idx, self._label)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_LABEL", false,
                    self.ParentColumn.ParentTab, idx, self._label)
            end
        end
    end
    return self._label
end

---Adds a ped to the pause menu or returns the current ped.
---@param ped number? If the ped parameter is 0 it will clear the ped.
---@return number -- If the ped parameter is 0 it will return -1.
function FriendItem:AddPedToPauseMenu(ped)
    if ped ~= nil then
        self.ClonePed = ped
        if ped == 0 then
            ClearPedInPauseMenu()
            return -1
        end
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            if self.Panel ~= nil then
                self.Panel:UpdatePanel()
            end
            local pSubT = self.ParentColumn.Parent()
            Citizen.CreateThread(function()
                Wait(100)
                if pSubT == "LobbyMenu" then
                    if self.ParentColumn.Items[self.ParentColumn:CurrentSelection()] == self then
                        local ped = ClonePed(self.ClonePed, false, false, true)
                        FinalizeHeadBlend(ped)
                        GivePedToPauseMenu(ped, 2);
                        SetPauseMenuPedSleepState(true)
                        SetPauseMenuPedLighting(true)
                    end
                elseif pSubT == "PauseMenu" then
                    local tab = self.ParentColumn.Parent.Tabs[self.ParentColumn.Parent.Index]
                    local _, subT = tab()
                    if subT == "PlayerListTab" then
                        if self.ParentColumn.Items[self.ParentColumn:CurrentSelection()] == self then
                            local ped = ClonePed(self.ClonePed, false, false, true)
                            FinalizeHeadBlend(ped)
                            GivePedToPauseMenu(ped, 2);
                            SetPauseMenuPedSleepState(true)
                            SetPauseMenuPedLighting(self.ParentColumn.Parent:FocusLevel() ~= 0);
                        end
                    end
                end
            end)
        end
    end
    return self.ClonePed
end

---Sets the item color of the item if supplied else it will return the current item color.
function FriendItem:ItemColor(color)
    if color ~= nil then
        self._itemColor = color
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_COLOUR", false, idx,
                    self._itemColor, self._coloredTag)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_COLOUR", false,
                    self.ParentColumn.ParentTab, idx, self._itemColor, self._coloredTag)
            end
        end
    end
    return self._itemColor
end

-- Sets if the item color should be used for the crew tag, if the argument is nil it will return the current value.
---@param enableColorTag boolean
---@return boolean
function FriendItem:ColoredTag(enableColorTag)
    if enableColorTag ~= nil then
        self._coloredTag = enableColorTag
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_COLOUR", false, idx,
                    self._itemColor, self._coloredTag)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_COLOUR", false,
                    self.ParentColumn.ParentTab, idx, self._itemColor, self._coloredTag)
            end
        end
    end
    return self._coloredTag
end

---Sets the rank of the item if supplied else it will return the current rank.
---@param rank number?
---@return number
function FriendItem:Rank(rank)
    if rank ~= nil then
        self._rank = rank
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_RANK", false, idx, self._rank)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_RANK", false,
                    self.ParentColumn.ParentTab, idx, self._rank)
            end
        end
    end
    return self._rank
end

---Sets the status of the item if supplied else it will return the current status.
---@param status string?
---@return string
function FriendItem:Status(status)
    if status ~= nil then
        self._status = status
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_STATUS", false, idx, self._status,
                    self._statusColor)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_STATUS", false,
                    self.ParentColumn.ParentTab, idx, self._status, self._statusColor)
            end
        end
    end
    return self._status
end

---Sets the status color of the item if supplied else it will return the current status color.
---@param color number
---@return number
function FriendItem:StatusColor(color)
    if color ~= nil then
        self._statusColor = color
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_STATUS", false, idx, self._status,
                    self._statusColor)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_STATUS", false,
                    self.ParentColumn.ParentTab, idx, self._status, self._statusColor)
            end
        end
    end
    return self._statusColor
end

---Sets the crew tag of the item if supplied else it will return the current crew tag.
---@param tag string?
---@return string
function FriendItem:CrewTag(tag)
    if tag ~= nil then
        self._crewTag = tag
        if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
            local idx = IndexOf(self.ParentColumn.Items, self) - 1
            local pSubT = self.ParentColumn.Parent()
            if pSubT == "LobbyMenu" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_CREW", false, idx, self._crewTag)
            elseif pSubT == "PauseMenu" then
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ITEM_CREW", false,
                    self.ParentColumn.ParentTab, idx, self._crewTag)
            end
        end
    end
    return self._crewTag
end

---Sets the left icon of the item.
---@param icon LobbyBadgeIcon?
---@param isBadge boolean?
function FriendItem:SetLeftIcon(icon, isBadge)
    self._iconL = icon;
    self._boolL = isBadge or false;
    if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
        local idx = IndexOf(self.ParentColumn.Items, self) - 1
        local pSubT = self.ParentColumn.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_ICON_LEFT", false, idx, self._iconL,
                self._boolL)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ICON_LEFT", false,
                self.ParentColumn.ParentTab, idx, self._iconL, self._boolL)
        end
    end
end

---Sets the right icon of the item.
---@param icon LobbyBadgeIcon?
---@param isBadge boolean?
function FriendItem:SetRightIcon(icon, isBadge)
    self._iconR = icon;
    self._boolR = isBadge or false;
    if self.ParentColumn ~= nil and self.ParentColumn.Parent ~= nil and self.ParentColumn.Parent:Visible() then
        local idx = IndexOf(self.ParentColumn.Items, self) - 1
        local pSubT = self.ParentColumn.Parent()
        if pSubT == "LobbyMenu" then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_PLAYER_ITEM_ICON_RIGHT", false, idx, self._iconR,
                self._boolR)
        elseif pSubT == "PauseMenu" then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_PLAYER_ICON_RIGHT", false,
                self.ParentColumn.ParentTab, idx, self._iconR, self._boolR)
        end
    end
end

---Sets the selected state of the item if supplied else it will return the current selected state.
---@param bool boolean?
---@return boolean
function FriendItem:Selected(bool)
    if bool ~= nil then
        self._Selected = ToBool(bool)
    end
    return self._Selected
end

---Sets the hovered state of the item if supplied else it will return the current hovered state.
function FriendItem:Hovered(bool)
    if bool ~= nil then
        self._Hovered = ToBool(bool)
    end
    return self._Hovered
end

---Sets the enabled state of the item if supplied else it will return the current enabled state.
function FriendItem:Enabled(bool)
    if bool ~= nil then
        self._Enabled = ToBool(bool)
    end
    return self._Enabled
end

---Adds a player stats panel to the item.
---@param panel PlayerStatsPanel
function FriendItem:AddPanel(panel)
    panel.ParentItem = self
    self.Panel = panel
    self.Panel:UpdatePanel()
end
MissionDetailsPanel = setmetatable({}, MissionDetailsPanel)
MissionDetailsPanel.__index = MissionDetailsPanel
MissionDetailsPanel.__call = function()
    return "Panel", "MissionDetailsPanel"
end

---@class MissionDetailsPanel
---@field private _title string
---@field private _label string
---@field private _color number
---@field public Parent MissionDetailsPanel
---@field public Items MissionDetailsItem[]
---@field public TextureDict string
---@field public TextureName string
---@field public Title fun(self: MissionDetailsPanel, label: string): string
---@field public UpdatePanelPicture fun(self: MissionDetailsPanel, txd: string, txn: string)
---@field public AddItem fun(self: MissionDetailsPanel, item: MissionDetailsItem)
---@field public OnIndexChanged fun(index: number)

function MissionDetailsPanel.New(label, color)
    local _data = {
        _title = "",
        _label = label or "",
        _color = color or 116,
        Parent = nil,
        Items = {} --[[@type MissionDetailsItem[]],
        TextureDict = "",
        TextureName = "",
        OnIndexChanged = function(index)
        end
    }
    return setmetatable(_data, MissionDetailsPanel)
end

function MissionDetailsPanel:Title(label)
    if label == nil then
        return self._title
    else
        self._title = label
        if self.Parent ~= nil and self.Parent:Visible() then
            ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_MISSION_PANEL_TITLE", false, self._title)
        end
    end
end

function MissionDetailsPanel:UpdatePanelPicture(txd, txn)
    self.TextureDict = txd
    self.TextureName = txn
    if self.Parent ~= nil and self.Parent:Visible() then
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_MISSION_PANEL_PICTURE", false, self.TextureDict,
            self.TextureName)
    end
end

function MissionDetailsPanel:AddItem(item)
    self.Items[#self.Items + 1] = item
    if self.Parent ~= nil and self.Parent:Visible() then
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_MISSION_PANEL_ITEM", false, item.Type, item.TextLeft,
            item.TextRight, item.Icon, item.IconColor, item.Tick)
    end
end

function MissionDetailsPanel:RemoveItem(idx)
    table.remove(self.Items, idx)
    if self.Parent ~= nil and self.Parent:Visible() then
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("REMOVE_MISSION_PANEL_ITEM", false, idx - 1)
    end
end
---@enum LobbyBadgeIcon
LobbyBadgeIcon = {
    NONE = 0,
    ACTIVE_HEADSET = 47,
    INACTIVE_HEADSET = 48,
    MUTED_HEADSET = 49,
    GTAV = 54,
    WORLD = 63,
    KICK = 64,
    RANK_FREEMODE = 65,
    SPECTATOR = 66,
    IS_CONSOLE_PLAYER = 119,
    IS_PC_PLAYER = 120
}
MainView = setmetatable({}, MainView)
MainView.__index = MainView
MainView.__call = function()
    return "LobbyMenu"
end
MainView.SoundId = GetSoundId()

---@class MainView
---@field public Title string
---@field public Subtitle string
---@field public SideTop string
---@field public SideMid string
---@field public SideBot string
---@field public SettingsColumn SettingsListColumn
---@field public PlayersColumn PlayerListColumn
---@field public MissionPanel MissionDetailsPanel
---@field public InstructionalButtons InstructionalButton[]
---@field public OnLobbyMenuOpen fun(menu: MainView)
---@field public OnLobbyMenuClose fun(menu: MainView)
---@field public TemporarilyHidden boolean
---@field public controller boolean
---@field public focusLevel number

function MainView.New(title, subtitle, sideTop, sideMid, sideBot)
    local _data = {
        Title = title or "",
        Subtitle = subtitle or "",
        SideTop = sideTop or "",
        SideMid = sideMid or "",
        SideBot = sideBot or "",
        ParentPool = nil,
        _headerPicture = {},
        _crewPicture = {},
        _visible = false,
        SettingsColumn = {} --[[@type SettingsListColumn]],
        PlayersColumn = {} --[[@type PlayerListColumn]],
        MissionPanel = {} --[[@type MissionDetailsPanel]],
        focusLevel = 1,
        TemporarilyHidden = false,
        controller = false,
        _loaded = false,
        _timer = 0,
        _time = 0,
        _times = 0,
        _delay = 150,
        _listCol = {},
        _firstTick = true,
        _canHe = true,
        InstructionalButtons = {
            InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 176, 176, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1),
        },
        OnLobbyMenuOpen = function(menu)
        end,
        OnLobbyMenuClose = function(menu)
        end
        --[[
        OnLeftItemChange = function(menu, leftItem, index)
        end,
        OnRightItemChange = function(menu, rightItem, index)
        end,
        OnLeftItemSelect = function(menu, leftItem, index)
        end,
        OnRightItemSelect = function(menu, rightItem, index)
        end
        ]]
    }
    return setmetatable(_data, MainView)
end

function MainView:FocusLevel(index)
    if index ~= nil then
        self.focusLevel = index
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_FOCUS", false, index - 1)
        if index == 2 then
            CreateThread(function()
                Wait(100)
                local ped = ClonePed(self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed, false,
                    true, true);
                GivePedToPauseMenu(ped, 2)
                SetPauseMenuPedSleepState(true);
                SetPauseMenuPedLighting(true);
            end)
        end
    else
        return self.focusLevel
    end
end

function MainView:CanPlayerCloseMenu(canHe)
    if canHe == nil then
        return self._canHe
    else
        self._canHe = canHe
    end
end

function MainView:Visible(visible, noeffect)
    if visible ~= nil then
        self._visible = visible
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(visible)
        ScaleformUI.Scaleforms._pauseMenu:Visible(visible)
        if visible == true then
            if not IsPauseMenuActive() then
                self.focusLevel = 1
                if not noeffect then
                    PlaySoundFrontend(self.SoundId, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET", true)
                end
                ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, true, -1)
                ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, true, -1)
                self:BuildPauseMenu()
                self.OnLobbyMenuOpen(self) 
                AnimpostfxPlay("PauseMenuIn", 800, true)
                ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.InstructionalButtons)
                SetPlayerControl(PlayerId(), false, 0)
                self._firstTick = true
                self.ParentPool:ProcessMenus(true)
            end
        else
            ScaleformUI.Scaleforms._pauseMenu:Dispose()
            AnimpostfxStop("PauseMenuIn")
            AnimpostfxPlay("PauseMenuOut", 800, false)
            self.OnLobbyMenuClose(self)
            SetPlayerControl(PlayerId(), true, 0)
            self.ParentPool:ProcessMenus(false)
            if IsPauseMenuActive() then
                if not noeffect then
                    PlaySoundFrontend(self.SoundId, "Hit_Out", "PLAYER_SWITCH_CUSTOM_SOUNDSET", true)
                end
                ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, false, -1)
            end
            SetFrontendActive(false)
        end
    else
        return self._visible
    end
end

function MainView:HeaderPicture(Txd, Txn)
    if (Txd ~= nil and Txn ~= nil) then
        self._headerPicture = { txd = Txd, txn = Txn }
    else
        return self._headerPicture
    end
end

function MainView:CrewPicture(Txd, Txn)
    if (Txd ~= nil and Txn ~= nil) then
        self._crewPicture = { txd = Txd, txn = Txn }
    else
        return self._crewPicture
    end
end

function MainView:SetupColumns(columns)
    assert(type(columns) == "table", "^1ScaleformUI [ERROR]: SetupColumns, Table expected^7")
    assert(#columns == 3, "^1ScaleformUI [ERROR]: SetupColumns, you must add 3 columns^7")
    self._listCol = columns
    for k, v in ipairs(columns) do
        local _, subT = v()
        if subT == "SettingsListColumn" then
            self.SettingsColumn = v
            self.SettingsColumn.Parent = self
            self.SettingsColumn.Order = k
        elseif subT == "PlayerListColumn" then
            self.PlayersColumn = v
            self.PlayersColumn.Parent = self
            self.PlayersColumn.Order = k
        elseif subT == "MissionDetailsPanel" then
            self.MissionPanel = v
            self.MissionPanel.Parent = self
            self.MissionPanel.Order = k
        end
    end
end

function MainView:ShowHeader()
    if self.Subtitle:IsNullOrEmpty() then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title)
    else
        ScaleformUI.Scaleforms._pauseMenu:ShiftCoronaDescription(true, false)
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title, self.Subtitle .. "\n\n\n\n\n\n\n\n\n\n\n")
    end
    if (self:HeaderPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderCharImg(self:HeaderPicture().txd, self:HeaderPicture().txn, true)
    end
    if (self:CrewPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderSecondaryImg(self:CrewPicture().txd, self:CrewPicture().txn, true)
    end
    ScaleformUI.Scaleforms._pauseMenu:SetHeaderDetails(self.SideTop, self.SideMid, self.SideBot)
    ScaleformUI.Scaleforms._pauseMenu:AddLobbyMenuTab(self._listCol[1]._label, 2, 0, self._listCol[1]._color)
    ScaleformUI.Scaleforms._pauseMenu:AddLobbyMenuTab(self._listCol[2]._label, 2, 0, self._listCol[2]._color)
    ScaleformUI.Scaleforms._pauseMenu:AddLobbyMenuTab(self._listCol[3]._label, 2, 0, self._listCol[3]._color)
    ScaleformUI.Scaleforms._pauseMenu._header:CallFunction("SET_ALL_HIGHLIGHTS", false, true, 117);
    self._loaded = true
end

function MainView:BuildPauseMenu()
    self:ShowHeader()
    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("CREATE_MENU", false, self.SettingsColumn.Order - 1,
        self.PlayersColumn.Order - 1, self.MissionPanel.Order - 1);
    Citizen.CreateThread(function()
        local items = self.SettingsColumn.Items
        local it = 1
        while it <= #items do
            Citizen.Wait(1)
            local item = items[it]
            local Type, SubType = item()
            AddTextEntry("menu_lobby_desc_{" .. it .. "}", item:Description())

            if SubType == "UIMenuListItem" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_LEFT_ITEM", false, 1, item:Label(),
                    "menu_lobby_desc_{" .. it .. "}", item:Enabled(), item:BlinkDescription(),
                    table.concat(item.Items, ","),
                    item:Index() - 1, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor)
            elseif SubType == "UIMenuCheckboxItem" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_LEFT_ITEM", false, 2, item:Label(),
                    "menu_lobby_desc_{" .. it .. "}", item:Enabled(), item:BlinkDescription(), item.CheckBoxStyle,
                    item._Checked, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor)
            elseif SubType == "UIMenuSliderItem" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_LEFT_ITEM", false, 3, item:Label(),
                    "menu_lobby_desc_{" .. it .. "}", item:Enabled(), item:BlinkDescription(), item._Max,
                    item._Multiplier,
                    item:Index(), item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor, item.SliderColor, item._heritage)
            elseif SubType == "UIMenuProgressItem" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_LEFT_ITEM", false, 4, item:Label(),
                    "menu_lobby_desc_{" .. it .. "}", item:Enabled(), item:BlinkDescription(), item._Max,
                    item._Multiplier,
                    item:Index(), item.Base._mainColor, item.Base._highlightColor, item.Base._textColor,
                    item.Base._highlightedTextColor, item.SliderColor)
            else
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_LEFT_ITEM", false, 0, item:Label(),
                    "menu_lobby_desc_{" .. it .. "}", item:Enabled(), item:BlinkDescription(), item._mainColor,
                    item._highlightColor, item._textColor, item._highlightedTextColor)
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("UPDATE_SETTINGS_ITEM_LABEL_RIGHT", false, it - 1,
                    item:RightLabel())
                if item._rightBadge ~= BadgeStyle.NONE then
                    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_ITEM_RIGHT_BADGE", false, it - 1,
                        item._rightBadge)
                end
            end

            if (SubType == "UIMenuItem" and item._leftBadge ~= BadgeStyle.NONE) or (SubType ~= "UIMenuItem" and item.Base._leftBadge ~= BadgeStyle.NONE) then
                if SubType ~= "UIMenuItem" then
                    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_ITEM_LEFT_BADGE", false, it - 1,
                        item.Base._leftBadge)
                else
                    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_SETTINGS_ITEM_LEFT_BADGE", false, it - 1,
                        item._leftBadge)
                end
            end

            it = it + 1
        end
        self.SettingsColumn:CurrentSelection(0)
    end)
    Citizen.CreateThread(function()
        local items = self.PlayersColumn.Items
        local it = 1
        while it <= #items do
            Citizen.Wait(1)
            local item = items[it]
            local Type, SubType = item()
            if SubType == "FriendItem" then
                ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_PLAYER_ITEM", false, 1, 1, item:Label(),
                    item:ItemColor(), item:ColoredTag(), item._iconL, item._boolL, item._iconR, item._boolR,
                    item:Status(),
                    item:StatusColor(), item:Rank(), item:CrewTag());
            end
            if item.Panel ~= nil then
                item.Panel:UpdatePanel(true)
            end
            it = it + 1
        end
        self.PlayersColumn:CurrentSelection(0)
    end)
    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_MISSION_PANEL_PICTURE", false,
        self.MissionPanel.TextureDict, self.MissionPanel.TextureName);
    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_MISSION_PANEL_TITLE", false, self.MissionPanel:Title());
    for k, item in pairs(self.MissionPanel.Items) do
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("ADD_MISSION_PANEL_ITEM", false, item.Type, item.TextLeft,
            item.TextRight, item.Icon, item.IconColor, item.Tick);
    end
end

function MainView:Draw()
    if not self:Visible() or self.TemporarilyHidden then
        return
    end
    DisableControlAction(0, 199, true)
    DisableControlAction(0, 200, true)
    DisableControlAction(1, 199, true)
    DisableControlAction(1, 200, true)
    DisableControlAction(2, 199, true)
    DisableControlAction(2, 200, true)
    ScaleformUI.Scaleforms._pauseMenu:Draw(true)
    if self._firstTick then
        ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("FADE_IN", false)
        self._firstTick = false
    end
end

local success, event_type, context, item_id

function MainView:ProcessMouse()
    if not IsUsingKeyboard(2) then
        return
    end
    SetMouseCursorActiveThisFrame()
    SetInputExclusive(2, 239)
    SetInputExclusive(2, 240)
    SetInputExclusive(2, 237)
    SetInputExclusive(2, 238)

    success, event_type, context, item_id = GetScaleformMovieCursorSelection(ScaleformUI.Scaleforms._pauseMenu._lobby
        .handle)
    if success then
        if event_type == 5 then
            if self.focusLevel ~= context + 1 then
                self:FocusLevel(context + 1)
            end
            local col = self._listCol[context + 1]
            local Type, SubType = col()
            if SubType == "SettingsListColumn" then
                ClearPedInPauseMenu()
                for k, v in pairs(self.PlayersColumn.Items) do v:Selected(false) end
                if not col.Items[col:CurrentSelection()]:Enabled() then
                    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    return
                end
                if col.Items[item_id + 1]:Selected() then
                    ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", false, 16)
                    local item = col.Items[item_id + 1]
                    local _type, _subType = item()
                    if _subType == "UIMenuCheckboxItem" then
                        item:Checked(not item:Checked())
                        item.OnCheckboxChanged(nil, item, item:Checked())
                    elseif _subType == "UIMenuListItem" then
                        item.OnListSelected(nil, item, item._Index)
                    elseif _subType == "UIMenuSliderItem" then
                        item.OnSliderSelected(nil, item, item._Index)
                    elseif _subType == "UIMenuProgressItem" then
                        item.OnProgressSelected(nil, item, item._Index)
                    else
                        item.Activated(nil, item)
                    end
                    return
                end
                col:CurrentSelection(item_id)
                col.OnIndexChanged(item_id + 1)
            elseif SubType == "PlayerListColumn" then
                for k, v in pairs(self.SettingsColumn.Items) do v:Selected(false) end
                if not col.Items[col:CurrentSelection()]:Enabled() then
                    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    return
                end
                if not col.Items[item_id + 1] or col.Items[item_id + 1]:Selected() then
                    return
                end
                col:CurrentSelection(item_id)
                col.OnIndexChanged(item_id + 1)
                if col.Items[item_id + 1].ClonePed ~= nil and col.Items[item_id + 1].ClonePed ~= 0 then
                    local ped = ClonePed(col.Items[item_id + 1].ClonePed, false, true, true);
                    Citizen.Wait(0)
                    GivePedToPauseMenu(ped, 2)
                    SetPauseMenuPedSleepState(true);
                    SetPauseMenuPedLighting(true);
                else
                    ClearPedInPauseMenu()
                end
            end
        end
    end
end

function MainView:ProcessControl()
    if not self:Visible() or self.TemporarilyHidden then
        return
    end

    if (IsControlPressed(2, 172)) then
        if GlobalGameTimer - self._time > self._delay then
            self:ButtonDelay()
            Citizen.CreateThread(function()
                self:GoUp()
                return
            end)
        end
    end
    if (IsControlPressed(2, 173)) then
        if GlobalGameTimer - self._time > self._delay then
            self:ButtonDelay()
            Citizen.CreateThread(function()
                self:GoDown()
                return
            end)
        end
    end
    if (IsControlPressed(2, 174)) then
        if GlobalGameTimer - self._time > self._delay then
            self:ButtonDelay()
            Citizen.CreateThread(function()
                self:GoLeft()
                return
            end)
        end
    end
    if (IsControlPressed(2, 175)) then
        if GlobalGameTimer - self._time > self._delay then
            self:ButtonDelay()
            Citizen.CreateThread(function()
                self:GoRight()
                return
            end)
        end
    end

    if (IsControlJustPressed(2, 201)) then
        Citizen.CreateThread(function()
            self:Select()
        end)
    end
    if (IsDisabledControlJustReleased(2, 177)) then
        Citizen.CreateThread(function()
            self:GoBack()
        end)
    end

    if (IsControlJustPressed(1, 241)) then
        Citizen.CreateThread(function()
            ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(-1)
        end)
    end
    if (IsControlJustPressed(1, 242)) then
        Citizen.CreateThread(function()
            ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(1)
        end)
    end

    if (IsControlJustReleased(0, 172) or IsControlJustReleased(1, 172) or IsControlJustReleased(2, 172)) or
        (IsControlJustReleased(0, 173) or IsControlJustReleased(1, 173) or IsControlJustReleased(2, 173)) or
        (IsControlJustReleased(0, 174) or IsControlJustReleased(1, 174) or IsControlJustReleased(2, 174)) or
        (IsControlJustReleased(0, 175) or IsControlJustReleased(1, 175) or IsControlJustReleased(2, 175))
    then
        self._times = 0
        self._delay = 150
    end
end

function MainView:ButtonDelay()
    self._times = self._times + 1
    if self._times % 5 == 0 then
        self._delay = self._delay - 10
        if self._delay < 50 then
            self._delay = 50
        end
    end
    self._time = GlobalGameTimer
end

function MainView:Select()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", true, 16) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueString(return_value)

    local splitted = Split(retVal, ",")
    if self:FocusLevel() == self.SettingsColumn.Order then
        local item = self.SettingsColumn.Items[self.SettingsColumn:CurrentSelection()]
        local type, subtype = item()
        if not item:Enabled() then
            PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            return
        end
        if subtype == "UIMenuCheckboxItem" then
            item:Checked(not item:Checked())
            item.OnCheckboxChanged(nil, item, item:Checked())
        elseif subtype == "UIMenuListItem" then
            item.OnListSelected(nil, item, item._Index)
        elseif subtype == "UIMenuSliderItem" then
            item.OnSliderSelected(nil, item, item._Index)
        elseif subtype == "UIMenuProgressItem" then
            item.OnProgressSelected(nil, item, item._Index)
        else
            item.Activated(nil, item)
        end
    elseif self:FocusLevel() == self.PlayersColumn.Order then
    end
end

function MainView:GoBack()
    if self:CanPlayerCloseMenu() then
        self:Visible(false)
    end
end

function MainView:GoUp()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", true, 8, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueString(return_value)

    local splitted = Split(retVal, ",")

    if self:FocusLevel() == self.SettingsColumn.Order then
        self.SettingsColumn:CurrentSelection(tonumber(splitted[2]))
        self.SettingsColumn.OnIndexChanged(self.SettingsColumn:CurrentSelection())
    elseif self:FocusLevel() == self.PlayersColumn.Order then
        self.PlayersColumn:CurrentSelection(tonumber(splitted[2]))
        if self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= nil and self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
            local ped = ClonePed(self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed, false, true,
                true);
            Citizen.Wait(0)
            GivePedToPauseMenu(ped, 2)
            SetPauseMenuPedSleepState(true);
            SetPauseMenuPedLighting(true);
        else
            ClearPedInPauseMenu()
        end
        self.PlayersColumn.OnIndexChanged(self.PlayersColumn:CurrentSelection())
    end
end

function MainView:GoDown()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", true, 9, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueString(return_value)

    local splitted = Split(retVal, ",")

    if self:FocusLevel() == self.SettingsColumn.Order then
        self.SettingsColumn:CurrentSelection(tonumber(splitted[2]))
        self.SettingsColumn.OnIndexChanged(self.SettingsColumn:CurrentSelection())
    elseif self:FocusLevel() == self.PlayersColumn.Order then
        self.PlayersColumn:CurrentSelection(tonumber(splitted[2]))
        if self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= nil and self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
            local ped = ClonePed(self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed, false, true,
                true);
            Citizen.Wait(0)
            GivePedToPauseMenu(ped, 2)
            SetPauseMenuPedSleepState(true);
            SetPauseMenuPedLighting(true);
        else
            ClearPedInPauseMenu()
        end
        self.PlayersColumn.OnIndexChanged(self.PlayersColumn:CurrentSelection())
    end
end

function MainView:GoLeft()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", true, 10, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueString(return_value)

    local splitted = Split(retVal, ",")

    if tonumber(splitted[3]) == -1 then
        self:FocusLevel(tonumber(splitted[1]) + 1)
        if self:FocusLevel() == self.SettingsColumn.Order then
            ClearPedInPauseMenu();
            self.SettingsColumn:CurrentSelection(tonumber(splitted[2]))
            self.SettingsColumn.OnIndexChanged(self.SettingsColumn:CurrentSelection());
        elseif self:FocusLevel() == self.PlayersColumn.Order then
            self.PlayersColumn:CurrentSelection(tonumber(splitted[2]))
            if self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= nil and self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                local ped = ClonePed(self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed, false,
                    true, true);
                Citizen.Wait(0)
                GivePedToPauseMenu(ped, 2)
                SetPauseMenuPedSleepState(true);
                SetPauseMenuPedLighting(true);
            else
                ClearPedInPauseMenu()
            end
            self.PlayersColumn.OnIndexChanged(self.PlayersColumn:CurrentSelection())
        end
    else
        local item = self.SettingsColumn.Items[self.SettingsColumn:CurrentSelection()];
        if not item:Enabled() then
            PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            return
        end
        local type, subtype = item()
        if subtype == "UIMenuListItem" then
            item:Index(tonumber(splitted[3]))
            item.OnListChanged(self, item, item._Index)
        elseif subtype == "UIMenuSliderItem" then
            item:Index(tonumber(splitted[3]))
            item.OnSliderChanged(self, item, item._Index)
        elseif subtype == "UIMenuProgressItem" then
            item:Index(tonumber(splitted[3]))
            item.OnProgressChanged(self, item, item:Index())
        end
        --PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end

function MainView:GoRight()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._lobby:CallFunction("SET_INPUT_EVENT", true, 11, self._delay) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueString(return_value)

    local splitted = Split(retVal, ",")

    if tonumber(splitted[3]) == -1 then
        self:FocusLevel(tonumber(splitted[1]) + 1)
        if self:FocusLevel() == self.SettingsColumn.Order then
            ClearPedInPauseMenu();
            self.SettingsColumn:CurrentSelection(tonumber(splitted[2]))
            self.SettingsColumn.OnIndexChanged(self.SettingsColumn:CurrentSelection());
        elseif self:FocusLevel() == self.PlayersColumn.Order then
            self.PlayersColumn:CurrentSelection(tonumber(splitted[2]))
            if self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= nil and self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                local ped = ClonePed(self.PlayersColumn.Items[self.PlayersColumn:CurrentSelection()].ClonePed, false,
                    true, true);
                Citizen.Wait(0)
                GivePedToPauseMenu(ped, 2)
                SetPauseMenuPedSleepState(true);
                SetPauseMenuPedLighting(true);
            else
                ClearPedInPauseMenu()
            end
            self.PlayersColumn.OnIndexChanged(self.PlayersColumn:CurrentSelection())
        end
    else
        local item = self.SettingsColumn.Items[self.SettingsColumn:CurrentSelection()];
        if not item:Enabled() then
            PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            return
        end
        local type, subtype = item()
        if subtype == "UIMenuListItem" then
            item:Index(tonumber(splitted[3]))
            item.OnListChanged(self, item, item._Index)
        elseif subtype == "UIMenuSliderItem" then
            item:Index(tonumber(splitted[3]))
            item.OnSliderChanged(self, item, item._Index)
        elseif subtype == "UIMenuProgressItem" then
            item:Index(tonumber(splitted[3]))
            item.OnProgressChanged(self, item, item:Index())
        end
        --PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end
UIMenuColorPanel = setmetatable({}, UIMenuColorPanel)
UIMenuColorPanel.__index = UIMenuColorPanel
UIMenuColorPanel.__call = function() return "UIMenuPanel", "UIMenuColorPanel" end

---@class UIMenuColorPanel
---@field public Title string
---@field public ColorPanelColorType number
---@field public value number
---@field public CustomColors table
---@field public ParentItem table
---@field public SetParentItem fun(self:UIMenuStatisticsPanel, item:UIMenuItem):UIMenuItem -- required
---@field public OnColorPanelChanged function

---New
---@param title string
---@param colorType number
---@param startIndex number
function UIMenuColorPanel.New(title, colorType, startIndex, colors)
    if colors ~= nil then
        colorType = 2
    end

    local _UIMenuColorPanel = {
        Title = title or "Color Panel",
        ColorPanelColorType = colorType,
        value = startIndex or 0,
        CustomColors = colors or nil,
        ParentItem = nil, -- required
        OnColorPanelChanged = function(item, panel, newindex)
        end
    }
    return setmetatable(_UIMenuColorPanel, UIMenuColorPanel)
end

---SetParentItem
---@param Item table
function UIMenuColorPanel:SetParentItem(Item) -- required
    if not Item() == nil then
        self.ParentItem = Item
    else
        return self.ParentItem
    end
end

function UIMenuColorPanel:CurrentSelection(new_value)
    if new_value ~= nil then
        self.value = new_value
        if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
            local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
            local van = IndexOf(self.ParentItem.Panels, self)
            ScaleformUI.Scaleforms._ui:CallFunction("SET_COLOR_PANEL_VALUE", false, it, van, new_value)
        end
    else
        return self.value
    end
end
UIMenuGridPanel = setmetatable({}, UIMenuGridPanel)
UIMenuGridPanel.__index = UIMenuGridPanel
UIMenuGridPanel.__call = function() return "UIMenuPanel", "UIMenuGridPanel" end

---@class UIMenuGridPanel
---@field public TopLabel string
---@field public RightLabel string
---@field public LeftLabel string
---@field public BottomLabel string
---@field public GridType number
---@field public ParentItem table
---@field public SetParentItem fun(self:UIMenuStatisticsPanel, item:UIMenuItem):UIMenuItem -- required
---@field public OnGridPanelChanged function

---New
---@param topText string
---@param leftText string
---@param rightText string
---@param bottomText string
---@param circlePosition vector2
---@param gridType number
function UIMenuGridPanel.New(topText, leftText, rightText, bottomText, circlePosition, gridType)
    local _UIMenuGridPanel = {
        TopLabel = topText or "UP",
        RightLabel = rightText or "RIGHT",
        LeftLabel = leftText or "LEFT",
        BottomLabel = bottomText or "DOWN",
        _CirclePosition = circlePosition or vector2(0.5, 0.5),
        GridType = gridType or 0,
        ParentItem = nil, -- required
        OnGridPanelChanged = function(item, panel, newindex)
        end
    }
    return setmetatable(_UIMenuGridPanel, UIMenuGridPanel)
end

---SetParentItem
---@param Item table
function UIMenuGridPanel:SetParentItem(Item) -- required
    if Item() ~= nil then
        self.ParentItem = Item
    else
        return self.ParentItem
    end
end

function UIMenuGridPanel:CirclePosition(position)
    if position ~= nil then
        self._CirclePosition = position
        if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
            local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
            local van = IndexOf(self.ParentItem.Panels, self)
            ScaleformUI.Scaleforms._ui:CallFunction("SET_GRID_PANEL_VALUE_RETURN_VALUE", false, it - 1, van - 1,
                position.x, position.y)
        end
    else
        return self._CirclePosition
    end
end
UIMenuPercentagePanel = setmetatable({}, UIMenuPercentagePanel)
UIMenuPercentagePanel.__index = UIMenuPercentagePanel
UIMenuPercentagePanel.__call = function() return "UIMenuPanel", "UIMenuPercentagePanel" end

---@class UIMenuPercentagePanel
---@field public Min string
---@field public Max string
---@field public Title string
---@field public Percentage number
---@field public ParentItem table
---@field public SetParentItem fun(self:UIMenuStatisticsPanel, item:UIMenuItem):UIMenuItem -- required
---@field public OnPercentagePanelChange function

---New
---@param title string
---@param minText string
---@param maxText string
---@param initialValue number
function UIMenuPercentagePanel.New(title, minText, maxText, initialValue)
    local _UIMenuPercentagePanel = {
        Min = minText or "0%",
        Max = maxText or "100%",
        Title = title or "Opacity",
        Percentage = initialValue or 0.0,
        ParentItem = nil, -- required
        OnPercentagePanelChange = function(item, panel, value)
        end
    }
    return setmetatable(_UIMenuPercentagePanel, UIMenuPercentagePanel)
end

function UIMenuPercentagePanel:Percentage(value)
    if value ~= nil then
        self.Percentage = value
        if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
            local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
            local van = IndexOf(self.ParentItem.Panels, self)
            ScaleformUI.Scaleforms._ui:CallFunction("SET_PERCENT_PANEL_RETURN_VALUE", false, it, van, value)
        end
    else
        return self.Percentage
    end
end

---SetParentItem
---@param Item table
function UIMenuPercentagePanel:SetParentItem(Item) -- required
    if not Item() == nil then
        self.ParentItem = Item
    else
        return self.ParentItem
    end
end
UIMenuStatisticsPanel = setmetatable({}, UIMenuStatisticsPanel)
UIMenuStatisticsPanel.__index = UIMenuStatisticsPanel
UIMenuStatisticsPanel.__call = function() return "UIMenuPanel", "UIMenuStatisticsPanel" end

---@class UIMenuStatisticsPanel
---@field public Items table
---@field public ParentItem UIMenuItem -- required
---@field public SetParentItem fun(self:UIMenuStatisticsPanel, item:UIMenuItem):UIMenuItem -- required

function UIMenuStatisticsPanel.New(items)
    local _UIMenuStatisticsPanel = {
        Items = items or {},
        ParentItem = nil, -- required
    }
    return setmetatable(_UIMenuStatisticsPanel, UIMenuStatisticsPanel)
end

---Set the parent item of the panel
---@param item UIMenuItem
---@return UIMenuItem
function UIMenuStatisticsPanel:SetParentItem(item) -- required
    if not item() ~= nil then
        self.ParentItem = item
    end
    return self.ParentItem
end

---Add a statistic to the panel
---@param name string -- The name of the statistic
---@param value number -- Must be between 0 and 100
function UIMenuStatisticsPanel:AddStatistic(name, value) -- required
    if name ~= nil and name ~= "" and value ~= nil then
        if value > 100 then
            value = 100
        elseif value < 0 then
            value = 0
        end
        table.insert(self.Items, { ['name'] = name,['value'] = value })
        if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
            local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
            local van = IndexOf(self.ParentItem.Panels, self)
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", false, it, van, name, value)
        end
    end
end

---Get the percentage of a statistic
---@param index number -- The index of the statistic 1-4
---@return number
function UIMenuStatisticsPanel:GetPercentage(index)
    if index ~= nil then
        if index > #self.Items then
            index = #self.Items
        elseif index < 1 then
            index = 1
        end
        return self.Items[index].value
    end
    return 0
end

---Update a statistic
---@param index number -- The index of the statistic starting from 1
---@param value number -- Must be a between 0 and 100
function UIMenuStatisticsPanel:UpdateStatistic(index, value)
    if value ~= nil then
        if value > 100 then
            value = 100
        elseif value < 0 then
            value = 0
        end
        self.Items[index].value = value
        if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
            local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
            local pan = IndexOf(self.ParentItem.Panels, self)
            ScaleformUI.Scaleforms._ui:CallFunction("SET_PANEL_STATS_ITEM_VALUE", false, it - 1, pan - 1, index - 1, value)
        end
    end
end
SettingsCheckboxItem = setmetatable({}, SettingsCheckboxItem)
SettingsCheckboxItem.__index = SettingsCheckboxItem
SettingsCheckboxItem.__call = function()
    return "SettingsItem", "SettingsItem"
end

---@class SettingsCheckboxItem
---@field public Base SettingsItem
---@field public ItemType SettingsItemType
---@field public Label string
---@field public CheckBoxStyle number
---@field public Parent SettingsItem
---@field public OnCheckboxChanged fun(item:SettingsCheckboxItem, checked:boolean)

---Create a new SettingsCheckboxItem.
---@param label string
---@param style number
---@param checked boolean
---@return table
function SettingsCheckboxItem.New(label, style, checked)
    local data = {
        Base = SettingsItem.New(label),
        ItemType = SettingsItemType.CheckBox,
        Label = label or "",
        CheckBoxStyle = style or 0,
        _isChecked = checked,
        _enabled = true,
        _hovered = false,
        _selected = false,
        Parent = nil,
        OnCheckboxChanged = function(item, _checked)
        end
    }
    return setmetatable(data, SettingsCheckboxItem)
end

---Toggle the enabled state of the item.
---@param enabled boolean
---@return boolean
function SettingsCheckboxItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_RIGHT_ITEM", false, tab, leftItem,
                    rightIndex, self._enabled)
            end
        end
    end
    return self._enabled
end

---Toggle the hovered state of the item.
---@param hover boolean
---@return boolean
function SettingsCheckboxItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    end
    return self._hovered
end

---Toggle the selected state of the item.
---@param selected boolean
---@return boolean
function SettingsCheckboxItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    end
    return self._selected
end

---Toggle the checked state of the item.
---@param checked boolean
---@return boolean
function SettingsCheckboxItem:Checked(checked)
    if checked ~= nil then
        self._isChecked = checked
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemBool(tab, leftItem, rightIndex, checked)
        self.OnCheckboxChanged(self, checked)
    end
    return self._isChecked
end
SettingsItem = setmetatable({}, SettingsItem)
SettingsItem.__index = SettingsItem
SettingsItem.__call = function()
    return "SettingsItem", "SettingsItem"
end

---@class SettingsItem
---@field ItemType SettingsItemType
---@field Label string
---@field Parent SettingsItem
---@field OnActivated fun(item:SettingsItem, index:number)

---Creates a new SettingsItem.
---@param label string
---@param rightLabel string?
---@return SettingsItem
function SettingsItem.New(label, rightLabel)
    local data = {
        ItemType = SettingsItemType.Basic,
        Label = label or "",
        _rightLabel = rightLabel or "",
        Parent = nil,
        _enabled = true,
        _hovered = false,
        _selected = false,
        OnActivated = function(item, index)
        end
    }
    return setmetatable(data, SettingsItem)
end

---Toggle the enabled state of the item.
---@param enabled any
---@return any
function SettingsItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_RIGHT_ITEM", false, tab, leftItem,
                    rightIndex, self._enabled)
            end
        end
    end
    return self._enabled
end

---Toggle the hovered state of the item.
---@param hover any
---@return any
function SettingsItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    end
    return self._hovered
end

---Toggle the selected state of the item.
---@param selected any
---@return any
function SettingsItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    end
    return self._selected
end

---Set the right label of the item.
---@param label string
---@return string
function SettingsItem:RightLabel(label)
    if label ~= nil then
        self._rightLabel = label
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu:UpdateItemRightLabel(tab, leftItem, rightIndex, self._rightLabel)
            end
        end
    end
    return self._rightLabel
end
SettingsListItem = setmetatable({}, SettingsListItem)
SettingsListItem.__index = SettingsListItem
SettingsListItem.__call = function()
    return "SettingsItem", "SettingsItem"
end

---@class SettingsListItem
---@field public Base SettingsItem
---@field public ItemType SettingsItemType
---@field public Label string
---@field public ListItems table
---@field public Parent SettingsItem
---@field public OnListChanged fun(item: SettingsListItem, value: number, listItem: string)
---@field public OnListSelected fun(item: SettingsListItem, value: number, listItem: string)

---Create a new SettingsListItem.
---@param label string
---@param items table
---@param index number
---@return table
function SettingsListItem.New(label, items, index)
    local data = {
        Base = SettingsItem.New(label, ""),
        ItemType = SettingsItemType.ListItem,
        Label = label or "",
        ListItems = items or {},
        _itemIndex = index or 0,
        _enabled = true,
        _hovered = false,
        _selected = false,
        Parent = nil,
        OnListChanged = function(item, value, listItem)
        end,
        OnListSelected = function(item, value, listItem)
        end
    }
    return setmetatable(data, SettingsListItem)
end

---Toggle the enabled state of the item.
---@param enabled boolean
---@return boolean
function SettingsListItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_RIGHT_ITEM", false, tab, leftItem,
                    rightIndex, self._enabled)
            end
        end
    end
    return self._enabled
end

---Toggle the hovered state of the item.
---@param hover boolean
---@return boolean
function SettingsListItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    end
    return self._hovered
end

---Toggle the selected state of the item.
---@param selected boolean
---@return boolean
function SettingsListItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    end
    return self._selected
end

---Set the index of the selected item.
---@param index number
---@return number
function SettingsListItem:ItemIndex(index)
    if index ~= nil then
        self._itemIndex = index
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemIndex(tab, leftItem, rightIndex, index)
        self.OnListChanged(self, self._itemIndex, tostring(self.ListItems[index]))
    end
    return self._itemIndex
end
SettingsProgressItem = setmetatable({}, SettingsProgressItem)
SettingsProgressItem.__index = SettingsProgressItem
SettingsProgressItem.__call = function()
    return "SettingsItem", "SettingsItem"
end

---@class SettingsProgressItem
---@field public Base BasicTabItem
---@field public ItemType SettingsItemType
---@field public Label string
---@field public MaxValue number
---@field public Parent BasicTabItem
---@field public OnBarChanged fun(item: SettingsProgressItem, value: number)
---@field public OnProgressSelected fun(item: SettingsProgressItem, value: number)

---Creates a new SettingsProgressItem.
---@param label string
---@param max number
---@param startIndex number
---@param masked boolean
---@param barColor number
---@return table
function SettingsProgressItem.New(label, max, startIndex, masked, barColor)
    local _type = SettingsItemType.ProgressBar
    if (masked) then
        _type = SettingsItemType.MaskedProgressBar
    end
    local data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = _type,
        Label = label or "",
        MaxValue = max,
        _value = startIndex,
        _coloredBarColor = barColor or Colours.HUD_COLOUR_FREEMODE,
        _enabled = true,
        _hovered = false,
        _selected = false,
        Parent = nil,
        OnBarChanged = function(item, value)
        end,
        OnProgressSelected = function(item, value)
        end
    }
    return setmetatable(data, SettingsProgressItem)
end

---Toggle the enabled state of the item.
---@param enabled boolean
---@return boolean
function SettingsProgressItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_RIGHT_ITEM", false, tab, leftItem,
                    rightIndex, self._enabled)
            end
        end
    end
    return self._enabled
end

---Toggle the hovered state of the item.
---@param hover boolean
---@return boolean
function SettingsProgressItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    end
    return self._hovered
end

---Toggle the selected state of the item.
---@param selected boolean
---@return boolean
function SettingsProgressItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    end
    return self._selected
end

---Set the value of the item.
---@param value number
---@return number
function SettingsProgressItem:Value(value)
    if value ~= nil then
        self._value = value
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemValue(tab, leftItem, rightIndex, value)
        self.OnBarChanged(self, value)
    end
    return self._value
end

---Set the color of the colored bar.
---@param color number
---@return number
function SettingsProgressItem:ColoredBarColor(color)
    if color ~= nil then
        self._coloredBarColor = color
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:UpdateItemColoredBar(tab, leftItem, rightIndex, color)
    end
    return self._coloredBarColor
end
SettingsSliderItem = setmetatable({}, SettingsSliderItem)
SettingsSliderItem.__index = SettingsSliderItem
SettingsSliderItem.__call = function()
    return "SettingsItem", "SettingsItem"
end

---@class SettingsSliderItem
---@field public Base BasicTabItem
---@field public ItemType SettingsItemType
---@field public Label string
---@field public MaxValue number
---@field public Parent BasicTabItem
---@field public OnBarChanged fun(item: SettingsSliderItem, value: number)
---@field public OnSliderSelected fun(item: SettingsSliderItem, value: number)

---Creates a new SettingsSliderItem.
---@param label string
---@param max number
---@param startIndex number
---@param barColor number
---@return table
function SettingsSliderItem.New(label, max, startIndex, barColor)
    local data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = SettingsItemType.SliderBar,
        Label = label or "",
        MaxValue = max,
        _value = startIndex,
        _coloredBarColor = barColor or Colours.HUD_COLOUR_FREEMODE,
        Parent = nil,
        _enabled = true,
        _hovered = false,
        _selected = false,
        OnBarChanged = function(item, value)
        end,
        OnSliderSelected = function(item, value)
        end
    }
    return setmetatable(data, SettingsSliderItem)
end

---Toggle the enabled state of the item.
---@param enabled boolean
---@return boolean
function SettingsSliderItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Parent ~= nil and self.Parent.Parent.Base.Parent ~= nil and self.Parent.Parent.Base.Parent:Visible() then
            if self.Parent:Selected() then
                local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
                local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
                local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_RIGHT_ITEM", false, tab, leftItem,
                    rightIndex, self._enabled)
            end
        end
    end
    return self._enabled
end

---Toggle the hovered state of the item.
---@param hover boolean
---@return boolean
function SettingsSliderItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    end
    return self._hovered
end

---Toggle the selected state of the item.
---@param selected boolean
---@return boolean
function SettingsSliderItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    end
    return self._selected
end

---Set the value of the item.
---@param value number
---@return number
function SettingsSliderItem:Value(value)
    if value ~= nil then
        self._value = value
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemValue(tab, leftItem, rightIndex, value)
        self.OnBarChanged(self, value)
    end
    return self._value
end

---Set the color of the colored bar.
---@param color number
---@return number
function SettingsSliderItem:ColoredBarColor(color)
    if color ~= nil then
        self._coloredBarColor = color
        local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
        local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
        local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
        ScaleformUI.Scaleforms._pauseMenu:UpdateItemColoredBar(tab, leftItem, rightIndex, color)
    end
    return self._coloredBarColor
end
BasicTabItem = setmetatable({}, BasicTabItem)
BasicTabItem.__index = BasicTabItem
BasicTabItem.__call = function()
    return "BasicTabItem", "BasicTabItem"
end

---@class BasicTabItem
---@field Label string
---@field Parent BasicTabItem

---Creates a new BasicTabItem.
---@param label string
---@return BasicTabItem
function BasicTabItem.New(label)
    local data = {
        Label = label or "",
        Parent = nil
    }
    return setmetatable(data, BasicTabItem)
end
KeymapItem = setmetatable({}, KeymapItem)
KeymapItem.__index = KeymapItem
KeymapItem.__call = function()
    return "BasicTabItem", "KeymapItem"
end

---@class KeymapItem
---@field public Label string
---@field public PrimaryKeyboard string
---@field public PrimaryGamepad string
---@field public SecondaryKeyboard string
---@field public SecondaryGamepad string

---Creates a new KeymapItem.
---@param title string
---@param primaryKeyboard string?
---@param primaryGamepad string?
---@param secondaryKeyboard string?
---@param secondaryGamepad string?
---@return table
function KeymapItem.New(title, primaryKeyboard, primaryGamepad, secondaryKeyboard, secondaryGamepad)
    local data = {}
    if secondaryKeyboard == nil and secondaryGamepad == nil then
        data = {
            Label = title,
            PrimaryKeyboard = primaryKeyboard,
            PrimaryGamepad = primaryGamepad,
            SecondaryKeyboard = "",
            SecondaryGamepad = "",
        }
    else
        data = {
            Label = title,
            PrimaryKeyboard = primaryKeyboard or "",
            PrimaryGamepad = primaryGamepad or "",
            SecondaryKeyboard = secondaryKeyboard or "",
            SecondaryGamepad = secondaryGamepad or "",
        }
    end
    return setmetatable(data, KeymapItem)
end
StatsTabItem = setmetatable({}, StatsTabItem)
StatsTabItem.__index = StatsTabItem
StatsTabItem.__call = function()
    return "BasicTabItem", "StatsTabItem"
end

---@class StatsTabItem
---@field public Base BasicTabItem
---@field public Type StatItemType
---@field public Label string
---@field public Parent BasicTabItem
---@field public OnBarChanged fun(item: StatsTabItem, value: number)
---@field public OnSliderSelected fun(item: StatsTabItem, value: number)

---Creates a new StatsTabItem.
---@param label string
---@param rightLabel string?
---@return table
function StatsTabItem.NewBasic(label, rightLabel)
    local data = {
        Base = BasicTabItem.New(label or ""),
        Type = StatItemType.Basic,
        Label = label or "",
        _rightLabel = rightLabel or ""
    }
    return setmetatable(data, StatsTabItem)
end

---Adds a new bar to the StatsTabItem.
---@param label string
---@param value number?
---@param color number?
---@return table
function StatsTabItem.NewBar(label, value, color)
    local data = {
        Base = BasicTabItem.New(label or ""),
        Type = StatItemType.ColoredBar,
        Label = label or "",
        _value = value,
        _coloredBarColor = color or Colours.HUD_COLOUR_FREEMODE
    }
    return setmetatable(data, StatsTabItem)
end

---Sets the right label of the item.
---@param label string
---@return string
function StatsTabItem:RightLabel(label)
    if self.Type == StatItemType.Basic then
        if label ~= nil then
            self._rightLabel = label
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBasic(tab, leftItem, rightIndex, self.Label,
                self._rightLabel)
        else
            return self._rightLabel
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: RightLabel function can only be called by Basic items.. your item is of type: " ..
            _type)
    end
    return self._rightLabel
end

---Sets the value of the item.
---@param value any
---@return any
function StatsTabItem:Value(value)
    if self.Type == StatItemType.ColoredBar then
        if value ~= nil then
            self._value = value
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBar(tab, leftItem, rightIndex, self._value)
            self.OnBarChanged(self, value)
        else
            return self._value
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: Value function can only be called by colored bar items.. your item is of type: " ..
            _type)
    end
    return self._value
end

---Sets the color of the item.
---@param color number
---@return number
function StatsTabItem:ColoredBarColor(color)
    if self.Type == StatItemType.ColoredBar then
        if color ~= nil then
            self._coloredBarColor = color
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBar(tab, leftItem, rightIndex, color)
        else
            return self._coloredBarColor
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print(
            "SCALEFORMUI - WARNING: ColoredBarColor function can only be called by colored bar items.. your item is of type: " ..
            _type)
    end
    return self._coloredBarColor
end
BaseTab = setmetatable({}, BaseTab)
BaseTab.__index = BaseTab
BaseTab.__call = function()
    return "BaseTab", "BaseTab"
end

---@class BaseTab
---@field public Title string
---@field public Type number
---@field public Visible boolean
---@field public Focused boolean
---@field public Active boolean
---@field public Parent BaseTab
---@field public LeftItemList BasicTabItem[]
---@field public Activated fun(item: BaseTab)

---Creates a new BaseTab.
---@param title string
---@param type number
---@return BaseTab
function BaseTab.New(title, type)
    local data = {
        Title = title or "",
        Type = type or 0,
        Visible = false,
        Focused = false,
        Active = false,
        Parent = nil,
        LeftItemList = {},
        Activated = function(item)
        end
    }
    return setmetatable(data, BaseTab)
end
PlayerListTab = setmetatable({}, PlayerListTab)
PlayerListTab.__index = PlayerListTab
PlayerListTab.__call = function()
    return "BaseTab", "PlayerListTab"
end

---@class PlayerListTab
---@field public Base BaseTab
---@field public LeftItemList BasicTabItem[]
---@field public Label string
---@field public TextTitle string
---@field public SettingsColumn SettingsListColumn
---@field public PlayersColumn PlayerListColumn
---@field public Index number
---@field public Focused boolean

---Creates a new PlayerListTab.
---@param name string
---@return PlayerListTab
function PlayerListTab.New(name)
    local data = {
        Base = BaseTab.New(name or "", 2),
        LeftItemList = {},
        Label = name or "",
        TextTitle = "",
        SettingsColumn = SettingsListColumn.New("", -1),
        PlayersColumn = PlayerListColumn.New("", -1),
        Index = 0,
        Focused = false,
        _focus = 0,
    }
    return setmetatable(data, PlayerListTab)
end

---Sets the focus of the tab.
---@param _f number
---@return number
function PlayerListTab:Focus(_f)
    if _f ~= nil then
        self._focus = _f
        if self.Base.Parent ~= nil and self.Base.Parent:Visible() then
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_PLAYERS_TAB_FOCUS", false,
                IndexOf(self.Base.Parent.Tabs, self) - 1, self._focus)
        end
    end
    return self._focus
end
SubmenuTab = setmetatable({}, SubmenuTab)
SubmenuTab.__index = SubmenuTab
SubmenuTab.__call = function()
    return "BaseTab", "SubmenuTab"
end

---@class SubmenuTab

function SubmenuTab.New(name)
    local data = {
        Base = BaseTab.New(name or "", 1),
        Label = name or "",
        TextTitle = "",
        LeftItemList = {},
        Index = 0,
        Focused = false,
        Parent = nil,
    }
    return setmetatable(data, SubmenuTab)
end

function SubmenuTab:AddLeftItem(item)
    item.Parent = self
    self.LeftItemList[#self.LeftItemList + 1] = item
end
TabLeftItem = setmetatable({}, TabLeftItem)
TabLeftItem.__index = TabLeftItem
TabLeftItem.__call = function()
    return "TabLeftItem", "TabLeftItem"
end

---@class TabLeftItem
---@field public Label string
---@field public ItemType number
---@field public Focused boolean
---@field public MainColor number
---@field public HighlightColor number
---@field public Highlighted boolean
---@field public ItemIndex number
---@field public ItemList table<SettingsItem|SettingsListItem|SettingsProgressItem|SettingsCheckboxItem|SettingsSliderItem|KeymapItem>
---@field public TextTitle string
---@field private _enabled boolean
---@field private _hovered boolean
---@field private _selected boolean
---@field public KeymapRightLabel_1 string
---@field public KeymapRightLabel_2 string
---@field public Index number
---@field public AddItem fun(self:TabLeftItem, item:SettingsItem|SettingsListItem|SettingsProgressItem|SettingsCheckboxItem|SettingsSliderItem|KeymapItem|BasicTabItem)
---@field public Enabled fun(self:TabLeftItem, enabled:boolean):boolean
---@field public Hovered fun(self:TabLeftItem, hover:boolean):boolean
---@field public Selected fun(self:TabLeftItem, selected:boolean):boolean
---@field public OnIndexChanged fun(item:TabLeftItem, index:number)
---@field public OnActivated fun(item:TabLeftItem, index:number)

function TabLeftItem.New(label, _type, mainColor, highlightColor)
    local data = {
        Label = label or "",
        ItemType = _type,
        Focused = false,
        MainColor = mainColor or Colours.NONE,
        HighlightColor = highlightColor or Colours.NONE,
        Highlighted = false,
        ItemIndex = 0,
        ItemList = {} --[[@type table<SettingsItem|SettingsListItem|SettingsProgressItem|SettingsCheckboxItem|SettingsSliderItem|KeymapItem|BasicTabItem>]],
        TextTitle = "",
        _enabled = true,
        _hovered = false,
        _selected = false,
        KeymapRightLabel_1 = "",
        KeymapRightLabel_2 = "",
        OnIndexChanged = function(item, index)
        end,
        OnActivated = function(item, index)
        end,
        Index = 0,
        Parent = nil
    }
    return setmetatable(data, TabLeftItem)
end

---Add item to the tab list
---@param item SettingsItem|SettingsListItem|SettingsProgressItem|SettingsCheckboxItem|SettingsSliderItem|KeymapItem|BasicTabItem
function TabLeftItem:AddItem(item)
    item.Parent = self
    self.ItemList[#self.ItemList + 1] = item
end

function TabLeftItem:Enabled(enabled)
    if enabled ~= nil then
        self._enabled = enabled
        if self.Parent ~= nil and self.Parent.Base.Parent ~= nil and self.Parent.Base.Parent:Visible() then
            local tab = IndexOf(self.Parent.Base.Parent.Tabs, self.Parent) - 1
            local leftItem = IndexOf(self.Parent.LeftItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ENABLE_LEFT_ITEM", false, tab, leftItem, self
                ._enabled)
        end
    else
        return self._enabled
    end
end

function TabLeftItem:Hovered(hover)
    if hover ~= nil then
        self._hovered = hover
    else
        return self._hovered
    end
end

function TabLeftItem:Selected(selected)
    if selected ~= nil then
        self._selected = selected
    else
        return self._selected
    end
end
TextTab = setmetatable({}, TextTab)
TextTab.__index = TextTab
TextTab.__call = function()
    return "BaseTab", "TextTab"
end

---@class TextTab

function TextTab.New(name, _title)
    local data = {
        Base = BaseTab.New(name or "", 0),
        Label = name,
        TextTitle = _title or "",
        LabelsList = {},
        LeftItemList = {},
        Index = 0,
        Focused = false,
        Parent = nil
    }
    return setmetatable(data, TextTab)
end

function TextTab:AddTitle(title)
    if not title:IsNullOrEmpty() then
        self.TextTitle = title
    end
end

function TextTab:AddItem(item)
    self.LabelsList[#self.LabelsList + 1] = item
end
---@class StatItemType
StatItemType = {
    Basic = 0,
    ColoredBar = 1,
}

---@class SettingsItemType
SettingsItemType = {
    Basic = 0,
    ListItem = 1,
    ProgressBar = 2,
    MaskedProgressBar = 3,
    CheckBox = 4,
    SliderBar = 5
}

---@class LeftItemType
LeftItemType = {
    Empty = 0,
    Info = 1,
    Statistics = 2,
    Settings = 3,
    Keymap = 4
}
TabView = setmetatable({}, TabView)
TabView.__index = TabView
TabView.__call = function()
    return "PauseMenu"
end
TabView.SoundId = GetSoundId()

---@class TabView

---comment
---@param title string
---@param subtitle string
---@param sideTop string
---@param sideMiddle string
---@param sideBottom string
function TabView.New(title, subtitle, sideTop, sideMiddle, sideBottom)
    local _data = {
        Title = title or "",
        Subtitle = subtitle or "",
        SideTop = sideTop or "",
        SideMid = sideMiddle or "",
        SideBot = sideBottom or "",
        _headerPicture = {},
        _crewPicture = {},
        Tabs = {},
        Index = 1,
        ParentPool = nil,
        _visible = false,
        focusLevel = 0,
        rightItemIndex = 1,
        leftItemIndex = 1,
        TemporarilyHidden = false,
        controller = false,
        _loaded = false,
        _timer = 0,
        _canHe = true,
        InstructionalButtons = {
            InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 176, 176, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT1C"), -1, -1, -1, "INPUTGROUP_FRONTEND_BUMPERS")
        },
        OnPauseMenuOpen = function(menu)
        end,
        OnPauseMenuClose = function(menu)
        end,
        OnPauseMenuTabChanged = function(menu, tab, tabIndex)
        end,
        OnPauseMenuFocusChanged = function(menu, tab, focusLevel)
        end,
        OnLeftItemChange = function(menu, leftItem, index)
        end,
        OnRightItemChange = function(menu, rightItem, index)
        end,
        OnLeftItemSelect = function(menu, leftItem, index)
        end,
        OnRightItemSelect = function(menu, rightItem, index)
        end
    }
    return setmetatable(_data, TabView)
end

function TabView:LeftItemIndex(index)
    if index ~= nil then
        self.leftItemIndex = index
        self.OnLeftItemChange(self, self.Tabs[self.Index].LeftItemList[self.leftItemIndex], self.leftItemIndex)
    else
        return self.leftItemIndex
    end
end

function TabView:RightItemIndex(index)
    if index ~= nil then
        self.rightItemIndex = index
        self.OnRightItemChange(self, self.Tabs[self.Index].LeftItemList[self.leftItemIndex].ItemList
            [self.rightItemIndex], self.rightItemIndex)
    else
        return self.rightItemIndex
    end
end

function TabView:FocusLevel(index)
    if index ~= nil then
        self.focusLevel = index
        ScaleformUI.Scaleforms._pauseMenu:SetFocus(index)
        self.OnPauseMenuFocusChanged(self, self.Tabs[self.Index], index)
    else
        return self.focusLevel
    end
end

function TabView:Visible(visible)
    if visible ~= nil then
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(visible)
        self._visible = visible
        ScaleformUI.Scaleforms._pauseMenu:Visible(visible)
        if visible == true then
            if not IsPauseMenuActive() then
                self.focusLevel = 1
                PlaySoundFrontend(self.SoundId, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET", true)
                ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, true, -1)
                self:BuildPauseMenu()
                self.ParentPool:ProcessMenus(true)
                self.OnPauseMenuOpen(self)
                AnimpostfxPlay("PauseMenuIn", 800, true)
                ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.InstructionalButtons)
                SetPlayerControl(PlayerId(), false, 0)
            end
        else
            ScaleformUI.Scaleforms._pauseMenu:Dispose()
            AnimpostfxStop("PauseMenuIn")
            AnimpostfxPlay("PauseMenuOut", 800, false)
            self.OnPauseMenuClose(self)
            SetPlayerControl(PlayerId(), true, 0)
            self.ParentPool:ProcessMenus(false)
            if IsPauseMenuActive() then
                PlaySoundFrontend(self.SoundId, "Hit_Out", "PLAYER_SWITCH_CUSTOM_SOUNDSET", true)
                ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, true, -1)
            end
            SetFrontendActive(false)
        end
    else
        return self._visible
    end
end

function TabView:AddTab(item)
    item.Base.Parent = self
    self.Tabs[#self.Tabs + 1] = item
    local _, subT = item()
    if subT == "PlayerListTab" then
        item.SettingsColumn.ParentTab = #self.Tabs - 1
        item.SettingsColumn.Parent = self
        item.PlayersColumn.ParentTab = #self.Tabs - 1
        item.PlayersColumn.Parent = self
    end
end

function TabView:HeaderPicture(Txd, Txn)
    if (Txd ~= nil and Txn ~= nil) then
        self._headerPicture = { txd = Txd, txn = Txn }
    else
        return self._headerPicture
    end
end

function TabView:CrewPicture(Txd, Txn)
    if (Txd ~= nil and Txn ~= nil) then
        self._crewPicture = { txd = Txd, txn = Txn }
    else
        return self._crewPicture
    end
end

function TabView:CanPlayerCloseMenu(canHe)
    if canHe == nil then
        return self._canHe
    else
        self._canHe = canHe
    end
end

function TabView:ShowHeader()
    if self.Subtitle:IsNullOrEmpty() then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title)
    else
        ScaleformUI.Scaleforms._pauseMenu:ShiftCoronaDescription(true, false)
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title, self.Subtitle)
    end
    if (self:HeaderPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderCharImg(self:HeaderPicture().txd, self:HeaderPicture().txn, true)
    end
    if (self:CrewPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderSecondaryImg(self:CrewPicture().txd, self:CrewPicture().txn, true)
    end
    ScaleformUI.Scaleforms._pauseMenu:SetHeaderDetails(self.SideTop, self.SideMid, self.SideBot)
    self._loaded = true
end

function TabView:BuildPauseMenu()
    BeginTextCommandBusyspinnerOn("FMMC_DOWNLOAD")
    EndTextCommandBusyspinnerOn(1)

    self:ShowHeader()
    for k, tab in pairs(self.Tabs) do
        local tabIndex = k - 1
        local type, subtype = tab()
        if subtype == "TextTab" then
            ScaleformUI.Scaleforms._pauseMenu:AddPauseMenuTab(tab.Base.Title, 1, tab.Base.Type)
            if not tostring(tab.TextTitle):IsNullOrEmpty() then
                ScaleformUI.Scaleforms._pauseMenu:AddRightTitle(tabIndex, 0, tab.TextTitle)
            end
            for j, item in pairs(tab.LabelsList) do
                ScaleformUI.Scaleforms._pauseMenu:AddRightListLabel(tabIndex, 0, item.Label)
            end
        elseif subtype == "SubmenuTab" then
            ScaleformUI.Scaleforms._pauseMenu:AddPauseMenuTab(tab.Base.Title, 1, tab.Base.Type)
            for j, item in pairs(tab.LeftItemList) do
                local itemIndex = j - 1
                ScaleformUI.Scaleforms._pauseMenu:AddLeftItem(tabIndex, item.ItemType, item.Label, item.MainColor,
                    item.HighlightColor, item:Enabled())

                if item.TextTitle ~= nil and not item.TextTitle:IsNullOrEmpty() then
                    if (item.ItemType == LeftItemType.Keymap) then
                        ScaleformUI.Scaleforms._pauseMenu:AddKeymapTitle(tabIndex, itemIndex, item.TextTitle,
                            item.KeymapRightLabel_1, item.KeymapRightLabel_2)
                    else
                        ScaleformUI.Scaleforms._pauseMenu:AddRightTitle(tabIndex, itemIndex, item.TextTitle)
                    end
                end

                for l, ii in pairs(item.ItemList) do
                    local __type, __subtype = ii()
                    if __subtype == "StatsTabItem" then
                        if (ii.Type == StatItemType.Basic) then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightStatItemLabel(tabIndex, itemIndex, ii.Label,
                                ii._rightLabel)
                        elseif (ii.Type == StatItemType.ColoredBar) then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightStatItemColorBar(tabIndex, itemIndex, ii.Label,
                                ii._value, ii._coloredBarColor)
                        end
                    elseif __subtype == "SettingsItem" then
                        if ii.ItemType == SettingsItemType.Basic then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsBaseItem(tabIndex, itemIndex, ii.Label,
                                ii._rightLabel, ii:Enabled())
                        elseif ii.ItemType == SettingsItemType.ListItem then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsListItem(tabIndex, itemIndex, ii.Label,
                                ii.ListItems, ii._itemIndex, ii:Enabled())
                        elseif ii.ItemType == SettingsItemType.ProgressBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsProgressItem(tabIndex, itemIndex, ii.Label,
                                ii.MaxValue, ii._coloredBarColor, ii._value, ii:Enabled())
                        elseif ii.ItemType == SettingsItemType.MaskedProgressBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsProgressItemAlt(tabIndex, itemIndex,
                                ii.Label, ii.MaxValue, ii._coloredBarColor, ii._value, ii:Enabled())
                        elseif ii.ItemType == SettingsItemType.CheckBox then
                            while (not HasStreamedTextureDictLoaded("commonmenu")) do
                                Citizen.Wait(0)
                                RequestStreamedTextureDict("commonmenu", true)
                            end
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsCheckboxItem(tabIndex, itemIndex, ii.Label,
                                ii.CheckBoxStyle, ii._isChecked, ii:Enabled())
                        elseif ii.ItemType == SettingsItemType.SliderBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsSliderItem(tabIndex, itemIndex, ii.Label,
                                ii.MaxValue, ii._coloredBarColor, ii._value, ii:Enabled())
                        end
                    elseif __subtype == "KeymapItem" then
                        if IsUsingKeyboard(2) then
                            ScaleformUI.Scaleforms._pauseMenu:AddKeymapItem(tabIndex, itemIndex, ii.Label,
                                ii.PrimaryKeyboard, ii.SecondaryKeyboard)
                        else
                            ScaleformUI.Scaleforms._pauseMenu:AddKeymapItem(tabIndex, itemIndex, ii.Label,
                                ii.PrimaryGamepad, ii.SecondaryGamepad)
                        end
                        self:UpdateKeymapItems()
                    else
                        ScaleformUI.Scaleforms._pauseMenu:AddRightListLabel(tabIndex, itemIndex, ii.Label)
                    end
                    Citizen.Wait(0)
                end
                Citizen.Wait(0)
            end
        elseif subtype == "PlayerListTab" then
            ScaleformUI.Scaleforms._pauseMenu:AddPauseMenuTab(tab.Base.Title, 1, tab.Base.Type)
            Citizen.CreateThread(function()
                local items = tab.SettingsColumn.Items
                local it = 1
                while it <= #items do
                    Citizen.Wait(1)
                    local item = items[it]
                    local Type, SubType = item()
                    AddTextEntry("menu_pause_playerTab{" .. it .. "}", item:Description())

                    if SubType == "UIMenuListItem" then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_SETTINGS_ITEM", false,
                            tabIndex, 1, item:Label(), "menu_pause_playerTab{" .. it .. "}", item:Enabled(),
                            item:BlinkDescription(), table.concat(item.Items, ","), item:Index() - 1,
                            item.Base._mainColor,
                            item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
                    elseif SubType == "UIMenuCheckboxItem" then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_SETTINGS_ITEM", false,
                            tabIndex, 2, item:Label(), "menu_pause_playerTab{" .. it .. "}", item:Enabled(),
                            item:BlinkDescription(), item.CheckBoxStyle, item._Checked, item.Base._mainColor,
                            item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
                    elseif SubType == "UIMenuSliderItem" then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_SETTINGS_ITEM", false,
                            tabIndex, 3, item:Label(), "menu_pause_playerTab{" .. it .. "}", item:Enabled(),
                            item:BlinkDescription(), item._Max, item._Multiplier, item:Index(), item.Base._mainColor,
                            item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor,
                            item.SliderColor, item._heritage)
                    elseif SubType == "UIMenuProgressItem" then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_SETTINGS_ITEM", false,
                            tabIndex, 4, item:Label(), "menu_pause_playerTab{" .. it .. "}", item:Enabled(),
                            item:BlinkDescription(), item._Max, item._Multiplier, item:Index(), item.Base._mainColor,
                            item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor,
                            item.SliderColor)
                    else
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_SETTINGS_ITEM", false,
                            tabIndex, 0, item:Label(), "menu_pause_playerTab{" .. it .. "}", item:Enabled(),
                            item:BlinkDescription(), item._mainColor, item._highlightColor, item._textColor,
                            item._highlightedTextColor)
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SETTINGS_SET_RIGHT_LABEL", false, it - 1,
                            item:RightLabel())
                        if item._rightBadge ~= BadgeStyle.NONE then
                            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SETTINGS_SET_RIGHT_BADGE", false,
                                it - 1, item._rightBadge)
                        end
                    end
                    --[[
                    if (SubType == "UIMenuItem" and item._leftBadge ~= BadgeStyle.NONE) or (SubType ~= "UIMenuItem" and item.Base._leftBadge ~= BadgeStyle.NONE) then
                        if SubType ~= "UIMenuItem" then
                            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SETTINGS_SET_LEFT_BADGE", false, it - 1, item.Base._leftBadge)
                        else
                            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SETTINGS_SET_LEFT_BADGE", false, it - 1, item._leftBadge)
                        end
                    end
                    ]]
                    it = it + 1
                end
                tab.SettingsColumn:CurrentSelection(0)
            end)
            Citizen.CreateThread(function()
                local items = tab.PlayersColumn.Items
                local it = 1
                while it <= #items do
                    Citizen.Wait(1)
                    local item = items[it]
                    local Type, SubType = item()
                    if SubType == "FriendItem" then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("ADD_PLAYERS_TAB_PLAYER_ITEM", false,
                            tabIndex, 1, 1, item:Label(), item:ItemColor(), item:ColoredTag(), item._iconL, item._boolL,
                            item._iconR, item._boolR, item:Status(), item:StatusColor(), item:Rank(), item:CrewTag())
                    end
                    if item.Panel ~= nil then
                        item.Panel:UpdatePanel(true)
                    end
                    it = it + 1
                end
                tab.PlayersColumn:CurrentSelection(0)
            end)
        end
    end

    BusyspinnerOff()
end

function TabView:UpdateKeymapItems()
    if not IsUsingKeyboard(2) then
        if not self.controller then
            self.controller = true
            for j, tab in pairs(self.Tabs) do
                local type, subtype = tab()
                if subtype == "SubmenuTab" then
                    for k, lItem in pairs(tab.LeftItemList) do
                        local idx = k - 1
                        if lItem.ItemType == LeftItemType.Keymap then
                            for i = 1, #lItem.ItemList, 1 do
                                local item = lItem.ItemList[i]
                                ScaleformUI.Scaleforms._pauseMenu:UpdateKeymap(j - 1, idx, i - 1, item.PrimaryGamepad,
                                    item.SecondaryGamepad)
                            end
                        end
                    end
                end
            end
        end
    else
        if self.controller then
            self.controller = false
            for j, tab in pairs(self.Tabs) do
                local type, subtype = tab()
                if subtype == "SubmenuTab" then
                    for k, lItem in pairs(tab.LeftItemList) do
                        local idx = k - 1
                        if lItem.ItemType == LeftItemType.Keymap then
                            for i = 1, #lItem.ItemList, 1 do
                                local item = lItem.ItemList[i]
                                ScaleformUI.Scaleforms._pauseMenu:UpdateKeymap(j - 1, idx, i - 1, item.PrimaryKeyboard,
                                    item.SecondaryKeyboard)
                            end
                        end
                    end
                end
            end
        end
    end
end

function TabView:Draw()
    if not self:Visible() or self.TemporarilyHidden then
        return
    end
    DisableControlAction(0, 199, true)
    DisableControlAction(0, 200, true)
    DisableControlAction(1, 199, true)
    DisableControlAction(1, 200, true)
    DisableControlAction(2, 199, true)
    DisableControlAction(2, 200, true)
    ScaleformUI.Scaleforms._pauseMenu:Draw()
    self:UpdateKeymapItems()
end

function TabView:Select()
    if self:FocusLevel() == 0 then
        self:FocusLevel(self:FocusLevel() + 1)
        local tab = self.Tabs[self.Index]
        local cur_tab, cur_sub_tab = tab()
        if cur_sub_tab == "PlayerListTab" then
            SetPauseMenuPedLighting(self:FocusLevel() ~= 0)
        end
        --[[ check if all disabled ]]
        local allDisabled = true
        for _, v in ipairs(self.Tabs[self.Index].LeftItemList) do
            if v:Enabled() then
                allDisabled = false
                break
            end
        end
        if allDisabled then return end
        --[[ end check all disabled ]]
        --
        while (not self.Tabs[self.Index].LeftItemList[self.leftItemIndex]:Enabled()) do
            Citizen.Wait(0)
            self.leftItemIndex = self.leftItemIndex + 1
            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_LEFT_ITEM_INDEX", false, self.leftItemIndex - 1)
        end
    elseif self:FocusLevel() == 1 then
        local tab = self.Tabs[self.Index]
        local cur_tab, cur_sub_tab = tab()
        if cur_sub_tab == "SubmenuTab" then
            local leftItem = tab.LeftItemList[self.leftItemIndex]
            if not leftItem:Enabled() then
                PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                return
            end
            if leftItem.ItemType == LeftItemType.Settings then
                self:FocusLevel(2)
                --[[ check if all disabled ]]
                local allDisabled = true
                for _, v in ipairs(self.Tabs[self.Index].LeftItemList) do
                    if v:Enabled() then
                        allDisabled = false
                        break
                    end
                end
                if allDisabled then return end
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                --[[ end check all disabled ]]
                --
                while (not self.Tabs[self.Index].LeftItemList[self.leftItemIndex]:Enabled()) do
                    Citizen.Wait(0)
                    self.rightItemIndex = self.rightItemIndex + 1
                    ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_RIGHT_ITEM_INDEX", false,
                        self.rightItemIndex - 1)
                end
            end
        elseif cur_sub_tab == "PlayerListTab" then
            if tab:Focus() == 0 then
                tab:Focus(1)
            elseif tab:Focus() == 1 then
                local _item = tab.SettingsColumn.Items[tab.SettingsColumn:CurrentSelection()]
                if not _item:Enabled() then
                    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    return
                end
                local _, subtype = _item()
                if subtype == "UIMenuCheckboxItem" then
                    _item:Checked(not _item:Checked())
                    _item.OnCheckboxChanged(self, _item, _item:Checked())
                elseif subtype == "UIMenuListItem" then
                    _item.OnListSelected(self, _item, _item._Index)
                elseif subtype == "UIMenuDynamicListItem" then
                    _item.OnListSelected(self, _item, _item._currentItem)
                elseif subtype == "UIMenuSliderItem" then
                    _item.OnSliderSelected(self, _item, _item._Index)
                elseif subtype == "UIMenuProgressItem" then
                    _item.OnProgressSelected(self, _item, _item._Index)
                elseif subtype == "UIMenuStatsItem" then
                    _item.OnStatsSelected(self, _item, _item._Index)
                else
                    _item:Activated(self, _item)
                end
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", false, 16)
            end
        end
    elseif self:FocusLevel() == 2 then
        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", false, 16)
        local leftItem = self.Tabs[self.Index].LeftItemList[self.leftItemIndex]
        if leftItem.ItemType == LeftItemType.Settings then
            local rightItem = leftItem.ItemList[self.rightItemIndex]
            if not rightItem:Enabled() then
                PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                return
            end
            --[[ to add real functions ]]
            --
            if rightItem.ItemType == SettingsItemType.ListItem then
                rightItem.OnListSelected(rightItem, rightItem:ItemIndex(),
                    tostring(rightItem.ListItems[rightItem:ItemIndex()]))
            elseif rightItem.ItemType == SettingsItemType.CheckBox then
                rightItem:Checked(not rightItem:Checked())
            elseif rightItem.ItemType == SettingsItemType.MaskedProgressBar or rightItem.ItemType == SettingsItemType.ProgressBar then
                rightItem.OnProgressSelected(rightItem, rightItem:Value())
            elseif rightItem.ItemType == SettingsItemType.SliderBar then
                rightItem.OnSliderSelected(rightItem, rightItem:Value())
            else
                rightItem.OnActivated(rightItem, IndexOf(leftItem.ItemList, rightItem))
            end
            self.OnRightItemSelect(self, rightItem, self.rightItemIndex)
        end
    end
end

function TabView:GoBack()
    if self:FocusLevel() > 0 then
        if self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab:Focus() == 1 then
                    tab:Focus(0)
                    return
                end
            end
        end
        self:FocusLevel(self:FocusLevel() - 1)
        SetPauseMenuPedLighting(self:FocusLevel() ~= 0)
    else
        if self:CanPlayerCloseMenu() then
            self:Visible(false)
        end
    end
end

function TabView:GoUp()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", true, 8) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueInt(return_value)
    if retVal ~= -1 then
        if self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab:Focus() == 0 then
                    tab.PlayersColumn:CurrentSelection(retVal)
                    if tab.PlayersColumn.Items[retVal + 1].ClonePed ~= nil and tab.PlayersColumn.Items[retVal + 1].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[retVal + 1]:AddPedToPauseMenu(tab.PlayersColumn.Items[retVal + 1]
                            .ClonePed)
                    else
                        tab.PlayersColumn.Items[retVal + 1]:AddPedToPauseMenu()
                    end
                    tab.PlayersColumn.OnIndexChanged(retVal + 1)
                    return
                elseif tab:Focus() == 1 then
                    tab.SettingsColumn:CurrentSelection(retVal)
                    tab.SettingsColumn.OnIndexChanged(retVal + 1)
                    return
                end
            end
            self:LeftItemIndex(retVal + 1)
        elseif self:FocusLevel() == 2 then
            self:RightItemIndex(retVal + 1)
        end
    end
end

function TabView:GoDown()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", true, 9) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueInt(return_value)
    if retVal ~= -1 then
        if self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab:Focus() == 0 then
                    tab.PlayersColumn:CurrentSelection(retVal)
                    if tab.PlayersColumn.Items[retVal + 1].ClonePed ~= nil and tab.PlayersColumn.Items[retVal + 1].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[retVal + 1]:AddPedToPauseMenu(tab.PlayersColumn.Items[retVal + 1]
                            .ClonePed)
                    else
                        tab.PlayersColumn.Items[retVal + 1]:AddPedToPauseMenu()
                    end
                    tab.PlayersColumn.OnIndexChanged(retVal + 1)
                    return
                elseif tab:Focus() == 1 then
                    tab.SettingsColumn:CurrentSelection(retVal)
                    tab.SettingsColumn.OnIndexChanged(retVal + 1)
                    return
                end
            end
            self:LeftItemIndex(retVal + 1)
        elseif self:FocusLevel() == 2 then
            self:RightItemIndex(retVal + 1)
        end
    end
end

function TabView:GoLeft()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", true, 10) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueInt(return_value)

    if retVal ~= -1 then
        if self:FocusLevel() == 0 then
            ScaleformUI.Scaleforms._pauseMenu:HeaderGoLeft()
            self.Index = retVal + 1
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                    tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab.PlayersColumn
                        .Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                else
                    tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                end
            else
                ClearPedInPauseMenu()
            end
        elseif self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab:Focus() == 0 then
                    if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab
                            .PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                    else
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                    end
                elseif tab:Focus() == 1 then
                    local Item = tab.SettingsColumn.Items[tab.SettingsColumn:CurrentSelection()]
                    if not Item:Enabled() then
                        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        return
                    end

                    local type, subtype = Item()

                    if subtype == "UIMenuListItem" then
                        Item:Index(retVal)
                        Item.OnListChanged(self, Item, Item._Index)
                    elseif subtype == "UIMenuSliderItem" then
                        Item:Index(retVal)
                        Item.OnSliderChanged(self, Item, Item._Index)
                    elseif subtype == "UIMenuProgressItem" then
                        Item:Index(retVal)
                        Item.OnProgressChanged(self, Item, Item:Index())
                    elseif subtype == "UIMenuStatsItem" then
                        Item:Index(retVal)
                        Item.OnStatsChanged(self, Item, Item._Index)
                    end
                end
                return
            end
        elseif self:FocusLevel() == 2 then
            local rightItem = self.Tabs[self.Index].LeftItemList[self.leftItemIndex].ItemList[self.rightItemIndex]
            local sub_item, sub_item_type = rightItem()

            if sub_item_type == "SettingsItem" then
                if rightItem.ItemType == SettingsItemType.ListItem then
                    rightItem:ItemIndex(retVal)
                    rightItem.OnListChanged(rightItem, rightItem:ItemIndex(),
                        tostring(rightItem.ListItems[rightItem:ItemIndex()]))
                elseif rightItem.ItemType == SettingsItemType.SliderBar then
                    rightItem:Value(retVal)
                    rightItem.OnBarChanged(rightItem, rightItem:Value())
                elseif rightItem.ItemType == SettingsItemType.ProgressBar or rightItem.ItemType == SettingsItemType.MaskedProgressBar then
                    rightItem:Value(retVal)
                    rightItem.OnBarChanged(rightItem, rightItem:Value())
                end
            end
        end
    end
end

function TabView:GoRight()
    local return_value = ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", true, 11) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local retVal = GetScaleformMovieMethodReturnValueInt(return_value)
    if retVal == -1 then retVal = 0 end
    if retVal ~= -1 then
        if self:FocusLevel() == 0 then
            ScaleformUI.Scaleforms._pauseMenu:HeaderGoRight()
            self.Index = retVal + 1
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                    tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab.PlayersColumn
                        .Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                else
                    tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                end
            else
                ClearPedInPauseMenu()
            end
        elseif self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subT = tab()
            if subT == "PlayerListTab" then
                if tab:Focus() == 0 then
                    if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab
                            .PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                    else
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                    end
                elseif tab:Focus() == 1 then
                    local Item = tab.SettingsColumn.Items[tab.SettingsColumn:CurrentSelection()]
                    if not Item:Enabled() then
                        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        return
                    end

                    local type, subtype = Item()

                    if subtype == "UIMenuListItem" then
                        Item:Index(retVal)
                        Item.OnListChanged(self, Item, Item._Index)
                    elseif subtype == "UIMenuSliderItem" then
                        Item:Index(retVal)
                        Item.OnSliderChanged(self, Item, Item._Index)
                    elseif subtype == "UIMenuProgressItem" then
                        Item:Index(retVal)
                        Item.OnProgressChanged(self, Item, Item:Index())
                    elseif subtype == "UIMenuStatsItem" then
                        Item:Index(retVal)
                        Item.OnStatsChanged(self, Item, Item._Index)
                    end
                end
                return
            end
        elseif self:FocusLevel() == 2 then
            local rightItem = self.Tabs[self.Index].LeftItemList[self.leftItemIndex].ItemList[self.rightItemIndex]
            local sub_item, sub_item_type = rightItem()
            if sub_item_type == "SettingsItem" then
                if rightItem.ItemType == SettingsItemType.ListItem then
                    rightItem:ItemIndex(retVal)
                    rightItem.OnListChanged(rightItem, rightItem:ItemIndex(),
                        tostring(rightItem.ListItems[rightItem:ItemIndex()]))
                elseif rightItem.ItemType == SettingsItemType.SliderBar then
                    rightItem:Value(retVal)
                    rightItem.OnBarChanged(rightItem, rightItem:Value())
                elseif rightItem.ItemType == SettingsItemType.ProgressBar or rightItem.ItemType == SettingsItemType.MaskedProgressBar then
                    rightItem:Value(retVal)
                    rightItem.OnBarChanged(rightItem, rightItem:Value())
                end
            end
        end
    end
end

local successHeader, event_type_h, context_h, item_id_h
local successPause, event_type, context, item_id

function TabView:ProcessMouse()
    if not IsUsingKeyboard(2) then
        return
    end
    SetMouseCursorActiveThisFrame()
    SetInputExclusive(2, 239)
    SetInputExclusive(2, 240)
    SetInputExclusive(2, 237)
    SetInputExclusive(2, 238)

    successHeader, event_type_h, context_h, item_id_h = GetScaleformMovieCursorSelection(ScaleformUI.Scaleforms
        ._pauseMenu._header.handle)
    if successHeader then
        if event_type_h == 5 then
            if context_h == -1 then
                ScaleformUI.Scaleforms._pauseMenu:SelectTab(item_id_h)
                self:FocusLevel(1)
                self.Index = item_id_h + 1
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                local tab = self.Tabs[self.Index]
                local _, subT = tab()
                if subT == "PlayerListTab" then
                    if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab
                            .PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                    else
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                    end
                end
            end
        end
    end

    successPause, event_type, context, item_id = GetScaleformMovieCursorSelection(ScaleformUI.Scaleforms._pauseMenu
        ._pause.handle)
    if successPause then
        local tab = self.Tabs[self.Index]
        local _, subT = tab()
        if event_type == 5 then
            if context == 0 then
                self:FocusLevel(1)
                if subT == "PlayerListTab" then
                    if tab:Focus() == 1 then
                        tab:Focus(0)
                    end
                    tab.PlayersColumn:CurrentSelection(item_id)
                    if tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= nil and tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed ~= 0 then
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu(tab
                            .PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()].ClonePed)
                    else
                        tab.PlayersColumn.Items[tab.PlayersColumn:CurrentSelection()]:AddPedToPauseMenu()
                    end
                else
                    if #tab.LeftItemList == 0 then return end
                    if not tab.LeftItemList[self.leftItemList] then return end
                    while not tab.LeftItemList[self.leftItemList]:Enabled() do
                        Citizen.Wait(0)
                        self.leftItemIndex = self.leftItemIndex + 1
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_LEFT_ITEM_INDEX", false,
                            self.leftItemIndex)
                    end
                end
            elseif context == 1 then
                if subT == "PlayerListTab" then
                    if not tab.SettingsColumn.Items[item_id + 1]:Enabled() then
                        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        return
                    end
                    if tab:Focus() == 0 then
                        tab:Focus(1)
                    end
                    if tab.SettingsColumn.Items[item_id + 1]:Selected() then
                        ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SET_INPUT_EVENT", false, 16)
                        local _item = tab.SettingsColumn.Items[item_id + 1]
                        local _, subtype = _item()
                        if subtype == "UIMenuCheckboxItem" then
                            _item:Checked(not _item:Checked())
                            _item.OnCheckboxChanged(self, _item, _item:Checked())
                        elseif subtype == "UIMenuListItem" then
                            _item.OnListSelected(self, _item, _item._Index)
                        elseif subtype == "UIMenuDynamicListItem" then
                            _item.OnListSelected(self, _item, _item._currentItem)
                        elseif subtype == "UIMenuSliderItem" then
                            _item.OnSliderSelected(self, _item, _item._Index)
                        elseif subtype == "UIMenuProgressItem" then
                            _item.OnProgressSelected(self, _item, _item._Index)
                        elseif subtype == "UIMenuStatsItem" then
                            _item.OnStatsSelected(self, _item, _item._Index)
                        else
                            _item:Activated(self, _item)
                        end
                    end
                    tab.SettingsColumn:CurrentSelection(item_id)
                else
                    if self:FocusLevel() ~= 1 then
                        if not tab.LeftItemList[item_id + 1]:Enabled() then
                            PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            return
                        end
                        tab.LeftItemList[self.leftItemIndex]:Selected(false)
                        self:LeftItemIndex(item_id + 1)
                        tab.LeftItemList[self.leftItemIndex]:Selected(true)
                        self:FocusLevel(1)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    elseif self:FocusLevel() == 1 then
                        if not tab.LeftItemList[item_id + 1]:Enabled() then
                            PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            return
                        end
                        if tab.LeftItemList[self.leftItemIndex].ItemType == LeftItemType.Settings then
                            self:FocusLevel(2)
                            ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_RIGHT_ITEM_INDEX", false, 0)
                            self:RightItemIndex(1)
                        end
                        tab.LeftItemList[self.leftItemIndex]:Selected(false)
                        self:LeftItemIndex(item_id + 1)
                        tab.LeftItemList[self.leftItemIndex]:Selected(true)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                    ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_LEFT_ITEM_INDEX", false, item_id)
                    tab.LeftItemList[self.leftItemIndex].OnActivated(tab.LeftItemList[self.leftItemIndex],
                        self.leftItemIndex)
                    self.OnLeftItemSelect(self, tab.LeftItemList[self.leftItemIndex], self.leftItemIndex)
                end
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            elseif context == 2 then
                local rightItem = tab.LeftItemList[self.leftItemIndex].ItemList[item_id + 1]
                if not rightItem:Enabled() then
                    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    return
                end
                if self:FocusLevel() ~= 2 then
                    self:FocusLevel(2)
                end
                if rightItem:Selected() then
                    if rightItem.ItemType == SettingsItemType.ListItem then
                        rightItem.OnListSelected(rightItem, rightItem:ItemIndex(),
                            tostring(rightItem.ListItems[rightItem:ItemIndex()]))
                    elseif rightItem.ItemType == SettingsItemType.CheckBox then
                        rightItem:Checked(not rightItem:Checked())
                    elseif rightItem.ItemType == SettingsItemType.MaskedProgressBar or rightItem.ItemType == SettingsItemType.ProgressBar then
                        rightItem.OnProgressSelected(rightItem, rightItem:Value())
                    elseif rightItem.ItemType == SettingsItemType.SliderBar then
                        rightItem.OnSliderSelected(rightItem, rightItem:Value())
                    else
                        rightItem.OnActivated(rightItem,
                            IndexOf(tab.LeftItemList[self.leftItemIndex].ItemList, rightItem))
                    end
                    self.OnRightItemSelect(self, rightItem, self.rightItemIndex)
                    return
                end
                tab.LeftItemList[self.leftItemIndex].ItemList[self.rightItemIndex]:Selected(false)
                self:RightItemIndex(item_id + 1)
                ScaleformUI.Scaleforms._pauseMenu._pause:CallFunction("SELECT_RIGHT_ITEM_INDEX", false, item_id)
                tab.LeftItemList[self.leftItemIndex].ItemList[self.rightItemIndex]:Selected(true)
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        elseif event_type == 9 then
            if context == 1 then
                if subT == "PlayerListTab" then
                    tab.SettingsColumn.Items[item_id + 1]:Hovered(true)
                else
                    for i, item in ipairs(tab.LeftItemList) do
                        item:Hovered(item:Enabled() and i == item_id + 1)
                    end
                end
            elseif context == 2 then
                for i, item in ipairs(tab.LeftItemList[self.leftItemIndex].ItemList) do
                    item:Hovered(item:Enabled() and i == item_id + 1)
                end
            end
        elseif event_type == 8 or event_type == 0 then
            if context == 1 then
                if subT == "PlayerListTab" then
                    tab.SettingsColumn.Items[item_id + 1]:Hovered(false)
                end
            end
        end
    end
end

function TabView:ProcessControl()
    if not self:Visible() or self.TemporarilyHidden then
        return
    end
    EnableControlAction(2, 177, true)
    if (IsControlJustPressed(2, 172)) then
        Citizen.CreateThread(function()
            self:GoUp()
        end)
    end
    if (IsControlJustPressed(2, 173)) then
        Citizen.CreateThread(function()
            self:GoDown()
        end)
    end
    if (IsControlJustPressed(2, 174)) then
        Citizen.CreateThread(function()
            self:GoLeft()
        end)
    end
    if (IsControlJustPressed(2, 175)) then
        Citizen.CreateThread(function()
            self:GoRight()
        end)
    end
    if (IsControlJustPressed(2, 205) or (IsUsingKeyboard(2) and IsControlJustPressed(2, 192) and IsControlPressed(2, 21))) then
        Citizen.CreateThread(function()
            if (self:FocusLevel() ~= 0) then
                self:FocusLevel(0)
            end
            self:GoLeft()
        end)
    end
    if (IsControlJustPressed(2, 206) or (IsUsingKeyboard(2) and IsControlJustPressed(2, 192))) then
        Citizen.CreateThread(function()
            if (self:FocusLevel() ~= 0) then
                self:FocusLevel(0)
            end
            self:GoRight()
        end)
    end
    if (IsControlJustPressed(2, 201)) then
        Citizen.CreateThread(function()
            self:Select()
        end)
    end
    if (IsControlJustReleased(2, 177)) then
        Citizen.CreateThread(function()
            self:GoBack()
        end)
    end

    if (IsControlJustPressed(2, 241) or IsDisabledControlJustPressed(2, 241)) then
        Citizen.CreateThread(function()
            ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(-1)
        end)
    end
    if (IsControlJustPressed(2, 242) or IsDisabledControlJustPressed(2, 242)) then
        Citizen.CreateThread(function()
            ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(1)
        end)
    end


    if (IsControlPressed(2, 3) and not IsUsingKeyboard(2)) then
        if (GlobalGameTimer - self._timer > 175) then
            Citizen.CreateThread(function()
                ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(-1)
            end)
            self._timer = GlobalGameTimer
        end
    end
    if (IsControlPressed(2, 4) and not IsUsingKeyboard(2)) then
        if (GlobalGameTimer - self._timer > 175) then
            Citizen.CreateThread(function()
                ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(1)
            end)
            self._timer = GlobalGameTimer
        end
    end
end
BigFeedInstance = setmetatable({}, BigFeedInstance)
BigFeedInstance.__index = BigFeedInstance
BigFeedInstance.__call = function()
    return "BigFeedInstance"
end

---@class BigFeedInstance
---@field public _sc scaleformUV
---@field private _title string
---@field private _subtitle string
---@field private _bodyText string
---@field private _txn string
---@field private _txd string
---@field public _enabled boolean
---@field private _rightAligned boolean
---@field private _disabledNotifications boolean
---@field public Title fun(self:BigFeedInstance, title:string):string
---@field public Subtitle fun(self:BigFeedInstance, subtitle:string):string
---@field public BodyText fun(self:BigFeedInstance, body:string):string
---@field public Texture fun(self:BigFeedInstance, textureName:string, textureDictionary:string):table<string, string>
---@field public Enabled fun(self:BigFeedInstance, enabled:boolean):boolean
---@field public UpdateInfo fun(self:BigFeedInstance):nil
---@field public Update fun(self:BigFeedInstance):nil
---@field public Load fun(self:BigFeedInstance):nil
---@field public Dispose fun(self:BigFeedInstance):nil

---Create a new BigFeedInstance
---@return BigFeedInstance
function BigFeedInstance.New()
    local data = {
        _sc = nil --[[@type scaleformUV]],
        _title = "",
        _subtitle = "",
        _bodyText = "",
        _txn = "",
        _txd = "",
        _enabled = false,
        _rightAligned = false,
        _disabledNotifications = false,
    }
    return setmetatable(data, BigFeedInstance)
end

---Sets the title of the BigFeedInstance, if no title is provided it will return the current title
---@param title? string
---@return string
function BigFeedInstance:Title(title)
    if title == nil then return self._title end
    self._title = tostring(title)
    if self._enabled then
        self:UpdateInfo()
    end

    return self._title
end

---Sets the subtitle of the BigFeedInstance, if no subtitle is provided it will return the current subtitle
---@param subtitle? string
---@return string
function BigFeedInstance:Subtitle(subtitle)
    if subtitle == nil then return self._subtitle end
    self._subtitle = tostring(subtitle)
    if self._enabled then
        self:UpdateInfo()
    end
    return self._subtitle
end

---Sets the body text of the BigFeedInstance, if no body text is provided it will return the current body text
---@param body? string
---@return string
function BigFeedInstance:BodyText(body)
    if body == nil then return self._bodyText end
    self._bodyText = tostring(body)
    if self._enabled then
        self:UpdateInfo()
    end
    return self._bodyText
end

---Sets the BigFeedInstance to be right aligned, if no state is provided it will return the current state
---@param rightAligned? boolean
---@return boolean
function BigFeedInstance:RightAligned(rightAligned)
    if rightAligned == nil then return self._rightAligned end
    self._rightAligned = ToBool(rightAligned)
    if self._enabled then
        self._sc:CallFunction("SETUP_BIGFEED", false, self._rightAligned)
        self:UpdateInfo()
    end
    return self._rightAligned
end

---Sets the texture of the BigFeedInstance, if no texture is provided it will return the current texture
---@param textureName? string
---@param textureDictionary? string
---@return table<string, string>
function BigFeedInstance:Texture(textureName, textureDictionary)
    if textureName == nil and textureDictionary == nil then return { txd = self._txd, txn = self._txn } end
    self._txn = textureName
    self._txd = textureDictionary
    if self._enabled then
        self._sc:CallFunction("SET_BIGFEED_IMAGE", false, textureDictionary, textureName)
        self:UpdateInfo()
    end
    return { txd = self._txd, txn = self._txn }
end

---Toggles the BigFeedInstance on or off, if a state is not provided it will return the current enabled state
---@param enabled? boolean
---@return boolean
function BigFeedInstance:Enabled(enabled)
    if enabled == nil then return self._enabled end
    self._enabled = ToBool(enabled)
    if enabled == true then
        self._sc:CallFunction("SETUP_BIGFEED", false, self._rightAligned)
        self._sc:CallFunction("HIDE_ONLINE_LOGO", false)
        self._sc:CallFunction("FADE_IN_BIGFEED", false)
        if self:DisabledNotifications() then
            ThefeedCommentTeleportPoolOn()
        end
        self:UpdateInfo()
    else
        self._sc:CallFunction("END_BIGFEED", false)
        if self:DisabledNotifications() then
            ThefeedCommentTeleportPoolOff()
        end
    end
    return self._enabled
end

---Updates the information displayed on the BigFeedInstance
---@return nil
function BigFeedInstance:UpdateInfo()
    if not self._enabled then return end
    AddTextEntry("scaleform_ui_bigFeed", self._bodyText)
    BeginScaleformMovieMethod(self._sc.handle, "SET_BIGFEED_INFO")
    ScaleformMovieMethodAddParamTextureNameString("")
    BeginTextCommandScaleformString("scaleform_ui_bigFeed")
    EndTextCommandScaleformString_2()
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamTextureNameString(self._txn)
    ScaleformMovieMethodAddParamTextureNameString(self._txd)
    ScaleformMovieMethodAddParamTextureNameString(self._subtitle)
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString(self._title)
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
end

---Draws the BigFeedInstance on the screen
---@return nil
function BigFeedInstance:Update()
    self._sc:Render2D()
end

---Loads the BigFeedInstance scaleform
---@return nil
function BigFeedInstance:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("GTAV_ONLINE")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
    self._sc:CallFunction("HIDE_ONLINE_LOGO", false)
end

---Disposes the BigFeedInstance scaleform
function BigFeedInstance:Dispose()
    self._sc:Dispose()
    self._sc = nil
end
BigMessageInstance = setmetatable({}, BigMessageInstance)
BigMessageInstance.__index = BigMessageInstance
BigMessageInstance.__call = function()
    return "BigMessageInstance"
end

---@class BigMessageInstance
---@field public _sc scaleformUV
---@field private _start number
---@field private _duration number
---@field private _transition string -- TRANSITION_UP, TRANSITION_OUT, TRANSITION_DOWN supported
---@field private _transitionDuration number -- default: 0.4
---@field private _transitionPreventAutoExpansion boolean -- default: false
---@field private _transitionExecuted boolean -- default: false
---@field public New fun():BigMessageInstance
---@field public Load fun():nil
---@field public Dispose fun(self:BigMessageInstance, force:boolean):nil
---@field public ShowMissionPassedMessage fun(self:BigMessageInstance, msg:string, duration:number, manualDispose?:boolean):nil
---@field public ShowColoredShard fun(self:BigMessageInstance, msg:string, desc:string, textColor:number, bgColor:number, duration:number, manualDispose?:boolean):nil
---@field public ShowOldMessage fun(self:BigMessageInstance, msg:string, duration:number, manualDispose?:boolean):nil
---@field public ShowSimpleShard fun(self:BigMessageInstance, msg:string, subtitle:string, duration:number, manualDispose?:boolean):nil
---@field public ShowRankupMessage fun(self:BigMessageInstance, msg:string, subtitle:string, rank:number, duration:number, manualDispose?:boolean):nil
---@field public ShowWeaponPurchasedMessage fun(self:BigMessageInstance, bigMessage:string, weaponName:string, weaponHash:number, duration:number, manualDispose?:boolean):nil
---@field public ShowMpMessageLarge fun(self:BigMessageInstance, msg:string, duration:number, manualDispose?:boolean):nil
---@field public ShowMpWastedMessage fun(self:BigMessageInstance, msg:string, subtitle:string, duration:number, manualDispose?:boolean):nil
---@field public SetTransition fun(self:BigMessageInstance, transition:string, duration:number, preventAutoExpansion:boolean):nil
---@field public Update fun(self:BigMessageInstance):nil

--[[
    SHOW_MISSION_PASSED_MESSAGE - TRANSITION_OUT,
    SHOW_SHARD_CENTERED_MP_MESSAGE - TRANSITION_OUT,
    SHOW_MISSION_PASSED_MESSAGE - TRANSITION_OUT,
    SHOW_SHARD_CREW_RANKUP_MP_MESSAGE - TRANSITION_OUT,
    SHOW_BIG_MP_MESSAGE - TRANSITION_OUT,
    SHOW_WEAPON_PURCHASED - TRANSITION_OUT,
    SHOW_CENTERED_MP_MESSAGE_LARGE - TRANSITION_OUT,
    SHOW_SHARD_WASTED_MP_MESSAGE - TRANSITION_OUT,
]]
---Creates a new BigMessageInstance
---@return BigMessageInstance
function BigMessageInstance.New()
    local data = {
        _sc = nil --[[@type scaleformUV]],
        _start = 0,
        _duration = 0,
        _transition = "TRANSITION_OUT", -- TRANSITION_UP, TRANSITION_OUT, TRANSITION_DOWN supported
        _transitionDuration = 0.15,
        _transitionPreventAutoExpansion = false,
        _transitionExecuted = false,
        _manualDispose = false
    }
    return setmetatable(data, BigMessageInstance)
end

---Loads the MP_BIG_MESSAGE_FREEMODE scaleform
---@return nil
function BigMessageInstance:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("MP_BIG_MESSAGE_FREEMODE")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
end

---Disposes the scaleform
function BigMessageInstance:Dispose()
    if self._sc == nil then return end

    if self._manualDispose then
        self._sc:CallFunction(self._transition, false, self._transitionDuration, self
            ._transitionPreventAutoExpansion)

        Wait(((self._transitionDuration * .5) * 1000))

        self._manualDispose = false
        -- Wait for the transition to finish
    end

    self._start = 0
    self._transitionExecuted = false
    self._sc:Dispose()
    self._sc = nil
end

---Runs the SHOW_MISSION_PASSED_MESSAGE method on the scaleform
---@param msg string
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowMissionPassedMessage(msg, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_MISSION_PASSED_MESSAGE", false, msg, "", 100, true, 0, true)
    self._duration = duration
end

---Runs the SHOW_SHARD_CENTERED_MP_MESSAGE message on the scaleform
---@param msg string
---@param desc string
---@param textColor Colours
---@param bgColor Colours
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowColoredShard(msg, desc, textColor, bgColor, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_SHARD_CENTERED_MP_MESSAGE", false, msg, desc, bgColor, textColor)
    self._duration = duration
end

---Runs the SHOW_MISSION_PASSED_MESSAGE method on the scaleform
---@param msg string
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowOldMessage(msg, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_MISSION_PASSED_MESSAGE", false, msg)
    self._duration = duration
end

---Runs the SHOW_SHARD_CREW_RANKUP_MP_MESSAGE method on the scaleform
---@param msg string
---@param subtitle string
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowSimpleShard(msg, subtitle, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_SHARD_CREW_RANKUP_MP_MESSAGE", false, msg, subtitle)
    self._duration = duration
end

---Runs the SHOW_BIG_MP_MESSAGE method on the scaleform
---@param msg string
---@param subtitle string
---@param rank number
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowRankupMessage(msg, subtitle, rank, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_BIG_MP_MESSAGE", false, msg, subtitle, rank, "", "")
    self._duration = duration
end

---Runs the SHOW_WEAPON_PURCHASED method on the scaleform
---@param bigMessage string
---@param weaponName string
---@param weaponHash number
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowWeaponPurchasedMessage(bigMessage, weaponName, weaponHash, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_WEAPON_PURCHASED", false, bigMessage, weaponName, weaponHash, "", 100)
    self._duration = duration
end

---Runs the SHOW_CENTERED_MP_MESSAGE_LARGE method on the scaleform
---@param msg string
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowMpMessageLarge(msg, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_CENTERED_MP_MESSAGE_LARGE", false, msg, "", 100, true, 100)
    self._sc:CallFunction("TRANSITION_IN", false)
    self._duration = duration
end

---Runs the SHOW_SHARD_WASTED_MP_MESSAGE method on the scaleform
---@param msg string
---@param subtitle string
---@param duration number
---@param manualDispose? boolean
---@return nil
function BigMessageInstance:ShowMpWastedMessage(msg, subtitle, duration, manualDispose)
    if duration == nil then duration = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._manualDispose = manualDispose or false
    self._sc:CallFunction("SHOW_SHARD_WASTED_MP_MESSAGE", false, msg, subtitle)
    self._duration = duration
end

---Sets the transition and duration for the scaleform when it is disposed
---@param transition string -- TRANSITION_UP, TRANSITION_OUT, TRANSITION_DOWN supported
---@param duration number? -- default 0.4
---@param preventAutoExpansion boolean? -- default true
---@return nil
function BigMessageInstance:SetTransition(transition, duration, preventAutoExpansion)
    if transition == nil then transition = "TRANSITION_OUT" end

    if transition ~= "TRANSITION_UP" and transition ~= "TRANSITION_OUT" and transition ~= "TRANSITION_DOWN" then
        transition = "TRANSITION_OUT"
    end

    self._transition = transition

    if duration == nil then duration = 0.4 end
    self._transitionDuration = duration + .0

    if preventAutoExpansion == nil then preventAutoExpansion = true end
    self._transitionPreventAutoExpansion = preventAutoExpansion
end

---Renders the scaleform and checks if the timer has expired, if so it will dispose the scaleform
---@return nil
function BigMessageInstance:Update()
    self._sc:Render2D()

    -- if the user wants to manually dispose the scaleform, don't do it automatically
    if self._manualDispose then return end

    if self._start ~= 0 and (GlobalGameTimer - self._start) > self._duration then
        if not self._transitionExecuted then
            self._sc:CallFunction(self._transition, false, self._transitionDuration, self
                ._transitionPreventAutoExpansion)
            self._transitionExecuted = true
            -- add the transition duration to the scaleform duration so the message is displayed for the full duration of the transition
            self._duration = self._duration + ((self._transitionDuration * .5) * 1000)
        else
            self:Dispose()
        end
    end
end
CountdownHandler = setmetatable({}, CountdownHandler)
CountdownHandler.__index = CountdownHandler
CountdownHandler.__call = function()
    return "CountdownHandler"
end

---@class CountdownHandler
---@field public _sc scaleformUV
---@field private _start number
---@field private _timer number
---@field private _colour {r:number, g:number, b:number, a:number}
---@field public New fun():CountdownHandler
---@field public Load fun(self:CountdownHandler):promise
---@field public Dispose fun(self:CountdownHandler, force:boolean):nil
---@field public Update fun(self:CountdownHandler):nil
---@field public ShowMessage fun(self:CountdownHandler, message:string):nil
---@field public Start fun(self:CountdownHandler, number:number?, hudColour:number?, countdownAudioName:string?, countdownAudioRef:string?, goAudioName:string?, goAudioRef:string?):promise

---Creates a new CountdownHandler
---@return CountdownHandler
function CountdownHandler.New()
    local data = {
        _sc = nil --[[@type scaleformUV]],
        _start = 0,
        _timer = 0,
        _colour = { r = 255, g = 255, b = 255, a = 255 }
    }
    return setmetatable(data, CountdownHandler)
end

---Loads the COUNTDOWN scaleform
---@return promise
function CountdownHandler:Load()
    local p = promise.new()

    if self._sc ~= nil then
        p:resolve()
        return p
    end

    RequestScriptAudioBank("HUD_321_GO", false);

    self._sc = scaleformUV.Request("COUNTDOWN")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end

    if self._sc:IsLoaded() then
        p:resolve()
    else
        p:reject()
    end

    return p
end

---Dispose the COUNTDOWN scaleform
function CountdownHandler:Dispose()
    self._sc:Dispose()
    self._sc = nil
end

---Update is called every frame to render the COUNTDOWN scaleform to the screen by mainScaleform.lua
function CountdownHandler:Update()
    self._sc:Render2D()
end

---Show a message on the COUNTDOWN scaleform
---@param message string
function CountdownHandler:ShowMessage(message)
    self._sc:CallFunction("SET_MESSAGE", false, message, self._colour.r, self._colour.g, self._colour.b, true);
    self._sc:CallFunction("FADE_MP", false, message, self._colour.r, self._colour.g, self._colour.b);
end

---Starts the countdown
---@param number number? - The number to start the countdown from
---@param hudColour number? - The hud colour to use for the countdown
---@param countdownAudioName string? - The audio name to play for each number
---@param countdownAudioRef string? - The audio ref to play for each number
---@param goAudioName string? - The audio name to play when the countdown is finished
---@param goAudioRef string? - The audio ref to play when the countdown is finished
---@return promise
function CountdownHandler:Start(number, hudColour, countdownAudioName, countdownAudioRef, goAudioName, goAudioRef)
    local p = promise.new()

    if number == nil then number = 3 end
    if hudColour == nil then hudColour = 18 end
    if countdownAudioName == nil then countdownAudioName = "321" end
    if countdownAudioRef == nil then countdownAudioRef = "Car_Club_Races_Pursuit_Series_Sounds" end
    if goAudioName == nil then goAudioName = "Go" end
    if goAudioRef == nil then goAudioRef = "Car_Club_Races_Pursuit_Series_Sounds" end

    self:Load():next(function()
        self._colour.r, self._colour.g, self._colour.b, self._colour.a = GetHudColour(hudColour)

        local gameTime = GlobalGameTimer

        while number >= 0 do
            Wait(0)

            if GlobalGameTimer - gameTime > 1000 then
                PlaySoundFrontend(-1, countdownAudioName, countdownAudioRef, true);
                self:ShowMessage(string.format(number))
                number = number - 1
                gameTime = GlobalGameTimer
            end
        end

        PlaySoundFrontend(-1, goAudioName, goAudioRef, true);
        self:ShowMessage("CNTDWN_GO")
        p:resolve()

        if GlobalGameTimer - gameTime > 1000 then
            self:Dispose()
        end
    end, function()
        error("Failed to load countdown scaleform")
        p:reject()
    end)

    return p
end
ButtonsHandler = setmetatable({}, ButtonsHandler)
ButtonsHandler.__index = ButtonsHandler
ButtonsHandler.__call = function()
    return "ButtonsHandler"
end

---@class ButtonsHandler
---@field public _sc scaleformUV
---@field public UseMouseButtons boolean
---@field public _enabled boolean
---@field public IsUsingKeyboard boolean
---@field private _changed boolean
---@field private savingTimer number
---@field public IsSaving boolean
---@field public ControlButtons table<string, InstructionalButton>
---@field public Enabled fun(self: table, bool: boolean?): boolean

function ButtonsHandler.New()
    local data = {
        _sc = nil --[[@type scaleformUV]],
        UseMouseButtons = false,
        _enabled = false,
        IsUsingKeyboard = false,
        _changed = true,
        savingTimer = 0,
        IsSaving = false,
        ControlButtons = {}
    }
    return setmetatable(data, ButtonsHandler)
end

---Enables or disables the instructional buttons
---@param bool boolean?
---@return boolean
function ButtonsHandler:Enabled(bool)
    if bool ~= nil then
        if not bool and self._sc ~= nil then
            self._sc:CallFunction("CLEAR_ALL", false)
            self._sc:CallFunction("CLEAR_RENDER", false)
            self._sc:Dispose()
            self._sc = nil
        end
        self._enabled = bool
        self._changed = bool
    end
    return self._enabled
end

---Loads the instructional buttons
function ButtonsHandler:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("INSTRUCTIONAL_BUTTONS")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
end

---Sets the instructional buttons
---@param buttons table<InstructionalButton>
function ButtonsHandler:SetInstructionalButtons(buttons)
    self.ControlButtons = buttons
    self._changed = true
end

---Adds a new instructional button
---@param button InstructionalButton
function ButtonsHandler:AddInstructionalButton(button)
    self.ControlButtons[#self.ControlButtons + 1] = button
    self._changed = true
end

---Removes an instructional button
---@param button InstructionalButton
function ButtonsHandler:RemoveInstructionalButton(button)
    local bt
    for k, v in pairs(self.ControlButtons) do
        if v.Text == button.Text then
            self.ControlButtons[k] = nil
        end
    end
    self._changed = true
end

---Removes all instructional buttons
function ButtonsHandler:ClearButtonList()
    self.ControlButtons = {}
    self._changed = true
end

---Shows a busy spinner
---@param spinnerType number
---@param text string
---@param time number
function ButtonsHandler:ShowBusySpinner(spinnerType, text, time, manualDispose)
    if time == nil or time < 0 then time = 3000 end
    self.IsSaving = true
    self._changed = true
    self._manualDispose = manualDispose or false
    self.savingTimer = GlobalGameTimer

    if text == nil or text == "" then
        BeginTextCommandBusyspinnerOn("PM_WAIT")
    else
        BeginTextCommandBusyspinnerOn("STRING")
        AddTextComponentSubstringPlayerName(text)
    end
    EndTextCommandBusyspinnerOn(spinnerType)
    if self._manualDispose then return end
    while GlobalGameTimer - self.savingTimer <= time do Citizen.Wait(100) end
    BusyspinnerOff()
    self.IsSaving = false
end

---Hide Busy Spinner
function ButtonsHandler:HideBusySpinner()
    BusyspinnerOff()
    self.IsSaving = false
end

---Updates the instructional buttons
function ButtonsHandler:UpdateButtons()
    if not self._changed then return end
    if self._sc == nil then return end

    self._sc:CallFunction("SET_DATA_SLOT_EMPTY", false)
    self._sc:CallFunction("TOGGLE_MOUSE_BUTTONS", false, self.UseMouseButtons)
    local count = 0

    for k, button in pairs(self.ControlButtons) do
        if button:IsUsingController() then
            if button.PadCheck == 0 or button.PadCheck == -1 then
                if ScaleformUI.Scaleforms.Warning:IsShowing() then
                    self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 0, -1)
                else
                    self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text)
                end
            end
        else
            if button.PadCheck == 1 or button.PadCheck == -1 then
                if self.UseMouseButtons then
                    self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 1,
                        button.KeyboardButton)
                else
                    if ScaleformUI.Scaleforms.Warning:IsShowing() then
                        self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 0,
                            -1)
                    else
                        self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text)
                    end
                end
            end
        end
        count = count + 1
    end
    self._sc:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS", false, -1)
    self._changed = false
end

---Draws the instructional buttons on the screen
function ButtonsHandler:Draw()
    SetScriptGfxDrawBehindPausemenu(true)
    self._sc:Render2D()
end

---Draws the instructional buttons on the screen with a custom position
function ButtonsHandler:DrawScreenSpace(x, y)
    self._sc:Render2DNormal(0.5 - x, 0.5 - y, 1, 1)
end

---Draws the instructional buttons on the screen with a custom position
---@deprecated Use DrawScreenSpace() instead
function ButtonsHandler:DrawScreeSpace(x, y)
    self._sc:Render2DNormal(0.5 - x, 0.5 - y, 1, 1)
end

---Update tick for the instructional buttons
function ButtonsHandler:Update()
    if IsUsingKeyboard(2) then
        if not self.IsUsingKeyboard then
            self.IsUsingKeyboard = true
            self._changed = true
        end
    else
        if self.IsUsingKeyboard then
            self.IsUsingKeyboard = false
            self._changed = true
        end
    end
    self:UpdateButtons()
    if not ScaleformUI.Scaleforms.Warning:IsShowing() then self:Draw() end
    if self.UseMouseButtons then SetMouseCursorActiveThisFrame() end
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(9)
end
InstructionalButton = setmetatable({}, InstructionalButton)
InstructionalButton.__index = InstructionalButton
InstructionalButton.__call = function()
    return "InstructionalButton"
end

---@class InstructionalButton
---@field public Text string
---@field public GamepadButtons number[]
---@field public GamepadButton number
---@field public KeyboardButtons number[]
---@field public KeyboardButton number
---@field public PadCheck number

---Creates a new InstructionalButton object
---@param text string
---@param padcheck number?
---@param gamepadControls number
---@param keyboardControls number
---@param inputGroup string|number?
---@return table
function InstructionalButton.New(text, padcheck, gamepadControls, keyboardControls, inputGroup)
    local _instructionalButton = {
        Text = text or "",
        GamepadButtons = nil,
        GamepadButton = -1,
        KeyboardButtons = nil,
        KeyboardButton = -1,
        PadCheck = padcheck or -1
    }

    if type(gamepadControls) == "table" then
        if padcheck == 0 or padcheck == -1 then
            _instructionalButton.GamepadButtons = gamepadControls
        end
    else
        if padcheck == 0 or padcheck == -1 then
            _instructionalButton.GamepadButton = gamepadControls
        else
            _instructionalButton.GamepadButton = -1
        end
    end
    if type(keyboardControls) == "table" then
        if padcheck == 1 or padcheck == -1 then
            _instructionalButton.KeyboardButtons = keyboardControls
        end
    else
        if padcheck == 1 or padcheck == -1 then
            _instructionalButton.KeyboardButton = keyboardControls
        else
            _instructionalButton.KeyboardButton = -1
        end
    end
    _instructionalButton.InputGroupButton = inputGroup or -1

    return setmetatable(_instructionalButton, InstructionalButton)
end

---Checks if the player is using a controller
---@return boolean
function InstructionalButton:IsUsingController()
    return not IsUsingKeyboard(2)
end

---Gets the button id for the instructional button
function InstructionalButton:GetButtonId()
    if self.KeyboardButtons ~= nil or self.GamepadButtons ~= nil then
        local retVal = ""
        if self:IsUsingController() then
            if self.GamepadButtons ~= nil then
                for i = #self.GamepadButtons, 1, -1 do
                    if i == 1 then
                        retVal = retVal .. GetControlInstructionalButton(2, self.GamepadButtons[i], true)
                    else
                        retVal = retVal .. GetControlInstructionalButton(2, self.GamepadButtons[i], true) .. "%"
                    end
                end
            end
        else
            if self.KeyboardButtons ~= nil then
                for i = #self.KeyboardButtons, 1, -1 do
                    if i == 1 then
                        retVal = retVal .. GetControlInstructionalButton(2, self.KeyboardButtons[i], true)
                    else
                        retVal = retVal .. GetControlInstructionalButton(2, self.KeyboardButtons[i], true) .. "%"
                    end
                end
            end
        end
        return retVal
    elseif self.InputGroupButton ~= -1 then
        return "~" .. self.InputGroupButton .. "~"
    end
    if self:IsUsingController() then
        return GetControlInstructionalButton(2, self.GamepadButton, true)
    else
        return GetControlInstructionalButton(2, self.KeyboardButton, true)
    end
end
MidMessageInstance = setmetatable({}, MidMessageInstance)
MidMessageInstance.__index = MidMessageInstance
MidMessageInstance.__call = function()
    return "MidMessageInstance"
end

---@class MidMessageInstance
---@field public _sc scaleformUV
---@field public _start number
---@field public _timer number
---@field public _hasAnimatedOut boolean
---@field public New fun():MidMessageInstance
---@field public Load fun(self:MidMessageInstance):nil
---@field public Dispose fun(self:MidMessageInstance, force:boolean):nil
---@field public Update fun(self:MidMessageInstance):nil

---Creates a new MidMessageInstance object
---@return MidMessageInstance
function MidMessageInstance.New()
    local _sc = nil --[[@type scaleformUV]]
    local _start = 0
    local _timer = 0
    local _hasAnimatedOut = false
    local data = { _sc = _sc, _start = _start, _timer = _timer, _hasAnimatedOut = _hasAnimatedOut }
    return setmetatable(data, MidMessageInstance)
end

---Loads the MIDSIZED_MESSAGE scaleform
function MidMessageInstance:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("MIDSIZED_MESSAGE")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
end

---Dispose the MIDSIZED_MESSAGE scaleform
function MidMessageInstance:Dispose()
    self._sc:Dispose()
    self._sc = nil
end

---Shows a message on the screen
---@param msg string
---@param desc string
---@param bgColor Colours
---@param useDarkerShard boolean
---@param useCondensedShard boolean
---@param time number? - The time in milliseconds the message should be shown for (default: 5000)
function MidMessageInstance:ShowColoredShard(msg, desc, bgColor, useDarkerShard, useCondensedShard, time)
    if time == nil then time = 5000 end
    self:Load()
    self._start = GlobalGameTimer
    self._sc:CallFunction("SHOW_SHARD_MIDSIZED_MESSAGE", false, msg, desc, bgColor, useDarkerShard, useCondensedShard)
    self._timer = time
    self._hasAnimatedOut = false
end

---Shows a message on the screen
function MidMessageInstance:Update()
    self._sc:Render2D()
    if self._start ~= 0 and GlobalGameTimer - self._start > self._timer then
        if not self._hasAnimatedOut then
            self._sc:CallFunction("SHARD_ANIM_OUT", false, 21, 750)
            self._hasAnimatedOut = true
            self._timer = self._timer + 750
        else
            PlaySoundFrontend(-1, "Shard_Disappear", "GTAO_FM_Events_Soundset", true)
            self._start = 0
            self:Dispose()
        end
    end
end
JobSelectionButton = setmetatable({}, JobSelectionButton)
JobSelectionButton.__index = JobSelectionButton
JobSelectionButton.__call = function()
    return "JobSelectionButton"
end

---@class JobSelectionButton
---@field public Text string
---@field public Description string
---@field public Details table<MissionDetailsItem>
---@field public OnButtonPressed fun(self: JobSelectionButton)

---Creates a new JobSelectionButton object
---@param title string
---@param description string
---@param details table<MissionDetailsItem>
---@return JobSelectionButton
function JobSelectionButton.New(title, description, details)
    local data = {
        Text = title,
        Description = description,
        Details = details,
        OnButtonPressed = function()
        end
    }
    return setmetatable(data, JobSelectionButton)
end
JobSelectionCard = setmetatable({}, JobSelectionCard)
JobSelectionCard.__index = JobSelectionCard
JobSelectionCard.__call = function()
    return "JobSelectionCard"
end

---@class JobSelectionCard
---@field public Title string
---@field public Description string
---@field public Txd string
---@field public Txn string
---@field public RpMultiplier number
---@field public CashMultiplier number
---@field public Icon JobSelectionCardIcon
---@field public IconColor Colours
---@field public ApMultiplier number
---@field public Details table<MissionDetailsItem>

---Creates a new JobSelectionCard object
---@param title string
---@param description string
---@param txd string
---@param txn string
---@param rpMult number
---@param cashMult number
---@param icon JobSelectionCardIcon
---@param iconColor Colours
---@param apMultiplier number
---@param details table<MissionDetailsItem>
---@return JobSelectionCard
function JobSelectionCard.New(title, description, txd, txn, rpMult, cashMult, icon, iconColor, apMultiplier, details)
    local data = {
        Title = title,
        Description = description,
        Txd = txd,
        Txn = txn,
        RpMultiplier = rpMult,
        CashMultiplier = cashMult,
        Icon = icon,
        IconColor = iconColor,
        ApMultiplier = apMultiplier,
        Details = details
    }
    return setmetatable(data, JobSelectionCard)
end
MissionDetailsItem = setmetatable({}, MissionDetailsItem)
MissionDetailsItem.__index = MissionDetailsItem
MissionDetailsItem.__call = function()
    return "MissionDetailsItem"
end

---@class MissionDetailsItem
---@field public Type number
---@field public TextLeft string
---@field public TextRight string
---@field public Icon JobIcon
---@field public IconColor Colours
---@field public Tick boolean

---Creates a new MissionDetailsItem object
---@param textLeft string
---@param textRight string
---@param seperator boolean
---@param icon JobIcon
---@param iconColor Colours
---@param tick boolean
---@return MissionDetailsItem
function MissionDetailsItem.New(textLeft, textRight, seperator, icon, iconColor, tick)
    local _type
    if seperator == true then
        _type = 4
    elseif icon ~= nil and iconColor ~= nil then
        _type = 2
    else
        _type = 0
    end
    _MissionDetailsItem = {
        Type = _type,
        TextLeft = textLeft,
        TextRight = textRight,
        Icon = icon,
        IconColor = iconColor,
        Tick = tick or false
    }
    return setmetatable(_MissionDetailsItem, MissionDetailsItem)
end
MissionSelectorHandler = setmetatable({}, MissionSelectorHandler)
MissionSelectorHandler.__index = MissionSelectorHandler
MissionSelectorHandler.__call = function()
    return "MissionSelectorHandler"
end

---@class MissionSelectorHandler
---@field public _sc scaleformUV
---@field public _start number
---@field public _timer number
---@field public enabled boolean
---@field public alreadyVoted boolean
---@field public Votes table<number, number>
---@field public VotedFor number
---@field public MaxVotes number
---@field public SelectedCard number
---@field public VotesColor number
---@field public JobTitle table<string, string>
---@field public Cards table<number, JobSelectionCard>
---@field public Buttons table<number, JobSelectionButton>
---@field public SetTitle fun(self:MissionSelectorHandler, title:string):nil
---@field public SetVotes fun(self:MissionSelectorHandler, actual:number, label:string):nil
---@field public AddCard fun(self:MissionSelectorHandler, card:JobSelectionCard):nil
---@field public AddButton fun(self:MissionSelectorHandler, button:JobSelectionButton):nil
---@field public Enabled fun(self:MissionSelectorHandler, bool:boolean?):boolean
---@field public AlreadyVoted fun(self:MissionSelectorHandler):boolean
---@field public BuildMenu fun(self:MissionSelectorHandler):nil
---@field public Dispose fun(self:MissionSelectorHandler):nil
---@field public SelectCard fun(self:MissionSelectorHandler, card:number):nil
---@field public UpdateOwnVote fun(self:MissionSelectorHandler, card:number, oldCard:number, showCheckmark:boolean, flashBackground:boolean):nil
---@field public ShowPlayerVote fun(self:MissionSelectorHandler, card:number, playerName:string, colour:Colours, showCheckmark:boolean, flashBackground:boolean):nil
---@field public Load fun(self:MissionSelectorHandler):nil
---@field public Update fun(self:MissionSelectorHandler):nil

---Creates a new MissionSelectorHandler object
---@return MissionSelectorHandler
function MissionSelectorHandler.New()
    local data = {
        _sc = nil,
        _start = 0,
        _timer = 0,
        enabled = false,
        alreadyVoted = false,
        Votes = { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        VotedFor = -1,
        MaxVotes = 0,
        SelectedCard = 1,
        VotesColor = Colours.HUD_COLOUR_BLUE,
        JobTitle = {
            Title = "",
            Label = "",
            Votes = "",
        },
        Cards = {},
        Buttons = {},
    }
    return setmetatable(data, MissionSelectorHandler)
end

---Sets the title of the mission selector
---@param title string
function MissionSelectorHandler:SetTitle(title)
    self.JobTitle.Title = title
end

---Sets the votes of the mission selector
---@param actual number
---@param label string?
function MissionSelectorHandler:SetVotes(actual, label)
    local tot = actual .. " / " .. self.MaxVotes
    if not string.IsNullOrEmpty(label or "") then
        self.JobTitle.Label = label
    end
    self.JobTitle.Votes = tot .. " " .. self.JobTitle.Label
end

---Adds a card to the mission selector grid menu (max 9)
---@param card JobSelectionCard
function MissionSelectorHandler:AddCard(card)
    if #self.Cards < 9 then
        self.Cards[#self.Cards + 1] = card
    end
end

---Adds a button to the mission selector grid menu (max 3)
---@param button JobSelectionButton
function MissionSelectorHandler:AddButton(button)
    if #self.Buttons < 3 then
        self.Buttons[#self.Buttons + 1] = button
    end
end

---Toggles the mission selector on or off
---@param bool boolean?
function MissionSelectorHandler:Enabled(bool)
    if bool ~= nil then
        if bool then
            self:BuildMenu()
        else
            self:Dispose()
        end
        self.enabled = bool
    end
    return self.enabled
end

---Returns true if the player has already voted
function MissionSelectorHandler:AlreadyVoted()
    return self.alreadyVoted
end

---Disposes the mission selector
function MissionSelectorHandler:Dispose()
    self._sc:Dispose()
    self._sc = nil
end

---Builds the mission selector menu
function MissionSelectorHandler:BuildMenu()
    self:Load()
    while self._sc == nil or not self._sc:IsLoaded() do Citizen.Wait(0) end
    self:_SetTitle(self.JobTitle.Title, self.JobTitle.Votes)
    for i, card in ipairs(self.Cards) do
        if not string.IsNullOrEmpty(card.Txd) then
            while not HasStreamedTextureDictLoaded(card.Txd) do
                Citizen.Wait(0)
                RequestStreamedTextureDict(card.Txd, true)
            end
        end
        self:SetGridItem(i - 1, card.Title, card.Txd, card.Txn, 1, 0, card.Icon, false, card.RpMultiplier,
            card.CashMultiplier, false, card.IconColor, card.ApMultiplier)
        SetStreamedTextureDictAsNoLongerNeeded(card.Txd)
    end

    for i, button in ipairs(self.Buttons) do
        self:SetButtonItem(i - 1, button.Text)
    end
    self:SetSelection(0, self.Cards[1].Title, self.Cards[1].Description)
    for i, detail in ipairs(self.Cards[1].Details) do
        self:SetDetailsItem(i - 1, 0, i - 1, detail.Type, 0, 0, detail.TextLeft, detail.TextRight, detail.Icon,
            detail.IconColor, detail.Tick)
    end
end

---Selects a card in the mission selector
function MissionSelectorHandler:SelectCard(idx)
    if idx <= 6 then
        self:SetSelection(idx - 1, self.Cards[idx].Title, self.Cards[idx].Description)
        for i, detail in pairs(self.Cards[idx].Details) do
            self:SetDetailsItem(i - 1, idx, i - 1, detail.Type, 0, 0, detail.TextLeft, detail.TextRight, detail.Icon,
                detail.IconColor, detail.Tick)
        end
    else
        self:SetSelection(idx - 1, self.Buttons[idx - 6].Text, self.Buttons[idx - 6].Description)
        for i, detail in pairs(self.Buttons[idx - 6].Details) do
            self:SetDetailsItem(i - 1, idx, i - 1, detail.Type, 0, 0, detail.TextLeft, detail.TextRight, detail.Icon,
                detail.IconColor, detail.Tick)
        end
    end
end

---Updates own vote on a card in the mission selector
function MissionSelectorHandler:UpdateOwnVote(idx, oldidx, showCheckMark, flashBG)
    if showCheckMark == nil then showCheckMark = false end
    if flashBG == nil then flashBG = false end
    if idx == oldidx then return end
    for i = 1, 9 do
        self._sc:CallFunction("SET_GRID_ITEM_VOTE", false, i - 1, self.Votes[i], self.VotesColor, showCheckMark, flashBG)
    end
    local votes = 0
    for k, v in ipairs(self.Votes) do
        if v > 0 then votes = votes + v end
    end
    self:SetVotes(votes)
    self:_SetTitle(self.JobTitle.Title, self.JobTitle.Votes)
end

---Shows a player's vote on a card in the mission selector
function MissionSelectorHandler:ShowPlayerVote(idx, playerName, color, showCheckMark, flashBG)
    self.Votes[idx] = self.Votes[idx] + 1
    if showCheckMark == nil then showCheckMark = false end
    if flashBG == nil then flashBG = false end

    local r, g, b, a = GetHudColour(color)
    self._sc:CallFunction("SHOW_PLAYER_VOTE", false, idx - 1, playerName, r, g, b)
    local votes = 0
    for k, v in ipairs(self.Votes) do
        if v > 0 then votes = votes + v end
    end
    self:SetVotes(votes)
    self:_SetTitle(self.JobTitle.Title, self.JobTitle.Votes)
    self._sc:CallFunction("SET_GRID_ITEM_VOTE", false, idx - 1, self.Votes[idx], self.VotesColor, showCheckMark, flashBG)
end

---Loads the mission selector scaleform
function MissionSelectorHandler:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("MP_NEXT_JOB_SELECTION")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
end

local success, event_type, context, item_id

---Updates the mission selector
function MissionSelectorHandler:Update()
    self._sc:Render2D()
    DisableAllControlActions(0)
    DisableAllControlActions(1)
    DisableAllControlActions(2)

    if IsUsingKeyboard(2) then
        SetMouseCursorActiveThisFrame();
        SetInputExclusive(2, 239);
        SetInputExclusive(2, 240);
        SetInputExclusive(2, 237);
        SetInputExclusive(2, 238);

        success, event_type, context, item_id = GetScaleformMovieCursorSelection(self._sc.handle)
        if success then
            if event_type == 5 then
                if self.SelectedCard ~= context + 1 then
                    self.SelectedCard = context + 1
                    self:SelectCard(self.SelectedCard)
                    return
                else
                    if self.SelectedCard <= 6 then
                        if self.alreadyVoted then
                            local old = self.VotedFor
                            self.Votes[self.VotedFor] = self.Votes[self.VotedFor] - 1
                            if (old ~= self.SelectedCard) then
                                self.VotedFor = self.SelectedCard
                                self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                            end
                            self:UpdateOwnVote(self.VotedFor, old)
                        else
                            self.alreadyVoted = true
                            self.VotedFor = self.SelectedCard
                            self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                            self:UpdateOwnVote(self.VotedFor, -1)
                        end
                    else
                        local btn = self.Buttons[self.SelectedCard - 6]
                        if btn.Selectable then
                            if self.alreadyVoted then
                                local old = self.VotedFor
                                self.Votes[self.VotedFor] = self.Votes[self.VotedFor] - 1
                                if (old ~= self.SelectedCard) then
                                    self.VotedFor = self.SelectedCard
                                    self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                                end
                                self:UpdateOwnVote(self.VotedFor, old)
                            else
                                self.alreadyVoted = true
                                self.VotedFor = self.SelectedCard
                                self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                                self:UpdateOwnVote(self.VotedFor, -1)
                            end
                        end
                        btn.OnButtonPressed()
                    end
                end
            end
        end
    end

    if IsDisabledControlJustPressed(2, 188) then
        if self.SelectedCard - 3 >= 1 and self.SelectedCard - 3 <= 9 then
            self.SelectedCard = self.SelectedCard - 3
            self:SelectCard(self.SelectedCard)
        end
    elseif IsDisabledControlJustPressed(2, 187) then
        if self.SelectedCard + 3 >= 1 and self.SelectedCard + 3 <= 9 then
            self.SelectedCard = self.SelectedCard + 3
            self:SelectCard(self.SelectedCard)
        end
    elseif IsDisabledControlJustPressed(2, 189) then
        if self.SelectedCard - 1 >= 1 and self.SelectedCard - 1 <= 9 then
            self.SelectedCard = self.SelectedCard - 1
            self:SelectCard(self.SelectedCard)
        end
    elseif IsDisabledControlJustPressed(2, 190) then
        if self.SelectedCard + 1 >= 1 and self.SelectedCard + 1 <= 9 then
            self.SelectedCard = self.SelectedCard + 1
            self:SelectCard(self.SelectedCard)
        end
    elseif IsDisabledControlJustPressed(2, 201) then
        if self.SelectedCard <= 6 then
            if self.alreadyVoted then
                local old = self.VotedFor
                self.Votes[self.VotedFor] = self.Votes[self.VotedFor] - 1
                if (old ~= self.SelectedCard) then
                    self.VotedFor = self.SelectedCard
                    self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                end
                self:UpdateOwnVote(self.VotedFor, old)
            else
                self.alreadyVoted = true
                self.VotedFor = self.SelectedCard
                self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                self:UpdateOwnVote(self.VotedFor, -1)
            end
        else
            local btn = self.Buttons[self.SelectedCard - 6]
            if btn.Selectable then
                if self.alreadyVoted then
                    local old = self.VotedFor
                    self.Votes[self.VotedFor] = self.Votes[self.VotedFor] - 1
                    if (old ~= self.SelectedCard) then
                        self.VotedFor = self.SelectedCard
                        self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                    end
                    self:UpdateOwnVote(self.VotedFor, old)
                else
                    self.alreadyVoted = true
                    self.VotedFor = self.SelectedCard
                    self.Votes[self.VotedFor] = self.Votes[self.VotedFor] + 1
                    self:UpdateOwnVote(self.VotedFor, -1)
                end
            end
            btn.OnButtonPressed()
        end
    end
end

-- These all don't make much sense based on their names, there is some cross over with naming conventions

function MissionSelectorHandler:_SetTitle(left, votes)
    self._sc:CallFunction("SET_TITLE", false, left, votes);
end

function MissionSelectorHandler:SetGridItem(id, title, txd, txn, loadtype, verified_type, icon, check, rp_multiplier,
                                            cash_multiplier,
                                            disabled, iconColor, ap_multiplier)
    self._sc:CallFunction("SET_GRID_ITEM", false, id, title, txd, txn, loadtype, verified_type, icon, check,
        rp_multiplier, cash_multiplier, disabled, iconColor, ap_multiplier);
end

function MissionSelectorHandler:SetButtonItem(id, title)
    self._sc:CallFunction("SET_GRID_ITEM", false, id + 6, title, "", "", -1, -1, -1, false, -1, -1, false, -1, -1);
end

function MissionSelectorHandler:SetSelection(index, title, description, hideHighlight)
    if hideHighlight == nil then hideHighlight = false end
    self._sc:CallFunction("SET_SELECTION", false, index, title, description, hideHighlight);
end

function MissionSelectorHandler:SetDetailsItem(id, menu_id, unique_id, type, initial_index, is_selectable, lText, rText,
                                               icon, iconColor, tick)
    if iconColor == nil then iconColor = Colours.HUD_COLOUR_WHITE end
    if tick == nil then tick = false end
    self._sc:CallFunction("SET_DETAILS_ITEM", false, id, menu_id, unique_id, type, initial_index, is_selectable, lText,
        rText, icon, iconColor, tick)
end
MultiplayerChat = setmetatable({}, MultiplayerChat)
MultiplayerChat.__index = MultiplayerChat
MultiplayerChat.__call = function()
  return "MultiplayerChat"
end

---@class MultiplayerChat
---@field public _sc scaleformUV

local INITIALIZED = false

---@enum ChatScope
ChatScope = {
  Global = 0,
  Team = 1,
  All = 2,
  Clan = 3
}

---@enum ChatVisible
ChatVisible = {
  Hidden = 0,
  Default = 1,
  Typing = 2
}

---Create a new MultiplayerChat instance
---@return table
function MultiplayerChat.New()
  local data = {
    _sc = nil --[[@type scaleformUV]],
    messages = {} --[[@type table<string, string, string, boolean, Colours>]],
    _start = 0,
    _enabled = false,
    _isTyping = false,
  }
  return setmetatable(data, MultiplayerChat)
end

---Load the MULTIPLAYER_CHAT scaleform
---@return promise
function MultiplayerChat:Load()
  local p = promise.new()

  if self._sc ~= nil then
    p:resolve()
    return p
  end

  self._sc = scaleformUV.Request("MULTIPLAYER_CHAT")
  local timeout = 1000
  local start = GlobalGameTimer
  while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end

  if self._sc:IsLoaded() then
    if not INITIALIZED then
      self._sc:CallFunction("RESET", false)
      INITIALIZED = true
    end
    p:resolve()
  else
    p:reject()
  end

  return p
end

---Set the focus of the chat
---@param visibleState ChatVisible
---@param scopeType? ChatScope
---@param scopeText? string
---@param playerName? string
---@param colour? Colours
function MultiplayerChat:SetFocus(visibleState, scopeType, scopeText, playerName, colour)
  if visibleState == ChatVisible.Hidden then
    self._start = 0
  elseif visibleState == ChatVisible.Default then
    self._start = GlobalGameTimer
  elseif visibleState == ChatVisible.Typing then
    self._isTyping = true
  end

  self._sc:CallFunction("SET_FOCUS", false, visibleState, scopeType, scopeText, playerName, colour)
end

function MultiplayerChat:Show()
  self:SetFocus(ChatVisible.Default)
end

function MultiplayerChat:StartTyping(scopeType, scopeText)
  self:SetFocus(ChatVisible.Typing, scopeType, scopeText, GetPlayerName(PlayerId()), Colours.White)
end

---Scroll the chat up
function MultiplayerChat:PageUp()
  self._sc:CallFunction("PAGE_UP", false)
end

---Scroll the chat down
function MultiplayerChat:PageDown()
  self._sc:CallFunction("PAGE_DOWN", false)
end

---Delete last character
function MultiplayerChat:DeleteText()
  self._sc:CallFunction("DELETE_TEXT", false)
end

---Set the typing state as completed
function MultiplayerChat:SetTypingDone()
  self._sc:CallFunction("SET_TYPING_DONE", false)
  self._isTyping = false
end

---Add a message with player name to the chat
---@param playerName string
---@param message string
---@param scope? ChatScope
---@param teamOnly? boolean
---@param playerColour? Colours
function MultiplayerChat:AddMessage(playerName, message, scope, teamOnly, playerColour)
  self._sc:CallFunction("ADD_MESSAGE", false, playerName, message, scope, teamOnly, playerColour)
end

-- As a key is pressed this will add the letter onto the current message in the capture field
-- if the enter key is pressed the word "ENTER" should be sent, this will trigger SET_TYPING_DONE
-- if the backspace key is pressed the word "BACKSPACE" should be sent, this will remove the last letter from the current message
-- if the escape key is pressed whe word "ESCAPE" should be sent, this will clear the current message
---Add a character to the chat
---@param text string -- The character to add, or "ENTER", "BACKSPACE", or "ESCAPE"
function MultiplayerChat:AddText(text)
  self._sc:CallFunction("ADD_TEXT", false, text)
end

---Close the chat
function MultiplayerChat:Close()
  self:SetFocus(ChatVisible.Hidden, ChatScope.Global, "")
  self._start = 0
  self._enabled = false
  self._isTyping = false
end

---Complete Text -- this will add the current messahe information to the chat locally, its also called by SetTypingDone
function MultiplayerChat:CompleteText()
  self._sc:CallFunction("COMPLETE_TEXT", false)
end

---Abort Text
function MultiplayerChat:AbortText()
  self._sc:CallFunction("ABORT_TEXT", false)
end

---Reset Text
function MultiplayerChat:Reset()
  self._sc:CallFunction("RESET", false)
end

function MultiplayerChat:IsEnabled()
  if self._sc == nil then return false end
  return self._start > 10000 or self._enabled
end

function MultiplayerChat:IsTyping()
  if self._sc == nil then return false end
  return self._isTyping
end

---Update is called every frame to render the MULTIPLAYER_CHAT scaleform to the screen by mainScaleform.lua
function MultiplayerChat:Update()
  if self._sc == nil then return end
  self._sc:Render2D()

  if self._enabled then
    DisableControlAction(0, 200, true);
  end

  if GlobalGameTimer - self._start > 10000 and not self._enabled then
    self:Close()
  end
end

---Dispose the MULTIPLAYER_CHAT scaleform
function MultiplayerChat:Dispose()
  self._sc:Dispose()
  self._sc = nil
end
PauseMenu = setmetatable({}, PauseMenu)
PauseMenu.__index = PauseMenu
PauseMenu.__call = function()
    return "PauseMenu"
end

---@class PauseMenu
---@field public _header scaleformUV
---@field public _pause scaleformUV
---@field public _lobby scaleformUV
---@field public Loaded boolean
---@field public _visible boolean
---@field public Visible fun(self:PauseMenu, visible:boolean):boolean
---@field public SetHeaderTitle fun(self:PauseMenu, title:string, subtitle:string?, shiftUpHeader:boolean?):nil
---@field public SetHeaderDetails fun(self:PauseMenu, topDetail:string, midDetail:string, botDetail:string):nil
---@field public ShiftCoronaDescription fun(self:PauseMenu, shiftDesc:boolean, hideTabs:boolean):nil
---@field public ShowHeaderDetails fun(self:PauseMenu, show:boolean):nil
---@field public SetHeaderCharImg fun(self:PauseMenu, txd:string, charTexturePath:string, show:boolean):nil
---@field public SetHeaderSecondaryImg fun(self:PauseMenu, txd:string, charTexturePath:string, show:boolean):nil
---@field public HeaderGoRight fun(self:PauseMenu):nil
---@field public HeaderGoLeft fun(self:PauseMenu):nil
---@field public AddPauseMenuTab fun(self:PauseMenu, title:string, _type:number, _tabContentType:number, color:Colours?):nil
---@field public AddLobbyMenuTab fun(self:PauseMenu, title:string, _type:number, _tabContentType:number, color:Colours?):nil
---@field public SelectTab fun(self:PauseMenu, tab:number):nil
---@field public SetFocus fun(self:PauseMenu, focus:number):nil
---@field public AddLeftItem fun(self:PauseMenu, tab:number, title:string, _type:number, _tabContentType:number, color:Colours, enabled:boolean):nil
---@field public AddRightTitle fun(self:PauseMenu, tab:number, leftItemIndex:number, title:string):nil
---@field public AddRightListLabel fun(self:PauseMenu, tab:number, leftItemIndex:number, title:string):nil
---@field public AddRightStatItemLabel fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, rightLabel:string):nil
---@field public AddRightStatItemColorBar fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, value:number, color:Colours):nil
---@field public AddRightSettingsBaseItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, rightLabel:string, enabled:boolean):nil
---@field public AddRightSettingsListItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, items:table, startIndex:number, enabled:boolean):nil
---@field public AddRightSettingsProgressItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, max:number, colour:Colours, index:number, enabled:boolean):nil
---@field public AddRightSettingsProgressItemAlt fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, max:number, colour:Colours, index:number, enabled:boolean):nil
---@field public AddRightSettingsSliderItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, max:number, colour:Colours, index:number, enabled:boolean):nil
---@field public AddRightSettingsCheckboxItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, style:number, check:boolean, enabled:boolean):nil
---@field public AddKeymapTitle fun(self:PauseMenu, tab:number, leftItemIndex:number, title:string, rightLabel:string, rightLabel2:string):nil
---@field public AddKeymapItem fun(self:PauseMenu, tab:number, leftItemIndex:number, label:string, control:string, control2:string):nil
---@field public UpdateKeymap fun(self:PauseMenu, tab:number, leftItemIndex:number, rightIndex:number, control:string, control2:string):nil
---@field public SetRightSettingsItemBool fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, check:boolean):nil
---@field public SetRightSettingsItemIndex fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, value:number):nil
---@field public SetRightSettingsItemValue fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, value:number):nil
---@field public UpdateItemRightLabel fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, rightLabel:string):nil
---@field public UpdateStatsItemBasic fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, label:string, rightLabel:string):nil
---@field public UpdateStatsItemBar fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, label:string, value:number, color:Colours):nil
---@field public UpdateItemColoredBar fun(self:PauseMenu, tab:number, leftItemIndex:number, rightItemIndex:number, colour:Colours):nil
---@field public SendInputEvent fun(self:PauseMenu, inputEvent:string):nil
---@field public SendScrollEvent fun(self:PauseMenu, scrollEvent:number):nil
---@field public SendClickEvent fun(self:PauseMenu):nil
---@field public Dispose fun(self:PauseMenu):nil
---@field public Draw fun(self:PauseMenu, isLobby:boolean?):nil
---@field public Load fun(self:PauseMenu):nil

---Creates a new instance of the pause menu
---@return PauseMenu
function PauseMenu.New()
    local _data = {
        _header = nil,
        _pause = nil,
        _lobby = nil,
        Loaded = false,
        _visible = false,
    }
    return setmetatable(_data, PauseMenu)
end

---Toggle the visibility of the pause menu
---@param visible boolean
---@return boolean
function PauseMenu:Visible(visible)
    if ToBool(visible) then
        self._visible = visible
    end
    return self._visible
end

---Load the pause menu scaleforms
function PauseMenu:Load()
    if (self._header ~= nil and self._pause ~= nil and self._lobby ~= nil) then return end
    self._header = scaleformUV.Request("pausemenuheader")
    self._pause = scaleformUV.Request("pausemenu")
    self._lobby = scaleformUV.Request("lobbymenu")
    self.Loaded = self._header:IsLoaded() and self._pause:IsLoaded() and self._lobby:IsLoaded()
end

---Set the header title and subtitle text of the pause menu header
---@param title string
---@param subtitle string?
---@param shiftUpHeader boolean?
function PauseMenu:SetHeaderTitle(title, subtitle, shiftUpHeader)
    if (subtitle == nil) then subtitle = "" end
    if (shiftUpHeader == nil) then shiftUpHeader = false end
    self._header:CallFunction("SET_HEADER_TITLE", false, title, subtitle, shiftUpHeader)
end

---Set the header details of the pause menu header
---@param topDetail string
---@param midDetail string
---@param botDetail string
function PauseMenu:SetHeaderDetails(topDetail, midDetail, botDetail)
    self._header:CallFunction("SET_HEADER_DETAILS", false, topDetail, midDetail, botDetail, false)
end

---Shift the corona description of the pause menu header
---@param shiftDesc boolean
---@param hideTabs boolean
function PauseMenu:ShiftCoronaDescription(shiftDesc, hideTabs)
    self._header:CallFunction("SHIFT_CORONA_DESC", false, shiftDesc, hideTabs)
end

---Toggle the header details of the pause menu header
---@param show boolean
function PauseMenu:ShowHeadingDetails(show)
    self._header:CallFunction("SHOW_HEADING_DETAILS", false, show)
end

---Set the header character headshot of the pause menu header
---@param txd string
---@param charTexturePath string
---@param show boolean
function PauseMenu:SetHeaderCharImg(txd, charTexturePath, show)
    self._header:CallFunction("SET_HEADER_CHAR_IMG", false, txd, charTexturePath, show)
end

---Set the header secondary image of the pause menu header
---@param txd string
---@param charTexturePath string
---@param show boolean
function PauseMenu:SetHeaderSecondaryImg(txd, charTexturePath, show)
    self._header:CallFunction("SET_HEADER_CREW_IMG", false, txd, charTexturePath, show)
end

---Move selection of the header to the right
function PauseMenu:HeaderGoRight()
    self._header:CallFunction("GO_RIGHT", false)
end

---Move selection of the header to the left
function PauseMenu:HeaderGoLeft()
    self._header:CallFunction("GO_LEFT", false)
end

---Add a tab to the pause menu
---@param title string
---@param _type number
---@param _tabContentType number
---@param color Colours? - Sets the color of the tab (default: 116)
function PauseMenu:AddPauseMenuTab(title, _type, _tabContentType, color)
    if color == nil then color = 116 end
    self._header:CallFunction("ADD_HEADER_TAB", false, title, _type, color)
    self._pause:CallFunction("ADD_TAB", false, _tabContentType)
end

---Add a tab to the lobby menu
---@param title string
---@param _type number
---@param _tabContentType number - Currently not used
---@param color Colours? - Sets the color of the tab (default: 116)
function PauseMenu:AddLobbyMenuTab(title, _type, _tabContentType, color)
    if color == nil then color = 116 end
    self._header:CallFunction("ADD_HEADER_TAB", false, title, _type, color)
end

---Select a tab in the pause menu
---@param tab number
function PauseMenu:SelectTab(tab)
    self._header:CallFunction("SET_TAB_INDEX", false, tab)
    self._pause:CallFunction("SET_TAB_INDEX", false, tab)
end

---Set the focued item of the pause menu
---@param focus number
function PauseMenu:SetFocus(focus)
    self._pause:CallFunction("SET_FOCUS", false, focus)
end

---Add a left item to the pause menu
---@param tab number
---@param _type number
---@param title string
---@param itemColor Colours? - Sets the color of the item (default: Colours.NONE)
---@param highlightColor Colours? - Sets the color of the item when highlighted (default: Colours.NONE)
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddLeftItem(tab, _type, title, itemColor, highlightColor, enabled)
    if itemColor == nil then itemColor = Colours.NONE end
    if highlightColor == nil then highlightColor = Colours.NONE end

    if itemColor ~= Colours.NONE and highlightColor == Colours.NONE then
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title, enabled, itemColor)
    elseif (itemColor ~= Colours.NONE and highlightColor ~= Colours.NONE) then
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title, enabled, itemColor, highlightColor)
    else
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title, enabled)
    end
end

---Add a right title to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param title string
function PauseMenu:AddRightTitle(tab, leftItemIndex, title)
    self._pause:CallFunction("ADD_RIGHT_TITLE", false, tab, leftItemIndex, title)
end

---Add a right list label to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
function PauseMenu:AddRightListLabel(tab, leftItemIndex, label)
    AddTextEntry("PauseMenu_" .. tab .. "_" .. leftItemIndex, label)
    BeginScaleformMovieMethod(self._pause.handle, "ADD_RIGHT_LIST_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItemIndex)
    ScaleformMovieMethodAddParamInt(0)
    BeginTextCommandScaleformString("PauseMenu_" .. tab .. "_" .. leftItemIndex)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

---Add a right stat item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param rightLabel string
function PauseMenu:AddRightStatItemLabel(tab, leftItemIndex, label, rightLabel)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 1, 0, label, rightLabel)
end

---Add a right stat item colour bar to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param value number
---@param barColor Colours? - Sets the color of the bar (default: Colours.NONE)
function PauseMenu:AddRightStatItemColorBar(tab, leftItemIndex, label, value, barColor)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 1, 1, label, value, barColor)
end

---Add a right settings base item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param rightLabel string
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsBaseItem(tab, leftItemIndex, label, rightLabel, enabled)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 0, label, enabled, rightLabel)
end

---Add a right settings list item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param items table
---@param startIndex number
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsListItem(tab, leftItemIndex, label, items, startIndex, enabled)
    local stringList = table.concat(items, ",")
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 1, label, enabled, stringList,
        startIndex)
end

---Add a right settings progress item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param max number
---@param color Colours? - Sets the color of the bar (default: Colours.NONE)
---@param index number
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsProgressItem(tab, leftItemIndex, label, max, color, index, enabled)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 2, label, enabled, max, color, index)
end

---Add a right settings progress item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param max number
---@param color Colours? - Sets the color of the bar (default: Colours.NONE)
---@param index number
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsProgressItemAlt(tab, leftItemIndex, label, max, color, index, enabled)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 3, label, enabled, max, color, index)
end

---Add a right settings slider item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param max number
---@param color Colours? - Sets the color of the bar (default: Colours.NONE)
---@param index number
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsSliderItem(tab, leftItemIndex, label, max, color, index, enabled)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 5, label, enabled, max, color, index)
end

---Add a right settings checkbox item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param style number
---@param check boolean
---@param enabled boolean? - Sets the item to be enabled or disabled
function PauseMenu:AddRightSettingsCheckboxItem(tab, leftItemIndex, label, style, check, enabled)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItemIndex, 2, 4, label, enabled, style, check)
end

---Add a key map title to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param title string
---@param rightLabel_1 string
---@param rightLabel_2 string
function PauseMenu:AddKeymapTitle(tab, leftItemIndex, title, rightLabel_1, rightLabel_2)
    self._pause:CallFunction("ADD_RIGHT_TITLE", false, tab, leftItemIndex, title, rightLabel_1, rightLabel_2)
end

---Add a key map item to a tab and left item
---@param tab number
---@param leftItemIndex number
---@param label string
---@param control1 string
---@param control2 string
function PauseMenu:AddKeymapItem(tab, leftItemIndex, label, control1, control2)
    BeginScaleformMovieMethod(self._pause.handle, "ADD_RIGHT_LIST_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItemIndex)
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamTextureNameString(label)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(control1)
    EndTextCommandScaleformString_2()
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(control2)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

---Update a key map item
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param control1 string
---@param control2 string
function PauseMenu:UpdateKeymap(tab, leftItemIndex, rightItem, control1, control2)
    BeginScaleformMovieMethod(self._pause.handle, "UPDATE_KEYMAP_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItemIndex)
    ScaleformMovieMethodAddParamInt(rightItem)
    BeginTextCommandScaleformString("string")
    AddTextComponentSubstringKeyboardDisplay(control1)
    EndTextCommandScaleformString_2()
    BeginTextCommandScaleformString("string")
    AddTextComponentSubstringKeyboardDisplay(control2)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

---Set right settings item boolean value
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param value boolean
function PauseMenu:SetRightSettingsItemBool(tab, leftItemIndex, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItemIndex, rightItem, value)
end

---Set right settings item index
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param value number
function PauseMenu:SetRightSettingsItemIndex(tab, leftItemIndex, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItemIndex, rightItem, value)
end

---Set right settings item value
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param value number
function PauseMenu:SetRightSettingsItemValue(tab, leftItemIndex, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItemIndex, rightItem, value)
end

---Update right settings item label
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param label string
function PauseMenu:UpdateItemRightLabel(tab, leftItemIndex, rightItem, label)
    self._pause:CallFunction("UPDATE_RIGHT_ITEM_RIGHT_LABEL", false, tab, leftItemIndex, rightItem, label)
end

---Update Stats Item Basic
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param label string
---@param rightLabel string
function PauseMenu:UpdateStatsItemBasic(tab, leftItemIndex, rightItem, label, rightLabel)
    self._pause:CallFunction("UPDATE_RIGHT_STATS_ITEM", false, tab, leftItemIndex, rightItem, label, rightLabel)
end

---Update Stats Item Bar
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param label string
---@param value number
---@param color Colours? - Sets the color of the bar (default: Colours.NONE)
function PauseMenu:UpdateStatsItemBar(tab, leftItemIndex, rightItem, label, value, color)
    self._pause:CallFunction("UPDATE_RIGHT_STATS_ITEM", false, tab, leftItemIndex, rightItem, label, value, color)
end

---Update Item Colored Bar
---@param tab number
---@param leftItemIndex number
---@param rightItem number
---@param color Colours? - Sets the color of the bar (default: Colours.NONE)
function PauseMenu:UpdateItemColoredBar(tab, leftItemIndex, rightItem, color)
    if (color == nil or color == Colours.NONE) then
        self._pause:CallFunction("UPDATE_COLORED_BAR_COLOR", false, tab, leftItemIndex, rightItem,
            Colours.HUD_COLOUR_WHITE)
    else
        self._pause:CallFunction("UPDATE_COLORED_BAR_COLOR", false, tab, leftItemIndex, rightItem, color)
    end
end

---Send an input event to the pause menu
---@param direction any
---@return string
function PauseMenu:SendInputEvent(direction) -- to be awaited
    local return_value = self._pause:CallFunction("SET_INPUT_EVENT", true, direction) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    return GetScaleformMovieMethodReturnValueString(return_value)
end

---Send a scroll event to the pause menu
---@param direction number
function PauseMenu:SendScrollEvent(direction)
    self._pause:CallFunction("SET_SCROLL_EVENT", false, direction)
end

---Send a click event to the pause menu
---@return string
function PauseMenu:SendClickEvent() -- to be awaited
    local return_value = self._pause:CallFunction("MOUSE_CLICK_EVENT", true) --[[@as number]]
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    return GetScaleformMovieMethodReturnValueString(return_value)
end

---Dispose the pause menu
function PauseMenu:Dispose()
    self._pause:CallFunction("CLEAR_ALL", false)
    self._header:CallFunction("CLEAR_ALL", false)
    self._lobby:CallFunction("CLEAR_ALL", false)
    self._visible = false
end

---Draw the pause menu
---@param isLobby boolean?
function PauseMenu:Draw(isLobby)
    if isLobby == nil then isLobby = false end
    if self._visible and GetCurrentFrontendMenuVersion() == -2060115030 then
        SetScriptGfxDrawBehindPausemenu(true)
        if IsUsingKeyboard(2) then
            SetMouseCursorActiveThisFrame()
        end
        self._header:Render2DNormal(0.501, 0.162, 0.6782, 0.145)
        if isLobby then
            self._lobby:Render2DNormal(0.6617187, 0.7226667, 1.0, 1.0)
        else
            self._pause:Render2DNormal(0.6617187, 0.7226667, 1.0, 1.0)
        end
    end
end
RankbarHandler = setmetatable({}, RankbarHandler)
RankbarHandler.__index = RankbarHandler
RankbarHandler.__call = function()
    return "RankbarHandler"
end

---@class RankbarHandler
---@field public Load fun():promise
---@field public SetScores fun(limitStart:number, limitEnd:number, previousValue:number, currentValue:number, currentRank:number):nil
---@field public SetColour fun(rankBarColor:number):nil
---@field public Remove fun():nil
---@field public OverrideAnimationSpeed fun(speed:number):nil
---@field public OverrideOnscreenDuration fun(duration:number):nil

local HUD_COMPONENT_ID = 19
local _rankBarColor = 116

---Creates a new RankbarHandler instance
---@return RankbarHandler
function RankbarHandler.New()
    local data = {}
    return setmetatable(data, RankbarHandler)
end

---Loads the rankbar scaleform movie
---@return promise
function RankbarHandler:Load()
    local p = promise.new()

    if HasScaleformScriptHudMovieLoaded(HUD_COMPONENT_ID) then
        p:resolve()
        return p
    end

    RequestScaleformScriptHudMovie(HUD_COMPONENT_ID)
    local timeout = 1000
    local start = GlobalGameTimer
    while not HasScaleformScriptHudMovieLoaded(HUD_COMPONENT_ID) and GlobalGameTimer - start < timeout do Citizen.Wait(0) end

    if HasScaleformScriptHudMovieLoaded(HUD_COMPONENT_ID) then
        p:resolve()
    else
        p:reject()
    end

    return p
end

---Set the scores for the rankbar
---@param limitStart number
---@param limitEnd number
---@param previousValue number
---@param currentValue number
---@param currentRank number
function RankbarHandler:SetScores(limitStart, limitEnd, previousValue, currentValue, currentRank)
    self:Load():next(function()
            BeginScaleformScriptHudMovieMethod(HUD_COMPONENT_ID, "SET_COLOUR")
            ScaleformMovieMethodAddParamInt(_rankBarColor)
            EndScaleformMovieMethod()

            BeginScaleformScriptHudMovieMethod(HUD_COMPONENT_ID, "SET_RANK_SCORES")
            ScaleformMovieMethodAddParamInt(limitStart)
            ScaleformMovieMethodAddParamInt(limitEnd)
            ScaleformMovieMethodAddParamInt(previousValue)
            ScaleformMovieMethodAddParamInt(currentValue)
            ScaleformMovieMethodAddParamInt(currentRank)
            EndScaleformMovieMethod()
        end,
        function()
            print("RankbarHandler:Load() failed")
        end)
end

---Set the colour of the rankbar
---@param rankBarColor Colours
function RankbarHandler:SetColour(rankBarColor)
    _rankBarColor = rankBarColor
end

---Remove the rankbar from the screen
function RankbarHandler:Remove()
    if HasScaleformScriptHudMovieLoaded(HUD_COMPONENT_ID) then
        BeginScaleformScriptHudMovieMethod(HUD_COMPONENT_ID, "REMOVE");
        EndScaleformMovieMethod();
    end
end

---Override the animation speed of the rankbar
---@param speed number -- milliseconds (default 1000)
function RankbarHandler:OverrideAnimationSpeed(speed)
    self:Load():next(function()
            BeginScaleformScriptHudMovieMethod(HUD_COMPONENT_ID, "OVERRIDE_ANIMATION_SPEED");
            ScaleformMovieMethodAddParamInt(speed);
            EndScaleformMovieMethod();
        end,
        function()
            print("RankbarHandler:Load() failed")
        end)
end

---Override the onscreen duration of the rankbar
---@param duration number -- milliseconds (default 4000)
function RankbarHandler:OverrideOnscreenDuration(duration)
    self:Load():next(function()
            BeginScaleformScriptHudMovieMethod(HUD_COMPONENT_ID, "OVERRIDE_ONSCREEN_DURATION");
            ScaleformMovieMethodAddParamInt(duration);
            EndScaleformMovieMethod();
        end,
        function()
            print("RankbarHandler:Load() failed")
        end)
end
PlayerListScoreboard = setmetatable({}, PlayerListScoreboard)
PlayerListScoreboard.__index = PlayerListScoreboard
PlayerListScoreboard.__call = function()
    return "PlayerListScoreboard"
end

---@class PlayerListScoreboard
---@field _uptime number
---@field _start number
---@field _timer number
---@field _sc scaleformUV
---@field public Enabled boolean
---@field public Index number
---@field public MaxPages number
---@field public currentPage number
---@field public PlayerRows table<number, SCPlayerItem>
---@field public TitleLeftText string
---@field public TitleRightText string
---@field public TitleIcon number
---@field public X number
---@field public Y number
---@field public Update fun(self:PlayerListScoreboard):nil
---@field public NextPage fun(self:PlayerListScoreboard):nil
---@field public AddRow fun(self:PlayerListScoreboard, row:SCPlayerItem):nil
---@field public RemoveRow fun(self:PlayerListScoreboard, index:number):nil
---@field public CurrentPage fun(self:PlayerListScoreboard, _c:number?):number
---@field public Dispose fun(self:PlayerListScoreboard):nil
---@field public Load fun(self:PlayerListScoreboard):nil
---@field public SetTitle fun(self:PlayerListScoreboard, title:string, label:string, icon:number):nil
---@field public SetPosition fun(self:PlayerListScoreboard, x:number, y:number):nil

---Creates a new PlayerListScoreboard instance
---@return PlayerListScoreboard
function PlayerListScoreboard.New()
    local data = {
        _uptime = 8000,
        _start = 0,
        _timer = 0,
        _sc = nil,
        Enabled = false,
        Index = 0,
        MaxPages = 1,
        currentPage = 0,
        PlayerRows = {},
        TitleLeftText = "",
        TitleRightText = "",
        TitleIcon = 0,
        X = 0.122,
        Y = 0.3
    }
    return setmetatable(data, PlayerListScoreboard)
end

---Current page of the scoreboard
---@param _c number?
---@return number
function PlayerListScoreboard:CurrentPage(_c)
    if _c ~= nil then
        if #self.PlayerRows == 0 then
            self.currentPage = 0
            return self.currentPage
        end
        self.currentPage = _c
        if self.currentPage > 0 then
            self.Enabled = true
            self:NextPage()
        end
    end
    return self.currentPage
end

---Load the scoreboard scaleform
function PlayerListScoreboard:Load()
    if self._sc ~= nil then return end
    self._sc = scaleformUV.Request("MP_MM_CARD_FREEMODE")
    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end
end

---Dispose the scoreboard scaleform
function PlayerListScoreboard:Dispose()
    if self._sc == nil then return end
    self.Enabled = false
    self.Index = 0
    self.MaxPages = 1
    self:CurrentPage(0)
    self.TitleLeftText = ""
    self.TitleRightText = ""
    self.TitleIcon = 0
    self._sc:CallFunction("SET_DATA_SLOT_EMPTY", false)
    self._sc:Dispose()
    self._sc = nil
    for i = 0, 1024 do -- cleaning up in case of a reload, this frees up all ped headshot handles :)
        UnregisterPedheadshot(i)
    end
end

---Set the title of the scoreboard
---@param title string
---@param label string
---@param icon number
function PlayerListScoreboard:SetTitle(title, label, icon)
    self.TitleLeftText = title or ""
    self.TitleRightText = label or ""
    self.TitleIcon = icon or 0
end

---Set the position of the scoreboard
---@param x number
---@param y number
function PlayerListScoreboard:SetPosition(x, y)
    self.X = x
    self.Y = y
end

---Set the duration the scoreboard should be visible
function PlayerListScoreboard:SetTimer(upTime)
    self.uptime = upTime
end

---Add a new row to the scoreboard
---@param player SCPlayerItem
function PlayerListScoreboard:AddRow(player)
    self.PlayerRows[#self.PlayerRows + 1] = player
end

---Remove a row from the scoreboard
---@param index number
function PlayerListScoreboard:RemoveRow(index)
    table.remove(self.PlayerRows, index)
end

---Get if a row_id should be displayed on the current page
---@param row_id number
function PlayerListScoreboard:IsSupposedToShow(row_id)
    if self:CurrentPage() == 0 then return false end
    local max = self:CurrentPage() * 16
    local min = self:CurrentPage() * 16 - 15
    return row_id >= min and row_id <= max
end

---Update max pages displayed on the scoreboard
function PlayerListScoreboard:UpdateMaxPages()
    self.MaxPages = math.ceil(#self.PlayerRows / 16.0)
end

---Draw the scoreboard on the screen
function PlayerListScoreboard:Update()
    self._sc:Render2DNormal(self.X, self.Y, 0.28, 0.6)
    if self._start ~= 0 and GlobalGameTimer - self._start > self._timer then
        self:CurrentPage(0)
        self.Enabled = false
        self._start = 0
        self:Dispose()
    end
end

---Change the page of the scoreboard
function PlayerListScoreboard:NextPage()
    self:UpdateMaxPages()
    self._start = GlobalGameTimer
    self._timer = self._uptime or 8000
    self:BuildMenu()
    if self:CurrentPage() > self.MaxPages then
        self:CurrentPage(0)
        self.Enabled = false
        self._start = 0
        self:Dispose()
    end
end

---Highlight a row on the scoreboard
---@param idx number
function PlayerListScoreboard:Highlight(idx)
    self._sc:CallFunction("SET_HIGHLIGHT", false, idx - 1)
end

---Show microphone icon on a row
---@param idx number
---@param show boolean
function PlayerListScoreboard:ShowMic(idx, show)
    self._sc:CallFunction("DISPLAY_MIC", false, idx - 1, show)
end

---Update a slot on the scoreboard
---@param id number
---@param row SCPlayerItem
function PlayerListScoreboard:UpdateSlot(id, row)
    if row.CrewLabelText ~= "" then
        self._sc:CallFunction("UPDATE_SLOT", false, id - 1, row.RightText, row.Name, row.Color, row.RightIcon,
            row.IconOverlayText, row.JobPointsText, "..+" .. row.CrewLabelText, row.JobPointsDisplayType,
            row.TextureString,
            row.TextureString, row.FriendType)
    else
        self._sc:CallFunction("UPDATE_SLOT", false, id - 1, row.RightText, row.Name, row.Color, row.RightIcon,
            row.IconOverlayText, row.JobPointsText, "", row.JobPointsDisplayType, row.TextureString, row.TextureString,
            row.FriendType)
    end
end

---Refresh all slots on the scoreboard
function PlayerListScoreboard:RefreshAll()
    Citizen.CreateThread(function()
        for index, row in pairs(self.PlayerRows) do
            if row.CrewLabelText ~= "" then
                self._sc:CallFunction("UPDATE_SLOT", false, index - 1, row.RightText, row.Name, row.Color, row.RightIcon,
                    row.IconOverlayText, row.JobPointsText, "..+" .. row.CrewLabelText, row.JobPointsDisplayType,
                    row.TextureString, row.TextureString, row.FriendType)
            else
                self._sc:CallFunction("UPDATE_SLOT", false, index - 1, row.RightText, row.Name, row.Color, row.RightIcon,
                    row.IconOverlayText, row.JobPointsText, "", row.JobPointsDisplayType, row.TextureString,
                    row.TextureString, row.FriendType)
            end
        end
    end)
end

---Set the icon of a row
---@param idx number
---@param icon number
---@param txt string
function PlayerListScoreboard:SetIcon(idx, icon, txt)
    local row = self.PlayerRows[idx]
    if row ~= nil then
        self._sc:CallFunction("SET_ICON", false, idx - 1, icon, txt)
    end
end

---Build the scoreboard
function PlayerListScoreboard:BuildMenu()
    if self._sc == nil then self:Load() end
    while self._sc == nil or not self._sc:IsLoaded() do Citizen.Wait(0) end
    local rows = {}
    self._sc:CallFunction("SET_DATA_SLOT_EMPTY", false)
    self._sc:CallFunction("SET_TITLE", false, self.TitleLeftText, self.TitleRightText, self.TitleIcon)
    for k, v in pairs(self.PlayerRows) do
        if self:IsSupposedToShow(k) then
            rows[#rows + 1] = v
        end
    end
    self.Index = 0
    for k, row in pairs(rows) do
        if string.IsNullOrEmpty(row.CrewLabelText) then
            self._sc:CallFunction("SET_DATA_SLOT", false, self.Index, row.RightText, row.Name, row.Color, row.RightIcon,
                row.IconOverlayText, row.JobPointsText, "", row.JobPointsDisplayType, row.TextureString,
                row.TextureString,
                row.FriendType)
        else
            self._sc:CallFunction("SET_DATA_SLOT", false, self.Index, row.RightText, row.Name, row.Color, row.RightIcon,
                row.IconOverlayText, row.JobPointsText, "..+" .. row.CrewLabelText, row.JobPointsDisplayType,
                row.TextureString, row.TextureString, row.FriendType)
        end
        self.Index = self.Index + 1
    end
    self._sc:CallFunction("DISPLAY_VIEW", false)
end
SCPlayerItem = setmetatable({}, SCPlayerItem)
SCPlayerItem.__index = SCPlayerItem
SCPlayerItem.__call = function()
    return "SCPlayerItem"
end

---@class SCPlayerItem
---@field public Name string
---@field public Color Colours
---@field public RightIcon number
---@field public RightText number
---@field public FriendType string
---@field public CrewLabelText string
---@field public IconOverlayText string
---@field public JobPointsDisplayType number
---@field public JobPointsText string
---@field public ServerId number
---@field public TextureString string

---Creates a new SCPlayerItem instance
---@param label string
---@param color Colours
---@param rightIcon number
---@param rightText number
---@param friendType string
---@param crewLabel string
---@param iconText string
---@param jobPointsType number
---@param jobPointsText string
---@param serverId number
---@param txd string
---@return SCPlayerItem
function SCPlayerItem.New(label, color, rightIcon, rightText, friendType, crewLabel, iconText, jobPointsType,
                          jobPointsText, serverId, txd)
    local data = {
        Name = label,
        Color = color,
        RightIcon = rightIcon,
        RightText = rightText,
        FriendType = friendType,
        CrewLabelText = crewLabel,
        IconOverlayText = iconText,
        JobPointsDisplayType = jobPointsType,
        JobPointsText = jobPointsText,
        ServerId = serverId,
        TextureString = txd,
    }
    return setmetatable(data, SCPlayerItem)
end
ScoreDisplayType = {
    NUMBER_ONLY = 0,
    ICON = 1,
    NONE = 2
}

ScoreRightIconType = {
    NONE = 0,
    INACTIVE_HEADSET = 48,
    MUTED_HEADSET = 49,
    ACTIVE_HEADSET = 47,
    RANK_FREEMODE = 65,
    KICK = 64,
    LOBBY_DRIVER = 79,
    LOBBY_CODRIVER = 80,
    SPECTATOR = 66,
    BOUNTY = 115,
    DEAD = 116,
    DPAD_GANG_CEO = 121,
    DPAD_GANG_BIKER = 122,
    DPAD_DOWN_TARGET = 123
}
WarningInstance = setmetatable({}, WarningInstance)
WarningInstance.__index = WarningInstance
WarningInstance.__call = function()
    return "WarningInstance"
end

---@class WarningInstance
---@field _sc scaleformUV
---@field _disableControls boolean
---@field _buttonList table<InstructionalButton>
---@field OnButtonPressed fun(button: InstructionalButton)
---@field public Update fun(self:WarningInstance):nil
---@field public IsShowing fun(self:WarningInstance):boolean

---Creates a new WarningInstance instance
---@return WarningInstance
function WarningInstance.New()
    local data = {
        _sc = nil --[[@type scaleformUV]],
        _disableControls = false,
        _buttonList = {},
        OnButtonPressed = function(button)
        end
    }
    return setmetatable(data, WarningInstance)
end

---Returns whether the warning is currently showing
---@return boolean
function WarningInstance:IsShowing()
    return self._sc ~= nil
end

---Loads the warning scaleform
---@return promise
function WarningInstance:Load()
    local p = promise.new()

    if self._sc ~= nil then
        p:resolve()
        return p
    end

    self._sc = scaleformUV.Request("POPUP_WARNING")

    if self._sc == nil then
        p:reject("Error requesting warning scaleform.")
        return p
    end

    local timeout = 1000
    local start = GlobalGameTimer
    while not self._sc:IsLoaded() and GlobalGameTimer - start < timeout do Citizen.Wait(0) end

    if self._sc:IsLoaded() then
        p:resolve()
    else
        p:reject("Error loading warning scaleform.")
    end

    return p
end

---Disposes the warning scaleform
function WarningInstance:Dispose()
    if self._sc == nil then return end
    self._sc:CallFunction("HIDE_POPUP_WARNING", false, 1000)
    self._sc:Dispose()
    self._sc = nil
    self._disableControls = false
end

---Shows the warning with the given title, subtitle, prompt, error message and warning type
---@param title string
---@param subtitle string
---@param prompt string
---@param errorMsg string
---@param warningType number
function WarningInstance:ShowWarning(title, subtitle, prompt, errorMsg, warningType, showBackground)
    self:Load():next(function()
        if warningType == nil then warningType = 0 end
        if showBackground == nil then showBackground = true end
        self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, showBackground, warningType, errorMsg)
    end, function(value)
        print("Error loading warning: " .. value)
    end)
end

---Updates the warning with the given title, subtitle, prompt, error message and warning type
---@param title string
---@param subtitle string
---@param prompt string
---@param errorMsg string
---@param warningType number
function WarningInstance:UpdateWarning(title, subtitle, prompt, errorMsg, warningType, showBackground)
    if not self:IsShowing() then return end
    if warningType == nil then warningType = 0 end
    if showBackground == nil then showBackground = true end
    self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, showBackground, warningType, errorMsg)
end

---Shows the warning with the given title, subtitle, prompt, error message, warning type and buttons
---@param title string
---@param subtitle string
---@param prompt string
---@param buttons table<InstructionalButton>
---@param errorMsg string
---@param warningType number
function WarningInstance:ShowWarningWithButtons(title, subtitle, prompt, buttons, errorMsg, warningType, showBackground)
    self:Load():next(function()
        if warningType == nil then warningType = 0 end
        if showBackground == nil then showBackground = true end
        self._disableControls = true
        self._buttonList = buttons
        if buttons == nil or #buttons == 0 then return end
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self._buttonList)
        ScaleformUI.Scaleforms.InstructionalButtons.UseMouseButtons = true
        self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, showBackground, warningType, errorMsg)
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
    end, function(value)
        print("Error loading warning: " .. value)
    end)
end

---Draws the warning
function WarningInstance:Update()
    if self._sc == nil then return end
    if not self._sc:IsLoaded() then return end

    self._sc:Render2D()
    if self._disableControls then
        ScaleformUI.Scaleforms.InstructionalButtons:Draw()
        for k, v in pairs(self._buttonList) do
            if IsControlJustPressed(1, v.GamepadButton) or IsControlJustPressed(1, v.KeyboardButton) then
                self.OnButtonPressed(v)
                self:Dispose()
                ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
                ScaleformUI.Scaleforms.InstructionalButtons.UseMouseButtons = false
            end
        end
    end
end
ScaleformUI = {}
ScaleformUI.Scaleforms = {}
ScaleformUI.Notifications = nil
ScaleformUI.Scaleforms._ui = nil --[[@type scaleformUV]]                             -- scaleformui
ScaleformUI.Scaleforms._pauseMenu = nil --[[@type PauseMenu]]                      -- pausemenu
ScaleformUI.Scaleforms.MidMessageInstance = nil --[[@type MidMessageInstance]]     -- midmessage
ScaleformUI.Scaleforms.PlayerListScoreboard = nil --[[@type PlayerListScoreboard]] -- playerlist
ScaleformUI.Scaleforms.InstructionalButtons = nil --[[@type ButtonsHandler]]       -- buttons
ScaleformUI.Scaleforms.BigMessageInstance = nil --[[@type BigMessageInstance]]     -- bigmessage
ScaleformUI.Scaleforms.Warning = nil --[[@type WarningInstance]]                   -- warning
ScaleformUI.Scaleforms.JobMissionSelector = nil --[[@type MissionSelectorHandler]] -- missionselector
ScaleformUI.Scaleforms.RankbarHandler = nil --[[@type RankbarHandler]]             -- rankbar
ScaleformUI.Scaleforms.CountdownHandler = nil --[[@type CountdownHandler]]         -- countdown

ScaleformUI.Scaleforms._pauseMenu = nil

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        if IsPauseMenuActive() and GetCurrentFrontendMenuVersion() == -2060115030 then
            ActivateFrontendMenu(`FE_MENU_VERSION_EMPTY_NO_BACKGROUND`, true, -1)
            AnimpostfxStop("PauseMenuIn");
            AnimpostfxPlay("PauseMenuOut", 800, false);
        end
        ScaleformUI.Scaleforms._pauseMenu:Dispose()
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms._ui:Dispose()
        if not IsPlayerControlOn(PlayerId()) then
            SetPlayerControl(PlayerId(), true, 0)
        end
    end
end)

Citizen.CreateThread(function()
    ScaleformUI.Scaleforms._ui = scaleformUV.RequestWidescreen("scaleformui")
    ScaleformUI.Scaleforms.BigMessageInstance = BigMessageInstance.New()
    ScaleformUI.Scaleforms.MidMessageInstance = MidMessageInstance.New()
    ScaleformUI.Scaleforms.Warning = WarningInstance.New()
    ScaleformUI.Scaleforms.PlayerListScoreboard = PlayerListScoreboard.New()
    ScaleformUI.Scaleforms.JobMissionSelector = MissionSelectorHandler.New()
    ScaleformUI.Scaleforms.InstructionalButtons = ButtonsHandler.New()
    ScaleformUI.Notifications = Notifications.New()
    ScaleformUI.Scaleforms._pauseMenu = PauseMenu.New()
    ScaleformUI.Scaleforms._pauseMenu:Load()
    ScaleformUI.Scaleforms.RankbarHandler = RankbarHandler.New()
    ScaleformUI.Scaleforms.CountdownHandler = CountdownHandler.New()
    ScaleformUI.Scaleforms.BigFeed = BigFeedInstance.New()

    local wait = 850
    while true do
        wait = 850
        if not IsPauseMenuActive() then
            if ScaleformUI.Scaleforms.BigMessageInstance._sc ~= nil then
                ScaleformUI.Scaleforms.BigMessageInstance:Update()
                wait = 0
            end
            if ScaleformUI.Scaleforms.MidMessageInstance._sc ~= nil then
                ScaleformUI.Scaleforms.MidMessageInstance:Update()
                wait = 0
            end
            if ScaleformUI.Scaleforms.PlayerListScoreboard._sc ~= nil and ScaleformUI.Scaleforms.PlayerListScoreboard.Enabled then
                ScaleformUI.Scaleforms.PlayerListScoreboard:Update()
                wait = 0
            end
            if ScaleformUI.Scaleforms.JobMissionSelector.enabled and ScaleformUI.Scaleforms.JobMissionSelector._sc and ScaleformUI.Scaleforms.JobMissionSelector._sc:IsLoaded() then
                ScaleformUI.Scaleforms.JobMissionSelector:Update()
                wait = 0
            end
            if ScaleformUI.Scaleforms.Warning._sc ~= nil then
                ScaleformUI.Scaleforms.Warning:Update()
                wait = 0
            end
            if ScaleformUI.Scaleforms.BigFeed._sc ~= nil and ScaleformUI.Scaleforms.BigFeed._enabled then
                ScaleformUI.Scaleforms.BigFeed:Update()
                wait = 0
            end
        end
        if (ScaleformUI.Scaleforms.InstructionalButtons._sc == nil) then
            ScaleformUI.Scaleforms.InstructionalButtons:Load()
        elseif ScaleformUI.Scaleforms.InstructionalButtons:Enabled() or ScaleformUI.Scaleforms.InstructionalButtons.IsSaving then
            ScaleformUI.Scaleforms.InstructionalButtons:Update()
            wait = 0
        end
        if ScaleformUI.Scaleforms._ui == nil then
            ScaleformUI.Scaleforms._ui = scaleformUV.RequestWidescreen("scaleformui")
        end
        if not ScaleformUI.Scaleforms._pauseMenu.Loaded then
            ScaleformUI.Scaleforms._pauseMenu:Load()
        end

        if ScaleformUI.Scaleforms.BigMessageInstance._sc == nil and
            ScaleformUI.Scaleforms.MidMessageInstance._sc == nil and
            ScaleformUI.Scaleforms.Warning._sc == nil and
            (ScaleformUI.Scaleforms.PlayerListScoreboard._sc ~= nil and not ScaleformUI.Scaleforms.PlayerListScoreboard.Enabled) and
            (ScaleformUI.Scaleforms.JobMissionSelector.enabled or ScaleformUI.Scaleforms.JobMissionSelector._sc == nil) and
            (not ScaleformUI.Scaleforms.InstructionalButtons._enabled or (ScaleformUI.Scaleforms.InstructionalButtons.ControlButtons == nil or #ScaleformUI.Scaleforms.InstructionalButtons.ControlButtons == 0 and not ScaleformUI.Scaleforms.InstructionalButtons.IsSaving))
        then
            wait = 850
        end

        Citizen.Wait(wait)
    end
end)

UIMenuFreemodeDetailsItem = setmetatable({}, UIMenuFreemodeDetailsItem)
UIMenuFreemodeDetailsItem.__index = UIMenuFreemodeDetailsItem
UIMenuFreemodeDetailsItem.__call = function() return "UIMenuFreemodeDetailsItem", "UIMenuFreemodeDetailsItem" end

function UIMenuFreemodeDetailsItem.New(textLeft, textRight, seperator, icon, iconColor, tick)
    local _type
    if seperator then
        _type = 3
    elseif icon ~= nil and iconColor ~= nil then
        _type = 2
    elseif textRight == nil and seperator == nil and icon == nil and iconColor == nil and tick == nil then
        _type = 4
    else
        _type = 0
    end
    _UIMenuFreemodeDetailsItem = {
        Type = _type,
        TextLeft = textLeft,
        TextRight = textRight,
        Icon = icon,
        IconColor = iconColor,
        Tick = tick or false
    }
    return setmetatable(_UIMenuFreemodeDetailsItem, UIMenuFreemodeDetailsItem)
end
UIMissionDetailsPanel = setmetatable({}, UIMissionDetailsPanel)
UIMissionDetailsPanel.__index = UIMissionDetailsPanel
UIMissionDetailsPanel.__call = function() return "UIMissionDetailsPanel", "UIMissionDetailsPanel" end

function UIMissionDetailsPanel.New(side, title, color, inside, txd, txn)
    local _titleType, _titleColor
    if inside == -1 then
        _titleType = 1
    elseif inside then
        _titleType = 2
    else
        _titleType = 0
    end

    if color ~= -1 then
        _titleColor = color
    else
        _titleColor = Colours.NONE
    end

    _UIMissionDetailsPanel = {
        PanelSide = side,
        Title = title,
        TitleColor = _titleColor,
        TitleType = _titleType,
        TextureDict = txd or "",
        TextureName = txn or "",
        Items = {},
        ParentItem = nil
    }
    return setmetatable(_UIMissionDetailsPanel, UIMissionDetailsPanel)
end

function UIMissionDetailsPanel:SetParentItem(Item) -- required
    if Item() == "UIMenuItem" then
        self.ParentItem = Item
    else
        return self.ParentItem
    end
end

function UIMissionDetailsPanel:UpdatePanelTitle(title)
    self.Title = title

    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_SIDE_PANEL_TITLE", false, item, title)
    end
end

function UIMissionDetailsPanel:UpdatePanelPicture(txd, txn)
    self.TextureDict = txd
    self.TextureName = txn

    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_MISSION_DETAILS_PANEL_IMG", false, item, txd, txn)
    end
end

function UIMissionDetailsPanel:AddItem(newitem)
    self.Items[#self.Items + 1] = newitem
    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("ADD_MISSION_DETAILS_DESC_ITEM", false, item, newitem.Type,
            newitem.TextLeft, newitem.TextRight, newitem.Icon, newitem.IconColor, newitem.Tick)
    end
end

function UIMissionDetailsPanel:RemoveItemAt(index)
    table.remove(self.Items, index)
    if self.ParentItem ~= nil then
        ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_MISSION_DETAILS_DESC_ITEM", false, index - 1)
    end
end
UIVehicleColorPickerPanel = setmetatable({}, UIVehicleColorPickerPanel)
UIVehicleColorPickerPanel.__index = UIVehicleColorPickerPanel
UIVehicleColorPickerPanel.__call = function() return "UIVehicleColorPickerPanel", "UIVehicleColorPickerPanel" end

function UIVehicleColorPickerPanel.New(side, title, color)
    local _titleColor
    if color ~= -1 then
        _titleColor = color
    else
        _titleColor = Colours.NONE
    end

    _UIVehicleColorPickerPanel = {
        PanelSide = side,
        Title = title,
        TitleColor = _titleColor,
        TitleType = 0,
        Value = 1,
        ParentItem = nil,
        PickerSelect = function(menu, item, newindex)
        end
    }
    return setmetatable(_UIVehicleColorPickerPanel, UIVehicleColorPickerPanel)
end

function UIVehicleColorPickerPanel:SetParentItem(Item) -- required
    if not Item() == nil then
        self.ParentItem = Item
    else
        return self.ParentItem
    end
end

function UIVehicleColorPickerPanel:UpdatePanelTitle(title)
    self.Title = title
    if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_SIDE_PANEL_TITLE", false, item, title)
    end
end
---@diagnostic disable: missing-parameter -- false positive

ProgressTimerBar = setmetatable({}, ProgressTimerBar)
ProgressTimerBar.__index = ProgressTimerBar
ProgressTimerBar.__call = function()
    return "TimerBarBase", "ProgressTimerBar"
end

function ProgressTimerBar.New(label, backgroundColor, foregroundColor)
    if backgroundColor == nil then backgroundColor = { R = 112, G = 25, B = 25, A = 255 } end
    if foregroundColor == nil then foregroundColor = { R = 224, G = 50, B = 50, A = 255 } end
    local _data = {
        _label = label or "",
        _percentage = 0,
        _backgroundColor = backgroundColor or { R = 112, G = 25, B = 25, A = 255 }, --darkred
        _foregroundColor = foregroundColor or { R = 224, G = 50, B = 50, A = 255 }, -- red
        _backgroundRect = UIResRectangle.New(0, 0, 150, 15, backgroundColor.R or 112, backgroundColor.G or 25,
            backgroundColor.B or 25, backgroundColor.A or 255),
        _foregroundRect = UIResRectangle.New(0, 0, 0, 15, foregroundColor.R or 224, foregroundColor.G or 50,
            foregroundColor.B or 50, foregroundColor.A or 255),
        _enabled = true,
        _labelFont = Font.CHALET_LONDON,
        Handle = nil,
    }
    return setmetatable(_data, ProgressTimerBar)
end

function ProgressTimerBar:Label(label)
    if label == nil then
        return self._label
    else
        self._label = label
    end
end

function ProgressTimerBar:LabelFont(font)
    if font == nil then
        return self._labelFont
    else
        self._labelFont = font
    end
end

function ProgressTimerBar:BackgroundColor(color)
    if color == nil then
        return self._backgroundColor
    else
        self._backgroundColor = color
    end
end

function ProgressTimerBar:ForegroundColor(color)
    if color == nil then
        return self._foregroundColor
    else
        self._foregroundColor = color
    end
end

function ProgressTimerBar:Percentage(val)
    if val == nil then
        return self._percentage
    else
        self._percentage = val
    end
end

function ProgressTimerBar:Enabled(bool)
    if bool == nil then
        return self._enabled
    else
        self._enabled = bool
    end
end

function ProgressTimerBar:Draw(interval)
    if not self._enabled then return end
    local resx, resy = ResolutionMaintainRatio()
    local safex, safey = SafezoneBounds()

    UIResText.New(self:Label(), resx - safex - 180, resy - safey - (30 + (4 * interval)), 0.3, 240, 240, 240, 255,
        self._labelFont, 2)
        :Draw()
    Sprite.New("timerbars", "all_black_bg", resx - safex - 298, resy - safey - (40 + (4 * interval)), 300, 37, 0.0, 255,
        255, 255, 180):Draw()

    local startx, starty = resx - safex - 160, resy - safey - (28 + (4 * interval))
    self._backgroundRect:Position(startx, starty)
    self._foregroundRect:Position(startx, starty)
    self._foregroundRect:Size(150 * self._percentage, 15)

    -- in case someone decides to change color on the fly..
    self._backgroundRect:Colour(self._backgroundColor.R, self._backgroundColor.G, self._backgroundColor.B,
        self._backgroundColor.A)
    self._foregroundRect:Colour(self._foregroundColor.R, self._foregroundColor.G, self._foregroundColor.B,
        self._foregroundColor.A)

    self._backgroundRect:Draw()
    self._foregroundRect:Draw()

    HideHudComponentThisFrame(6);
    HideHudComponentThisFrame(7);
    HideHudComponentThisFrame(9);
end
---@diagnostic disable: missing-parameter

TextTimerBar = setmetatable({}, TextTimerBar)
TextTimerBar.__index = TextTimerBar
TextTimerBar.__call = function()
    return "TimerBarBase", "TextTimerBar"
end

function TextTimerBar.New(label, text, captionColor)
    if captionColor == nil then captionColor = { R = 240, G = 240, B = 240, A = 255 } end
    local _data = {
        _label = label or "",
        _caption = text or "",
        _captionColor = captionColor,
        _enabled = true,
        _labelFont = Font.CHALET_LONDON,
        _captionFont = Font.CHALET_LONDON,
        Handle = nil,
    }
    return setmetatable(_data, TextTimerBar)
end

function TextTimerBar:Label(label)
    if label == nil then
        return self._label
    else
        self._label = label
    end
end

function TextTimerBar:Caption(caption)
    if caption == nil then
        return self._caption
    else
        self._caption = caption
    end
end

function TextTimerBar:LabelFont(font)
    if font == nil then
        return self._labelFont
    else
        self._labelFont = font
    end
end

function TextTimerBar:CaptionFont(font)
    if font == nil then
        return self._captionFont
    else
        self._captionFont = font
    end
end

function TextTimerBar:Color(color)
    if color == nil then
        return self._captionColor
    else
        self._captionColor = color
    end
end

function TextTimerBar:Enabled(bool)
    if bool == nil then
        return self._enabled
    else
        self._enabled = bool
    end
end

function TextTimerBar:Draw(interval)
    if not self._enabled then return end
    local resx, resy = ResolutionMaintainRatio()
    local safex, safey = SafezoneBounds()

    UIResText.New(self._label, resx - safex - 180, resy - safey - (30 + (4 * interval)), 0.3, 240, 240, 240, 255,
        self._labelFont, 2):
        Draw()
    Sprite.New("timerbars", "all_black_bg", resx - safex - 298, resy - safey - (40 + (4 * interval)), 300, 37, 0.0, 255,
        255, 255, 180):Draw()
    UIResText.New(self._caption, resx - safex - 10, resy - safey - (42 + (4 * interval)), 0.5, self._captionColor.R,
        self._captionColor.G, self._captionColor.B, self._captionColor.A, self._captionFont, 2):Draw()

    HideHudComponentThisFrame(6);
    HideHudComponentThisFrame(7);
    HideHudComponentThisFrame(9);
end
Sprite = setmetatable({}, Sprite)
Sprite.__index = Sprite
Sprite.__call = function() return "Sprite" end

---@class Sprite
---@field TxtDictionary string
---@field TxtName string
---@field X number
---@field Y number
---@field Width number
---@field Height number
---@field Heading number
---@field _Colour table
---@field _Colour.R number
---@field _Colour.G number
---@field _Colour.B number
---@field _Colour.A number
---@field Position function
---@field Size function

---New
---@param TxtDictionary string
---@param TxtName string
---@param X number|0
---@param Y number|0
---@param Width number|0
---@param Height number|0
---@param Heading number|0
---@param R number|255
---@param G number|255
---@param B number|255
---@param A number|255
function Sprite.New(TxtDictionary, TxtName, X, Y, Width, Height, Heading, R, G, B, A)
    local _Sprite = {
        TxtDictionary = tostring(TxtDictionary),
        TxtName = tostring(TxtName),
        X = tonumber(X) or 0,
        Y = tonumber(Y) or 0,
        Width = tonumber(Width) or 0,
        Height = tonumber(Height) or 0,
        Heading = tonumber(Heading) or 0,
        _Colour = { R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255 },
    }
    return setmetatable(_Sprite, Sprite)
end

---Sets the position of the sprite
---@param X number?
---@param Y number?
function Sprite:Position(X, Y)
    if tonumber(X) and tonumber(Y) then
        self.X = tonumber(X)
        self.Y = tonumber(Y)
    else
        return { X = self.X, Y = self.Y }
    end
end

---Sets the size of the sprite
---@param Width number?
---@param Height number?
function Sprite:Size(Width, Height)
    if tonumber(Width) and tonumber(Width) then
        self.Width = tonumber(Width)
        self.Height = tonumber(Height)
    else
        return { Width = self.Width, Height = self.Height }
    end
end

---Sets the Colour of the sprite
---@param R number?
---@param G number?
---@param B number?
---@param A number?
function Sprite:Colour(R, G, B, A)
    if tonumber(R) or tonumber(G) or tonumber(B) or tonumber(A) then
        self._Colour.R = tonumber(R) or 255
        self._Colour.B = tonumber(B) or 255
        self._Colour.G = tonumber(G) or 255
        self._Colour.A = tonumber(A) or 255
    else
        return self._Colour
    end
end

---Draws the sprite to the screen
function Sprite:Draw()
    if not HasStreamedTextureDictLoaded(self.TxtDictionary) then
        RequestStreamedTextureDict(self.TxtDictionary, true)
    end
    local Position = self:Position()
    local Size = self:Size()
    Size.Width, Size.Height = FormatXWYH(Size.Width, Size.Height)
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)
    DrawSprite(self.TxtDictionary, self.TxtName, Position.X + Size.Width * 0.5, Position.Y + Size.Height * 0.5,
        Size.Width, Size.Height, self.Heading, self._Colour.R, self._Colour.G, self._Colour.B, self._Colour.A)
end
TimerBarPool = setmetatable({}, TimerBarPool)
TimerBarPool.__index = TimerBarPool

function TimerBarPool.New()
    local _data = {
        Bars = {}
    }
    return setmetatable(_data, TimerBarPool)
end

function TimerBarPool:AddBar(timerBar)
    timerBar.Handle = #self.Bars + 1;
    self.Bars[timerBar.Handle] = timerBar
end

function TimerBarPool:RemoveBar(timerBar)
    table.remove(self.Bars, timerBar.Handle)
end

function TimerBarPool:Draw()
    local offset = 0
    if ScaleformUI.Scaleforms.InstructionalButtons:Enabled() or ScaleformUI.Scaleforms.InstructionalButtons.IsSaving then
        offset = 9
    end
    for k, v in pairs(self.Bars) do
        v:Draw((k * 10) + offset)
    end
end
UIResRectangle = setmetatable({}, UIResRectangle)
UIResRectangle.__index = UIResRectangle
UIResRectangle.__call = function() return "Rectangle" end

---New
---@param X number|0
---@param Y number|0
---@param Width number|0
---@param Height number|0
---@param R number|255
---@param G number|255
---@param B number|255
---@param A number|255
function UIResRectangle.New(X, Y, Width, Height, R, G, B, A)
    local _UIResRectangle = {
        X = tonumber(X) or 0,
        Y = tonumber(Y) or 0,
        Width = tonumber(Width) or 0,
        Height = tonumber(Height) or 0,
        _Colour = { R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255 },
    }
    return setmetatable(_UIResRectangle, UIResRectangle)
end

---Position
---@param X number?
---@param Y number?
function UIResRectangle:Position(X, Y)
    if tonumber(X) and tonumber(Y) then
        self.X = tonumber(X)
        self.Y = tonumber(Y)
    else
        return { X = self.X, Y = self.Y }
    end
end

---Size
---@param Width number?
---@param Height number?
function UIResRectangle:Size(Width, Height)
    if tonumber(Width) and tonumber(Height) then
        self.Width = tonumber(Width)
        self.Height = tonumber(Height)
    else
        return { Width = self.Width, Height = self.Height }
    end
end

---Colour
---@param R number?
---@param G number?
---@param B number?
---@param A number?
function UIResRectangle:Colour(R, G, B, A)
    if tonumber(R) or tonumber(G) or tonumber(B) or tonumber(A) then
        self._Colour.R = tonumber(R) or 255
        self._Colour.B = tonumber(B) or 255
        self._Colour.G = tonumber(G) or 255
        self._Colour.A = tonumber(A) or 255
    else
        return self._Colour
    end
end

---Draw
function UIResRectangle:Draw()
    local Position = self:Position()
    local Size = self:Size()
    Size.Width, Size.Height = FormatXWYH(Size.Width, Size.Height)
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)
    DrawRect(Position.X + Size.Width * 0.5, Position.Y + Size.Height * 0.5, Size.Width, Size.Height, self._Colour.R,
        self._Colour.G, self._Colour.B, self._Colour.A)
end
UIResText = setmetatable({}, UIResText)
UIResText.__index = UIResText
UIResText.__call = function() return "Text" end

---GetCharacterCount
---@param str string
function GetCharacterCount(str)
    local characters = 0
    for c in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local a = c:byte(1, -1)
        if a ~= nil then
            characters = characters + 1
        end
    end
    return characters
end

---GetByteCount
---@param str string
function GetByteCount(str)
    local bytes = 0

    for c in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local a, b, c, d = c:byte(1, -1)
        if a ~= nil then
            bytes = bytes + 1
        end
        if b ~= nil then
            bytes = bytes + 1
        end
        if c ~= nil then
            bytes = bytes + 1
        end
        if d ~= nil then
            bytes = bytes + 1
        end
    end
    return bytes
end

---AddLongStringForAscii
---@param str string
function AddLongStringForAscii(str)
    local maxbytelength = 99
    for i = 0, GetCharacterCount(str), 99 do
        AddTextComponentSubstringPlayerName(string.sub(str, i, math.min(maxbytelength, GetCharacterCount(str) - i))) --needs changed
    end
end

---AddLongStringForUtf8
---@param str string
function AddLongStringForUtf8(str)
    local maxbytelength = 99
    local bytecount = GetByteCount(str)

    if bytecount < maxbytelength then
        AddTextComponentSubstringPlayerName(str)
        return
    end
    local startIndex = 0
    for i = 0, GetCharacterCount(str), 1 do
        local length = i - startIndex
        if GetByteCount(string.sub(str, startIndex, length)) > maxbytelength then
            AddTextComponentSubstringPlayerName(string.sub(str, startIndex, length - 1))
            i = i - 1
            startIndex = startIndex + (length - 1)
        end
    end
    AddTextComponentSubstringPlayerName(string.sub(str, startIndex, GetCharacterCount(str) - startIndex))
end

---AddLongString
---@param str string
function AddLongString(str)
    local bytecount = GetByteCount(str)
    if bytecount == GetCharacterCount(str) then
        AddLongStringForAscii(str)
    else
        AddLongStringForUtf8(str)
    end
end

---MeasureStringWidthNoConvert
---@param str string
---@param font number
---@param scale number
function MeasureStringWidthNoConvert(str, font, scale)
    BeginTextCommandGetWidth("STRING")
    AddLongString(str)
    SetTextFont(font or 0)
    SetTextScale(1.0, scale or 0)
    return EndTextCommandGetWidth(true)
end

---MeasureStringWidth
---@param str string
---@param font number
---@param scale number
function MeasureStringWidth(str, font, scale)
    return MeasureStringWidthNoConvert(str, font, scale) * 1920
end

---New
---@param Text string
---@param X number|0
---@param Y number|0
---@param Scale number|0
---@param R number|255
---@param G number|255
---@param B number|255
---@param A number|255
---@param Font number|0
---@param Alignment number?
---@param DropShadow number?
---@param Outline number?
---@param WordWrap number|0
function UIResText.New(Text, X, Y, Scale, R, G, B, A, Font, Alignment, DropShadow, Outline, WordWrap)
    local _UIResText = {
        _Text = tostring(Text) or "",
        X = tonumber(X) or 0,
        Y = tonumber(Y) or 0,
        Scale = tonumber(Scale) or 0,
        _Colour = { R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255 },
        Font = tonumber(Font) or 0,
        Alignment = Alignment or nil,
        DropShadow = DropShadow or nil,
        Outline = Outline or nil,
        WordWrap = tonumber(WordWrap) or 0,
    }
    return setmetatable(_UIResText, UIResText)
end

---Position
---@param X number?
---@param Y number?
function UIResText:Position(X, Y)
    if tonumber(X) and tonumber(Y) then
        self.X = tonumber(X)
        self.Y = tonumber(Y)
    else
        return { X = self.X, Y = self.Y }
    end
end

---Colour
---@param R number?
---@param G number?
---@param B number?
---@param A number?
function UIResText:Colour(R, G, B, A)
    if tonumber(R) and tonumber(G) and tonumber(B) and tonumber(A) then
        self._Colour.R = tonumber(R)
        self._Colour.B = tonumber(B)
        self._Colour.G = tonumber(G)
        self._Colour.A = tonumber(A)
    else
        return self._Colour
    end
end

---Text
---@param Text string
function UIResText:Text(Text)
    if tostring(Text) and Text ~= nil then
        self._Text = tostring(Text)
    else
        return self._Text
    end
end

---Draw
function UIResText:Draw()
    local Position = self:Position()
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)

    SetTextFont(self.Font)
    SetTextScale(1.0, self.Scale)
    SetTextColour(self._Colour.R, self._Colour.G, self._Colour.B, self._Colour.A)

    if self.DropShadow then
        SetTextDropShadow()
    end
    if self.Outline then
        SetTextOutline()
    end

    if self.Alignment ~= nil then
        if self.Alignment == 1 or self.Alignment == "Center" or self.Alignment == "Centre" then
            SetTextCentre(true)
        elseif self.Alignment == 2 or self.Alignment == "Right" then
            SetTextRightJustify(true)
            SetTextWrap(0, Position.X)
        end
    end


    if tonumber(self.WordWrap) then
        if tonumber(self.WordWrap) ~= 0 then
            local Width, Height = GetScreenResolution()
            SetTextWrap(Position.X, Position.X + (tonumber(self.WordWrap) / Width))
        end
    end

    BeginTextCommandDisplayText("STRING")
    AddLongString(self._Text)
    EndTextCommandDisplayText(Position.X, Position.Y)
end
-- Globals
GlobalGameTimer = GetGameTimer() --[[@type number]] -- GlobalGameTimer is used in many places, so we'll just define it here.

--Update GlobalGameTimer every 100ms, so we don't have to call GetGameTimer() every time we need it.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        GlobalGameTimer = GetGameTimer()
    end
end)

---starts
---@param Str string
---@param Start string
---@return boolean
function string.starts(Str, Start)
    return string.sub(Str, 1, string.len(Start)) == Start
end

---StartsWith
---@param self string
---@param str string
---@return boolean
string.StartsWith = function(self, str)
    return self:find('^' .. str) ~= nil
end

---IsNullOrEmpty
---@param self string
---@return boolean
string.IsNullOrEmpty = function(self)
    return self == nil or self == '' or not not tostring(self):find("^%s*$")
end

---Insert
---@param self string
---@param pos number
---@param str2 string
string.Insert = function(self, pos, str2)
    return self:sub(1, pos) .. str2 .. self:sub(pos + 1)
end

-- Return the first index with the given value (or -1 if not found).
function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return -1
end

-- Return a key with the given value (or nil if not found).  If there are
-- multiple keys with that value, the particular key returned is arbitrary.
function KeyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

function math.round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function ToBool(input)
    if input == "true" or tonumber(input) == 1 or input == true then
        return true
    else
        return false
    end
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t, i = {}, 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

function Split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            Table[#Table + 1] = cap
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        Table[#Table + 1] = cap
    end
    return Table
end

function ResolutionMaintainRatio()
    local screenw, screenh = GetActiveScreenResolution()
    local ratio = screenw / screenh
    local width = 1080 * ratio
    return width, 1080
end

function SafezoneBounds()
    local t = GetSafeZoneSize();
    local g = math.round(t, 2);
    g = (g * 100) - 90;
    g = 10 - g;

    local screenw = 720 * GetAspectRatio(false)
    local screenh = 720
    local ratio = screenw / screenh;
    local wmp = ratio * 5.4

    return math.round(g * wmp), math.round(g * 5.4)
end

function FormatXWYH(Value, Value2)
    local w, h = ResolutionMaintainRatio()
    return Value / w, Value2 / h
end

---Returns the magnitude of the vector.
---@param vector vector3 -- The vector to get the magnitude of.
---@return number
function GetVectorMagnitude(vector)
    return Sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
end

---Returns true if the vector is inside the sphere, false otherwise.
---@param vector vector3 -- The vector to check.
---@param position vector3 -- The position of the sphere.
---@param scale vector3 -- The scale of the sphere.
---@return boolean
function IsVectorInsideSphere(vector, position, scale)
    local distance = (vector - position)
    local radius = GetVectorMagnitude(scale) / 2
    return GetVectorMagnitude(distance) <= radius
end
UIMenuDetailsWindow = setmetatable({}, UIMenuDetailsWindow)
UIMenuDetailsWindow.__index = UIMenuDetailsWindow
UIMenuDetailsWindow.__call = function() return "UIMenuWindow", "UIMenuDetailsWindow" end

--- TODO: Refactor method arguments so they can be documented better
---New
function UIMenuDetailsWindow.New(...)
    local args = { ... }

    if #args == 3 or #args == 4 then
        _UIMenuDetailsWindow = {
            id = 1,
            DetailTop = args[1],
            DetailMid = args[2],
            DetailBottom = args[3],
            StatWheelEnabled = false,
            DetailLeft = args[4] or {
                Txd = "",
                Txn = "",
                Pos = vector2(0, 0),
                Size = vector2(0, 0),
            },
            ParentMenu = nil, -- required
        }
    elseif #args == 5 then
        _UIMenuDetailsWindow = {
            id = 1,
            DetailTop = args[1],
            DetailMid = args[2],
            DetailBottom = args[3],
            StatWheelEnabled = args[4],
            DetailStats = args[5],
            DetailLeft = {
                Txd = "statWheel",
                Txn = "",
                Pos = vector2(0, 0),
                Size = vector2(0, 0),
            },
            ParentMenu = nil, -- required
        }
    end
    return setmetatable(_UIMenuDetailsWindow, UIMenuDetailsWindow)
end

---SetParentMenu
---@param Menu table
function UIMenuDetailsWindow:SetParentMenu(Menu) -- required
    if Menu() == "UIMenu" then
        self.ParentMenu = Menu
    else
        return self.ParentMenu
    end
end

function UIMenuDetailsWindow:UpdateLabels(top, mid, bot, leftDetail)
    self.DetailTop = top
    self.DetailMid = mid
    self.DetailBottom = bot
    self.DetailLeft = leftDetail or {
        Txd = "",
        Txn = "",
        Pos = vector2(0, 0),
        Size = vector2(0, 0),
    }

    if self.ParentMenu ~= nil then
        local wid = IndexOf(self.ParentMenu.Windows, self) - 1
        if self.StatWheelEnabled then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_DETAILS_WINDOW_VALUES", false, wid, self.DetailBottom,
                self.DetailMid, self.DetailTop, "statWheel")
        else
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_DETAILS_WINDOW_VALUES", false, wid, self.DetailBottom,
                self.DetailMid, self.DetailTop, self.DetailLeft.Txd, self.DetailLeft.Txn, self.DetailLeft.Pos.x,
                self.DetailLeft.Pos.y, self.DetailLeft.Size.x, self.DetailLeft.Size.y)
        end
    end
end

function UIMenuDetailsWindow:AddStatsListToWheel(stats)
    if self.StatWheelEnabled then
        self.DetailStats = stats
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            for key, value in pairs(self.DetailStats) do
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false, wid,
                    value.Percentage, value.HudColor)
            end
        end
    end
end

function UIMenuDetailsWindow:AddStatSingleToWheel(stat)
    if self.StatWheelEnabled then
        self.DetailStats[#self.DetailStats + 1] = stat
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false, wid, stat.Percentage,
                stat.HudColor)
        end
    end
end

function UIMenuDetailsWindow:UpdateStatsToWheel()
    if self.StatWheelEnabled then
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            for key, value in pairs(self.DetailStats) do
                ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_STATS_DETAILS_WINDOW_STATWHEEL", false, wid, key - 1,
                    value.Percentage, value.HudColor)
            end
        end
    end
end
UIMenuHeritageWindow = setmetatable({}, UIMenuHeritageWindow)
UIMenuHeritageWindow.__index = UIMenuHeritageWindow
UIMenuHeritageWindow.__call = function() return "UIMenuWindow", "UIMenuHeritageWindow" end

---New
---@param Mom number
---@param Dad number
function UIMenuHeritageWindow.New(Mom, Dad)
    if not tonumber(Mom) then Mom = 0 end
    if not (Mom >= 0 and Mom <= 21) then Mom = 0 end
    if not tonumber(Dad) then Dad = 0 end
    if not (Dad >= 0 and Dad <= 23) then Dad = 0 end
    _UIMenuHeritageWindow = {
        id = 0,
        Mom = Mom,
        Dad = Dad,
        ParentMenu = nil, -- required
    }
    return setmetatable(_UIMenuHeritageWindow, UIMenuHeritageWindow)
end

---SetParentMenu
---@param Menu table
function UIMenuHeritageWindow:SetParentMenu(Menu) -- required
    if Menu() == "UIMenu" then
        self.ParentMenu = Menu
    else
        return self.ParentMenu
    end
end

function UIMenuHeritageWindow:Index(Mom, Dad)
    if not tonumber(Mom) then Mom = self.Mom end
    if not tonumber(Dad) then Dad = self.Dad end

    if tonumber(Mom) == -1 then
        Mom = self.Mom
    elseif tonumber(Dad) == -1 then
        Dad = self.Dad
    end

    self.Mom = Mom - 1
    self.Dad = Dad - 1

    local wid = IndexOf(self.ParentMenu.Windows, self) - 1
    ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_HERITAGE_WINDOW", false, wid, self.Mom, self.Dad)
end
