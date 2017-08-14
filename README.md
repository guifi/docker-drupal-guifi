# Docker environment for guifi.net website
Docker images for Drupal with drupal-guifi module enabled
## Requirements
We must have installed those packages:
- **docker engine**: version 1.13 or above
- **python**: 2.7
- **python-pip**: suitable for version 2.7
- **docker-compose**: preferible latest versions.

### Requirements installation (Debian)
Firstly, we should install **docker-ce** engine. The tutorial shown in docker website should be enough to achieve that: (https://docs.docker.com/engine/installation/linux/docker-ce/debian/#install-using-the-repository)

The next step would be the installation of python packages (if they weren't installed before):

```
sudo apt install -y python2.7 python-pip
```

The last step would be docker-compose installation:

```
sudo pip install docker-compose
```

And that should be enough to run our docker-compose files.

## Working with this composition
In this point we include all possible image uses at the moment
### Drupal 6
If you want to work with this version of guifi webpage you should download ./drupal6/docker-compose.yml file inside this repository and place it inside a development directory with writing permissions.

[Click here to download docker-compose.yml](./drupal6/docker-compose.yml)
