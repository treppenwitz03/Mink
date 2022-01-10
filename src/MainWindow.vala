public class Dbm.Window : Gtk.ApplicationWindow {

    public Window (Dbm.Application app) {
        Object (application: app);
    }

    construct {
        var button = new Gtk.Button.with_label ("Daijoubu");
        child = button;

        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("Dabooma"),
            show_title_buttons = true
        };

        set_titlebar (headerbar);
    }

}
