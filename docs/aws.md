# AWS

## Client

Install `aws` client: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

Set initial configuration

    aws configure

It will ask for,

```
AWS Access Key ID [None]: AK....
AWS Secret Access Key [None]: ......
Default region name [None]: us-east-1
Default output format [None]:
```

So have it around

Example copy command from s3 bucket `db.backup`

    aws s3 cp s3://db.backup/@auto_pb_backup_20250416000000.zip .

Example copy command to s3 bucket `db.backup`

    aws s3 cp sql_dump.sql.bz2 s3://db.backup/may_2025/sql_dump.sql.bz2

