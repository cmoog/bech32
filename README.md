
# bech32 CLI

A small command-line utility for encoding and decoding bech32 strings.

## Installation

```
cargo install --git https://github.com/cmoog/bech32
```

## Usage

```
bech32 0.1.0

USAGE:
    bech32 [FLAGS] [OPTIONS] [data]

FLAGS:
    -d, --decode     Decode data. The human-readable prefix is discarded.
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -p, --prefix <prefix>    The human-readable part of the encoded bech32 string.
                             Example) "cm" is the prefix for cm1vfjkx6zlxve97cmvd90ksetvwq0h3xcp

ARGS:
    <data>    Data to encode or decode. Leave empty to use stdin.
```
