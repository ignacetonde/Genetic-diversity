#!/bin/bash
#SBATCH --job-name=sniffles_stricts
#SBATCH --partition=normal
#SBATCH --nodelist=node01
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --output=/home/tonde/sniffles_calling_%j.log
#SBATCH --error=/home/tonde/sniffles_calling_%j.err
# Chargement des modules (ajustez selon votre cluster)
module load bioinfo-wave
module load sniffles/2.3.3(n’étant pas disponible sur le cluster j’ai dû installer cet environnement)  # 
module load samtools/1.23.1
# Déplacement dans le dossier de travail
cd /scratch/tonde_mentha/rawdata/fastq_clean/nouveau/fichiers_filtres_propres
echo "Job démarré le : $(date)"
# 1. On crée le dossier de sortie pour les signatures
mkdir -p ./SVs_Sniffles_Stricts
# 2. Étape 1 : Génération des signatures (.snf)
# On utilise 2 threads par échantillon pour traiter plusieurs fichiers en même temps
# ou on garde une boucle simple (plus sûr pour la mémoire)
for bam in *_q20.bam; do
    if [ -f "$bam" ]; then
        echo "Traitement de $bam (Min Support: 10)..."
        sniffles --input "$bam" \
                 --snf "./SVs_Sniffles_Stricts/${bam%_q20.bam}.snf" \
                 --minsupport 10 \
                 --threads 16
    fi
done
# 3. Étape 2 : Fusion globale (Population Calling)
echo "Fusion de tous les échantillons vers le VCF global..."
# Sniffles2 permet de passer tous les. snf en entrée pour une fusion propre
sniffles --input ./SVs_Sniffles_Stricts/*.snf \
         --vcf SVs_globaux_stricts_10.vcf \
         --threads 16
echo " Terminé ! Le fichier propre est : SVs_globaux_stricts_10.vcf"
echo "Job terminé le : $(date)"
