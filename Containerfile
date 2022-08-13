# Learn more about Fedora at: https://getfedora.org/
ARG FEDORA_VERSION=36
FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}

ENV NAME=hatbox VERSION=36 ARCH=x86_64
LABEL com.github.containers.toolbox="true" \
      com.github.debarshiray.toolbox="true" \
      name="$NAME" \
      version="$VERSION" \
      architecture="$ARCH" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Image for creating Fedora toolbox containers" \
      maintainer="Shrey Sonar <shreysonar13@gmail.com>"

# Fast dnf
RUN echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
RUN echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf

# missing manpages
RUN sed -ie 's/\<nodocs\>//' /etc/dnf/dnf.conf
RUN dnf reinstall -y $(rpm -qa --queryformat '%{NAME}[:%{FILENAMES}]\n' | \
    grep ':/usr/share/man/' | cut -f1 -d:)

# upgrade and install packages
COPY packages /
RUN dnf upgrade -y --refresh \
    && dnf install -y $(<packages) \
    && dnf clean all -y \
    && rm /packages

# These commands will help the image better integrate with the toolbox upstream:
# https://github.com/containers/toolbox#image-requirements
RUN touch /etc/host.conf /etc/hosts /etc/localtime /etc/resolv.conf /etc/timezone
RUN mkdir -p /etc/krb5.conf.d

# Also required to run, but not documented: https://github.com/containers/toolbox/pull/715
RUN touch /etc/machine-id

# This will give the group `wheel` sudo access on the host.
RUN mkdir -p /etc/sudoers.d
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-toolbox

CMD /bin/sh
