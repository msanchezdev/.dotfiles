# Minimal Ubuntu base for testing a from-scratch dotfiles bootstrap.
# Deliberately bare: no Homebrew, no build-essential, no node — install.sh
# must bring all of that itself. Only the prerequisites a stock Ubuntu has
# (or trivially needs) to run the Homebrew/bun installers are present.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl file git ca-certificates procps sudo unzip zsh locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Homebrew refuses to run as root, so the install runs as an unprivileged user
# with passwordless sudo (the apt installer phase needs it).
RUN useradd -m -s /usr/bin/zsh tester \
    && echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester \
    && chmod 0440 /etc/sudoers.d/tester

USER tester
ENV HOME=/home/tester LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
WORKDIR /home/tester
CMD ["bash"]
