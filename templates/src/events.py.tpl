from pydantic import BaseModel, Field

class FrozenBaseModel(BaseModel):
    model_config = {'frozen': True}


class ConfigurationProvided(FrozenBaseModel):
    """Événement distribué au démarrage avec le contexte de la session."""
    session_guid: str = Field(description="Identifiant unique pour la session.")


class StartProducing(FrozenBaseModel):
    """Événement qui déclenche le début du processus."""
    # Champ booléen ajouté pour éviter un payload vide.
    payload: bool = Field(default=True, description="Champ de compatibilité.")


class HelloMessage(FrozenBaseModel):
    """Message 'hello'."""
    text: str = Field(default="hello")


class WorldMessage(FrozenBaseModel):
    """Message 'world' en réponse."""
    response: str = Field(default="world")