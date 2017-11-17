public class WebArchives.HistoryItem : Object {
    public string title     {get; private set;}
    public string url       {get; private set;}
    public string name      {get; private set;}
    public int64  timestamp {get; private set; default = 0;}

    public HistoryItem (
        string title,
        string url,
        string name,
        int64  timestamp = 0
    ) {
        this.title = title;
        this.url = url;
        this.name = name;
        this.timestamp = timestamp;
    }

    public void update_timestamp () {
        GLib.DateTime time = new GLib.DateTime.now_utc ();
        timestamp = time.to_unix ();
    }
}
