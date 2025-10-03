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
        // box.margin = 10;
        set_child (box);

        // archive box
        box_archive = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (box_archive);

        zoom_box = new ZoomBox ();
        // zoom_box.margin_bottom = 10;
        zoom_box.homogeneous = true;
        box_archive.append (zoom_box);

        Gtk.Button search_in_button = new Gtk.Button.with_label (_("Search in..."));
        search_in_button.clicked.connect (on_search_in);
        box_archive.append (search_in_button);

        Gtk.Button print_button = new Gtk.Button.with_label (_("Print"));
        print_button.clicked.connect (on_print);
        box_archive.append (print_button);

        box_archive.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.Button main_page_button = new Gtk.Button.with_label (_("Main page"));
        main_page_button.clicked.connect (on_main_page);
        box_archive.append (main_page_button);

        Gtk.Button random_button = new Gtk.Button.with_label (_("Random page"));
        random_button.clicked.connect (on_random);
        box_archive.append (random_button);

        box_archive.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.Button bookmark_button = new Gtk.Button.with_label (_("Bookmarks"));
        bookmark_button.clicked.connect (on_bookmark);
        box_archive.append (bookmark_button);

        Gtk.Button history_button = new Gtk.Button.with_label (_("History"));
        history_button.clicked.connect (on_history);
        box_archive.append (history_button);

        separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        box.append (separator);

        // app box
        Gtk.Box box_app = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (box_app);

        Gtk.Button button = new Gtk.Button.with_label (_("New window"));
        button.clicked.connect (on_new_window);

        box_app.append (button);

        night_mode_button = new NightModeButton ();
        box_app.append (night_mode_button);

        box_app.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        Gtk.Button shortcuts_button = new Gtk.Button.with_label (_("Keyboard shortcuts"));
        shortcuts_button.action_name = "win.show-help-overlay";
        box_app.append (shortcuts_button);

        Gtk.Button about_button = new Gtk.Button.with_label (_("About"));
        about_button.clicked.connect (on_about);
        box_app.append (about_button);

        Gtk.Button quit_button = new Gtk.Button.with_label (_("Quit"));
        quit_button.action_name = "app.quit";
        box_app.append (quit_button);
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

    private void on_about () {
        context.about_state.show_about ();
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

