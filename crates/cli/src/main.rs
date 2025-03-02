use crate::{
    commands::{Commands, GenerateCommands},
    error::Result,
};
use clap::Parser;
use scad_tree::prelude::*;

mod commands;
mod error;

fn car_body() -> Scad {
    let cube_a = cube!([60., 20., 10.], true);
    let mut cube_b = cube!([30., 20., 10.], true);
    cube_b = translate!([0., 0., 10.], cube_b;);
    let mut connector = cube!([30., 20., 0.002], true);
    connector = translate!([0., 0., 5.-0.001], connector;);

    cube_a + cube_b + connector
}

fn wheel() -> Scad {
    let mut cylinder = cylinder!(3., 8.);
    cylinder = rotate!([90., 0., 0.], cylinder;);

    cylinder
}

fn axle() -> Scad {
    let dist = 15.;

    let mut left = wheel();
    left = translate!([0., -15., 0.], left;);
    let mut right = wheel();
    right = translate!([0., 18., 0.], right;);

    let mut axle = cylinder!(dist * 2. + 0.002, 3., 3., true);
    axle = rotate!([90., 0., 0.], axle;);

    left + right + axle
}

fn car() -> Scad {
    let body = car_body();

    let mut front_axle = axle();
    front_axle = translate!([20., 0., -2.], front_axle;);
    let mut back_axle = axle();
    back_axle = translate!([-20., 0., -2.], back_axle;);

    body + front_axle + back_axle
}

fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let args = commands::Args::parse();
    match args.command {
        Commands::Generate(generate) => {
            let cmd = generate.command;
            match cmd {
                GenerateCommands::Default => {
                    let car = car();
                    scad_file!(32, "default.scad", fa=1.0, fs=0.4, car;);
                }
            }
        }
    }

    Ok(())
}
