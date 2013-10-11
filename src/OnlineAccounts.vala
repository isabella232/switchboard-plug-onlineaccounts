// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */
namespace OnlineAccounts {

    string dialog_bus_address;
    
    public Plugins.Manager plugins_manager;
    public Keyring keyring;
    //public DBus dbus;
    
    public class Plug : Pantheon.Switchboard.Plug {

        public Plug () {
            keyring = new Keyring ();
            plugins_manager = new Plugins.Manager (Build.PLUGIN_DIR, "online-accounts", null);
            
            var main_grid = new Gtk.Grid ();
            var paned = new Granite.Widgets.ThinPaned ();
            var source_selector = new SourceSelector ();
            var account_view = new AccountView ();
            
            paned.pack1 (source_selector, false, false);
            paned.pack2 (account_view, true, false);
            paned.set_position (200);
            
            main_grid.attach (paned, 0, 0, 1, 1);
            main_grid.show_all ();
            this.add (main_grid);
            
            check_folder ();
            plugins_manager.activate ();
            plugins_manager.load_accounts ();
            //dbus = new DBus ();
            
        }
        
        private void check_folder () {
            try {
                File directory = File.new_for_path (GLib.Environment.get_user_config_dir () + "/gsignond/");
                if (!directory.query_exists ()) {
                    directory.make_directory_with_parents ();
                }
                File file = File.new_for_path (GLib.Environment.get_user_config_dir () + "/gsignond/gsignond.conf");
                if (!file.query_exists ()) {
                    debug ("creating gsignond config file");
                    var iostream = file.create_readwrite (GLib.FileCreateFlags.NONE);
                    iostream.output_stream.write (config_file.data);
                    iostream.close ();
                }
            } catch (Error e) {
                stdout.printf ("Error: %s\n", e.message);
            }
        }

    }
    
    public static string string_from_string_array (string[] strv) {
        string output = "";
        bool first = true;
        foreach (var str in strv) {
            if (first) {
                output = str;
                first = false;
            } else {
                output = output + " " + str;
            }
        }
        return output;
    }
}
public static int main (string[] args) {

    Gtk.init (ref args);
    var plug = new OnlineAccounts.Plug ();
    plug.register ("OnlineAccounts");
    plug.show_all ();
    Gtk.main ();
    return 0;
}

internal void translation () {
    var title = _("Online Accounts");
}

const string config_file = """[General]
Extension = pantheon
StoragePath = ~/.local/gsignond/
[ObjectTimeouts]
IdentityTimeout = 5
AuthSessionTimeout = 5""";
