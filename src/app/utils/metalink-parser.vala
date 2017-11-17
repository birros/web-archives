public class WebArchives.MetalinkParser : Object {
    private Metalink metalink;

    public Metalink? parse_file (string filepath) {
        metalink = new Metalink ();

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

        if (root->name == "metalink") {
            parse_metalink (root);
        }

        delete doc;

        Xml.Parser.cleanup ();

        return metalink;
    }

    private void parse_metalink (Xml.Node* node) {
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            string node_name = iter->name;
            if (node_name == "file") {
                parse_file_node (iter);
                return;
            }
        }
    }

    private void parse_file_node (Xml.Node* node) {
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            string node_name = iter->name;
            string node_content = iter->get_content ();
            if (node_name == "url") {
                metalink.urls.append (node_content);
            }
        }
    }
}
