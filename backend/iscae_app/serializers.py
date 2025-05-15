from rest_framework import serializers
from .models import CustomUser, Filiere, Semestre, Matiere, EmploisDuTemps, Cours, Archive


class FiliereSerializer(serializers.ModelSerializer):
    class Meta:
        model = Filiere
        fields = ['id', 'nom']

class SemestreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Semestre
        fields = ['id', 'nom']

class CustomUserSerializer(serializers.ModelSerializer):
    filiere = FiliereSerializer()  # تضمين بيانات الفيلير
    class Meta:
        model = CustomUser
        fields = ['email', 'username', 'prenom', 'matricule', 'filiere', 'annee']

class MatiereSerializer(serializers.ModelSerializer):
    class Meta:
        model = Matiere
        fields = '__all__'


class EmploisDuTempsSerializer(serializers.ModelSerializer):
    matiere = serializers.CharField(source='matiere.nom')  # اسم المادة بدلاً من الـ id

    class Meta:
        model = EmploisDuTemps
        fields = ['jour', 'heure_debut', 'heure_fin', 'matiere']

class CoursSerializer(serializers.ModelSerializer):
    matiere = serializers.CharField(source='matiere.nom')  # لعرض اسم المادة بدلاً من ID

    class Meta:
        model = Cours
        fields = ['id', 'titre', 'fichier', 'matiere']


class ArchiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Archive
        fields = '__all__'
