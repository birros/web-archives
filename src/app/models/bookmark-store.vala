/**
 * FIXME: not optimized code.
 */
public class WebArchives.BookmarkStore : Object {
    private GenericSet<BookmarkItem> store;
    public signal void item_added (BookmarkItem item);
    public signal void item_removed (BookmarkItem item);
    public delegate void SFunc<V> (V value);

    public BookmarkStore () {
        store = new GenericSet<BookmarkItem> (direct_hash, direct_equal);
    }

    public bool add (BookmarkItem item) {
        /**
         * Check if there is no existing item stored with same name and url.
         */
        foreach (BookmarkItem result in store.get_values ()) {
            if (result.name == item.name && result.url == item.url) {
                return false;
            }
        }
        store.add (item);
        item_added (item);
        return true;
    }

    public bool remove (BookmarkItem item) {
        bool result = store.remove (item);
        if (result) {
            item_removed (item);
            return true;
        }
        return false;
    }

    public BookmarkItem? get_by_name_and_url (string name, string url) {
        foreach (BookmarkItem result in store.get_values ()) {
            if (result.name == name && result.url == url) {
                return result;
            }
        }
        return null;
    }

    public bool contains_by_name_and_url (string name, string url) {
        foreach (BookmarkItem result in store.get_values ()) {
            if (result.name == name && result.url == url) {
                return true;
            }
        }
        return false;
    }

    public void @foreach (SFunc<BookmarkItem> func) {
        store.foreach ((item) => {
            func (item);
        });
    }
}
