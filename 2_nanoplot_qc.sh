#!/bin/bash
#SBATCH --job-name=nanoplot_qc
#SBATCH --partition=normal
#SBATCH --nodelist=node01
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --output=nanoplot_%j.log
#SBATCH --error=nanoplot_%j.err
# 1. Dossiers
RAW_DIR="/scratch/tonde_mentha/rawdata"
OUT_DIR="/scratch/tonde_mentha/QC_Results_Final"
mkdir -p "$OUT_DIR"
cd "$RAW_DIR" || exit 1
# 2. Charger le module NanoPlot (si nécessaire sur ton cluster)
# module load nanoplot  
# Décommente cette ligne si NanoPlot n'est pas dans ton PATH par défaut
# 3. Boucle de traitement
for file in *.fastq.gz; do
    [ -e "$file" ] || continue
    name=$(basename "$file" .fastq.gz)
        echo "Processing $name at $(date)"
         Exécution de NanoPlot avec 4 threads (cohérent avec --cpus-per-task=4)
    NanoPlot -t 4 --fastq "$file" -o "$OUT_DIR/QC_$name"
done
echo "Job finished at $(date)"
