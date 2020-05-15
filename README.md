# Covid19

Voici les bases de données originelles que je vais utiliser.

-	Essential_tunisia_final.dta : j’ai pris cette base de données et j’ai enlevé les duplicates. 
Nous avons désormais essential_tunisia_final_no_d.dta

-	Dans un second temps, les secteurs essentiels italiens sont classés en 2 digits et 4 digits. 
J’ai donc construit deux bases de données avec les 2 digits seulement (italy_essential1.dta) 
et en 4 digit (Italy_essential2.dta) afin de pouvoir merger et obtenir la variable essentielle. 
J’ai ensuite fusionné avec la table de correspondance nat09 et ISIC4. 

-	Merging.do permet de merger l’ensemble des données. Dans un premier temps, nous avons Book1.dta 
(c’est la deuxième feuille du dossier excel que tu m’as envoyé) qui va être mergé avec la première feuille, 
pour qu’on puisse avoir les revenus moyens. Donc on a mergé Book1.dta et occupation.dta

Par la suite,  j’ai mergé : 

o	essential_tunisia_final_no_d.dta
o	nat09_isic4.dta
o	nat09_ISIC4_essential.dta 
o	isic_demand_shock.dta

Dans Merging.do j’ai également recensé toutes les manipulations que j’ai fait, ainsi que dans merge.do.
