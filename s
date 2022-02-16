public class Mink.ScheduleOptions : Gtk.Widget {
    public Gtk.ScrolledWindow scrolled { get; set; }
    public Mink.Window window { get; construct; }
    public Settings settings { get; set; }
    public ScheduleOptions (Mink.Window win) {
        Object (window: win);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        margin_start = 10;
        margin_end = 10;
        margin_top = 20;
        margin_bottom = 20;
        settings = new Settings ("com.github.zenitsudev.mink.schedules");

        var monday = new Mink.LinkList (this, "Monday");
        var tuesday = new Mink.LinkList (this, "Tuesday");
        var wednesday = new Mink.LinkList (this, "Wednesday");
        var thursday = new Mink.LinkList (this, "Thursday");
        var friday = new Mink.LinkList (this, "Friday");
        var saturday = new Mink.LinkList (this, "Saturday");
        var sunday = new Mink.LinkList (this, "Sunday");

        var grid = new Gtk.Grid ();
        grid.attach (monday, 0, 0);
        grid.attach (tuesday, 0, 1);
        grid.attach (wednesday, 0, 2);
        grid.attach (thursday, 0, 3);
        grid.attach (friday, 0, 4);
        grid.attach (saturday, 0, 5);
        grid.attach (sunday, 0, 6);

        scrolled = new Gtk.ScrolledWindow () {
            child = grid,
            vexpand = true
        };
        scrolled.set_parent (this);
    }

    ~ScheduleOptions () {
        while (get_last_child () != null) {
            get_last_child ().unparent ();
        }
    }
}

public class Mink.LinkList : Gtk.Grid {
    public string weekday { get; construct; }
    public Mink.ScheduleOptions schedule_options { get; construct; }
    public string[] schedules_for_day { get; set; }

    public LinkList (Mink.ScheduleOptions schedule_options, string weekday) {
        Object (
            schedule_options: schedule_options,
            weekday: weekday
        );
    }

    construct {
        schedules_for_day = schedule_options.settings.get_strv (weekday.ascii_down ());

        var listbox = new Gtk.ListBox ();

        var add_button = new Gtk.Button.with_label ("+") {
            hexpand = true
        };

        var main_grid = new Gtk.Grid ();
        main_grid.attach (listbox, 0, 0);
        main_grid.attach (add_button, 0, 1);

        var revealer = new Gtk.Revealer () {
            child = main_grid,
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };

        var label = new Gtk.Label ("<b>" + weekday + "</b>") {
            xalign = -1,
            use_markup = true
        };

        var button = new Gtk.ToggleButton () {
            child = label,
            hexpand = true
        };

        attach (button, 0, 0);
        attach (revealer, 0, 1);

        can_focus = false;

        button.toggled.connect (() => {
            revealer.reveal_child = button.active;
            add_button.margin_bottom = (int) button.active * 10;
        });

        add_button.clicked.connect (() => {
            listbox.append (new Mink.LinkItem (this));
        });
    }
}

public class Mink.LinkItem : Gtk.Box {
    public Mink.LinkList list { get; construct; }
    public bool first_time { get; set; default = true; }

    public Gtk.Label title { get; set; }
    public Gtk.Label starting_time { get; set; }

    public LinkItem (Mink.LinkList list) {
        Object (list: list);
    }

    construct {
        height_request = 25;

        var item_editor = new Mink.ItemEditor (this) {
            transient_for = list.schedule_options.window
        };

        title = new Gtk.Label ("") {
            use_markup = true,
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 15,
            xalign = -1,
            hexpand = true,
            margin_start = 10
        };

        starting_time = new Gtk.Label ("") {
            margin_end = 5,
            halign = Gtk.Align.END
        };

        var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
            halign = Gtk.Align.END,
            margin_end = 10
        };
        delete_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        append (title);
        append (starting_time);
        append (delete_button);

        var click_controller = new Gtk.GestureClick ();
        this.add_controller (click_controller);

        delete_button.clicked.connect (() => {
            this.destroy ();
        });

        click_controller.pressed.connect (() => {
            if (!first_time) {
                item_editor.acceptance_button.label = "Edit";
            }

            item_editor.show ();
        });

        if (first_time) {
            item_editor.show ();
            first_time = false;
        }
    }
}

public class Mink.ItemEditor : Granite.Dialog {
    public Mink.LinkItem item { get; construct; }
    public Gtk.Button acceptance_button { get; set; }
    public ItemEditor (Mink.LinkItem item) {
        Object (item: item);
    }

    construct {
        default_width = 200;
        default_height = 300;

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        acceptance_button = (Gtk.Button) add_button ("Add", Gtk.ResponseType.ACCEPT);

        this.response.connect ((response) => {
            switch (response) {
                case Gtk.ResponseType.CANCEL:
                    this.hide ();
                    break;
                case Gtk.ResponseType.ACCEPT:
                    print ("Inazuma shines Eternal");
                    this.hide ();
                    break;
            }
        });
    }
}
