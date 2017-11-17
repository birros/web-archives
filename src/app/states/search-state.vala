public class WebArchives.SearchState : Object {
    public string text {get; set; default = "";}

    public signal void key_down ();
    public signal void key_up ();
}
