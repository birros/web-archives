public class WebArchives.StatusLabel : Adw.Bin {
    private Gtk.Label label_widget;

    private int64 p_timestamp = 0;
    public int64 timestamp {
        get { return p_timestamp; }
        set {
            p_timestamp = value;
            update_label ();
            update_tooltip ();
        }
    }

    public bool progress_enabled { get; set; default = false; }
    public string progress_label { get; set; }
    public double progress { get; set; }

    public StatusLabel () {
        label_widget = new Gtk.Label ("") {
            xalign = 0, // left align
            hexpand = true
        };

        set_child (label_widget);

        update_label ();
        update_tooltip ();

        Timeout.add (1000, update_label);
        notify["progress"].connect (on_progress);
    }

    private void on_progress () {
        uint8 progress_percent = (uint8) (progress * 100);
        label_widget.label = _("%s: %u %%").printf (progress_label, progress_percent);
    }

    private void update_tooltip () {
        if (timestamp == 0) {
            label_widget.tooltip_text = _("Never refreshed");
            return;
        }

        DateTime time = new DateTime.from_unix_local (timestamp);
        label_widget.tooltip_text = time.format (_("Last refreshed: %H:%M - %e %b %Y"));
    }

    private bool update_label () {
        if (progress_enabled) {
            return true;
        }
        if (timestamp == 0) {
            label_widget.label = _("Never refreshed");
            return true;
        }

        GLib.DateTime time = new GLib.DateTime.now_utc ();
        int64 current = time.to_unix ();

        int64 diff_s = current - timestamp;
        int64 diff_m = diff_s / 60;
        int64 diff_h = diff_m / 60;
        int64 diff_D = diff_h / 24;
        int64 diff_M = diff_D / 30;
        int64 diff_Y = diff_D / 365;

        if (diff_Y > 0) {
            label_widget.label = _("%lluY ago").printf (diff_Y);
        } else if (diff_M > 0) {
            label_widget.label = _("%lluM ago").printf (diff_M);
        } else if (diff_D > 0) {
            label_widget.label = _("%lluD ago").printf (diff_D);
        } else if (diff_h > 0) {
            label_widget.label = _("%lluh ago").printf (diff_h);
        } else if (diff_m > 0) {
            label_widget.label = _("%llum ago").printf (diff_m);
        } else if (diff_s >= 0) {
            label_widget.label = _("%llus ago").printf (diff_s);
        }

        return true;
    }

    // Convenience getter if you need the underlying Gtk.Label
    public Gtk.Label get_label_widget () {
        return label_widget;
    }
}

