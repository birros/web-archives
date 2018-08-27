public class WebArchives.HeaderBar : Gtk.HeaderBar {
    private Context context;
    private NewTabButton new_tab_button;
    private MenuButton menu_button;
    private NavigationBox navigation_box;
    private Gtk.Stack left_stack;
    private Gtk.Stack center_stack;
    private Gtk.Stack right_stack;
    private TitleBar title_bar;
    private SearchBar search_bar;
    private SearchInBar search_in_bar;
    private Gtk.Button back_button;
    private Gtk.Button search_button;
    private BookmarkButton bookmark_button;
    private Gtk.Box web_box;
    private Gtk.Label empty;

    private ulong title_callback;
    private ulong route_callback;

    public HeaderBar () {
        this.set_show_close_button (true);

        // left stack
        left_stack = new Gtk.Stack ();
        left_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        left_stack.set_homogeneous (false);
        pack_start (left_stack);

        navigation_box = new NavigationBox ();
        left_stack.add (navigation_box);

        back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic");
        back_button.clicked.connect (on_back);
        left_stack.add (back_button);

        // center stack
        center_stack = new Gtk.Stack ();
        center_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        center_stack.set_homogeneous (false);
        set_custom_title (center_stack);

        title_bar = new TitleBar ();
        center_stack.add (title_bar);

        search_bar = new SearchBar ();
        center_stack.add (search_bar);

        search_in_bar = new SearchInBar ();
        center_stack.add (search_in_bar);

        // right_box
        Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        pack_end (right_box);

        // right stack
        right_stack = new Gtk.Stack ();
        right_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        right_stack.set_homogeneous (false);
        right_stack.margin_end = 6;
        right_box.add (right_stack);

        // web box
        web_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        right_stack.add (web_box);

        search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic");
        search_button.tooltip_text = _("Search");
        search_button.clicked.connect (on_search);
        web_box.add (search_button);

        bookmark_button = new BookmarkButton ();
        web_box.add (bookmark_button);

        // empty
        empty = new Gtk.Label (null);
        right_stack.add (empty);

        // window box
        Gtk.Box window_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        right_box.add (window_box);

        new_tab_button = new NewTabButton ();
        window_box.add (new_tab_button);

        menu_button = new MenuButton ();
        window_box.add (menu_button);

        show_all ();
    }

    private void on_search () {
        context.route_state.route = RouteState.Route.SEARCH;
    }

    private void on_back () {
        context.route_state.route = context.route_state.last_route;
    }

    public void set_context (Context context) {
        if (this.context != null) {
            bool title_connected = SignalHandler.is_connected (
                this.context.title_state, title_callback
            );
            bool route_connected = SignalHandler.is_connected (
                this.context.route_state, route_callback
            );
            if (title_connected) {
                this.context.title_state.disconnect (title_callback);
            }
            if (route_connected) {
                this.context.route_state.disconnect (route_callback);
            }
        }

        this.context = context;

        title_callback = context.title_state.notify["title"].connect (() => {
            set_title_text ();
        });
        set_title_text ();

        route_callback = context.route_state.notify["route"].connect (() => {
            update_view ();
        });
        update_view ();

        navigation_box.set_context (context);
        title_bar.set_context (context);
        search_bar.set_context (context);
        search_in_bar.set_context (context);
        menu_button.set_context (context);
        new_tab_button.set_context (context);
        bookmark_button.set_context (context);
    }

    private void update_view () {
        switch (context.route_state.route) {
            case RouteState.Route.HOME:
            {
                center_stack.set_visible_child (title_bar);
                left_stack.set_visible_child (navigation_box);
                right_stack.set_visible_child (empty);
                break;
            }
            case RouteState.Route.WEB:
            {
                center_stack.set_visible_child (title_bar);
                left_stack.set_visible_child (navigation_box);
                right_stack.set_visible_child (web_box);
                break;
            }
            case RouteState.Route.SEARCH:
            {
                center_stack.set_visible_child (search_bar);
                left_stack.set_visible_child (back_button);
                right_stack.set_visible_child (empty);

                search_bar.grab_focus_without_selecting ();
                break;
            }
            case RouteState.Route.SEARCHIN:
            {
                center_stack.set_visible_child (search_in_bar);
                left_stack.set_visible_child (back_button);
                right_stack.set_visible_child (empty);

                context.search_in_state.focus ();
                break;
            }
            case RouteState.Route.BOOKMARK:
            case RouteState.Route.HISTORY:
            {
                center_stack.set_visible_child (title_bar);
                left_stack.set_visible_child (back_button);
                right_stack.set_visible_child (empty);
                break;
            }
        }
    }

    private void set_title_text () {
        if (context.route_state.route == RouteState.Route.HOME) {
            set_title ("WebArchives");
        } else {
            set_title (context.title_state.title + " - WebArchives");
        }
    }
}
