# group-dotenv
*Centrally manage multiple .env files*

# Installation
Available as a npm package
```
npm install --global group-dotenv
```

# Usage
Inserts environment variables in multiple `.env` files based on a centrally-managed YAML configuration file.

```
Usage:
  group-dotenv [-q]
  group-dotenv <config-file> [-q]

Options:
  -q: Quiet mode (suppress output except for errors)
```

# Configuration
The general format of the YAML config file is as follows:
```
variables:
- name: NODE_ENV
  values:
    "./.env": development
    "./.env.staging": staging
    "./env.production": production
- name: ANOTHER
  values:
  - "./.env": v1
  - "./.env.staging": v2
    "./.env.production": v3
```

Running `group-dotenv` with this configuration will result in the following file at `./.env`
```
NODE_ENV=development
ANOTHER=v1
```
...and so forth for the other `.env` files mentioned in the script.

# License
Made by Marko Calasan, 2023.

This product is licensed under the **MIT License**.
