use url::Url;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // This table is included in the Rust example
    let table_path = Url::from_directory_path(std::fs::canonicalize("data/COVID-19_NYT")?).unwrap();

    // Get Delta table metadata
    let table = deltalake::open_table(table_path).await?;
    println!("\r\n=== Delta table metadata ===");
    println!("{}", table);
    println!("Version: {:?}", table.version());

    let files: Vec<String> = table.get_file_uris()?.collect();
    println!("Files: {}", files.join(", "));

    Ok(())
}
