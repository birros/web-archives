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
    private Route _route {get; private set; default = Route.HOME;}
    public Route route {
        get {
            return _route;
        }
        set {
            if (_route != value) {
                last_route = _route;
                _route = value;
            }
        }
    }
}
