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
                    let cube = cube!(2.);
                    let sphere = sphere!(1.0, fn=128);
                    let mut sphere_b = sphere!(1.0, fn=256);
                    sphere_b = translate!([1.2, 0.0, 0.0], sphere_b;);

                    let difference = difference!(cube; sphere; sphere_b;);
                    difference.save("default.scad");
                }
            }
        }
    }

    Ok(())
}
