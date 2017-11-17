/**
 * FIXME: not optimized code.
 */
public class WebArchives.LanguageStore : Object {
    private ArchiveStore archive_store;
    private HashTable<string, LanguageItem> items;
    public signal void item_added (LanguageItem item);
    public signal void item_removed (LanguageItem item);
    public delegate void SFunc<V> (V value);

    public LanguageStore (ArchiveStore archive_store) {
        this.archive_store = archive_store;

        items = new HashTable<string, LanguageItem> (str_hash, str_equal);

        archive_store.foreach (on_add);
        archive_store.item_added.connect (on_add);
        archive_store.item_removed.connect (on_remove);
    }

    private void on_add (ArchiveItem archive_item) {
        if (archive_item.scope != "REMOTE") {
            return;
        }

        if (archive_item.lang == "") {
            add ("");
        } else {
            var langs = archive_item.lang.split (",");
            foreach (var l in langs) {
                add (l);
            }
        }
    }

    private void on_remove (ArchiveItem archive_item) {
        if (archive_item.scope != "REMOTE") {
            return;
        }

        if (archive_item.lang == "") {
            remove ("");
        } else {
            var langs = archive_item.lang.split (",");
            foreach (var l in langs) {
                remove (l);
            }
        }
    }

    private void add (string lang) {
        var item = items.get (lang);
        if (item == null) {
            item = new LanguageItem (lang);
            items.insert (lang, item);
            item_added (item);
        }
        item.count++;
    }

    private void remove (string lang) {
        var item = items.get (lang);
        if (item == null) {
            return;
        }
        item.count--;
        if (item.count == 0) {
            items.remove (lang);
            item_removed (item);
        }
    }

    public void @foreach (SFunc<LanguageItem> func) {
        items.foreach ((lang, item) => {
            func (item);
        });
    }
}
