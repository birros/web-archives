public class WebArchives.HeaderBarPopover : Gtk.Popover {
    private Context context;
    private ZoomBox zoom_box;
    private NightModeButton night_mode_button;
    private Gtk.Box box_archive;
    private Gtk.Separator separator;
    private ulong route_callback;

    public HeaderBarPopover () {
        position = Gtk.PositionType.BOTTOM;

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.margin = 10;
        add (box);

        // archive box
        box_archive = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (box_archive);

        zoom_box = new ZoomBox ();
        zoom_box.margin_bottom = 10;
        box_archive.add (zoom_box);

        Gtk.ModelButton search_in_button = new Gtk.ModelButton ();
        search_in_button.label = _("Search in...");
        search_in_button.xalign = 0;
        search_in_button.clicked.connect (on_search_in);
        box_archive.add (search_in_button);

        Gtk.ModelButton print_button = new Gtk.ModelButton ();
        print_button.label = _("Print");
        print_button.xalign = 0;
        print_button.clicked.connect (on_print);
        box_archive.add (print_button);

        box_archive.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.ModelButton main_page_button = new Gtk.ModelButton ();
        main_page_button.label = _("Main page");
        main_page_button.xalign = 0;
        main_page_button.clicked.connect (on_main_page);
        box_archive.add (main_page_button);

        Gtk.ModelButton random_button = new Gtk.ModelButton ();
        random_button.label = _("Random page");
        random_button.xalign = 0;
        random_button.clicked.connect (on_random);
        box_archive.add (random_button);

        box_archive.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.ModelButton bookmark_button = new Gtk.ModelButton ();
        bookmark_button.label = _("Bookmarks");
        bookmark_button.xalign = 0;
        bookmark_button.clicked.connect (on_bookmark);
        box_archive.add (bookmark_button);

        Gtk.ModelButton history_button = new Gtk.ModelButton ();
        history_button.label = _("History");
        history_button.xalign = 0;
        history_button.clicked.connect (on_history);
        box_archive.add (history_button);

        separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        box.add (separator);

        // app box
        Gtk.Box box_app = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (box_app);

        Gtk.ModelButton button = new Gtk.ModelButton ();
        button.label = _("New window");
        button.xalign = 0;
        button.clicked.connect (on_new_window);
        box_app.add (button);

        night_mode_button = new NightModeButton ();
        box_app.add (night_mode_button);

        box_app.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.ModelButton shortcuts_button = new Gtk.ModelButton ();
        shortcuts_button.label = _("Keyboard shortcuts");
        shortcuts_button.xalign = 0;
        shortcuts_button.action_name = "win.show-help-overlay";
        box_app.add (shortcuts_button);

        box.show_all ();
    }

    private void on_main_page () {
        context.main_page_state.main_page ();
    }

    private void on_random () {
        context.random_page_state.random ();
    }

    private void on_print () {
        context.print_state.print ();
    }

    private void on_bookmark () {
        context.route_state.route = RouteState.Route.BOOKMARK;
    }

    private void on_history () {
        context.route_state.route = RouteState.Route.HISTORY;
    }

    private void on_search_in () {
        context.route_state.route = RouteState.Route.SEARCHIN;
        context.search_in_state.focus ();
    }

    private void on_new_window () {
        context.popover_menu_state.new_window ();
    }

    private void on_route () {
        switch (context.route_state.route) {
            case RouteState.Route.WEB:
            case RouteState.Route.SEARCHIN:
            {
                box_archive.show ();
                separator.show ();
                break;
            }
            default:
            {
                box_archive.hide ();
                separator.hide ();
                break;
            }
        }
    }

    public void set_context (Context context) {
        if (this.context != null) {
            this.context.route_state.disconnect (route_callback);
        }

        this.context = context;

        route_callback = context.route_state.notify["route"].connect (on_route);
        on_route ();

        zoom_box.set_context (context);
        night_mode_button.set_context (context);
    }
}
