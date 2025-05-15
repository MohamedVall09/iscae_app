from django.contrib import admin
from django.urls import path
from iscae_app import views
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/get_user_by_matricule/', views.get_user_by_matricule),
    path('api/register/', views.register_user),
    path('api/user/', views.get_authenticated_user),
    path('api/filieres/', views.get_filieres),
    path('api/semestres/', views.semestres_par_annee_et_filiere),
    path('api/matieres/', views.get_matieres_by_semestre),
    path('api/emplois_du_temps/', views.get_emplois_by_semestre),
    path('api/cours/', views.get_cours_by_matiere),
    path('api/archives/', views.get_archives),

]
