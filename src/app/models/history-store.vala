/**
 * FIXME: not optimized code.
 * use essentialy the same code than SearchRecentStore.
 */
public class WebArchives.HistoryStore : Object {
    private const uint MAX_HISTORY_ITEMS = 1000;
    private ListStore store;
    private HashTable<HistoryItem, ulong> callbacks;
    public signal void item_added (HistoryItem item);
    public signal void item_removed (HistoryItem item);
    public delegate void SFunc<V> (V value);

    public HistoryStore () {
        store = new ListStore (typeof (HistoryItem));
        callbacks = new HashTable<HistoryItem, ulong> (
            direct_hash, direct_equal
        );
    }

    public bool add (HistoryItem item) {
        /**
         * Remove last item if store is full.
         */
        if (store.get_n_items () == MAX_HISTORY_ITEMS) {
            uint last_index = store.get_n_items () - 1;
            HistoryItem last = (HistoryItem) store.get_item (last_index);
            remove (last);
        }

        /**
         * Check if there is no existing item stored with same name and url.
         */
        for (int i = 0; i < store.get_n_items(); i++) {
            HistoryItem result = (HistoryItem) store.get_item (i);
            if (item.name == result.name && item.url == result.url) {
                return false;
            }
        }

        listen (item);
        store.insert_sorted (item, sort_by_timestamp);
        item_added (item);
        return true;
    }

    public bool remove (HistoryItem item) {
        for (int i = 0; i < store.get_n_items(); i++) {
            HistoryItem result = (HistoryItem) store.get_item (i);
            if (item == result) {
                unlisten (item);
                store.remove (i);
                item_removed (item);
                return true;
            }
        }
        return false;
    }

    private void listen (HistoryItem item) {
        ulong callback = item.notify.connect (() => {
            store.sort (sort_by_timestamp);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (HistoryItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    private int sort_by_timestamp (GLib.Object a, GLib.Object b) {
        HistoryItem aa = (HistoryItem) a;
        HistoryItem bb = (HistoryItem) b;

        if (aa.timestamp > bb.timestamp) {
            return -1;
        } else if (aa.timestamp < bb.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }

    public HistoryItem? get_by_name_and_url (string name, string url) {
        for (int i = 0; i < store.get_n_items(); i++) {
            HistoryItem item = (HistoryItem) store.get_item (i);
            if (item.name == name && item.url == url) {
                return item;
            }
        }
        return null;
    }

    public void @foreach (SFunc<HistoryItem> func) {
        for (int i = 0; i < store.get_n_items(); i++) {
            HistoryItem item = (HistoryItem) store.get_item (i);
            func (item);
        }
    }
}
