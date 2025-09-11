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


### User and Policy Setup

All users are now set up via JSON files in the `/users` directory. Each JSON file should contain:

```json
{
	"username": "service-user",
	"policy": "service-policy"
}
```

User credentials (username and password) should be managed securely and referenced in your application as needed. Policies are assigned based on the `policy` field in the user JSON file.

Example user file: `/users/file-service-user.json`

```json
{
	"username": "file-service-user",
	"policy": "file-service-policy"
}
```

To add or modify users, simply add or edit JSON files in `/users` and restart the setup container.

### Adding New Services

1. Add a new user JSON file in the `/users` directory
2. Add a corresponding policy file in the `/policies` directory
3. Restart the setup: `docker-compose down && docker-compose up -d`

### Modifying Policies

1. Edit the policy files in `/policies` directory
2. Restart the setup container: `docker-compose restart minio-setup`

## Troubleshooting

- **Setup fails**: Check logs with `docker-compose logs minio-setup`
- **Access denied**: Verify the user has the correct policy assigned
- **Connection refused**: Ensure MinIO is running on port 9000

## Security Notes

- Use HTTPS in production environments
- Consider using external secret management
- Regularly audit user permissions
