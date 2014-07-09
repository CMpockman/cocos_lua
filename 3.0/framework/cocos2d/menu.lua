--=======================================================================
-- File Name    : menu.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not Menu then
	Menu = {}
end

function Menu:GenerateByImage(element_list, params)

	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0
	
	local menu_array = {}
	
	local item_height = 0
	local y = 0
	local max_width = 0
	local width_sum = 0
	for row, row_elements in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(row_elements) do
			local menu = cc.MenuItemImage:create(
				element.normal_image,
				element.selected_image,
				element.disabled_image
			)
			menu:registerScriptTapHandler(element.callback_function)
			local item_width = menu:getContentSize().width
			if item_height == 0 then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array+ 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	return menu_array, max_width, -y
end

function Menu:GenerateByString(element_list, params)
	local font_file_path = params.font_file_path or "framework/fonts/msyh.ttf"
	local font_size = params.font_size or 16
	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0
	local font_color = params.color
	local outline_color = params.outline_color
	local outline_width = params.outline_width

	local menu_array = {}

	local item_height = 0
	local y = 0
	local max_width = 0
	local width_sum = 0

	local ttfConfig = {}
    ttfConfig.fontFilePath = font_file_path
    ttfConfig.fontSize = font_size
    ttfConfig.glyphs = cc.GLYPHCOLLECTION_CUSTOM

	for row, row_elements in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(row_elements) do
			local ccLabel = cc.Label:createWithTTF(ttfConfig, element["item_name"] or "错误的菜单项")
			if outline_color and outline_width then
				ccLabel:enableOutline(outline_color, outline_width)
			end
			if font_color then
				ccLabel:setColor(Def:GetColor(font_color))
			end
			local menu = CCMenuItemLabel:create(ccLabel)
			menu:registerScriptTapHandler(element["callback_function"])
			local item_width = menu:getContentSize().width
			if item_height == 0 then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array + 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	return menu_array, max_width, -y
end

function Menu:GenerateBySprite(element_list, params)
	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0
	
	local menu_array = {}

	local item_height = 0
	local y = 0
	local max_width = 0
	local width_sum = 0
	for row, tbRow in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(tbRow) do
			local menu = CCMenuItemSprite:create(
				element.sprite_normal,
				element.sprite_selected,
				element.sprite_disable
			)
			menu:registerScriptTapHandler(element.callback_function)

			local item_width = menu:getContentSize().width
			if item_height == 0 then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array+ 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	return menu_array, max_width, -y
end

