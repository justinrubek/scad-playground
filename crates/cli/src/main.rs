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

fn triangular_prism(b: f64, d: f64, h: f64, h_z: f64) -> Scad {
    let mut points = Pt2s::new();
    for point in [Pt2::new(0., 0.), Pt2::new(b, 0.), Pt2::new(d, h)] {
        points.push(point)
    }
    let mut face = polygon!(points);
    face = linear_extrude!(h_z, face;);
    face = rotate!([90., 90., 90.], face;);
    face = translate!([-h_z/2., 0., 0.], face;);

    face
}

fn roof(l: f64) -> Scad {
    let h = l / 8. + 1.999;
    let mut a = triangular_prism(3., 3., l / 4., l);
    a = translate!([0., 0., h], a;);
    a = color!("red", a;);
    let mut b = triangular_prism(3., 3., l / 4., l);
    b = translate!([0., 0., h], b;);
    b = color!("blue", b;);
    b = mirror!([0., 1., 0.], b;);

    a + b
}

fn house(l: f64) -> Scad {
    let body = cube!([l, l / 2., l / 8.], true);
    let roof = roof(l);

    let mut chimney = cube!([0.5, 0.5, 3.]);
    chimney = translate!([5., 1., 1.], chimney;);

    body + roof + chimney
}

fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let args = commands::Args::parse();
    match args.command {
        Commands::Generate(generate) => {
            let cmd = generate.command;
            match cmd {
                GenerateCommands::Default => {
                    scad_file!(32, "car.scad", fa=1.0, fs=0.4, car(););
                    scad_file!(32, "house.scad", fa=1.0, fs=0.4, house(16.););
                }
            }
        }
    }

    Ok(())
}
