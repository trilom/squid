FROM alpine:3.13.1

ENV CN=squid.local \
    O=squid \
    OU=squid \
    C=US \
    SQUID_CACHE_DIR="/var/cache/squid" \
    SQUID_CERT_DIR="/etc/squid-cert" \
    SQUID_LOG_DIR="/var/log/squid"

RUN apk add --no-cache \
    dumb-init=1.2.5-r0 \
    su-exec=0.2-r1 \
    # bash=5.1.0-r0 \
    libressl \
    squid=5.0.4-r0 \
    && rm -rf /var/cache/apk/* \
    ; 
    # touch /var/run/squid.pid && chown squid:squid /var/run/squid.pid
# RUN 

# ssl certs
RUN apk add --no-cache \
    ca-certificates \
    && rm -rf /var/cache/apk/*
COPY .docker/openssl.cnf.add /etc/ssl/openssl.cnf.add
RUN cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf

RUN install -d ${SQUID_CERT_DIR} -o squid -g squid

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
# RUN touch /var/run/squid.pid && chown 31:31 /var/run/squid.pid
COPY .docker/entrypoint.sh /sbin/entrypoint.sh
# this runs the rest as squid, sets entrypoint as squid user and runs the
# entrypoint as squid
# USER squid
CMD ["squid", "-NYCd", "1"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
