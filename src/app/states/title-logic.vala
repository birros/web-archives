public class WebArchives.TitleLogic : Object {
    private Context context;

    public TitleLogic (Context context) {
        this.context = context;

        context.route_state.notify["route"].connect (update_title);
        context.web_view_state.notify["title"].connect (update_title);

        update_title ();
    }

    private void update_title () {
        switch (context.route_state.route) {
            case RouteState.Route.HOME:
            {
                context.title_state.title = _("WebArchives");
                context.title_state.subtitle = "";
                break;
            }
            case RouteState.Route.DETAILS:
            {
                context.title_state.title = _("Details");
                context.title_state.subtitle =
                    context.archive_state.archive.title;
                break;
            }
            case RouteState.Route.WEB:
            {
                context.title_state.title = context.web_view_state.title;
                context.title_state.subtitle =
                    context.archive_state.archive.title;
                break;
            }
            case RouteState.Route.BOOKMARK:
            {
                context.title_state.title = _("Bookmarks");
                context.title_state.subtitle =
                    context.archive_state.archive.title;
                break;
            }
            case RouteState.Route.HISTORY:
            {
                context.title_state.title = _("History");
                context.title_state.subtitle =
                    context.archive_state.archive.title;
                break;
            }
        }
    }
}
