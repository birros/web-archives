public class WebArchives.LoadUriLogic : Object {
    private Context context;

    public LoadUriLogic (Context context) {
        this.context = context;

        context.web_view_state.load_uri.connect (on_load_uri);
    }

    private void on_load_uri () {
        context.route_state.route = RouteState.Route.WEB;
    }
}
