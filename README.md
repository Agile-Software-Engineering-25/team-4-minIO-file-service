# MinIO Multi-User Demo

This project demonstrates how to set up MinIO with multiple users and policies for different microservices using Docker Compose.

## Quick Start

1. Start the MinIO setup:
```bash
docker-compose up -d
```

2. Wait for the setup to complete (check logs):
```bash
docker-compose logs minio-setup
```

## Architecture

### Users Created
### Buckets Created
- `user-service-bucket` - User profile data, avatars
- `auth-service-bucket` - Authentication tokens, certificates
- `file-service-bucket` - General file uploads
- `notification-service-bucket` - Email templates, notification assets
- `shared-bucket` - Shared resources between services

### Policies

Each service has its own IAM policy with appropriate permissions:

- **User Service**: Full access to `user-service-bucket` only
- **Auth Service**: Full access to `auth-service-bucket`, read access to `shared-bucket`
- **File Service**: Full access to `file-service-bucket` and `shared-bucket`
- **Notification Service**: Full access to `notification-service-bucket`, read access to all other buckets
- **Read only**: Read access to all buckets for monitoring

## Using in Your Applications

### Environment Variables

Set these in your microservice environment:

```env
# Example Service
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=example-service-user
MINIO_SECRET_KEY=example-service-password
MINIO_BUCKET=example-service-bucket
```

## Customization

### Adding New Services

1. Edit `scripts/setup-minio.sh` to add new users, buckets, and policies
2. Add corresponding policy files in the `policies/` directory
3. Restart the setup: `docker-compose down && docker-compose up -d`

### Modifying Policies

1. Edit the policy files in `policies/` directory
2. Restart the setup container: `docker-compose restart minio-setup`

## Troubleshooting

- **Setup fails**: Check logs with `docker-compose logs minio-setup`
- **Access denied**: Verify the user has the correct policy assigned
- **Connection refused**: Ensure MinIO is running on port 9000

## Security Notes

- Change default passwords in production
- Use HTTPS in production environments
- Consider using external secret management
- Regularly audit user permissions
