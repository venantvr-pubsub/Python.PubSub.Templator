# noinspection PyPackageRequirements
from pubsub import OrchestratorBase, ServiceBus, AllProcessingCompleted

from .logger import logger
from .agents.producer_agent import ProducerAgent
from .agents.consumer_agent import ConsumerAgent
from .events import StartProducing, WorldMessage

class HelloWorldOrchestrator(OrchestratorBase):
    """Orchestre le simple flux 'hello world' entre deux agents."""

    def __init__(self, session_guid: str):
        self.session_guid = session_guid
        # L'URL du serveur pub/sub est généralement lue depuis une config ou .env
        service_bus = ServiceBus(url="http://localhost:5000", consumer_name=self.__class__.__name__)
        super().__init__(service_bus, enable_status_page=False)

    def register_services(self) -> None:
        """Crée et enregistre les agents (workers) managés."""
        self.producer = ProducerAgent(service_bus=self.service_bus)
        self.consumer = ConsumerAgent(service_bus=self.service_bus)
        self.services = [self.producer, self.consumer]
        logger.info("Agents Producer et Consumer enregistrés.")

    def setup_event_subscriptions(self) -> None:
        """Abonne l'orchestrateur aux événements qui pilotent le workflow."""
        self.service_bus.subscribe(WorldMessage.__name__, self._handle_world_message)

    def start_workflow(self) -> None:
        """Démarre le processus en envoyant le premier événement."""
        logger.info("Workflow démarré. Envoi de l'événement 'StartProducing'.")
        start_event = StartProducing()
        self.service_bus.publish(StartProducing.__name__, start_event, self.__class__.__name__)

    def _handle_world_message(self, event: WorldMessage):
        """Gère la réception du message final pour terminer le processus."""
        logger.info(f"🎉 Succès ! Message final reçu : '{event.response}' (GUID original: {event.original_guid})")
        logger.info("Toute la séquence est terminée. Arrêt de l'application.")
        # Publie l'événement de fin pour débloquer la boucle .run()
        self.service_bus.publish(AllProcessingCompleted.__name__, AllProcessingCompleted(), self.__class__.__name__)