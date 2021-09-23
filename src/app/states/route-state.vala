public class WebArchives.RouteState : Object {
    public enum Route {
        HOME,
        WEB,
        SEARCH,
        SEARCHIN,
        BOOKMARK,
        HISTORY
    }

    public Route last_route {get; private set;}
    private Route p_route {get; private set; default = Route.HOME;}
    public Route route {
        get {
            return p_route;
        }
        set {
            if (p_route != value) {
                last_route = p_route;
                p_route = value;
            }
        }
    }
}
