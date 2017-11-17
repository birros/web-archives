public class WebArchives.NavigationLogic : Object {
    private Context context;

    public NavigationLogic (Context context) {
        this.context = context;

        context.archive_state.notify.connect (update_navigation);
        context.route_state.notify.connect (update_navigation);
        context.web_view_state.notify.connect (update_navigation);

        context.navigation_state.go_home.connect (on_go_home);
        context.navigation_state.go_back.connect (on_go_back);
        context.navigation_state.go_forward.connect (on_go_forward);

        update_navigation ();
    }

    private void update_navigation () {
        switch (context.route_state.route) {
            case RouteState.Route.HOME:
            {
                context.navigation_state.can_go_back = false;
                if (context.archive_state.archive != null) {
                    context.navigation_state.can_go_forward = true;
                } else {
                    context.navigation_state.can_go_forward = false;
                }
                break;
            }
            case RouteState.Route.WEB:
            {
                context.navigation_state.can_go_back = true;
                if (context.web_view_state.can_go_forward) {
                    context.navigation_state.can_go_forward = true;
                } else {
                    context.navigation_state.can_go_forward = false;
                }
                break;
            }
        }
    }

    private void on_go_home () {
        context.route_state.route = RouteState.Route.HOME;
        context.web_view_state.go_home ();
    }

    private void on_go_back () {
        switch (context.route_state.route) {
            case RouteState.Route.WEB:
            {
                if (context.web_view_state.can_go_back) {
                    context.web_view_state.go_back ();
                } else {
                    context.route_state.route = RouteState.Route.HOME;
                }
                break;
            }
            case RouteState.Route.SEARCH:
            case RouteState.Route.SEARCHIN:
            case RouteState.Route.BOOKMARK:
            case RouteState.Route.DETAILS:
            case RouteState.Route.HISTORY:
            {
                context.route_state.route = context.route_state.last_route;
                break;
            }
        }
    }

    private void on_go_forward () {
        switch (context.route_state.route) {
            case RouteState.Route.HOME:
            {
                if (context.navigation_state.can_go_forward) {
                    context.route_state.route = RouteState.Route.WEB;
                }
                break;
            }
            case RouteState.Route.WEB:
            {
                context.web_view_state.go_forward ();
                break;
            }
        }
    }
}
