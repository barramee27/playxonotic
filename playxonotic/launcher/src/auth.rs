use serde::{Deserialize, Serialize};

const API_BASE: &str = "https://playxonotic.com/api/auth";

#[derive(Debug, Serialize)]
struct LoginRequest {
    email: String,
    password: String,
}

#[derive(Debug, Serialize)]
struct SignupRequest {
    username: String,
    email: String,
    password: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    #[serde(alias = "_id")]
    pub id: String,
    pub username: String,
    pub email: String,
}

#[derive(Debug, Deserialize)]
pub struct AuthResponse {
    pub token: String,
    pub user: User,
}

#[derive(Debug, Deserialize)]
struct MeResponse {
    user: User,
}

pub fn login(email: &str, password: &str) -> Result<AuthResponse, String> {
    let client = reqwest::blocking::Client::new();
    let res = client
        .post(format!("{}/login", API_BASE))
        .json(&LoginRequest {
            email: email.to_string(),
            password: password.to_string(),
        })
        .send()
        .map_err(|e| e.to_string())?;

    let status = res.status();
    let body: serde_json::Value = res.json().map_err(|_| "Invalid response")?;
    if !status.is_success() {
        let err = body["error"].as_str().unwrap_or("Login failed");
        return Err(err.to_string());
    }
    serde_json::from_value(body).map_err(|_| "Invalid response".to_string())
}

pub fn signup(username: &str, email: &str, password: &str) -> Result<AuthResponse, String> {
    let client = reqwest::blocking::Client::new();
    let res = client
        .post(format!("{}/signup", API_BASE))
        .json(&SignupRequest {
            username: username.to_string(),
            email: email.to_string(),
            password: password.to_string(),
        })
        .send()
        .map_err(|e| e.to_string())?;

    let status = res.status();
    let body: serde_json::Value = res.json().map_err(|_| "Invalid response")?;
    if !status.is_success() {
        let err = body["error"].as_str().unwrap_or("Signup failed");
        return Err(err.to_string());
    }
    serde_json::from_value(body).map_err(|_| "Invalid response".to_string())
}

pub fn verify_token(token: &str) -> Result<User, String> {
    let client = reqwest::blocking::Client::new();
    let res = client
        .get(format!("{}/me", API_BASE))
        .header("Authorization", format!("Bearer {}", token))
        .send()
        .map_err(|e| e.to_string())?;

    if !res.status().is_success() {
        return Err("Invalid token".to_string());
    }
    let me: MeResponse = res.json().map_err(|_| "Invalid response")?;
    Ok(me.user)
}
