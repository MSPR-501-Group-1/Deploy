# Pour lancer le projet complet :

Dans VSCODE :

- git clone --recurse-submodules https://github.com/MSPR-501-Group-1/main.git

- docker compose up --build

# Pour faire une feature complète :

Exemple : Une feature qui touche backend + frontend

1. Faire une branche dans chaque repo concerné

```
cd backend
git checkout -b feature/login
```
```
cd ../frontend
git checkout -b feature/login
```

2. Dev normalement dans chaque repo

commit dans backend

commit dans frontend

3. Push chaque repo
```
git push origin feature/login
```

4. Revenir dans Main
```
cd ..
git checkout -b feature/login
```

5. Mettre à jour les submodules
```
git add backend frontend
git commit -m "update submodules for feature/login"
```

-> Main pointe vers les bons commits des submodules

6. Push sur Main
```
git push origin feature/login
```