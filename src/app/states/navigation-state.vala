public class WebArchives.NavigationState : Object {
    public bool can_go_back    {set; get; default = false;}
    public bool can_go_forward {set; get; default = false;}

    public signal void go_home ();
    public signal void go_back ();
    public signal void go_forward ();
}
