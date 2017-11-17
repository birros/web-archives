public class WebArchives.BookmarkState : Object {
    public bool bookmarked {get; set; default = false;}

    public signal void toggle ();
}
