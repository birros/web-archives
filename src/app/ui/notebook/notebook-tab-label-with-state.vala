public class WebArchives.NotebookTabLabelWithState : NotebookTabLabel {
    private Context context;

    public NotebookTabLabelWithState (Context context) {
        this.context = context;

        context.title_state.notify["title"].connect (update_text);
        context.title_state.notify["subtitle"].connect (update_text);

        update_text ();
    }

    private void update_text () {
        string title = context.title_state.title;
        if (context.title_state.subtitle != "") {
             title += " - " + context.title_state.subtitle;
        }
        set_text (title);
    }

    public void set_context (Context context) {
        this.context = context;
    }
}
