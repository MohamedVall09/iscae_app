from django.shortcuts import render
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth.hashers import make_password
from .models import CustomUser, Filiere, Semestre, Matiere, EmploisDuTemps, Cours, Archive
from .serializers import CustomUserSerializer, FiliereSerializer, SemestreSerializer, MatiereSerializer, EmploisDuTempsSerializer, CoursSerializer, ArchiveSerializer
 


# جلب بيانات الطالب من رقم التسجيل
@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_by_matricule(request):
    matricule = request.GET.get('matricule')
    try:
        user = CustomUser.objects.get(matricule=matricule)
        return Response(CustomUserSerializer(user).data)
    except CustomUser.DoesNotExist:
        return Response({'message': 'Utilisateur non trouvé'}, status=404)

# تسجيل الحساب بعد جلب البيانات
@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    data = request.data
    try:
        user = CustomUser.objects.get(matricule=data['matricule'])
        user.email = data['email']
        user.password = make_password(data['password'])
        user.save()
        return Response({'message': 'Compte créé avec succès'}, status=201)
    except:
        return Response({'message': 'Erreur lors de la création'}, status=400)

# استرجاع بيانات المستخدم المسجل حاليًا
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_authenticated_user(request):
    return Response(CustomUserSerializer(request.user).data)

# جلب الفيلير
@api_view(['GET'])
@permission_classes([AllowAny])
def get_filieres(request):
    filieres = Filiere.objects.all()
    return Response(FiliereSerializer(filieres, many=True).data)

# جلب الفصول حسب الفيلير والسنة
@api_view(['GET'])
@permission_classes([AllowAny])
def semestres_par_annee_et_filiere(request):
    filiere_id = request.GET.get('filiere')
    annee = request.GET.get('annee')

    noms = {
        'L1': ['S1', 'S2'],
        'L2': ['S3', 'S4'],
        'L3': ['S5', 'S6'],
    }.get(annee, [])

    semestres = Semestre.objects.filter(filiere_id=filiere_id, nom__in=noms)
    return Response(SemestreSerializer(semestres, many=True).data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_matieres_by_semestre(request):
    semestre_id = request.GET.get('semestre')
    matieres = Matiere.objects.filter(semestre_id=semestre_id)
    return Response(MatiereSerializer(matieres, many=True).data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_emplois_by_semestre(request):
    semestre_id = request.GET.get('semestre')
    emplois = EmploisDuTemps.objects.filter(semestre_id=semestre_id)
    return Response(EmploisDuTempsSerializer(emplois, many=True).data)



@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_cours_by_matiere(request):
    matiere_id = request.GET.get('matiere')
    cours = Cours.objects.filter(matiere_id=matiere_id)
    data = [{'id': c.id, 'titre': c.titre, 'fichier': c.fichier.url} for c in cours]
    return Response(data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_archives(request):
    matiere_id = request.GET.get('matiere')
    archives = Archive.objects.filter(matiere_id=matiere_id)
    serializer = ArchiveSerializer(archives, many=True)
    return Response(serializer.data)