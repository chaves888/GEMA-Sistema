
# GEMA - Sistema de Gerenciamento Escolar de Merenda e Alimentos

![GEMA Logo](src/lib/assets/logo-gema.png)

> **TCC - Trabalho de Conclusão de Curso**
> **Curso:** Sistemas para Internet - UniALFA
> **Aluno:** Leonardo Chaves Batista da Silva
> **Orientador:** Diogo Ranghetti

## 📌 Sobre o Projeto

O **GEMA** é uma plataforma web desenvolvida para centralizar e otimizar a gestão da merenda escolar. O sistema conecta a Prefeitura (Estoque Central), as Escolas, Nutricionistas e Cozinheiras em um único ambiente digital.

O objetivo principal é solucionar problemas como o desperdício de alimentos, a falta de rastreabilidade de estoque e a comunicação ineficiente (papel/telefone) entre as escolas e a gestão municipal.

## 🚀 Tecnologias Utilizadas

O projeto foi desenvolvido utilizando uma arquitetura moderna e escalável:

### Front-end
-   ![Svelte](https://img.shields.io/badge/SvelteKit-FF3E00?style=for-the-badge&logo=svelte&logoColor=white) **SvelteKit**: Framework para interfaces reativas e rápidas.
-   ![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white) **TailwindCSS**: Estilização utilitária e responsiva.
-   **Flatpickr**: Manipulação de datas e calendários.
-   **Chart.js / ApexCharts**: Visualização de dados no Dashboard.

### Back-end
-   ![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white) **NestJS**: Framework Node.js robusto e modular.
-   ![TypeORM](https://img.shields.io/badge/TypeORM-FE0702?style=for-the-badge&logo=typeorm&logoColor=white) **TypeORM**: ORM para interação com o banco de dados.
-   ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white) **MySQL**: Banco de dados relacional.
-   **JWT (JSON Web Token)**: Autenticação segura e controle de sessões.

---

## ⚙️ Funcionalidades Principais

O sistema possui perfis de acesso distintos com regras de negócio específicas:

### 🏛️ Prefeitura (Gestor Municipal)
-   [cite_start]**Dashboard Gerencial**: Visão macro de solicitações pendentes e alertas de estoque crítico[cite: 4040].
-   **Estoque Central**: Controle de entradas (com importação de Excel) e saídas.
-   **Gestão de Solicitações**: Análise e aprovação de pedidos feitos pelas escolas. O sistema valida automaticamente a disponibilidade no estoque antes da aprovação.
-   [cite_start]**Relatórios**: Geração de PDFs e planilhas para auditoria de envios, perdas e ajustes[cite: 4038].

### 🏫 Escola (Gestor Escolar)
-   [cite_start]**Solicitação de Produtos**: Criação de pedidos de reposição de forma digital[cite: 4039].
-   **Estoque Local**: Visualização do estoque da própria escola.
-   **Confirmação de Recebimento**: Conferência dos itens recebidos com opção de reportar divergências (ex: produto avariado ou quantidade incorreta).

### 🍎 Nutricionista
-   **Gestão de Cardápios**: Criação e planejamento dos cardápios semanais.
-   [cite_start]**Controle Nutricional**: Definição dos produtos utilizados em cada refeição (Manhã/Tarde)[cite: 4039].

### 👩‍🍳 Cozinha
-   **Visualização Diária**: Acesso rápido ao cardápio do dia e aos ingredientes disponíveis.

---

## 🔧 Como Executar o Projeto

### Pré-requisitos
-   Node.js (v18+)
-   MySQL Server em execução

### 1. Configuração do Banco de Dados
Crie um banco de dados MySQL chamado `gema_db`.

### 2. Executando o Back-end (API)

```bash
# Entre na pasta do backend
cd gema-backend

# Instale as dependências
npm install

# Configure as variáveis de ambiente (.env)
# Crie um arquivo .env na raiz baseado no exemplo abaixo:
# DB_HOST=localhost
# DB_PORT=3306
# DB_USERNAME=root
# DB_PASSWORD=sua_senha
# DB_DATABASE=gema_db
# JWT_SECRET=seu_segredo_jwt

# Execute o servidor em modo de desenvolvimento
npm run start:dev
