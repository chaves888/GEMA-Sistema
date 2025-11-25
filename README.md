# GEMA - Sistema de Gerenciamento Escolar de Merenda e Alimentos

![Logo GEMA](gema-frontend/src/lib/assets/logo-gema.png)

> **TCC - Trabalho de Conclusão de Curso** <br>
> **Curso:** Sistemas para Internet - UniALFA<br>
> **Autor:** Leonardo Chaves Batista da Silva

## 📌 Sobre o Projeto

O **GEMA** é uma plataforma web desenvolvida para centralizar e otimizar a gestão da merenda escolar municipal. O sistema conecta a Prefeitura (Estoque Central), as Escolas, Nutricionistas e Cozinheiras em um único ambiente digital, substituindo processos manuais e descentralizados.

O objetivo principal é solucionar problemas como o desperdício de alimentos, a falta de rastreabilidade de estoque e a comunicação ineficiente entre as escolas e a gestão municipal.

## 🚀 Tecnologias Utilizadas

O projeto utiliza uma arquitetura moderna, separada em Frontend e Backend:

### Front-end
* ![Svelte](https://img.shields.io/badge/SvelteKit-FF3E00?style=for-the-badge&logo=svelte&logoColor=white) **SvelteKit**
* ![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white) **TailwindCSS**
* **Lucide Svelte** (Ícones)
* **Flatpickr** (Seleção de datas)

### Back-end
* ![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white) **NestJS**
* ![TypeORM](https://img.shields.io/badge/TypeORM-FE0702?style=for-the-badge&logo=typeorm&logoColor=white) **TypeORM**
* ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white) **MySQL**
* **JWT & Passport** (Autenticação e Segurança)
* **Nodemailer** (Envio de e-mails)

---

## ⚙️ Funcionalidades Principais

O sistema gerencia perfis de acesso distintos (Prefeitura, Escola, Nutricionista, Cozinheira):

### 🏛️ Prefeitura (Gestor Municipal)
* **Dashboard Gerencial**: Visão macro de solicitações pendentes e alertas de estoque crítico.
* **Estoque Central**: Controle total de entradas (incluindo importação via Excel) e saídas.
* **Análise de Solicitações**: Aprovação ou recusa de pedidos das escolas com validação automática de saldo em estoque.
* **Relatórios**: Geração de PDFs e planilhas para auditoria de envios, perdas e ajustes.

### 🏫 Escola (Gestor Escolar)
* **Solicitações**: Criação de pedidos de reposição de produtos.
* **Confirmação de Recebimento**: Conferência dos itens entregues com opção de reportar divergências (ex: produto avariado).
* **Estoque Local**: Visualização e controle do estoque da própria escola.

### 🍎 Nutricionista
* **Cardápios**: Planejamento de cardápios semanais e definição de refeições (Manhã/Tarde).
* **Controle de Feriados**: Marcação de dias sem merenda para evitar desperdício.

### 👩‍🍳 Cozinheira
* **Visualização Diária**: Acesso rápido ao cardápio do dia e ingredientes necessários.

---

## 🔧 Como Executar o Projeto

### Pré-requisitos
* Node.js (v18+)
* MySQL Server rodando

### 1. Configuração do Banco de Dados
Crie um banco de dados MySQL chamado `gema_db`.

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
```

### 3. Executando o Front-end

```bash

# Entre na pasta do frontend
cd gema-frontend

# Instale as dependências
npm install

# Execute o servidor de desenvolvimento
npm run dev
