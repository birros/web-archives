public class WebArchives.HistoryLogic : Object {
    private Context context;

    public HistoryLogic (Context context) {
        this.context = context;

        context.web_view_state.notify["url"].connect (update_history);
    }

    private void update_history () {
        if (context.web_view_state.url == "") {
            return;
        }

        HistoryItem item = context.history_store.get_by_name_and_url (
            context.archive_state.archive.name,
            context.web_view_state.url
        );
        if (item == null) {
            item = new HistoryItem (
                context.web_view_state.title,
                context.web_view_state.url,
                context.archive_state.archive.name
            );
            context.history_store.add (item);
        }
        item.update_timestamp ();
    }
}
