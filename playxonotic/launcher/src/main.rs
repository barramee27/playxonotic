mod app;
mod auth;
mod game;
mod ui;

use app::App;
use gtk4::prelude::*;
use gtk4::Application;
use std::cell::RefCell;
use std::rc::Rc;

const APP_ID: &str = "com.playxonotic.Launcher";

fn main() {
    let app = Application::builder().application_id(APP_ID).build();
    app.connect_activate(|app| {
        let state = Rc::new(RefCell::new(App::new()));
        ui::build_ui(app, state);
    });
    app.run();
}
