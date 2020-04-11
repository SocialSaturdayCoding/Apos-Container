FROM debian:buster AS base

ARG BACKEND_PATH=./apos-backend

# Install base dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends 'g++' python3-dev uwsgi uwsgi-plugin-python3 python3-pip python3-setuptools
RUN pip3 install uWSGI


# Setup backend
FROM base as backend
ADD $BACKEND_PATH /opt/apos-backend
WORKDIR /opt/apos-backend

RUN pip3 install poetry

RUN poetry export -n -f requirements.txt | grep -v "Warning:" | tee requirements.txt

# Setup frontend
RUN echo "!!! NO FRONETND YET !!!"


# Combine built frontend and built backend
FROM base as combined
COPY --from=backend /opt/apos-backend/ /opt/apos-backend/
RUN pip3 install -r /opt/apos-backend/requirements.txt
RUN apt-get install -y --no-install-recommends python3-psycopg2


# Build final image
FROM combined as final
RUN apt-get clean

ADD cmd.sh /usr/local/bin/cmd.sh
CMD ["/usr/local/bin/cmd.sh"]
ADD uwsgi-apos-backend.ini /etc/uwsgi/apos-backend.ini
RUN ln -sf /etc/apos/backend-config.py /opt/apos-backend/apos/config.py

VOLUME /etc/apos
EXPOSE 3008/tcp     # uwsgi (uwsgi protocol)
EXPOSE 8080/tcp     # uwsgi (http for convenience)

