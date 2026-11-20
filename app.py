#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Flask, request, render_template, redirect, flash

app = Flask(__name__)
app.config["TEMPLATES_AUTO_RELOAD"] = True
app.secret_key = 'une cle(token) : grain de sel(any random string)'


from flask import session, g
import pymysql.cursors

def get_db():
    if 'db' not in g:
        g.db =  pymysql.connect(
            host="serveurmysql.iut-bm.univ-fcomte.fr",  # localhost sur les machines perso.
            user="hatni",
            password="secret",
            database="BDD_hatni",
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
    return g.db

@app.teardown_appcontext
def teardown_db(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()


@app.route('/')
def show_accueil():
    return render_template('index.html')


@app.route('/vente/show')
def show_ventes():
    mycursor = get_db().cursor()
    sql = '''   SELECT VENTE.id_vente AS id
     , VENTE.date_vente
     , VENTE.prix_final
     , VENTE.remise_parrainage
     , VENTE.mode_paiement
     , VENTE.voiture_id
     , MODELE.nom_modele
     , COULEUR.libelle_couleur
     , EMPLOYE.nom AS nom_employe
     , EMPLOYE.prenom AS prenom_employe
     , CLIENT.nom AS nom_client
     , CLIENT.prenom AS prenom_client
    FROM VENTE
    INNER JOIN VOITURE ON VOITURE.id_voiture = VENTE.voiture_id
    INNER JOIN MODELE ON MODELE.id_modele = VOITURE.modele_id
    INNER JOIN COULEUR ON COULEUR.id_couleur = VOITURE.couleur_id
    INNER JOIN EMPLOYE ON EMPLOYE.id_employe = VENTE.employe_id
    INNER JOIN CLIENT ON CLIENT.id_client = VENTE.client_id
    ORDER BY VENTE.date_vente DESC;      '''
    mycursor.execute(sql)
    liste_ventes = mycursor.fetchall()
    return render_template('vente/show_vente.html', ventes=liste_ventes)


@app.route('/vente/add', methods=['GET'])
def add_vente():
    print('''affichage du formulaire pour saisir une vente''')
    mycursor = get_db().cursor()
    sql = '''   SELECT VOITURE.id_voiture
     , MODELE.nom_modele
     , COULEUR.libelle_couleur
     , ETAT.libelle_etat
     , VOITURE.kilometrage
    FROM VOITURE
    INNER JOIN MODELE ON MODELE.id_modele = VOITURE.modele_id
    INNER JOIN COULEUR ON COULEUR.id_couleur = VOITURE.couleur_id
    INNER JOIN ETAT ON ETAT.id_etat = VOITURE.etat_id
    ORDER BY MODELE.nom_modele;      '''
    mycursor.execute(sql)
    liste_voitures = mycursor.fetchall()

    sql = '''   SELECT id_employe AS id, nom, prenom
                FROM EMPLOYE
                ORDER BY nom;      '''
    mycursor.execute(sql)
    liste_employes = mycursor.fetchall()

    sql = '''   SELECT id_client AS id, nom, prenom
                FROM CLIENT
                ORDER BY nom;      '''
    mycursor.execute(sql)
    liste_clients = mycursor.fetchall()
    return render_template('vente/add_vente.html', voitures=liste_voitures,
                           employes=liste_employes, clients=liste_clients)


@app.route('/vente/add', methods=['POST'])
def valid_add_vente():
    print('''ajout de la vente dans la base de données''')
    date_vente = request.form.get('date_vente', 'None date_vente')
    prix_final = request.form.get('prix_final', 'None prix_final')
    remise_parrainage = request.form.get('remise_parrainage', 'None remise_parrainage')
    mode_paiement = request.form.get('mode_paiement', 'None mode_paiement')
    voiture_id = request.form.get('voiture_id', 'None voiture_id')
    employe_id = request.form.get('employe_id', 'None employe_id')
    client_id = request.form.get('client_id', 'None client_id')
    message = 'Ajout d\'une vente du ' + str(date_vente) + ' - voiture :' + str(voiture_id) \
              + ' - employe_id :' + str(employe_id) + ' - client_id :' + str(client_id)
    print(message)

    mycursor = get_db().cursor()
    sql = '''   SELECT id_vente FROM VENTE WHERE voiture_id = %s ;      '''
    mycursor.execute(sql, (voiture_id,))
    vente_existante = mycursor.fetchone()
    # IF justifié : une voiture ne peut être vendue qu'une seule fois (contrainte UNIQUE)
    if vente_existante:
        flash('Cette voiture a déjà été vendue, choisissez-en une autre', 'alert-warning')
        return redirect('/vente/add')

    sql = '''   INSERT INTO VENTE (id_vente, date_vente, prix_final, remise_parrainage, mode_paiement,
                               voiture_id, employe_id, client_id)
                VALUES (NULL, %s, %s, %s, %s, %s, %s, %s);      '''
    tuple_param = (date_vente, prix_final, remise_parrainage, mode_paiement,
                   voiture_id, employe_id, client_id)
    mycursor.execute(sql, tuple_param)
    get_db().commit()
    flash(message, 'alert-success')
    return redirect('/vente/show')


@app.route('/vente/delete')
def delete_vente():
    print('''suppression d'une vente''')
    id = request.args.get('id')
    message = 'Suppression de la vente d\'identifiant :' + str(id)
    print(message)
    mycursor = get_db().cursor()
    # aucune table ne référence VENTE : la suppression est toujours possible
    sql = '''   DELETE FROM VENTE WHERE id_vente = %s ;      '''
    mycursor.execute(sql, (id,))
    get_db().commit()
    flash(message, 'alert-warning')
    return redirect('/vente/show')


@app.route('/vente/edit', methods=['GET'])
def edit_vente():
    print('''affichage du formulaire pour modifier une vente''')
    id = request.args.get('id')
    print(id)
    mycursor = get_db().cursor()
    sql = '''   SELECT id_vente AS id
     , date_vente
     , prix_final
     , remise_parrainage
     , mode_paiement
     , voiture_id
     , employe_id
     , client_id
    FROM VENTE
    WHERE id_vente = %s ;      '''
    mycursor.execute(sql, (id,))
    vente = mycursor.fetchone()

    sql = '''   SELECT VOITURE.id_voiture
     , MODELE.nom_modele
     , COULEUR.libelle_couleur
     , ETAT.libelle_etat
     , VOITURE.kilometrage
    FROM VOITURE
    INNER JOIN MODELE ON MODELE.id_modele = VOITURE.modele_id
    INNER JOIN COULEUR ON COULEUR.id_couleur = VOITURE.couleur_id
    INNER JOIN ETAT ON ETAT.id_etat = VOITURE.etat_id
    ORDER BY MODELE.nom_modele;      '''
    mycursor.execute(sql)
    liste_voitures = mycursor.fetchall()

    sql = '''   SELECT id_employe AS id, nom, prenom
                FROM EMPLOYE
                ORDER BY nom;      '''
    mycursor.execute(sql)
    liste_employes = mycursor.fetchall()

    sql = '''   SELECT id_client AS id, nom, prenom
                FROM CLIENT
                ORDER BY nom;      '''
    mycursor.execute(sql)
    liste_clients = mycursor.fetchall()
    return render_template('vente/edit_vente.html', vente=vente, voitures=liste_voitures,
                           employes=liste_employes, clients=liste_clients)


@app.route('/vente/edit', methods=['POST'])
def valid_edit_vente():
    print('''modification de la vente dans la base de données''')
    id = request.form.get('id', 'None id')
    date_vente = request.form.get('date_vente', 'None date_vente')
    prix_final = request.form.get('prix_final', 'None prix_final')
    remise_parrainage = request.form.get('remise_parrainage', 'None remise_parrainage')
    mode_paiement = request.form.get('mode_paiement', 'None mode_paiement')
    voiture_id = request.form.get('voiture_id', 'None voiture_id')
    employe_id = request.form.get('employe_id', 'None employe_id')
    client_id = request.form.get('client_id', 'None client_id')
    message = 'Modification de la vente d\'identifiant :' + str(id) + ' - date :' + str(date_vente) \
              + ' - voiture :' + str(voiture_id) + ' - employe_id :' + str(employe_id) \
              + ' - client_id :' + str(client_id)
    print(message)

    mycursor = get_db().cursor()
    sql = '''   SELECT id_vente FROM VENTE WHERE voiture_id = %s AND id_vente <> %s ;      '''
    mycursor.execute(sql, (voiture_id, id))
    autre_vente = mycursor.fetchone()
    # IF justifié : une voiture ne peut pas être associée à deux ventes
    if autre_vente:
        flash('Cette voiture est déjà associée à une autre vente', 'alert-warning')
        return redirect('/vente/edit?id=' + str(id))

    sql = '''   UPDATE VENTE SET date_vente = %s, prix_final = %s, remise_parrainage = %s,
                             mode_paiement = %s, voiture_id = %s, employe_id = %s, client_id = %s
                WHERE id_vente = %s ;      '''
    tuple_param = (date_vente, prix_final, remise_parrainage, mode_paiement,
                   voiture_id, employe_id, client_id, id)
    mycursor.execute(sql, tuple_param)
    get_db().commit()
    flash(message, 'alert-warning')
    return redirect('/vente/show')


@app.route('/vente/etat')
def etat_ventes():
    print('''état : statistiques des ventes entre deux dates''')
    date_debut = request.args.get('date_debut', '2000-01-01')
    date_fin = request.args.get('date_fin', '2100-12-31')
    mycursor = get_db().cursor()

    sql = '''   SELECT COUNT(id_vente) AS nb_ventes
                FROM VENTE
                WHERE date_vente >= %s AND date_vente <= %s ;      '''
    mycursor.execute(sql, (date_debut, date_fin))
    total = mycursor.fetchone()

    sql = '''   SELECT EMPLOYE.nom
     , EMPLOYE.prenom
     , POSTE.libelle_poste
     , COUNT(VENTE.id_vente) AS nb_ventes
    FROM VENTE
    INNER JOIN EMPLOYE ON EMPLOYE.id_employe = VENTE.employe_id
    INNER JOIN POSTE ON POSTE.id_poste = EMPLOYE.poste_id
    WHERE VENTE.date_vente >= %s AND VENTE.date_vente <= %s
    GROUP BY EMPLOYE.id_employe, EMPLOYE.nom, EMPLOYE.prenom, POSTE.libelle_poste
    ORDER BY nb_ventes DESC;      '''
    mycursor.execute(sql, (date_debut, date_fin))
    stats_employes = mycursor.fetchall()

    sql = '''   SELECT MODELE.nom_modele
     , MODELE.carrosserie
     , MODELE.energie
     , COUNT(VENTE.id_vente) AS nb_ventes
    FROM VENTE
    INNER JOIN VOITURE ON VOITURE.id_voiture = VENTE.voiture_id
    INNER JOIN MODELE ON MODELE.id_modele = VOITURE.modele_id
    WHERE VENTE.date_vente >= %s AND VENTE.date_vente <= %s
    GROUP BY MODELE.id_modele, MODELE.nom_modele, MODELE.carrosserie, MODELE.energie
    ORDER BY nb_ventes DESC;      '''
    mycursor.execute(sql, (date_debut, date_fin))
    stats_modeles = mycursor.fetchall()

    sql = '''   SELECT VENTE.mode_paiement
     , COUNT(VENTE.id_vente) AS nb_ventes
    FROM VENTE
    WHERE VENTE.date_vente >= %s AND VENTE.date_vente <= %s
    GROUP BY VENTE.mode_paiement
    ORDER BY nb_ventes DESC;      '''
    mycursor.execute(sql, (date_debut, date_fin))
    stats_paiements = mycursor.fetchall()

    return render_template('vente/etat_vente.html', total=total,
                           stats_employes=stats_employes, stats_modeles=stats_modeles,
                           stats_paiements=stats_paiements,
                           date_debut=date_debut, date_fin=date_fin)


if __name__ == '__main__':
    app.run(debug=True, port=5000)