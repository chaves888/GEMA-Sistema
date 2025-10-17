<script lang="ts">
  export let percentage: number;
  export let status: 'Crítico' | 'Médio' | 'Bom' | 'N/A';

  // Limita a barra em 100% para não estourar o layout
  const barWidth = Math.min(percentage, 100);
</script>

<!-- Container da barra -->
<div class="w-full bg-gray-200 rounded-full h-2.5">
  <!-- Barra de progresso colorida -->
  <div
    class="h-2.5 rounded-full transition-all duration-500"
    class:bg-red-500={status === 'Crítico'}
    class:bg-yellow-400={status === 'Médio'}
    class:bg-green-500={status === 'Bom'}
    class:bg-gray-400={status === 'N/A'}
    style="width: {barWidth}%"
  ></div>
</div>
