public class Mink.Window : Gtk.ApplicationWindow {

    public Window (Mink.Application app) {
        Object (application: app);
    }

    construct {
        var close_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("window-close")
        };
        var close = new Gtk.Button () {
            halign = Gtk.Align.START,
            can_focus = false,
            width_request = 24,
            height_request = 24,
            margin_start = 6,
            margin_top = 6,
            child = close_icon
        };
        close.add_css_class (Granite.STYLE_CLASS_FLAT);

        var today = new Granite.Placeholder ("Meeting Underway!") {
            icon = new ThemedIcon ("dialog-warning"),
            valign = Gtk.Align.START,
            margin_top = 50
        };

        var subject = new Gtk.Label ("Culminating") {
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        subject.add_css_class (Granite.STYLE_CLASS_H2_LABEL);
        subject.add_css_class ("subject_color");

        var enter = new Gtk.Button.with_label ("Enter") {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.END,
            width_request = 100,
            margin_bottom = 30
        };
        enter.add_css_class ("enter");

        var today_grid = new Gtk.Grid () {
            hexpand = true,
            vexpand = true
        };
        today_grid.attach (today, 0, 0);
        today_grid.attach (subject, 0, 1);
        today_grid.attach (enter, 0, 2);

        var options = new Mink.ScheduleOptions (this) {
            hexpand = true,
            vexpand = true
        };

        var stack = new Gtk.Stack () {
            hexpand = true,
            vexpand = true,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        stack.add_titled (today_grid, "today", "Today");
        stack.add_titled (options, "options", "Options");

        var switcher = new Gtk.StackSwitcher () {
            stack = stack,
            halign = Gtk.Align.CENTER
        };

        var grid = new Gtk.Grid ();
        grid.attach (close, 0, 0);
        grid.attach (switcher, 0, 1);
        grid.attach (stack, 0, 2);

        decorated = false;
        default_width = 275;
        default_height = 375;
        resizable = false;

        var window_handle = new Gtk.WindowHandle () {
            child = grid
        };
        child = window_handle;

        close.clicked.connect (() => {
            this.destroy ();
        });

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });

        var style_string = """
            .enter {
                background-color: @accent_color_500;
                color: @text-color;
            }

            .subject_color {
                color: @accent_color_900;
                font-weight: bold;
            }
            .reject_entry {
                border-color: red;
            }
        """;
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_data ((uint8[]) style_string);
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

}
