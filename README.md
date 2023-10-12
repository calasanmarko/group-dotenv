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
  group-dotenv pull <file1> <file2> ... [-q] [-o output-file]

Options:
  -q: Quiet mode (suppress output except for errors)
  -o: Specify output file for the 'pull' command. Default is 'group-dotenv.yaml'.

Applies the given environment variables to the .env files specified in the config file.
By default, the script looks for 'group-dotenv.yaml' in the current directory.
```

# Configuration
The general format of the YAML config file is as follows:
```
variables:
- name: NODE_ENV
  values:
  - "./.env": development
    "./.env.staging": staging
    "./.env.production": production
- name: ANOTHER
  values:
  - "./.env": v1
    "./.env.staging": v2
    "./.env.production": v3
```

Running `group-dotenv` with this configuration will result in the following file at `./.env`
```
NODE_ENV=development
ANOTHER=v1
```
...and so forth for the other `.env` files mentioned in the script.

# Pull
The pull functionality reverses the process, generating a `group-dotenv.yaml` file from the passed `.env` files.

For instance, running
```
group-dotenv pull .env .env.staging .env.production
```

after running the example under **Configuration** will reverse the process and regenerate the sample `group-dotenv.yaml` file.

# License
Made by Marko Calasan, 2023.

This product is licensed under the **MIT License**.
