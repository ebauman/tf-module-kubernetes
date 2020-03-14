FROM alpine

RUN apk update
RUN apk add openssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
RUN echo "root:$NEW_UUID" | chpasswd

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 22
CMD ["/setup.sh"]
