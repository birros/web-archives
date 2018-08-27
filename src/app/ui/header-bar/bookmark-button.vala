public class WebArchives.BookmarkButton : Gtk.Button {
    private Context context;
    private ulong callback;

    public BookmarkButton () {
        set_image (new Gtk.Image.from_icon_name (
            "non-starred-symbolic", Gtk.IconSize.BUTTON)
        );
        tooltip_text = _("Toggle bookmark for current page");
        clicked.connect (on_clicked);
    }

    private void on_clicked () {
        context.bookmark_state.toggle ();
    }

    private void update_icon () {
        Gtk.Image image;
        if (context.bookmark_state.bookmarked) {
            image = new Gtk.Image.from_icon_name (
                "starred-symbolic", Gtk.IconSize.BUTTON
            );
        } else {
            image = new Gtk.Image.from_icon_name (
                "non-starred-symbolic", Gtk.IconSize.BUTTON
            );
        }
        set_image (image);
    }

    public void set_context (Context context) {
        if (this.context != null) {
            bool connected = SignalHandler.is_connected (
                this.context.bookmark_state, callback
            );
            if (connected) {
                this.context.bookmark_state.disconnect (callback);
            }
        }

        this.context = context;

        callback = context.bookmark_state.notify["bookmarked"].connect (() => {
            update_icon ();
        });
        update_icon ();
    }
}
