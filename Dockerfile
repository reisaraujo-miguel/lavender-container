FROM fedora:41 AS base-image

COPY ./ /tmp

# allow to install packages docs
RUN sed -i '/^tsflags=nodocs$/d' /etc/dnf/dnf.conf

# Update the system packages
RUN dnf update -y && dnf clean all


FROM base-image AS extra-repos

RUN dnf -y install 'dnf5-command(copr)' && dnf clean all &&\
	chmod +x /tmp/enable-extra-repos.sh && /tmp/enable-extra-repos.sh 


FROM extra-repos AS extra-packages
# Install essential coding tools
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mapfile -t groups < /tmp/install-groups &&\
	mapfile -t pkgs < /tmp/install-pkgs &&\
	dnf install -y "${pkgs[@]}" --allowerasing &&\
	dnf group install -y "${groups[@]}" --allowerasing &&\
	dnf clean all

RUN mandb


FROM extra-packages AS cleanup

RUN dnf install -y symlinks &&\
	symlinks -r -c -d /usr &&\
	dnf remove -y symlinks &&\
	dnf clean all


FROM cleanup AS create-user

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Create a non-root user (recommended for security)
RUN useradd -m -u 1000 dev

# Grant sudo access without password to dev user
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/dev

# Set permissions for the sudoers file (optional but recommended)
RUN chmod 0440 /etc/sudoers.d/dev &&\
	chown root:root /etc/sudoers.d/dev

USER dev

# Set the working directory
WORKDIR /home/dev


FROM create-user AS configure-user

RUN git clone https://github.com/reisaraujo-miguel/my-dot-files.git ./.local/share/dotfiles &&\
	./.local/share/dotfiles/install.sh

CMD ["zsh"]
