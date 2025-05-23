# Generated by Django 5.2 on 2025-05-08 20:09

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('iscae_app', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Matiere',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nom', models.CharField(max_length=100)),
                ('semestre', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='iscae_app.semestre')),
            ],
        ),
        migrations.CreateModel(
            name='Cours',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('titre', models.CharField(max_length=200)),
                ('fichier', models.FileField(upload_to='cours/')),
                ('matiere', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='iscae_app.matiere')),
            ],
        ),
    ]
