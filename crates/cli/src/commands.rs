#[derive(clap::Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub(crate) struct Args {
    #[clap(subcommand)]
    pub command: Commands,
}

#[derive(clap::Subcommand, Debug)]
pub(crate) enum Commands {
    Generate(Generate),
}

#[derive(clap::Args, Debug)]
pub(crate) struct Generate {
    #[clap(subcommand)]
    pub command: GenerateCommands,
}

#[derive(clap::Subcommand, Debug)]
pub(crate) enum GenerateCommands {
    Default,
}
