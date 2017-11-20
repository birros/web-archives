public class WebArchives.SearchBarLogic : Object {
    private Context context;

    public SearchBarLogic (Context context) {
        this.context = context;

        context.route_state.notify["route"].connect (update_search);
        update_search ();
    }

    private void update_search () {
        if (context.route_state.route != RouteState.Route.SEARCH) {
            context.search_state.text = "";
        }
    }
}
