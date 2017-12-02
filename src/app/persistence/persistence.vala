public class WebArchives.Persistence : Object {
    private Database cache_database;
    private Database data_database;
    private ArchiveDatabase archive_database;
    private SearchRecentDatabase search_recent_database;
    private BookmarkDatabase bookmark_database;
    private HistoryDatabase history_database;
    private TimestampDatabase timestamp_database;

    public Persistence (Context context) {
        cache_database = new Database (Database.Type.CACHE);
        data_database = new Database (Database.Type.DATA);

        archive_database = new ArchiveDatabase (
            cache_database, context.archive_store
        );
        search_recent_database = new SearchRecentDatabase (
            cache_database, context.search_recent_store
        );
        history_database = new HistoryDatabase (
            cache_database, context.history_store
        );
        timestamp_database = new TimestampDatabase (
            cache_database, context.tracker, context.remote
        );

        bookmark_database = new BookmarkDatabase (
            data_database, context.bookmark_store
        );
    }
}
