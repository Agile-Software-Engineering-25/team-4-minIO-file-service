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

### Users Created
TODO

### Buckets Created
TODO

### Policies

TODO

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

For username "file-service", it looks for env vars MINIO_FILE_SERVICE_USER and MINIO_FILE_SERVICE_PASSWORD

Update the `env`File when creating new Users. There all the ENVIROMENT Variables that need to be set are defined.

### Adding New Services

1. Add a new user JSON file in the `/users` directory
2. Add a corresponding policy file in the `/policies` directory
3. Restart the setup: `docker-compose down && docker-compose up -d`

### Modifying Policies

1. Edit the policy files in `/policies` directory
2. Restart the setup container: `docker-compose restart minio-setup`

## Local Instance:

1. Build image for setup:
``docker build -f Dockerfile.minio-setup -t minio/setup .``
2. Create an `.env file` in the project root with all the enviroment values set.
3. Run `/scripts/docker-compose-env-dev.sh`

## Troubleshooting

- **Setup fails**: Check logs with `docker-compose logs minio-setup`
- **Access denied**: Verify the user has the correct policy assigned
- **Connection refused**: Ensure MinIO is running on port 9000

## Security Notes

- Use HTTPS in production environments
- Consider using external secret management
- Regularly audit user permissions
