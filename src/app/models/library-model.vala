public class WebArchives.LibraryModel : Object {
    private GenericSet<LibraryItem> items;
    private HashTable<string, LibraryItem> index_id;
    public delegate void MFunc<V> (V value);

    public LibraryModel () {
        items = new GenericSet<LibraryItem> (direct_hash, direct_equal);
        index_id = new HashTable<string, LibraryItem> (str_hash, str_equal);
    }

    public void add (LibraryItem item) {
        items.add (item);
        index_id.insert (item.id, item);
    }

    public bool contains_by_id (string id) {
        var item = index_id.get (id);
        if (item != null) {
            return true;
        }
        return false;
    }

    public void @foreach (MFunc<LibraryItem> func) {
        items.foreach ((item) => {
            func (item);
        });
    }
}
