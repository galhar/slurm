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

# sbsh - srun bash with default arguments
# Usage: sbsh [-c N] [-g N|TYPE:N] [additional srun arguments...]
function sbsh() {
  local cpus=$SLURM_DEFAULT_CPUS
  local gpus=$SLURM_DEFAULT_GPUS
  local extra_args=()
  local srun_args=()

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -c|--c)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
          cpus=$2
          shift 2
        else
          echo "Error: -c requires a number" >&2
          return 1
        fi
        ;;
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
        # Any other arguments are passed directly to srun
        extra_args+=("$1")
        shift
        ;;
    esac
  done

  # Build srun command
  # GPU specification: supports both numeric (e.g., "2") and type:count (e.g., "A100:2")
  srun_args=(
    -A "$SLURM_DEFAULT_ACCOUNT"
    -p "$SLURM_DEFAULT_PARTITION"
    -c "$cpus"
    --gres="gpu:$gpus"
  )

  # Add extra default arguments if set
  if [[ -n "$SLURM_DEFAULT_EXTRA_ARGS" ]]; then
    # Split SLURM_DEFAULT_EXTRA_ARGS by spaces and add each as a separate argument
    local default_extra=(${(s: :)SLURM_DEFAULT_EXTRA_ARGS})
    srun_args+=($default_extra)
  fi

  # Add any user-provided extra arguments
  if [[ ${#extra_args} -gt 0 ]]; then
    srun_args+=($extra_args)
  fi

  # Add bash at the end
  srun_args+=(bash)

  # Execute srun
  command srun $srun_args
}

