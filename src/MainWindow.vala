
using Gtk;
using Gst;

namespace SomaFM {

    public class MainWindow : Gtk.ApplicationWindow {

private Stack stack;
private Box vbox_player_page;
private Box vbox_edit_page;
private dynamic Element player;
private Gtk.ListStore list_store;
private TreeView tree_view;
private GLib.List<string> list;
private Entry entry_name;
private Entry entry_url;
private Button back_button;
private Button add_button;
private Button delete_button;
private Button edit_button;
private Button start_browser_button;
private Button play_button;
private Button stop_button;
private Button record_button;
private Button stop_record_button;
private Label current_station;
private Recorder recorder;
private string directory_path;
private string item;
private int mode;

        public MainWindow(Gtk.Application application) {
            GLib.Object(application: application,
                         title: "Soma Radio",
                         resizable: true,
                         default_height: 500);
        }

        construct {
        Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
        headerbar.get_style_context().add_class("flat");
        set_titlebar(headerbar);
        back_button = new Gtk.Button ();
            back_button.set_icon_name ("go-previous-symbolic");
            back_button.vexpand = false;
        add_button = new Gtk.Button ();
            add_button.set_icon_name ("list-add-symbolic");
            add_button.vexpand = false;
        delete_button = new Gtk.Button ();
            delete_button.set_icon_name ("list-remove-symbolic");
            delete_button.vexpand = false;
        edit_button = new Gtk.Button ();
            edit_button.set_icon_name ("document-edit-symbolic");
            edit_button.vexpand = false;
        start_browser_button = new Gtk.Button ();
            start_browser_button.set_icon_name ("web-browser-symbolic");
            start_browser_button.vexpand = false;
        play_button = new Gtk.Button();
            play_button.set_icon_name ("media-playback-start-symbolic");
            play_button.vexpand = false;
        stop_button = new Gtk.Button();
            stop_button.set_icon_name ("media-playback-stop-symbolic");
            stop_button.vexpand = false;
        record_button = new Gtk.Button();
            record_button.set_icon_name ("media-record-symbolic");
            record_button.vexpand = false;
        stop_record_button = new Gtk.Button();
            stop_record_button.set_icon_name ("process-stop-symbolic");
            stop_record_button.vexpand = false;
        var open_directory_button = new Gtk.Button();
            open_directory_button.set_icon_name ("folder-open-symbolic");
            open_directory_button.vexpand = false;
        back_button.set_tooltip_text(_("Back"));
        add_button.set_tooltip_text(_("Add station"));
        delete_button.set_tooltip_text(_("Delete station"));
        edit_button.set_tooltip_text(_("Edit station"));
        start_browser_button.set_tooltip_text(_("Go to the website somafm.com"));
        play_button.set_tooltip_text(_("Play"));
        stop_button.set_tooltip_text(_("Stop"));
        record_button.set_tooltip_text(_("Start recording"));
        stop_record_button.set_tooltip_text(_("Stop recording"));
        open_directory_button.set_tooltip_text(_("Open the Records folder"));
        back_button.clicked.connect(on_back_clicked);
        add_button.clicked.connect(on_add_clicked);
        delete_button.clicked.connect(on_delete_dialog);
        edit_button.clicked.connect(on_edit_clicked);
        start_browser_button.clicked.connect(on_start_browser_clicked);
        record_button.clicked.connect(on_record_clicked);
        stop_record_button.clicked.connect(on_stop_record_clicked);
        open_directory_button.clicked.connect(on_open_directory_clicked);
        play_button.clicked.connect(on_play_station);
        stop_button.clicked.connect(on_stop_station);
        headerbar.pack_start(back_button);
        headerbar.pack_start(add_button);
        headerbar.pack_start(delete_button);
        headerbar.pack_start(edit_button);
        headerbar.pack_start(start_browser_button);
        headerbar.pack_end(open_directory_button);
        headerbar.pack_end(record_button);
        headerbar.pack_end(stop_record_button);
        headerbar.pack_end(stop_button);
        headerbar.pack_end(play_button);
        set_widget_visible(back_button,false);
        set_widget_visible(stop_record_button, false);
        set_widget_visible(stop_button,false);
          stack = new Stack();
          stack.set_transition_duration (600);
          stack.set_transition_type (StackTransitionType.SLIDE_LEFT_RIGHT);
          stack.set_margin_end(10);
          stack.set_margin_top(10);
          stack.set_margin_start(10);
          stack.set_margin_bottom(10);
          set_child(stack);
   list_store = new Gtk.ListStore(Columns.N_COLUMNS, typeof(string));
           tree_view = new TreeView.with_model(list_store);
           var text = new CellRendererText ();
           var column = new TreeViewColumn ();
           column.pack_start (text, true);
           column.add_attribute (text, "markup", Columns.TEXT);
           tree_view.append_column (column);
           tree_view.set_headers_visible (false);
           tree_view.cursor_changed.connect(on_select_item);
   var scroll = new ScrolledWindow ();
        scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.set_vexpand(true);
        scroll.set_child (this.tree_view);
        current_station = new Label(_("Welcome!"));
   vbox_player_page = new Box(Orientation.VERTICAL,10);
   vbox_player_page.append (current_station);
   vbox_player_page.append (scroll);
   stack.add_child(vbox_player_page);
        entry_name = new Entry();
        entry_name.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_name.icon_press.connect ((pos, event) => {
              entry_name.set_text("");
              entry_name.grab_focus();
        });
        var label_name = new Label.with_mnemonic (_("_Name:"));
        label_name.set_xalign(0);
        var vbox_name = new Box (Orientation.VERTICAL, 5);
        vbox_name.append (label_name);
        vbox_name.append (entry_name);
        entry_url = new Entry();
        entry_url.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_url.icon_press.connect ((pos, event) => {
              entry_url.set_text("");
              entry_url.grab_focus();
        });
        var label_url = new Label.with_mnemonic ("_URL:");
        label_url.set_xalign(0);
        var vbox_url = new Box (Orientation.VERTICAL, 5);
        vbox_url.append (label_url);
        vbox_url.append (entry_url);
        var button_ok = new Button.with_label("OK");
        button_ok.clicked.connect(on_ok_clicked);
        vbox_edit_page = new Box(Orientation.VERTICAL,10);
        vbox_edit_page.append(vbox_name);
        vbox_edit_page.append(vbox_url);
        vbox_edit_page.append(button_ok);
        stack.add_child(vbox_edit_page);
        stack.visible_child = vbox_player_page;
        player = ElementFactory.make ("playbin", "play");
   directory_path = Environment.get_user_data_dir()+"/stations_for_soma_radio";
   GLib.File file = GLib.File.new_for_path(directory_path);
   if(!file.query_exists()){
     try{
        file.make_directory();
     }catch(Error e){
        stderr.printf ("Error: %s\n", e.message);
     }
     create_default_stations();
   }
   show_stations();
   recorder = Recorder.get_default ();
   record_button.set_sensitive(false);
 }

 private void on_play_station(){
    var selection = tree_view.get_selection();
      selection.set_mode(SelectionMode.SINGLE);
      TreeModel model;
      TreeIter iter;
      if (!selection.get_selected(out model, out iter)) {
          alert(_("Please choose a station"));
          return;
      }
 string uri;
   try {
       FileUtils.get_contents (directory_path+"/"+item, out uri);
   } catch (Error e) {
       alert(e.message);
       return;
   }
 player.uri = uri;
 player.set_state (State.PLAYING);
 current_station.set_text(_("Now playing: ")+item);
 set_widget_visible(play_button,false);
 set_widget_visible(stop_button,true);
 record_button.set_sensitive(true);
}

private void on_stop_station(){
 player.set_state (State.READY);
 current_station.set_text(_("Stopped"));
 set_widget_visible(play_button,true);
 set_widget_visible(stop_button,false);
 if(recorder.is_recording){
     on_stop_record_clicked();
 }
 record_button.set_sensitive(false);
}

private void on_record_clicked(){
var selection = tree_view.get_selection();
selection.set_mode(SelectionMode.SINGLE);
TreeModel model;
TreeIter iter;
if (!selection.get_selected(out model, out iter)) {
   alert(_("Please choose a station"));
   return;
}
try {
   recorder.start_recording();
 } catch (Gst.ParseError e) {
    alert(e.message);
    return;
 }
 set_widget_visible(record_button,false);
 set_widget_visible(stop_record_button,true);
}

private void on_stop_record_clicked(){
   recorder.stop_recording();
   set_widget_visible(record_button,true);
   set_widget_visible(stop_record_button,false);
}

   private void on_start_browser_clicked(){
       var start_browser_dialog = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL,Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, _("Do you want to visit the website somafm.com?"));
       start_browser_dialog.set_title(_("Question"));
       start_browser_dialog.show ();
       start_browser_dialog.response.connect((response) => {
                if (response == Gtk.ResponseType.OK) {
                   Gtk.show_uri(this, "https://somafm.com/", Gdk.CURRENT_TIME);
                }
                start_browser_dialog.close();
            });
       }
   
   private void on_open_directory_clicked(){
      Gtk.show_uri(this, "file://"+Environment.get_user_data_dir(), Gdk.CURRENT_TIME);
  }  

   private void on_select_item () {
           var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               return;
           }
           TreePath path = model.get_path(iter);
           var index = int.parse(path.to_string());
           if (index >= 0) {
               item = list.nth_data(index);
               recorder.station_name = item;
           }
       }

   private void on_add_clicked () {
              stack.visible_child = vbox_edit_page;
              set_buttons_on_edit_page();
              mode = 1;
              if(!is_empty(entry_name.get_text())){
                    entry_name.set_text("");
              }
              if(!is_empty(entry_url.get_text())){
                    entry_url.set_text("");
              }
  }

   private void on_edit_clicked(){
         var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert(_("Choose a station"));
               return;
           }
        stack.visible_child = vbox_edit_page;
        set_buttons_on_edit_page();
        mode = 0;
        entry_name.set_text(item);
        string url;
        try {
            FileUtils.get_contents (directory_path+"/"+item, out url);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        entry_url.set_text(url);
   }

   private void on_ok_clicked(){
         if(is_empty(entry_name.get_text())){
		    alert(_("Enter the name"));
                    entry_name.grab_focus();
                    return;
		}
		if(is_empty(entry_url.get_text())){
		   alert(_("Enter the url"));
                   entry_url.grab_focus();
                   return;
		}
        switch(mode){
            case 0:
		GLib.File select_file = GLib.File.new_for_path(directory_path+"/"+item);
		GLib.File edit_file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
		if (select_file.get_basename() != edit_file.get_basename() && !edit_file.query_exists()){
                FileUtils.rename(select_file.get_path(), edit_file.get_path());
                if(!edit_file.query_exists()){
                    alert(_("Rename failed"));
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
            }
            }else{
                if (select_file.get_basename() != edit_file.get_basename()) {
                    alert(_("A station with the same name already exists"));
                    entry_name.grab_focus();
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
             }
            }
            show_stations();
            break;
            case 1:
	GLib.File file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
        if(file.query_exists()){
            alert(_("A station with the same name already exists"));
            entry_name.grab_focus();
            return;
        }
        try {
            FileUtils.set_contents (file.get_path(), entry_url.get_text().strip());
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        if(!file.query_exists()){
           alert(_("Add failed"));
           return;
        }else{
           show_stations();
        }
        break;
      }
      on_back_clicked();
   }

   private void on_back_clicked(){
       stack.visible_child = vbox_player_page;
       set_buttons_on_player_page();
   }

   private void on_delete_dialog(){
       var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert(_("Choose a station"));
               return;
           }
           GLib.File file = GLib.File.new_for_path(directory_path+"/"+item);
         var delete_station_dialog = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL,Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, _("Delete station ")+file.get_basename()+"?");
         delete_station_dialog.set_title(_("Question"));
         delete_station_dialog.show ();
         delete_station_dialog.response.connect((response) => {
                if (response == Gtk.ResponseType.OK) {
                     FileUtils.remove (directory_path+"/"+item);
                    if(file.query_exists()){
                       alert(_("Delete failed"));
                    }else{
                       show_stations();
                    }
                }
                delete_station_dialog.close();
            });
         }

   private void show_stations () {
           list_store.clear();
           list = new GLib.List<string> ();
            try {
            Dir dir = Dir.open (directory_path, 0);
            string? name = null;
            while ((name = dir.read_name ()) != null) {
                list.append(name);
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }
         TreeIter iter;
           foreach (string item in list) {
               list_store.append(out iter);
               list_store.set(iter, Columns.TEXT, item);
           }
       }

   private void set_widget_visible (Gtk.Widget widget, bool visible) {
         widget.visible = !visible;
         widget.visible = visible;
  }

   private void set_buttons_on_player_page(){
       set_widget_visible(back_button,false);
       set_widget_visible(add_button,true);
       set_widget_visible(delete_button,true);
       set_widget_visible(edit_button,true);
       set_widget_visible(start_browser_button,true);
   }

   private void set_buttons_on_edit_page(){
       set_widget_visible(back_button,true);
       set_widget_visible(add_button,false);
       set_widget_visible(delete_button,false);
       set_widget_visible(edit_button,false);
       set_widget_visible(start_browser_button,false);
   }

   private bool is_empty(string str){
        return str.strip().length == 0;
      }

       private enum Columns {
           TEXT, N_COLUMNS
       }
   private void create_default_stations(){
          string[] name_station = {"Groove Salad","Drone Zone","Deep Space One","Indie Pop Rocks!","Space Station Soma","Lush","Secret Agent","Underground 80s","Groove Salad Classic","Left Coast 70s","Folk Forward","Beat Blender","DEF CON Radio","Boot Liquor","Suburbs of Goa","BAGeL Radio","Synphaera Radio","The Trip","Sonic Universe","PopTron","Seven Inch Soul","Fluid","Dub Step Beyond","Illinois Street Lounge","ThistleRadio","Mission Control","Digitalis","Heavyweight Reggae","cliqhop idm","Metal Detector","Vaporwaves","SF 10-33","Covers","Black Rock FM","Doomed (Special)","n5MD Radio","SomaFM Live","SF Police Scanner"};
          string[] url_station = {"http://ice4.somafm.com/groovesalad-256-mp3","http://ice2.somafm.com/dronezone-256-mp3","http://ice4.somafm.com/deepspaceone-128-mp3","http://ice2.somafm.com/indiepop-128-mp3","http://ice6.somafm.com/spacestation-128-mp3","http://ice6.somafm.com/lush-128-mp3","http://ice6.somafm.com/secretagent-128-mp3","http://ice6.somafm.com/u80s-256-mp3","http://ice2.somafm.com/gsclassic-128-mp3","http://ice2.somafm.com/seventies-320-mp3","http://ice4.somafm.com/folkfwd-128-mp3","http://ice2.somafm.com/beatblender-128-mp3","http://ice4.somafm.com/defcon-256-mp3","http://ice4.somafm.com/bootliquor-320-mp3","http://ice6.somafm.com/suburbsofgoa-128-mp3","http://ice6.somafm.com/bagel-128-mp3","http://ice6.somafm.com/synphaera-256-mp3","http://ice4.somafm.com/thetrip-128-mp3","http://ice6.somafm.com/sonicuniverse-256-mp3","http://ice2.somafm.com/poptron-128-mp3","http://ice6.somafm.com/7soul-128-mp3","http://ice2.somafm.com/fluid-128-mp3","http://ice4.somafm.com/dubstep-256-mp3","http://ice6.somafm.com/illstreet-128-mp3","http://ice6.somafm.com/thistle-128-mp3","http://ice6.somafm.com/missioncontrol-128-mp3","http://ice4.somafm.com/digitalis-128-mp3","http://ice4.somafm.com/reggae-256-mp3","http://ice4.somafm.com/cliqhop-256-mp3","http://ice6.somafm.com/metal-128-mp3","http://ice4.somafm.com/vaporwaves-128-mp3","http://ice6.somafm.com/sf1033-128-mp3","http://ice2.somafm.com/covers-128-mp3","http://ice2.somafm.com/brfm-128-mp3","http://ice6.somafm.com/specials-128-mp3","http://ice2.somafm.com/n5md-128-mp3","http://ice2.somafm.com/live-128-mp3","http://ice6.somafm.com/scanner-128-mp3"};
          for(int i=0;i<38;i++){
            try {
                 FileUtils.set_contents (directory_path+"/"+name_station[i], url_station[i]);
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
             }
          }
   }
   private void alert (string str){
          var dialog_alert = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, str);
          dialog_alert.set_title(_("Message"));
          dialog_alert.response.connect((_) => { dialog_alert.close(); });
          dialog_alert.show();
       }
   }
}
