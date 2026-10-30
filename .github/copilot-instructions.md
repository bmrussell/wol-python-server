# GitHub Copilot Instructions

## General Principles

- Write clean, maintainable, and well-documented code
- Follow SOLID principles and design patterns appropriate to the context
- Prioritize readability and simplicity over cleverness
- Include error handling and input validation
- Write meaningful variable and function names
- Add comments for complex logic, but prefer self-documenting code
- For python projects, create a virtual environment under `.venv` and activate as necessary. Use `pip install -r requirements.txt` to install dependencies.


---
## Language-Specific Guidelines

This repository uses modular Copilot instructions organized by language and framework. Language-specific guidelines are automatically applied via `.instructions.md` files in `.github/instructions/` based on the file being edited:

- **Flask/** - Flask API Web API guidelines (`flask.instructions.md`)

## Testing Guidelines (All Projects)

- Write unit tests for business logic
- Write integration tests for APIs and database operations
- Aim for meaningful test coverage, not just high percentages
- Use descriptive test names that explain what is being tested
- Follow AAA pattern: Arrange, Act, Assert
- Mock external dependencies
- Use test data builders for complex objects

---

## Security Considerations (All Projects)

- Validate and sanitize all user inputs
- Implement proper authentication and authorization
- Never commit secrets, API keys, or passwords
- Use environment variables for configuration
- Keep dependencies up to date
- Follow principle of least privilege

