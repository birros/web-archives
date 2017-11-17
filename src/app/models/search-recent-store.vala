/**
 * FIXME: not optimized code.
 * use essentialy the same code than HistoryStore.
 */
public class WebArchives.SearchRecentStore : Object {
    private const uint MAX_SEARCH_RECENT_ITEMS = 1000;
    private ListStore store;
    private HashTable<SearchRecentItem, ulong> callbacks;
    public signal void item_added (SearchRecentItem item);
    public signal void item_removed (SearchRecentItem item);
    public delegate void SFunc<V> (V value);

    public SearchRecentStore () {
        store = new ListStore (typeof (SearchRecentItem));
        callbacks = new HashTable<SearchRecentItem, ulong> (
            direct_hash, direct_equal
        );
    }

    public bool add (SearchRecentItem item) {
        /**
         * Remove last item if store is full.
         */
        if (store.get_n_items () == MAX_SEARCH_RECENT_ITEMS) {
            uint last_index = store.get_n_items () - 1;
            SearchRecentItem last = (SearchRecentItem) store.get_item (
                last_index
            );
            remove (last);
        }

        /**
         * Check if there is no existing item stored with same name and text.
         */
        for (int i = 0; i < store.get_n_items(); i++) {
            SearchRecentItem result = (SearchRecentItem) store.get_item (i);
            if (item.name == result.name && item.text == result.text) {
                return false;
            }
        }

        listen (item);
        store.insert_sorted (item, sort_by_timestamp);
        item_added (item);
        return true;
    }

    public bool remove (SearchRecentItem item) {
        for (int i = 0; i < store.get_n_items(); i++) {
            SearchRecentItem result = (SearchRecentItem) store.get_item (i);
            if (item == result) {
                unlisten (item);
                store.remove (i);
                item_removed (item);
                return true;
            }
        }
        return false;
    }

    private void listen (SearchRecentItem item) {
        ulong callback = item.notify.connect (() => {
            store.sort (sort_by_timestamp);
        });
        callbacks.insert (item, callback);
    }

    private void unlisten (SearchRecentItem item) {
        ulong callback = callbacks.get (item);
        item.disconnect (callback);
        callbacks.remove (item);
    }

    private int sort_by_timestamp (Object a, Object b) {
        SearchRecentItem aa = (SearchRecentItem) a;
        SearchRecentItem bb = (SearchRecentItem) b;

        if (aa.timestamp > bb.timestamp) {
            return -1;
        } else if (aa.timestamp < bb.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }

    public SearchRecentItem? get_by_name_and_text (string name, string text) {
        for (int i = 0; i < store.get_n_items(); i++) {
            SearchRecentItem item = (SearchRecentItem) store.get_item (i);
            if (item.name == name && item.text == text) {
                return item;
            }
        }
        return null;
    }

    public void @foreach (SFunc<SearchRecentItem> func) {
        for (int i = 0; i < store.get_n_items(); i++) {
            SearchRecentItem item = (SearchRecentItem) store.get_item (i);
            func (item);
        }
    }
}
