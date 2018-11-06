FROM tarscloud/tars-node

WORKDIR /root/

VOLUME ["/data"]
	
COPY install.sh /root/init/
COPY entrypoint.sh /sbin/

RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh", "start" ]

