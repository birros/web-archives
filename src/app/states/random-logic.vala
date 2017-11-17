public class WebArchives.RandomLogic : Object {
    private Context context;

    public RandomLogic (Context context) {
        this.context = context;

        context.random_page_state.random.connect (on_random_page);
    }

    private void on_random_page () {
        string url = ArchiveUtils.get_random_page_url (
            context.archive_state.archive
        );
        if (url.length > 0) {
            context.web_view_state.load_uri (url);
        }
    }
}
