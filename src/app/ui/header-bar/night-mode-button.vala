public class WebArchives.NightModeButton : Gtk.Bin {
    private Context context;
    private Gtk.ModelButton button;
    private ulong night_mode_callback;

    public NightModeButton () {
        button = new Gtk.ModelButton ();
        button.label = _("Night mode");
        Gtk.Label label = button.get_child() as Gtk.Label;
        if (label != null) {
            label.xalign = 0;
        }
        button.role = Gtk.ButtonRole.CHECK;
        button.clicked.connect (() => {
            on_clicked ();
        });

        add (button);
    }

    private void on_clicked () {
        context.night_mode_state.active = !context.night_mode_state.active;
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
