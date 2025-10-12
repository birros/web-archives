public class WebArchives.NightModeButton : Adw.Bin {
    private Context context;
    private Gtk.CheckButton button;
    private ulong night_mode_callback;

    public NightModeButton () {
        button = new Gtk.CheckButton.with_label (_("Night mode"));
        button.toggled.connect (() => {
            context.night_mode_state.active = !context.night_mode_state.active;
        });

        set_child (button);
    }

    private void on_night_mode () {
        button.active = context.night_mode_state.active;
    }

    public void set_context (Context context) {
        if (this.context != null) {
            bool connected = SignalHandler.is_connected (
                this.context.night_mode_state, night_mode_callback
            );
            if (connected) {
                this.context.night_mode_state.disconnect (night_mode_callback);
            }
        }

        this.context = context;

        night_mode_callback =
            context.night_mode_state.notify["active"].connect (on_night_mode);
        on_night_mode ();
    }
}
