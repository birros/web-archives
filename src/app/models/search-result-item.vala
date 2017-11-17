public class WebArchives.SearchResultItem : Object {
    public string text {get; private set;}
    public string url  {get; private set;}

    public SearchResultItem (string text, string url) {
        this.text = text;
        this.url = url;
    }
}
