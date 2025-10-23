🏛️ PREFEITURA
Data de Entrega: Incluir um campo de "Data de Entrega Prevista" no momento da aprovação da solicitação da escola.

Justificativa de Estoque: Ao diminuir a quantidade de um item no estoque da prefeitura, exigir uma justificativa obrigatória em um modal. O sistema deve salvar quem, quando e por que a alteração foi feita.

Cadastro de Cidades: Melhorar o cadastro de cidades para incluir um campo de CEP e um seletor de UF (Estado), validando se o CEP pertence àquele estado/cidade.

🏫 ESCOLA
Status de Recebimento: Se a escola confirmar o recebimento de um item com quantidade 0, o status desse item específico deve mudar para "Pendente" (ou "Não Recebido") em vez de fechar o pedido.

Listagem de Solicitações: Adicionar 3 novas colunas na tela de solicitações da escola:

Quantidade Solicitada (total)

Quantidade Liberada (total aprovado pela prefeitura)

Data Prevista de Entrega (informada pela prefeitura)

🍽️ NUTRICIONISTA
Publicação de Cardápio: O sistema não deve permitir "Publicar" um cardápio se algum dia útil (para o qual não foi marcado "Sem Aula") estiver sem as refeições da manhã e da tarde preenchidas.

Simplificação do Cardápio: Remover o campo "Nome" da criação do cardápio, preenchendo-o automaticamente com base nas datas selecionadas (ex: "Cardápio de 27/10 a 31/10").

Opção "Sem Aula": Em cada dia útil do cardápio (seg, ter, qua, etc.), adicionar um checkbox "Sem Aula". Se marcado, o preenchimento das refeições (manhã/tarde) para aquele dia deixa de ser obrigatório.

Validação de Data: Impedir a criação de cardápios com data de início anterior à data atual.

👩‍🍳 COZINHEIRA
Acesso ao Estoque: Permitir que a cozinheira visualize o estoque da escola (somente leitura), mas sem permissão para fazer ajustes.

🔐 GERAL (Todos os Perfis)
Login: Adicionar a funcionalidade "Esqueci minha senha" na tela de login.

Validação de E-mail: Implementar uma validação mais robusta no formato do e-mail durante o cadastro.
