FROM alpine:3.21.3 AS base

COPY ./common-pkgs /tmp/common-pkgs

RUN apk add --no-cache bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mapfile -t pkgs < /tmp/common-pkgs &&\
	apk add --no-cache "${pkgs[@]}"

RUN rm -r /tmp/*

FROM base AS bat-extras
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk add --no-cache shfmt

RUN git clone https://github.com/eth-p/bat-extras.git /tmp/bat-extras &&\
	/tmp/bat-extras/build.sh --minify=all --install --prefix=/usr --no-verify


FROM bat-extras AS tools
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk add --no-cache nodejs npm deno

# install bun
RUN curl -fsSL https://bun.sh/install | bash

# install typescript
RUN npm install -g typescript ts-node nodemon &&\
	npm install -g @types/node

FROM tools AS finish

RUN git clone https://github.com/reisaraujo-miguel/dotfiles.git ~/.config/dotfiles &&\
	~/.config/dotfiles/install.sh

RUN rm -r /tmp/*

CMD ["zsh"]
