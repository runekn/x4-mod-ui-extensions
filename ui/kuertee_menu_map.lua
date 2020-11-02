﻿local ffi = require ("ffi")
local C = ffi.C
local Lib = require ("extensions.sn_mod_support_apis.lua_library")
local mapMenu
local oldFuncs = {}
local newFuncs = {}
local callbacks = {}
local isInited
local function init ()
	DebugError ("kuertee_menu_map.init")
	if not isInited then
		isInited = true
		mapMenu = Lib.Get_Egosoft_Menu ("MapMenu")
		mapMenu.registerCallback = newFuncs.registerCallback
		oldFuncs.createInfoFrame = mapMenu.createInfoFrame
		mapMenu.createInfoFrame = newFuncs.createInfoFrame
		oldFuncs.refreshInfoFrame = mapMenu.refreshInfoFrame
		mapMenu.refreshInfoFrame = newFuncs.refreshInfoFrame
		oldFuncs.createPropertyOwned = mapMenu.createPropertyOwned
		mapMenu.createPropertyOwned = newFuncs.createPropertyOwned
		oldFuncs.createPropertyRow = mapMenu.createPropertyRow
		mapMenu.createPropertyRow = newFuncs.createPropertyRow
		oldFuncs.createSideBar = mapMenu.createSideBar
		mapMenu.createSideBar = newFuncs.createSideBar
		oldFuncs.onRowChanged = mapMenu.onRowChanged
		mapMenu.onRowChanged = newFuncs.onRowChanged
		oldFuncs.onSelectElement = mapMenu.onSelectElement
		mapMenu.onSelectElement = newFuncs.onSelectElement
		oldFuncs.onRenderTargetSelect = mapMenu.onRenderTargetSelect
		mapMenu.onRenderTargetSelect = newFuncs.onRenderTargetSelect
		oldFuncs.onTableRightMouseClick = mapMenu.onTableRightMouseClick
		mapMenu.onTableRightMouseClick = newFuncs.onTableRightMouseClick
		oldFuncs.onInteractiveElementChanged = mapMenu.onInteractiveElementChanged
		mapMenu.onInteractiveElementChanged = newFuncs.onInteractiveElementChanged
		oldFuncs.closeContextMenu = mapMenu.closeContextMenu
		mapMenu.closeContextMenu = newFuncs.closeContextMenu
		oldFuncs.updateSelectedComponents = mapMenu.updateSelectedComponents
		mapMenu.updateSelectedComponents = newFuncs.updateSelectedComponents
		oldFuncs.updateTableSelection = mapMenu.updateTableSelection
		mapMenu.updateTableSelection = newFuncs.updateTableSelection
	end
end
function newFuncs.registerCallback (callbackName, callbackFunction)
	-- DebugError ("kuertee_menu_transporter.registerCallback " .. tostring (callbackName) .. " " .. tostring (callbackFunction))
	-- note 1: format is generally [function name]_[action]. e.g.: in kuertee_menu_transporter, "display_on_set_room_active" overrides the room's active property with the return of the callback.
	-- note 2: events have the word "_on_" followed by a PRESENT TENSE verb. e.g.: in kuertee_menu_transporter, "display_on_set_buttontable" is called after all of the rows of buttontable are set.
	-- note 3: new callbacks can be added or existing callbacks can be edited. but commit your additions/changes to the mod's GIT repository.
	-- note 4: search for the callback names to see where they are executed.
	-- note 5: if a callback requires a return value, return it in an object var. e.g. "display_on_set_room_active" requires a return of {active = true | false}.
	-- available callbacks:
	-- (true | false) = createInfoFrame_on_menu_infoTableMode (menu.infoFrame)
	-- createPropertyOwned_on_start (config)
	-- createPropertyOwned_on_init_infoTableData (infoTableData)
	-- createPropertyOwned_on_add_ship_infoTableData (infoTableData, object)
	-- createPropertyOwned_on_add_other_objects_infoTableData (infoTableData)
	-- {numdisplayed = numdisplayed} = createPropertyOwned_on_createPropertySection_unassignedships (numdisplayed, instance, ftable, infoTableData)
	-- {maxicons = maxicons, subordinates = subordinates, dockedships = dockedships, constructions = constructions, convertedComponent = convertedComponent} = createPropertyRow_on_init_vars (maxicons, subordinates, dockedships, constructions, convertedComponent)
	-- {locationtext = locationtext} = createPropertyRow_on_set_locationtext (locationtext, component)
	-- {shipname = shipname, properties = createTextProperties} = createPropertyRow_override_row_shipname_createText (shipname, createTextProperties, component)
	-- {locationtext = locationtext, properties = createTextProperties} = createPropertyRow_override_row_location_createText (locationtext, createTextProperties, component)
	-- createSideBar_on_start (config)
	if callbacks [callbackName] == nil then
		callbacks [callbackName] = {}
	end
	table.insert (callbacks [callbackName], callbackFunction)
end
-- only have config stuff here that are used in this file
local config = {
	infoFrameLayer = 4,
	contextFrameLayer = 3,

	leftBar = {
		{ name = ReadText(1001, 3224),	icon = "mapst_objectlist",			mode = "objectlist",	helpOverlayID = "map_sidebar_objectlist",			helpOverlayText = ReadText(1028, 3201) },
		{ name = ReadText(1001, 1000),	icon = "mapst_propertyowned",		mode = "propertyowned",	helpOverlayID = "map_sidebar_propertyowned",		helpOverlayText = ReadText(1028, 3203) },
		{ spacing = true },
		{ name = ReadText(1001, 3324),	icon = "mapst_mission_offers",		mode = "missionoffer",	helpOverlayID = "map_sidebar_mission_offers",		helpOverlayText = ReadText(1028, 3205) },
		{ name = ReadText(1001, 3323),	icon = "mapst_mission_accepted",	mode = "mission",		helpOverlayID = "map_sidebar_mission_accepted",		helpOverlayText = ReadText(1028, 3207) },
		{ spacing = true },
		{ name = ReadText(1001, 2427),	icon = "mapst_information",			mode = "info",			helpOverlayID = "map_sidebar_information",			helpOverlayText = ReadText(1028, 3209) },
		{ spacing = true },
		{ name = ReadText(1001, 3226),	icon = "mapst_plotmanagement",		mode = "plots",			helpOverlayID = "map_sidebar_plotmanagement",		helpOverlayText = ReadText(1028, 3211) },
		{ spacing = true,																			condition = IsCheatVersion }, -- (cheats only)
		{ name = "Cheats",				icon = "mapst_cheats",				mode = "cheats",		condition = IsCheatVersion }, -- (cheats only)
	},
	propertyCategories = {
		{ category = "propertyall",                name = ReadText(1001, 8380),    icon = "mapst_propertyowned",        helpOverlayID = "mapst_po_propertyowned",        helpOverlayText = ReadText(1028, 3220) },
		{ category = "stations",                name = ReadText(1001, 8379),    icon = "mapst_ol_stations",            helpOverlayID = "mapst_po_stations",            helpOverlayText = ReadText(1028, 3221) },
		{ category = "fleets",                    name = ReadText(1001, 8326),    icon = "mapst_ol_fleets",            helpOverlayID = "mapst_po_fleets",                helpOverlayText = ReadText(1028, 3223) },
		{ category = "unassignedships",            name = ReadText(1001, 8327),    icon = "mapst_ol_unassigned",        helpOverlayID = "mapst_po_unassigned",            helpOverlayText = ReadText(1028, 3224) },
		{ category = "inventoryships",            name = ReadText(1001, 8381),    icon = "mapst_ol_inventory",        helpOverlayID = "mapst_po_inventory",            helpOverlayText = ReadText(1028, 3225) },
		{ category = "deployables",                name = ReadText(1001, 1332),    icon = "mapst_ol_deployables",        helpOverlayID = "mapst_po_deployables",            helpOverlayText = ReadText(1028, 3226) },
	},

	layersettings = {
		["layer_trade"] = {
			callback = function (value) return C.SetMapRenderTradeOffers(menu.holomap, value) end,
			[1] = {
				caption = ReadText(1001, 46),
				info = ReadText(1001, 3279),
				overrideText = ReadText(1001, 8378),
				type = "multiselectlist",
				id = "trade_wares",
				callback = function (...) return menu.filterTradeWares(...) end,
				listOptions = function (...) return menu.getFilterTradeWaresOptions(...) end,
				displayOption = function (option) return "\27[maptr_supply] " .. GetWareData(option, "name") end,
			},
			[2] = {
				caption = ReadText(1001, 1400),
				type = "checkbox",
				callback = function (...) return menu.filterTradeStorage(...) end,
				[1] = {
					id = "trade_storage_container",
					name = ReadText(20205, 100),
					info = ReadText(1001, 3280),
					param = "container",
				},
				[2] = {
					id = "trade_storage_solid",
					name = ReadText(20205, 200),
					info = ReadText(1001, 3281),
					param = "solid",
				},
				[3] = {
					id = "trade_storage_liquid",
					name = ReadText(20205, 300),
					info = ReadText(1001, 3282),
					param = "liquid",
				},
			},
			[3] = {
				caption = ReadText(1001, 2808),
				type = "slidercell",
				callback = function (...) return menu.filterTradePrice(...) end,
				[1] = {
					id = "trade_price_maxprice",
					name = ReadText(1001, 3284),
					info = ReadText(1001, 3283),
					param = "maxprice",
					scale = {
						min       = 0,
						max       = 5000,
						step      = 1,
						suffix    = ReadText(1001, 101),
						exceedmax = true
					}
				},
			},
			[4] = {
				caption = ReadText(1001, 8357),
				type = "dropdown",
				callback = function (...) return menu.filterTradeVolume(...) end,
				[1] = {
					id = "trade_volume",
					info = ReadText(1001, 8358),
					listOptions = function (...) return menu.getFilterTradeVolumeOptions(...) end,
					param = "volume"
				},
			},
			[5] = {
				caption = ReadText(1001, 11205),
				type = "dropdown",
				callback = function (...) return menu.filterTradePlayerOffer(...) end,
				[1] = {
					id = "trade_playeroffer_buy",
					info = ReadText(1001, 11209),
					listOptions = function (...) return menu.getFilterTradePlayerOfferOptions(true) end,
					param = "playeroffer_buy"
				},
				[2] = {
					id = "trade_playeroffer_sell",
					info = ReadText(1001, 11210),
					listOptions = function (...) return menu.getFilterTradePlayerOfferOptions(false) end,
					param = "playeroffer_sell"
				},
			},
			[6] = {
				caption = ReadText(1001, 11240),
				type = "checkbox",
				callback = function (...) return menu.filterTradeRelation(...) end,
				[1] = {
					id = "trade_relation_enemy",
					name = ReadText(1001, 11241),
					info = ReadText(1001, 11242),
					param = "enemy",
				},
			},
			[7] = {
				caption = ReadText(1001, 8343),
				type = "slidercell",
				callback = function (...) return menu.filterTradeOffer(...) end,
				[1] = {
					id = "trade_offer_number",
					name = ReadText(1001, 8344),
					info = ReadText(1001, 8345),
					param = "number",
					scale = {
						min       = 0,
						minSelect = 1,
						max       = 5,
						step      = 1,
						exceedmax = true,
					}
				},
			},
		},
		["layer_fight"] = {},
		["layer_think"] = {
			callback = function (value) return menu.filterThink(value) end,
			[1] = {
				caption = ReadText(1001, 3285),
				type = "dropdown",
				callback = function (...) return menu.filterThinkAlert(...) end,
				[1] = {
					info = ReadText(1001, 3286),
					id = "think_alert",
					listOptions = function (...) return menu.getFilterThinkAlertOptions(...) end,
					param = "alert"
				},
			},
			[2] = {
				caption = ReadText(1001, 8335),
				type = "checkbox",
				callback = function (...) return menu.filterOtherStation(...) end,
				[1] = {
					id = "other_misc_missions",
					name = ReadText(1001, 3291),
					info = ReadText(1001, 3292),
					param = "missions",
				},
			},
			[3] = {
				caption = ReadText(1001, 11204),
				type = "checkbox",
				callback = function (...) return menu.filterThinkDiplomacy(...) end,
				[1] = {
					id = "think_diplomacy_factioncolor",
					name = ReadText(1001, 11203),
					param = "factioncolor",
				},
				[2] = {
					id = "think_diplomacy_highlightvisitor",
					name = ReadText(1001, 11216),
					info = ReadText(1001, 11217),
					param = "highlightvisitors",
				},
			},
		},
		["layer_build"] = {},
		["layer_diplo"] = {},
		["layer_mining"] = {
			callback = function (value) return menu.filterMining(value) end,
			[1] = {
				caption = ReadText(1001, 8330),
				type = "checkbox",
				callback = function (...) return menu.filterMiningResources(...) end,
				[1] = {
					id = "mining_resource_display",
					name = ReadText(1001, 8331),
					info = ReadText(1001, 8332),
					param = "display"
				},
			},
		},
		["layer_other"] = {
			callback = function (value) return menu.filterOther(value) end,
			[1] = {
				caption = ReadText(1001, 8335),
				type = "checkbox",
				callback = function (...) return menu.filterOtherStation(...) end,
				[1] = {
					id = "other_misc_cargo",
					name = ReadText(1001, 3289),
					info = ReadText(1001, 3290),
					param = "cargo",
				},
				[2] = {
					id = "other_misc_workforce",
					name = ReadText(1001, 3293),
					info = ReadText(1001, 3294),
					param = "workforce",
				},
				[3] = {
					id = "other_misc_dockedships",
					name = ReadText(1001, 3275),
					info = ReadText(1001, 3299),
					param = "dockedships",
				},
				[4] = {
					id = "other_misc_civilian",
					name = ReadText(1001, 8333),
					info = ReadText(1001, 8334),
					param = "civilian",
				},
			},
			[2] = {
				caption = ReadText(1001, 8336),
				type = "checkbox",
				callback = function (...) return menu.filterOtherShip(...) end,
				[1] = {
					id = "other_misc_orderqueue",
					name = ReadText(1001, 3287),
					info = ReadText(1001, 8372),
					param = "orderqueue",
				},
				[2] = {
					id = "other_misc_allyorderqueue",
					name = ReadText(1001, 8370),
					info = ReadText(1001, 8371),
					param = "allyorderqueue",
				},
				[3] = {
					id = "other_misc_crew",
					name = ReadText(1001, 3295),
					info = ReadText(1001, 3296),
					param = "crew",
				},
			},
			[3] = {
				caption = ReadText(1001, 2664),
				type = "checkbox",
				callback = function (...) return menu.filterOtherMisc(...) end,
				[1] = {
					id = "other_misc_ecliptic",
					name = ReadText(1001, 3297),
					info = ReadText(1001, 3298),
					param = "ecliptic",
				},
				[2] = {
					id = "other_misc_wrecks",
					name = ReadText(1001, 8382),
					info = ReadText(1001, 8383),
					param = "wrecks",
				},
				[3] = {
					id = "other_misc_selection_lines",
					name = ReadText(1001, 11214),
					info = ReadText(1001, 11215),
					param = "selectionlines",
				},
				[4] = {
					id = "other_misc_gate_connections",
					name = ReadText(1001, 11243),
					info = ReadText(1001, 11244),
					param = "gateconnections",
				},
				[5] = {
					id = "other_misc_opacity",
					name = ReadText(1001, 11245),
					info = ReadText(1001, 11246),
					param = "opacity",
				},
			},
		}
	},

	mapRowHeight = Helper.standardTextHeight,
	mapFontSize = Helper.standardFontSize,
	contextBorder = 5
}
function newFuncs.createInfoFrame()
	local menu = mapMenu

	menu.createInfoFrameRunning = true
	menu.refreshed = true
	menu.noupdate = false

	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoFrameLayer)

	-- infoTable
	local infoTableHeight = Helper.viewHeight - menu.infoTableOffsetY - menu.borderOffset

	menu.infoFrame = Helper.createFrameHandle(menu, {
		x = menu.infoTableOffsetX,
		y = menu.infoTableOffsetY,
		width = menu.infoTableWidth,
		height = infoTableHeight,
		layer = config.infoFrameLayer,
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		standardButtons = {},
		showBrackets = false,
		autoFrameHeight = true,
		helpOverlayID = "map_infoframe",
	})

	menu.autopilottarget = GetAutoPilotTarget()
	menu.softtarget = C.GetSofttarget().softtargetID
	menu.populateUpkeepMissionData()

	if (menu.infoTableMode ~= "info") and (menu.mode ~= "orderparam_object") then
		menu.infoTablePersistentData.left.cashtransferdetails = {}
		menu.infoTablePersistentData.left.drops = {}
		menu.infoTablePersistentData.left.crew.object = nil
		menu.infoTablePersistentData.left.macrostolaunch = {}
	end

	if menu.contextMenuMode ~= "trade" then
		-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
		-- start kuertee_lua_with_callbacks:
		if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
		-- end kuertee_lua_with_callbacks:
			if not menu.arrowsRegistered then
				RegisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = true
			end
		else
			if menu.arrowsRegistered then
				UnregisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = nil
			end
		end
	end

	if menu.holomap ~= 0 then
		if menu.infoTableMode then
			C.SetMapStationInfoBoxMargin(menu.holomap, "left", menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder)
		else
			C.SetMapStationInfoBoxMargin(menu.holomap, "left", 0)
		end
	end

	local helpOverlayText = ""

	local infotabledesc, infotabledesc2
	menu.infoTableData = menu.infoTableData or {}
	menu.infoTableData.left = {}
	if menu.infoTableMode == "objectlist" then
		infotabledesc, infotabledesc2 = menu.createObjectList(menu.infoFrame, "left")
	elseif menu.infoTableMode == "propertyowned" then
		infotabledesc = menu.createPropertyOwned(menu.infoFrame, "left")
	elseif menu.infoTableMode == "plots" then
		menu.createPlotMode(menu.infoFrame)
	elseif menu.infoTableMode == "info" then
		if menu.infoMode.left == "objectinfo" then
			menu.infoFrame.properties.autoFrameHeight = false
			menu.createInfoSubmenu(menu.infoFrame, "left")
		elseif menu.infoMode.left == "objectcrew" then
			menu.createCrewInfoSubmenu(menu.infoFrame, "left")
		elseif menu.infoMode.left == "objectloadout" then
			menu.createLoadoutInfoSubmenu(menu.infoFrame, "left")
		elseif menu.infoMode.left == "orderqueue" then
			menu.createOrderQueue(menu.infoFrame, menu.infoMode.left, "left")
		elseif menu.infoMode.left == "orderqueue_advanced" then
			menu.createOrderQueue(menu.infoFrame, menu.infoMode.left, "left")
		elseif menu.infoMode.left == "standingorders" then
			menu.createStandingOrdersMenu(menu.infoFrame, "left")
		end
	elseif menu.infoTableMode == "missionoffer" then
		menu.createMissionMode(menu.infoFrame)
	elseif menu.infoTableMode == "mission" then
		menu.createMissionMode(menu.infoFrame)
	elseif menu.infoTableMode == "cheats" then
		menu.createCheats(menu.infoFrame)
	else
		-- -- empty
		-- menu.infoFrame.properties.backgroundID = ""
		-- menu.infoFrame.properties.showBrackets = false
		-- menu.infoFrame.properties.autoFrameHeight = false
		-- menu.infoFrame:addTable(0)

		-- start kuertee_lua_with_callbacks:
		local isCreated = false
		if callbacks ["createInfoFrame_on_menu_infoTableMode"] then
			for _, callback in ipairs (callbacks ["createInfoFrame_on_menu_infoTableMode"]) do
				if callback (menu.infoFrame) then
					isCreated = true
				end
			end
		end
		if isCreated ~= true then
			menu.infoFrame.properties.backgroundID = ""
			menu.infoFrame.properties.showBrackets = false
			menu.infoFrame.properties.autoFrameHeight = false
			menu.infoFrame:addTable(0)
		end
		-- end kuertee_lua_with_callbacks:

	end

	if menu.infoFrame then
		menu.infoFrame.properties.helpOverlayText = helpOverlayText
		menu.infoFrame:display()
	else
		-- create legacy info frame
		-- NOTE: descriptor table is {infotabledesc} if infotabledesc2 == nil
		Helper.displayFrame(menu, {infotabledesc, infotabledesc2}, false, "solid", "", {}, nil, config.infoFrameLayer, Helper.color.semitransparent, nil, false, true, nil, nil, menu.infoTableWidth, infoTableHeight, menu.infoTableOffsetX, menu.infoTableOffsetY)
	end

	if menu.holomap and (menu.holomap ~= 0) then
		menu.setSelectedMapComponents()
	end
end
function newFuncs.refreshInfoFrame(setrow, setcol)
	local menu = mapMenu

	if (menu.mode == "tradecontext") or (menu.mode == "dropwarescontext") or (menu.mode == "renamecontext") or (menu.mode == "crewtransfercontext") then
		return
	end
	if not menu.createInfoFrameRunning then
		menu.settoprow = menu.settoprow or GetTopRow(menu.infoTable)
		menu.topRows.infotableleft = menu.settoprow
		if menu.setplottoprow then
			menu.settoprow = menu.setplottoprow
			menu.setplottoprow = nil
		end
		-- if (menu.infoTableMode ~= "objectlist") and (menu.infoTableMode ~= "propertyowned") then
		-- start kuertee_lua_with_callbacks:
		if (not string.find ("" .. tostring (menu.infoTableMode), "objectlist")) and (not string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
		-- end kuertee_lua_with_callbacks:
			menu.setrow = setrow or Helper.currentTableRow[menu.infoTable]
			menu.selectedRows.infotableleft = menu.setrow
			if menu.setplotrow then
				menu.setrow = menu.setplotrow
				menu.setplotrow = nil
			end
			menu.setcol = setcol or Helper.currentTableCol[menu.infoTable]
			menu.selectedCols.infotableleft = menu.setcol
		end

		menu.selectedRows.infotable2 = nil
		if menu.infoTable2 then
			menu.selectedRows.infotable2 = Helper.currentTableRow[menu.infoTable2]
		end
		if menu.orderHeaderTable and menu.lastactivetable == menu.orderHeaderTable.id then
			menu.selectedRows.orderHeaderTableleft = menu.selectedRows.orderHeaderTableleft or Helper.currentTableRow[menu.orderHeaderTable.id] or 1
			menu.selectedCols.orderHeaderTableleft = menu.selectedCols.orderHeaderTableleft or Helper.currentTableCol[menu.orderHeaderTable.id]
		end
		menu.createInfoFrame()
	end
	menu.refreshInfoFrame2()
end
function newFuncs.createPropertyOwned(frame, instance)
	local menu = mapMenu

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createPropertyOwned_on_start"] then
		for _, callback in ipairs (callbacks ["createPropertyOwned_on_start"]) do
			callback (config)
		end
	end
	-- end kuertee_lua_with_callbacks:

	local infoTableData = menu.infoTableData[instance]

	-- TODO: Move to config table?
	infoTableData.maxIcons = 5
	infoTableData.shipIconWidth = math.max(math.ceil(C.GetTextHeight("99", Helper.standardFont, Helper.scaleFont(Helper.standardFont, config.mapFontSize), Helper.viewWidth)), math.ceil(C.GetTextWidth("99", Helper.standardFont, Helper.scaleFont(Helper.standardFont, config.mapFontSize))))
	local maxicons = infoTableData.maxIcons

	local ftable = frame:addTable(5 + maxicons, { tabOrder = 1, multiSelect = true })
	ftable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })

	--  [+/-] [Object Name][Location] [Sub_1] [Sub_2] [Sub_3] ... [Sub_N] [Shield/Hull Bar]
	ftable:setColWidth(1, Helper.scaleY(config.mapRowHeight), false)
	ftable:setDefaultBackgroundColSpan(2, 4 + maxicons)
	ftable:setColWidthMinPercent(2, 14)
	ftable:setColWidthMinPercent(4, 5)
	for i = 1, maxicons do
		ftable:setColWidth(5 + i - 1, infoTableData.shipIconWidth, false)
	end
	ftable:setColWidth(5 + maxicons, infoTableData.shipIconWidth, false)

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(5 + maxicons):createText(ReadText(1001, 1000), Helper.headerRowCenteredProperties)

	infoTableData.stations = { }
	infoTableData.fleetLeaderShips = { }
	infoTableData.unassignedShips = { }
	infoTableData.constructionShips = { }
	infoTableData.inventoryShips = { }
	infoTableData.deployables = { }
	infoTableData.subordinates = { }
	infoTableData.dockedships = { }
	infoTableData.constructions = { }
	infoTableData.moduledata = { }

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createPropertyOwned_on_init_infoTableData"] then
		for _, callback in ipairs (callbacks ["createPropertyOwned_on_init_infoTableData"]) do
			callback (infoTableData)
		end
	end
	-- end kuertee_lua_with_callbacks:

	local onlineitems = {}
	if menu.propertyMode == "inventoryships" then
		onlineitems = OnlineGetUserItems(false)
		local persistentonlineitems = OnlineGetUserItems(true)
		for k, v in pairs(persistentonlineitems) do
			onlineitems[k] = v
		end
	end

	local playerobjects = GetContainedObjectsByOwner("player")
	for i = #playerobjects, 1, -1 do
		local object = playerobjects[i]
		local object64 = ConvertIDTo64Bit(object)
		if menu.isObjectValid(object64) then
			local hull, purpose = GetComponentData(object, "hullpercent", "primarypurpose")
			playerobjects[i] = { id = object, name = ffi.string(C.GetComponentName(object64)), fleetname = menu.getFleetName(object64), objectid = ffi.string(C.GetObjectIDCode(object64)), class = ffi.string(C.GetComponentClass(object64)), hull = hull, purpose = purpose }
		else
			table.remove(playerobjects, i)
		end
	end

	table.sort(playerobjects, menu.componentSorter(menu.propertySorterType))

	for _, entry in ipairs(playerobjects) do
		local object = entry.id
		local object64 = ConvertIDTo64Bit(object)
		-- Determine subordinates that may appear in the menu
		local subordinates = {}
		if C.IsComponentClass(object64, "controllable") then
			subordinates = GetSubordinates(object)
		end
		for i = #subordinates, 1, -1 do
			local subordinate = subordinates[i]
			if not menu.isObjectValid(ConvertIDTo64Bit(subordinate)) then
				table.remove(subordinates, i)
			end
		end
		subordinates.hasRendered = #subordinates > 0
		infoTableData.subordinates[tostring(object)] = subordinates
		-- Find docked ships
		local dockedships = {}
		if C.IsComponentClass(object64, "container") then
			Helper.ffiVLA(dockedships, "UniverseID", C.GetNumDockedShips, C.GetDockedShips, object64, nil)
		end
		for i = #dockedships, 1, -1 do
			local convertedID = ConvertStringToLuaID(tostring(dockedships[i]))
			local loccommander = GetCommander(convertedID)
			if not loccommander then
				dockedships[i] = convertedID
			else
				table.remove(dockedships, i)
			end
		end
		infoTableData.dockedships[tostring(object)] = dockedships
		-- Check if object is station, fleet leader or unassigned
		local commander
		if C.IsComponentClass(object64, "controllable") then
			commander = GetCommander(object)
		end
		if not commander then
			if C.IsRealComponentClass(object64, "station") then
				table.insert(infoTableData.stations, object)
			elseif GetComponentData(object, "isdeployable") or C.IsComponentClass(object64, "lockbox") then
				table.insert(infoTableData.deployables, object)
			elseif #subordinates > 0 then
				table.insert(infoTableData.fleetLeaderShips, object)
			else
				table.insert(infoTableData.unassignedShips, object)
			end
		end

		if C.IsRealComponentClass(object64, "station") then
			local constructions = {}
			-- builds in progress
			local n = C.GetNumBuildTasks(object64, 0, true, false)
			local buf = ffi.new("BuildTaskInfo[?]", n)
			n = C.GetBuildTasks(buf, n, object64, 0, true, false)
			for i = 0, n - 1 do
				table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = true })
			end
			-- other builds
			local n = C.GetNumBuildTasks(object64, 0, false, false)
			local buf = ffi.new("BuildTaskInfo[?]", n)
			n = C.GetBuildTasks(buf, n, object64, 0, false, false)
			for i = 0, n - 1 do
				table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = false })
			end
			infoTableData.constructions[tostring(object)] = constructions
		elseif C.IsComponentClass(object64, "ship") then
			if menu.propertyMode == "inventoryships" then
				local pilot = ConvertIDTo64Bit(GetComponentData(object, "assignedpilot"))
				if pilot and (pilot ~= C.GetPlayerID()) then
					local inventory = GetInventory(pilot)
					if next(inventory) then
						local sortedWares = {}
						for ware, entry in pairs(inventory) do
							local ispersonalupgrade = GetWareData(ware, "ispersonalupgrade")
							if (not ispersonalupgrade) and (not onlineitems[ware]) then
								table.insert(infoTableData.inventoryShips, object)
								break
							end
						end
					end
				end
			end

			-- start kuertee_lua_with_callbacks:
			if callbacks ["createPropertyOwned_on_add_ship_infoTableData"] then
				for _, callback in ipairs (callbacks ["createPropertyOwned_on_add_ship_infoTableData"]) do
					callback (infoTableData, object)
				end
			end
			-- end kuertee_lua_with_callbacks:

		end
	end

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createPropertyOwned_on_add_other_objects_infoTableData"] then
		for _, callback in ipairs (callbacks ["createPropertyOwned_on_add_other_objects_infoTableData"]) do
			callback (infoTableData)
		end
	end
	-- end kuertee_lua_with_callbacks:

	local n = C.GetNumPlayerShipBuildTasks(true, false)
	local buf = ffi.new("BuildTaskInfo[?]", n)
	n = C.GetPlayerShipBuildTasks(buf, n, true, false)
	for i = 0, n - 1 do
		local factionid = ffi.string(buf[i].factionid)
		if factionid == "player" then
			table.insert(infoTableData.constructionShips, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = factionid, buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = true })
		end
	end
	local n = C.GetNumPlayerShipBuildTasks(false, false)
	local buf = ffi.new("BuildTaskInfo[?]", n)
	n = C.GetPlayerShipBuildTasks(buf, n, false, false)
	for i = 0, n - 1 do
		local factionid = ffi.string(buf[i].factionid)
		if factionid == "player" then
			table.insert(infoTableData.constructionShips, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = factionid, buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = false })
		end
	end

	local numdisplayed = 0
	local maxvisibleheight = ftable:getFullHeight()
	if menu.mode ~= "selectCV" then
		if (menu.propertyMode == "stations") or (menu.propertyMode == "propertyall") then
			numdisplayed = menu.createPropertySection(instance, "ownedstations", ftable, ReadText(1001, 8379), infoTableData.stations, "-- " .. ReadText(1001, 33) .. " --", true, numdisplayed, nil, menu.propertySorterType)
		end
	end
	if (menu.propertyMode == "fleets") or (menu.propertyMode == "propertyall") then
		numdisplayed = menu.createPropertySection(instance, "ownedfleets", ftable, ReadText(1001, 8326), infoTableData.fleetLeaderShips, "-- " .. ReadText(1001, 34) .. " --", nil, numdisplayed, nil, menu.propertySorterType)			-- {1001,8326} = Fleets
	end
	if (menu.propertyMode == "unassignedships") or (menu.propertyMode == "propertyall") then
		numdisplayed = menu.createPropertySection(instance, "ownedships", ftable, ReadText(1001, 8327), infoTableData.unassignedShips, "-- " .. ReadText(1001, 34) .. " --", nil, numdisplayed, nil, menu.propertySorterType)	-- {1001,8327} = Unassigned Ships
	end
	if menu.propertyMode == "inventoryships" then
		numdisplayed = menu.createPropertySection(instance, "inventoryships", ftable, ReadText(1001, 8381), infoTableData.inventoryShips, "-- " .. ReadText(1001, 34) .. " --", nil, numdisplayed, true, menu.propertySorterType)	-- {1001,8327} = Ships with Inventory
	end
	if (menu.propertyMode == "unassignedships") or (menu.propertyMode == "propertyall") then
		-- construction rows do not use the shield/hull bar widget
		menu.createConstructionSection(instance, "constructionships", ftable, ReadText(1001, 8328), infoTableData.constructionShips)
	end
	if menu.mode ~= "selectCV" then
		if menu.propertyMode == "deployables" then
			numdisplayed = menu.createPropertySection(instance, "owneddeployables", ftable, ReadText(1001, 1332), infoTableData.deployables, "-- " .. ReadText(1001, 34) .. " --", nil, numdisplayed, nil, menu.propertySorterType)
		end
	end

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createPropertyOwned_on_createPropertySection_unassignedships"] then
		local result
		for _, callback in ipairs (callbacks ["createPropertyOwned_on_createPropertySection_unassignedships"]) do
			result = callback (numdisplayed, instance, ftable, infoTableData)
			if result and result.numdisplayed > numdisplayed then
				numdisplayed = result.numdisplayed
			end
		end
	end
	-- end kuertee_lua_with_callbacks:

	if numdisplayed > 50 then
		ftable.properties.maxVisibleHeight = maxvisibleheight + 50 * (Helper.scaleY(config.mapRowHeight) + Helper.borderSize)
	end

	menu.numFixedRows = ftable.numfixedrows

	menu.settoprow = ((not menu.settoprow) or (menu.settoprow == 0)) and ((menu.setrow and menu.setrow > 31) and (menu.setrow - 27) or 3) or menu.settoprow
	ftable:setTopRow(menu.settoprow)
	if menu.infoTable then
		local result = GetShiftStartEndRow(menu.infoTable)
		if result then
			ftable:setShiftStartEnd(table.unpack(result))
		end
	end
	ftable:setSelectedRow(menu.sethighlightborderrow or menu.setrow)
	menu.setrow = nil
	menu.settoprow = nil
	menu.setcol = nil
	menu.sethighlightborderrow = nil

	local tabtable = frame:addTable(#config.propertyCategories + 3, { tabOrder = 2, reserveScrollBar = false })
	for i = 1, #config.propertyCategories do
		tabtable:setColWidth(i, menu.sideBarWidth, false)
	end
	local sorterWidth = menu.infoTableWidth - 3 * (menu.sideBarWidth + Helper.borderSize) - (#config.propertyCategories - 1) * Helper.borderSize
	local availableWidthForExtraColumns = menu.infoTableWidth - #config.propertyCategories * (menu.sideBarWidth + Helper.borderSize) - 2 * Helper.borderSize
	local colwidth = sorterWidth / 3
	local colspan = 3
	if colwidth > 3 * menu.sideBarWidth + 2 * Helper.borderSize then
		colspan = 4
	elseif colwidth < 2 * menu.sideBarWidth + Helper.borderSize then
		colspan = 2
		colwidth = (menu.infoTableWidth - 6 * (menu.sideBarWidth + Helper.borderSize) - 2 * Helper.borderSize) / 2
	end

	if 2 * colwidth >= availableWidthForExtraColumns then
		colwidth = math.floor((availableWidthForExtraColumns - 1) / 2)
	end

	tabtable:setColWidth(#config.propertyCategories + 2, colwidth, false)
	tabtable:setColWidth(#config.propertyCategories + 3, colwidth, false)

	local row = tabtable:addRow("property_tabs", { fixed = true, bgColor = Helper.color.transparent })
	for i, entry in ipairs(config.propertyCategories) do
		local bgcolor = Helper.defaultTitleBackgroundColor
		local color = Helper.color.white
		if entry.category == menu.propertyMode then
			bgcolor = Helper.defaultArrowRowBackgroundColor
		end

		local active = true
		if menu.mode == "selectCV" then
			active = entry.category == "propertyall"
		elseif (menu.mode == "selectComponent") and (menu.modeparam[3] == "deployables") then
			active = entry.category == "deployables"
			if active and (menu.selectedCols.propertytabs == nil) then
				menu.selectedCols.propertytabs = i
			end
		end

		row[i]:createButton({ height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name, scaling = false, helpOverlayID = entry.helpOverlayID, helpOverlayText = entry.helpOverlayText, active = active }):setIcon(entry.icon, { color = color})
		row[i].handlers.onClick = function () return menu.buttonPropertySubMode(entry.category, i) end
	end

	local row = tabtable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(3):createText(ReadText(1001, 2906) .. ReadText(1001, 120))

	local buttonheight = Helper.scaleY(config.mapRowHeight)
	local button = row[4]:setColSpan(colspan):createButton({ scaling = false, height = buttonheight }):setText(ReadText(1001, 8026), { halign = "center", scaling = true })
	if menu.propertySorterType == "class" then
		button:setIcon("table_arrow_inv_down", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	elseif menu.propertySorterType == "classinverse" then
		button:setIcon("table_arrow_inv_up", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	end
	row[4].handlers.onClick = function () return menu.buttonPropertySorter("class") end
	local button = row[#config.propertyCategories + colspan - 2]:setColSpan(5 - colspan):createButton({ scaling = false, height = buttonheight }):setText(ReadText(1001, 2809), { halign = "center", scaling = true })
	if menu.propertySorterType == "name" then
		button:setIcon("table_arrow_inv_down", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	elseif menu.propertySorterType == "nameinverse" then
		button:setIcon("table_arrow_inv_up", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	end
	row[#config.propertyCategories + colspan - 2].handlers.onClick = function () return menu.buttonPropertySorter("name") end
	local button = row[#config.propertyCategories + 3]:createButton({ scaling = false, height = buttonheight }):setText(ReadText(1001, 1), { halign = "center", scaling = true })
	if menu.propertySorterType == "hull" then
		button:setIcon("table_arrow_inv_down", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	elseif menu.propertySorterType == "hullinverse" then
		button:setIcon("table_arrow_inv_up", { width = buttonheight, height = buttonheight, x = button:getColSpanWidth() - buttonheight })
	end
	row[#config.propertyCategories + 3].handlers.onClick = function () return menu.buttonPropertySorter("hull") end
	
	tabtable:setSelectedRow(menu.selectedRows.propertytabs or menu.selectedRows.infotable2 or 0)
	tabtable:setSelectedCol(menu.selectedCols.propertytabs or Helper.currentTableCol[menu.infoTable2] or 0)
	menu.selectedRows.propertytabs = nil
	menu.selectedCols.propertytabs = nil

	ftable.properties.y = tabtable.properties.y + tabtable:getFullHeight() + Helper.borderSize
	tabtable.properties.nextTable = ftable.index
	ftable.properties.prevTable = tabtable.index
end
function newFuncs.createPropertyRow(instance, ftable, component, iteration, commanderlocation, showmodules, hidesubordinates, numdisplayed, sorter)
	local menu = mapMenu

	local maxicons = menu.infoTableData[instance].maxIcons

	local subordinates = menu.infoTableData[instance].subordinates[tostring(component)] or {}
	local dockedships = menu.infoTableData[instance].dockedships[tostring(component)] or {}
	local constructions = menu.infoTableData[instance].constructions[tostring(component)] or {}
	local convertedComponent = ConvertStringTo64Bit(tostring(component))

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createPropertyRow_on_init_vars"] then
		local result
		for _, callback in ipairs (callbacks ["createPropertyRow_on_init_vars"]) do
			result = callback (maxicons, subordinates, dockedships, constructions, convertedComponent, iteration)
			if result then
				maxicons = result.maxicons
				subordinates = result.subordinates
				dockedships = result.dockedships
				constructions = result.constructions
				convertedComponent = result.convertedComponent
				iteration = result.iteration
			end
		end
	end
	-- end kuertee_lua_with_callbacks:

	if (#menu.searchtext == 0) or Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.FilterComponentByText(convertedComponent, numtexts, texts, true) end, "text") then
		numdisplayed = numdisplayed + 1

		if (not menu.isPropertyExtended(tostring(component))) and (menu.isCommander(component) or menu.isConstructionContext(convertedComponent)) then
			menu.extendedproperty[tostring(component)] = true
		end
		if (not menu.isPropertyExtended(tostring(component))) and menu.isDockContext(convertedComponent) then
			-- if menu.infoTableMode ~= "propertyowned" then
			-- start kuertee_lua_with_callbacks:
			if not string.find (menu.infoTableMode, "propertyowned") then
			-- end kuertee_lua_with_callbacks:
				menu.extendedproperty[tostring(component)] = true
			end
		end

		local isstation = IsComponentClass(component, "station")
		local isdoublerow = (iteration == 0 and (isstation or #subordinates > 0))
		local name, color, bgcolor, font, mouseover = menu.getContainerNameAndColors(component, iteration, isdoublerow, false)
		local alertString = ""
		local alertMouseOver = ""
		if menu.getFilterOption("layer_think") then
			local alertStatus, missionlist = menu.getContainerAlertLevel(component)
			local minAlertLevel = menu.getFilterOption("think_alert")
			if (minAlertLevel ~= 0) and alertStatus >= minAlertLevel then
				local color = Helper.color.white
				if alertStatus == 1 then
					color = menu.holomapcolor.lowalertcolor
				elseif alertStatus == 2 then
					color = menu.holomapcolor.mediumalertcolor
				else
					color = menu.holomapcolor.highalertcolor
				end
				alertString = Helper.convertColorToText(color) .. "\027[workshop_error]\027X"
				alertMouseOver = ReadText(1001, 3305) .. ReadText(1001, 120) .. "\n" .. missionlist
			end
		end

		if menu.mode == "selectCV" then
			local isplayerowned, isenemy = GetComponentData(component, "isplayerowned", "isenemy")
			if isenemy then
				mouseover = "\027R" .. ReadText(1026, 8014) .. "\027X"
			elseif C.IsBuilderBusy(convertedComponent) then
				mouseover = "\027R" .. ReadText(1001, 7939) .. "\027X"
			elseif not isplayerowned then
				local fee = tonumber(C.GetBuilderHiringFee())
				mouseover = ((fee > GetPlayerMoney()) and "\027R" or "\027G") .. ReadText(1001, 7940) .. ReadText(1001, 120) .. " " .. ConvertMoneyString(fee, false, true, nil, true) .. " " .. ReadText(1001, 101) .. "\027X"
			end
		end

		local row = ftable:addRow({"property", component, nil, iteration}, { bgColor = bgcolor, multiSelected = menu.isSelectedComponent(component) })
		if (menu.getNumSelectedComponents() == 1) and menu.isSelectedComponent(component) then
			menu.setrow = row.index
		end
		if IsSameComponent(component, menu.highlightedbordercomponent) then
			menu.sethighlightborderrow = row.index
		end

		-- Set up columns
		--  [+/-] [Object Name] [Top Level Shield/Hull Bar] [Location] [Sub_1] [Sub_2] [Sub_3] ... [Sub_N or Shield/Hull Bar]
		if showmodules or (subordinates.hasRendered and (not hidesubordinates)) or (#dockedships > 0) or (isstation and (#constructions > 0)) then
			row[1]:createButton({ scaling = false }):setText(menu.isPropertyExtended(tostring(component)) and "-" or "+", { scaling = true, halign = "center" })
			row[1].handlers.onClick = function () return menu.buttonExtendProperty(tostring(component)) end
		end

		local location, locationtext, isdocked, aipilot, isplayerowned, isonlineobject = GetComponentData(component, "sectorid", "sector", "isdocked", "assignedaipilot", "isplayerowned", "isonlineobject")
		local displaylocation = location and not (commanderlocation and IsSameComponent(location, commanderlocation))
		local currentordericon, currentorderrawicon, currentordercolor, currentordername, currentorderisoverride = "", "", nil, "", false
		if IsComponentClass(component, "ship") then
			currentordericon, currentorderrawicon, currentordercolor, currentordername, currentorderisoverride = menu.getOrderInfo(convertedComponent)
		end
		local fleettypes = IsComponentClass(component, "controllable") and menu.getPropertyOwnedFleetData(instance, component, maxicons) or {}

		if isplayerowned and isonlineobject then
			locationtext = Helper.convertColorToText(menu.holomapcolor.visitorcolor) .. ReadText(1001, 11231) .. "\27X"
			currentordericon = Helper.convertColorToText(menu.holomapcolor.visitorcolor) .. "\27[order_venture]\27X"
			currentorderrawicon = "order_venture"
			currentordercolor = menu.holomapcolor.visitorcolor
			currentordername = ReadText(1001, 7868)
			isdocked = false
		end

		-- start kuertee_lua_with_callbacks:
		if callbacks ["createPropertyRow_on_set_locationtext"] then
			local result
			for _, callback in ipairs (callbacks ["createPropertyRow_on_set_locationtext"]) do
				result = callback (locationtext, component)
				if result then
					locationtext = result.locationtext
				end
			end
		end
		-- end kuertee_lua_with_callbacks:

		local namecolspan = 1
		if menu.infoTableMode == "objectlist" then
			displaylocation = false
		end
		if not displaylocation then
			if (currentordericon ~= "") or isdocked then
				namecolspan = namecolspan + maxicons - 2
			else
				namecolspan = namecolspan + maxicons
			end
		end

		if isdoublerow then
			if isstation then
				-- station case
				local secondline = ""
				if displaylocation then
					secondline = locationtext
				end
				row[2]:setColSpan(4 + maxicons - #fleettypes - 1)
				local stationname = alertString .. Helper.convertColorToText(color) .. name .. "\27X"
				local stationnametruncated = TruncateText(stationname, font, Helper.scaleFont(font, config.mapFontSize), row[2]:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx))
				if stationnametruncated ~= stationname then
					mouseover = stationname .. ((mouseover ~= "") and ("\n" .. mouseover) or "")
				end
				if alertMouseOver ~= "" then
					if mouseover ~= "" then
						mouseover = mouseover .. "\n\n"
					end
					mouseover = mouseover .. alertMouseOver
				end
				row[2]:createText(stationname .. "\n" .. secondline, { font = font, mouseOverText = mouseover })
			else
				-- fleet case
				local textheight = C.GetTextHeight(" \n ", font, Helper.scaleFont(font, config.mapFontSize), Helper.viewWidth)
				local icon = row[2]:setColSpan(4 + maxicons - #fleettypes - 1):createIcon("solid", { scaling = false, color = { r = 0, g = 0, b = 0, a = 1 }, height = textheight })
				
				local secondtext1 = ""
				local secondtext2 = ""
				if displaylocation or (currentordericon ~= "") or isdocked then
					if displaylocation then
						secondtext1 = locationtext
					end
					secondtext2 = (currentordericon ~= "") and currentordericon or ""
					if isdocked then
						secondtext2 = secondtext2 .. " \27[order_dockat]"
					end
				end
				secondtext1truncated = TruncateText(secondtext1, font, Helper.scaleFont(font, config.mapFontSize), icon:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx))
				local secondtext1width = C.GetTextWidth(secondtext1truncated, font, Helper.scaleFont(font, config.mapFontSize))
				local secondtext2width = C.GetTextWidth(secondtext2, font, Helper.scaleFont(font, config.mapFontSize))

				local fleetname = ffi.string(C.GetFleetName(convertedComponent))
				local shipname = alertString .. name
				local fleetnametruncated = TruncateText(fleetname, font, Helper.scaleFont(font, config.mapFontSize), icon:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx) - secondtext1width - Helper.scaleX(10))
				local shipnametruncated = TruncateText(shipname, font, Helper.scaleFont(font, config.mapFontSize), icon:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx) - secondtext2width - Helper.scaleX(10))

				local mouseovertext = ""
				if fleetnametruncated ~= fleetname then
					mouseovertext = mouseovertext .. fleetname
				end
				if shipnametruncated ~= shipname then
					if mouseovertext ~= "" then
						mouseovertext = mouseovertext .. "\n"
					end
					mouseovertext = mouseovertext .. alertString .. Helper.convertColorToText(color) .. name .. "\27X"
				end
				if secondtext1truncated ~= secondtext1 then
					if mouseovertext ~= "" then
						mouseovertext = mouseovertext .. "\n"
					end
					mouseovertext = mouseovertext .. secondtext1
				end
				if currentordername ~= "" then
					if mouseovertext ~= "" then
						mouseovertext = mouseovertext .. "\n"
					end
					mouseovertext = mouseovertext .. currentordername
				end
				if alertMouseOver ~= "" then
					if mouseovertext ~= "" then
						mouseovertext = mouseovertext .. "\n\n"
					end
					mouseovertext = mouseovertext .. alertMouseOver
				end
				icon.properties.mouseOverText = mouseovertext

				icon:setText(string.format("%s\n%s%s", fleetnametruncated, Helper.convertColorToText(color), shipnametruncated), { scaling = true, font = font, x = Helper.standardTextOffsetx })
				icon:setText2(currentorderisoverride and function () return menu.overrideOrderIcon(currentordercolor, true, currentorderrawicon, secondtext1truncated .. "\n", isdocked and "\27[order_dockat]" or "") end or (secondtext1truncated .. "\n" .. secondtext2), { scaling = true, font = font, halign = "right", x = Helper.standardTextOffsetx })
			end
			-- fleet info
			for i, fleetdata in ipairs(fleettypes) do
				local colidx = 5 + maxicons - #fleettypes + i - 1
				if fleetdata.icon then
					row[colidx]:createText(string.format("\027[%s]\n%d", fleetdata.icon, fleetdata.count), { halign = "center", x = 0 })
				else
					row[colidx]:createText(string.format("...\n%d", fleetdata.count), { halign = "center", x = 0 })
				end
			end
			-- shieldhullbar
			row[5 + maxicons]:createObjectShieldHullBar(component, { y = isstation and Helper.standardTextHeight / 2 or 1.5 * Helper.standardTextHeight })
		else
			-- unassigned ship case
			row[2]:setColSpan(namecolspan + 1)
			local indentation, actualname = string.match(name, "([ ]*)(.*)")
			local shipname = indentation .. alertString .. actualname
			local shipnametruncated = TruncateText(shipname, font, Helper.scaleFont(font, config.mapFontSize), row[2]:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx))
			if shipnametruncated ~= shipname then
				mouseover = indentation .. alertString .. actualname .. "\27X" .. ((mouseover ~= "") and ("\n" .. mouseover) or "")
			end
			if alertMouseOver ~= "" then
				if mouseover ~= "" then
					mouseover = mouseover .. "\n\n"
				end
				mouseover = mouseover .. alertMouseOver
			end

			-- row[2]:createText(shipname, { font = font, color = color, mouseOverText = mouseover })
			-- start kuertee_lua_with_callbacks:
			if not callbacks ["createPropertyRow_override_row_shipname_createText"] then
				row[2]:createText(shipname, { font = font, color = color, mouseOverText = mouseover })
			else
				local result
				for _, callback in ipairs (callbacks ["createPropertyRow_override_row_shipname_createText"]) do
					result = callback (shipname, { font = font, color = color, mouseOverText = mouseover }, component)
					if result then
						row[2]:createText(result.shipname, result.properties)
					end
				end
				if not result then
					row[2]:createText(shipname, { font = font, color = color, mouseOverText = mouseover })
				end
			end
			-- end kuertee_lua_with_callbacks:
			-- location / order
			if displaylocation then
				local colspan = 5 + maxicons - 3 - namecolspan
				if currentordericon ~= "" then
					colspan = colspan - 1
				end
				if isdocked then
					colspan = colspan - 1
				end
				row[3 + namecolspan]:setColSpan(colspan)
				local locationtexttruncated = TruncateText(locationtext, font, Helper.scaleFont(font, config.mapFontSize), row[3 + namecolspan]:getColSpanWidth())
				local mouseovertext = ""
				if locationtexttruncated ~= locationtext then
					mouseovertext = locationtext
				end

				-- row[3 + namecolspan]:createText(locationtext, { halign = "right", font = font, mouseOverText = mouseovertext, x = 0 })
				-- start kuertee_lua_with_callbacks:
				if not callbacks ["createPropertyRow_override_row_location_createText"] then
					row[3 + namecolspan]:createText(locationtext, { halign = "right", font = font, mouseOverText = mouseovertext, x = 0 })
				else
					local result
					for _, callback in ipairs (callbacks ["createPropertyRow_override_row_location_createText"]) do
						result = callback (locationtext, {halign = "right", font = font, mouseOverText = mouseovertext, x = 0}, component)
						if result then
							row[3 + namecolspan]:createText(result.locationtext, result.properties)
						end
					end
					if not result then
						row[3 + namecolspan]:createText(locationtext, { halign = "right", font = font, mouseOverText = mouseovertext, x = 0 })
					end
				end
				-- end kuertee_lua_with_callbacks:
			end

			if (currentordericon ~= "") or isdocked then
				if isdocked then
					row[4 + maxicons]:createIcon("order_dockat", { width = config.mapRowHeight, height = config.mapRowHeight, mouseOverText = ReadText(1001, 3249) })
					if currentordericon ~= "" then
						row[3 + maxicons]:createIcon(currentorderrawicon, { color = currentorderisoverride and function () return menu.overrideOrderIcon(currentordercolor, false) end or currentordercolor, width = config.mapRowHeight, height = config.mapRowHeight, mouseOverText = currentordername })
					end
				else
					row[4 + maxicons]:createIcon(currentorderrawicon, { color = currentorderisoverride and function () return menu.overrideOrderIcon(currentordercolor, false) end or currentordercolor, width = config.mapRowHeight, height = config.mapRowHeight, mouseOverText = currentordername })
				end
			end
			-- shieldhullbar
			row[5 + maxicons]:createObjectShieldHullBar(component)
		end

		if row[1].type == "button" then
			if isdoublerow and (not isstation) then
				row[1].properties.height = row[2]:getHeight()
			else
				row[1].properties.height = row[2]:getMinTextHeight(true)
			end
		end

		if IsComponentClass(component, "station") then
			AddKnownItem("stationtypes", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_xl") then
			AddKnownItem("shiptypes_xl", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_l") then
			AddKnownItem("shiptypes_l", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_m") then
			AddKnownItem("shiptypes_m", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_s") then
			AddKnownItem("shiptypes_s", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_xs") then
			AddKnownItem("shiptypes_xs", GetComponentData(component, "macro"))
		end

		if menu.isPropertyExtended(tostring(component)) then
			-- modules
			if showmodules then
				menu.createModuleSection(instance, ftable, component, iteration)
			end
			-- subordinates
			if subordinates.hasRendered and (not hidesubordinates) then
				numdisplayed = menu.createSubordinateSection(instance, ftable, component, isstation, iteration, location or commanderlocation, numdisplayed, sorter)
			end
			-- dockedships
			if #dockedships > 0 then
				local isdockedshipsextended = menu.isDockedShipsExtended(tostring(component), isstation)
				if (not isdockedshipsextended) and menu.isDockContext(convertedComponent) then
					-- if menu.infoTableMode ~= "propertyowned" then
					-- start kuertee_lua_with_callbacks:
					if not string.find (menu.infoTableMode, "propertyowned") then
					-- end kuertee_lua_with_callbacks:
						menu.extendeddockedships[tostring(component)] = true
						isdockedshipsextended = true
					end
				end

				local row = ftable:addRow({"dockedships", component}, { bgColor = Helper.color.transparent })
				row[1]:createButton():setText(isdockedshipsextended and "-" or "+", { halign = "center" })
				row[1].handlers.onClick = function () return menu.buttonExtendDockedShips(tostring(component), isstation) end
				local text = ReadText(1001, 3265)
				for i = 1, iteration + 1 do
					text = "    " .. text
				end
				row[2]:setColSpan(3):createText(text)
				if IsSameComponent(component, menu.highlightedbordercomponent) and (menu.highlightedborderstationcategory == "dockedships") then
					menu.sethighlightborderrow = row.index
				end
				if isdockedshipsextended then
					dockedships = menu.sortComponentListHelper(dockedships, sorter)
					for _, dockedship in ipairs(dockedships) do
						numdisplayed = menu.createPropertyRow(instance, ftable, dockedship, iteration + 2, location or commanderlocation, nil, true, numdisplayed, sorter)
					end
				end
			end
			if isstation then
				-- construction
				if #constructions > 0 then
					menu.createConstructionSubSection(ftable, component, constructions)
				end
			end
		end
	end

	return numdisplayed
end
function newFuncs.createSideBar(firsttime, frame, width, height, offsetx, offsety)
	local menu = mapMenu

	-- start kuertee_lua_with_callbacks:
	if callbacks ["createSideBar_on_start"] then
		for _, callback in ipairs (callbacks ["createSideBar_on_start"]) do
			callback (config)
		end
	end
	-- end kuertee_lua_with_callbacks:

	local spacingHeight = menu.sideBarWidth / 4
	local ftable = frame:addTable(1, { tabOrder = 3, width = width, height = height, x = offsetx, y = offsety, scaling = false, borderEnabled = false, reserveScrollBar = false, defaultInteractiveObject = menu.infoTableMode == nil })

	local firstactive
	for _, entry in ipairs(config.leftBar) do
		if (entry.condition == nil) or entry.condition() then
			if not entry.spacing then
				local active = true
				if menu.mode == "selectCV" then
					-- if (entry.mode ~= "objectlist") and (entry.mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (entry.mode, "objectlist")) and (not string.find (entry.mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "hire" then
					-- if entry.mode ~= "propertyowned" then
					-- start kuertee_lua_with_callbacks:
					if not string.find (entry.mode, "propertyowned") then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "orderparam_object" then
					-- if (entry.mode ~= "objectlist") and (entry.mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (entry.mode, "objectlist")) and (not string.find (entry.mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "selectComponent" then
					-- if (entry.mode ~= "objectlist") and (entry.mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (entry.mode, "objectlist")) and (not string.find (entry.mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				end
				if active then
					local selectedmode = false
					if type(entry.mode) == "table" then
						for _, mode in ipairs(entry.mode) do
							if mode == menu.infoTableMode then
								selectedmode = true
								break
							end
						end
					else
						if entry.mode == menu.infoTableMode then
							selectedmode = true
						end
					end
					if selectedmode then
						firstactive = nil
						break
					end
					if not firstactive then
						firstactive = entry.mode
					end
				end
			end
		end
	end
	if firstactive and firsttime then
		menu.infoTableMode = firstactive
		firstactive = nil
	end

	for _, entry in ipairs(config.leftBar) do
		if (entry.condition == nil) or entry.condition() then
			if entry.spacing then
				local row = ftable:addRow(false, { fixed = true })
				row[1]:createIcon("mapst_seperator_line", { width = menu.sideBarWidth, height = spacingHeight })
			else
				local mode = entry.mode
				if type(entry.mode) == "table" then
					mode = mode[1]
				end
				local row = ftable:addRow(true, { fixed = true })
				local active = true
				if menu.mode == "selectCV" then
					-- if (mode ~= "objectlist") and (mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (mode, "objectlist")) and (not string.find (mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "hire" then
					-- if mode ~= "propertyowned" then
					-- start kuertee_lua_with_callbacks:
					if not string.find (mode, "propertyowned") then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "orderparam_object" then
					-- if (mode ~= "objectlist") and (mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (mode, "objectlist")) and (not string.find (mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				elseif menu.mode == "selectComponent" then
					-- if (mode ~= "objectlist") and (mode ~= "propertyowned") then
					-- start kuertee_lua_with_callbacks:
					if (not string.find (mode, "objectlist")) and (not string.find (mode, "propertyowned")) then
					-- end kuertee_lua_with_callbacks:
						active = false
					end
				end
				local bgcolor = Helper.defaultTitleBackgroundColor
				if type(entry.mode) == "table" then
					for _, mode in ipairs(entry.mode) do
						if mode == menu.infoTableMode then
							bgcolor = Helper.defaultArrowRowBackgroundColor
							break
						end
					end
				else
					if entry.mode == menu.infoTableMode then
						bgcolor = Helper.defaultArrowRowBackgroundColor
					end
				end
				local color = Helper.color.white
				if menu.highlightLeftBar[mode] then
					color = Helper.color.mission
				end
				
				row[1]:createButton({ active = active, height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name, helpOverlayID = entry.helpOverlayID, helpOverlayText = entry.helpOverlayText }):setIcon(entry.icon, { color = color })
				row[1].handlers.onClick = function () return menu.buttonToggleObjectList(mode) end
			end
		end
	end

	ftable:setSelectedRow(menu.selectedRows.sideBar)
	menu.selectedRows.sideBar = nil
end
function newFuncs.onRowChanged(row, rowdata, uitable, modified, input, source)
	local menu = mapMenu

	-- Lock button over updates
	menu.lock = getElapsedTime()

	-- handle map modes without a holomap first
	if (menu.mode == "boardingcontext") and menu.boardingtable_shipselection and (uitable == menu.boardingtable_shipselection.id) and (type(rowdata) == "table") and (rowdata[1] == "boardingship") and C.IsComponentClass(rowdata[2], "defensible") and (menu.boardingData.selectedship ~= rowdata[2]) then
		--print("queueing refresh on next frame. ship: " .. ffi.string(C.GetComponentName(rowdata[2])) .. " " .. tostring(rowdata[2]))
		menu.boardingData.selectedship = rowdata[2]
		menu.queuecontextrefresh = true
	elseif menu.contextMenuMode == "trade" then
		if uitable == menu.contextshiptable then
			if rowdata then
				menu.selectedTradeWare = rowdata
				if (not menu.skipTradeRowChange) and (not menu.tradeSliderLock) then
					menu.queuetradecontextrefresh = true
				end
				menu.skipTradeRowChange = nil
			end
		end
	end

	if menu.holomap == 0 then
		return
	end

	if (menu.infoTableMode == "info") then
		if uitable == menu.infoTable then
			if (menu.infoMode.left == "objectinfo") or (menu.infoMode.left == "objectcrew") or (menu.infoMode.left == "objectloadout") then
				menu.selectedRows.infotableleft = row
				if menu.infoMode.left == "objectloadout" then
					local infomacrostolaunch = menu.infoTablePersistentData.left.macrostolaunch
					if (type(rowdata) == "table") and (rowdata[1] == "info_deploy") then
						if GetMacroData(rowdata[2], "islasertower") and (infomacrostolaunch.lasertower ~= rowdata[2]) then
							menu.infoTablePersistentData.left.macrostolaunch = { lasertower = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "mine") and (infomacrostolaunch.mine ~= rowdata[2]) then
							menu.infoTablePersistentData.left.macrostolaunch = { mine = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "navbeacon") and (infomacrostolaunch.navbeacon ~= rowdata[2]) then
							menu.infoTablePersistentData.left.macrostolaunch = { navbeacon = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "resourceprobe") and (infomacrostolaunch.resourceprobe ~= rowdata[2]) then
							menu.infoTablePersistentData.left.macrostolaunch = { resourceprobe = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "satellite") and (infomacrostolaunch.satellite ~= rowdata[2]) then
							menu.infoTablePersistentData.left.macrostolaunch = { satellite = rowdata[2] }
						end
					else
						menu.infoTablePersistentData.left.macrostolaunch = {}
					end
				end
			elseif (menu.infoMode.left == "orderqueue") or (menu.infoMode.left == "orderqueue_advanced") or (menu.infoMode.left == "standingorders") then
				menu.infoTablePersistentData.left.selectedorder = rowdata
				if type(menu.infoTablePersistentData.left.selectedorder) == "table" then
					menu.infoTablePersistentData.left.selectedorder.object = menu.infoSubmenuObject
				end
			end
		end
	-- start kuertee_lua_with_callbacks:
	-- elseif (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
	elseif (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
	-- end kuertee_lua_with_callbacks:
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local convertedComponent = ConvertIDTo64Bit(rowdata[2])
				if (source ~= "auto") and convertedComponent then
					local convertedcomponentclass = ffi.string(C.GetComponentClass(convertedComponent))
					if convertedcomponentclass  == "station" then
						AddUITriggeredEvent(menu.name, "selection_station", convertedComponent)
					end
					if (convertedcomponentclass  == "ship_s") or (convertedcomponentclass  == "ship_m") or (convertedcomponentclass  == "ship_l") or (convertedcomponentclass  == "ship_xl") then
						AddUITriggeredEvent(menu.name, "selection_ship", convertedComponent)
					end
					if (convertedcomponentclass == "resourceprobe") then
						AddUITriggeredEvent(menu.name, "selection_resourceprobe", convertedComponent)
					end

					if (menu.mode ~= "orderparam_object") and (input ~= "rightmouse") then
						menu.infoSubmenuObject = convertedComponent
						if menu.infoTableMode == "info" then
							menu.refreshInfoFrame(nil, 0)
						elseif menu.searchTableMode == "info" then
							menu.refreshInfoFrame2(nil, 0)
						end
					end
				end
				menu.updateSelectedComponents(modified, source == "auto", convertedComponent)
				menu.setSelectedMapComponents()
			end
		end
	elseif menu.infoTableMode == "plots" then
		if menu.plotDoNotUpdate then
			menu.plotDoNotUpdate = nil
		elseif menu.table_plotlist and (uitable == menu.table_plotlist.id) then
			menu.settoprow = GetTopRow(menu.table_plotlist)
			menu.setrow = Helper.currentTableRow[menu.table_plotlist]
			if not rowdata then
				print("rowdata empty. table id: " .. tostring(uitable) .. ", row: " .. tostring(row) .. ", rowdata: " .. tostring(rowdata))
			elseif input == "mouse" then
				--print("table id: " .. tostring(uitable) .. ", row: " .. tostring(row) .. ", rowdata: " .. tostring(rowdata) .. ", menu.table_plotlist.id: " .. tostring(menu.table_plotlist.id) .. ", uitable == menu.table_plotlist.id? " .. tostring(uitable == menu.table_plotlist.id))
				if rowdata == "plots_new" then
					menu.updatePlotData("plots_new", true)
				else
					C.SetFocusMapComponent(menu.holomap, rowdata, true)
				end
				menu.updatePlotData(rowdata)
			end
		end
	elseif (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local missionid = ConvertStringTo64Bit(rowdata[1])
				menu.missionModeCurrent = rowdata[1]
				C.SetMapRenderMissionGuidance(menu.holomap, missionid)
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				elseif input == "mouse" then
					if menu.contextMenuData and menu.contextMenuData.missionid and (menu.contextMenuData.missionid == missionid) then
						menu.closeContextMenu()
						menu.missionModeContext = nil
					else
						menu.closeContextMenu()
						menu.showMissionContext(missionid)
						menu.missionModeContext = true
					end
				end
			elseif type(rowdata) == "string" then
				menu.missionModeCurrent = rowdata
				C.SetMapRenderMissionGuidance(menu.holomap, 0)
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				elseif input == "mouse" then
					menu.closeContextMenu()
					menu.missionModeContext = nil
				end
			end
			if menu.missionDoNotUpdate then
				menu.missionDoNotUpdate = nil
			end
		end
	end

	if (menu.searchTableMode == "info") then
		if uitable == menu.infoTableRight then
			if (menu.infoMode.right == "objectinfo") or (menu.infoMode.right == "objectcrew") or (menu.infoMode.right == "objectloadout") then
				menu.selectedRows.infotableright = row
				if menu.infoMode.right == "objectloadout" then
					local infomacrostolaunch = menu.infoTablePersistentData.right.macrostolaunch
					if (type(rowdata) == "table") and (rowdata[1] == "info_deploy") then
						if GetMacroData(rowdata[2], "islasertower") and (infomacrostolaunch.lasertower ~= rowdata[2]) then
							menu.infoTablePersistentData.right.macrostolaunch = { lasertower = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "mine") and (infomacrostolaunch.mine ~= rowdata[2]) then
							menu.infoTablePersistentData.right.macrostolaunch = { mine = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "navbeacon") and (infomacrostolaunch.navbeacon ~= rowdata[2]) then
							menu.infoTablePersistentData.right.macrostolaunch = { navbeacon = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "resourceprobe") and (infomacrostolaunch.resourceprobe ~= rowdata[2]) then
							menu.infoTablePersistentData.right.macrostolaunch = { resourceprobe = rowdata[2] }
						elseif IsMacroClass(rowdata[2], "satellite") and (infomacrostolaunch.satellite ~= rowdata[2]) then
							menu.infoTablePersistentData.right.macrostolaunch = { satellite = rowdata[2] }
						end
					else
						menu.infoTablePersistentData.right.macrostolaunch = {}
					end
				end
			elseif (menu.infoMode.right == "orderqueue") or (menu.infoMode.right == "orderqueue_advanced") or (menu.infoMode.right == "standingorders") then
				menu.infoTablePersistentData.right.selectedorder = rowdata
				if type(menu.infoTablePersistentData.right.selectedorder) == "table" then
					menu.infoTablePersistentData.right.selectedorder.object = menu.infoSubmenuObject
				end
			end
		end
	end
end
function newFuncs.onSelectElement (uitable, modified, row, isdblclick, input)
	local menu = mapMenu

	local rowdata = Helper.getCurrentRowData(menu, uitable)

	-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
	-- start kuertee_lua_with_callbacks:
	if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
	-- end kuertee_lua_with_callbacks:
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local convertedRowComponent = ConvertIDTo64Bit(rowdata[2])
				menu.setSelectedMapComponents()

				if convertedRowComponent and (convertedRowComponent ~= 0) then
					local isonlineobject, isplayerowned = GetComponentData(rowdata[2], "isonlineobject", "isplayerowned")
					if (isdblclick or (input ~= "mouse")) and (ffi.string(C.GetComponentClass(convertedRowComponent)) ~= "sector") then
						if string.find(rowdata[1], "subordinates") then
							local subordinates = menu.infoTableData.left.subordinates[tostring(rowdata[2])] or {}
							local groups = {}
							for _, subordinate in ipairs(subordinates) do
								local group = GetComponentData(subordinate, "subordinategroup")
								if group and group > 0 then
									if groups[group] then
										table.insert(groups[group].subordinates, subordinate)
									else
										groups[group] = { assignment = ffi.string(C.GetSubordinateGroupAssignment(convertedRowComponent, group)), subordinates = { subordinate } }
									end
								end
							end

							if groups[rowdata[3]] then
								C.SetFocusMapComponent(menu.holomap, ConvertIDTo64Bit(groups[rowdata[3]].subordinates[1]), true)
								menu.addSelectedComponents(groups[rowdata[3]].subordinates, modified ~= "shift")
							end
						elseif isplayerowned and isonlineobject then
							local assigneddock = ConvertIDTo64Bit(GetComponentData(convertedRowComponent, "assigneddock"))
							if assigneddock then
								local container = C.GetContextByClass(assigneddock, "container", false)
								if container then
									C.SetFocusMapComponent(menu.holomap, container, true)
								end
							end
						else
							C.SetFocusMapComponent(menu.holomap, convertedRowComponent, true)
						end
					end
				end
			end
		end
	elseif menu.infoTableMode == "plots" then
		if menu.plotDoNotUpdate then
			menu.plotDoNotUpdate = nil
		elseif menu.table_plotlist and (uitable == menu.table_plotlist.id) then
			if rowdata == "plots_new" then
				menu.updatePlotData("plots_new", true)
			else
				C.SetFocusMapComponent(menu.holomap, rowdata, true)
			end
			menu.updatePlotData(rowdata)
		end
	elseif (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				menu.missionModeCurrent = rowdata[1]
				local missionid = ConvertStringTo64Bit(rowdata[1])
				if menu.contextMenuData and menu.contextMenuData.missionid and (menu.contextMenuData.missionid == missionid) then
					menu.closeContextMenu()
					menu.missionModeContext = nil
				else
					menu.closeContextMenu()
					menu.showMissionContext(missionid)
					menu.missionModeContext = true
				end
			elseif type(rowdata) == "string" then
				menu.missionModeCurrent = rowdata
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				else
					menu.closeContextMenu()
					menu.missionModeContext = nil
				end
			end
		end
	elseif (menu.infoTableMode == "info") then
		if (isdblclick or (input ~= "mouse")) then
			if (rowdata == "info_focus") or ((type(rowdata) == "table") and (rowdata[1] == "info_focus")) then
				C.SetFocusMapComponent(menu.holomap, menu.infoSubmenuObject, true)
			end
		end
	end

	if (menu.searchTableMode == "info") then
		if (isdblclick or (input ~= "mouse")) then
			if (rowdata == "info_focus") or ((type(rowdata) == "table") and (rowdata[1] == "info_focus")) then
				C.SetFocusMapComponent(menu.holomap, menu.infoSubmenuObject, true)
			end
		end
	end
end
function newFuncs.onRenderTargetSelect(modified)
	local menu = mapMenu

	local offset = table.pack(GetLocalMousePosition())
	-- Check if the mouse button was down less than 0.5 seconds and the mouse was moved more than a distance of 5px
	if (not menu.leftdown) or ((menu.leftdown.time + 0.5 > getElapsedTime()) and not Helper.comparePositions(menu.leftdown.position, offset, 5)) then
		if menu.mode == "selectbuildlocation" then
			local station = 0
			if menu.plotData.active then
				local offset = ffi.new("UIPosRot")
				local offsetvalid = C.GetBuildMapStationLocation(menu.holomap, offset)
				if offsetvalid then
					AddUITriggeredEvent(menu.name, "plotplaced")
					station = C.ReserveBuildPlot(menu.plotData.sector, "player", menu.plotData.set, offset, menu.plotData.size.x * 1000, menu.plotData.size.y * 1000, menu.plotData.size.z * 1000)
					if GetComponentData(ConvertStringTo64Bit(tostring(menu.plotData.sector)), "isplayerowned") then
						local size = { x = menu.plotData.size.x * 1000, y = menu.plotData.size.y * 1000, z = menu.plotData.size.z * 1000 }
						local plotcenter = { x = offset.x, y = offset.y, z = offset.z }
						C.PayBuildPlotSize(station, size, plotcenter)
					end
					C.ClearMapBuildPlot(menu.holomap)
					menu.plotData.active = nil
				end
			else
				local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
				local pickedcomponentclass = ffi.string(C.GetRealComponentClass(pickedcomponent))
				if (pickedcomponentclass == "station") and GetComponentData(ConvertStringToLuaID(tostring(pickedcomponent)), "isplayerowned") then
					station = pickedcomponent
				end
			end

			if station ~= 0 then
				for _, row in ipairs(menu.table_plotlist.rows) do
					if row.rowdata == station then
						menu.setplotrow = row.index
						menu.setplottoprow = (row.index - 12) > 1 and (row.index - 12) or 1
						break
					end
				end

				menu.updatePlotData(station, true)
				menu.refreshInfoFrame()
			end
		elseif menu.mode == "orderparam_position" then
			local offset = ffi.new("UIPosRot")
			local eclipticoffset = ffi.new("UIPosRot")
			local offsetcomponent = C.GetMapPositionOnEcliptic2(menu.holomap, offset, false, 0, eclipticoffset)
			if offsetcomponent ~= 0 then
				local class = ffi.string(C.GetComponentClass(offsetcomponent))
				if (not menu.modeparam[2].inputparams.class) or (class == menu.modeparam[2].inputparams.class) then
					menu.modeparam[1]({ConvertStringToLuaID(tostring(offsetcomponent)), {offset.x, offset.y, offset.z}})
				elseif (menu.modeparam[2].inputparams.class == "zone") and (class == "sector") then
					offsetcomponent = C.GetZoneAt(offsetcomponent, offset)
					menu.modeparam[1]({ConvertStringToLuaID(tostring(offsetcomponent)), {offset.x, offset.y, offset.z}})
				end
			end
		elseif (menu.mode == "orderparam_selectenemies") or (menu.mode == "orderparam_selectplayerdeployables") then
			menu.mode = nil
			menu.modeparam = {}
			SetMouseCursorOverride("default")
			menu.removeMouseCursorOverride(3)
		elseif menu.mode == "boardingcontext" then

		else
			local colspan = 1
			if menu.editboxHeight >= Helper.scaleY(config.mapRowHeight) then
				colspan = 2
			end
			Helper.confirmEditBoxInput(menu.searchField, 1, colspan + 2)
			local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
			local pickedorder = ffi.new("Order")
			local isintermediate = ffi.new("bool[1]", 0)
			local pickedordercomponent = C.GetPickedMapOrder(menu.holomap, pickedorder, isintermediate)
			local pickedcomponentclass = ffi.string(C.GetComponentClass(pickedcomponent))
			local ispickedcomponentship = C.IsComponentClass(pickedcomponent, "ship") and not C.IsUnit(pickedcomponent)
			local pickedtradeoffer = C.GetPickedMapTradeOffer(menu.holomap)
			if pickedordercomponent ~= 0 then
				local sectorcontext = C.GetContextByClass(pickedordercomponent, "sector", false)
				if sectorcontext ~= menu.currentsector then
					menu.currentsector = sectorcontext
				end

				menu.createInfoFrame()
			elseif pickedtradeoffer ~= 0 then
				local tradeid = ConvertStringToLuaID(tostring(pickedtradeoffer))
				local tradedata = GetTradeData(tradeid)
				if tradedata.ware then
					local setting = config.layersettings["layer_trade"][1]
					local rawwarelist = menu.getFilterOption(setting.id) or {}
					local found = false
					for i, ware in ipairs(rawwarelist) do
						if ware == tradedata.ware then
							found = i
							break
						end
					end
					AddUITriggeredEvent(menu.name, "filterwareselected", tradedata.isbuyoffer and "buyoffer" or "selloffer")
					if found then
						menu.removeFilterOption(setting, setting.id, found)
					else
						menu.setFilterOption("layer_trade", setting, setting.id, tradedata.ware)
					end
				end
			elseif pickedcomponent ~= 0 then
				if (not menu.sound_selectedelement) or (menu.sound_selectedelement ~= pickedcomponent) or (modified == "ctrl") or (modified == "shift") then
					local isselected = menu.isSelectedComponent(pickedcomponent)
					if (not isselected) and (modified == "shift") then
						PlaySound("ui_positive_multiselect")
					elseif modified == "ctrl" then
						if isselected then
							PlaySound("ui_positive_deselect")
						else
							PlaySound("ui_positive_multiselect")
						end
					elseif (pickedcomponentclass == "sector") then
						PlaySound("ui_positive_deselect")
					else
						PlaySound("ui_positive_select")
					end
				end
				menu.sound_selectedelement = pickedcomponent
				if menu.mode ~= "orderparam_object" then
					menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(pickedcomponent))
					if menu.infoTableMode == "info" then
						menu.refreshInfoFrame(nil, 0)
					elseif menu.searchTableMode == "info" then
						menu.refreshInfoFrame2(nil, 0)
					end
				end

				if pickedcomponentclass == "sector" then
					AddUITriggeredEvent(menu.name, "selection_reset")
					menu.clearSelectedComponents()
					if pickedcomponent ~= menu.currentsector then
						menu.currentsector = pickedcomponent
						menu.updateMapAndInfoFrame()
					end
				elseif (#menu.searchtext == 0) or Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.FilterComponentByText(pickedcomponent, numtexts, texts, true) end) then
					local isconstruction = IsComponentConstruction(ConvertStringTo64Bit(tostring(pickedcomponent)))
					if (C.IsComponentOperational(pickedcomponent) and (pickedcomponentclass ~= "player") and (pickedcomponentclass ~= "collectablewares") and (not menu.createInfoFrameRunning)) or
						(pickedcomponentclass == "gate") or (pickedcomponentclass == "asteroid") or isconstruction
					then
						local sectorcontext = C.GetContextByClass(pickedcomponent, "sector", false)
						if sectorcontext ~= menu.currentsector then
							menu.currentsector = sectorcontext
						end
						
						if modified == "ctrl" then
							menu.toggleSelectedComponent(pickedcomponent)
						else
							if pickedcomponentclass == "station" then
								AddUITriggeredEvent(menu.name, "selection_station", ConvertStringTo64Bit(tostring(pickedcomponent)))
							end
							if (pickedcomponentclass == "ship_s") or (pickedcomponentclass == "ship_m") or (pickedcomponentclass == "ship_l") or (pickedcomponentclass == "ship_xl") then
								AddUITriggeredEvent(menu.name, "selection_ship", ConvertStringTo64Bit(tostring(pickedcomponent)))
							end
							if (pickedcomponentclass == "resourceprobe") then
								AddUITriggeredEvent(menu.name, "selection_resourceprobe", ConvertStringTo64Bit(tostring(pickedcomponent)))
							end

							local newmode
							if (menu.mode ~= "selectComponent") or (menu.modeparam[3] ~= "deployables") then
								-- start kuertee_lua_with_callbacks:
								-- if menu.infoTableMode == "objectlist" then
								if string.find ("" .. tostring (menu.infoTableMode), "objectlist") then
								-- end kuertee_lua_with_callbacks:
									local isdeployable = GetComponentData(ConvertStringTo64Bit(tostring(pickedcomponent)), "isdeployable")
									if isdeployable or (pickedcomponentclass == "lockbox") then
										newmode = "deployables"
									elseif menu.objectMode ~= "objectall" then
										if C.IsRealComponentClass(pickedcomponent, "station") then
											newmode = "stations"
										elseif ispickedcomponentship then
											local found = false
											local commanderlist = GetAllCommanders(ConvertStringTo64Bit(tostring(pickedcomponent)))
											for i, entry in ipairs(commanderlist) do
												if IsComponentClass(entry, "station") then
													found = true
													break
												end
											end
											if found then
												newmode = "stations"
											else
												newmode = "ships"
											end
										end
									end
								-- start kuertee_lua_with_callbacks:
								-- elseif menu.infoTableMode == "propertyowned" then
								elseif string.find ("" .. tostring (menu.infoTableMode), "propertyowned") then
								-- end kuertee_lua_with_callbacks:
									local isplayerowned, isdeployable = GetComponentData(ConvertStringTo64Bit(tostring(pickedcomponent)), "isplayerowned", "isdeployable")
									if isplayerowned then
										if isdeployable or (pickedcomponentclass == "lockbox") then
											newmode = "deployables"
										elseif menu.propertyMode ~= "propertyall" then
											if C.IsRealComponentClass(pickedcomponent, "station") then
												newmode = "stations"
											elseif ispickedcomponentship then
												local found = false
												local commanderlist = GetAllCommanders(ConvertStringTo64Bit(tostring(pickedcomponent)))
												for i, entry in ipairs(commanderlist) do
													if IsComponentClass(entry, "station") then
														found = true
														break
													end
												end
												if found then
													newmode = "stations"
												else
													if #commanderlist > 0 then
														newmode = "fleets"
													else
														newmode = "unassignedships"
													end
												end
											end
										end
									end
								end
							end
							menu.addSelectedComponent(pickedcomponent, not modified)
							if newmode then
								-- start kuertee_lua_with_callbacks:
								-- if menu.infoTableMode == "objectlist" then
								if string.find ("" .. tostring (menu.infoTableMode), "objectlist") then
								-- end kuertee_lua_with_callbacks:
									if newmode ~= menu.objectMode then
										menu.objectMode = newmode
										menu.refreshInfoFrame()
									end
								-- start kuertee_lua_with_callbacks:
								-- elseif menu.infoTableMode == "propertyowned" then
								elseif string.find ("" .. tostring (menu.infoTableMode), "propertyowned") then
								-- end kuertee_lua_with_callbacks:
									if newmode ~= menu.propertyMode then
										menu.propertyMode = newmode
										menu.refreshInfoFrame()
									end
								end
							end
						end
					end
				end
			else
				if (menu.mode ~= "info") or (not menu.infoMode.left) or (menu.infoMode.left == "objectinfo") or (menu.infoMode.left == "objectcrew") or (menu.infoMode.left == "objectloadout") then
					AddUITriggeredEvent(menu.name, "selection_reset")
					menu.clearSelectedComponents()
				end
			end
		end
	end
	menu.leftdown = nil
end
function newFuncs.onTableRightMouseClick(uitable, row, posx, posy)
	local menu = mapMenu

	if (menu.mode == "orderparam_position") then
		menu.resetOrderParamMode()
	else
		if row > (menu.numFixedRows or 0) then
			local rowdata = menu.rowDataMap[uitable] and menu.rowDataMap[uitable][row]
			-- start kuertee_lua_with_callbacks:
			-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
			if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
			-- end kuertee_lua_with_callbacks:
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						local convertedRowComponent = ConvertIDTo64Bit(rowdata[2])
						if convertedRowComponent and (convertedRowComponent ~= 0) then
							local x, y = GetLocalMousePosition()
							if menu.mode == "hire" then
								if GetComponentData(convertedRowComponent, "isplayerowned") and C.IsComponentClass(convertedRowComponent, "controllable") then
									menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
									menu.contextMenuMode = "select"
									menu.createContextFrame(menu.selectWidth)
								end
							elseif menu.mode == "selectCV" then
								menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
								menu.contextMenuMode = "select"
								menu.createContextFrame(menu.selectWidth)
							elseif menu.mode == "orderparam_object" then
								if menu.checkForOrderParamObject(convertedRowComponent) then
									menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
									menu.contextMenuMode = "select"
									menu.createContextFrame(menu.selectWidth)
								end
							elseif menu.mode == "selectComponent" then
								if menu.checkForSelectComponent(convertedRowComponent) then
									menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
									menu.contextMenuMode = "select"
									menu.createContextFrame(menu.selectWidth)
								end
							else
								local missions = {}
								Helper.ffiVLA(missions, "MissionID", C.GetNumMapComponentMissions, C.GetMapComponentMissions, menu.holomap, convertedRowComponent)
								
								local playerships, otherobjects, playerdeployables = menu.getSelectedComponentCategories()
								if rowdata[1] == "construction" then
									menu.interactMenuComponent = convertedRowComponent
									Helper.openInteractMenu(menu, { component = convertedRowComponent, playerships = playerships, otherobjects = otherobjects, playerdeployables = playerdeployables, mouseX = posx, mouseY = posy, construction = rowdata[3], componentmissions = missions })
								elseif string.find(rowdata[1], "subordinates") then
									menu.interactMenuComponent = convertedRowComponent
									Helper.openInteractMenu(menu, { component = convertedRowComponent, playerships = playerships, otherobjects = otherobjects, playerdeployables = playerdeployables, mouseX = posx, mouseY = posy, subordinategroup = rowdata[3], componentmissions = missions })
								else
									menu.interactMenuComponent = convertedRowComponent
									Helper.openInteractMenu(menu, { component = convertedRowComponent, playerships = playerships, otherobjects = otherobjects, playerdeployables = playerdeployables, mouseX = posx, mouseY = posy, componentmissions = missions })
								end
							end
						end
					end
				end
			elseif menu.infoTableMode == "info" then
				if uitable == menu.infoTable then
					menu.prepareInfoContext(rowdata, "left")
				end
			elseif menu.infoTableMode == "missionoffer" then
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						menu.closeContextMenu()

						local missionid = ConvertStringTo64Bit(rowdata[1])
						local playerships, otherobjects, playerdeployables = menu.getSelectedComponentCategories()
						Helper.openInteractMenu(menu, { missionoffer = missionid, playerships = playerships, otherobjects = otherobjects, playerdeployables = playerdeployables })
					end
				end
			elseif menu.infoTableMode == "mission" then
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						menu.closeContextMenu()

						local missionid = ConvertStringTo64Bit(rowdata[1])
						local playerships, otherobjects, playerdeployables = menu.getSelectedComponentCategories()
						Helper.openInteractMenu(menu, { mission = missionid, playerships = playerships, otherobjects = otherobjects, playerdeployables = playerdeployables })
					end
				end
			end

			if menu.searchTableMode == "info" then
				if uitable == menu.infoTableRight then
					menu.prepareInfoContext(rowdata, "right")
				end
			end
		else
			menu.closeContextMenu()
		end
	end
end
function newFuncs.onInteractiveElementChanged(element)
	local menu = mapMenu

	menu.lastactivetable = element
	-- start kuertee_lua_with_callbacks:
	-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
	if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
	-- end kuertee_lua_with_callbacks:
		if menu.lastactivetable == menu.infoTable then
			if not menu.arrowsRegistered then
				RegisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = true
			end
		else
			if menu.arrowsRegistered then
				UnregisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = nil
			end
		end
	end
end
function newFuncs.closeContextMenu(dueToClose)
	local menu = mapMenu

	if Helper.closeInteractMenu() then
		return true
	end
	if menu.contextMenuMode then
		if menu.contextMenuMode == "trade" then
			if C.IsComponentOperational(menu.contextMenuData.currentShip) then
				SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), false)
			end
			if menu.contextMenuData.wareexchange then
				if C.IsComponentOperational(menu.contextMenuData.component) then
					SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), false)
				end
			end

			-- start kuertee_lua_with_callbacks:
			-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
			if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
			-- end kuertee_lua_with_callbacks:
				if not menu.arrowsRegistered then
					RegisterAddonBindings("ego_detailmonitor", "map_arrows")
					menu.arrowsRegistered = true
				end
			end
		elseif menu.contextMenuMode == "mission" then
			if menu.contextMenuData.isoffer then
				UnregisterEvent("missionofferremoved", menu.onMissionOfferRemoved)
			else
				UnregisterEvent("missionremoved", menu.onMissionRemoved)
			end
		elseif menu.contextMenuMode == "boardingcontext" then
			-- restore old mode and old info table mode
			menu.mode = menu.oldmode
			menu.oldmode = nil
			menu.infoTableMode = menu.oldInfoTableMode
			menu.refreshMainFrame = true
			menu.oldInfoTableMode = nil
			menu.boardingData = {}
			menu.contexttoprow = nil
			menu.contextselectedrow = nil
		end
		-- REMOVE this block once the mouse out/over event order is correct -> This should be unnessecary due to the global tablemouseout event reseting the picking
		if menu.currentMouseOverTable and (
			(menu.currentMouseOverTable == menu.contexttable)
			or (menu.currentMouseOverTable == menu.contextshiptable)
			or (menu.currentMouseOverTable == menu.contextbuttontable)
			or (menu.currentMouseOverTable == menu.contextdesctable)
			or (menu.currentMouseOverTable == menu.contextobjectivetable)
			or (menu.currentMouseOverTable == menu.contextbottomtable)
			or (menu.contextMenuMode == "boardingcontext")
			or (menu.contextMenuMode == "dropwares")
			or (menu.contextMenuMode == "crewtransfer")
			or (menu.contextMenuMode == "rename")
			or (menu.contextMenuMode == "userquestion")
			or (menu.contextMenuMode == "mission")
		) then
			menu.picking = true
			menu.currentMouseOverTable = nil
		end
		-- END
		menu.contextFrame = nil
		Helper.clearFrame(menu, config.contextFrameLayer)
		menu.contextMenuData = {}
		menu.contextMenuMode = nil
		if (menu.mode == "tradecontext") or (menu.mode == "dropwarescontext") or (menu.mode == "renamecontext") or (menu.mode == "crewtransfercontext") or menu.closemapwithmenu then
			Helper.closeMenu(menu, dueToClose)
			menu.cleanup()
		end
		return true
	end
	return false
end
function newFuncs.updateSelectedComponents(modified, keepselection, changedComponent)
	local menu = mapMenu

	local components = {}
	local rows, highlightedborderrow = GetSelectedRows(menu.infoTable)

	for _, row in ipairs(rows) do
		local rowdata = menu.rowDataMap[menu.infoTable][row]
		if type(rowdata) == "table" then
			if (rowdata[1] ~= "moduletype") and (not string.find(rowdata[1], "subordinates")) and (rowdata[1] ~= "dockedships") and (rowdata[1] ~= "constructions") then
				if rowdata[1] == "construction" then
					if rowdata[3].component ~= 0 then
						table.insert(components, ConvertStringTo64Bit(tostring(rowdata[3].component)))
					end
				else
					table.insert(components, rowdata[2])
				end
			end
		end
	end

	if modified or keepselection then
		for id in pairs(menu.selectedcomponents) do
			local component = ConvertStringTo64Bit(id)
			-- keep gates, satellites, etc. selected even if they don't have their own list entries
			if C.IsComponentClass(component, "gate") or C.IsComponentClass(component, "asteroid") or C.IsComponentClass(component, "buildstorage") or C.IsComponentClass(component, "highwayentrygate") then
				table.insert(components, component)
			end
			-- start kuertee_lua_with_callbacks:
			-- if menu.infoTableMode == "propertyowned" then
			if string.find ("" .. tostring (menu.infoTableMode), "propertyowned") then
			-- end kuertee_lua_with_callbacks:
				local isplayerowned, isdeployable = GetComponentData(component, "isplayerowned", "isdeployable")
				if not isplayerowned then
					-- keep npc ships selected
					table.insert(components, component)
				elseif menu.propertyMode ~= "propertyall" then
					-- keep other property selected that is currently not displayed
					if (menu.propertyMode ~= "stations") and C.IsRealComponentClass(component, "station") then
						table.insert(components, component)
					end
					if (modified ~= "ctrl") or (component ~= changedComponent) then
						if C.IsComponentClass(component, "ship") then
							table.insert(components, component)
						end
					end
				end
				if (menu.propertyMode ~= "deployables") and (isdeployable or C.IsComponentClass(component, "lockbox")) then
					table.insert(components, component)
				end
			-- start kuertee_lua_with_callbacks:
			-- elseif menu.infoTableMode == "objectlist" then
			elseif string.find ("" .. tostring (menu.infoTableMode), "objectlist") then
			-- end kuertee_lua_with_callbacks:
				local isdeployable = GetComponentData(component, "isdeployable")
				if menu.objectMode ~= "objectall" then
					-- keep other property selected that is currently not displayed
					if (menu.objectMode ~= "stations") and C.IsRealComponentClass(component, "station") then
						table.insert(components, component)
					end
						if (modified ~= "ctrl") or (component ~= changedComponent) then
						if C.IsComponentClass(component, "ship") then
							table.insert(components, component)
						end
					end
				end
				if (menu.objectMode ~= "deployables") and (isdeployable or C.IsComponentClass(component, "lockbox")) then
					table.insert(components, component)
				end
			end
		end
	end

	local rowdata = menu.rowDataMap[menu.infoTable][highlightedborderrow]
	if type(rowdata) == "table" then
		menu.highlightedbordercomponent = rowdata[2]
		if rowdata[1] == "construction" then
			if rowdata[3].component ~= 0 then
				menu.highlightedbordercomponent = ConvertStringTo64Bit(tostring(rowdata[3].component))
			end
		end
		local oldselectedstationcategory = menu.selectedstationcategory
		menu.highlightedbordermoduletype = nil
		menu.highlightedborderstationcategory = nil
		menu.selectedstationcategory = nil
		menu.highlightedplannedmodule = nil
		menu.highlightedconstruction = nil
		menu.selectedconstruction = nil
		if rowdata[1] == "moduletype" then
			menu.highlightedbordermoduletype = rowdata[3]
		elseif rowdata[1] == "module" then
			menu.highlightedbordermoduletype = rowdata[3]
			if rowdata[6] then
				menu.highlightedbordercomponent = rowdata[5]
				menu.highlightedplannedmodule = rowdata[6]
			end
		elseif string.find(rowdata[1], "subordinates") then
			menu.highlightedborderstationcategory = rowdata[1]
			if (keepselection and (oldselectedstationcategory == rowdata[1])) or (modified ~= "ctrl") then
				menu.selectedstationcategory = rowdata[1]
			end
		elseif rowdata[1] == "dockedships" then
			menu.highlightedborderstationcategory = "dockedships"
		elseif rowdata[1] == "constructions" then
			menu.highlightedborderstationcategory = "constructions"
		elseif rowdata[1] == "construction" then
			menu.highlightedconstruction = rowdata[3]
			if (modified ~= "ctrl") then
				menu.selectedconstruction = rowdata[3]
			end
		end
		menu.highlightedbordersection = nil
	elseif type(rowdata) == "string" then
		menu.highlightedbordercomponent = nil
		menu.highlightedbordermoduletype = nil
		menu.highlightedborderstationcategory = nil
		menu.selectedstationcategory = nil
		menu.highlightedconstruction = nil
		menu.selectedconstruction = nil
		menu.highlightedbordersection = rowdata
	end

	menu.addSelectedComponents(components, modified)
end
function newFuncs.updateTableSelection(lastcomponent)
	local menu = mapMenu

	menu.refreshMainFrame = true
	-- if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
	-- start kuertee_lua_with_callbacks:
	if (string.find ("" .. tostring (menu.infoTableMode), "objectlist")) or (string.find ("" .. tostring (menu.infoTableMode), "propertyowned")) then
	-- end kuertee_lua_with_callbacks:
		-- check if sections need to be extended - if so we need a refresh
		local refresh = false
		for id in pairs(menu.selectedcomponents) do
			local component = ConvertStringTo64Bit(id)
			-- build queues contain components that are not connected to the universe yet
			if IsValidComponent(component) then
				local commanderlist = C.IsComponentClass(component, "controllable") and GetAllCommanders(component) or {}
				for i, entry in ipairs(commanderlist) do
					if (not menu.isPropertyExtended(tostring(entry))) then
						menu.extendedproperty[tostring(entry)] = true
						refresh = true
					end
				end
			end
		end
		if refresh then
			menu.refreshInfoFrame()
			return
		end

		if menu.rowDataMap[menu.infoTable] then
			local rows = {}
			local curRow
			for row, rowdata in pairs(menu.rowDataMap[menu.infoTable]) do
				if type(rowdata) == "table" then
					if rowdata[1] == nil then
						print(TraceBack())
					end
					if (rowdata[1] ~= "moduletype") and (not string.find(rowdata[1], "subordinates")) and (rowdata[1] ~= "dockedships") and (rowdata[1] ~= "constructions") and (rowdata[1] ~= "construction") and menu.isSelectedComponent(rowdata[2]) then
						table.insert(rows, row)
						if ConvertStringTo64Bit(tostring(rowdata[2])) == lastcomponent then
							curRow = row
						end
					elseif (rowdata[1] == "construction") and (rowdata[3].component ~= 0) and menu.isSelectedComponent(rowdata[3].component) then
						table.insert(rows, row)
						if ConvertStringTo64Bit(tostring(rowdata[3].component)) == lastcomponent then
							curRow = row
						end
					elseif (rowdata[1] == "construction") and rowdata[2] and menu.selectedconstruction and (menu.selectedconstruction.id == rowdata[3].id) then
						table.insert(rows, row)
						if ConvertStringTo64Bit(tostring(rowdata[2])) == lastcomponent then
							curRow = row
						end
					elseif string.find(rowdata[1], "subordinates") and (rowdata[1] == menu.selectedstationcategory) then
						table.insert(rows, row)
					end
				end
			end
			SetSelectedRows(menu.infoTable, rows, curRow or (Helper.currentTableRow[menu.infoTable] or 0))
		end
	end
	menu.setSelectedMapComponents()
end
init ()
