#
# Usage examples:
#
#   # Get a disposable shell.
#   docker run -t --rm solvaholic/railsbox:local
#

# Build donor image, to copy some things over rather than install in-place.
FROM debian:buster AS donor

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y locales && \
    rm -rf /var/lib/apt/lists/*

# Build and set locale
# (Generate /usr/lib/locale/en_US.UTF-8 for railsbox target)
WORKDIR /tmp
RUN cp /usr/share/i18n/charmaps/UTF-8.gz /tmp && \
    rm -rf /tmp/UTF-8 && \
    gzip -d UTF-8.gz && \
    localedef -f /tmp/UTF-8 -i /usr/share/i18n/locales/en_US \
    /usr/lib/locale/en_US.UTF-8

# Build railsbox image
FROM ruby:2-buster AS railsbox
ARG image_version

LABEL name="solvaholic/railsbox" \
      version="${image_version}" \
      maintainer="solvaholic on GitHub" \
      org.opencontainers.image.source="https://github.com/solvaholic/animated-potato/blob/main/Dockerfile"

SHELL ["/bin/bash", "--login", "-c"]
ENTRYPOINT ["/bin/bash", "--login", "-c", "--"]
CMD ["/bin/bash"]

# Set locale, so text encoding and decoding can work reliably
# hadolint ignore=SC2174
RUN mkdir -p -m 755 /usr/lib/locale/en_US.UTF-8
COPY --from=donor /usr/lib/locale/en_US.UTF-8 /usr/lib/locale/en_US.UTF-8/
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add a non-root user account and create /code
RUN useradd -c "" -m -p "" -s /bin/bash user1
RUN mkdir -p /code && \
    chown user1 /code
USER user1

# Install prerequisites
RUN mkdir -p "${HOME}/.local/bin"
# hadolint ignore=DL3028,DL3016,DL4006
RUN set -o pipefail && \
    _rails=rails && \
    _nvm=https://raw.githubusercontent.com/nvm-sh/nvm/3fea5493a4/install.sh && \
    gem install --user-install --bindir "${HOME}/.local/bin" "${_rails}" && \
    curl -o- "${_nvm}" | bash && \
    source "${HOME}/.nvm/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    npm install --global yarn

WORKDIR /code
VOLUME /code
EXPOSE 3000/tcp
