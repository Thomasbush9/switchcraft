#!/usr/bin/env bash
#SBATCH --nodes=<nodes>
#SBATCH --ntasks-per-node=<ntasks_per_node>
#SBATCH --cpus-per-task=<cpus_per_task>
#SBATCH --gpus-per-node=<gpus_per_node>
#SBATCH --mem=<mem>
# Partition/account set by caller via sbatch flags (from config)
#SBATCH --partition=<partition>
#SBATCH --account=<account>
#SBATCH --time=01:00:00
# Log dir from env (caller passes -o)
#SBATCH --output=<output_dir>%x.%A_%a.out

# Minimal example (repo + Boltz weights baked in SIF; only output dir on host):
#   mkdir -p /scratch/${USER}/switchcraft_out
#   sbatch launch_switchcraft.slurm \
#     tasks/pos_allostery.yaml \
#     /path/to/switchcraft.sif \
#     /scratch/${USER}/switchcraft_out
#
# Args:
#   CONFIG_FILE        — YAML under /opt/switchcraft (e.g. tasks/pos_allostery.yaml)
#   SWITCHCRAFT_IMAGE  — path to .sif
#   OUTPUT_DIR         — host scratch dir (bind-mounted for writes)

set -euo pipefail

CONFIG_FILE="${1}"
SWITCHCRAFT_IMAGE="${2}"
OUTPUT_DIR="${3}"

mkdir -p "${OUTPUT_DIR}"

echo "Running ${SWITCHCRAFT_IMAGE}"
echo "  config: ${CONFIG_FILE}"
echo "  output: ${OUTPUT_DIR}"

singularity exec --nv --pwd /opt/switchcraft \
  -B "${OUTPUT_DIR}:${OUTPUT_DIR}" \
  "${SWITCHCRAFT_IMAGE}" \
  python switchcraft.py \
    --config "${CONFIG_FILE}" \
    --outpath "${OUTPUT_DIR}" \
    --verbose

echo "Run completed."
