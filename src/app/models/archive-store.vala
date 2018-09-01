/**
 * FIXME: not optimized code.
 *
 * Note: This class is thread-safe.
 */
public class WebArchives.ArchiveStore : Object {
    private Mutex mutex;
    private GenericSet<ArchiveItem> store;
    private HashTable<string, HashTable<string, ArchiveItem>> index_scope_path;
    private HashTable<string, HashTable<string, ArchiveItem>> index_scope_uuid;
    public signal void item_added (ArchiveItem item);
    public signal void item_removed (ArchiveItem item);
    public delegate void SFunc<V> (V value);

    public ArchiveStore () {
        mutex = Mutex ();
        store = new GenericSet<ArchiveItem> (direct_hash, direct_equal);
        index_scope_path =
            new HashTable<string, HashTable<string, ArchiveItem>> (
                str_hash, str_equal
            );
        index_scope_uuid =
            new HashTable<string, HashTable<string, ArchiveItem>> (
                str_hash, str_equal
            );
    }

    /**
     * RECENTS and LOCAL: path unique
     * REMOTE: uuid unique
     */
    public bool add (ArchiveItem item) {
        switch (item.scope) {
            case "RECENTS":
            case "LOCAL":
            {
                if (contains_by_scope_and_path (item.scope, item.path)) {
                    return false;
                }
                break;
            }
            case "REMOTE":
            {
                if (contains_by_scope_and_uuid (item.scope, item.uuid)) {
                    return false;
                }
                break;
            }
        }
        mutex.lock ();
        store.add (item);
        index (item);
        mutex.unlock ();
        item_added (item);
        return true;
    }

    public bool remove (ArchiveItem item) {
        if (store.contains (item)) {
            mutex.lock ();
            store.remove (item);
            unindex (item);
            mutex.unlock ();
            item_removed (item);
            return true;
        }
        return false;
    }

    private void index (ArchiveItem item) {
        // index path
        HashTable<string, ArchiveItem> index_path = index_scope_path.get (
            item.scope
        );
        if (index_path == null) {
            index_path = new HashTable<string, ArchiveItem> (
                str_hash, str_equal
            );
            index_scope_path.insert (item.scope, index_path);
        }
        index_path.insert (item.path, item);

        // index uuid
        HashTable<string, ArchiveItem> index_uuid = index_scope_uuid.get (
            item.scope
        );
        if (index_uuid == null) {
            index_uuid = new HashTable<string, ArchiveItem> (
                str_hash, str_equal
            );
            index_scope_uuid.insert (item.scope, index_uuid);
        }
        index_uuid.insert (item.uuid, item);
    }

    private void unindex (ArchiveItem item) {
        // index path
        HashTable<string, ArchiveItem> index_path = index_scope_path.get (
            item.scope
        );
        index_path.remove (item.path);
        if (index_path.length == 0) {
            index_scope_path.remove (item.scope);
        }

        // index uuid
        HashTable<string, ArchiveItem> index_uuid = index_scope_uuid.get (
            item.scope
        );
        index_uuid.remove (item.uuid);
        if (index_uuid.length == 0) {
            index_scope_uuid.remove (item.scope);
        }
    }

    public bool contains_by_scope_and_path (string scope, string path) {
        mutex.lock ();
        HashTable<string, ArchiveItem> index_path = index_scope_path.get (
            scope
        );
        mutex.unlock ();
        if (index_path != null) {
            mutex.lock ();
            ArchiveItem item = index_path.get (path);
            mutex.unlock ();
            if (item != null) {
                return true;
            }
        }
        return false;
    }

    public bool contains_by_scope_and_uuid (string scope, string uuid) {
        mutex.lock ();
        HashTable<string, ArchiveItem> index_uuid = index_scope_uuid.get (
            scope
        );
        mutex.unlock ();
        if (index_uuid != null) {
            mutex.lock ();
            ArchiveItem item = index_uuid.get (uuid);
            mutex.unlock ();
            if (item != null) {
                return true;
            }
        }
        return false;
    }

    public ArchiveItem? get_by_scope_and_path (string scope, string path) {
        mutex.lock ();
        HashTable<string, ArchiveItem> index_path = index_scope_path.get (
            scope
        );
        mutex.unlock ();
        if (index_path != null) {
            mutex.lock ();
            ArchiveItem item = index_path.get (path);
            mutex.unlock ();
            if (item != null) {
                return item;
            }
        }
        return null;
    }

    public ArchiveItem? get_by_scope_and_uuid (string scope, string uuid) {
        mutex.lock ();
        HashTable<string, ArchiveItem> index_uuid = index_scope_uuid.get (
            scope
        );
        mutex.unlock ();
        if (index_uuid != null) {
            mutex.lock ();
            ArchiveItem item = index_uuid.get (uuid);
            mutex.unlock ();
            if (item != null) {
                return item;
            }
        }
        return null;
    }

    public void @foreach (SFunc<ArchiveItem> func) {
        // We copy the store
        GenericSet<ArchiveItem> _store =
            new GenericSet<ArchiveItem> (direct_hash, direct_equal);
        mutex.lock ();
        store.foreach ((item) => {
            _store.add (item);
        });
        mutex.unlock ();

        // And then loop on it to prevent mutex problems
        _store.foreach ((item) => {
            func (item);
        });
    }
}
