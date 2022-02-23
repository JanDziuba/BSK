FROM debian:buster

WORKDIR /app
COPY . /app
RUN bash install.sh
RUN bash initial_setup.sh
RUN bash ssh_setup.sh
EXPOSE 8000
CMD bash run_client_and_officer_app.sh
