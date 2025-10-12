# PRD — ReadSprint: Primeira Execução, Consentimento e Identidade

> **Objetivo**: exemplo adaptado do PRD Base para o tema **ReadSprint**, um app que ajuda alunos a dividirem livros e artigos em **metas semanais de leitura**, promovendo constância e clareza no progresso.

---

## 0) Metadados do Projeto
- **Nome do Produto/Projeto**: ReadSprint — Leituras em Sprints
- **Responsável**: Felipe Sousa da Costa
- **Curso/Disciplina**: Desenvolvimento de Aplicações (Flutter)
- **Versão do PRD**: v1.0
- **Data**: 2025-10-03

---

## 1) Visão Geral
**Resumo**: O ReadSprint ajuda alunos a dividirem livros e artigos em metas semanais, promovendo constância e clareza no avanço da leitura. Na primeira execução, o app demonstra automaticamente uma divisão de sprint antes de solicitar dados pessoais, valorizando o impacto imediato do método.

**Problemas que ataca**: dificuldade em manter ritmo de leitura, falta de organização e percepção de progresso.

**Resultado desejado**: experiência inicial que motive o usuário a continuar lendo, mostrando rapidamente o benefício de planejar leituras em sprints.

---

## 2) Personas & Cenários de Primeiro Acesso
- **Persona principal**: aluno que precisa ler com prazo, buscando disciplina e visualização de metas.
- **Cenário (happy path)**: abrir app → splash (decisão de rota) → onboarding (2–3 telas explicando o conceito de sprints) → visualização de políticas → consentimento → home com sugestão do primeiro sprint.
- **Cenários alternativos**:
  - **Pular** para consentimento a partir das telas iniciais do onboarding.
  - **Revogar consentimento** na Home (configurações) com confirmação + **Desfazer**.

---

## 3) Identidade do Tema (Design)
### 3.1 Paleta e Direção Visual
- **Primária**: Amber `#F59E0B`
- **Secundária**: Navy `#0B1220`
- **Acento**: Gray `#475569`
- **Superfície**: `#FFFFFF` (claro) / `#0B1220` (escuro)
- **Texto**: `#0F172A` (claro) / `#E2E8F0` (escuro)
- Direção: **flat minimalista**, alto contraste **WCAG AA**, **useMaterial3: true**; esquema de cores derivado (sem cores mágicas).

### 3.2 Tipografia
- Títulos: `headlineSmall` (peso 600)
- Corpo: `bodyLarge`/`bodyMedium`
- Escalabilidade: suportar **text scaling ≥ 1.3** sem quebras.

### 3.3 Iconografia & Ilustrações
- Ícone: **livro com barra de progresso** (flat, sem texto, 1024×1024).
- Hero/empty: ilustração flat minimalista de **pilha de livros com marcador de sprint semanal**.

**Entrega de identidade**: grade de cores (hex), 2–3 referências (moodboard) e 1 prompt aprovado.

---

## 4) Jornada de Primeira Execução (Fluxo Base)
### 4.1 Splash
- Exibe logomarca e decide rota conforme versão de aceite.

### 4.2 Onboarding (3 telas)
1. **Bem-vindo** — destaca o valor de ler em sprints curtos.
2. **Como funciona** — mostra exemplo de metas e progresso semanal.
3. **Consentimento** — porta de entrada para políticas (sem **Pular**).  
   - **DotsIndicator** sincronizado; ocultar na última página.

### 4.3 Políticas e Consentimento
- Leitura dos **Termos e Política de Privacidade** (Markdown) com barra de progresso.  
- Botão “**Marcar como lido**” habilita após 100% de rolagem.  
- Checkbox de aceite habilita após ambos os docs lidos; botão **Concordo** libera navegação para a Home e persiste versão.

### 4.4 Home & Revogação
- Home com card “**Crie seu primeiro sprint de leitura (7 dias)**”.
- **Revogar aceite** em Configurações → **AlertDialog** + **SnackBar** com **Desfazer**.

---

## 5) Requisitos Funcionais (RF)
- **RF‑1** Dots sincronizados e ocultos na última tela do onboarding.
- **RF‑2** Navegação contextual entre telas (Pular → consentimento).
- **RF‑3** Visualizador de políticas em Markdown com barra de progresso.
- **RF‑4** Consentimento **opt‑in** obrigatório após leitura.
- **RF‑5** Splash decide rota por flags/versão aceita.
- **RF‑6** Revogação com confirmação + **Desfazer** (SnackBar).
- **RF‑7** Versão de políticas persistida e datada.
- **RF‑8** Ícone gerado via `flutter_launcher_icons` (1024×1024).

---

## 6) Requisitos Não Funcionais (RNF)
- **A11Y**: alvos ≥ 48dp, foco visível, contraste AA.  
- **Privacidade (LGPD)**: registro de aceite e revogação simples.  
- **Arquitetura**: **UI → Service → Storage** (sem uso direto de `SharedPreferences`).  
- **Performance**: animações suaves (~300ms).  
- **Testabilidade**: serviço de preferências mockável.

---

## 7) Dados & Persistência (chaves)
- `privacy_read_v1`: bool  
- `terms_read_v1`: bool  
- `policies_version_accepted`: string  
- `accepted_at`: string (ISO8601)  
- `onboarding_completed`: bool  
- `first_sprint_created`: bool  

**Serviço:** `PrefsService` com `get/set/clear`, `isFullyAccepted()`, `migratePolicyVersion()`.

---

## 8) Roteamento
- `/` → **Splash**  
- `/onboarding` → **PageView (3 telas)**  
- `/policy-viewer` → **Viewer de políticas**  
- `/home` → **Tela inicial (primeiro sprint)**

---

## 9) Critérios de Aceite
1. Fluxo de onboarding e consentimento completo e persistente.  
2. Consentimento só habilitado após leitura integral.  
3. Splash reconhece aceite e direciona à Home.  
4. Revogação funcional com opção de **Desfazer**.  
5. UI desacoplada do storage e ícone gerado corretamente.

---

## 10) Protocolo de QA (Testes Manuais)
- Onboarding completo → viewer → aceite → Home.  
- Leitura parcial não habilita aceite.  
- Reabertura com aceite existente leva à Home.  
- Revogação com **Desfazer** restaura aceite.  
- Testar **A11Y** e text scaling ≥ 1.3.

---

## 11) Riscos & Decisões
- **Risco**: falta de clareza na visualização dos sprints → **Mitigação**: mostrar exemplo pré-criado.  
- **Risco**: aceite não persistido → **Mitigação**: checagem no Splash.  
- **Decisão**: demonstrar valor (divisão automática) antes de pedir dados pessoais.

---

## 12) Entregáveis
1. PRD preenchido + identidade visual (paleta, ícone, moodboard).  
2. Fluxo funcional de primeira execução e consentimento.  
3. Evidências de onboarding, políticas e revogação.  
4. Ícone aplicado em plataforma Android/iOS.

---

## 13) Backlog de Evolução (Opcional)
- Tela de histórico de sprints (evolução semanal).  
- Notificações para início de novo sprint.  
- Análise de progresso semanal por gráfico.  
- Exportação de sprints concluídos em PDF.

---

## 14) Referências Internas
- Baseado no PRD de exemplo **EduCare — UTFPR**.  
- Adaptado para domínio de leitura e metas semanais.  
- **Material 3**, **WCAG AA**, **LGPD** e arquitetura modular.

---

### Checklist de Conformidade (colar no PR)
- [ ] Dots sincronizados e ocultos na última tela  
- [ ] Pular → consentimento; Voltar/Avançar contextuais  
- [ ] Viewer com progresso + “Marcar como lido”  
- [ ] Aceite habilita somente após leitura dos 2 docs  
- [ ] Splash decide rota por versão aceita  
- [ ] Revogação com confirmação + **Desfazer**  
- [ ] Sem `SharedPreferences` direto na UI  
- [ ] Ícones gerados  
- [ ] A11Y (48dp, contraste, Semantics, text scaling)

> **Nota ao aluno**: este PRD foi adaptado para o tema *ReadSprint — Leituras em Sprints*, mantendo o fluxo base de consentimento e identidade visual do modelo EduCare.
