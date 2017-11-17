public class WebArchives.Content : Gtk.Stack {
    private Context context;
    private HomeView home_view;
    private DetailsView details_view;
    private WebView web_view;
    private SearchView search_view;
    private BookmarkView bookmark_view;
    private HistoryView history_view;

    public Content (Context context) {
        this.context = context;
        transition_type = Gtk.StackTransitionType.CROSSFADE;

        home_view = new HomeView (context);
        add (home_view);

        details_view = new DetailsView (context);
        add (details_view);

        web_view = new WebView (context);
        add (web_view);

        search_view = new SearchView (context);
        add (search_view);

        bookmark_view = new BookmarkView (context);
        add (bookmark_view);

        history_view = new HistoryView (context);
        add (history_view);

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
            case RouteState.Route.HOME:
            {
                set_visible_child (home_view);
                break;
            }
            case RouteState.Route.WEB:
            {
                set_visible_child (web_view);
                break;
            }
            case RouteState.Route.SEARCH:
            {
                set_visible_child (search_view);
                break;
            }
            case RouteState.Route.DETAILS:
            {
                set_visible_child (details_view);
                break;
            }
            case RouteState.Route.BOOKMARK:
            {
                set_visible_child (bookmark_view);
                break;
            }
            case RouteState.Route.HISTORY:
            {
                set_visible_child (history_view);
                break;
            }
        }
    }

    ~Content () {
        info ("destroy");
    }
}
