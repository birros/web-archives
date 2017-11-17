public class WebArchives.SearchInState : Object {
    public enum Key {
        DOWN,
        UP,
        PAGE_DOWN,
        PAGE_UP
    }

    public string text {get; set; default = "";}

    public signal void key (Key key);
    public signal void focus ();
    public signal void next ();
    public signal void previous ();
}
