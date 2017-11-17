public class WebArchives.BookmarkLogic : Object {
    private Context context;

    public BookmarkLogic (Context context) {
        this.context = context;

        context.bookmark_state.toggle.connect (on_bookmark_toggle);
        context.web_view_state.notify["url"].connect (update_bookmark);
        context.route_state.notify["route"].connect (update_bookmark);
        context.bookmark_store.item_added.connect (update_bookmark);
        context.bookmark_store.item_removed.connect (update_bookmark);
    }

    private void update_bookmark () {
        if (context.archive_state.archive == null) {
            return;
        }
        if (context.route_state.route == RouteState.Route.WEB) {
            context.bookmark_state.bookmarked =
                context.bookmark_store.contains_by_name_and_url (
                    context.archive_state.archive.name,
                    context.web_view_state.url
                );
        }
    }

    private void on_bookmark_toggle () {
        if (!context.bookmark_state.bookmarked) {
            BookmarkItem item = new BookmarkItem (
                context.web_view_state.title,
                context.web_view_state.url,
                context.archive_state.archive.name
            );
            context.bookmark_store.add (item);
        } else {
            BookmarkItem item = context.bookmark_store.get_by_name_and_url (
                context.archive_state.archive.name,
                context.web_view_state.url
            );
            context.bookmark_store.remove (item);
        }
    }
}
