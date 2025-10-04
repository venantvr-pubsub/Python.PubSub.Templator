from typing import Optional

# noinspection PyPackageRequirements
from pubsub import QueueWorkerThread, ServiceBus

from ..logger import logger
from ..events import StartProducing, HelloMessage

class ProducerAgent(QueueWorkerThread):
    """Agent qui produit le message 'hello'."""

    def __init__(self, service_bus: Optional[ServiceBus] = None):
        super().__init__(service_bus=service_bus, name="ProducerAgent")

    def setup_event_subscriptions(self) -> None:
        """S'abonne à l'événement qui déclenche son action."""
        self.service_bus.subscribe(StartProducing.__name__, self._handle_start_producing)

    def _handle_start_producing(self, event: StartProducing):
        """Handler pour l'événement StartProducing. Ajoute la tâche à la queue."""
        logger.info(f"'{self.name}' a reçu le signal de départ. Ajout de la tâche de production.")
        # On passe l'événement complet à la tâche pour pouvoir récupérer le GUID
        self.add_task("_produce_hello_message", event)

    def _produce_hello_message(self, start_event: StartProducing):
        """La logique métier de l'agent, exécutée dans son thread."""

        # On récupère le GUID directement de l'événement de départ. C'est plus simple.
        session_guid = start_event.session_guid

        logger.info(f"Envoi du message 'hello' avec le GUID: {session_guid}")
        hello_event = HelloMessage(text="hello", session_guid=session_guid)

        if self.service_bus:
            self.service_bus.publish(HelloMessage.__name__, hello_event, self.__class__.__name__)