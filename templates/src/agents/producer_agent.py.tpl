from typing import Optional

# noinspection PyPackageRequirements
from pubsub import QueueWorkerThread, ServiceBus

from ..logger import logger
from ..events import StartProducing, HelloMessage, WorldMessage

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
        # Délègue le travail à son propre thread via la work_queue
        self.add_task("_produce_hello_message")

    def _produce_hello_message(self):
        """La logique métier de l'agent, exécutée dans son thread."""
        from {{project_name_py}}.orchestrator import HelloWorldOrchestrator

        # On cherche l'instance de l'orchestrateur parmi les abonnés pour récupérer le session_guid
        orchestrator_instance = next(
            (s.handler.__self__ for s in self.service_bus.get_subscribers(WorldMessage.__name__) if isinstance(s.handler.__self__, HelloWorldOrchestrator)),
            None
        )

        if orchestrator_instance is None or not hasattr(orchestrator_instance, 'session_guid'):
            logger.error("Impossible de trouver l'instance de l'orchestrateur ou son GUID de session.")
            return

        session_guid = orchestrator_instance.session_guid

        logger.info(f"Envoi du message 'hello' avec le GUID: {session_guid}")
        hello_event = HelloMessage(text="hello", session_guid=session_guid)

        if self.service_bus:
            self.service_bus.publish(HelloMessage.__name__, hello_event, self.__class__.__name__)