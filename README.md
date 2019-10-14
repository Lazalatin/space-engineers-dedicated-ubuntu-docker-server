# space-engineers-dedicated-ubuntu-docker-server
This project aims to provide an ubuntu docker image in order to host a fully functional dedicated Space Engineers® Server

### Credits
Many parts of this project were compared with and adapted from https://github.com/bregell/docker_space_engineers_server
Thank you, Johan Bregell, for making your work open-source for me to learn from! 

### How to run
First you need to actually start the Dedicated Server Software using a genuine Windows® installation and generate a world using the local console.
After that you need to copy the worlds data (normally to be found at path `C:\Users\<yourUsername>\AppData\Roaming\SpaceEngineersDedicated\`) to your serving machine. 

Adjust environment variables (such as the path where you copied your server data) in `docker-compose.yml` and server settings in `resources/SpaceEngineers-Dedicated.cfg` 
according to your needs and issue `docker-compose up` in the projects root.
See, now you are running a fully customizable Space Engineers® Dedicated Server!

### Known issues
See the [issues](./issues).

### How to contribute
See the [contributing rules](./CONTRIBUTING.md).
