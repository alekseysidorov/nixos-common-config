let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {
        if ($in | path exists) {$'"($in | str replace "\"" "\\\"" )"'} else {$in}
    }
}

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        nu => $carapace_completer
        _ => $fish_completer
    } | do $in $spans
}

let menu_style = {
    text: white_bold                     # Text style
    selected_text: white_reverse         # Text style for selected option
    description_text: yellow_dimmed      # Text style for description
}

$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }

    color_config: {
        header: white_bold
        string: yellow
        int: light_yellow
    }

    menus: [
        {
            name: help_menu
            only_buffer_difference: true # Search is done on the text written after activating the menu
            marker: "? "                 # Indicator that appears with the menu is active
            type: {
                layout: description      # Type of menu
                columns: 4               # Number of columns where the options are displayed
                col_width: 20            # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2           # Padding between columns
                selection_rows: 4        # Number of rows allowed to display found options
                description_rows: 10     # Number of rows allowed to display command description
            }
            style: {
                text: green                   # Text style
                selected_text: green_reverse  # Text style for selected option
                description_text: yellow      # Text style for description
            }
        }
        {
            name: completion_menu
            only_buffer_difference: false # Search is done on the text written after activating the menu
            marker: "| "                  # Indicator that appears with the menu is active
            type: {
                layout: columnar          # Type of menu
                columns: 4                # Number of columns where the options are displayed
                col_padding: 2            # Padding between columns
            }
            style: $menu_style
        },
        {
            name: history_menu
            only_buffer_difference: true # Search is done on the text written after activating the menu
            marker: "? "                 # Indicator that appears with the menu is active
            type: {
                layout: list             # Type of menu
                page_size: 10            # Number of entries that will presented when activating the menu
            }
            style: $menu_style
        }
    ]
}
