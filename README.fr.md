# lanpass

[简体中文](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Español](README.es.md) | **Français**

> Quand le Groupe résidentiel a disparu, que la découverte réseau échoue et que l'accès invité est bloqué par défaut — lanpass permet toujours à Windows 7 / 10 / 11 de se voir.

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">

## Le problème

Une salle informatique : des dizaines de PC, un seul commutateur, un seul sous-réseau. Mais le dossier « Réseau » n'affiche rien.

Deux niveaux de causes.

**Niveau superficiel** : le Groupe résidentiel est apparu avec Windows 7 et a été **supprimé dans Windows 10 1803**. Win7 et Win10/11 ne partagent aucun mécanisme commun.

**Cause racine** : depuis Windows 10 1709, `AllowInsecureGuestAuth` vaut 0 par défaut. Win10/11 refuse tout accès SMB anonyme. Même en contournant le Groupe résidentiel et en se connectant par IP, on obtient *« Les stratégies de sécurité de votre organisation bloquent l'accès invité non authentifié »*.

**Corriger uniquement le Groupe résidentiel ne sert à rien. Le blocage se situe au niveau de l'authentification SMB.**

## Fonctionnalités

| | |
|---|---|
| **Zéro dépendance** | Uniquement `mshta` / `cmd` / `net` / `ping` / `arp` intégrés. Ni .NET, ni VC++, ni Java, Python ou Node |
| **Sans services de découverte** | Fonctionne même si Groupe résidentiel, Découverte réseau, Computer Browser, SSDP et DNS sont arrêtés |
| **Entre versions** | Win7 / Win10 / Win11 dans les deux sens |
| **Deux rôles** | Client professeur pour toute la classe, client élève pour un dépôt en un clic |
| **Correction automatique** | Écrit 4 valeurs de registre qui lèvent le blocage de l'accès invité |
| **Découverte active** | Table ARP + ping de tout le sous-réseau, sans service système |
| **Mémoire des postes** | Liste en cache, démarrage instantané |
| **Faible empreinte** | 34 Mo de RAM, 0 % de CPU au repos, sans interrogation périodique |

## Démarrage rapide

1. Copiez le dossier sur chaque PC
2. PC professeur : lancez `教师端.exe` ; PC élève : `学生端.exe`
3. Cliquez sur « 配置共享 » (Configurer le partage) et acceptez l'UAC
4. Professeur : cliquez sur « 刷新学生机 » (Actualiser les élèves). Liste vide ? Cliquez sur « 全段扫描 » (Analyse complète)
5. Cliquez sur « 打开 » (Ouvrir) sur la ligne d'un élève

Pas de lecteur D: ? Remplacez `D:\lan-share` par un chemin existant dans `setup-share.bat` et `app.hta`.

## Interface

| Professeur | Élève |
|---|---|
| ![](docs/screenshots/teacher.png) | ![](docs/screenshots/student.png) |

## Pour aller plus loin

- [FAQ, 27 entrées (chinois)](docs/QRA.txt)
- [Notes de sécurité](docs/SECURITY.md)
- [Instructions de compilation](BUILD.md)

## Notes techniques

La découverte lit la table ARP locale (couche 2, indépendante des services Windows). Si ARP est vide, un ping de tout le sous-réseau (254 adresses, 32 en parallèle, environ 4 secondes) la remplit. Le ping ne sert qu'à remplir la table ARP, pas à attendre des réponses ICMP.

L'interface est un HTA rendu par le `mshta.exe` intégré (mode de compatibilité IE8). Tout le code est en HTML + JScript en clair et peut être audité.

## Licence

MIT
