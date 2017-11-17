public class WebArchives.NewTabButton : Gtk.Button {
    private Context context;

    public NewTabButton () {
        Gtk.Image new_tab_image = new Gtk.Image.from_icon_name (
            "tab-new-symbolic", Gtk.IconSize.MENU
        );
        set_image (new_tab_image);

        clicked.connect (button_clicked_cb);
    }

    private void button_clicked_cb () {
        context.new_tab_button_state.clicked ();
    }

    public void set_context (Context context) {
        this.context = context;
    }
}
