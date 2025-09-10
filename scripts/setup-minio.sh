#!/bin/bash

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
until mc alias set minio http://minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD; do
  echo "MinIO not ready yet, waiting..."
  sleep 5
done

echo "MinIO is ready! Setting up users, policies, and buckets..."

# Create buckets for different microservices (with idempotency)
echo "Creating buckets..."
mc mb minio/user-service-bucket --ignore-existing
mc mb minio/auth-service-bucket --ignore-existing
mc mb minio/file-service-bucket --ignore-existing
mc mb minio/notification-service-bucket --ignore-existing
mc mb minio/shared-bucket --ignore-existing

# Create policies for different microservices
echo "Creating policies..."

# TODO: Use the policies define in the JSON FOLDER!
# Create a custom function to make policies
# Create a custom function to add users
# User Service Policy - can access only user-service-bucket
cat > /tmp/user-service-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::user-service-bucket",
        "arn:aws:s3:::user-service-bucket/*"
      ]
    }
  ]
}
EOF

# Auth Service Policy - can access auth-service-bucket and read shared-bucket
cat > /tmp/auth-service-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::auth-service-bucket",
        "arn:aws:s3:::auth-service-bucket/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::shared-bucket",
        "arn:aws:s3:::shared-bucket/*"
      ]
    }
  ]
}
EOF

# File Service Policy - can access file-service-bucket and shared-bucket
cat > /tmp/file-service-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::file-service-bucket",
        "arn:aws:s3:::file-service-bucket/*",
        "arn:aws:s3:::shared-bucket",
        "arn:aws:s3:::shared-bucket/*"
      ]
    }
  ]
}
EOF

# Notification Service Policy - read-only access to all buckets for notifications
cat > /tmp/notification-service-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::notification-service-bucket",
        "arn:aws:s3:::notification-service-bucket/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::user-service-bucket",
        "arn:aws:s3:::user-service-bucket/*",
        "arn:aws:s3:::auth-service-bucket",
        "arn:aws:s3:::auth-service-bucket/*",
        "arn:aws:s3:::file-service-bucket",
        "arn:aws:s3:::file-service-bucket/*",
        "arn:aws:s3:::shared-bucket",
        "arn:aws:s3:::shared-bucket/*"
      ]
    }
  ]
}
EOF

# Add policies to MinIO 
echo "Adding policies to MinIO..."
mc admin policy create minio user-service-policy /tmp/user-service-policy.json 2>/dev/null || echo "Policy user-service-policy already exists"
mc admin policy create minio auth-service-policy /tmp/auth-service-policy.json 2>/dev/null || echo "Policy auth-service-policy already exists"
mc admin policy create minio file-service-policy /tmp/file-service-policy.json 2>/dev/null || echo "Policy file-service-policy already exists"
mc admin policy create minio notification-service-policy /tmp/notification-service-policy.json 2>/dev/null || echo "Policy notification-service-policy already exists"

# Create users for each microservice (with existence check)
echo "Creating users..."
mc admin user add minio user-service-user userServicePassword123 2>/dev/null || echo "User user-service-user already exists"
mc admin user add minio auth-service-user authServicePassword123 2>/dev/null || echo "User auth-service-user already exists"
mc admin user add minio file-service-user fileServicePassword123 2>/dev/null || echo "User file-service-user already exists"
mc admin user add minio notification-service-user notificationServicePassword123 2>/dev/null || echo "User notification-service-user already exists"

# Assign policies to users (using new command)
echo "Assigning policies to users..."
mc admin policy attach minio user-service-policy --user user-service-user
mc admin policy attach minio auth-service-policy --user auth-service-user
mc admin policy attach minio file-service-policy --user file-service-user
mc admin policy attach minio notification-service-policy --user notification-service-user

# Create a read-only user for monitoring/debugging
mc admin user add minio readonly-user readonlyPassword123 2>/dev/null || echo "User readonly-user already exists"
cat > /tmp/readonly-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*"
      ]
    }
  ]
}
EOF

mc admin policy create minio readonly-policy /tmp/readonly-policy.json 2>/dev/null || echo "Policy readonly-policy already exists"
mc admin policy attach minio readonly-policy --user readonly-user

echo "Setup complete!"
echo "==========================="
echo "MinIO Console: http://localhost:9001"
echo "MinIO API: http://localhost:9000"
echo "Admin credentials: admin / adminpassword"
echo ""
echo "Service Users Created:"
echo "- user-service-user / userServicePassword123"
echo "- auth-service-user / authServicePassword123"
echo "- file-service-user / fileServicePassword123"
echo "- notification-service-user / notificationServicePassword123"
echo "- readonly-user / readonlyPassword123"
echo ""
echo "Buckets Created:"
echo "- user-service-bucket"
echo "- auth-service-bucket"
echo "- file-service-bucket"
echo "- notification-service-bucket"
echo "- shared-bucket"
echo "==========================="