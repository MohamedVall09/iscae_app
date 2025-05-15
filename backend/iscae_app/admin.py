from django.contrib import admin
from .models import CustomUser, Filiere, Semestre, Matiere, EmploisDuTemps, Cours, Archive 
from django.contrib.auth.admin import UserAdmin

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('email', 'username', 'matricule', 'filiere', 'annee', 'is_staff')
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('matricule', 'prenom', 'filiere', 'annee')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        (None, {'fields': ('matricule', 'prenom', 'filiere', 'annee')}),
    )

admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(Filiere)
admin.site.register(Semestre)
admin.site.register(Matiere)
admin.site.register(EmploisDuTemps)
admin.site.register(Cours)
admin.site.register(Archive)
