# Swift Package Registry - Reference Implementation

![CI][ci badge]

This is a reference implementation for a package registry service,
as described in [this proposal](https://github.com/apple/swift-evolution/pull/1179).

## Requirements

- macOS 10.14+
- Swift 5.2+ (_install the latest version of Xcode_)
- [Homebrew](https://brew.sh)
- Docker* (_optional_)

## Setup

Install the required system dependencies by running the following command:

```terminal
$ brew bundle
```

## Usage

A command-line interface is provided in addition to the web server
for more convenient testing and debugging.

### Server

Run the following command to spin up a package registry locally.

```terminal
$ swift run registry serve --index path/to/index
```

A registry index (that is, a Git repository used as a database)
will be created at the specified path if one doesn't already exist there.

You can interact with the registry using `curl` or your REST client of choice.

```terminal
$ curl -X PUT \
    -H "Accept: application/vnd.swift.registry.v1+json" \
    "http://localhost:8080/github.com/Alamofire/Alamofire/5.0.0"
```

### Command Line Interface

```terminal
$ swift run registry --help
USAGE: registry-command <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    Initializes a new registry at the specified path.
  publish                 Creates a new release of a package.
  serve                   Runs the registry web service locally.

  See 'registry-command help <subcommand>' for detailed help.

$ swift run registry init --index path/to/index
$ swift run registry publish github.com/Jounce/Surge 2.3.0 --index path/to/index
$ swift run registry publish github.com/Flight-School/Money 1.2.0 --index path/to/index
$ swift run registry list --index path/to/index
github.com/Flight-School/Money - 1.2.0
github.com/Jounce/Surge - 2.3.0
```

[ci badge]: https://github.com/mattt/swift-registry/workflows/CI/badge.svg
