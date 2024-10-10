import subprocess
import os
import time

def run_command(command, shell=False):
    try:
        if shell:
            subprocess.run(command, shell=True, check=True)
        else:
            subprocess.run(command.split(), check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")

def main():
    # Step 1: Download and run the script from URL
    print("Running script from URL...")
    run_command("curl -s https://file.winsnip.xyz/file/uploads/Logo-winsip.sh | bash", shell=True)
    
    # Wait for 5 seconds
    time.sleep(5)

    # Step 2: Update and upgrade system
    print("Updating and upgrading system...")
    run_command("sudo apt update -y && sudo apt upgrade -y", shell=True)

    # Step 3: Remove existing docker packages
    packages = ["docker.io", "docker-doc", "docker-compose", "podman-docker", "containerd", "runc"]
    for pkg in packages:
        print(f"Removing package: {pkg}...")
        run_command(f"sudo apt-get remove -y {pkg}")

    # Step 4: Install dependencies
    print("Installing ca-certificates, curl, and gnupg...")
    run_command("sudo apt-get update")
    run_command("sudo apt-get install -y ca-certificates curl gnupg")

    # Step 5: Setup Docker keyring and repository
    print("Setting up Docker keyring and repository...")
    run_command("sudo install -m 0755 -d /etc/apt/keyrings")
    run_command("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg", shell=True)
    run_command("sudo chmod a+r /etc/apt/keyrings/docker.gpg")

    # Add Docker repository
    print("Adding Docker repository...")
    arch = subprocess.getoutput("dpkg --print-architecture")
    version_codename = subprocess.getoutput(". /etc/os-release && echo $VERSION_CODENAME")
    repo = f"deb [arch={arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu {version_codename} stable"
    run_command(f'echo "{repo}" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null', shell=True)

    # Step 6: Update and install Docker
    print("Updating system and installing Docker...")
    run_command("sudo apt update -y && sudo apt upgrade -y", shell=True)
    run_command("sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")

    # Set executable permissions for docker-compose
    run_command("sudo chmod +x /usr/local/bin/docker-compose")

    # Step 7: Verify Docker installation
    run_command("docker --version")

    # Step 8: Create directory and navigate into it
    print("Creating directory 'sixgpt' and navigating into it...")
    os.makedirs("sixgpt", exist_ok=True)
    os.chdir("sixgpt")

    # Step 9: Set environment variables for Docker Compose
    vana_private_key = input("Masukkan VANA_PRIVATE_KEY: 54f6955031303578c639b50ac40a12cac8799560203003658433fd94e502c5a2")
    vana_network = input("Masukkan VANA_NETWORK: satori")

    os.environ["VANA_PRIVATE_KEY"] = vana_private_key
    os.environ["VANA_NETWORK"] = vana_network

    # Step 10: Create docker-compose.yml file
    print("Creating docker-compose.yml file...")
    docker_compose_content = f"""
version: '3.8'

services:
  ollama:
    image: ollama/ollama:0.3.12
    ports:
      - "11435:11434"
    volumes:
      - ollama:/root/.ollama
    restart: unless-stopped
 
  sixgpt3:
    image: sixgpt/miner:latest
    ports:
      - "3015:3000"
    depends_on:
      - ollama
    environment:
      - VANA_PRIVATE_KEY=${{{vana_private_key}}}
      - VANA_NETWORK=${{{vana_network}}}
    restart: always

volumes:
  ollama:
"""

    with open("docker-compose.yml", "w") as file:
        file.write(docker_compose_content)

    # Step 11: Run docker-compose up
    print("Running docker-compose up...")
    run_command("docker compose up -d", shell=True)

if __name__ == "__main__":
    main()
