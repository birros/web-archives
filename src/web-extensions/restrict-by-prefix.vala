[CCode (cname="G_MODULE_EXPORT webkit_web_extension_initialize_with_user_data", instance_pos = -1)]
public static void webkit_web_extension_initialize_with_user_data (
    WebKit.WebExtension extension,
    Variant             user_data
) {
    string prefix = user_data.get_string ();
    RestrictByPrefix restrict = new RestrictByPrefix (prefix);
    /**
     * FIXME : It is necessary to use a lambda function to capture the restrict
     * instance, otherwise the object is destroyed.
     */
    extension.page_created.connect ((page) => {
        restrict.on_page_created (page);
    });
}

public class RestrictByPrefix : Object {
    private string prefix;

    public RestrictByPrefix (string prefix) {
        this.prefix = prefix;
        info ("Prefix used: %s", prefix);
    }

    public void on_page_created (WebKit.WebPage page) {
        info ("Page %llu created", page.get_id ());
        page.send_request.connect (on_send_request);
    }

    public bool on_send_request (
        WebKit.URIRequest   request,
        WebKit.URIResponse? response
    ) {
        string uri = request.get_uri ();

        if (
            uri.has_prefix (prefix) ||
            uri.has_prefix ("data:") ||
            uri.has_prefix ("blob:")
        ) {
            info ("URI authorized: %s", uri);
            return false;
        } else {
            info ("URI blocked: %s", uri);
            return true;
        }
    }
}
