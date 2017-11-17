public class WebArchives.LanguageItem : Object {
    public string language {get; private set; default = "";}
    public uint   count    {get; set; default = 0;}

    public LanguageItem (string language) {
        this.language = language;
    }
}
