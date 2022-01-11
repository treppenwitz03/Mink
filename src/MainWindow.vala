public class Dbm.Window : Gtk.ApplicationWindow {

    public Window (Dbm.Application app) {
        Object (application: app);
    }

    construct {
        var button = new Gtk.Button.with_label ("Daijoubu");
        child = button;

        var headerbar = new Dbm.HeaderBar (this);

        set_titlebar (headerbar);
    }

}
