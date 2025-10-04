import logging
import sys

# Configuration du logger pour une sortie claire et colorée
class ColorFormatter(logging.Formatter):
    GREY = "\\x1b[38;20m"
    YELLOW = "\\x1b[33;20m"
    RED = "\\x1b[31;20m"
    BOLD_RED = "\\x1b[31;1m"
    RESET = "\\x1b[0m"

    FORMATS = {
        logging.DEBUG: GREY + "%(asctime)s - %(levelname)s - %(message)s" + RESET,
        logging.INFO: GREY + "%(asctime)s - %(levelname)s - %(message)s" + RESET,
        logging.WARNING: YELLOW + "%(asctime)s - %(levelname)s - %(message)s" + RESET,
        logging.ERROR: RED + "%(asctime)s - %(levelname)s - %(message)s" + RESET,
        logging.CRITICAL: BOLD_RED + "%(asctime)s - %(levelname)s - %(message)s" + RESET,
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt, datefmt="%Y-%m-%d %H:%M:%S")
        return formatter.format(record)

# Création du logger principal
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Handler pour afficher les logs dans la console
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(ColorFormatter())
logger.addHandler(handler)