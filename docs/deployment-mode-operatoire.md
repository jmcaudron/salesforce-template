# Mode operatoire de deploiement

Ce projet contient 2 types d'applications Salesforce avec 2 workflows differents:

- Standard metadata: `force-app`
- Unlocked package source: `framework-pkg/main/logging-utilities-core` et `framework-pkg/main/batch-template-core`

## 1) Standard metadata (force-app)

Utiliser ce workflow pour les metadonnees de l'application principale.

### Preconditions

- Org cible disponible (sandbox/scratch/dev).
- Authentification active dans le CLI `sf`.
- Manifest cible: `manifest/force-app-package.xml`.

### Etapes

1. Verifier le perimetre des changements dans `force-app`.
2. Valider rapidement le format/lint du repo:
   - `npm run lint`
3. Deployer via manifest dedie:
   - `sf project deploy start --manifest manifest/force-app-package.xml --target-org <alias>`
4. Verifier les composants deployes dans l'org.
5. Optionnel: verifier la coherence source/org:
   - `sf project retrieve start --manifest manifest/force-app-package.xml --target-org <alias>`

### Rollback

- Re-deployer la version precedente des metadonnees `force-app` depuis la branche stable.

## 2) Unlocked packages (framework-pkg)

Utiliser ce workflow pour les composants framework. La voie de release est la creation de version de package, puis installation.

### Preconditions

- Dev Hub disponible et configure.
- Package aliases presents dans `sfdx-project.json`.
- Ne pas melanger des changements `force-app` et `framework-pkg` dans un meme package.xml de routine.

### Etapes communes

1. Verifier le perimetre par package source:
   - `framework-pkg/main/logging-utilities-core`
   - `framework-pkg/main/batch-template-core`
2. Valider lint/tests locaux:
   - `npm run lint`
   - `npm run test`
3. Creer la version du package concerne:
   - Logging:
     - `sf package version create --package logging-utilities-core --target-dev-hub <devhub> --wait 60 --code-coverage`
   - Batch template:
     - `sf package version create --package batch-template-core --target-dev-hub <devhub> --wait 60 --code-coverage`
4. Recuperer l'ID de version package (`04t...`).
5. Installer dans org de validation:
   - `sf package install --package <04t...> --target-org <alias> --wait 30 --publish-wait 10`
6. Executer les verifications post-installation (tests de non-regression fonctionnelle).

### Points d'attention

- `batch-template-core` depend de `logging-utilities-core`: respecter l'ordre d'installation si necessaire.
- Mettre a jour `sfdx-project.json` (aliases/version refs) quand une nouvelle version doit etre referencee.

### Rollback

- Reinstaller la version package precedente validee (`04t...` precedent).

## 3) Regle de decision rapide

- Changement dans `force-app` seulement: deploy metadata standard.
- Changement dans `framework-pkg` seulement: create/install unlocked package.
- Changement dans les deux: traiter comme deux flux separes, chacun avec son manifest ou son cycle package.

## 4) Checklist de release

### Checklist force-app (metadata standard)

- [ ] Le scope de changements est limite a `force-app`.
- [ ] Le manifest cible est `manifest/force-app-package.xml`.
- [ ] Le deploy via manifest passe sans erreur.
- [ ] Les composants critiques sont verifies dans l'org cible.
- [ ] Le plan de rollback est documente.

### Checklist framework-pkg (unlocked package)

- [ ] Le scope est limite au package source concerne.
- [ ] La creation de version package est reussie (`04t...` capture).
- [ ] L'installation de la version package en org de validation est reussie.
- [ ] Les dependances entre packages sont respectees.
- [ ] Les references de version/aliases sont a jour dans `sfdx-project.json` si necessaire.
- [ ] Le plan de rollback vers la version package precedente est documente.
