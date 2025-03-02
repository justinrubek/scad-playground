use crate::{
    commands::{Commands, GenerateCommands},
    error::Result,
};
use clap::Parser;
use scad_tree::prelude::*;

mod commands;
mod error;

fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let args = commands::Args::parse();
    match args.command {
        Commands::Generate(generate) => {
            let cmd = generate.command;
            match cmd {
                GenerateCommands::Default => {
                    let cube = cube!([25., 35., 55.], true);

                    let finished = cube;
                    finished.save("default.scad");
                }
            }
        }
    }

    Ok(())
}
