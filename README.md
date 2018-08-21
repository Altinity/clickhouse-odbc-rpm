# clickhouse-odbc-rpm
RPM build script for clickhouse-odbc

# ODBC configuration
```bash
vim ~/.odbc.ini:
```
```ini
[ClickHouse]
Driver =  /usr/local/lib64/odbc/libclickhouseodbc.so
# Optional settings:
#Description = ClickHouse driver
#server = localhost
#database = default
#uid = default
#port = 8123
#sslmode = require
```

# Testing

Run
```bash
isql -v ClickHouse
```

