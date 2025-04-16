# AWS (Amazon Web Services)

Amazon Web Services (AWS) is a comprehensive cloud computing platform offering a wide variety of services, including computing power, storage, databases, networking, machine learning, and more.

## AWS Command Line Interface (CLI)

The AWS CLI is a unified tool to manage your AWS services from the command line.

### Installation

Follow the official instructions to install the AWS CLI for your operating system:
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Example installation for Linux x86_64:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# Verify installation
aws --version
```

### Configuration

Once installed, configure the CLI to connect to your AWS account. Run:

```bash
aws configure
```

The command will prompt you for the following information:

```
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

*   **AWS Access Key ID & Secret Access Key:** These are your security credentials. Generate them from the AWS Management Console under IAM (Identity and Access Management). **Treat your Secret Access Key like a password; do not share it or commit it to version control.**
*   **Default region name:** The AWS region where your resources are primarily located (e.g., `us-east-1`, `eu-west-2`).
*   **Default output format:** How AWS CLI responses are formatted (e.g., `json`, `yaml`, `text`, `table`). `json` is common for scripting.

This command stores the credentials in `~/.aws/credentials` and the region/output format in `~/.aws/config`. You can configure multiple profiles using `aws configure --profile <profile_name>`.

**Security Note:** For applications running on AWS resources like EC2 instances, it's generally more secure to use IAM Roles instead of storing access keys directly.

## Common S3 Commands

Amazon Simple Storage Service (S3) is an object storage service. Here are some common `aws s3` commands:

### List Buckets

```bash
aws s3 ls
```

### List Objects in a Bucket

```bash
aws s3 ls s3://your-bucket-name/
# List objects under a specific prefix (folder)
aws s3 ls s3://your-bucket-name/path/to/folder/
```

### Copy Files/Objects

**Download from S3:**

```bash
# Download a specific object
aws s3 cp s3://db.backup/@auto_pb_backup_20250416000000.zip .

# Download recursively (entire prefix/folder)
aws s3 cp s3://your-bucket-name/data/ /local/path/ --recursive
```

**Upload to S3:**

```bash
# Upload a single file
aws s3 cp local_file.txt s3://your-bucket-name/

# Upload a single file to a specific path/prefix
aws s3 cp sql_dump.sql.bz2 s3://db.backup/may_2025/sql_dump.sql.bz2

# Upload recursively (entire local folder)
aws s3 cp /local/path/ s3://your-bucket-name/data/ --recursive
```

### Sync Files/Directories

Synchronizes directories. Copies only new or updated files.

```bash
# Sync local directory to S3
aws s3 sync /local/path/ s3://your-bucket-name/data/

# Sync S3 directory to local
aws s3 sync s3://your-bucket-name/data/ /local/path/
```

### Remove Objects

```bash
# Remove a single object
aws s3 rm s3://your-bucket-name/old_file.txt

# Remove objects recursively (use with caution!)
aws s3 rm s3://your-bucket-name/temp-data/ --recursive
```
