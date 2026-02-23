# Python.PubSub.Templator

Project skeleton generator for pub/sub consumer applications. Uses YAML-driven configuration and Smarty-style templates for automated scaffolding.

## Stack

[![Stack](https://skillicons.dev/icons?i=py,php&theme=dark)](https://skillicons.dev)
## Structure

- `bootstrap.py` -- Entry point for project generation
- `structure.yaml` -- Defines the output project layout
- `requirements.txt` -- Python dependencies
- `templates/` -- Template files for generated projects
  - `Makefile.tpl`, `docker-compose.yml.tpl`, `env.example.tpl` -- Build and environment templates
  - `src/agents/` -- Consumer and producer agent templates
  - `src/main.py.tpl`, `src/orchestrator.py.tpl`, `src/events.py.tpl` -- Core application templates
  - `tests/` -- Test scaffolding templates
