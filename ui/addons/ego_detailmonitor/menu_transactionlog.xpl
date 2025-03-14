﻿-- param == { 0, 0, container }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	bool IsComponentOperational(UniverseID componentid);
	bool IsMouseEmulationActive(void);
	bool IsRealComponentClass(UniverseID componentid, const char* classname);
]]

local menu = {
	name = "TransactionLogMenu",
	lastRefreshTime = 0,
}

local config = {
	infoLayer = 4,
	contextLayer = 2,
	mouseOutRange = 100,
}

-- kuertee start:
menu.uix_callbacks = {}
-- kuertee end

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end

	-- kuertee start:
	menu.init_kuertee()
	-- kuertee end
end

-- kuertee start:
function menu.init_kuertee ()
end
-- kuertee end

function menu.cleanup()
	menu.infoFrame = nil
	menu.sidebar = nil

	-- start: kuertee call-back
	if menu.uix_callbacks ["cleanup"] then
		for uix_id, uix_callback in pairs (menu.uix_callbacks ["cleanup"]) do
			uix_callback ()
		end
	end
	-- end: kuertee call-back
end

-- widget scripts

function menu.buttonRightBar(newmenu, params)
	Helper.closeMenuAndOpenNewMenu(menu, newmenu, params, true)
	menu.cleanup()
end

function menu.buttonContainerInfo(controllable)
	Helper.closeMenuAndOpenNewMenu(menu, "MapMenu", { 0, 0, true, nil, nil, "infomode", { "info", controllable } })
	menu.cleanup()
end

function menu.buttonTransactionLog(controllable)
	Helper.closeMenuAndOpenNewMenu(menu, "TransactionLogMenu", { 0, 0, controllable });
	menu.cleanup()
end

-- Menu member functions

function menu.onShowMenu()
	-- Init
	menu.containerid = menu.param[3]
	menu.container = ConvertIDTo64Bit(menu.containerid)

	menu.isstation = C.IsRealComponentClass(menu.container, "station")

	menu.selectedRows = {}

	-- display main frame
	menu.createFrame()
end

function menu.createFrame(toprow, selectedrow)
	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	local frameProperties = {
		layer = config.infoLayer,
		standardButtons = {},
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
		standardButtons = { back = true, close = true, help = true  }
	}
	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	menu.sidebarWidth = Helper.scaleX(Helper.sidebarWidth)

	if menu.isstation then
		local rightbartable = Helper.createRightSideBar(menu.infoFrame, menu.container, true, "transactions", menu.buttonRightBar)
		rightbartable:addConnection(1, 4, true)
	end

	local tableProperties = {
		width = Helper.playerInfoConfig.width * 5 / 4,
		height = Helper.viewHeight - 2 * Helper.frameBorder,
		x = Helper.frameBorder,
		y = Helper.frameBorder,
		x2 = menu.isstation and (menu.sidebarWidth + Helper.borderSize + Helper.frameBorder) or Helper.frameBorder,
	}
	local selection = {}
	if menu.infoTable then
		selection = { toprow = toprow or GetTopRow(menu.infoTable), selectedrow = selectedrow or Helper.currentTableRow[menu.infoTable] }
	end
	Helper.createTransactionLog(menu.infoFrame, menu.container, tableProperties, menu.createFrame, selection)

	-- start: kuertee call-back
	if menu.uix_callbacks ["createFrame_on_create_transaction_log"] then
			for uix_id, uix_callback in pairs (menu.uix_callbacks ["createFrame_on_create_transaction_log"]) do
				uix_callback ()
			end
		end
	-- end: kuertee call-back

	menu.infoFrame:display()
	menu.lastRefreshTime = getElapsedTime()
end

function menu.createContextFrame(data, x, y, width, nomouseout)
	Helper.removeAllWidgetScripts(menu, config.contextLayer)
	PlaySound("ui_positive_click")

	local contextmenuwidth = width or menu.contextMenuWidth

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		width = contextmenuwidth,
		x = x,
		y = 0,
		autoFrameHeight = true,
	})
	menu.contextFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	local ftable = menu.contextFrame:addTable(1, { tabOrder = 4, highlightMode = "off" })
	local entryIdx = Helper.transactionLogData.transactionsByIDUnfiltered[data]
	if entryIdx == nil then
		return
	end
	local entry = Helper.transactionLogData.accountLogUnfiltered[entryIdx]
	local active = (entry.partner ~= 0) and C.IsComponentOperational(entry.partner)

	local row = ftable:addRow(false, { fixed = true })
	local text = TruncateText(entry.partnername, Helper.standardFontBold, Helper.scaleFont(Helper.standardFontBold, Helper.headerRow1FontSize), contextmenuwidth - 2 * Helper.scaleX(Helper.standardButtonWidth))
	row[1]:createText(text, Helper.headerRowCenteredProperties)
	row[1].properties.mouseOverText = entry.partnername

	row = ftable:addRow(true, { fixed = true })
	row[1]:createButton({ active = active, bgColor = active and Color["button_background_default"] or Color["button_background_inactive"] }):setText(ReadText(1001, 2427), { color = active and Color["text_normal"] or Color["text_inactive"] })
	row[1].handlers.onClick = function () return menu.buttonContainerInfo(entry.partner) end

	if active and GetComponentData(ConvertStringTo64Bit(tostring(entry.partner)), "isplayerowned") then
		row = ftable:addRow(true, { fixed = true })
		row[1]:createButton({ active = active, bgColor = active and Color["button_background_default"] or Color["button_background_inactive"] }):setText(ReadText(1001, 7702), { color = active and Color["text_normal"] or Color["text_inactive"] })
		row[1].handlers.onClick = function () return menu.buttonTransactionLog(entry.partner) end
	end

	if menu.contextFrame.properties.x + contextmenuwidth > Helper.viewWidth then
		menu.contextFrame.properties.x = Helper.viewWidth - contextmenuwidth - Helper.frameBorder
	end
	local height = menu.contextFrame:getUsedHeight()
	if y + height > Helper.viewHeight then
		menu.contextFrame.properties.y = Helper.viewHeight - height - Helper.frameBorder
	else
		menu.contextFrame.properties.y = y
	end

	menu.contextFrame:display()

	if not nomouseout then
		menu.mouseOutBox = {
			x1 =   menu.contextFrame.properties.x -  Helper.viewWidth / 2                    - config.mouseOutRange,
			x2 =   menu.contextFrame.properties.x -  Helper.viewWidth / 2 + contextmenuwidth + config.mouseOutRange,
			y1 = - menu.contextFrame.properties.y + Helper.viewHeight / 2                    + config.mouseOutRange,
			y2 = - menu.contextFrame.properties.y + Helper.viewHeight / 2 - height           - config.mouseOutRange
		}
	end
end

function menu.viewCreated(layer, ...)
	if menu.isstation then
		menu.sidebar, menu.infoTable = ...
	else
		menu.infoTable = ...
	end
end

-- update
menu.updateInterval = 0.1

function menu.onUpdate()
	Helper.onTransactionLogUpdate()

	-- kuertee start: in case onUpdate is called without the menu being opened. i.e. from kuertee_trade_analytics mod.
	if not menu.infoFrame then
		return
	end
	-- kuertee end: in case onUpdate is called without the menu being opened. i.e. from kuertee_trade_analytics mod.

	menu.infoFrame:update()

	if not Helper.transactionLogData.noupdate then
		local curtime = getElapsedTime()
		if curtime > menu.lastRefreshTime + 10 then
			menu.createFrame()
		end
	end

	if menu.mouseOutBox then
		if (GetControllerInfo() ~= "gamepad") or (C.IsMouseEmulationActive()) then
			local curpos = table.pack(GetLocalMousePosition())
			if curpos[1] and ((curpos[1] < menu.mouseOutBox.x1) or (curpos[1] > menu.mouseOutBox.x2)) then
				menu.closeContextMenu()
			elseif curpos[2] and ((curpos[2] > menu.mouseOutBox.y1) or (curpos[2] < menu.mouseOutBox.y2)) then
				menu.closeContextMenu()
			end
		end
	end
end

function menu.onRowChanged(row, rowdata, uitable)
	if uitable == menu.infoTable then
		Helper.onTransactionLogRowChanged(rowdata)
	end
end

function menu.onSelectElement(uitable, modified, row)
end

function menu.onEditBoxActivated(widget)
	Helper.onTransactionLogEditBoxActivated(widget)
end

function menu.onTableRightMouseClick(uitable, row, posx, posy)
	if uitable == menu.infoTable then
		local rowdata = menu.rowDataMap[uitable] and menu.rowDataMap[uitable][row]

		local entryIdx = Helper.transactionLogData.transactionsByIDUnfiltered[rowdata]
		if entryIdx == nil then
			return
		end
		local entry = Helper.transactionLogData.accountLogUnfiltered[entryIdx]
		if entry.partnername ~= "" then
			local x, y = GetLocalMousePosition()
			if x == nil then
				-- gamepad case
				x = posx
				y = -posy
			end
			menu.contextMenuMode = "transactionlog"
			menu.createContextFrame(rowdata, x + Helper.viewWidth / 2, Helper.viewHeight / 2 - y, Helper.scaleX(260))
		end
	end
end

function menu.closeContextMenu()
	Helper.clearFrame(menu, config.contextLayer)
	menu.contextMenuMode = nil
	menu.mouseOutBox = nil
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "back" then
		if menu.contextMenuMode then
			menu.closeContextMenu()
			return
		end

		if Helper.checkDiscardStationEditorChanges(menu) then
			return
		end
	end

	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

-- kuertee start:
menu.uix_callbackCount = 0
function menu.registerCallback(callbackName, callbackFunction, id)
    -- note 1: format is generally [function name]_[action]. e.g.: in kuertee_menu_transporter, "display_on_set_room_active" overrides the room's active property with the return of the callback.
    -- note 2: events have the word "_on_" followed by a PRESENT TENSE verb. e.g.: in kuertee_menu_transporter, "display_on_set_buttontable" is called after all of the rows of buttontable are set.
    -- note 3: new callbacks can be added or existing callbacks can be edited. but commit your additions/changes to the mod's GIT repository.
    -- note 4: search for the callback names to see where they are executed.
    -- note 5: if a callback requires a return value, return it in an object var. e.g. "display_on_set_room_active" requires a return of {active = true | false}.
    if menu.uix_callbacks [callbackName] == nil then
        menu.uix_callbacks [callbackName] = {}
    end
    if not menu.uix_callbacks[callbackName][id] then
        if not id then
            menu.uix_callbackCount = menu.uix_callbackCount + 1
            id = "_" .. tostring(menu.uix_callbackCount)
        end
        menu.uix_callbacks[callbackName][id] = callbackFunction
        if Helper.isDebugCallbacks then
            Helper.debugText_forced(menu.name .. " uix registerCallback: menu.uix_callbacks[" .. tostring(callbackName) .. "][" .. tostring(id) .. "]: " .. tostring(menu.uix_callbacks[callbackName][id]))
        end
    else
        Helper.debugText_forced(menu.name .. " uix registerCallback: callback at " .. callbackName .. " with id " .. tostring(id) .. " was already previously registered")
    end
end

menu.uix_isDeregisterQueued = nil
menu.uix_callbacks_toDeregister = {}
function menu.deregisterCallback(callbackName, callbackFunction, id)
    if not menu.uix_callbacks_toDeregister[callbackName] then
        menu.uix_callbacks_toDeregister[callbackName] = {}
    end
    if id then
        table.insert(menu.uix_callbacks_toDeregister[callbackName], id)
    else
        if menu.uix_callbacks[callbackName] then
            for id, func in pairs(menu.uix_callbacks[callbackName]) do
                if func == callbackFunction then
                    table.insert(menu.uix_callbacks_toDeregister[callbackName], id)
                end
            end
        end
    end
    if not menu.uix_isDeregisterQueued then
        menu.uix_isDeregisterQueued = true
        Helper.addDelayedOneTimeCallbackOnUpdate(menu.deregisterCallbacksNow, true, getElapsedTime() + 1)
    end
end

function menu.deregisterCallbacksNow()
    menu.uix_isDeregisterQueued = nil
    for callbackName, ids in pairs(menu.uix_callbacks_toDeregister) do
        if menu.uix_callbacks[callbackName] then
            for _, id in ipairs(ids) do
                if menu.uix_callbacks[callbackName][id] then
                    if Helper.isDebugCallbacks then
                        Helper.debugText_forced(menu.name .. " uix deregisterCallbacksNow (pre): menu.uix_callbacks[" .. tostring(callbackName) .. "][" .. tostring(id) .. "]: " .. tostring(menu.uix_callbacks[callbackName][id]))
                    end
                    menu.uix_callbacks[callbackName][id] = nil
                    if Helper.isDebugCallbacks then
                        Helper.debugText_forced(menu.name .. " uix deregisterCallbacksNow (post): menu.uix_callbacks[" .. tostring(callbackName) .. "][" .. tostring(id) .. "]: " .. tostring(menu.uix_callbacks[callbackName][id]))
                    end
                else
                    Helper.debugText_forced(menu.name .. " uix deregisterCallbacksNow: callback at " .. callbackName .. " with id " .. tostring(id) .. " doesn't exist")
                end
            end
        end
    end
    menu.uix_callbacks_toDeregister = {}
end

menu.uix_isUpdateQueued = nil
menu.uix_callbacks_toUpdate = {}
function menu.updateCallback(callbackName, id, callbackFunction)
    if not menu.uix_callbacks_toUpdate[callbackName] then
        menu.uix_callbacks_toUpdate[callbackName] = {}
    end
    if id then
        table.insert(menu.uix_callbacks_toUpdate[callbackName], {id = id, callbackFunction = callbackFunction})
    end
    if not menu.uix_isUpdateQueued then
        menu.uix_isUpdateQueued = true
        Helper.addDelayedOneTimeCallbackOnUpdate(menu.updateCallbacksNow, true, getElapsedTime() + 1)
    end
end

function menu.updateCallbacksNow()
    menu.uix_isUpdateQueued = nil
    for callbackName, updateDatas in pairs(menu.uix_callbacks_toUpdate) do
        if menu.uix_callbacks[callbackName] then
            for _, updateData in ipairs(updateDatas) do
                if menu.uix_callbacks[callbackName][updateData.id] then
                    if Helper.isDebugCallbacks then
                        Helper.debugText_forced(menu.name .. " uix updateCallbacksNow (pre): menu.uix_callbacks[" .. tostring(callbackName) .. "][" .. tostring(updateData.id) .. "]: " .. tostring(menu.uix_callbacks[callbackName][updateData.id]))
                    end
                    menu.uix_callbacks[callbackName][updateData.id] = updateData.callbackFunction
                    if Helper.isDebugCallbacks then
                        Helper.debugText_forced(menu.name .. " uix updateCallbacksNow (post): menu.uix_callbacks[" .. tostring(callbackName) .. "][" .. tostring(updateData.id) .. "]: " .. tostring(menu.uix_callbacks[callbackName][updateData.id]))
                    end
                else
                    Helper.debugText_forced(menu.name .. " uix updateCallbacksNow: callback at " .. callbackName .. " with id " .. tostring(id) .. " doesn't exist")
                end
            end
        end
    end
end
-- kuertee end

init()
