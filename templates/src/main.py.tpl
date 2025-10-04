import uuid
from {{project_name_py}}.orchestrator import HelloWorldOrchestrator
from {{project_name_py}}.logger import logger

if __name__ == "__main__":
    session_guid = str(uuid.uuid4())
    logger.info(f"🚀 Démarrage de la session : {session_guid}")

    try:
        orchestrator = HelloWorldOrchestrator(session_guid=session_guid)
        orchestrator.run()
        logger.info(f"✅ Session terminée proprement : {session_guid}")
    except Exception as e:
        logger.critical(f"❌ Erreur critique non gérée : {e}", exc_info=True)
        exit(1)