# readthedocs-docker

## Description
Dockerized readthedocs image.

## Usage

```bash
docker run -d -it -p 8000:8000 --env "RTD_PRODUCTION_DOMAIN=0.0.0.0:8000" --name readthedocs garciparedes/readthedocs
```

```bash
docker start readthedocs
```

```bash
docker stop readthedocs
```

```bash
docker rm --force readthedocs
```

## Development
```bash
docker build -t garciparedes/readthedocs .
```

```bash
docker logs readthedocs
```

```bash
docker exec -it readthedocs bash
```

## Contributors
* [Sergio García Prado](https://garciparedes.me)
