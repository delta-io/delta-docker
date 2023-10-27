use datafusion::execution::context::SessionContext;
use std::sync::Arc;
use deltalake;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), deltalake::DeltaTableError>  {
    // This table is included in the Rust example
    let table_path = "data/COVID-19_NYT";

    // datafusion SessionContext
    let ctx = SessionContext::new();
    let delta_table = deltalake::open_table(table_path)
        .await?;

    // register table via `datafusion-ext`
    ctx.register_table("covid19_nyt", Arc::new(delta_table)).unwrap();
    
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
