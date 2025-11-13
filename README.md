# ReadSprint

Um aplicativo de leitura que divide livros em metas menores, desenvolvido em Flutter por Felipe Sousa da Costa.

## Características

- **Leitura em Sprints:** Divida livros em partes menores para facilitar o acompanhamento.
- **Interface Intuitiva:** Design limpo e focado na experiência de leitura.
- **Privacidade:** Seus dados de leitura são armazenados localmente.
- **Multiplataforma:** Experiência otimizada para dispositivos móveis e web.

## Como Executar

1.  **Pré-requisitos:** Certifique-se de ter o Flutter instalado em sua máquina.
2.  **Clone o Repositório:**
    ```bash
    git clone <URL_DO_REPOSITORIO>
    ```
3.  **Navegue até o Diretório:**
    ```bash
    cd readsprint
    ```
4.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```
5.  **Execute o Aplicativo:**
    ```bash
    flutter run
    ```

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── features/
│   ├── app/                  # Widgets e lógica globais
│   ├── home/                 # Tela principal
│   ├── models/               # Modelos de dados
│   ├── onboarding/           # Telas de introdução
│   ├── policies/             # Telas de políticas e termos
│   ├── providers/            # Provedores de dados (Supabase)
│   ├── splashscreen/         # Tela de carregamento inicial
│   └── sprints/               # Lógica e telas de sprints de leitura
├── services/
│   ├── shared_preferences_services.dart # Serviço de armazenamento local
│   └── supabase_service.dart      # Serviço de integração com Supabase
├── theme/
│   └── app_theme.dart        # Configurações de tema
└── utils/
    └── ...                   # Utilitários e helpers
```

## Funcionalidades

### Tela Principal

-   Visualização dos livros e sprints de leitura atuais.
-   Acompanhamento do progresso de leitura.

### Políticas e Termos

-   Leitura e aceite da Política de Privacidade e dos Termos de Uso antes de acessar o aplicativo.

### Armazenamento

-   Dados armazenados localmente com `SharedPreferences`.
-   Sincronização opcional com `Supabase`.

## Tecnologias Utilizadas

-   **Flutter:** Framework de desenvolvimento
-   **Dart:** Linguagem de programação
-   **SharedPreferences:** Armazenamento local
-   **Supabase:** Backend como serviço (opcional)
-   **Riverpod:** Gerenciamento de estado
-   **Material Design 3:** Design system
