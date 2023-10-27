#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), deltalake::DeltaTableError> {
    // This table is included in the Rust example
    let table_path = "data/COVID-19_NYT";

    // Get Delta table metadata
    let table = deltalake::open_table(table_path).await?;
    println!("\r\n=== Delta table metadata ===");
    println!("{}", table);

    // Get Delta table files
    let files = table.get_files();
    println!("\r\n=== Delta table files ===");
    println!("{:?}", files);

    Ok(())
}