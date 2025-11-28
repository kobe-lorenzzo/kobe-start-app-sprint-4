O **Fast Route** é uma aplicação móvel desenvolvida em Flutter para gestão pessoal de compromissos e rotas. O objetivo é permitir que o utilizador agende tarefas, visualize a localização dos seus compromissos num mapa interativo e receba notificações locais para não se esquecer de nada.

A aplicação foca-se na acessibilidade e numa experiência de utilização fluida, integrando serviços de geolocalização e mapas em tempo real.

## Funcionalidades

* **Autenticação Segura:** Login e Registo de conta utilizando Firebase Authentication.
* **Gestão de Agenda:**
  * Criação de compromissos com Título, Data, Hora e Endereço.
  * Busca inteligente de endereços (Autocompletar) via OpenStreetMap (Nominatim).
  * Listagem de compromissos ordenados.
  * Exclusão de compromissos com gesto de deslizar ("swipe-to-dismiss").
* **Mapa Interativo:**
  * Visualização de todos os compromissos marcados no mapa.
  * Localização atual do utilizador em tempo real.
  * Marcadores personalizados.
* **Notificações Locais:** Lembretes automáticos agendados para 1 hora antes de cada compromisso.
* **Acessibilidade:** Suporte melhorado para leitores de ecrã (TalkBack/VoiceOver).

## Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Gestão de Estado:** [Provider](https://pub.dev/packages/provider)
* **Backend & Base de Dados:**
  * [Firebase Auth](https://firebase.google.com/docs/auth) (Gestão de Utilizadores)
  * [Cloud Firestore](https://firebase.google.com/docs/firestore) (Armazenamento de Dados)
* **Mapas & Geolocalização:**
  * [flutter_map](https://pub.dev/packages/flutter_map) (Mapas OpenSource)
  * [geolocator](https://pub.dev/packages/geolocator) (GPS do dispositivo)
* **Notificações:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

## Estrutura do Projeto

O projeto segue uma arquitetura modular baseada em **Features**:

```bash
lib/
├── core/                  # Configurações globais
├── features/
│   ├── 1_auth/            # Ecrãs e lógica de Autenticação
│   ├── 2_agenda/          # Ecrãs e lógica da Agenda
│   ├── 3_map/             # Ecrã e lógica do Mapa
│   └── home_wrapper.dart  # Navegação principal (BottomNavigationBar)
├── models/                # Modelos de Dados (Appointment, PlaceSuggestion)
├── services/              # Serviços externos (API, Firebase, GPS, Notificações)
└── main.dart              # Ponto de entrada e injeção de dependências

## Como Executar

### Pré-requisitos
* Flutter SDK instalado.
* Configuração do ambiente Android/iOS.
* Projeto Firebase configurado (ficheiro `google-services.json` para Android e `GoogleService-Info.plist` para iOS).

### Passos

1. **Clonar o repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/fast-route.git](https://github.com/seu-usuario/fast-route.git)
    cd fast-route

2. **Instalar dependências:**
    ```bash
    flutter pub get

3. **Executar a aplicação:**
    ```bash
    flutter run

## Configurações Específicas (Android 13+)

Para garantir o funcionamento das notificações em dispositivos Android 13 ou superior (API 33+ - ex: Pixel 7), foram adicionadas as seguintes permissões no `AndroidManifest.xml`:
* `POST_NOTIFICATIONS`
* `SCHEDULE_EXACT_ALARM`
* `USE_EXACT_ALARM`

> **Nota Importante:** Ao iniciar a aplicação pela primeira vez, será solicitado ao utilizador que autorize o envio de notificações.

---

## Testes e Acessibilidade

*(https://drive.google.com/file/d/1D3421FKjEfKT6APNbxIh3P01nh8dWwmv/view?usp=sharing)*


### Testes de Fluxo com Maestro

*(https://drive.google.com/file/d/13p9Ae-4CVtLggPeQ9aFuFR09XV9Iep_m/view?usp=sharing)*

---

**Desenvolvido por Lorenzzo Patricio**