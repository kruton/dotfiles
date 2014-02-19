" Set GUI font used
if has("gui_running")
    if has("gui_macvim")
        set guifont=Essential\ PragmataPro:h12
    elseif has("gui_gtk2")
        set guifont=Essential\ PragmataPro\ 10
    endif
endif
