public class WebArchives.Content : Adw.Bin {
    private Context context;
    private Gtk.Stack stack;

    private HomeView home_view;
    private WebView web_view;
    private SearchView search_view;
    private BookmarkView bookmark_view;
    private HistoryView history_view;

    public Content (Context context) {
        this.context = context;

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            hexpand = true,
            vexpand = true
        };

        // Add child views
        home_view = new HomeView (context);
        stack.add_child (home_view);

        web_view = new WebView (context);
        stack.add_child (web_view);

        search_view = new SearchView (context);
        stack.add_child (search_view);

        bookmark_view = new BookmarkView (context);
        stack.add_child (bookmark_view);

        history_view = new HistoryView (context);
        stack.add_child (history_view);

        // Put stack inside the bin
        set_child (stack);

        // Route handling
        context.route_state.notify["route"].connect (on_route);
    }

    public Context get_context () {
        return context;
    }

    public void set_context (Context context) {
        this.context = context;
    }

    private void on_route () {
        switch (context.route_state.route) {
            case RouteState.Route.HOME:     stack.set_visible_child (home_view); break;
            case RouteState.Route.WEB:      stack.set_visible_child (web_view); break;
            case RouteState.Route.SEARCH:   stack.set_visible_child (search_view); break;
            case RouteState.Route.BOOKMARK: stack.set_visible_child (bookmark_view); break;
            case RouteState.Route.HISTORY:  stack.set_visible_child (history_view); break;
            case RouteState.Route.SEARCHIN: break;
        }
    }
}

