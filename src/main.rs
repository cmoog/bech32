use bech32::{self, FromBase32, ToBase32, Variant};
use clap::{Arg, Command};
use std::io::{stdin, stdout, Read, Write};
use std::process;
use std::str;

const ARG_DATA: &str = "data";
const ARG_DECODE: &str = "decode";
const ARG_PREFIX: &str = "prefix";

fn main() {
    let matches = Command::new("bech32")
        .version("0.1.0")
        .arg(
            Arg::new(ARG_DATA)
                .takes_value(true)
                .help("Data to encode or decode. Leave empty to use stdin."),
        )
        .arg(
            Arg::new(ARG_DECODE)
                .short('d')
                .long("decode")
                .help("Decode data. The human-readable prefix is discarded."),
        )
        .arg(
            Arg::new(ARG_PREFIX)
                .long("prefix")
                .short('p')
                .takes_value(true)
                .help(
                    "The human-readable part of the encoded bech32 string.
Example) \"cm\" is the prefix for cm1vfjkx6zlxve97cmvd90ksetvwq0h3xcp",
                ),
        )
        .get_matches();

    if let Err(e) = execute(matches) {
        eprintln!("{}", e);
        process::exit(1);
    }
}

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn execute(matches: clap::ArgMatches) -> Result<()> {
    match matches.value_of(ARG_DATA) {
        None | Some("-") => {
            let mut buf = Vec::new();
            // TODO: read in chunks
            stdin().read_to_end(&mut buf)?;
            process_buf(&matches, buf)?;
        }
        Some(data) => process_buf(&matches, data.into())?,
    }
    Ok(())
}

fn process_buf(matches: &clap::ArgMatches, data: Vec<u8>) -> Result<()> {
    if matches.is_present(ARG_DECODE) {
        let raw = str::from_utf8(data.as_slice())?
            // trim trailing newline
            // This is a hack and should probably be removed, but it
            // ensures compatibility with simple usages of "echo", "cat", etc.
            .trim_end_matches("\n");

        let (_, base32, _) = bech32::decode(raw)?;
        let buf = Vec::<u8>::from_base32(&base32)?;
        stdout().write_all(buf.as_slice())?;
    } else {
        let hrp = matches.value_of(ARG_PREFIX).ok_or(clap::Error::raw(
            clap::ErrorKind::ArgumentConflict,
            "--prefix required for encoding",
        ))?;
        // TODO: add CLI flag for variant
        let s = bech32::encode(hrp, data.to_base32(), Variant::Bech32)?;
        println!("{}", s);
    }
    Ok(())
}
