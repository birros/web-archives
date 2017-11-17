public class WebArchives.LibraryParser : Object {
    private LibraryModel library_model;

    public LibraryModel? parse_file (string filepath) {
        library_model = new LibraryModel ();

        Xml.Parser.init ();

        Xml.Doc* doc = Xml.Parser.parse_file (filepath);
        if (doc == null) {
            warning ("File %s not found or permissions missing", filepath);
            return null;
        }

        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            delete doc;
            warning ("The xml file '%s' is empty", filepath);
            return null;
        }

        if (root->name == "library") {
            parse_library (root);
        }

        delete doc;

        Xml.Parser.cleanup ();

        return library_model;
    }

    private void parse_library (Xml.Node* node) {
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            string node_name = iter->name;
            if (node_name == "book") {
                parse_book (iter);
            }
        }
    }

    private void parse_book (Xml.Node* node) {
        LibraryItem library_item = new LibraryItem ();

        for (
            Xml.Attr* prop = node->properties; prop != null; prop = prop->next
        ) {
            string attr_name = prop->name;
            string attr_content = prop->children->content;

            switch (attr_name) {
                case "id":
                {
                    library_item.id = attr_content;
                    break;
                }
                case "language":
                {
                    library_item.language = attr_content;
                    break;
                }
                case "articleCount":
                {
                    library_item.article_count = uint64.parse (attr_content);
                    break;
                }
                case "mediaCount":
                {
                    library_item.media_count = uint64.parse (attr_content);
                    break;
                }
                case "favicon":
                {
                    library_item.favicon = attr_content;
                    break;
                }
                case "description":
                {
                    library_item.description = attr_content;
                    break;
                }
                case "name":
                {
                    library_item.name = attr_content;
                    break;
                }
                case "title":
                {
                    library_item.title = attr_content;
                    break;
                }
                case "date":
                {
                    library_item.date = attr_content;
                    break;
                }
                case "size":
                {
                    library_item.size = uint64.parse (attr_content);
                    break;
                }
                case "tags":
                {
                    library_item.tags = attr_content;
                    break;
                }
                case "creator":
                {
                    library_item.creator = attr_content;
                    break;
                }
                case "publisher":
                {
                    library_item.publisher = attr_content;
                    break;
                }
                case "faviconMimeType":
                {
                    library_item.favicon_mime_type = attr_content;
                    break;
                }
                case "url":
                {
                    library_item.url = attr_content;
                    break;
                }
            }
        }

        library_model.add (library_item);
    }
}
