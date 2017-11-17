public class WebArchives.SearchRecentItem : Object {
    public string text      {get; private set;}
    public string name      {get; private set;}
    public int64  timestamp {get; private set;}

    public SearchRecentItem (
        string text,
        string name,
        int64  timestamp = 0
    ) {
        this.text = text;
        this.name = name;
        this.timestamp = timestamp;
    }

    public void update_timestamp () {
        GLib.DateTime time = new GLib.DateTime.now_utc ();
        timestamp = time.to_unix ();
    }
}
