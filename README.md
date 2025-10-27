🧩 Funcionalidades Pendentes e Ajustes do Sistema

Este documento descreve as funcionalidades pendentes, melhorias e regras específicas por perfil de usuário (Prefeitura, Escola, Nutricionista e Cozinheira), além de ajustes gerais aplicáveis a todo o sistema.

🏛️ PREFEITURA
📅 Data de Entrega

Incluir um campo "Data de Entrega Prevista" no momento da aprovação da solicitação da escola.

📦 Justificativa de Estoque

Ao diminuir a quantidade de um item no estoque:

Exibir um modal obrigatório solicitando justificativa.

O modal deve conter um campo de texto para o motivo da alteração.

O sistema deve registrar:

Usuário responsável

Data e hora da modificação

Motivo informado

🗺️ Cadastro de Cidades

Melhorar o cadastro de cidades para incluir:

Campo de CEP

Seletor de UF (Estado)

O sistema deve validar se o CEP pertence à cidade e UF selecionadas.

📦 Visualização de Estoque das Escolas

A Prefeitura poderá visualizar o estoque de cada escola, em modo somente leitura.

Não será permitido editar, excluir ou movimentar itens do estoque da escola.

🏫 ESCOLA
📦 Status de Recebimento

Caso a escola confirme o recebimento de um item com quantidade 0, o status do produto deve ser alterado automaticamente para:

“Pendente” ou “Não Recebido” (em vez de “Concluído”).

📋 Listagem de Solicitações

Na listagem de solicitações da escola, adicionar as seguintes colunas:

Quantidade Solicitada — total requisitado pela escola.

Quantidade Liberada — total aprovado pela prefeitura.

Data Prevista de Entrega — informada pela prefeitura no momento da aprovação.

🍽️ NUTRICIONISTA
📅 Publicação de Cardápio

O sistema não deve permitir publicação de um cardápio se:

Algum dia útil (não marcado como “Sem Aula”) estiver sem preenchimento das refeições Manhã e Tarde.

🧾 Simplificação do Cardápio

Remover o campo “Nome” do formulário de criação do cardápio.

O nome deve ser gerado automaticamente com base no período, por exemplo:

“Cardápio de 27/10 a 31/10”.

📆 Opção “Sem Aula”

Em cada dia útil do cardápio, incluir um checkbox “Sem Aula”.

Quando marcado, os campos de refeição Manhã e Tarde tornam-se opcionais.

⏰ Validação de Data

Impedir a criação de cardápios com data inicial anterior à data atual.

👩‍🍳 COZINHEIRA
📊 Acesso ao Estoque

A cozinheira poderá apenas visualizar o estoque da escola.

Não possui permissão de edição, exclusão ou movimentação de itens.

🔐 GERAL (Todos os Perfis)
🔑 Login

Adicionar a funcionalidade “Esqueci minha senha” na tela de login.

📧 Validação de E-mail

Implementar validação robusta de e-mail, garantindo:

Formato correto (ex: usuario@dominio.com
)

Domínio válido

📘 Observação

Essas regras e melhorias devem ser integradas ao fluxo atual do sistema, mantendo a segurança, rastreabilidade e coerência entre os módulos de Prefeitura, Escola, Nutricionista e Cozinheira.
