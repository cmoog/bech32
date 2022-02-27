use anyhow::Result;
use bech32::{self, FromBase32, ToBase32};
use clap::{App, Arg};
use std::io::{stdin, BufRead};

fn main() {
    let matches = App::new("bech32")
        .version("0.0.1")
        .arg(Arg::with_name("data").takes_value(true))
        .arg(Arg::with_name("decode").short("d").long("decode"))
        .arg(
            Arg::with_name("prefix")
                .long("prefix")
                .short("p")
                .takes_value(true),
        )
        .get_matches();

    match execute(matches) {
        Ok(_) => {}
        Err(e) => eprintln!("{}", e),
    };
}

fn execute(matches: clap::ArgMatches) -> Result<()> {
    if let Some(line) = matches.value_of("data") {
        process_line(&matches, line)?;
    } else {
        let stdin = stdin();
        let lines = stdin.lock().lines();
        for line in lines {
            process_line(&matches, line?.as_str())?;
        }
    }
    Ok(())
}

fn process_line(matches: &clap::ArgMatches, line: &str) -> Result<()> {
    if matches.is_present("decode") {
        let (_, data) = bech32::decode(line)?;
        let base32 = Vec::<u8>::from_base32(&data)?;
        let str = std::str::from_utf8(base32.as_slice())?;
        println!("{}", str)
    } else {
        let hrp = matches
            .value_of("prefix")
            .ok_or(clap::Error::with_description(
                "--prefix required for encoding",
                clap::ErrorKind::ArgumentConflict,
            ))?;
        let s = bech32::encode(hrp, line.to_base32())?;
        println!("encoded = {}", s);
    }
    Ok(())
}
