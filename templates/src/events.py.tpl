from pydantic import BaseModel, Field

# Utilisation d'une classe de base pour la configuration commune (immutabilité)
class FrozenBaseModel(BaseModel):
    model_config = {'frozen': True}


class StartProducing(FrozenBaseModel):
    """Événement pour déclencher le début du processus par le Producer."""
    message: str = Field(default="Go!", description="Message de déclenchement.")


class HelloMessage(FrozenBaseModel):
    """Message envoyé par le ProducerAgent."""
    text: str = Field(description="Le contenu du message 'hello'.")
    session_guid: str = Field(description="Identifiant unique de la session.")


class WorldMessage(FrozenBaseModel):
    """Message envoyé par le ConsumerAgent en réponse."""
    response: str = Field(description="La réponse 'world'.")
    original_guid: str = Field(description="GUID du message original pour le suivi.")