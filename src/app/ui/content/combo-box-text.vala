public class WebArchives.ComboBoxText : Gtk.ToggleButton {
    private Gtk.ListBox listbox;
    public string active_text {get; set; default = "eng";}
    public signal void changed ();
    private bool binded;
    private LanguageModel language_model;
    private string search_text {get; set; default = "";}
    private Gtk.Popover popover;

    public class ComboBoxText () {
        binded = false;
        Gtk.Image image_widget = new Gtk.Image.from_icon_name (
            "pan-down-symbolic", Gtk.IconSize.MENU
        );

        notify["active-text"].connect (() => {
            update_label ();
        });
        update_label ();

        always_show_image = true;
        image_position = Gtk.PositionType.RIGHT;
        image = image_widget;

        popover = new Gtk.Popover (this);
        popover.set_size_request (300, 400);
        popover.hide.connect (() => {
            active = false;
        });

        Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.margin_top = 6;
        box.margin_end = 6;
        box.margin_bottom = 6;
        box.margin_start = 6;
        popover.add (box);

        Gtk.SearchEntry search_entry = new Gtk.SearchEntry ();
        search_entry.search_changed.connect (() => {
            search_text = search_entry.text;
            language_model.invalidate_filter ();
            popover.show_all ();
        });
        box.add (search_entry);

        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (
            null, null
        );
        scrolled_window.vexpand = true;
        box.add (scrolled_window);

        listbox = new Gtk.ListBox ();
        listbox.row_activated.connect (row => {
            ComboBoxRow combobox_row = (ComboBoxRow) row;
            string text = combobox_row.language_item.language;

            if (text != active_text) {
                active_text = text;
                update_label ();
                changed ();
            }
            popover.hide();
        });
        scrolled_window.add (listbox);


        toggled.connect (() => {
			if (active) {
				if (!binded) {
				    _bind_model ();
				}
				popover.show_all ();
			}
		});
    }

    private void update_label () {
        string language = LanguageFormater.format_language (active_text);
        label = language;
    }

    private void _bind_model () {
        int index = 0;
        int select_index = 0;
        listbox.bind_model (language_model, (obj) => {
            LanguageItem item = (LanguageItem) obj;
            if (item.language == active_text) {
                select_index = index;
            }
            index++;
            return new ComboBoxRow (item);
        });
        Gtk.ListBoxRow row = listbox.get_row_at_index (select_index);
        listbox.select_row (row);

        binded = true;
    }

    public void bind_model (LanguageModel language_model) {
        this.language_model = language_model;
        language_model.set_filter_func ((item) => {
            string language = LanguageFormater.format_language (
                item.language
            );

            language = language.down ();
            string search_text_down = search_text.down ();
            bool found = language.index_of (search_text_down) != -1;

            return found;
        });
        language_model.items_changed.connect ((position, removed, added) => {
            if (active) {
                popover.show_all ();
            }
        });
    }
}
