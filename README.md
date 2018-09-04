# clickhouse-odbc-rpm
RPM build script for clickhouse-odbc

# Ready-to-use RPMs
In case you'd like to just get ready RPMs look into [this repo](https://packagecloud.io/Altinity/clickhouse)

# Build RPMs
In most cases just run `./build.sh all`

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

![image01](img/image01.png)
![image02](img/image02.png)
![image03](img/image03.png)
![image04](img/image04.png)
![image05](img/image05.png)
![image06](img/image06.png)
![image07](img/image07.png)
![image08](img/image08.png)
![image09](img/image09.png)
![image10](img/image10.png)
![image11](img/image11.png)

