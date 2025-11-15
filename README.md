# ActualBudget Server with Cloudflare Tunnel Access

## License

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.

## Author

- [MartinatorTime](https://github.com/MartinatorTime)

Feel free to reach out with any questions, issues, or suggestions!

## Functions and Scripts

This project utilizes several scripts and Dockerfile commands to manage the ActualBudget server, Cloudflare Tunnel, and R2 backups.

## Environment Variables

The following environment variables are used to configure the Docker container and scripts:

### Dockerfile Build Arguments (ARG)

*   **`INSTALL_SUPERCRONIC`**: (default: `true`) Set to `true` to install Supercronic for cron jobs.
*   **`INSTALL_CADDY`**: (default: `true`) Set to `true` to install Caddy as a reverse proxy.
*   **`SYNC_DATA_CLOUDFLARE_R2`**: (default: `true`) Set to `true` to enable data synchronization with Cloudflare R2.
*   **`KEEP_ALIVE`**: (default: `true`) Set to `true` to enable the keep-alive script.
*   **`INSTALL_CLOUDFLARED`**: (default: `true`) Set to `true` to install Cloudflared for Cloudflare Tunnel.
*   **`BACKUP_RCLONE_R2`**: (default: `true`) Set to `true` to enable R2 backups using rclone.

### Dockerfile Environment Variables (ENV)

*   **`PORT`**: (default: `8080`) The port on which the ActualBudget server listens.
*   **`LOG_FILE`**: (default: `/data/actual.log`) Path to the ActualBudget server log file.
*   **`DOMAIN`**: (default: `https://budget.martinatortime.us.to`) The domain name for the Caddy server.
*   **`R2_DATA_SYNC_LOG`**: (default: `false`) Set to `true` to enable logging for R2 data synchronization.
*   **`SYNC_DATA_CLOUDFLARE_R2`**: (default: `true`) Controls whether data synchronization with Cloudflare R2 is active.
*   **`FLY_SWAP`**: (default: `false`) Related to Fly.io deployment, likely for swap file management.
*   **`OVERMIND_DAEMONIZE`**: (default: `1`) Overmind setting to daemonize processes.
*   **`OVERMIND_AUTO_RESTART`**: (default: `all`) Overmind setting to auto-restart all processes.
*   **`CFUSEREMAIL`**: Cloudflare user email for API authentication.
*   **`CFAPITOKEN`**: Cloudflare API Token for API authentication.
*   **`CFZONEID`**: Cloudflare Zone ID for DNS management.
*   **`KEEP_ALIVE`**: (default: `true`) Controls whether the keep-alive script is active.
*   **`TINI_SUBREAPER`**: (default: `true`) Tini init system setting for subreaper functionality.

### `Caddyfile` Placeholders

*   **`{$DOMAIN}`**: Used to define the server block for the domain.
*   **`{$LOG_FILE}`**: Used to specify the Caddy log file path.

### `scripts/backup-r2-rclone.sh` Environment Variables

*   **`CF_ACCESS_KEY`**: Cloudflare R2 access key ID for rclone.
*   **`CF_ACCESS_KEY_SECRET`**: Cloudflare R2 secret access key for rclone.
*   **`CF_R2_ENDPOINT`**: Cloudflare R2 endpoint URL (e.g., `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`).
*   **`PASS`**: Passphrase for GPG encryption of the backup file.

### `scripts/keep-alive.sh` Environment Variables

*   **`PING_URL`**: The URL to periodically ping to keep the application alive.

### `scripts/start_cloudflared.sh` Environment Variables

*   **`IS_PRIVILEGED`**: Set to `true` if the container runs in a privileged environment, affecting `sysctl` and `cloudflared` protocol.
*   **`CF_TOKEN`**: Cloudflare Tunnel token for authentication.
