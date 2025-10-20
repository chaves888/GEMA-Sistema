-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 20/10/2025 às 06:11
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
-- Estrutura para tabela `cities`
--

CREATE TABLE `cities` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `state` varchar(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `cities`
--

INSERT INTO `cities` (`id`, `name`, `state`) VALUES
('13d8429d-a380-4dca-8ab7-f9fb5b2c5aab', 'Umuarama', 'SP');

-- --------------------------------------------------------

--
-- Estrutura para tabela `escola_estoque`
--

CREATE TABLE `escola_estoque` (
  `id` varchar(36) NOT NULL,
  `quantity` float NOT NULL DEFAULT 0,
  `product_id` varchar(36) DEFAULT NULL,
  `school_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `escola_estoque`
--

INSERT INTO `escola_estoque` (`id`, `quantity`, `product_id`, `school_id`) VALUES
('306f44b1-0e7c-4d27-8229-1a089df924e3', 12, 'b41d1106-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('3d602dcf-74a9-4c12-adb9-11dde644cabf', 78, 'b41d10ac-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('6e306316-c711-484e-9f7c-de4530c01997', 3, 'b41d10e7-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('75976350-6646-44a3-b70d-56388af20d20', 7, 'b41d045c-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('8cf042ca-b0b2-4450-ba3a-181c34d26346', 3, 'b41d1120-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('a8f37b8c-4d0a-455f-a509-f92f20da764c', 27, 'f0fef45e-1c09-461b-a70a-208f0d0bc396', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('aa560452-974d-4472-9ca0-798d22fcd6af', 3, 'b41d1049-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('b0e7b310-7d01-4ebf-8793-a1e4b7ed5f2d', 5, 'b41d0fd7-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('c75a2819-7b2d-4a51-ad37-c5060cbe3307', 3, 'b41d10ca-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('e2320817-09a4-4fd1-bcbd-1707ec908039', 5, '63807e37-f8f7-4b8c-b028-cf257ebdd810', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('ee8d2e79-8b1a-4550-b2e3-53be59eac3bb', 23, 'b41d108c-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('fa303da7-9522-4a04-bce8-f706f070e53a', 10, 'b41d10ac-aae4-11f0-979e-a8a159e69946', '4b5f2e78-d358-47da-bebc-c211430d542b'),
('fdc7171b-f128-4b9e-9a94-e9c12bfda87b', 3, 'b41d106d-aae4-11f0-979e-a8a159e69946', '2ca88603-3da8-4fc4-a223-988e05dfd902');

-- --------------------------------------------------------

--
-- Estrutura para tabela `prefeitura_estoque`
--

CREATE TABLE `prefeitura_estoque` (
  `id` varchar(36) NOT NULL,
  `quantity` float NOT NULL DEFAULT 0,
  `product_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `prefeitura_estoque`
--

INSERT INTO `prefeitura_estoque` (`id`, `quantity`, `product_id`) VALUES
('0c6d3866-13b1-49e4-ae04-99978f536fe2', 1, 'b41d0fd7-aae4-11f0-979e-a8a159e69946'),
('2d644d05-5ed4-45f9-b734-33ec10c7e5e0', 93, 'b41d1106-aae4-11f0-979e-a8a159e69946'),
('4bc7e231-111e-4047-9ffd-074c8c68e035', 3, 'b41d045c-aae4-11f0-979e-a8a159e69946'),
('4c93a2a0-5bf1-4b9e-bfcb-c702c0e20a7f', 5, 'b41d106d-aae4-11f0-979e-a8a159e69946'),
('8e625c04-16d9-491b-a7cb-c22f23c38820', 12, 'b41d1049-aae4-11f0-979e-a8a159e69946'),
('a068a835-2fb0-4ada-82a8-9bfe3d1a9362', 118, 'b41d10ac-aae4-11f0-979e-a8a159e69946'),
('a49da9d0-9ef4-475b-9ebf-622d46ebe8dc', 5, 'b41d10e7-aae4-11f0-979e-a8a159e69946'),
('a7098f0b-1446-4d53-8d18-0da6ae07fea4', 103, 'b41d10ca-aae4-11f0-979e-a8a159e69946'),
('dbc2a728-4a18-4ec5-8df5-3374eda02fc3', 1, '63807e37-f8f7-4b8c-b028-cf257ebdd810'),
('e38b3c24-2564-4355-ae7a-6b47d383f1e9', 15, 'b41d108c-aae4-11f0-979e-a8a159e69946'),
('fa5dee8a-b08a-4fc3-8f80-e85d6b0563b1', 14, 'b41d1120-aae4-11f0-979e-a8a159e69946'),
('fca7b4de-877e-4c73-8c99-3ce8e8b1d9d8', 10, 'f0fef45e-1c09-461b-a70a-208f0d0bc396');

-- --------------------------------------------------------

--
-- Estrutura para tabela `products`
--

CREATE TABLE `products` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `unit` enum('KG','G','L','ML','UN') NOT NULL,
  `createdAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updatedAt` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `minStock` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `products`
--

INSERT INTO `products` (`id`, `name`, `unit`, `createdAt`, `updatedAt`, `minStock`) VALUES
('63807e37-f8f7-4b8c-b028-cf257ebdd810', 'Coca-Cola', 'L', '2025-10-17 00:01:02.921513', '2025-10-17 00:01:02.921513', 4),
('b41d045c-aae4-11f0-979e-a8a159e69946', 'Arroz Agulhinha Tipo 1', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:05:44.000000', 10),
('b41d0fd7-aae4-11f0-979e-a8a159e69946', 'Feijão Carioca', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:05:48.000000', 10),
('b41d1049-aae4-11f0-979e-a8a159e69946', 'Macarrão Espaguete', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:05:53.000000', 10),
('b41d106d-aae4-11f0-979e-a8a159e69946', 'Óleo de Soja', 'L', '2025-10-16 20:06:09.000000', '2025-10-16 23:05:58.000000', 10),
('b41d108c-aae4-11f0-979e-a8a159e69946', 'Sal Refinado', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:02.000000', 10),
('b41d10ac-aae4-11f0-979e-a8a159e69946', 'Açúcar Cristal', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:04.000000', 10),
('b41d10ca-aae4-11f0-979e-a8a159e69946', 'Peito de Frango Congelado', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:07.000000', 10),
('b41d10e7-aae4-11f0-979e-a8a159e69946', 'Maçã Fuji', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:10.000000', 10),
('b41d1106-aae4-11f0-979e-a8a159e69946', 'Banana Nanica', 'KG', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:12.000000', 10),
('b41d1120-aae4-11f0-979e-a8a159e69946', 'Ovos Brancos', 'UN', '2025-10-16 20:06:09.000000', '2025-10-16 23:06:18.000000', 10),
('f0fef45e-1c09-461b-a70a-208f0d0bc396', 'Ovo', 'UN', '2025-10-16 23:03:46.968901', '2025-10-16 23:03:46.968901', 20);

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
('2ca88603-3da8-4fc4-a223-988e05dfd902', 'Monteiro Lobato', 'Avenida 2', '13d8429d-a380-4dca-8ab7-f9fb5b2c5aab'),
('4b5f2e78-d358-47da-bebc-c211430d542b', 'Bento', 'Avenida 1', '13d8429d-a380-4dca-8ab7-f9fb5b2c5aab'),
('7a808ba6-8b3c-4489-864f-78f2ae62dcd8', 'Rachel de Queiroz', 'Rua bem te vi', '13d8429d-a380-4dca-8ab7-f9fb5b2c5aab');

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

--
-- Despejando dados para a tabela `solicitacao_items`
--

INSERT INTO `solicitacao_items` (`id`, `quantity_requested`, `quantity_approved`, `quantity_received`, `solicitacao_id`, `product_id`) VALUES
('0408e941-7b57-4d64-90c6-e9f095250da7', 4, 4, 4, 'da1552b9-035f-4580-aa8a-97688f8a0906', 'b41d10ac-aae4-11f0-979e-a8a159e69946'),
('0627ed1b-0fa9-428b-ae80-5b99927ec192', 3, 3, 3, 'afa7438e-3282-43db-8bb5-371137884a95', 'b41d10ac-aae4-11f0-979e-a8a159e69946'),
('0d7b1c67-0dec-43d0-ab9f-c4e9e79e9525', 3, 2, 2, '80f320b2-f181-4601-886f-2a1666cf03c2', 'b41d0fd7-aae4-11f0-979e-a8a159e69946'),
('0f7c496b-1a31-447a-9c91-93cc61036e68', 5, 5, 5, 'da1552b9-035f-4580-aa8a-97688f8a0906', 'b41d1106-aae4-11f0-979e-a8a159e69946'),
('92f4e7bd-b0fd-431b-af63-7b0afc1b6d2e', 5, 5, 5, '9a0ab1a2-a05d-43cc-8662-4f8cd5b6c15f', '63807e37-f8f7-4b8c-b028-cf257ebdd810'),
('c4aff049-7d2f-41c0-bb71-bcd9416cdf6b', 7, 7, 6, '64fb3547-9deb-4f72-aa27-bcdf091fc988', 'b41d10ac-aae4-11f0-979e-a8a159e69946'),
('f37db393-b271-45b7-ae43-d8d735fd6373', 4, 4, 4, 'afa7438e-3282-43db-8bb5-371137884a95', 'b41d1106-aae4-11f0-979e-a8a159e69946'),
('f8e1e703-13f1-4166-bf69-44e0953b472f', 100, 2, 2, 'e2d943f9-3bbe-4bcd-994a-de238c9b76a2', 'f0fef45e-1c09-461b-a70a-208f0d0bc396');

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

--
-- Despejando dados para a tabela `solicitacoes`
--

INSERT INTO `solicitacoes` (`id`, `created_at`, `updated_at`, `status`, `justificativa`, `observacao_prefeitura`, `school_id`, `requester_user_id`) VALUES
('64fb3547-9deb-4f72-aa27-bcdf091fc988', '2025-10-19 23:12:56.000777', '2025-10-19 23:13:28.000000', 'recebido', 'teste5', 'aprovado', '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL),
('80f320b2-f181-4601-886f-2a1666cf03c2', '2025-10-19 23:05:04.533321', '2025-10-19 23:05:43.000000', 'recebido', 'teste3', 'aprovado', '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL),
('9a0ab1a2-a05d-43cc-8662-4f8cd5b6c15f', '2025-10-19 23:06:11.637838', '2025-10-19 23:12:14.000000', 'recebido', 'teste4', NULL, '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL),
('afa7438e-3282-43db-8bb5-371137884a95', '2025-10-19 22:59:46.908696', '2025-10-19 23:00:35.000000', 'recebido', 'Teste', NULL, '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL),
('da1552b9-035f-4580-aa8a-97688f8a0906', '2025-10-19 23:02:40.723813', '2025-10-19 23:03:44.000000', 'recebido', 'teste2', 'aprovado', '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL),
('e2d943f9-3bbe-4bcd-994a-de238c9b76a2', '2025-10-19 23:37:09.051595', '2025-10-19 23:37:51.000000', 'recebido', 'teste6', NULL, '2ca88603-3da8-4fc4-a223-988e05dfd902', NULL);

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
('08084751-bcbf-4705-99d5-e42615e1696b', 'Sandra', 'cozinheira@gema.com', '$2b$10$oSKcjEXak75S31KmMzhzqO5ZWns8SWw2fdZYAQRc8YEiE0ALjUeeO', 'cozinheira', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('5c5df9a8-1c96-4fa1-b572-2268c1c7d79f', 'Wilson', 'Wilson@gema.com', '$2b$10$/XJOKiI7RPGAjvkDKePEI.Iuo6F.N1.IJlnM5i9gfAu9wmu1e/vga', 'escola', '2ca88603-3da8-4fc4-a223-988e05dfd902'),
('862098b5-c4cd-4879-a8a8-0e6d192e0653', 'Vinicius Chaves', 'vini@gema.com', '$2b$10$o1L0vW9T7Kh0wjlqzgAC4OQVVBr2gf2l4uEFidWzbSK7HPeuieD9O', 'prefeitura', NULL),
('a2d3b3b8-68f1-4919-8ad1-6b04a5f2ca5b', 'Leonardo', 'leonardo@gema.com', '$2b$10$Wb/xIQMyDa0UwFa8USeRaumuNI.C8GT8J2Qv6lv9nKpBZ36BrHHEW', 'escola', '4b5f2e78-d358-47da-bebc-c211430d542b'),
('b953a614-1a7f-466f-acec-ddaa5fde74ba', 'Admin Prefeitura', 'prefeitura@gema.com', '$2b$10$.G4EiteU3tPG48cSL0bztuFWdT7j4VQ6.ReHFlem9ZC5JLqmfiwAi', 'prefeitura', NULL),
('cb58e4c7-1d63-481a-9c96-54390ff43a36', 'Nutricionista', 'nutricionista@gema.com', '$2b$10$ZGZNVTcQo.V7MOnHD2uhE.nPeFKGe0dKNEMLnpe.GT4qxdX6xyNKW', 'nutricionista', NULL);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_a0ae8d83b7d32359578c486e7f` (`name`);

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
