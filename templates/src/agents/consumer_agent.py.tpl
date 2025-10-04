from typing import Optional

# noinspection PyPackageRequirements
from pubsub import QueueWorkerThread, ServiceBus

from ..logger import logger
from ..events import ConfigurationProvided, HelloMessage, WorldMessage


class ConsumerAgent(QueueWorkerThread):
    """Agent qui reçoit 'hello' et répond 'world'."""

    def __init__(self, service_bus: Optional[ServiceBus] = None, name="ConsumerAgent"):
        super().__init__(service_bus=service_bus, name=name)
        self.session_guid: Optional[str] = None

    def setup_event_subscriptions(self) -> None:
        """S'abonne aux événements de configuration et au message 'hello'."""
        self.service_bus.subscribe(ConfigurationProvided.__name__, self._handle_configuration)
        self.service_bus.subscribe(HelloMessage.__name__, self._handle_hello_message)

    def _handle_configuration(self, event: ConfigurationProvided):
        """Stocke le GUID de session reçu via l'événement de configuration."""
        self.session_guid = event.session_guid
        logger.info(f"'{self.name}' a reçu la configuration pour la session {self.session_guid}")

    def _handle_hello_message(self, event: HelloMessage):
        """Réceptionne le message 'hello' et déclenche la tâche de réponse."""
        logger.info(f"'{self.name}' a reçu '{event.text}' pour la session {self.session_guid}")
        self.add_task("_produce_world_response")

    def _produce_world_response(self):
        """Crée et publie la réponse 'world' en utilisant le GUID de session stocké."""
        if not self.session_guid:
            logger.warning(f"'{self.name}' a reçu 'hello' mais n'a pas de session_guid.")
            return

        logger.info(f"'{self.name}' répond 'world' pour la session {self.session_guid}")
        world_event = WorldMessage()
        self.service_bus.publish(WorldMessage.__name__, world_event, self.__class__.__name__)