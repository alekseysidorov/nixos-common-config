let fish_completer = {|spans| fish --command
$'complete "--do-complete=($spans | str join
" "
)"'| $"value(char tab
)description(char newline
)"+$in | from tsv
--flexible
--no-infer
}let menu_style = {text:white_bold# Text styleselected_text:white_reverse# Text style for selected optiondescription_text:yellow_dimmed# Text style for description
}$env config={completions:{external:{enable:truecompleter:$fish_completer }}color_config:{header:white_boldstring:yellowint:light_yellow}menus:[{name:help_menuonly_buffer_difference:true# Search is done on the text written after activating the menumarker:"? "# Indicator that appears with the menu is activetype:{layout:description# Type of menucolumns:4# Number of columns where the options are displayedcol_width:20# Optional value. If missing all the screen width is used to calculate column widthcol_padding:2# Padding between columnsselection_rows:4# Number of rows allowed to display found optionsdescription_rows:10# Number of rows allowed to display command description
            }style:{text:green# Text styleselected_text:green_reverse# Text style for selected optiondescription_text:yellow# Text style for description
            }}{name:completion_menuonly_buffer_difference:false# Search is done on the text written after activating the menumarker:"| "# Indicator that appears with the menu is activetype:{layout:columnar# Type of menucolumns:4# Number of columns where the options are displayedcol_padding:2# Padding between columns
            }style:$menu_style },{name:history_menuonly_buffer_difference:true# Search is done on the text written after activating the menumarker:"? "# Indicator that appears with the menu is activetype:{layout:list# Type of menupage_size:10# Number of entries that will presented when activating the menu
            }style:$menu_style }]}
