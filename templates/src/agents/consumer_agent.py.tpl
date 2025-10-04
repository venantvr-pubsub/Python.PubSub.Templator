from typing import Optional

# noinspection PyPackageRequirements
from pubsub import QueueWorkerThread, ServiceBus

from ..logger import logger
from ..events import HelloMessage, WorldMessage

class ConsumerAgent(QueueWorkerThread):
    """Agent qui consomme 'hello' et répond 'world'."""

    def __init__(self, service_bus: Optional[ServiceBus] = None):
        super().__init__(service_bus=service_bus, name="ConsumerAgent")

    def setup_event_subscriptions(self) -> None:
        """S'abonne à l'événement qui l'intéresse."""
        self.service_bus.subscribe(HelloMessage.__name__, self._handle_hello_message)

    def _handle_hello_message(self, event: HelloMessage):
        """Handler pour l'événement HelloMessage. Ajoute la tâche à la queue."""
        logger.info(f"'{self.name}' a reçu le message '{event.text}'. Ajout de la tâche de réponse.")
        # Délègue le traitement à son propre thread
        self.add_task("_produce_world_response", event)

    def _produce_world_response(self, original_event: HelloMessage):
        """La logique métier de réponse, exécutée dans son thread."""
        response_text = "world"
        logger.info(f"Réponse avec '{response_text}' au message avec GUID: {original_event.session_guid}")

        world_event = WorldMessage(
            response=response_text,
            original_guid=original_event.session_guid
        )

        if self.service_bus:
            self.service_bus.publish(WorldMessage.__name__, world_event, self.__class__.__name__)