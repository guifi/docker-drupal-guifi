# Docker environment for guifi.net website
Docker images for Drupal with drupal-guifi module enabled
## Requirements
We must have installed those packages:
- **docker engine**: version 1.13 or above
- **python**: 2.7
- **python-pip**: suitable for version 2.7
- **docker-compose**: preferible latest versions
- **git**: any version

### Requirements installation (Debian)
Firstly, we should install **docker-ce** engine. The tutorial shown in docker website should be enough to achieve that: (https://docs.docker.com/engine/installation/linux/docker-ce/debian/#install-using-the-repository)

The next step would be the installation of python packages (if they weren't installed before):

```
sudo apt install -y python2.7 python-pip git
```

The last step would be docker-compose installation:

```
sudo pip install docker-compose
```

And that should be enough to run our docker-compose files.

## Working with this composition
In this point we include all possible image uses at the moment. All images supplied support Xdebug PHP Debugger (https://xdebug.org/) compatible with a lot of IDEs. 
### Drupal 6
If you want to work with this version of guifi webpage you should clone this repository inside a development directory with writing permissions:

```
git clone https://github.com/guifi/docker-drupal-guifi
```

and go to the directory where there is [the docker-compose.yml file](./drupal6/docker-compose.yml) to build the development environment

```
cd docker-drupal-guifi/drupal6
docker-compose up
```

This command downloads automates installation similar to guifi.net website, its output is the log of the procedure, installation is finished when you see:

```
Guifi.net dev page successfully installed in Docker image!
```

After that you can navigate to:
- guifi.net website: http://localhost:8080 with `user: webmestre` and `password: guifi`
- phpmyadmin (database visualization): http://localhost:8000 with `user: root` and `password: admin`

User `webmestre` is the Drupal ID 1 user. It is imperative to use this user to test migrations to further Drupal versions.

In this environment, all drupal users of guifi.net website will have the same password: **guifi**

If you want to erase all development website's content and create a new one, we should execute those commands:
```
docker-compose rm -vf
sudo rm -rf ./guifi-web/*
docker-compose up
```
