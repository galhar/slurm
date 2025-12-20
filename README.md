# Zsh plugin for SLURM

A zsh plugin for SLURM that provides convenient commands for running interactive SLURM jobs.

## Features

- `sbsh` - Run `srun bash` with configurable default arguments
- `sq` - View queue for default partition (with formatted output)
- `sqme` - View your own jobs in the queue (with formatted output)
- Override any SLURM parameter on the fly
- Customizable default SLURM parameters

## Configuration

Set these environment variables in your `.zshrc`:

```zsh
SLURM_DEFAULT_ACCOUNT=espresso
SLURM_DEFAULT_PARTITION=espresso
SLURM_DEFAULT_CPUS=4
SLURM_DEFAULT_GPUS=1
SLURM_DEFAULT_EXTRA_ARGS="--pty"
```

Defaults (if not set): `espresso` account/partition, `4` CPUs, `1` GPU, `--pty` extra args.

## Usage

### sbsh - Run interactive bash session

**Default command:**
```sh
sbsh
# Runs: srun -A espresso -p espresso -c 4 --gres=gpu:1 --pty bash
```

**Examples:**
```zsh
# Override CPUs and GPUs
sbsh -c 16 -g 4

# Request specific GPU type
sbsh -g A100:2

# Override partition
sbsh -p public

# Pass any SLURM arguments (override defaults)
sbsh --time=01:00:00 --mem=32G
sbsh -A myaccount --partition=public

# Combine options
sbsh -c 16 -g A100:2 -p public --time=01:00:00 --mem=32G
```

**Note:** Any SLURM argument can be passed directly. User arguments override defaults (SLURM uses the last occurrence of conflicting flags).

### sq - View queue

**Default command:**
```sh
sq
# Runs: squeue -p espresso --sort=+u -o "%.10i %.9P %.10j %.8u  %.10M %.6C %.14b %.10R" | sed 's/gres:gpu://g'
```

**Examples:**
```zsh
# Specific partition
sq -p public
sq --partition=public

# With filters
sq -p public --states=RUNNING
```

### sqme - View your jobs

**Default command:**
```sh
sqme
# Runs: squeue -u $USER --sort=+u -o "%.10i %.9P %.10j %.8u  %.10M %.6C %.14b %.10R" | sed 's/gres:gpu://g'
```

**Examples:**
```zsh
# With filters
sqme --states=RUNNING
sqme --partition=public --states=PENDING
```

## Installation

### oh-my-zsh

```sh
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/yourusername/slurm slurm
```

Add to `.zshrc`: `plugins=(... slurm)`

### Zgen

Add to `.zshrc`: `zgen load yourusername/slurm`, then run `zgen save`

### ZPM

Add to `.zshrc`: `zpm load yourusername/slurm`

### Manual

```sh
git clone https://github.com/yourusername/slurm ~/.zsh/plugins/slurm
```

Add to `.zshrc`: `source ~/.zsh/plugins/slurm/slurm.plugin.zsh`
