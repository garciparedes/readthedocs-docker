# readthedocs-docker

## Description
[TODO]

## Usage
[TODO]

```bash
docker run -d -it -p 8000:8000 --name readthedocs garciparedes/readthedocs
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
