<div align="center">
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/nurebo_logo_blue.png" alt="Nurebo Admin Banner" width="400"/>
  <p><strong>Pannello di amministrazione per gestire business, prenotazioni, servizi ed eventi su Nurebo.</strong></p>

<p>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </p>
</div>


## 📱 Cos'è Nurebo Admin?

**Nurebo Admin** è l'applicazione companion di Nurebo dedicata ai business e ai professionisti.

Permette di gestire in modo completo:

- Prenotazioni e calendari
- Prestazioni (servizi) e disponibilità
- Eventi e biglietti
- Post e contenuti social
- Campagne e notifiche
- Statistiche e report
- Profilo business e impostazioni

È pensata per chi offre servizi su Nurebo e vuole avere il controllo completo delle attività, delle prenotazioni e della comunicazione con i clienti.

## ✨ Funzionalità principali

<div align="center">
  <img src="https://nurebo-public.s3.eu-central-1.amazonaws.com/images/nurebo_icon_blue.png" alt="Nurebo Admin Features" width="200"/>
</div>

| Funzionalità | Descrizione |
|-------------|-------------|
| **Prenotazioni** | Visualizza, crea, modifica e gestisci prenotazioni con stati |
| **Calendario** | Vista calendario delle disponibilità e degli appuntamenti |
| **Prestazioni** | Gestisci servizi, prezzi, durata e slot |
| **Eventi** | Crea e gestisci eventi e relative prenotazioni |
| **Post & Vetrina** | Pubblica contenuti e gestisci la vetrina del business |
| **Campagne** | Invia notifiche e campagne mirate |
| **Statistiche** | Grafici e report sull'andamento (fl_chart) |
| **Impostazioni** | Orari, profilo business, notifiche e configurazioni |



## 📸 Screenshot

<div align="center">
  <img src="docs/home-screen.png" alt="Admin Home Screen" width="300"/>
</div>


## 🛠 Tech Stack

- **Framework**: Flutter 3.x + Dart
- **State Management**: Provider + GetX
- **Real-time**: Socket.IO Client
- **Mappe**: flutter_map + geolocator
- **Notifiche**: Firebase Messaging + flutter_local_notifications
- **Grafici**: fl_chart
- **Storage locale**: SQLite (sqflite) + SharedPreferences
- **UI**: Google Fonts, Lottie, Material Design Icons, custom widgets
- **Altro**: Image Picker, QR scanner, Permissions, Crashlytics, etc.


## 🚀 Come iniziare

### Prerequisiti

- Flutter SDK >= 3.0.2
- Dart SDK
- Android Studio / Xcode
- Account Firebase configurato

### Installazione

```bash
# Clona il repository
git clone https://github.com/jacko95/nurebo_admin.git
cd nurebo_admin

# Installa le dipendenze
flutter pub get

# Genera launcher icons e splash (se necessario)
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Avvia l'app
flutter run
```

### Configurazione

1. Configura Firebase (`lib/services/firebase_options.dart`)
2. Imposta l'endpoint del server (nurebo-server)
3. Configura certificati e chiavi necessarie


## 📁 Struttura del progetto

```
lib/
├── main.dart                 # Entry point
├── models/                   # Modelli (Booking, Prestazione, Event, etc.)
├── provider/                 # State management
├── screens/                  # Schermate admin
├── services/                 # Servizi (Firebase, API, Socket)
├── utils/                    # Utility
└── widgets/                  # Componenti riutilizzabili
```


## 🔗 Progetti correlati

- **[nurebo](https://github.com/jacko95/nurebo)** — App principale per gli utenti
- **[nurebo-server](https://github.com/jacko95/nurebo-server)** — Backend


## 📄 Licenza

Questo progetto è rilasciato sotto la **MIT License**.

Copyright (c) 2026 Domenico Politi

Vedi il file [LICENSE](LICENSE) per i dettagli completi (se presente).

---

<div align="center">
  <p>Realizzato con ❤️ in Flutter</p>
  <p><strong>Nurebo Admin</strong> — Gestisci il tuo business.</p>
</div>
