# Working with Environment Variables

Environment variables store configuration values that affect how programs and processes behave. They hold settings like paths, preferences, and other runtime information.

## Viewing Environment Variables

To view all environment variables:
```bash
printenv
```

To view a specific environment variable:
```bash
echo $VARIABLE_NAME
```

## Setting Environment Variables

To set an environment variable **temporarily** (for the current session):
```bash
export VARIABLE_NAME=value
```

To set an environment variable **permanently**, you can add the export command to your shell configuration file (e.g., `~/.bashrc`):
```bash
echo 'export VARIABLE_NAME=value' >> ~/.bashrc
source ~/.bashrc
```

## Common Environment Variables

- `PATH`: Specifies the directories where executable programs are located.
- `HOME`: Points to the current user's home directory.
- `USER`: Contains the current username.
- `PWD`: Contains the current working directory.

## Example Usage

### Setting a Custom Variable
```bash
export MY_VAR="Hello, World!"
echo $MY_VAR
```

### Adding a Directory to PATH
```bash
export PATH=$PATH:/new/directory
```

### Using Variables in Scripts
```bash
#!/bin/bash
export GREETING="Welcome"
echo $GREETING to $USER
```

## Best Practices

- Use uppercase names for environment variables by convention.
- Avoid spaces and special characters in variable names.
- Always quote variable values to handle spaces and special characters correctly.
