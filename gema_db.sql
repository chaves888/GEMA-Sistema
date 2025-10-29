-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 29/10/2025 às 21:02
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `gema_db`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `cardapios`
--

CREATE TABLE `cardapios` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `status` enum('rascunho','publicado') NOT NULL DEFAULT 'rascunho',
  `holidayWeekdays` text DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `created_by_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `cities`
--

CREATE TABLE `cities` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `state` varchar(2) NOT NULL,
  `cep` varchar(9) NOT NULL,
  `bairro` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `cities`
--

INSERT INTO `cities` (`id`, `name`, `state`, `cep`, `bairro`) VALUES
('87a6369d-9553-4ef0-8718-5b00be177ef3', 'Umuarama', 'PR', '87504-180', 'Zona V');

-- --------------------------------------------------------

--
-- Estrutura para tabela `escola_estoque`
--

CREATE TABLE `escola_estoque` (
  `id` varchar(36) NOT NULL,
  `quantity` float NOT NULL DEFAULT 0,
  `product_id` varchar(36) DEFAULT NULL,
  `school_id` varchar(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `prefeitura_estoque`
--

CREATE TABLE `prefeitura_estoque` (
  `id` varchar(36) NOT NULL,
  `quantity` float NOT NULL DEFAULT 0,
  `product_id` varchar(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `products`
--

CREATE TABLE `products` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `unit` enum('L','UN') NOT NULL,
  `min_stock_prefeitura` float NOT NULL DEFAULT 0,
  `min_stock_escola` float NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `products`
--

INSERT INTO `products` (`id`, `name`, `unit`, `min_stock_prefeitura`, `min_stock_escola`, `created_at`, `updated_at`) VALUES
('069656e3-ffe9-4e16-bbd3-21747fc1a182', 'Fubá Mimoso (1Kg)', 'UN', 100, 10, '2025-10-29 16:56:05.145770', '2025-10-29 16:58:22.000000'),
('32e1075b-7bcf-4add-8a4e-253064392338', 'Óleo de Soja (900ml)', 'UN', 200, 40, '2025-10-29 16:50:54.569925', '2025-10-29 16:57:27.000000'),
('330179f7-4225-4c53-bcce-fa4e78f33b08', 'Saco de Arroz Agulhinha (10Kg)', 'UN', 500, 10, '2025-10-29 16:45:18.855984', '2025-10-29 16:45:18.855984'),
('34fcc870-59be-4798-b0ea-d949c63c7ee9', 'Ovos (Dúzia)', 'UN', 500, 10, '2025-10-29 17:00:48.082960', '2025-10-29 17:00:48.082960'),
('79e1e219-cb47-4f3e-b529-68e2e2a98d45', 'Açúcar Cristal', 'UN', 200, 10, '2025-10-29 16:52:14.751131', '2025-10-29 16:52:14.751131'),
('980c95b2-9fd8-4645-b848-730a5bf0bfff', 'Leite em Pó Integral (380)', 'UN', 150, 15, '2025-10-29 16:55:46.582786', '2025-10-29 16:58:03.000000'),
('a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', 'Feijão Carioca (1KG)', 'UN', 400, 40, '2025-10-29 16:49:52.912843', '2025-10-29 16:49:52.912843'),
('abca8fbe-753a-458a-863b-48fc46c255e4', 'Sal Refinado (1Kg)', 'UN', 500, 10, '2025-10-29 16:51:31.177731', '2025-10-29 16:51:31.177731'),
('c2566218-7972-4778-bcf3-b5f6e8ed2136', 'Macarrão Parafuso (1Kg)', 'UN', 300, 30, '2025-10-29 16:50:39.318232', '2025-10-29 16:50:39.318232'),
('e47b6419-3c22-4423-8f44-609431702278', 'Carne Bovina (Acém moído - 1 Kg)', 'UN', 800, 80, '2025-10-29 17:01:20.215322', '2025-10-29 17:01:41.000000'),
('e9a78193-e02b-48a0-803e-f46c17cbe2f8', 'Peito de Frango (congelado - 1Kg) ', 'UN', 800, 80, '2025-10-29 16:57:10.757939', '2025-10-29 17:01:36.000000');

-- --------------------------------------------------------

--
-- Estrutura para tabela `refeicao_products`
--

CREATE TABLE `refeicao_products` (
  `refeicao_id` varchar(36) NOT NULL,
  `product_id` varchar(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `refeicoes`
--

CREATE TABLE `refeicoes` (
  `id` varchar(36) NOT NULL,
  `diaSemana` enum('segunda','terca','quarta','quinta','sexta') NOT NULL,
  `tipo` enum('manha','tarde') NOT NULL,
  `description` text NOT NULL,
  `cardapioId` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `schools`
--

CREATE TABLE `schools` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `schools`
--

INSERT INTO `schools` (`id`, `name`, `address`, `city_id`) VALUES
('430c8fde-ccfb-452a-8570-0c64059b7fdc', 'Escola1', 'Avenida 1', '87a6369d-9553-4ef0-8718-5b00be177ef3');

-- --------------------------------------------------------

--
-- Estrutura para tabela `solicitacao_items`
--

CREATE TABLE `solicitacao_items` (
  `id` varchar(36) NOT NULL,
  `quantity_requested` float NOT NULL,
  `quantity_approved` float DEFAULT NULL,
  `quantity_received` float DEFAULT NULL,
  `solicitacao_id` varchar(36) DEFAULT NULL,
  `product_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `solicitacoes`
--

CREATE TABLE `solicitacoes` (
  `id` varchar(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `status` enum('pendente','aprovado','aprovado_parcialmente','negado','recebido') NOT NULL DEFAULT 'pendente',
  `justificativa` text DEFAULT NULL,
  `observacao_prefeitura` text DEFAULT NULL,
  `school_id` varchar(36) DEFAULT NULL,
  `requester_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `users`
--

CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile` enum('prefeitura','escola','nutricionista','cozinheira') NOT NULL,
  `school_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `profile`, `school_id`) VALUES
('30939156-3375-450f-88b3-c44349ec7fec', 'Gestor Escola 1', 'gestorescola1@gmail.com', '$2b$10$n8CeKfztq/1HBl4uoL3f.uOTtinGOmk1vQirUW39n/9tOD5KRIdaO', 'escola', '430c8fde-ccfb-452a-8570-0c64059b7fdc'),
('862098b5-c4cd-4879-a8a8-0e6d192e0653', 'Leonardo Chaves', 'leonardo@gema.com', '$2b$10$o1L0vW9T7Kh0wjlqzgAC4OQVVBr2gf2l4uEFidWzbSK7HPeuieD9O', 'prefeitura', NULL),
('dbde8d5a-4344-402c-b7f3-68626ab62c14', 'Cozinheira Escola 1', 'cozinheiraescola1@gmail.com', '$2b$10$Li1oCrcXAimUgMvTDxsz2OLAHuXSYLm.pq3BGqykuFWQZOhLGnusu', 'cozinheira', '430c8fde-ccfb-452a-8570-0c64059b7fdc'),
('fe7b56e1-7de8-486a-987b-8d5f0c4abda6', 'Nutricionista', 'nutricionista@gmail.com', '$2b$10$h3ZZ/Nzg6QgRZejiTJxGiOT6Smb0RRw4LC0PegIiBv5L1zxbx3WhK', 'nutricionista', NULL);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `cardapios`
--
ALTER TABLE `cardapios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_47f0cdaced75010db0a02d56564` (`created_by_user_id`);

--
-- Índices de tabela `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_a0ae8d83b7d32359578c486e7f` (`name`),
  ADD UNIQUE KEY `IDX_1b02e4e8e1bfae43deacbad04c` (`cep`);

--
-- Índices de tabela `escola_estoque`
--
ALTER TABLE `escola_estoque`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_b99bea8bf264022b92a0707ed9` (`product_id`,`school_id`),
  ADD KEY `FK_0b60422d0b38efb969505c3f0f4` (`school_id`);

--
-- Índices de tabela `prefeitura_estoque`
--
ALTER TABLE `prefeitura_estoque`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `REL_dca2a658a8ff8f08bc62592b15` (`product_id`);

--
-- Índices de tabela `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_4c9fb58de893725258746385e1` (`name`);

--
-- Índices de tabela `refeicao_products`
--
ALTER TABLE `refeicao_products`
  ADD PRIMARY KEY (`refeicao_id`,`product_id`),
  ADD KEY `IDX_98fee2876918511c6f956ba8c6` (`refeicao_id`),
  ADD KEY `IDX_553989363ba25c39e9b66de60e` (`product_id`);

--
-- Índices de tabela `refeicoes`
--
ALTER TABLE `refeicoes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_ff9c814bb9579885aca06c03f9` (`cardapioId`,`diaSemana`,`tipo`);

--
-- Índices de tabela `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_d92181684e73f7533e903e1acfd` (`city_id`);

--
-- Índices de tabela `solicitacao_items`
--
ALTER TABLE `solicitacao_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_a9c3f22b6a18dca4517b98a0e7c` (`solicitacao_id`),
  ADD KEY `FK_4e728e4178eec03db815fd6362f` (`product_id`);

--
-- Índices de tabela `solicitacoes`
--
ALTER TABLE `solicitacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_c16f33eb96b18a29fa53d301af9` (`school_id`),
  ADD KEY `FK_04d41884a01f9d04032b902ba1e` (`requester_user_id`);

--
-- Índices de tabela `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_97672ac88f789774dd47f7c8be` (`email`),
  ADD KEY `FK_25e1cf8f41bae2f3d11f3c2a028` (`school_id`);

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `cardapios`
--
ALTER TABLE `cardapios`
  ADD CONSTRAINT `FK_47f0cdaced75010db0a02d56564` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Restrições para tabelas `escola_estoque`
--
ALTER TABLE `escola_estoque`
  ADD CONSTRAINT `FK_0b60422d0b38efb969505c3f0f4` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_3a8866b379173ca41d8f0bc3a12` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `prefeitura_estoque`
--
ALTER TABLE `prefeitura_estoque`
  ADD CONSTRAINT `FK_dca2a658a8ff8f08bc62592b152` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `refeicao_products`
--
ALTER TABLE `refeicao_products`
  ADD CONSTRAINT `FK_553989363ba25c39e9b66de60e3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_98fee2876918511c6f956ba8c63` FOREIGN KEY (`refeicao_id`) REFERENCES `refeicoes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Restrições para tabelas `refeicoes`
--
ALTER TABLE `refeicoes`
  ADD CONSTRAINT `FK_f63129842592484fb1e75fe993c` FOREIGN KEY (`cardapioId`) REFERENCES `cardapios` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `schools`
--
ALTER TABLE `schools`
  ADD CONSTRAINT `FK_d92181684e73f7533e903e1acfd` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Restrições para tabelas `solicitacao_items`
--
ALTER TABLE `solicitacao_items`
  ADD CONSTRAINT `FK_4e728e4178eec03db815fd6362f` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_a9c3f22b6a18dca4517b98a0e7c` FOREIGN KEY (`solicitacao_id`) REFERENCES `solicitacoes` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `solicitacoes`
--
ALTER TABLE `solicitacoes`
  ADD CONSTRAINT `FK_04d41884a01f9d04032b902ba1e` FOREIGN KEY (`requester_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_c16f33eb96b18a29fa53d301af9` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON UPDATE NO ACTION;

--
-- Restrições para tabelas `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `FK_25e1cf8f41bae2f3d11f3c2a028` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
