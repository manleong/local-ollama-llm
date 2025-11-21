# Local LLM Server (Docker Deployment)

A helper project for quickly spinning up a fully functional **local LLM server** using Docker.  
This setup includes:

- **Ollama** — the backend LLM engine  
- **Nginx** — reverse proxy for HTTP/HTTPS  
- **Certbot** — automated certificate generation (optional HTTPS)

The environment is prepared using `setup.sh`, which builds and launches all necessary containers.

---

## Features

This project allows you to:

- Launch a complete **local LLM service** in Docker with one command  
- Automatically configure environment variables through a `.env` file  
- Serve the LLM backend via **Nginx** with optional HTTPS  
- Run an isolated and reproducible local LLM environment  
- Easily rebuild or reset all containers

The system spawns the following services:

| Service        | Image                  | Description                 |
|----------------|------------------------|-----------------------------|
| `llm-nginx`    | `nginx:alpine`         | Reverse proxy (HTTP/HTTPS) |
| `llm-certbot`  | `certbot/certbot`      | SSL certificate handling    |
| `llm-ollama`   | `ollama/ollama:latest` | LLM backend engine          |

---

## Requirements

Before starting, create a `.env` file in the project root.  
Use `.env.sample` as the template:

```bash
cp .env.sample .env
```
Edit the `.env` file according to your domain, ports, and model configuration.

----------

## ## Usage

### 1. Prepare your environment variables

Create a `.env` file:
```bash
cp .env.sample .env
```
Update the values as needed.


----------
### 2. Make the setup script executable

```bash
chmod +x setup.sh
```
----------

### 2. Start the full LLM stack

Run the setup script:

```bash
sudo ./setup.sh
``` 

This script will:

-   Validate your `.env`
    
-   Pull required Docker images
    
-   Configure networks and volumes
    
-   Start all services (`llm-nginx`, `llm-certbot`, `llm-ollama`)
    

----------

## Notes

-   Run with **sudo** to avoid permission issues with Docker.
    
-   Ensure your `.env` file is fully configured before starting.
    
-   You can rerun `setup.sh` to rebuild or reset the environment.
    
-   Ollama automatically pulls models when requested via API/CLI.
