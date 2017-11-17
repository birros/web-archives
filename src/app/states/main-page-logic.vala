public class WebArchives.MainPageLogic : Object {
    private Context context;

    public MainPageLogic (Context context) {
        this.context = context;

        context.main_page_state.main_page.connect (on_main_page);
    }

    private void on_main_page () {
        context.web_view_state.load_uri ("/A/");
    }
}
