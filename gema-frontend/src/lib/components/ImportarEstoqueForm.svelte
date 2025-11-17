<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import { toast } from '$lib/toast';
    import * as api from '$lib/api';
    import { Loader2, AlertTriangle, UploadCloud } from 'lucide-svelte';
    import { fade } from 'svelte/transition';

    const dispatch = createEventDispatcher();

    let fileList: FileList | undefined;
    let isLoading = false;
    let importErrors: string[] = [];
    let dragOver = false;

    async function handleSubmit() {
        const file = fileList?.[0];
        if (!file) {
            toast.error('Por favor, selecione um arquivo .xlsx ou .xls');
            return;
        }

        isLoading = true;
        importErrors = [];

        const formData = new FormData();
        formData.append('file', file);

        try {
            const response = await api.post('estoque/prefeitura/importar', formData);
            
            toast.success(response.message || 'Estoque importado com sucesso!');
            dispatch('imported');
            dispatch('cancel');
            
        } catch (e: any) {
            if (e && e.erros) {
                toast.error(e.message || 'Falha na validação. Verifique os erros.');
                importErrors = e.erros;
            } else {
                toast.error(e.message || 'Ocorreu um erro desconhecido.');
            }
            console.error(e);
        } finally {
            isLoading = false;
        }
    }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
    <div class="border-b pb-4 mb-6">
        <h2 class="text-xl md:text-2xl font-bold text-gray-800">Importar Ajustes de Estoque</h2>
        <p class="text-gray-600 mt-1 text-sm md:text-base">
            Envie uma planilha .xlsx ou .xls para <span class="font-bold">somar ou subtrair</span> do estoque atual.
        </p>
    </div>

    <div class="space-y-5 flex-1 overflow-y-auto pr-1">
        <label
            for="file-upload"
            class="relative flex flex-col items-center justify-center w-full h-48 border-2 border-dashed rounded-lg cursor-pointer transition-colors
            {dragOver
                ? 'border-primary-600 bg-primary-50'
                : 'border-gray-300 bg-gray-50 hover:bg-gray-100'}"
            on:dragover|preventDefault={() => (dragOver = true)}
            on:dragleave|preventDefault={() => (dragOver = false)}
            on:drop|preventDefault={(e) => {
                fileList = e.dataTransfer?.files;
                dragOver = false;
            }}
        >
            <div class="flex flex-col items-center justify-center pt-5 pb-6 text-center px-4">
                <UploadCloud class="w-10 h-10 mb-3 text-gray-400" />
                {#if !fileList || fileList.length === 0}
                    <p class="mb-2 text-sm text-gray-500">
                        <span class="font-semibold">Clique para enviar</span> ou arraste e solte
                    </p>
                    <p class="text-xs text-gray-500">Somente .xlsx ou .xls</p>
                {:else}
                    <p class="font-semibold text-primary-700 text-sm break-all px-2">{fileList[0].name}</p>
                    <p class="text-xs text-gray-500 mt-1">
                        {Math.round(fileList[0].size / 1024)} KB
                    </p>
                {/if}
            </div>
            <input
                id="file-upload"
                type="file"
                class="hidden"
                bind:files={fileList}
                accept=".xlsx, .xls, application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            />
        </label>

        <div class="text-sm text-gray-600 p-3 bg-gray-100 rounded-md border">
            <span class="font-semibold block mb-1">Instruções:</span>
            A planilha deve conter exatamente estes cabeçalhos na primeira linha:
            <ul class="list-disc list-inside ml-1 mt-1 space-y-1 text-xs md:text-sm">
                <li><code class="font-bold bg-gray-200 px-1 rounded">PRODUTO_NOME</code> (Nome exato do produto)</li>
                <li><code class="font-bold bg-gray-200 px-1 rounded">QUANTIDADE_AJUSTE</code> (Valor a somar/subtrair)</li>
            </ul>
            <p class="mt-2 text-xs italic text-gray-500">
                Ex: Se o estoque é 10 e a planilha tem 5, o novo será 15. Se tiver -2, será 8.
            </p>
        </div>

        {#if importErrors.length > 0}
            <div
                class="bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg shadow-inner max-h-48 overflow-y-auto text-sm"
                transition:fade
            >
                <h4 class="font-bold mb-2 flex items-center gap-2 text-red-800">
                    <AlertTriangle class="w-5 h-5 flex-shrink-0" />
                    Erros na planilha:
                </h4>
                <ul class="list-disc list-inside space-y-1 ml-1">
                    {#each importErrors as error}
                        <li>{error}</li>
                    {/each}
                </ul>
            </div>
        {/if}
    </div>

    <div class="mt-6 flex flex-col-reverse sm:flex-row justify-between gap-3 border-t pt-6">
        <button
            type="button"
            on:click={() => dispatch('cancel')}
            class="w-full sm:w-auto px-5 py-2.5 rounded-xl border border-gray-300 text-gray-700 font-semibold bg-gray-100 hover:bg-gray-200 transition-all"
            disabled={isLoading}
        >
            Cancelar
        </button>
        <button
            type="submit"
            class="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-primary-600 text-white font-semibold hover:bg-primary-700 transition-all shadow-sm active:scale-95 disabled:opacity-50 flex justify-center items-center min-w-[120px]"
            disabled={isLoading}
        >
            {#if isLoading}
                <Loader2 class="w-5 h-5 animate-spin" />
            {:else}
                Importar
            {/if}
        </button>
    </div>
</form>