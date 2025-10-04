from typing import Optional

# noinspection PyPackageRequirements
from pubsub import QueueWorkerThread, ServiceBus

from ..logger import logger
from ..events import ConfigurationProvided, StartProducing, HelloMessage


class ProducerAgent(QueueWorkerThread):
    """Agent qui produit le message 'hello' après avoir reçu le signal de départ."""

    def __init__(self, service_bus: Optional[ServiceBus] = None, name="ProducerAgent"):
        super().__init__(service_bus=service_bus, name=name)
        self.session_guid: Optional[str] = None

    def setup_event_subscriptions(self) -> None:
        """S'abonne aux événements de configuration et de déclenchement."""
        self.service_bus.subscribe(ConfigurationProvided.__name__, self._handle_configuration)
        self.service_bus.subscribe(StartProducing.__name__, self._handle_start_producing)

    def _handle_configuration(self, event: ConfigurationProvided):
        """Stocke le GUID de session reçu via l'événement de configuration."""
        self.session_guid = event.session_guid
        logger.info(f"'{self.name}' a reçu la configuration pour la session {self.session_guid}")

    def _handle_start_producing(self, event: StartProducing):
        """Ajoute la tâche de production à la file d'attente lors du déclenchement."""
        self.add_task("_produce_hello_message")

    def _produce_hello_message(self):
        """Crée et publie le message 'hello' en utilisant le GUID de session stocké."""
        if not self.session_guid:
            logger.warning(f"'{self.name}' a reçu un signal de départ mais n'a pas de session_guid.")
            return

        logger.info(f"'{self.name}' envoie 'hello' pour la session {self.session_guid}")
        hello_event = HelloMessage()
        self.service_bus.publish(HelloMessage.__name__, hello_event, self.__class__.__name__)