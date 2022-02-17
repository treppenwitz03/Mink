public class Mink.ScheduleOptions : Gtk.Widget {
    public Gtk.ScrolledWindow scrolled { get; set; }
    public Mink.Window window { get; construct; }
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
    public Gtk.ListBox listbox { get; set; }
    public Settings settings { get; set; }

    public LinkList (Mink.ScheduleOptions schedule_options, string weekday) {
        Object (
            schedule_options: schedule_options,
            weekday: weekday
        );
    }

    construct {
        listbox = new Gtk.ListBox ();

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

        settings = new Settings ("com.github.zenitsudev.mink.schedules");
        var schedules_for_day = settings.get_strv (weekday.ascii_down ());

        button.toggled.connect (() => {
            revealer.reveal_child = button.active;
            add_button.margin_bottom = (int) button.active * 10;
        });

        add_button.clicked.connect (() => {
            listbox.append (new LinkItem (this, true));
        });

        foreach (string schedules in schedules_for_day) {
            var existing_item = new LinkItem (this, false) {
                first_time = false
            };
            var splitted = schedules.split ("®");
            existing_item.title = splitted[0];
            existing_item.starting_time = splitted[1].split ("-")[0];
            existing_item.ending_time = splitted[1].split ("-")[1];
            existing_item.link = splitted[2];
            existing_item.title_label.label = existing_item.title;
            existing_item.starting_time_label.label = existing_item.starting_time;
            listbox.append (existing_item);
        }
    }

    public class LinkItem : Gtk.Box {
        public Mink.LinkList list { get; construct; }
        public bool first_time { get; set construct; }

        public Gtk.Label title_label { get; set; }
        public Gtk.Label starting_time_label { get; set; }

        public string title { get; set; }
        public string starting_time { get; set; }
        public string ending_time { get; set; }
        public string link { get; set; }

        public LinkItem (Mink.LinkList list, bool first_time) {
            Object (
                list: list,
                first_time: first_time
            );
        }

        construct {
            height_request = 25;
            tooltip_text = "Edit this item";

            var item_editor = new ItemEditor (this) {
                transient_for = list.schedule_options.window
            };

            title_label = new Gtk.Label ("") {
                use_markup = true,
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 10,
                xalign = -1,
                hexpand = true,
                margin_start = 10
            };

            starting_time_label = new Gtk.Label ("") {
                margin_end = 5,
                halign = Gtk.Align.END
            };

            var click_controller = new Gtk.GestureClick ();

            var clickable_holder = new Gtk.Grid ();
            clickable_holder.attach (title_label, 0, 0);
            clickable_holder.attach (starting_time_label, 1, 0);
            clickable_holder.add_controller (click_controller);

            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
                halign = Gtk.Align.END,
                margin_end = 10,
                tooltip_text = "Delete this item"
            };
            delete_button.add_css_class (Granite.STYLE_CLASS_FLAT);

            append (clickable_holder);
            append (delete_button);

            delete_button.clicked.connect (() => {
                this.hide ();
            });

            click_controller.pressed.connect (() => {
                if (!first_time) {
                    item_editor.acceptance_button.label = "Edit";
                    item_editor.meeting_title_entry.text = title;
                    item_editor.starting_time_picker.text = starting_time;
                    item_editor.ending_time_picker.text = ending_time;
                    item_editor.meeting_link_entry.text = link;
                }

                item_editor.show ();
            });

            if (first_time) {
                item_editor.show ();
                first_time = false;
            }

        }

        public class ItemEditor : Granite.Dialog {
            public LinkItem item { get; construct; }
            public Gtk.Button acceptance_button { get; set; }
            public Gtk.Revealer meeting_time_revealer { get; set; }

            public Gtk.Entry meeting_title_entry { get; set; }
            public Granite.TimePicker starting_time_picker { get; set; }
            public Granite.TimePicker ending_time_picker { get; set; }
            public Gtk.Entry meeting_link_entry { get; set; }

            public ItemEditor (LinkItem item) {
                Object (item: item);
            }

            construct {
                default_width = 200;
                default_height = 300;

                add_button ("Cancel", Gtk.ResponseType.CANCEL);
                acceptance_button = (Gtk.Button) add_button ("Add", Gtk.ResponseType.ACCEPT);

                var meeting_title = new Gtk.Label ("<b>Meeting Title</b>") {
                    use_markup = true,
                    halign = Gtk.Align.START
                };

                meeting_title_entry = new Gtk.Entry () {
                    placeholder_text = "Title for your meeting eg. 'Onikabuto'",
                    tooltip_text = "Meeting Title",
                    hexpand = true,
                    height_request = 30
                };

                var title_focus_controller = new Gtk.EventControllerFocus ();
                meeting_title_entry.add_controller (title_focus_controller);

                var meeting_title_warner = new Gtk.Label ("Title should not be empty") {
                    halign = Gtk.Align.START
                };
                meeting_title_warner.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

                var meeting_title_revealer = new Gtk.Revealer () {
                    child = meeting_title_warner,
                    transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
                };

                var meeting_title_grid = new Gtk.Grid ();
                meeting_title_grid.attach (meeting_title_entry, 0, 0);
                meeting_title_grid.attach (meeting_title_revealer, 0, 1);

                var meeting_time = new Gtk.Label ("<b>Meeting Time</b>") {
                    use_markup = true,
                    halign = Gtk.Align.START
                };

                starting_time_picker = new Granite.TimePicker () {
                    hexpand = true
                };

                ending_time_picker = new Granite.TimePicker () {
                    hexpand = true
                };

                var time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                time_box.append (starting_time_picker);
                time_box.append (new Gtk.Label ("   to    "));
                time_box.append (ending_time_picker);

                var meeting_time_warner = new Gtk.Label ("Times must not be the same") {
                    halign = Gtk.Align.START
                };
                meeting_time_warner.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

                meeting_time_revealer = new Gtk.Revealer () {
                    child = meeting_time_warner,
                    transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
                };

                var meeting_time_grid = new Gtk.Grid ();
                meeting_time_grid.attach (time_box, 0, 0);
                meeting_time_grid.attach (meeting_time_revealer, 0, 1);

                var meeting_link = new Gtk.Label ("<b>Meeting Link</b>") {
                    use_markup = true,
                    halign = Gtk.Align.START
                };

                meeting_link_entry = new Gtk.Entry () {
                    placeholder_text = "Link your meeting eg. from Zoom",
                    tooltip_text = "Meeting Link",
                    hexpand = true,
                    height_request = 30
                };

                var link_focus_controller = new Gtk.EventControllerFocus ();
                meeting_link_entry.add_controller (link_focus_controller);

                var meeting_link_warner = new Gtk.Label ("Link should not be empty") {
                    halign = Gtk.Align.START
                };
                meeting_link_warner.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

                var meeting_link_revealer = new Gtk.Revealer () {
                    child = meeting_link_warner,
                    transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
                };

                var meeting_link_grid = new Gtk.Grid ();
                meeting_link_grid.attach (meeting_link_entry, 0, 0);
                meeting_link_grid.attach (meeting_link_revealer, 0, 1);

                var content_area_child = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

                content_area_child.append (meeting_title);
                content_area_child.append (meeting_title_grid);
                content_area_child.append (meeting_time);
                content_area_child.append (meeting_time_grid);
                content_area_child.append (meeting_link);
                content_area_child.append (meeting_link_grid);

                var toast = new Granite.Widgets.Toast ("Item already exists. Try again.");

                var overlay = new Gtk.Overlay () {
                    child = content_area_child,
                    hexpand = true,
                    vexpand = true
                };
                overlay.add_overlay (toast);

                this.get_content_area ().append (overlay);

                var title_ready = false;
                var link_ready = false;

                title_focus_controller.leave.connect (() => {
                    if (meeting_title_entry.text == "") {
                        meeting_title_entry.add_css_class ("reject_entry");
                        meeting_title_revealer.reveal_child = true;
                        title_ready = false;
                    } else {
                        meeting_title_entry.remove_css_class ("reject_entry");
                        meeting_title_revealer.reveal_child = false;
                        title_ready = true;
                    }
                });

                starting_time_picker.time_changed.connect (() => { time_ready (); });
                ending_time_picker.time_changed.connect (() => { time_ready (); });

                link_focus_controller.leave.connect (() => {
                    if (meeting_link_entry.text == "") {
                        meeting_link_entry.add_css_class ("reject_entry");
                        meeting_link_revealer.reveal_child = true;
                        link_ready = false;
                    } else {
                        meeting_link_entry.remove_css_class ("reject_entry");
                        meeting_link_revealer.reveal_child = false;
                        link_ready = true;
                    }
                });

                this.response.connect ((response) => {
                    switch (response) {
                        case Gtk.ResponseType.CANCEL:
                            this.hide ();
                            break;
                        case Gtk.ResponseType.ACCEPT:
                            if (title_ready && time_ready () && link_ready) {
                                item.title_label.label = meeting_title_entry.text;
                                item.starting_time_label.label = starting_time_picker.text;
                                string[] schedules_for_day = item.list.settings.get_strv (item.list.weekday.ascii_down ());
                                var entry = meeting_title_entry.text + "®" + starting_time_picker.text + "-" + ending_time_picker.text + "®" + meeting_link_entry.text;
                                print (acceptance_button.label);
                                if (acceptance_button.label == "Edit") {
                                    item.title = meeting_title_entry.text;
                                    item.starting_time = starting_time_picker.text;
                                    item.ending_time = ending_time_picker.text;
                                    item.link = meeting_link_entry.text;
                                    schedules_for_day += entry;
                                    item.list.settings.set_strv (item.list.weekday.ascii_down (), schedules_for_day);
                                    this.hide ();
                                } else {
                                    if (entry in schedules_for_day) {
                                        toast.send_notification ();
                                    } else {
                                        item.title = meeting_title_entry.text;
                                        item.starting_time = starting_time_picker.text;
                                        item.ending_time = ending_time_picker.text;
                                        item.link = meeting_link_entry.text;
                                        schedules_for_day += entry;
                                        item.list.settings.set_strv (item.list.weekday.ascii_down (), schedules_for_day);
                                        this.hide ();
                                    }
                                }
                            }
                            break;
                    }
                });
            }

            public bool time_ready () {
                if (starting_time_picker.text == ending_time_picker.text) {
                    starting_time_picker.add_css_class ("reject_entry");
                    ending_time_picker.add_css_class ("reject_entry");
                    meeting_time_revealer.reveal_child = true;
                    return false;
                } else {
                    starting_time_picker.remove_css_class ("reject_entry");
                    ending_time_picker.remove_css_class ("reject_entry");
                    meeting_time_revealer.reveal_child = false;
                    return true;
                }
            }
        }
    }
}
