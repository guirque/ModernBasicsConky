require 'cairo'
-- https://github.com/brndnmtthws/conky/wiki/Lua:-Drawing
-- https://conky.sourceforge.net/variables.html

function conky_main()
    -- Conky Docs: https://github.com/brndnmtthws/conky/wiki/Lua:-Evaluation

    if not conky_window then return end

    local surface = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)

    local cr = cairo_create(surface)

    cairo_destroy(cr)
end