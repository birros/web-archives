public class WebArchives.Persistence : Object {
    private Database database;
    private ArchiveDatabase archive_database;
    private SearchRecentDatabase search_recent_database;
    private BookmarkDatabase bookmark_database;
    private HistoryDatabase history_database;
    private TimestampDatabase timestamp_database;

    public Persistence (Context context) {
        database = new Database ();
        archive_database = new ArchiveDatabase (
            database, context.archive_store
        );
        search_recent_database = new SearchRecentDatabase (
            database, context.search_recent_store
        );
        bookmark_database = new BookmarkDatabase (
            database, context.bookmark_store
        );
        history_database = new HistoryDatabase (
            database, context.history_store
        );
        timestamp_database = new TimestampDatabase (
            database, context.tracker, context.remote
        );
    }
}
