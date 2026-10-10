require 'cairo'
require 'cairo_xlib'

-- https://github.com/brndnmtthws/conky/wiki/Lua:-Drawing
-- https://conky.sourceforge.net/variables.html


-- Helper function from https://github.com/brndnmtthws/conky/wiki/Lua:-Drawing
function hex_color(hex, alpha)
    return tonumber(hex:sub(1, 2), 16) / 255,
           tonumber(hex:sub(3, 4), 16) / 255,
           tonumber(hex:sub(5, 6), 16) / 255,
           alpha or 1
end

local bar_height = 242
function create_bar(cr, x, y, variable, name)
    -- Creating Bar
    cairo_set_source_rgba(cr, hex_color("FFFFFF", 0.2))
    cairo_rectangle(cr, x, y, 18, bar_height)
    cairo_fill(cr)

    -- Creating Filling
    cairo_set_source_rgba(cr, hex_color("FF1111", 1))
    local filling_size = bar_height * variable / 100
    cairo_rectangle(cr, x, y + (bar_height- filling_size), 18, filling_size)
    cairo_fill(cr)

    -- Write text
    cairo_set_source_rgba(cr, hex_color("FFFFFF", 1))
    cairo_move_to(cr, x-2, y + bar_height + 25)
    cairo_show_text(cr, name)
    cairo_move_to(cr, x-2, y + bar_height + 40)
    cairo_show_text(cr, variable.."%")

end

function conky_main()
    -- Conky Docs: https://github.com/brndnmtthws/conky/wiki/Lua:-Evaluation

    if not conky_window then return end

    local surface = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)

    local cr = cairo_create(surface)

    -- Getting variables ------------------------------------------
    local cpu_usage = conky_parse("${cpu}")
    local memory_used = conky_parse("${memperc}")
    local gpu_usage = conky_parse("${nvidia gpuutil}")

    -- Making Bars ------------------------------------------------
    create_bar(cr, 25, 200, memory_used, "RAM")
    create_bar(cr, 70, 200, cpu_usage, "CPU")
    create_bar(cr, 115, 200, gpu_usage, "GPU")
    cairo_stroke(cr)

    -- Making Processes Dashboard --------------------------------
    -- This section was drawn, because inconsistencies in size and custom colors go better
    -- when programmatically controlled.
    cairo_set_source_rgba(cr, hex_color("FFFFFF", 1))
    cairo_set_font_size(cr, 14)
    local x_ini = 160
    local y_ini = 440
    for i = 1, 4, 1 do
        cairo_move_to(cr, x_ini, y_ini + (i-1)* 15)
        local process_name = conky_parse("${top name "..i.."}")
        process_name = string.gsub(process_name, " ", "")
        local trimmed_name = string.sub(process_name, 1, 5)
        if string.len(process_name) > 5 then trimmed_name = trimmed_name.."..." end

        cairo_show_text(cr, trimmed_name)
        cairo_move_to(cr, x_ini+65, y_ini + (i-1)* 15)
        cairo_show_text(cr, conky_parse("${top cpu "..i.."}      ${top mem "..i.."}"))
    end

    cairo_destroy(cr)
end