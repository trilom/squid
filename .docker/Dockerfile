FROM alpine:3.12

ENV CN=squid.local \
    O=squid \
    OU=squid \
    C=US \
    SQUID_LOG_DIR="/var/log/squid" \
    SQUID_CACHE_DIR="/var/cache/squid" \
    SQUID_CERT_DIR="/etc/squid-cert"

RUN apk update && apk add --no-cache \
    bash \
    libressl \
    squid && \
    rm -rf /var/cache/apk/*

# ssl certs
RUN apk update && apk add --no-cache ca-certificates && rm -rf /var/cache/apk/*
COPY .docker/openssl.cnf.add /etc/ssl
RUN cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf

RUN mkdir ${SQUID_CERT_DIR} && chown 31:31 ${SQUID_CERT_DIR}

# private.pem
RUN libressl req -new -newkey rsa:4096 -sha256 -days 365 -nodes -x509 \
	-keyout ${SQUID_CERT_DIR}/private.pem \
	-out ${SQUID_CERT_DIR}/private.pem \
	-subj "/CN=${CN}/O=${O}/OU=${OU}/C=${C}" \
    -utf8 -nameopt multiline,utf8
# CA.der
RUN libressl x509 -in ${SQUID_CERT_DIR}/private.pem \
	-outform DER -out ${SQUID_CERT_DIR}/CA.der
# RUN libressl x509 -inform DER -in ${cert_dir}/CA.der -out ${cert_dir}/CA.pem
# dhparam.pem
# https://security.stackexchange.com/questions/95178/diffie-hellman-parameters-still-calculating-after-24-hours
RUN libressl dhparam -dsaparam -outform PEM \
    -out ${SQUID_CERT_DIR}/dhparam.pem 2048

# for squid4
RUN rm -rfv /var/lib/ssl_db/ && \
    /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB && \
	chown -R 31:31 /var/lib/ssl_db

# fo http
EXPOSE 3128
# for ssl
EXPOSE 4128

COPY .docker/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
# for custom pid
RUN touch /var/run/squid.pid && chown 31:31 /var/run/squid.pid
# this runs the rest as squid, sets entrypoint as squid user and runs the
# entrypoint as squid
USER squid

ENTRYPOINT ["/sbin/entrypoint.sh"]