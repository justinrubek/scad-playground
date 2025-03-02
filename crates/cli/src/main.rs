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
                    let cube_a = cube!([60., 20., 10.], true);
                    let mut cube_b = cube!([30., 20., 10.], true);
                    cube_b = translate!([0., 0., 10.], cube_b;);
                    let mut connector = cube!([30., 20., 0.002], true);
                    connector = translate!([0., 0., 5.-0.001], connector;);

                    let finished = cube_a + cube_b + connector;
                    finished.save("default.scad");
                }
            }
        }
    }

    Ok(())
}
