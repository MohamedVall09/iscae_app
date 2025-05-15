from django.db import models
from django.contrib.auth.models import AbstractUser


class Filiere(models.Model):
    nom = models.CharField(max_length=100)

    def __str__(self):
        return self.nom

class Semestre(models.Model):
    nom = models.CharField(max_length=10)
    filiere = models.ForeignKey(Filiere, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.nom} - {self.filiere.nom}"

class CustomUser(AbstractUser):
    matricule = models.CharField(max_length=20, unique=True)
    prenom = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    filiere = models.ForeignKey(Filiere, on_delete=models.SET_NULL, null=True)
    annee = models.CharField(max_length=10, choices=[('L1', 'L1'), ('L2', 'L2'), ('L3', 'L3')])

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

class Matiere(models.Model):
    nom = models.CharField(max_length=100)
    semestre = models.ForeignKey(Semestre, on_delete=models.CASCADE)

    def __str__(self):
        return self.nom

class EmploisDuTemps(models.Model):
    jour = models.CharField(max_length=20)
    heure_debut = models.TimeField()
    heure_fin = models.TimeField()
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE)
    semestre = models.ForeignKey(Semestre, on_delete=models.CASCADE)
    

class Cours(models.Model):
    titre = models.CharField(max_length=200)
    fichier = models.FileField(upload_to='cours/')
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE)

    def __str__(self):
        return self.titre



class Archive(models.Model):
    titre = models.CharField(max_length=255)
    fichier = models.FileField(upload_to='archives/')
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE, related_name='archives')

    def __str__(self):
        return self.titre
