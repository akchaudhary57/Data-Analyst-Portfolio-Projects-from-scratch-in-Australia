pip install pandas pyodbc sqlalchemy

import pandas as pd
from sqlalchemy import create_engine
import urllib

# Step 1: Extract
def extract(filepath):
    return pd.read_csv(filepath)

# Step 2: Transform
def transform(df):
    df.columns = df.columns.str.lower().str.replace(" ", "_")
    df['sale_date'] = pd.to_datetime(df['sale_date'], errors='coerce')
    df = df[df['price'].notnull() & (df['price'] > 0)]
    df['price_per_sq_m'] = df['price'] / df['land_size']
    return df

# Step 3: Load into SQL Server
def load_to_sqlserver(df, table_name, server, database, username, password):
    # Connection string using SQLAlchemy + pyodbc
    params = urllib.parse.quote_plus(
        f'DRIVER=ODBC Driver 17 for SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    )
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

    # Write DataFrame to SQL Server
    df.to_sql(table_name, engine, if_exists='replace', index=False)
    print(f"✅ Loaded {len(df)} rows into table '{table_name}'.")

# --- Run the ETL ---
if __name__ == "__main__":
    # Update this path to your dataset
    csv_path = "australian_property_data.csv"
    
    # Update with your SQL Server credentials
    server = 'localhost'         # or your server IP/name
    database = 'bronze'
    username = 'your_username'
    password = 'your_password'

    # Run ETL
    raw_df = extract(csv_path)
    clean_df = transform(raw_df)
    load_to_sqlserver(clean_df, 'australian_properties', server, database, username, password)
