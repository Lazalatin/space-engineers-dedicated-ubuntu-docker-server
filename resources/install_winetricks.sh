#!/bin/sh

# Create and switch to a temporary directory writeable by current user. See:
#   https://www.tldp.org/LDP/abs/html/subshells.html
cd "$(mktemp -d)"

# Download the latest winetricks script (master="latest version") from Github.
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks

# Mark the winetricks script (we've just downloaded) as executable. See:
#   https://www.tldp.org/LDP/GNU-Linux-Tools-Summary/html/x9543.htm
chmod +x winetricks

# Move the winetricks script to a location which will be in the standard user PATH. See:
#   https://www.tldp.org/LDP/abs/html/internalvariables.html
mv winetricks /usr/bin/winetricks

# Download the latest winetricks BASH completion script (master="latest version") from Github.
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion

# Move the winetricks BASH completion script to a standard location for BASH completion modules. See:
#   https://www.tldp.org/LDP/abs/html/tabexpansion.html
mv winetricks.bash-completion /usr/share/bash-completion/completions/winetricks

### Hint of the editor of this project: This script was taken from https://github.com/Winetricks/winetricks
### and was stripped of the update mechanism because updating would mean to rebuild this container anyways