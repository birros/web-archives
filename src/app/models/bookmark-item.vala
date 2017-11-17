public class WebArchives.BookmarkItem : Object {
    public string title {get; private set;}
    public string url   {get; private set;}
    public string name  {get; private set;}

    public BookmarkItem (
        string title = "",
        string url = "",
        string name = ""
    ) {
        this.title = title;
        this.url = url;
        this.name = name;
    }
}
