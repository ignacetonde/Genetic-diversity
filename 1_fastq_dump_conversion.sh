#!/bin/bash
#SBATCH --job-name=fastq_dump_conversion
#SBATCH --partition=normal
#SBATCH --nodelist=node01
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=/home/tonde/fastq_dump_%j.log
#SBATCH --error=/home/tonde/fastq_dump_%j.err
# Chargement du module
module load bioinfo-wave
module load samtools/1.23.1
# On se place dans le dossier parent
cd /scratch/tonde_mentha/rawdata
# Création du dossier de destination s'il n'existe pas
mkdir -p fastq_clean
echo "Début de la conversion : $(date)"
# Boucle sur les dossiers/fichiers SRA (commençant par SRR)
for srr in SRR*; do
    # On vérifie que c'est bien un dossier ou un fichier existant
    [ -e "$srr" ] || continue
    echo "--------------------------------------------------"
    echo "Traitement de $srr en cours..."
        # --gzip : compresse directement en sortie
        # --stdout : envoie le flux dans le fichier spécifié par '>'
    fastq-dump --gzip --stdout "$srr" > "fastq_clean/${srr}.fastq.gz"
        if [ $? -eq 0 ]; then
        echo " Terminé avec succès pour $srr"
    else
        echo " Erreur lors de la conversion de $srr"
      fi
done
echo "--------------------------------------------------"
echo "Toutes les conversions sont terminées le : $(date)"
