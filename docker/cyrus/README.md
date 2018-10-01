# Docker uwegerdes/cyrus

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/cyrus \
	.
```

## Usage

Run the postfix container with:

```bash
$ docker run -it \
	--hostname cyrus \
	--name cyrus \
	uwegerdes/cyrus \
	bash
```
