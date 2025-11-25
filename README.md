# GEMA - Sistema de Gerenciamento Escolar de Merenda e Alimentos

![Logo GEMA](gema-frontend/src/lib/assets/logo-gema.png)

> **TCC - Trabalho de Conclusão de Curso**
> **Curso:** Sistemas para Internet - UniALFA
> **Autor:** Leonardo Chaves Batista da Silva

## 📌 Sobre o Projeto

O **GEMA** é uma plataforma web desenvolvida para centralizar e otimizar a gestão da merenda escolar municipal. O sistema conecta a Prefeitura (Estoque Central), as Escolas, Nutricionistas e Cozinheiras em um único ambiente digital, substituindo processos manuais e descentralizados.

[cite_start]O objetivo principal é solucionar problemas como o desperdício de alimentos, a falta de rastreabilidade de estoque e a comunicação ineficiente entre as escolas e a gestão municipal [cite: 4755-4758].

## 🚀 Tecnologias Utilizadas

O projeto utiliza uma arquitetura moderna, separada em Frontend e Backend:

### Front-end
* [cite_start]![Svelte](https://img.shields.io/badge/SvelteKit-FF3E00?style=for-the-badge&logo=svelte&logoColor=white) **SvelteKit** [cite: 1]
* [cite_start]![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white) **TailwindCSS** [cite: 4761]
* [cite_start]**Lucide Svelte** (Ícones) [cite: 415]
* [cite_start]**Flatpickr** (Seleção de datas) [cite: 339]

### Back-end
* [cite_start]![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white) **NestJS** [cite: 5064]
* [cite_start]![TypeORM](https://img.shields.io/badge/TypeORM-FE0702?style=for-the-badge&logo=typeorm&logoColor=white) **TypeORM** [cite: 5082]
* [cite_start]![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white) **MySQL** [cite: 5119]
* [cite_start]**JWT & Passport** (Autenticação e Segurança) [cite: 8764]
* [cite_start]**Nodemailer** (Envio de e-mails) [cite: 5087]

---

## ⚙️ Funcionalidades Principais

[cite_start]O sistema gerencia perfis de acesso distintos (Prefeitura, Escola, Nutricionista, Cozinheira) [cite: 5501-5504]:

### 🏛️ Prefeitura (Gestor Municipal)
* [cite_start]**Dashboard Gerencial**: Visão macro de solicitações pendentes e alertas de estoque crítico[cite: 3577].
* [cite_start]**Estoque Central**: Controle total de entradas (incluindo importação via Excel [cite: 7709]) e saídas.
* [cite_start]**Análise de Solicitações**: Aprovação ou recusa de pedidos das escolas com validação automática de saldo em estoque[cite: 5688].
* [cite_start]**Relatórios**: Geração de PDFs e planilhas para auditoria de envios, perdas e ajustes[cite: 6916].

### 🏫 Escola (Gestor Escolar)
* [cite_start]**Solicitações**: Criação de pedidos de reposição de produtos[cite: 5600].
* [cite_start]**Confirmação de Recebimento**: Conferência dos itens entregues com opção de reportar divergências (ex: produto avariado)[cite: 5841].
* [cite_start]**Estoque Local**: Visualização e controle do estoque da própria escola[cite: 7382].

### 🍎 Nutricionista
* [cite_start]**Cardápios**: Planejamento de cardápios semanais e definição de refeições (Manhã/Tarde)[cite: 8615].
* [cite_start]**Controle de Feriados**: Marcação de dias sem merenda para evitar desperdício[cite: 8714].

### 👩‍🍳 Cozinheira
* [cite_start]**Visualização Diária**: Acesso rápido ao cardápio do dia e ingredientes necessários[cite: 3593].

---

## 🔧 Como Executar o Projeto

### Pré-requisitos
* Node.js (v18+)
* MySQL Server rodando

### 1. Configuração do Banco de Dados
[cite_start]Crie um banco de dados MySQL chamado `gema_db`[cite: 5124].

### 2. Executando o Back-end

```bash
# Entre na pasta do backend
cd gema-backend

# Instale as dependências
npm install

# Crie um arquivo .env na raiz com as configurações (exemplo):
# DB_HOST=localhost
# DB_PORT=3306
# DB_USERNAME=root
# DB_PASSWORD=
# DB_DATABASE=gema_db
# JWT_SECRET=SEGREDO_SUPER_SECRETO_PARA_PROJETO_GEMA

# Execute o servidor
npm run start:dev
