#!/bin/bash
#SBATCH --job-name=minimap2_pacbio
#SBATCH --partition=normal
#SBATCH --nodelist=node01
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --output=/home/tonde/mapping_pacbio_%j.log
#SBATCH --error=/home/tonde/mapping_pacbio_%j.err
# Chargement des modules
module load bioinfo-wave
module load minimap2/2.30-r1287
module load samtools/1.23.1
# 1. Accès au dossier de travail correct
cd /scratch/tonde_mentha/rawdata/fastq_clean
# Définition des noms de fichiers 
REF="GCA_041501505.1_MenthaSuaveolens85_v8_genomic.fna"
INDEX="reference.mmi"
echo "Job démarré le : $(date)"
# 2. Vérification/Création de l'index minimap2
if [ ! -f "$INDEX" ]; then
    echo "Indexation du génome de référence..."
    minimap2 -d "$INDEX" "$REF"
fi
# 3. Boucle de mapping
for f in SRR*.fastq.gz; do
    # Vérifie si des fichiers SRR existent
    [ -e "$f" ]  ||{ echo "Aucun fichier SRR*.fastq.gz trouvé dans $(pwd)"; exit 1; }
    name=$(basename "$f" .fastq.gz)
        echo "--------------------------------------------------"
    echo "Mapping de : $name"
        # Mapping (map-pb) + Tri (sort) en une seule étape
    # On utilise 12 threads pour minimap2 et 4 pour samtools (total 16)
    minimap2 -ax map-pb -t 12 "$INDEX" "$f" | \
    samtools sort -@ 4 -o "${name}_sorted.bam"
        # Indexation du BAM
    echo "Création de l'index pour ${name}_sorted.bam..."
    samtools index "${name}_sorted.bam"
done
echo "--------------------------------------------------"
echo "Traitement terminé le : $(date)"
