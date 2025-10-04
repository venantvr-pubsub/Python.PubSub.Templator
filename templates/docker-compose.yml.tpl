services:
  pubsub-server:
    image: pubsub-server-image
    container_name: pubsub-server
    ports:
      - "5000:5000"
    build:
      context: https://github.com/venantvr-pubsub/Python.PubSub.Server.git