public class WebArchives.ArchiveItem : Object {
    /**
     *  path: unique for RECENTS and LOCALE
     *  uuid: unique for REMOTE
     *  timestamp: used for RECENTS
     */
    public string path          {get; private set; default = "";}
    public string favicon       {get; private set; default = "";}
    public string title         {get; private set; default = "";}
    public string date          {get; private set; default = "";}
    public string lang          {get; private set; default = "";}
    public int64  size          {get; private set; default = 0; }
    public string name          {get; private set; default = "";}
    public string uuid          {get; private set; default = "";}
    public string tags          {get; private set; default = "";}
    public string description   {get; private set; default = "";}
    public int64  article_count {get; private set; default = 0; }
    public int64  media_count   {get; private set; default = 0; }
    public string creator       {get; set;         default = "";}
    public string publisher     {get; set;         default = "";}
    public string url           {get; private set; default = "";}
    public int64  timestamp     {get; private set; default = 0; }

    /**
     * We can modify scope only if it's empty.
     */
    private string _scope {get; private set; default = "";}
    public string scope {
        get {
            return _scope;
        }
        set {
            if (_scope == "") {
                _scope = value;
            } else {
                warning ("Trying to modify scope property");
            }
        }
    }

    public ArchiveItem (
        string path,
        string favicon,
        string title,
        string date,
        string lang,
        int64  size,
        string name,
        string uuid,
        string tags,
        string description,
        int64  article_count,
        int64  media_count,
        string creator,
        string publisher,
        string url,
        int64  timestamp = 0,
        string scope = ""
    ) {
        this.path = path;
        this.favicon = favicon;
        this.title = title;
        this.date = date;
        this.lang = lang;
        this.size = size;
        this.name = name;
        this.uuid = uuid;
        this.tags = tags;
        this.description = description;
        this.article_count = article_count;
        this.media_count = media_count;
        this.creator = creator;
        this.publisher = publisher;
        this.url = url;
        this.timestamp = timestamp;
        this.scope = scope;
    }

    public ArchiveItem.copy (ArchiveItem archive) {
        path = archive.path;
        favicon = archive.favicon;
        title = archive.title;
        date = archive.date;
        lang = archive.lang;
        size = archive.size;
        name = archive.name;
        uuid = archive.uuid;
        tags = archive.tags;
        description = archive.description;
        article_count = archive.article_count;
        media_count = archive.media_count;
        creator = archive.creator;
        publisher = archive.publisher;
        url = archive.url;
    }

    public void update_timestamp () {
        GLib.DateTime time = new GLib.DateTime.now_utc ();
        timestamp = time.to_unix ();
    }
}
