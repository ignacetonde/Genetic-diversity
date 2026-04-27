#!/bin/bash
#SBATCH --job-name=filter_q20
#SBATCH --partition=normal
#SBATCH --nodelist=node01
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=/home/tonde/filtering_q20_%j.log
#SBATCH --error=/home/tonde/filtering_q20_%j.err
# Chargement des modules
module load bioinfo-wave
module load samtools/1.23.1
# 1. Accès au dossier où se trouvent les fichiers BAM triés
cd /scratch/tonde_mentha/rawdata/fastq_clean
# 2. Création du dossier pour les fichiers propres 
mkdir -p ./fichiers_filtres_propres
echo "Début du filtrage : $(date)"
echo "Fichier de scores utilisé : mapping_scores_final.tsv"
echo "--------------------------------------------------"
# 3. Lecture du fichier TSV et filtrage
# On saute l'en-tête (NR > 1) et on filtre les scores >= 20
awk 'NR > 1 { if ($2 >= 20) print $1, $2 }' mapping_scores_final.tsv | while read id score; do
        # Construction du nom du fichier source
        # Note : On utilise l'ID pour trouver le fichier _sorted.bam
    source="${id}_sorted.bam"
    cible="./fichiers_filtres_propres/${id}_q20.bam"
        echo "Analyse de $id | Score détecté : $score"
        if [ -f "$source" ]; then
        echo "   -> Filtrage Q20 de $source..."
        # On utilise -@ 8 pour accélérer la compression du BAM avec les threads alloués
        samtools view -@ 8 -b -q 20 "$source" > "$cible"
               echo "   -> Indexation du fichier filtré..."
        samtools index "$cible"
        echo " Terminé pour $id"
    else
        echo " ERREUR : Le fichier $source est introuvable."
    fi
    echo "--------------------------------------------------"
done
echo "Traitement global terminé le : $(date)"
echo "Les fichiers filtrés sont dans : $(pwd)/fichiers_filtres_propres"
