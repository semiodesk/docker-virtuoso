FROM ubuntu:20.04

# Set Virtuoso commit SHA to Virtuoso 7.2.5.2 release (16/08/2018)
ENV VIRTUOSO_COMMIT 7e48f8535874103505b6f8a630b09dbdb0678dc4

# Build virtuoso from source and clean up afterwards
RUN apt-get update \
        && apt-get install -y build-essential autotools-dev autoconf automake unzip wget net-tools libtool flex bison gperf gawk m4 libssl-dev libreadline-dev openssl crudini \
        # Workaround for #663
        && apt-get install -y libssl-dev \
        && wget https://github.com/openlink/virtuoso-opensource/archive/${VIRTUOSO_COMMIT}.zip \
        && unzip ${VIRTUOSO_COMMIT}.zip \
        && rm ${VIRTUOSO_COMMIT}.zip \
        && cd virtuoso-opensource-${VIRTUOSO_COMMIT} \
        && ./autogen.sh \
        && export CFLAGS="-O2 -m64" && ./configure --disable-bpel-vad --enable-conductor-vad --enable-fct-vad --disable-dbpedia-vad --disable-demo-vad --disable-isparql-vad --disable-ods-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso \
        && ln -s /var/lib/virtuoso/db /data \
        && cd .. \
        && rm -r /virtuoso-opensource-${VIRTUOSO_COMMIT} \
        && apt remove --purge -y build-essential autotools-dev autoconf automake unzip wget net-tools libtool flex bison gperf gawk m4 libssl-dev libreadline-dev \
        && apt autoremove -y \
        && apt autoclean

# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH

# Add Virtuoso config
COPY virtuoso.ini /virtuoso.ini

# Add dump_nquads_procedure
COPY dump_nquads_procedure.sql /dump_nquads_procedure.sql

# Add Virtuoso log cleaning script
COPY clean-logs.sh /clean-logs.sh

# Add startup script
COPY virtuoso.sh /virtuoso.sh

VOLUME /data
WORKDIR /data
EXPOSE 8890
EXPOSE 1111

CMD ["/bin/bash", "/virtuoso.sh"]
