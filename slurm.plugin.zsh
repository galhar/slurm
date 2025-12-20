#!/usr/bin/env zsh
# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Default SLURM configuration
SLURM_DEFAULT_ACCOUNT=${SLURM_DEFAULT_ACCOUNT:-espresso}
SLURM_DEFAULT_PARTITION=${SLURM_DEFAULT_PARTITION:-espresso}
SLURM_DEFAULT_CPUS=${SLURM_DEFAULT_CPUS:-4}
SLURM_DEFAULT_GPUS=${SLURM_DEFAULT_GPUS:-1}
SLURM_DEFAULT_EXTRA_ARGS=${SLURM_DEFAULT_EXTRA_ARGS:-"--pty"}

# Shared squeue output format
SLURM_SQUEUE_FORMAT="%.10i %.9P %.10j %.8u  %.10M %.6C %.14b %.10R"

# sbsh - srun bash with default arguments
# Usage: sbsh [-g N|TYPE:N] [any srun arguments...]
# Any SLURM argument can be passed directly and will override defaults
# -g is a convenience shortcut for --gres=gpu:
# SLURM uses the last occurrence of conflicting flags, so user args override defaults
function sbsh() {
  local gpus=$SLURM_DEFAULT_GPUS
  local user_args=()
  local srun_args=()

  # Parse -g convenience flag (not a standard SLURM flag)
  while [[ $# -gt 0 ]]; do
    case $1 in
      -g|--g)
        if [[ -n "$2" && ("$2" =~ ^[0-9]+$ || "$2" =~ ^[A-Za-z0-9]+:[0-9]+$) ]]; then
          gpus=$2
          shift 2
        else
          echo "Error: -g requires a number (e.g., 2) or GPU type specification (e.g., A100:2)" >&2
          return 1
        fi
        ;;
      *)
        # All other arguments are passed directly to srun
        user_args+=("$1")
        shift
        ;;
    esac
  done

  # Build srun command with defaults first
  srun_args=(
    -A "$SLURM_DEFAULT_ACCOUNT"
    -p "$SLURM_DEFAULT_PARTITION"
    -c "$SLURM_DEFAULT_CPUS"
    --gres="gpu:$gpus"
  )

  # Add extra default arguments if set
  if [[ -n "$SLURM_DEFAULT_EXTRA_ARGS" ]]; then
    local default_extra=(${(s: :)SLURM_DEFAULT_EXTRA_ARGS})
    srun_args+=($default_extra)
  fi

  # Add user-provided arguments (these will override defaults if they conflict)
  # SLURM uses the last occurrence of conflicting flags, so user args override defaults
  if [[ ${#user_args} -gt 0 ]]; then
    srun_args+=(${user_args})
  fi

  # Add bash at the end
  srun_args+=(bash)

  # Execute srun
  command srun $srun_args
}

# sq - squeue with default partition
# Usage: sq [any squeue arguments...]
# Any squeue argument can be passed directly and will override defaults
# SLURM uses the last occurrence of conflicting flags, so user args override defaults
function sq() {
  local squeue_args=()

  # Build squeue command with defaults first
  squeue_args=(
    -p "$SLURM_DEFAULT_PARTITION"
    --sort=+u
    -o "$SLURM_SQUEUE_FORMAT"
  )

  # Add user-provided arguments (these will override defaults if they conflict)
  if [[ $# -gt 0 ]]; then
    squeue_args+=("$@")
  fi

  # Execute squeue with formatted output
  command squeue $squeue_args | sed 's/gres:gpu://g'
}

# sqme - squeue for current user
# Usage: sqme [additional squeue arguments...]
# Any squeue argument can be passed directly and will override defaults
function sqme() {
  # Build squeue command with defaults
  local squeue_args=(
    -u "$USER"
    --sort=+u
    -o "$SLURM_SQUEUE_FORMAT"
  )

  # Add any user-provided extra arguments (these will override defaults if they conflict)
  if [[ $# -gt 0 ]]; then
    squeue_args+=("$@")
  fi

  # Execute squeue for current user with formatted output
  command squeue $squeue_args | sed 's/gres:gpu://g'
}

