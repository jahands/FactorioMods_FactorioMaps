
if not fm.gui then error("Hey silly. don't include this directly!") end

function fm.gui.registerAllHandlers()
    Gui.on_click("FactorioMaps_mainButton", fm.gui.actions.MainButton)
    Gui.on_click("FactorioMaps_advancedButton", fm.gui.actions.advancedButton)
    Gui.on_click("FactorioMaps_maxSize", fm.gui.actions.maxSize)
    Gui.on_click("FactorioMaps_baseSize", fm.gui.actions.baseSize)
    Gui.on_click("FactorioMaps_generate", fm.gui.actions.generate)
    Gui.on_click("FactorioMaps_topLeftView", fm.gui.actions.topLeftView)
    Gui.on_click("FactorioMaps_viewReturn", fm.gui.actions.viewReturn)
    Gui.on_click("FactorioMaps_topLeftPlayer", fm.gui.actions.topLeftPlayer)
    Gui.on_click("FactorioMaps_bottomRightView", fm.gui.actions.bottomRightView)
    Gui.on_click("FactorioMaps_bottomRightPlayer", fm.gui.actions.bottomRightPlayer)

    Gui.on_checked_state_changed("FactorioMaps_dayOnly", fm.gui.actions.dayOnly)
    Gui.on_checked_state_changed("FactorioMaps_altInfo", fm.gui.actions.altInfo)
    Gui.on_checked_state_changed("FactorioMaps_customSize", fm.gui.actions.customSize)
    Gui.on_checked_state_changed("FactorioMaps_radio_mapQuality_", fm.gui.actions.mapQualityRadio)
    Gui.on_checked_state_changed("FactorioMaps_radio_extension_", fm.gui.actions.extensionRadio)

    Gui.on_text_changed("FactorioMaps_folderName", fm.gui.actions.folderName)
    Gui.on_text_changed("FactorioMaps_topLeftX", fm.gui.actions.topLeftX)
    Gui.on_text_changed("FactorioMaps_topLeftY", fm.gui.actions.topLeftY)
    Gui.on_text_changed("FactorioMaps_bottomRightX", fm.gui.actions.bottomRightX)
    Gui.on_text_changed("FactorioMaps_bottomRightY", fm.gui.actions.bottomRightY)
end

function fm.gui.updateCoords()
    for index, player in pairs(game.players) do
        if player.valid and player.connected then
            local rightPane = fm.gui.getRightPane(player.index);
            if (rightPane and rightPane.label_currentPlayerCoords) then
                local x = math.floor(player.position.x);
                local y = math.floor(player.position.y);
                rightPane.label_currentPlayerCoords.caption = {"label-current-player-coords", player.surface.name, x, y};
            end
        end
    end
end

fm.gui.actions = {};

--------------------------------
-- MAIN WINDOW BUTTON
--------------------------------
function fm.gui.actions.MainButton(event)
    if (fm.gui.getMainWindow(event.player_index)) then
        fm.gui.hideMainWindow(event.player_index);
    else
        fm.gui.showMainWindow(event.player_index);
    end
end

--------------------------------
-- RADIO BUTTON SIMULATOR!
--------------------------------
fm.gui.radio = {};

function fm.gui.radio.selector(event)
    local function split(inputstr, seperator)
        if sep == nil then
                sep = "%s";
        end
        local t={} ;
        local i=1;
        for str in string.gmatch(inputstr, "([^" .. seperator .. "]+)") do
                t[i] = str;
                i = i + 1;
        end
        return t;
    end
    local tmp = split(event.element.name, "_");
    local radio = tmp[#tmp-1];
    local number = tonumber(tmp[#tmp]);

    for index, element in pairs(global._radios[radio]) do
        if (element.valid) then
            if (index == number) then
                element.state = true;
            else
                element.state = false;
            end
        else
            global._radios[radio][index] = nil;
        end
    end
    return number;
end

function fm.gui.radio.mapQualitySelect(thisOne)
    for index, element in pairs(global._radios.mapQuality) do
        if (index == thisOne) then
            fm.gui.radio.selector({element = element});
        end
    end
end

function fm.gui.radio.extensionSelect(thisOne)
    for index, element in pairs(global._radios.extension) do
        if (index == thisOne) then
            fm.gui.radio.selector({element = element});
        end
    end
end

--------------------------------
-- MAIN WINDOW LEFT PANE
--------------------------------
function fm.gui.actions.dayOnly(event)
    Game.print_all("dayOnly is " .. tostring(event.state));
    global.config.dayOnly = event.state;
end

function fm.gui.actions.altInfo(event)
    Game.print_all("altInfo is " .. tostring(event.state));
    global.config.altInfo = event.state;
end

function fm.gui.actions.advancedButton(event)
    if (fm.gui.getRightPane(event.player_index)) then
        fm.gui.hideRightPane(event.player_index);
    else
        fm.gui.showRightPane(event.player_index);
    end
end

function fm.gui.actions.folderName(event)
    if string.is_empty(event.text) then
        return;
    end

    global.config.folderName = event.text;
    Game.print_all("Using folder name of [" .. event.text .. "]");
end

function fm.gui.actions.maxSize(event)
    Game.print_all("Map set to whole world");
end

function fm.gui.actions.baseSize(event)
    Game.print_all("Cropping map to base Size");
end

function fm.gui.actions.generate(event)
    Game.print_all("Generating your map");
end

--------------------------------
-- MAIN WINDOW RIGHT PANE (ADVANCED SETTINGS)
--------------------------------
function fm.gui.actions.customSize(event)
    Game.print_all("customSize is " .. tostring(event.state));
    global.config.customSize = event.state;
end

function fm.gui.actions.topLeftX(event)
    if string.is_empty(event.text) then
        return;
    end

    global.config.topLeftX = event.text;
    Game.print_all("Using topLeftX of [" .. event.text .. "]");
end

function fm.gui.actions.topLeftY(event)
    if string.is_empty(event.text) then
        return;
    end

    global.config.topLeftY = event.text;
    Game.print_all("Using topLeftY of [" .. event.text .. "]");
end

function fm.gui.actions.bottomRightX(event)
    if string.is_empty(event.text) then
        return;
    end

    global.config.bottomRightX = event.text;
    Game.print_all("Using bottomRightX of [" .. event.text .. "]");
end

function fm.gui.actions.bottomRightY(event)
    if string.is_empty(event.text) then
        return;
    end

    global.config.bottomRightY = event.text;
    Game.print_all("Using bottomRightY of [" .. event.text .. "]");
end

function fm.gui.actions.mapQualityRadio(event)
    local num = fm.gui.radio.selector(event)
    global.config.mapQuality = num;
end

function fm.gui.actions.extensionRadio(event)
    local num = fm.gui.radio.selector(event)
    global.config.extension = num;
end

function fm.gui.actions.viewReturn(event)
    Game.print_all("Using viewReturn clicked");
end

function fm.gui.actions.topLeftView(event)
    Game.print_all("Using topLeftView clicked");
end

function fm.gui.actions.topLeftPlayer(event)
    Game.print_all("Using topLeftPlayer clicked");
end

function fm.gui.actions.bottomRightView(event)
    Game.print_all("Using bottomRightView clicked");
end

function fm.gui.actions.bottomRightPlayer(event)
    Game.print_all("Using bottomRightPlayer clicked");
end