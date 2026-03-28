FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=freetz

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    locales \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 de_DE.UTF-8

# Use the project's own prerequisite list for Debian 13 to keep dependencies aligned.
COPY tools /tmp/tools
RUN /tmp/tools/prerequisites install -y Debian13 \
 && rm -rf /var/lib/apt/lists/* /tmp/tools

RUN cat >/usr/local/bin/make <<'EOF' \
 && chmod +x /usr/local/bin/make
#!/usr/bin/env bash
set -euo pipefail

case "${PWD}" in
   /workspace/freetz-ng|/workspace/freetz-ng/*)
      if [ -x /workspace/freetz-ng/tools/make-cs ]; then
         exec /workspace/freetz-ng/tools/make-cs "$@"
      fi
      ;;
esac

exec /usr/bin/make "$@"
EOF

RUN if ! getent group ${GROUP_ID} >/dev/null; then groupadd --gid ${GROUP_ID} ${USER_NAME}; fi \
 && if ! getent passwd ${USER_ID} >/dev/null; then useradd --uid ${USER_ID} --gid ${GROUP_ID} --create-home --shell /bin/bash ${USER_NAME}; fi

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

WORKDIR /workspace/freetz-ng
USER ${USER_ID}
CMD ["bash"]