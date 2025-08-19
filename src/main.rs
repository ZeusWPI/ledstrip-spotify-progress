use dotenvy;
use reqwest;
use serde::Deserialize;
use std::env;
use std::env::args;
use std::sync::LazyLock;

#[derive(Deserialize)]
struct TokenJson {
    access_token: String,
}

#[derive(Deserialize)]
struct Song {
    duration_ms: f64,
}

const SPOTIFY_CLIENT_ID: LazyLock<String> =
    LazyLock::new(|| env::var("SPOTIFY_CLIENT_ID").expect("no client id set! :("));
const SPOTIFY_CLIENT_SECRET: LazyLock<String> =
    LazyLock::new(|| env::var("SPOTIFY_CLIENT_SECRET").expect("no client secret set! :("));

fn main() -> reqwest::Result<()> {
    dotenvy::dotenv().ok();

    let track_id = args().skip(1).next().expect("no track id! :(");

    println!("{}", SPOTIFY_CLIENT_ID.as_str());
    println!("{}", SPOTIFY_CLIENT_SECRET.as_str());

    let client = reqwest::blocking::Client::new();
    let res = client
        .post("https://accounts.spotify.com/api/token")
        .header(
            reqwest::header::CONTENT_TYPE,
            "application/x-www-form-urlencoded",
        )
        .body(format!(
            "grant_type=client_credentials&client_id={}&client_secret={}",
            SPOTIFY_CLIENT_ID.as_str(),
            SPOTIFY_CLIENT_SECRET.as_str()
        ))
        .send()?;
    let token = res.json::<TokenJson>()?.access_token;

    let res = client
        .get(format!("https://api.spotify.com/v1/tracks/{}", track_id).as_str())
        .header("Authorization", format!("Bearer {}", token.as_str()))
        .send()?
        .error_for_status()?;
    eprintln!("{:?}", res);
    let duration = res.json::<Song>()?.duration_ms;

    print!("{}", duration / 1000.0);

    Ok(())
}
