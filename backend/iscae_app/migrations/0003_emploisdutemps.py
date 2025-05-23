# Generated by Django 5.2 on 2025-05-08 20:35

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('iscae_app', '0002_matiere_cours'),
    ]

    operations = [
        migrations.CreateModel(
            name='EmploisDuTemps',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('jour', models.CharField(max_length=20)),
                ('heure_debut', models.TimeField()),
                ('heure_fin', models.TimeField()),
                ('matiere', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='iscae_app.matiere')),
                ('semestre', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='iscae_app.semestre')),
            ],
        ),
    ]
