FROM openziti/ziti-cli:0.33.1

COPY ./openziti-init-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
 