use crate::app::App;
use crate::auth;
use gtk4::prelude::*;
use gtk4::{
    Application, Box, Button, DialogFlags, Entry, Label, Notebook, Orientation, PolicyType,
    ScrolledWindow, Window,
};
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::mpsc;

pub fn build_ui(app: &Application, state: Rc<RefCell<App>>) {
    let state_clone = state.clone();
    let mut app_state = state.borrow_mut();

    // If we have valid token, try to launch directly
    if let (Some(token), Some(_)) = (&app_state.token, &app_state.user) {
        match auth::verify_token(token) {
            Ok(_) => {
                drop(app_state);
                if state_clone.borrow().launch_xonotic().is_ok() {
                    app.quit();
                    return;
                }
                state_clone.borrow_mut().clear_auth();
            }
            Err(e) => {
                // If invalid token, clear auth. If network error, launch anyway (offline mode).
                if e.contains("Invalid token") {
                    app_state.clear_auth();
                } else {
                    // Network error or other issue - assume offline and launch
                    eprintln!("Network/Auth error: {}. Launching in offline mode.", e);
                    drop(app_state);
                    if state_clone.borrow().launch_xonotic().is_ok() {
                        app.quit();
                        return;
                    }
                }
            }
        }
    }

    let window = Window::builder()
        .application(app)
        .title("PlayXonotic")
        .default_width(380)
        .default_height(480)
        .resizable(false)
        .build();

    let main_box = Box::new(Orientation::Vertical, 16);
    main_box.set_margin_top(24);
    main_box.set_margin_bottom(24);
    main_box.set_margin_start(24);
    main_box.set_margin_end(24);

    // Logo
    let logo = Label::new(Some("X"));
    logo.add_css_class("title-1");
    logo.set_margin_bottom(16);
    main_box.append(&logo);

    let title = Label::new(Some("PlayXonotic"));
    title.add_css_class("title-2");
    title.set_margin_bottom(24);
    main_box.append(&title);

    // Notebook (tabs)
    let notebook = Notebook::new();
    notebook.set_show_tabs(true);

    // Login tab
    let login_box = Box::new(Orientation::Vertical, 12);
    let email_login = Entry::new();
    email_login.set_placeholder_text(Some("Email"));
    email_login.set_hexpand(true);
    login_box.append(&email_login);

    let pass_login = Entry::new();
    pass_login.set_placeholder_text(Some("Password"));
    pass_login.set_visibility(false);
    pass_login.set_hexpand(true);
    login_box.append(&pass_login);

    let login_btn = Button::with_label("Sign In");
    login_btn.add_css_class("suggested-action");
    login_btn.set_margin_top(8);
    login_box.append(&login_btn);

    let login_err = Label::new(None);
    login_err.add_css_class("error");
    login_err.set_hexpand(true);
    login_err.set_wrap(true);
    login_box.append(&login_err);

    let login_page = Box::new(Orientation::Vertical, 0);
    login_page.append(&login_box);
    notebook.append_page(&login_page, Some(&Label::new(Some("Sign In"))));

    // Signup tab
    let signup_box = Box::new(Orientation::Vertical, 12);
    let username_signup = Entry::new();
    username_signup.set_placeholder_text(Some("Username"));
    username_signup.set_hexpand(true);
    signup_box.append(&username_signup);

    let email_signup = Entry::new();
    email_signup.set_placeholder_text(Some("Email"));
    email_signup.set_hexpand(true);
    signup_box.append(&email_signup);

    let pass_signup = Entry::new();
    pass_signup.set_placeholder_text(Some("Password"));
    pass_signup.set_visibility(false);
    pass_signup.set_hexpand(true);
    signup_box.append(&pass_signup);

    let signup_btn = Button::with_label("Create Account");
    signup_btn.add_css_class("suggested-action");
    signup_btn.set_margin_top(8);
    signup_box.append(&signup_btn);

    let signup_err = Label::new(None);
    signup_err.add_css_class("error");
    signup_err.set_hexpand(true);
    signup_err.set_wrap(true);
    signup_box.append(&signup_err);

    let signup_page = Box::new(Orientation::Vertical, 0);
    signup_page.append(&signup_box);
    notebook.append_page(&signup_page, Some(&Label::new(Some("Create Account"))));

    main_box.append(&notebook);

    // Play button (when logged in - we'll show after login)
    let play_btn = Button::with_label("Play");
    play_btn.add_css_class("suggested-action");
    play_btn.set_margin_top(16);
    play_btn.set_visible(false);

    let state_play = state.clone();
    let app_clone = app.clone();
    let window_clone = window.clone();
    play_btn.connect_clicked(move |_| {
        let s = state_play.borrow().clone();
        let (tx, rx) = mpsc::channel();
        let app_weak = app_clone.downgrade();

        // Show progress dialog (download can take 10–30 min)
        let dialog = gtk4::Dialog::with_buttons(
            Some("PlayXonotic"),
            Some(&window_clone),
            DialogFlags::MODAL | DialogFlags::DESTROY_WITH_PARENT,
            &[("Cancel", gtk4::ResponseType::Cancel)],
        );
        let content = dialog.content_area();
        let msg = Label::new(Some("Downloading Xonotic (1.2 GB)... Please wait."));
        content.append(&msg);
        dialog.present();

        std::thread::spawn(move || {
            let _ = tx.send(s.launch_xonotic());
        });

        let dialog_clone = dialog.clone();
        gtk4::glib::timeout_add_local(std::time::Duration::from_millis(200), move || {
            match rx.try_recv() {
                Ok(result) => {
                    dialog_clone.close();
                    if let Some(app) = app_weak.upgrade() {
                        match result {
                            Ok(()) => app.quit(),
                            Err(e) => eprintln!("Launch error: {}", e),
                        }
                    }
                    gtk4::glib::ControlFlow::Break
                }
                Err(_) => gtk4::glib::ControlFlow::Continue,
            }
        });
    });
    main_box.append(&play_btn);

    let login_err_clone = login_err.clone();
    let signup_err_clone = signup_err.clone();
    let play_btn_clone = play_btn.clone();
    let play_btn_clone2 = play_btn.clone();
    let notebook_clone = notebook.clone();
    let notebook_clone2 = notebook.clone();
    let state_login = state.clone();
    let state_signup = state.clone();

    login_btn.connect_clicked(move |_| {
        login_err_clone.set_text("");
        let email = email_login.text().trim().to_string();
        let password = pass_login.text().to_string();
        if email.is_empty() || password.is_empty() {
            login_err_clone.set_text("Email and password required");
            return;
        }
        match auth::login(&email, &password) {
            Ok(auth) => {
                let mut s = state_login.borrow_mut();
                s.save_auth(auth);
                drop(s);
                notebook_clone.set_visible(false);
                play_btn_clone.set_visible(true);
                if let Some(user) = state_login.borrow().user.as_ref() {
                    play_btn_clone.set_label(&format!("Play as {}", user.username));
                }
            }
            Err(e) => login_err_clone.set_text(&e),
        }
    });

    signup_btn.connect_clicked(move |_| {
        signup_err_clone.set_text("");
        let username = username_signup.text().trim().to_string();
        let email = email_signup.text().trim().to_string();
        let password = pass_signup.text().to_string();
        if username.is_empty() || email.is_empty() || password.is_empty() {
            signup_err_clone.set_text("All fields required");
            return;
        }
        if password.len() < 6 {
            signup_err_clone.set_text("Password must be at least 6 characters");
            return;
        }
        match auth::signup(&username, &email, &password) {
            Ok(auth) => {
                let mut s = state_signup.borrow_mut();
                s.save_auth(auth);
                drop(s);
                notebook_clone2.set_visible(false);
                play_btn_clone2.set_visible(true);
                if let Some(user) = state_signup.borrow().user.as_ref() {
                    play_btn_clone2.set_label(&format!("Play as {}", user.username));
                }
            }
            Err(e) => signup_err_clone.set_text(&e),
        }
    });

    let app_clone_close = app.clone();
    window.connect_close_request(move |_| {
        app_clone_close.quit();
        gtk4::glib::Propagation::Proceed
    });

    let scrolled = ScrolledWindow::builder()
        .hscrollbar_policy(PolicyType::Never)
        .vscrollbar_policy(PolicyType::Automatic)
        .child(&main_box)
        .build();

    window.set_child(Some(&scrolled));
    window.present();
}
