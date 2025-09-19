#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), deltalake::DeltaTableError> {
    // This table is included in the Rust example
    let table_path = "data/COVID-19_NYT";

    // Get Delta table metadata
    let table = deltalake::open_table(table_path).await?;
    println!("\r\n=== Delta table metadata ===");
    println!("{}", table);
    println!("Version: {:?}", table.version());

    let files: Vec<String> = table.get_file_uris()?.collect();
    println!("Files: {}", files.join(", "));

    Ok(())
}