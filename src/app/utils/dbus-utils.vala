[DBus (name = "org.freedesktop.DBus")]
private interface DBusInterface : Object {
    [DBus (name = "ListActivatableNames")]
    public abstract string[] list_activatable_names () throws Error;
}

[DBus (name = "org.gtk.vfs.MountTracker")]
private interface MountTracker : GLib.Object {
    [DBus (name = "ListMountTypes")]
    public abstract string[] list_mount_types() throws Error;
}

public class WebArchives.DBusUtils : Object {
    private static bool array_contains (string[] array, string val) {
        foreach (string item in array) {
            if (item == val) {
                return true;
            }
        }
        return false;
    }

    public static bool is_name_activatable (string name) {
        try {
            DBusInterface interface = Bus.get_proxy_sync (
                BusType.SESSION, "org.freedesktop.DBus", "/org/freedesktop/DBus"
            );

            string[] names = interface.list_activatable_names ();

            if (array_contains (names, name)) {
                return true;
            } else {
                return false;
            }
        } catch (Error e) {
            warning (e.message);
        }
        return false;
    }

    public static bool is_gvfs_backend_supported (string protocol) {
        try {
            MountTracker interface = Bus.get_proxy_sync (
                BusType.SESSION, "org.gtk.vfs.Daemon",
                "/org/gtk/vfs/mounttracker"
            );

            string[] types = interface.list_mount_types ();

            if (array_contains (types, protocol)) {
                return true;
            } else {
                return false;
            }
        } catch (Error e) {
            warning (e.message);
        }
        return false;
    }
}
