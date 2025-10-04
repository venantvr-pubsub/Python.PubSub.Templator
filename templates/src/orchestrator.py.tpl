from typing import Optional

# noinspection PyPackageRequirements
from pubsub import OrchestratorBase, ServiceBus, AllProcessingCompleted

from .logger import logger
from .agents.producer_agent import ProducerAgent
from .agents.consumer_agent import ConsumerAgent
from .events import ConfigurationProvided, StartProducing, WorldMessage


class HelloWorldOrchestrator(OrchestratorBase):
    """Orchestre le simple flux 'hello world' entre les agents."""

    def __init__(self, session_guid: str):
        self.session_guid = session_guid
        service_bus = ServiceBus(url="http://localhost:5000", consumer_name=self.__class__.__name__)
        super().__init__(service_bus, enable_status_page=False)

    def register_services(self) -> None:
        """Crée et enregistre les agents (workers) managés."""
        self.producer = ProducerAgent(service_bus=self.service_bus)
        self.consumer = ConsumerAgent(service_bus=self.service_bus)
        self.services = [self.producer, self.consumer]

    def setup_event_subscriptions(self) -> None:
        """Abonne l'orchestrateur aux événements qui pilotent le workflow."""
        self.service_bus.subscribe(WorldMessage.__name__, self._handle_world_message)

    def start_workflow(self) -> None:
        """Démarre le processus en distribuant la configuration et en déclenchant le départ."""
        logger.info(f"Distribution de la configuration pour la session: {self.session_guid}")
        config_event = ConfigurationProvided(session_guid=self.session_guid)
        self.service_bus.publish(ConfigurationProvided.__name__, config_event, self.__class__.__name__)

        logger.info("Déclenchement du workflow...")
        start_event = StartProducing()
        self.service_bus.publish(StartProducing.__name__, start_event, self.__class__.__name__)

    def _handle_world_message(self, event: WorldMessage):
        """Gère la réception du message final pour terminer le processus."""
        logger.info(f"🎉 Succès ! Message final '{event.response}' reçu pour la session {self.session_guid}.")
        self.service_bus.publish(AllProcessingCompleted.__name__, AllProcessingCompleted(), self.__class__.__name__)