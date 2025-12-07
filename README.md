# Zsh plugin for SLURM

A zsh plugin for SLURM that provides convenient commands for running interactive SLURM jobs.

## Features

- `sbsh` - Run `srun bash` with configurable default arguments
- Override CPU and GPU counts on the fly
- Customizable default SLURM parameters

## Configuration

You can configure the default SLURM arguments by setting the following environment variables in your `.zshrc`:

```zsh
# Default account
SLURM_DEFAULT_ACCOUNT=espresso

# Default partition
SLURM_DEFAULT_PARTITION=espresso

# Default number of CPUs
SLURM_DEFAULT_CPUS=4

# Default number of GPUs
SLURM_DEFAULT_GPUS=1

# Additional default arguments (space-separated)
SLURM_DEFAULT_EXTRA_ARGS="--pty"
```

If not set, the defaults are:
- Account: `espresso`
- Partition: `espresso`
- CPUs: `4`
- GPUs: `1`
- Extra args: `--pty`

## Usage

### Basic usage

```zsh
sbsh
```

This will run: `srun -A espresso -p espresso -c 4 --gres=gpu:1 --pty bash`

### Override CPUs

```zsh
sbsh -c 16
```

This will run: `srun -A espresso -p espresso -c 16 --gres=gpu:1 --pty bash`

### Override GPUs

```zsh
sbsh -g 4
```

This will run: `srun -A espresso -p espresso -c 4 --gres=gpu:4 --pty bash`

### Request specific GPU type

```zsh
sbsh -g A100:2
```

This will run: `srun -A espresso -p espresso -c 4 --gres=gpu:A100:2 --pty bash`

### Override both CPUs and GPUs

```zsh
sbsh -c 16 -g 4
```

Or with GPU type:

```zsh
sbsh -c 16 -g L4:1
```

### Pass additional arguments to srun

```zsh
sbsh --time=01:00:00 --mem=32G
```

You can also pass additional `--gres` arguments directly:

```zsh
sbsh --gres=gpu:L4:1
```

This will run: `srun -A espresso -p espresso -c 4 --gres=gpu:1 --pty --gres=gpu:L4:1 bash`

You can combine all options:

```zsh
sbsh -c 16 -g A100:2 --time=01:00:00 --mem=32G
```

## Installation

### If you use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

* Clone this repository into `~/.oh-my-zsh/custom/plugins`
```sh
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/yourusername/slurm slurm
```
* After that, add `slurm` to your oh-my-zsh plugins array in your `.zshrc`:
```zsh
plugins=(... slurm)
```

### If you use [Zgen](https://github.com/tarjoilija/zgen)

1. Add `zgen load yourusername/slurm` to your `.zshrc` with your other plugin
2. run `zgen save`

### If you use [ZPM](https://github.com/zpm-zsh/zpm)

* Add `zpm load yourusername/slurm` into your `.zshrc`

### Manual installation

1. Clone this repository:
```sh
git clone https://github.com/yourusername/slurm ~/.zsh/plugins/slurm
```

2. Source the plugin in your `.zshrc`:
```zsh
source ~/.zsh/plugins/slurm/slurm.plugin.zsh
```
