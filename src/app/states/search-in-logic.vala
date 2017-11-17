public class WebArchives.SearchInLogic : Object {
    private Context context;

    public SearchInLogic (Context context) {
        this.context = context;

        context.route_state.notify["route"].connect (update_search_in);
        update_search_in ();
    }

    private void update_search_in () {
        if (context.route_state.route != RouteState.Route.SEARCHIN) {
            context.search_in_state.text = "";
        }
    }
}
