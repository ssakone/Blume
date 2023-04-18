## Qml Code guide

* directory structure

- qml/
	- **components/**:
		pour les differents components de l'application, ils s'agit de tout ce qui automatise un fonctionnement
	- **components_generic/**:
		pour les composants reutilisable avec different property comme les controls (button, textfield, ....)
	- **components_js/**:
		pour les objects javascript importable dans le but d'effectuer des actions precises
	- **pages/**:
		cet dossier contient tous les elements de view

* Fonctionement de la navigation

- Chaque nouvelle page creer doit etre declarer dans 
```bash
qml/NavigationPage.qml
``` 
comme suivant les autres dans la meme page
- pour ouvrir une page on utilise le code
```qml
page_view.push(navigator.<page_name>)
```
- pour creer une nouvelle page utiliser la syntax suivante

```qml
....
import "components_generic" // folder
import "components" // folder
....

BPage {
	id: control
	header: AppBar {
		title: "Title"
		// l'app bar contient deja un button retour sur la property leading qui personnalisable comme etant un button, lire le contenu de AppBar pour plus de comprehension
	}
	....
}

page_view.push(navigator.<page_name>)
```
