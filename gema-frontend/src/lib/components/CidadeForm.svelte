<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { Loader2 } from 'lucide-svelte';
  import { toast } from '$lib/toast';

  export let cidade: {
      id?: string;
      name: string;
      state: string;
      cep: string;
      bairro?: string | null;
  } = { name: '', state: '', cep: '', bairro: '' };

  export let isEditing = false;
  const dispatch = createEventDispatcher();

  let isCepLoading = false;
  let cepError: string | null = null;

  const estados = [
      { uf: 'AC', nome: 'Acre' }, { uf: 'AL', nome: 'Alagoas' }, { uf: 'AP', nome: 'Amapá' },
      { uf: 'AM', nome: 'Amazonas' }, { uf: 'BA', nome: 'Bahia' }, { uf: 'CE', nome: 'Ceará' },
      { uf: 'DF', nome: 'Distrito Federal' }, { uf: 'ES', nome: 'Espírito Santo' }, { uf: 'GO', nome: 'Goiás' },
      { uf: 'MA', nome: 'Maranhão' }, { uf: 'MT', nome: 'Mato Grosso' }, { uf: 'MS', nome: 'Mato Grosso do Sul' },
      { uf: 'MG', nome: 'Minas Gerais' }, { uf: 'PA', nome: 'Pará' }, { uf: 'PB', nome: 'Paraíba' },
      { uf: 'PR', nome: 'Paraná' }, { uf: 'PE', nome: 'Pernambuco' }, { uf: 'PI', nome: 'Piauí' },
      { uf: 'RJ', nome: 'Rio de Janeiro' }, { uf: 'RN', nome: 'Rio Grande do Norte' }, { uf: 'RS', nome: 'Rio Grande do Sul' },
      { uf: 'RO', nome: 'Rondônia' }, { uf: 'RR', nome: 'Roraima' }, { uf: 'SC', nome: 'Santa Catarina' },
      { uf: 'SP', nome: 'São Paulo' }, { uf: 'SE', nome: 'Sergipe' }, { uf: 'TO', nome: 'Tocantins' }
  ] as const;

  async function fetchCepData() {
      cepError = null;
      const cepInput = cidade.cep?.replace(/\D/g, '');

      if (cepInput && cepInput.length === 8) {
          isCepLoading = true;
          try {
              const response = await fetch(`https://viacep.com.br/ws/${cepInput}/json/`);
              if (!response.ok) throw new Error('Falha ao buscar CEP.');
              const data = await response.json();

              if (data.erro) {
                  cepError = 'CEP não encontrado.';
                  if (!isEditing) {
                      cidade.name = '';
                      cidade.state = '';
                      cidade.bairro = '';
                  }
              } else {
                  // Preenche os campos
                  cidade.name = data.localidade || cidade.name;
                  cidade.state = data.uf || cidade.state;
                  // Preenche o bairro se vier da API, mas permite edição
                  cidade.bairro = data.bairro || '';
                  cidade = { ...cidade };
              }
          } catch (error) {
              console.error("Erro ao buscar CEP:", error);
              cepError = 'Erro ao consultar API de CEP.';
          } finally {
              isCepLoading = false;
          }
      } else if (cepInput && cepInput.length > 0) {
            cepError = 'CEP deve conter 8 dígitos.';
      } else {
           cepError = null;
      }
  }

  function handleSubmit() {
    if (cidade.state) { cidade.state = cidade.state.toUpperCase(); }

    if (cidade.cep) {
        let cleanedCep = cidade.cep.replace(/\D/g, '');
        if (cleanedCep.length === 8) {
            cidade.cep = `${cleanedCep.slice(0, 5)}-${cleanedCep.slice(5)}`;
        } else {
             toast.error("Erro: CEP inválido. Deve conter 8 dígitos."); return;
        }
    } else {
        toast.error("Erro: O campo CEP é obrigatório."); return;
    }
    
    if (!cidade.name) { toast.error("Erro: O Nome da Cidade é obrigatório."); return; }
    if (!cidade.state) { toast.error("Erro: O Estado (UF) é obrigatório."); return; }

    // Envia o bairro como null se estiver vazio
    cidade.bairro = cidade.bairro || null;
    dispatch('save', cidade);
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
    <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 dark:text-white">
      {isEditing ? 'Editar Cidade' : 'Nova Cidade'}
    </h2>
  </div>

  <div class="space-y-5 flex-1 overflow-y-auto pr-1">
    <div>
        <label for="cep" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">CEP</label>
        <div class="relative">
            <input 
              type="text" 
              id="cep" 
              class="mt-1 w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition pr-10 placeholder-gray-400 dark:placeholder-gray-400" 
              placeholder="Digite 8 dígitos..." 
              maxlength="9" 
              bind:value={cidade.cep} 
              required 
              on:blur={fetchCepData} 
            />
            {#if isCepLoading}
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                    <Loader2 class="w-5 h-5 text-gray-400 dark:text-gray-500 animate-spin" />
                </div>
            {/if}
        </div>
        {#if cepError}<p class="mt-1 text-xs text-red-600 dark:text-red-400">{cepError}</p>{/if}
    </div>

    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Nome da Cidade</label>
      <input 
        type="text" 
        id="name" 
        class="mt-1 w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition disabled:bg-gray-100 dark:disabled:bg-gray-800 disabled:text-gray-500 dark:disabled:text-gray-400" 
        bind:value={cidade.name} 
        required 
        disabled={isCepLoading} 
      />
    </div>

    <div>
      <label for="bairro" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Bairro</label>
      <input 
        type="text" 
        id="bairro" 
        class="mt-1 w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition disabled:bg-gray-100 dark:disabled:bg-gray-800 disabled:text-gray-500 dark:disabled:text-gray-400 placeholder-gray-400 dark:placeholder-gray-400" 
        placeholder="Digite o bairro (se houver)" 
        bind:value={cidade.bairro} 
        disabled={isCepLoading} 
      />
    </div>
    
    <div>
      <label for="state" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Estado (UF)</label>
      <select 
        id="state" 
        class="mt-1 w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition disabled:bg-gray-100 dark:disabled:bg-gray-800 disabled:text-gray-500 dark:disabled:text-gray-400" 
        bind:value={cidade.state} 
        required 
        disabled={isCepLoading}
      >
          <option value="" disabled>Selecione...</option>
          {#each estados as estado (estado.uf)}
              <option value={estado.uf}>{estado.uf} - {estado.nome}</option>
          {/each}
      </select>
    </div>
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 sm:gap-4 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button 
      type="button" 
      on:click={() => dispatch('cancel')} 
      class="w-full sm:w-auto bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition shadow-sm"
    >
      Cancelar
    </button>
    <button 
      type="submit" 
      class="w-full sm:w-auto bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105 disabled:opacity-50" 
      disabled={isCepLoading}
    >
      Salvar
    </button>
  </div>
</form>