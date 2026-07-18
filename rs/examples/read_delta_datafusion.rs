use datafusion::execution::context::SessionContext;
use deltalake;
use std::sync::Arc;
use url::Url;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // This table is included in the Rust example
    let table_path = Url::from_file_path(std::fs::canonicalize("data/COVID-19_NYT")?)
        .expect("Invalid file path");

    // datafusion SessionContext
    let ctx = SessionContext::new();
    let delta_table = deltalake::open_table(table_path)
        .await?;

    // register table via `datafusion`
    ctx.register_table(
        "covid19_nyt",
        Arc::new(delta_table.table_provider().build().await?),
    )
    .unwrap();

    // Query table via datafusion
    let batches = ctx
        .sql("SELECT cases, county, date FROM covid19_nyt LIMIT 5")
        .await.unwrap()
        .collect()
        .await.unwrap();

    println!("\r\n=== Datafusion query ===");
    println!("{batches:?}");

    Ok(())
}
