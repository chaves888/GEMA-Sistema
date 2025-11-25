-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 25/11/2025 às 23:12
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

--
-- Despejando dados para a tabela `cardapios`
--

INSERT INTO `cardapios` (`id`, `name`, `startDate`, `endDate`, `status`, `holidayWeekdays`, `created_at`, `updated_at`, `created_by_user_id`) VALUES
('181070ab-6eac-400f-a71f-26112a3dddad', 'Cardápio 24/11 a 28/11/2025', '2025-11-24', '2025-11-28', 'rascunho', '', '2025-11-23 18:03:31.723372', '2025-11-23 18:03:31.723372', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6'),
('5e89b5f2-d47f-4c8f-8eab-380971c4995b', 'Cardápio 01/12 a 05/12/2025', '2025-12-01', '2025-12-05', 'publicado', 'quarta,quinta,segunda,sexta,terça', '2025-11-25 19:00:07.015133', '2025-11-25 19:00:22.000000', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6'),
('a1359c39-3375-42a9-875a-774d2dd9ceb6', 'Cardápio 25/11 a 28/11/2025', '2025-11-25', '2025-11-28', 'publicado', 'sexta', '2025-11-25 18:41:29.584875', '2025-11-25 18:42:17.000000', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6'),
('b1a19f37-24e3-42b0-acb5-8c4db97cb9fe', 'Cardápio 24/11 a 24/11/2025', '2025-11-24', '2025-11-24', 'rascunho', '', '2025-11-17 14:08:20.105229', '2025-11-17 14:08:20.105229', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6'),
('d9d01dc2-9d61-4651-a84e-d126efc30e1e', 'Cardápio 06/11 a 07/11/2025', '2025-11-06', '2025-11-07', 'publicado', '', '2025-11-06 14:38:24.539439', '2025-11-06 14:39:05.000000', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6'),
('e18d6ff8-4e31-4420-b2eb-ea7fc8646dc4', 'Cardápio 17/11 a 21/11/2025', '2025-11-17', '2025-11-21', 'publicado', 'quarta,quinta,segunda,sexta,terça', '2025-11-07 11:04:45.311086', '2025-11-17 10:21:50.000000', 'fe7b56e1-7de8-486a-987b-8d5f0c4abda6');

-- --------------------------------------------------------

--
-- Estrutura para tabela `cities`
--

CREATE TABLE `cities` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `state` varchar(2) NOT NULL,
  `cep` varchar(9) NOT NULL,
  `bairro` varchar(255) DEFAULT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  `deleted_by_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `cities`
--

INSERT INTO `cities` (`id`, `name`, `state`, `cep`, `bairro`, `deleted_at`, `deleted_by_user_id`) VALUES
('3a3a48d3-e83a-4009-b4c6-d56ad3b50632', 'Ivaté', 'PR', '87525-000', NULL, '2025-11-06 15:29:41.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('429fedbc-533c-46df-a3e0-486e644c9cf1', 'Ivaté', 'PR', '87525-000', NULL, '2025-11-06 15:45:29.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('87a6369d-9553-4ef0-8718-5b00be177ef3', 'Umuarama', 'PR', '87509-771', 'Jardim Verde Vale', NULL, NULL),
('f27eae60-75cd-4566-8f56-3c7f7eac22be', 'Umuarama', 'PR', '87504-180', 'Zona V', NULL, NULL);

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

--
-- Despejando dados para a tabela `escola_estoque`
--

INSERT INTO `escola_estoque` (`id`, `quantity`, `product_id`, `school_id`, `created_at`, `updated_at`) VALUES
('00b1d139-1464-4486-9430-51813f472e9c', 1, '34fcc870-59be-4798-b0ea-d949c63c7ee9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.922529', '2025-11-13 11:21:32.000000'),
('0c184de6-2996-4df7-a032-bc94b3ea76f8', 1, '980c95b2-9fd8-4645-b848-730a5bf0bfff', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.916605', '2025-11-13 11:21:32.000000'),
('0dedcd87-da68-4f49-9776-2f601b83d0e6', 211, '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.123128', '2025-11-17 16:01:46.000000'),
('10090667-05fd-45a3-8566-ae9ef576f108', 213, '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.139302', '2025-11-17 16:01:46.000000'),
('1b6095c1-4d1c-4229-8895-0812db1bd628', 1, '511430ef-91be-4857-91cd-22762429a2e6', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.905237', '2025-11-13 11:21:32.000000'),
('1ed22d68-ccc6-4ce4-8f7f-864a442871c5', 1, '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.933859', '2025-11-13 11:21:32.000000'),
('293b2d88-76d8-43ea-b1d3-c2b8e1029557', 199, '7f059474-4f8b-4ddf-9ea5-92ca62c469f5', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-06 10:41:23.512042', '2025-11-06 12:13:31.000000'),
('29582490-cc1d-4406-896d-c314ea79f1a2', 3, 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.134545', '2025-11-17 16:01:46.000000'),
('3d26d922-0be4-42f5-971f-3f1136a8df59', 1, 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.925091', '2025-11-13 11:21:32.000000'),
('4429dfa2-4e45-41dc-b3e2-22b24714703a', 13, 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-04 16:03:19.288114', '2025-11-17 16:01:46.000000'),
('476dbf86-d6ca-4b43-b689-b2c82ab09c27', 13, '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.150425', '2025-11-17 16:01:46.000000'),
('4a74926f-0c67-4db2-9674-fbf6ece86c78', 3, 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-05 10:35:28.452620', '2025-11-17 16:01:46.000000'),
('50b6bd6c-ee91-4be1-bb38-f008b703a5b6', 3, '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-05 10:35:28.451643', '2025-11-17 16:01:46.000000'),
('512eb319-1686-41cb-886d-5e7d9549e359', 100, 'dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-06 10:42:08.627169', '2025-11-06 10:42:08.627169'),
('6d196b88-5537-47f8-b84e-54b5f23988ad', 80, 'e25e9627-d431-4fc3-baae-170222bc3936', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-06 10:41:23.524812', '2025-11-06 10:43:01.000000'),
('713ff154-c4f1-4751-926d-06759fca97af', 3, 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.145840', '2025-11-17 16:01:46.000000'),
('7639533d-737a-49e4-a0a1-09367734bdaf', 3213, '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.148694', '2025-11-17 16:01:46.000000'),
('85a2be11-8e56-46f6-b07c-cdf4100333db', 10, '02dd05f1-cd36-4f68-b3cd-2208b41ee451', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-06 10:41:37.104294', '2025-11-06 10:41:37.104294'),
('8eca0041-83cd-4923-8f43-bc7390dc4615', 3, '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.116118', '2025-11-17 16:01:46.000000'),
('97d1e50a-6ac4-4b0f-8634-565fe8306924', 1, 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.964500', '2025-11-13 11:21:32.000000'),
('9dd3005c-5d93-4069-82db-7d3351baed2a', 1, '64a8a84c-e9e7-47f3-9419-3a18cd595157', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.954665', '2025-11-13 11:21:32.000000'),
('a41e81cf-29d7-4a26-88ce-3ae8801d1cab', 1, 'e47b6419-3c22-4423-8f44-609431702278', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.967484', '2025-11-13 11:21:32.000000'),
('ac37e8b0-f765-4d89-8e58-25e0f8bd982a', 2, 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.969022', '2025-11-05 14:23:57.000000'),
('b2570168-9a1e-4b1c-8c05-7763c2973e42', 1, 'abca8fbe-753a-458a-863b-48fc46c255e4', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.957882', '2025-11-13 11:21:32.000000'),
('be831c7a-4d5b-4a14-a710-36a789c4acc3', 3, '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-05 10:35:28.450343', '2025-11-17 16:01:46.000000'),
('c572b833-6d7c-49e4-af26-00de454d9809', 1, '069656e3-ffe9-4e16-bbd3-21747fc1a182', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.938526', '2025-11-13 11:21:32.000000'),
('ce2781ec-9c84-41db-a2f6-d0b36cdb0264', 210, '34fcc870-59be-4798-b0ea-d949c63c7ee9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-05 10:35:28.458603', '2025-11-17 16:01:46.000000'),
('e03558b4-d69c-4151-ae17-94029b58ca76', 1, '330179f7-4225-4c53-bcce-fa4e78f33b08', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:23:57.892920', '2025-11-13 11:21:32.000000'),
('e1b23a80-1541-4776-b6a5-b400656f69d5', 3, 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-05 10:35:28.465937', '2025-11-17 16:01:46.000000'),
('e5317f5d-0fe3-43e9-a6a5-605b333f6cab', 1, 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.944108', '2025-11-13 11:21:32.000000'),
('ebacee99-a8a1-42e4-b660-5e434ec32506', 1, 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.950834', '2025-11-13 11:21:32.000000'),
('f02859e9-8c52-4929-97c5-553d957953b9', 3, 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-10-30 13:27:39.133132', '2025-11-06 10:41:23.000000'),
('f3b23315-7da0-41b4-9af8-abc537def733', 212, 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '2025-11-04 09:58:51.887244', '2025-11-17 16:01:46.000000'),
('ffe05d47-7a66-4beb-9af2-e058d74cfa72', 1, '32e1075b-7bcf-4add-8a4e-253064392338', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '2025-11-05 14:18:10.940920', '2025-11-13 11:21:32.000000');

-- --------------------------------------------------------

--
-- Estrutura para tabela `estoque_movimentacoes`
--

CREATE TABLE `estoque_movimentacoes` (
  `id` varchar(36) NOT NULL,
  `contexto` varchar(20) NOT NULL,
  `tipo` enum('entrada','saida') NOT NULL,
  `quantidade` float NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `product_id` varchar(36) DEFAULT NULL,
  `school_id` varchar(36) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `motivoCategoria` enum('ajuste','perda','uso_interno','vencimento','outro','entrada_solicitacao','saida_solicitacao') NOT NULL,
  `motivoObservacao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `estoque_movimentacoes`
--

INSERT INTO `estoque_movimentacoes` (`id`, `contexto`, `tipo`, `quantidade`, `created_at`, `product_id`, `school_id`, `user_id`, `motivoCategoria`, `motivoObservacao`) VALUES
('00267dbf-6787-433a-bc82-aa737f35dd9e', 'prefeitura', 'entrada', 100, '2025-11-06 10:35:25.057806', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('00e36f41-ccb3-45e6-8cf0-a2ff684ee482', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.765757', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('019c85df-f130-429f-89c1-27b29ffc318a', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.859805', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('0316e75f-8c94-4b2d-bec0-2ab730fe8b9e', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.644198', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('03186498-5387-4792-b0bc-218cc087a0b9', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.729983', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('03246e63-e5cc-497c-9a3b-d5ac4917b82d', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.550779', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('03870587-371f-47b5-b404-c0f9a596c7eb', 'escola', 'saida', 2, '2025-11-11 13:52:32.766605', 'e47b6419-3c22-4423-8f44-609431702278', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'uso_interno', NULL),
('03e6ce1e-d9f1-4941-b297-83cac6c0ee8d', 'escola', 'entrada', 1, '2025-11-17 15:25:55.454088', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('04bf1708-d589-4786-9a08-16e5a0f69504', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.755654', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('053e5a2d-3631-492b-a43d-0e21297a3324', 'escola', 'entrada', 1, '2025-11-17 15:25:55.431819', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('05aac5ae-e15c-4769-a9ee-dd9a9ce1cdb5', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.085698', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('05f272a2-f710-49e6-8f7c-f3778a84fd03', 'escola', 'entrada', 1, '2025-11-06 14:06:32.868593', '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('061fbcfd-b13f-4e11-8f20-868afda0343d', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.289418', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('063f9620-1014-47d9-acb7-4ea7a41974dc', 'prefeitura', 'saida', 7220, '2025-11-06 10:35:39.451510', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('06da5a7e-a25b-4f2f-9ce3-5cbe9b045a0b', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.765090', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('0b413682-2ca7-4c9a-9b07-116b882b7976', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.780930', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('0b6687fe-de72-4617-9159-739927faaa98', 'escola', 'entrada', 1, '2025-11-17 13:33:23.967151', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('0b75508b-e0ba-41fc-b1be-0ef596cb0ada', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.770007', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('0c669c6a-2348-426b-bbb7-4fd83ba22113', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.620811', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('0cb71f5b-88d6-4efd-aafd-6ba321860f08', 'escola', 'entrada', 1, '2025-11-13 11:21:32.587291', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('0e94b272-f5a7-479f-ad0a-02c1cff7f72a', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.778686', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('0f40b40a-606f-4c26-955e-ba8677c8a551', 'prefeitura', 'saida', 19884, '2025-11-17 10:15:30.630807', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('1007b744-d029-4531-8929-7df5f78f955d', 'escola', 'entrada', 1, '2025-11-06 14:06:32.858006', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('12065b15-1aa7-4da4-92cd-43b1214fe169', 'escola', 'saida', 109, '2025-11-06 14:44:21.101662', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'vencimento', NULL),
('128ab334-c7df-47bd-9fd4-d1c1a466bc16', 'escola', 'entrada', 1, '2025-11-17 13:33:23.960716', 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('12996063-c857-430c-a7d4-765c83d9d547', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.183167', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('15054a5e-cfae-4143-a28e-68a0d5bad7b7', 'escola', 'entrada', 1, '2025-11-17 15:25:55.426019', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('150ad5bc-0de3-4d3e-ab94-f49d071cccc4', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.138242', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('154b9dc7-4e54-4d3b-9820-57757f7e04af', 'escola', 'saida', 2, '2025-11-11 13:53:11.445972', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'perda', NULL),
('15deebfe-15e3-4380-9ab6-a661b1b496b0', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.746350', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('16ec3880-0a38-4c45-a051-17e8d72d4824', 'prefeitura', 'saida', 630, '2025-11-06 10:52:29.267357', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'outro', 'teste'),
('174abae9-3c47-41ff-b522-fc924c1647c2', 'prefeitura', 'saida', 7839, '2025-11-06 16:07:17.062503', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'perda', NULL),
('1755093d-b955-46ad-9d16-33b6c11fa68f', 'escola', 'saida', 221, '2025-11-11 13:54:33.543836', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'outro', 'teste'),
('17fb1839-2f0d-4dcd-a15b-08614fb24bc9', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.596432', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('1804abc8-10a1-47e0-9a0d-2d25e26999d0', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.778315', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('184cec66-2770-411b-bb9e-8d98d13f2565', 'prefeitura', 'entrada', 900, '2025-11-06 12:03:29.244279', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha'),
('19be2195-99c4-4388-9be3-bdbabf05400d', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.786563', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('1a5df1d6-d608-4c2b-8a79-fdbbbb114bf7', 'prefeitura', 'saida', 11822, '2025-11-17 10:15:36.054869', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('1b04d73a-7cf1-4979-824b-d43a8bfb3741', 'escola', 'saida', 2, '2025-11-11 13:53:50.401300', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('1cd7a419-f7d5-469b-ba8e-0f7dbb9e1293', 'prefeitura', 'saida', 19829, '2025-11-17 10:15:23.388571', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('1db32f96-c54d-41a4-a8de-a97e0109e152', 'escola', 'saida', 2, '2025-11-11 13:53:06.659781', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('1de51952-3999-4fac-baac-5856e6ec2b96', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.919404', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('218b08bc-ed3a-42c9-af99-0d3c4c07faad', 'prefeitura', 'saida', 7883, '2025-11-17 10:15:07.221000', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('22cbc16c-3a6c-4657-8cd8-d23284abffc3', 'escola', 'entrada', 200, '2025-11-06 13:59:37.415433', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 06a3171a'),
('23ab2b92-fe09-4b6e-87fc-32f9e90cac10', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.763489', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('248e6949-e8e4-48e3-8b2a-4dba44e3f129', 'escola', 'entrada', 1, '2025-11-17 15:25:55.424401', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('2507d6f6-0bad-481a-b97a-41b69a392017', 'prefeitura', 'entrada', 1000, '2025-11-06 12:34:10.421819', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +1000)'),
('25093680-723f-4d1e-8d9a-1c47368e14fa', 'escola', 'entrada', 1, '2025-11-17 15:25:55.435815', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('255238b4-5e78-4bb5-adb7-2fe1b93d7b5c', 'escola', 'saida', 2, '2025-11-11 13:52:54.952249', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'outro', 'teste'),
('2622e35e-b518-4d38-8d20-559a41d493de', 'escola', 'entrada', 1, '2025-11-06 14:06:32.869882', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('2629d833-12b5-4340-9c6d-68de32c56bd4', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.156672', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('26516236-b1f5-462b-abf8-38f2c5f3bdf2', 'prefeitura', 'entrada', 6000, '2025-11-07 10:46:19.256366', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +6000)'),
('265a7e28-eef9-4852-8785-cfbed927eee7', 'escola', 'entrada', 1, '2025-11-06 14:05:02.780141', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('2794c2f3-77a1-43e0-8f26-845331e415fb', 'escola', 'entrada', 1, '2025-11-13 11:21:32.577233', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('284ee4e1-715d-4ab3-b2c4-7f822cb419cf', 'escola', 'entrada', 1, '2025-11-17 16:01:46.235339', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('2874f7db-c7e2-47aa-862b-24074a21944c', 'escola', 'saida', 426, '2025-11-11 13:54:44.342857', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'vencimento', NULL),
('28da1b64-ca3a-435d-a378-153aab70ef81', 'escola', 'entrada', 1, '2025-11-06 14:06:32.865253', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('2912fd35-46f7-4d2d-b419-abcd42a8f8bf', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.855278', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('291f5bf7-f3d7-4a5d-976f-a954087cfe8a', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.483602', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('2b683c9b-55e4-4217-8d60-0ae951ad6e79', 'prefeitura', 'entrada', 100, '2025-11-17 11:11:34.432804', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +100)'),
('2bdf5080-0b62-4b7a-ad6f-8d6b330d1e38', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.034426', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('2c96c69b-af23-49e2-bd53-7ce58cbd4472', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.754396', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('2d0f3d44-5709-4ce7-84aa-7716e08935fa', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.703320', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('2e1de011-f77a-4a4e-a920-40a7e361d22e', 'prefeitura', 'saida', 7697, '2025-11-17 10:16:04.546579', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('2ecd95b3-3311-458c-a2d2-bd2317e1f0b1', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.787774', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('30b2d274-cc44-493d-b67a-cfa6efaf0e76', 'escola', 'saida', 1, '2025-11-11 13:53:35.932568', 'abca8fbe-753a-458a-863b-48fc46c255e4', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('312d4578-4733-4e38-9168-6a196c8e3172', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.923764', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('31ccf81a-0fb5-44bb-b85b-dba89f0e013e', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.083908', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('31e26dd6-d85a-4032-9f40-8ebf8a385e53', 'prefeitura', 'saida', 100, '2025-11-06 14:13:40.102601', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 9941dc5b)'),
('33e709d4-0160-4213-bbd3-5b605af11ff7', 'escola', 'entrada', 1, '2025-11-17 15:25:55.427450', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('3491c0d1-fcff-4664-9ca6-784c83794354', 'prefeitura', 'saida', 1, '2025-11-06 14:13:40.119887', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 9941dc5b)'),
('355d34f1-45e5-44eb-8c1e-f375ef8cfc6e', 'escola', 'saida', 95, '2025-11-06 14:09:53.904835', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'vencimento', NULL),
('366b9ea5-9089-4c85-a433-46885b2f919f', 'escola', 'entrada', 1, '2025-11-17 15:25:55.433575', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('36c2f2a0-5213-4b17-ae9c-9c86fa104e0e', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.928677', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('371a1a08-c881-4b9f-af4b-16d2bfc8cfd7', 'escola', 'entrada', 1, '2025-11-17 13:33:23.973120', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('37ae16a1-642f-4fe3-872c-f7c1a95d8223', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.069139', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('37f825b5-e638-4a6a-abac-4718b072282d', 'escola', 'entrada', 1, '2025-11-17 13:33:23.977140', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('38e3972d-9150-47af-afd3-0c164674ba24', 'prefeitura', 'entrada', 6000, '2025-11-06 13:49:47.226850', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +6000)'),
('390f0296-5e2e-4f7a-a164-ca8045547080', 'escola', 'entrada', 1, '2025-11-06 14:06:32.871361', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('393fd8c1-9233-473b-ac1a-68685a2e827d', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.073918', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('3949c5d8-db8b-4dcc-9ca2-a2b4d9427a24', 'prefeitura', 'saida', 1, '2025-11-17 15:58:29.913091', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('3a13d90f-96ad-416e-a18f-f97bbb7679b7', 'escola', 'entrada', 1, '2025-11-17 13:33:23.965253', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('3baccbed-1259-48aa-a31f-62363a061bcb', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.773061', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('3d53b815-7249-4a12-b05a-cf22f53c4d44', 'escola', 'entrada', 1, '2025-11-06 14:05:02.757341', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('3e49dce3-b5d5-429c-aa3d-60523792c4a4', 'escola', 'entrada', 1, '2025-11-06 14:06:32.872093', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('3ef1b1b5-ca2a-4800-a098-217471af1f7d', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.312896', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('4060dd64-9c02-44c0-ba41-d0a59f07d5e2', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.758617', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('40da8bf8-caab-443c-abf0-cfd14e24ca9a', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.822934', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('4313ccee-e793-40ee-9f46-e8cbf340744f', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.135403', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('432a7fe3-9329-4788-8ecb-f8e30fff3987', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.736096', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('434d70e9-dcf0-4171-a631-031faafbf2e4', 'escola', 'entrada', 1, '2025-11-17 13:33:23.970800', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('43590249-39fd-4b82-bdbf-4f138e0e7ecd', 'escola', 'entrada', 1, '2025-11-06 14:14:11.428609', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 9941dc5b'),
('436611f2-6043-40ee-8ca0-307afc3aa2e2', 'prefeitura', 'saida', 1996, '2025-11-13 14:50:54.385166', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'outro', 'teste 13/11/2025'),
('4431eeae-0dec-4844-8c51-288917c2b7f9', 'prefeitura', 'saida', 1, '2025-11-17 15:58:29.868007', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('451960a1-7af2-41f5-a0a2-e2f5035e8f2a', 'escola', 'saida', 3, '2025-11-11 13:53:01.573304', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('46c86c87-ffe8-4296-8d37-c642edee4f45', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.179159', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('46e07410-0b8c-4899-b2c7-7c7656db36cd', 'prefeitura', 'saida', 3831, '2025-11-17 10:15:59.442631', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('4729a89d-4079-4f9e-91c7-5414deab5bef', 'escola', 'entrada', 1, '2025-11-17 16:01:46.250708', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('477f490d-ad3e-4f11-bd70-9a1285fe03fd', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.173338', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('4a87b9f9-d18f-45ff-aac7-9eba3e250230', 'prefeitura', 'saida', 9884, '2025-11-17 10:15:55.187043', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('4ab8d062-2bc5-4113-8f0c-809938c0b5a3', 'escola', 'entrada', 1, '2025-11-13 11:21:32.579233', 'e47b6419-3c22-4423-8f44-609431702278', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('4bf25e0a-1292-4efe-8c53-c8f07eeb731b', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.187240', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('4d9e6d3c-6e50-4774-ad1d-42704607972d', 'escola', 'entrada', 1, '2025-11-06 14:06:32.869247', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('4f3da16b-cbd7-4eeb-872e-c91339e2d612', 'escola', 'entrada', 1, '2025-11-06 14:06:32.855229', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('506c9c3e-61ce-4a9f-9637-9df436a39663', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.768451', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('51eef897-d691-4160-ba1f-0cfcbd51e39f', 'escola', 'entrada', 1, '2025-11-17 13:33:23.975846', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('5211c929-2940-4347-b9a7-c68c886ffbc8', 'escola', 'entrada', 1, '2025-11-17 15:25:55.422406', '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('5284132a-6ebf-48f6-aa18-9c35e9e59f1b', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.319621', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('52b6186a-0a17-428b-bb88-08d631673faa', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.913307', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('5387f2bf-a512-4c42-b312-ad3087f50d09', 'escola', 'entrada', 1, '2025-11-17 16:01:46.238777', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('5504272a-5a8c-4998-8a9a-3259e02362d6', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.297747', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('56163849-1cab-46bb-b7ac-1db61ba37280', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.739203', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('576500da-4394-414e-acc6-ef15ec12ee63', 'prefeitura', 'entrada', 1000, '2025-11-06 13:49:33.564884', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +1000)'),
('57ff0d27-af92-4f66-b979-3e37f167c565', 'prefeitura', 'saida', 5998, '2025-11-17 10:15:01.588072', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('59dc454f-c7e7-432b-a4ce-cbb258b9a208', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.773506', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('5a5958f9-bfe9-4d14-90f4-ff001c9d58f7', 'prefeitura', 'entrada', 1000, '2025-11-06 13:48:58.850330', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +1000)'),
('5aac07e6-04b8-4494-abea-03396f2c7ff8', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.166798', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('5ad2f3b5-c0a3-4a9b-92f8-1e25e20c5a35', 'prefeitura', 'saida', 1, '2025-11-17 15:58:29.924906', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('5ad2f5ff-1176-434c-a6b4-59a5cd0e92b7', 'escola', 'entrada', 1, '2025-11-06 14:05:02.756117', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('5e5a0c52-517c-40ba-a991-91f4800d2294', 'escola', 'entrada', 1, '2025-11-17 16:01:46.245523', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('5f03d758-1e96-4b5b-a72a-e33efb24dfb9', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.781989', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('620f3010-59e5-4dc9-a267-e10bf533ef53', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.273613', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('62748af5-0608-432c-861a-94c027a6eb5d', 'prefeitura', 'entrada', 300, '2025-11-17 11:11:34.567156', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +300)'),
('62764eb3-3986-4fda-89dd-9747669cb8db', 'escola', 'entrada', 1, '2025-11-17 13:33:23.981306', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('62c67411-5630-4de1-9835-786843e127f5', 'escola', 'entrada', 1, '2025-11-17 16:01:46.249596', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('6394e3e0-fc1e-4583-963b-b75669fa4f71', 'escola', 'entrada', 1, '2025-11-06 14:05:02.774817', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('63985201-3fdb-49ae-974d-5908756e08ab', 'prefeitura', 'saida', 14828, '2025-11-17 10:15:40.325124', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('647ccd00-848a-4b75-aa10-38f70ffa48e6', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.061862', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('649295f1-1b69-43ab-a1f9-63d8022de80d', 'escola', 'entrada', 99, '2025-11-06 10:42:15.184244', 'e25e9627-d431-4fc3-baae-170222bc3936', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('67e41f13-34ce-407d-ad39-2c48a0461b51', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.720511', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('67faa9ad-00f6-4a53-97c3-f3153a1fe7ba', 'escola', 'entrada', 100, '2025-11-06 14:14:11.417687', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 9941dc5b'),
('69653a42-c5d9-43bc-9f81-27343ef0addd', 'escola', 'entrada', 1, '2025-11-13 11:21:32.598379', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('6a7c01c5-9bb6-4103-927f-641904c31f0f', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.063833', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('6a8ea777-883d-4367-abb0-6b1ad13e9020', 'prefeitura', 'saida', 1, '2025-11-17 15:58:29.892399', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('6b96bf21-1ddd-483c-a2c8-99e671a96691', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.140419', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('6ba9d53a-263c-4e84-b68f-e097cafb4235', 'prefeitura', 'saida', 14884, '2025-11-17 10:15:45.111134', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('6bb40ba8-8d4f-4c4b-81db-892ff0ee1095', 'escola', 'entrada', 1, '2025-11-06 14:06:32.852842', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('6dcdd281-a94b-4344-ac0c-bdb631f3e6a8', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.816360', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('6ec4e20e-d1d6-4a28-8939-850bd558597d', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.027040', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('6ed20ae6-82f6-43e4-a265-25f8aee33eab', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.799267', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('6f85468c-2c14-471f-9f8f-363489698450', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.741360', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('72415529-d7a7-43d6-9f8f-0539e418b2d2', 'escola', 'entrada', 1, '2025-11-13 11:21:32.612165', 'abca8fbe-753a-458a-863b-48fc46c255e4', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('72a91358-0d28-4ab7-aa1c-2d7f357aad18', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.657973', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('73848b43-c72d-4227-bf27-3abeee5a1e0b', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.734171', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('746c18b6-1602-4214-9a69-8044276cb3f4', 'escola', 'entrada', 1, '2025-11-17 13:33:23.974390', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('74e537e0-5ef1-4dae-9a8c-7f8af634eb4d', 'prefeitura', 'entrada', 100, '2025-11-17 11:11:34.536944', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +100)'),
('75b7aba0-5b6f-4f6d-83ca-955b62109a61', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.130075', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('75fdbad5-3d47-4906-bd46-f57799129f44', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.843368', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('77827178-f0d6-4404-a302-74f456c99547', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.777291', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('77fb384e-fb67-4ace-ac73-11f991492555', 'prefeitura', 'saida', 7783, '2025-11-17 10:16:08.804374', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('788b80cf-8f57-493e-9bfd-d67be17e797c', 'prefeitura', 'saida', 1, '2025-11-06 14:13:40.113391', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 9941dc5b)'),
('7910182c-a41d-4bd5-b710-994d1420d1dc', 'escola', 'entrada', 1, '2025-11-17 16:01:46.246589', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('79594946-b46d-4381-b360-a1da0e73f4bb', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.795780', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('798f9f3c-5472-4532-868f-84afdde5886f', 'prefeitura', 'saida', 1, '2025-11-06 10:52:59.651873', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'perda', NULL),
('79938946-82a9-4f20-9654-d3e4ae8ffb99', 'prefeitura', 'saida', 59999, '2025-11-17 10:15:18.285199', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('79dacac0-fe19-49cb-92b0-7c06be05fd9d', 'escola', 'entrada', 1, '2025-11-17 13:33:23.979271', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('7c1a845d-f005-401b-8ba9-67b3a135a430', 'escola', 'saida', 2, '2025-11-11 13:53:44.896616', '069656e3-ffe9-4e16-bbd3-21747fc1a182', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'uso_interno', NULL),
('7d77e489-ad39-40de-9fc5-03b9b00b8192', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.730076', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('7f373a67-fb29-4b1e-b3f9-aef7d8aa75e5', 'escola', 'entrada', 1, '2025-11-17 16:01:46.242221', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('808d3a71-c15b-4c16-a230-85d585838af4', 'escola', 'entrada', 10, '2025-11-06 10:41:37.096330', '02dd05f1-cd36-4f68-b3cd-2208b41ee451', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('80a4bfa2-4e5f-49f7-836c-602cf4e292fc', 'escola', 'saida', 2, '2025-11-11 13:53:16.373247', '32e1075b-7bcf-4add-8a4e-253064392338', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'ajuste', NULL),
('80db1765-15a3-4394-a2d2-c0406fee3e8f', 'prefeitura', 'entrada', 1, '2025-11-06 11:52:26.497632', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('83416492-e6f7-408a-825a-ce71dee8f2af', 'escola', 'entrada', 1, '2025-11-17 16:01:46.236051', 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('84cc1f09-b1d0-4276-b7e4-8c9ee1f3ee72', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.809589', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('84d8c46b-c47d-45bf-ac68-66f11a9e3da8', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.141710', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('888ce8b5-73f4-4503-bb03-3de44db4a6b7', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.126420', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('8a5a83b3-7c25-46ff-a0ad-07b7a5aa90c2', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.751069', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('8a99e21b-96ba-43cc-abef-77b05b6f53a5', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.849233', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('8af64a54-42c4-4a5d-b6d9-669da958804b', 'escola', 'entrada', 1, '2025-11-17 15:25:55.434971', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('8c9244fe-c1e2-45f8-8a49-710d2f9da515', 'escola', 'entrada', 1, '2025-11-06 14:05:02.777204', 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('8ebe4977-c8ad-4ef9-bc33-7268febbddec', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.115155', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('8f4dfdb9-c24b-43d0-8913-8df2f7e0ab84', 'prefeitura', 'saida', 1, '2025-11-06 14:13:40.128633', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 9941dc5b)'),
('8fee4610-4d53-4eb8-acf5-fc5455b1efba', 'prefeitura', 'entrada', 1000, '2025-11-06 12:33:57.069151', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +1000)'),
('90fbccfc-eb8d-457f-bec1-03abbef0c895', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.897939', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('91736f7b-fc6c-4316-b4c8-a468fdd95855', 'prefeitura', 'saida', 1, '2025-11-17 15:58:29.952900', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('91acf4af-a6ca-45cf-8691-ac809d779b3f', 'prefeitura', 'entrada', 90, '2025-11-06 12:01:46.739705', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha'),
('91bb6145-6be7-4df1-b322-4f6feb48933f', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.190852', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('951b23c5-64af-4dfe-a069-d4be20287cd8', 'escola', 'entrada', 1, '2025-11-17 16:01:46.243604', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('95360de5-35cd-4fe7-9437-5b2aa4592463', 'escola', 'entrada', 1, '2025-11-17 13:33:23.969651', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('95636c86-f95b-4516-aebe-903ab1422d4e', 'escola', 'entrada', 1, '2025-11-17 15:25:55.429288', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('95738487-a3a5-412b-abd4-7a770f7b1101', 'prefeitura', 'saida', 9925, '2025-11-06 11:51:40.119244', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('9708e0d5-9853-4f22-abf3-f1c196b6bc56', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.791879', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('9750ce39-227c-43b3-95d6-085e82916494', 'escola', 'entrada', 1, '2025-11-17 16:01:46.248529', '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('97b4af97-8e0c-4768-8879-f2132f3d60d0', 'escola', 'entrada', 1, '2025-11-13 11:21:32.597351', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('988407fc-9f79-4e54-9bbd-e5c3a65a3fb3', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.056212', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('98e97370-7688-4061-93d6-39bcc1fad4d7', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.338918', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('9a3a6071-1290-4332-ae18-7f2c5a2ac078', 'escola', 'entrada', 1, '2025-11-06 14:14:11.421523', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 9941dc5b'),
('9a41362f-c366-4292-b204-3a69faff0089', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.038872', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('9afa7b7b-4a4a-46d4-b006-029f618e366e', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.712598', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('9bc437aa-6646-471b-be83-358943a6bafb', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.087759', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('9c393ae1-d489-41e5-941d-ea87cf64ac0e', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.197006', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('9cc2210b-63ad-436e-8cab-6531fa7e279b', 'escola', 'saida', 213, '2025-11-11 13:54:07.077295', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'uso_interno', NULL),
('9f178f5d-59b7-458f-b623-8c986a6008d4', 'escola', 'entrada', 1, '2025-11-06 14:06:32.850779', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd');
INSERT INTO `estoque_movimentacoes` (`id`, `contexto`, `tipo`, `quantidade`, `created_at`, `product_id`, `school_id`, `user_id`, `motivoCategoria`, `motivoObservacao`) VALUES
('9fe003f1-e36b-4617-9881-291fe9e73c34', 'escola', 'entrada', 1, '2025-11-17 15:25:55.456157', 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('a0dd3714-6720-459f-a462-734605029c36', 'escola', 'entrada', 1, '2025-11-13 11:21:32.580581', '64a8a84c-e9e7-47f3-9419-3a18cd595157', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('a2ee7459-94f9-4b14-9e64-69c07942275a', 'prefeitura', 'saida', 4882, '2025-11-17 10:15:51.026213', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('a4412c00-cc99-44de-ac51-101895794b07', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.780048', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('a4ae612a-f97d-4bd8-b559-edff69b99511', 'escola', 'entrada', 1, '2025-11-17 16:01:46.236739', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('a55a00af-9e79-4208-b9ae-89198edb35e8', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.335558', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('a679c9ca-9681-4a6b-89ca-56e3d3baa6a1', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.831685', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('a6acfbeb-bc7f-44ee-a977-04e7e3b70693', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.790841', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('a6c15ccf-a556-4edb-9173-05c4d56913f5', 'escola', 'saida', 178, '2025-11-11 13:54:25.305520', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'perda', NULL),
('a796ecbb-9c03-4109-94ee-5db3424e5cf2', 'prefeitura', 'saida', 1000, '2025-11-13 14:52:04.704715', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('a8588a6e-b5d2-47bf-8180-087116bf9289', 'escola', 'entrada', 1, '2025-11-17 13:33:23.968241', '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('a9188dad-812a-4625-9995-a387bef4ce54', 'escola', 'entrada', 1, '2025-11-06 14:06:32.856727', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('a9c92c5b-a254-4764-aaf3-056c9994e1ae', 'prefeitura', 'entrada', 100, '2025-11-17 11:11:34.582747', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +100)'),
('aa510f8d-a323-4429-b543-2c69a5cd82bc', 'escola', 'entrada', 1, '2025-11-13 11:21:32.596199', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('ac8a762d-d817-4550-8668-242a1fda57d0', 'escola', 'saida', 2, '2025-11-11 13:53:40.248442', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('acb9c6ea-cfa9-4522-9066-f8c345ff0cb9', 'escola', 'entrada', 98, '2025-11-06 10:43:42.928927', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('ad362d01-46ed-4370-910f-fe4963cdab2a', 'escola', 'entrada', 1, '2025-11-17 13:33:23.971993', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('ae4146a1-beae-43c6-8374-1d1de823f28a', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.784042', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('ae4c9425-9e9c-45c6-a8f7-f7250e01c5f7', 'escola', 'entrada', 1, '2025-11-13 11:21:32.593051', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('b0ca5821-c7d8-4753-99fc-60cd9e306fd5', 'escola', 'entrada', 100, '2025-11-06 10:42:08.623038', 'dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('b17f1d22-36cc-43c0-8d0c-86edb834b068', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.043334', '34fcc870-59be-4798-b0ea-d949c63c7ee9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('b2ecd5cd-7a8f-47b2-9d93-7527f01f40d9', 'escola', 'entrada', 1, '2025-11-06 14:05:02.789067', '32e1075b-7bcf-4add-8a4e-253064392338', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('b4918c0b-19ff-4a5f-8bb6-12a7ed9fd6eb', 'prefeitura', 'entrada', 300, '2025-11-17 11:11:34.501983', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +300)'),
('b51fa684-7b65-497a-9db9-152d56025d3a', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.802653', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('b661ab43-48bf-4088-b0e7-1aaf181d1b79', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.846637', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('b6f8b57f-e757-4cab-bc8f-2f1bdaceb39c', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.304779', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('b775671b-5e64-4e67-8177-ba4b6a483ef9', 'prefeitura', 'entrada', 100, '2025-11-06 10:46:57.277242', 'dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('b95d50f3-c395-4d95-af0e-2b30f08aa98a', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.634528', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('ba3af74b-1c2d-4417-bc98-ef28d1165d57', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.194326', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('bba8985d-cf83-4f39-962e-e74a1f04b715', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.874675', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('bd3467be-9afe-4647-91ba-b9f1da4edc8c', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.786947', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('bd6253ad-1af2-4cd9-a595-5770e33e9cbd', 'escola', 'saida', 208, '2025-11-11 13:54:11.639881', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'vencimento', NULL),
('bdcbffca-cb6a-452a-aa42-3d4028bb643b', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.308047', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('bdd7e859-2e37-4a36-9228-8c4991145762', 'escola', 'entrada', 1, '2025-11-17 13:33:23.978212', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: fa2e273a'),
('c298cea8-23d4-4f30-95fa-9d28e14c08c1', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.932725', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('c4c75eff-8ad9-41d9-ac4a-6820dd629312', 'escola', 'entrada', 1, '2025-11-13 11:21:32.594724', '511430ef-91be-4857-91cd-22762429a2e6', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('c4cc81f7-99dd-44d5-9032-6b770023869e', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.127351', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('c507cb30-3aad-48dd-b412-b1ffe0b66019', 'prefeitura', 'entrada', 200, '2025-11-17 11:11:34.518887', 'e47b6419-3c22-4423-8f44-609431702278', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +200)'),
('c6226f39-3eae-4a0c-b3db-da61879d57c3', 'prefeitura', 'saida', 1, '2025-11-17 16:13:21.794633', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 75c7ad10)'),
('c83e72ae-722a-4b2e-b1c9-0bd4422a3d69', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.767064', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('cab3e426-b1c1-4f5b-a310-961c6126fa3d', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.327445', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('cac5b0a9-ae75-4605-a289-4c67c4c0a613', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.092073', '980c95b2-9fd8-4645-b848-730a5bf0bfff', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('cbb42213-cadb-4f82-bb45-559f5792b5d6', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.809788', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('cbd0a567-8c18-405b-a17c-f40fe66bb3d5', 'escola', 'entrada', 1, '2025-11-17 16:01:46.234421', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('cc4044b6-6d91-4b06-9dbd-7df32ac9505d', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.331063', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('cf81707d-b36d-4a8c-952a-69ef98ca8000', 'escola', 'saida', 2, '2025-11-11 13:53:22.038583', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'perda', NULL),
('cf8f2348-a95e-4fc5-9d0a-d4cb65ac1b27', 'escola', 'entrada', 1, '2025-11-06 14:06:32.858784', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('cfef6590-512d-4ba1-b837-6ab2732a24f0', 'escola', 'entrada', 1, '2025-11-06 14:05:02.765054', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('d0f31da5-831e-4ac8-8137-1c92e2f4aedb', 'prefeitura', 'entrada', 55000, '2025-11-13 15:23:19.135166', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('d2070143-706c-4503-a065-71a8e40404d4', 'escola', 'saida', 2, '2025-11-11 13:53:30.495495', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'vencimento', NULL),
('d2c6fc1c-913c-415e-bf25-a5ec64937f55', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.054241', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('d338d17d-681f-4bac-a77c-95260132a2c0', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.788774', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('d3c89130-265c-40d0-967e-80600ef904ed', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.774137', '069656e3-ffe9-4e16-bbd3-21747fc1a182', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('d472f9b3-9047-4901-afab-b463b0df3bff', 'escola', 'saida', 20, '2025-11-06 10:43:01.183296', 'e25e9627-d431-4fc3-baae-170222bc3936', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('d5fa12d6-f759-4540-8147-f45be15bcebd', 'escola', 'entrada', 1, '2025-11-13 11:21:32.600247', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('d60d1083-5f25-4ffe-92ef-7207b8c361fb', 'prefeitura', 'entrada', 100, '2025-11-06 12:20:00.230255', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('d616f0f7-eca5-4f8f-9b7c-5d08e0414eb2', 'escola', 'entrada', 1, '2025-11-06 14:06:32.851949', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('d790711a-86f1-4b48-8f73-c1004b814eec', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.802686', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('d849068f-007d-4b90-a7a7-641e47f178d8', 'escola', 'saida', 116, '2025-11-11 13:54:38.872335', '980c95b2-9fd8-4645-b848-730a5bf0bfff', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'perda', NULL),
('dd8d0e8f-2dd1-4897-9dea-d75466a1b573', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.769853', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('dd9c648b-1eee-453a-89f5-708b92fd6b02', 'prefeitura', 'saida', 1, '2025-11-06 14:03:33.805981', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 5f8fb4bd)'),
('df2ffd4a-99f6-49fc-b4aa-e314341e1560', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.073419', '79e1e219-cb47-4f3e-b529-68e2e2a98d45', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('df61e9c7-0f01-4250-a50e-3cbb9e7f60f7', 'prefeitura', 'saida', 1, '2025-11-06 10:36:34.709224', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('df66d9dc-ceea-4b98-8704-20847dc609a3', 'escola', 'saida', 1, '2025-11-11 13:53:26.549188', '330179f7-4225-4c53-bcce-fa4e78f33b08', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'perda', NULL),
('e1ad28ee-4307-4c05-837d-f80c45cc7484', 'prefeitura', 'saida', 200, '2025-11-06 13:58:45.667590', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 06a3171a)'),
('e28fde9d-320f-4536-8ad8-5d1bffb989c1', 'prefeitura', 'saida', 1874, '2025-11-17 10:15:13.682428', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'uso_interno', NULL),
('e29a31ff-9896-4785-b1b8-7c56cf1b3c5d', 'escola', 'entrada', 1, '2025-11-17 15:25:55.455120', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('e35ec93e-0732-4956-88b7-b80b70e5280d', 'escola', 'entrada', 1, '2025-11-06 14:14:11.437939', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 9941dc5b'),
('e3b7503b-2c37-4b7c-ac82-6343d1a43c85', 'prefeitura', 'saida', 1, '2025-11-06 14:03:21.828513', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Escola 1 (ID: 1b98cd24)'),
('e4aeec1e-f24b-47ae-93a5-91f8d164466e', 'escola', 'entrada', 1, '2025-11-17 16:01:46.239678', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('e5734341-8dbd-4cf1-a76f-7457e402d9f4', 'escola', 'entrada', 1, '2025-11-17 15:25:55.436635', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('e6380707-3bd9-4a71-9598-318b77ddfdfc', 'escola', 'saida', 210, '2025-11-11 13:54:19.281893', '511430ef-91be-4857-91cd-22762429a2e6', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'ajuste', NULL),
('e6ebd5b8-561d-4da7-ba29-48ee1b9101b7', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.323426', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('e726461b-517c-494b-a5b6-5a4b0102c205', 'prefeitura', 'saida', 1, '2025-11-17 15:58:30.079375', '330179f7-4225-4c53-bcce-fa4e78f33b08', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 1b8aac33)'),
('e7acc0c9-7839-4e41-be5b-4e1d2f2c9d26', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.797796', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('ec28c4ec-d32f-40ea-8dc6-91564031f78b', 'escola', 'entrada', 1, '2025-11-17 15:25:55.443373', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: f06aa734'),
('ecad682c-8f1b-4fb8-af99-1bc22fe68dc1', 'prefeitura', 'saida', 1, '2025-11-13 11:13:12.760518', '511430ef-91be-4857-91cd-22762429a2e6', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: b7f551fd)'),
('ed466b8e-d2e6-4001-9d4f-ff11e3f5340e', 'prefeitura', 'entrada', 100, '2025-11-06 10:45:38.951722', '02dd05f1-cd36-4f68-b3cd-2208b41ee451', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', NULL),
('f0ac4952-be8e-41ab-b440-02ec049f2e0f', 'escola', 'entrada', 1, '2025-11-13 11:21:32.601426', '34fcc870-59be-4798-b0ea-d949c63c7ee9', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('f184a0c1-a8ed-4d19-ad23-5b5ad103b5de', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.131686', '32e1075b-7bcf-4add-8a4e-253064392338', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('f1ab81a4-2e50-46f5-b502-215519e561f8', 'escola', 'entrada', 1, '2025-11-06 14:06:32.867601', 'abca8fbe-753a-458a-863b-48fc46c255e4', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 5f8fb4bd'),
('f1c8a259-a640-4d1f-9164-6ab03b7552a8', 'escola', 'entrada', 1, '2025-11-17 16:01:46.247586', '330179f7-4225-4c53-bcce-fa4e78f33b08', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b8aac33'),
('f49bbae2-dd7d-4359-814d-2736b7c10935', 'escola', 'entrada', 1, '2025-11-06 14:05:02.779031', 'e47b6419-3c22-4423-8f44-609431702278', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'entrada_solicitacao', 'Recebimento da Solicitação ID: 1b98cd24'),
('f54bb327-94ff-433d-9824-0342ac6d9077', 'prefeitura', 'saida', 1, '2025-11-17 16:12:56.122821', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: 69e2de7e)'),
('f556a65b-a597-4467-9094-7f283e97254c', 'prefeitura', 'saida', 1, '2025-11-13 15:42:36.301092', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Monteiro Lobato (ID: 0380cece)'),
('f6b17f4d-e399-41d8-9be7-1fe54dbb1383', 'escola', 'entrada', 1, '2025-11-13 11:21:32.578475', '330179f7-4225-4c53-bcce-fa4e78f33b08', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('f72f5629-d780-45a8-93e4-1dc9cdfba3c1', 'prefeitura', 'saida', 1, '2025-11-17 15:24:55.839408', 'bef0ae2a-e146-49e5-a544-74afb5667e4f', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: f06aa734)'),
('f814fb53-f721-473f-bb30-d034081492ba', 'escola', 'saida', 2, '2025-11-11 13:52:39.750990', '511430ef-91be-4857-91cd-22762429a2e6', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'perda', NULL),
('f8433cb0-d0c1-4f0f-b7b0-6974084b5a6a', 'escola', 'entrada', 1, '2025-11-13 11:21:32.579912', '32e1075b-7bcf-4add-8a4e-253064392338', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'entrada_solicitacao', 'Recebimento da Solicitação ID: b7f551fd'),
('fab766e6-9dac-4cbf-9bf7-5527ba5124ca', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.135050', 'c2566218-7972-4778-bcf3-b5f6e8ed2136', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('fcb83600-534a-4c6a-8895-783b22ce36f2', 'prefeitura', 'saida', 1, '2025-11-17 11:51:43.174529', '64a8a84c-e9e7-47f3-9419-3a18cd595157', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'saida_solicitacao', 'Saída p/ Solicitação Escola: Bento Mussurunga (ID: fa2e273a)'),
('fd262b23-5ed6-4366-b8fb-0dea4a895968', 'prefeitura', 'entrada', 100, '2025-11-17 11:11:34.670186', 'abca8fbe-753a-458a-863b-48fc46c255e4', NULL, '862098b5-c4cd-4879-a8a8-0e6d192e0653', 'ajuste', 'Importação via planilha (Ajuste: +100)');

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

--
-- Despejando dados para a tabela `prefeitura_estoque`
--

INSERT INTO `prefeitura_estoque` (`id`, `quantity`, `product_id`, `created_at`, `updated_at`) VALUES
('12572ee6-d16d-4af6-a15a-bb7c8a06527d', 68, 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1', '2025-10-29 21:51:40.588241', '2025-11-06 10:52:59.000000'),
('287b854d-4180-44d2-bc4f-d878dffb3e96', 195, 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', '2025-10-29 21:52:27.723665', '2025-11-17 16:13:21.000000'),
('40fbbc83-7cd5-4c16-9277-12c7e169535c', 96, 'abca8fbe-753a-458a-863b-48fc46c255e4', '2025-10-29 21:54:07.219198', '2025-11-17 16:12:56.000000'),
('59d02d2d-c502-4cc4-a285-a501990c384b', 195, 'e47b6419-3c22-4423-8f44-609431702278', '2025-10-29 21:52:00.688487', '2025-11-17 16:13:21.000000'),
('611e0609-ef5d-4d83-bcfe-f03a37411c75', 95, '980c95b2-9fd8-4645-b848-730a5bf0bfff', '2025-10-29 21:52:40.696746', '2025-11-17 16:13:21.000000'),
('6439d58e-cb25-4bd7-a738-631dca39f6d6', 195, 'e9a78193-e02b-48a0-803e-f46c17cbe2f8', '2025-10-29 21:53:22.231675', '2025-11-17 16:13:21.000000'),
('6b80af61-7fb5-4a58-9d03-94a95cd65cdd', 99, 'e25e9627-d431-4fc3-baae-170222bc3936', '2025-11-05 16:10:28.854580', '2025-11-06 10:40:13.000000'),
('809a4aae-4ddb-4c1a-8798-6628a7076a76', 100, '02dd05f1-cd36-4f68-b3cd-2208b41ee451', '2025-11-06 10:45:38.956476', '2025-11-06 10:45:38.956476'),
('81055791-2d6b-4a78-82b1-4d15ca469ea3', 0, '7f059474-4f8b-4ddf-9ea5-92ca62c469f5', '2025-11-06 10:35:25.074781', '2025-11-06 12:09:56.000000'),
('92e4cfc2-708d-41ad-8e17-d4597d96f49c', 295, '64a8a84c-e9e7-47f3-9419-3a18cd595157', '2025-10-29 21:51:51.330225', '2025-11-17 16:13:21.000000'),
('a34290a3-8cad-4fe5-9399-1d9fb8cdd62c', 195, '34fcc870-59be-4798-b0ea-d949c63c7ee9', '2025-10-29 21:53:12.939398', '2025-11-17 16:13:21.000000'),
('ad641671-9aff-472a-aa58-567ad0129229', 95, '511430ef-91be-4857-91cd-22762429a2e6', '2025-10-29 21:52:14.837800', '2025-11-17 16:13:21.000000'),
('bea6b8a0-9b5b-45e5-be93-4b3e18c7da08', 100, 'dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9', '2025-11-06 10:46:57.280705', '2025-11-06 10:46:57.280705'),
('d5cabce1-5e8a-491b-98a9-79ebbf2ea80b', 295, '069656e3-ffe9-4e16-bbd3-21747fc1a182', '2025-10-29 21:52:34.857933', '2025-11-17 16:13:21.000000'),
('d7381b06-0096-48b1-8161-3a178aa7577f', 195, '32e1075b-7bcf-4add-8a4e-253064392338', '2025-10-29 21:53:01.247701', '2025-11-17 16:13:21.000000'),
('edff4678-b5c0-46ee-a300-aca19baa98c7', 195, 'bef0ae2a-e146-49e5-a544-74afb5667e4f', '2025-10-29 21:52:47.640288', '2025-11-17 16:13:21.000000'),
('fb921fbf-ad3d-46b1-b241-ab2b73d60c00', 95, '79e1e219-cb47-4f3e-b529-68e2e2a98d45', '2025-10-29 21:51:32.662374', '2025-11-17 16:13:21.000000'),
('fcfb64d7-93f7-460e-9a0f-83773185f5fb', 195, 'c2566218-7972-4778-bcf3-b5f6e8ed2136', '2025-10-29 21:52:53.585535', '2025-11-17 16:13:21.000000'),
('ff5f54e0-20e8-43b5-b906-0874c1dcc21d', 195, '330179f7-4225-4c53-bcce-fa4e78f33b08', '2025-10-29 21:53:33.908095', '2025-11-17 16:13:21.000000');

-- --------------------------------------------------------

--
-- Estrutura para tabela `products`
--

CREATE TABLE `products` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `unit` enum('UN') NOT NULL,
  `min_stock_prefeitura` float NOT NULL DEFAULT 0,
  `min_stock_escola` float NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  `deleted_by_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `products`
--

INSERT INTO `products` (`id`, `name`, `unit`, `min_stock_prefeitura`, `min_stock_escola`, `created_at`, `updated_at`, `deleted_at`, `deleted_by_user_id`) VALUES
('02dd05f1-cd36-4f68-b3cd-2208b41ee451', 'teste', 'UN', 10, 10, '2025-11-06 09:01:53.881802', '2025-11-06 11:17:25.000000', '2025-11-06 11:17:25.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('069656e3-ffe9-4e16-bbd3-21747fc1a182', 'Fubá Mimoso (1Kg)', 'UN', 100, 10, '2025-10-29 16:56:05.145770', '2025-10-29 16:58:22.000000', NULL, NULL),
('32e1075b-7bcf-4add-8a4e-253064392338', 'Óleo de Soja (900ml)', 'UN', 200, 40, '2025-10-29 16:50:54.569925', '2025-10-29 16:57:27.000000', NULL, NULL),
('330179f7-4225-4c53-bcce-fa4e78f33b08', 'Arroz Agulhinha (10Kg)', 'UN', 500, 10, '2025-10-29 16:45:18.855984', '2025-10-29 21:53:57.000000', NULL, NULL),
('34fcc870-59be-4798-b0ea-d949c63c7ee9', 'Ovos (Dúzia)', 'UN', 500, 10, '2025-10-29 17:00:48.082960', '2025-10-29 17:00:48.082960', NULL, NULL),
('511430ef-91be-4857-91cd-22762429a2e6', 'Cenoura', 'UN', 3000, 60, '2025-10-29 21:50:27.500896', '2025-10-29 21:50:27.500896', NULL, NULL),
('64a8a84c-e9e7-47f3-9419-3a18cd595157', 'Batata Inglesa', 'UN', 4000, 80, '2025-10-29 21:50:06.938780', '2025-10-29 21:50:06.938780', NULL, NULL),
('79e1e219-cb47-4f3e-b529-68e2e2a98d45', 'Açúcar Cristal (10Kg)', 'UN', 200, 10, '2025-10-29 16:52:14.751131', '2025-10-30 13:28:32.000000', NULL, NULL),
('7f059474-4f8b-4ddf-9ea5-92ca62c469f5', 'morango', 'UN', 100, 100, '2025-11-06 09:01:45.125437', '2025-11-06 12:32:26.000000', '2025-11-06 12:32:26.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('980c95b2-9fd8-4645-b848-730a5bf0bfff', 'Leite em Pó Integral (380)', 'UN', 150, 15, '2025-10-29 16:55:46.582786', '2025-10-29 16:58:03.000000', NULL, NULL),
('a6a4dc6c-7168-435c-ae90-fc827f5c5cc9', 'Feijão Carioca (1KG)', 'UN', 400, 40, '2025-10-29 16:49:52.912843', '2025-10-29 16:49:52.912843', NULL, NULL),
('abca8fbe-753a-458a-863b-48fc46c255e4', 'Sal Refinado (1Kg)', 'UN', 500, 10, '2025-10-29 16:51:31.177731', '2025-11-05 16:53:09.000000', NULL, NULL),
('b8e45d7c-3a48-4161-9d40-5e19df1a94b1', 'Banana Prata', 'UN', 3000, 50, '2025-10-29 21:50:58.537165', '2025-11-06 11:17:31.000000', '2025-11-06 11:17:31.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('bca5fe8c-1c69-40e7-8527-8f612c793736', 'teste1', 'UN', 0, 0, '2025-11-06 15:48:18.834966', '2025-11-06 15:48:22.000000', '2025-11-06 15:48:22.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('bef0ae2a-e146-49e5-a544-74afb5667e4f', 'Maçã Fuji', 'UN', 3000, 50, '2025-10-29 21:50:48.848428', '2025-11-05 16:24:45.000000', NULL, NULL),
('c2566218-7972-4778-bcf3-b5f6e8ed2136', 'Macarrão Parafuso (1Kg)', 'UN', 300, 30, '2025-10-29 16:50:39.318232', '2025-10-29 16:50:39.318232', NULL, NULL),
('dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9', 'teste31', 'UN', 100, 100, '2025-11-06 09:11:44.088833', '2025-11-06 11:17:22.000000', '2025-11-06 11:17:22.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('e25e9627-d431-4fc3-baae-170222bc3936', 'teste34', 'UN', 100, 100, '2025-11-05 15:10:08.799707', '2025-11-06 10:59:54.000000', '2025-11-06 10:59:54.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('e47b6419-3c22-4423-8f44-609431702278', 'Carne Bovina (Acém moído - 1 Kg)', 'UN', 800, 80, '2025-10-29 17:01:20.215322', '2025-10-29 17:01:41.000000', NULL, NULL),
('e9a78193-e02b-48a0-803e-f46c17cbe2f8', 'Peito de Frango (congelado - 1Kg) ', 'UN', 800, 80, '2025-10-29 16:57:10.757939', '2025-10-29 17:01:36.000000', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `refeicao_products`
--

CREATE TABLE `refeicao_products` (
  `refeicao_id` varchar(36) NOT NULL,
  `product_id` varchar(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `refeicao_products`
--

INSERT INTO `refeicao_products` (`refeicao_id`, `product_id`) VALUES
('11c9b971-9bc7-4e9e-8609-ae91807bda45', '32e1075b-7bcf-4add-8a4e-253064392338'),
('11c9b971-9bc7-4e9e-8609-ae91807bda45', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('11c9b971-9bc7-4e9e-8609-ae91807bda45', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('11c9b971-9bc7-4e9e-8609-ae91807bda45', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('14c82d94-59fe-439b-89bc-4b1cd1879acb', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('14c82d94-59fe-439b-89bc-4b1cd1879acb', '511430ef-91be-4857-91cd-22762429a2e6'),
('14c82d94-59fe-439b-89bc-4b1cd1879acb', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('14c82d94-59fe-439b-89bc-4b1cd1879acb', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('61d7e500-66bf-4526-ba4b-3b51acddafa6', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('61d7e500-66bf-4526-ba4b-3b51acddafa6', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('61d7e500-66bf-4526-ba4b-3b51acddafa6', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('61d7e500-66bf-4526-ba4b-3b51acddafa6', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('7a23415b-b765-4f79-a502-4c88a4c1e20a', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('7a23415b-b765-4f79-a502-4c88a4c1e20a', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('7a23415b-b765-4f79-a502-4c88a4c1e20a', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('7a23415b-b765-4f79-a502-4c88a4c1e20a', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('8c3e6886-45bd-48f8-bcad-9c782b501b77', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('8c3e6886-45bd-48f8-bcad-9c782b501b77', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('8c3e6886-45bd-48f8-bcad-9c782b501b77', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('d3080460-7476-493f-97f0-6f1595fd8cd3', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('d3080460-7476-493f-97f0-6f1595fd8cd3', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('d3080460-7476-493f-97f0-6f1595fd8cd3', 'e47b6419-3c22-4423-8f44-609431702278'),
('d8734088-4199-4ea8-8304-754ba3058f1f', '32e1075b-7bcf-4add-8a4e-253064392338'),
('d8734088-4199-4ea8-8304-754ba3058f1f', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('d8734088-4199-4ea8-8304-754ba3058f1f', '511430ef-91be-4857-91cd-22762429a2e6'),
('d8734088-4199-4ea8-8304-754ba3058f1f', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('d8734088-4199-4ea8-8304-754ba3058f1f', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('d8734088-4199-4ea8-8304-754ba3058f1f', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('d8734088-4199-4ea8-8304-754ba3058f1f', 'e47b6419-3c22-4423-8f44-609431702278'),
('e173bfd9-51bd-4e86-b828-9d2f06168848', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('e173bfd9-51bd-4e86-b828-9d2f06168848', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('e173bfd9-51bd-4e86-b828-9d2f06168848', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('e2729ea3-f8f1-4802-8cb1-8e0ce23fae70', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('e2729ea3-f8f1-4802-8cb1-8e0ce23fae70', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('e2729ea3-f8f1-4802-8cb1-8e0ce23fae70', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('e2729ea3-f8f1-4802-8cb1-8e0ce23fae70', 'e47b6419-3c22-4423-8f44-609431702278'),
('fcc37782-d532-4733-a645-b849d3aba298', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('fcc37782-d532-4733-a645-b849d3aba298', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('fcc37782-d532-4733-a645-b849d3aba298', '79e1e219-cb47-4f3e-b529-68e2e2a98d45');

-- --------------------------------------------------------

--
-- Estrutura para tabela `refeicoes`
--

CREATE TABLE `refeicoes` (
  `id` varchar(36) NOT NULL,
  `diaSemana` enum('segunda','terça','quarta','quinta','sexta') NOT NULL,
  `tipo` enum('manha','tarde') NOT NULL,
  `description` text NOT NULL,
  `cardapioId` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `refeicoes`
--

INSERT INTO `refeicoes` (`id`, `diaSemana`, `tipo`, `description`, `cardapioId`) VALUES
('11c9b971-9bc7-4e9e-8609-ae91807bda45', 'quinta', 'manha', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('14c82d94-59fe-439b-89bc-4b1cd1879acb', 'terça', 'manha', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('61d7e500-66bf-4526-ba4b-3b51acddafa6', 'quarta', 'manha', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('7a23415b-b765-4f79-a502-4c88a4c1e20a', 'quarta', 'tarde', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('8c3e6886-45bd-48f8-bcad-9c782b501b77', 'sexta', 'tarde', 'teste', 'd9d01dc2-9d61-4651-a84e-d126efc30e1e'),
('d3080460-7476-493f-97f0-6f1595fd8cd3', 'quinta', 'tarde', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('d8734088-4199-4ea8-8304-754ba3058f1f', 'terça', 'tarde', 'Teste Tcc', 'a1359c39-3375-42a9-875a-774d2dd9ceb6'),
('e173bfd9-51bd-4e86-b828-9d2f06168848', 'sexta', 'manha', 'teste', 'd9d01dc2-9d61-4651-a84e-d126efc30e1e'),
('e2729ea3-f8f1-4802-8cb1-8e0ce23fae70', 'quinta', 'tarde', 'teste', 'd9d01dc2-9d61-4651-a84e-d126efc30e1e'),
('fcc37782-d532-4733-a645-b849d3aba298', 'quinta', 'manha', 'teste', 'd9d01dc2-9d61-4651-a84e-d126efc30e1e');

-- --------------------------------------------------------

--
-- Estrutura para tabela `schools`
--

CREATE TABLE `schools` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city_id` varchar(36) DEFAULT NULL,
  `numero` varchar(50) DEFAULT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  `deleted_by_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `schools`
--

INSERT INTO `schools` (`id`, `name`, `address`, `city_id`, `numero`, `deleted_at`, `deleted_by_user_id`) VALUES
('430c8fde-ccfb-452a-8570-0c64059b7fdc', 'Bento Mussurunga', 'Avenida 1', '87a6369d-9553-4ef0-8718-5b00be177ef3', '1', NULL, NULL),
('8f05298a-9dbe-4ea6-8081-4ae4da0726fe', 'Monteiro Lobato', 'teste', 'f27eae60-75cd-4566-8f56-3c7f7eac22be', '12', NULL, NULL),
('b69a7105-20fd-42b9-a883-ba398a956c0d', 'Escola 2', 'Avenida 2', '3a3a48d3-e83a-4009-b4c6-d56ad3b50632', '2', '2025-11-06 15:16:40.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653');

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
('0021d5bc-1c9b-4ba9-94ae-28b6a06de4a7', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('008d66b2-4c81-4de4-b6dc-457ad02770a1', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('010b591b-c84f-4990-820d-4c056b5ae06a', 12, NULL, NULL, 'f31fd47e-6f79-47f7-b999-f938bf8b5765', '511430ef-91be-4857-91cd-22762429a2e6'),
('0130db32-6909-438b-95c5-f3c9bf8d2594', 1, 0, NULL, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'e25e9627-d431-4fc3-baae-170222bc3936'),
('01a9415f-dc55-4672-8170-eac14b173daf', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('01caa7e7-cbbe-4dd7-8d61-0e9318145eb8', 1, 1, 0, '48a5e395-a107-422c-b5e4-c11928eb851c', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('01dd995a-3881-4eee-86e2-aa6dfb7e1a0f', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('02678a82-19e7-46ec-8f90-7d0754fe59a1', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '511430ef-91be-4857-91cd-22762429a2e6'),
('02a93cc4-7a90-46ca-8d45-aa3fcfad25d4', 1, 1, 0, '21456270-f438-4b88-a267-bfa5e8d10665', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('037e3db3-769f-497b-8c32-b69128e8ee88', 1, 0, NULL, 'c5cef221-5204-4d1b-a707-0d82f5668103', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('038a01f2-4fe1-4194-a325-2b041857cd5c', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('039610aa-e67e-4f00-ad78-e7bcffed31df', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('040733de-a971-4842-bd01-b15dd9d20534', 1, 0, NULL, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('04198f3c-c1ae-40b7-88ce-290147ca9396', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('046c51d5-be71-4b5c-8cd4-e59f697425ce', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '511430ef-91be-4857-91cd-22762429a2e6'),
('057c813c-1832-46df-9052-5b3a941c21b4', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '511430ef-91be-4857-91cd-22762429a2e6'),
('066adf7d-1c9d-408d-91f4-65e2d82b6786', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('06ba0131-129d-4703-892e-99dc138e4972', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('072d3c7f-4128-4fe3-be54-5a173de3c261', 1, 1, 0, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('073d78b3-cb99-486e-ac2c-83bf71279ea5', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('07f68b36-5dd0-4821-beff-9f168c2bc761', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('0856501a-6893-433a-8001-267dac877bdb', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('0866d000-6d47-4b9f-88d7-de5b5a1e6634', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('08d382c8-b615-4d68-a83d-f831358999dc', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('08d7a5a0-aca8-438a-8877-29480830cc63', 1, 1, 0, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '32e1075b-7bcf-4add-8a4e-253064392338'),
('090b961c-f09c-436c-bb77-b2457a48edbb', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('094d0b80-cb69-45e1-b3e3-4c306bc1d3f1', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '511430ef-91be-4857-91cd-22762429a2e6'),
('09771fdd-40be-4837-b59b-49a8b7e4db73', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('09acd439-12af-4773-99c8-fca29e51e42d', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('0a0ac374-49cb-4bf3-afbe-134be64057d2', 1, 0, NULL, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('0ad48866-f838-4f79-9f25-3a80215e4454', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('0af9f065-c94f-4cb7-993c-6dacaa769562', 20, 0, NULL, '6acd1108-baf4-4cb6-8bad-10841835f112', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('0b30346b-d6d8-4e51-bc3d-8ed5e336230e', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '32e1075b-7bcf-4add-8a4e-253064392338'),
('0b96dab4-49da-479e-871e-893f199be4e0', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('0c7e360a-11de-4813-b548-ad2bb9691019', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('0c9f974a-b462-4d1f-a53a-067fdb11fc9d', 1, 1, 0, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('0cb310c4-5397-4ce1-b2cd-09c5bb0c57ff', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('0cfd12cf-1408-4bb0-ace3-facbf4793d85', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('0d22d75d-1deb-40a3-b846-95616d496ff4', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('0d507eef-a01e-4ae6-be8b-166518293b86', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('0e1faab7-d781-475a-b0f9-5d6137675366', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('0e2a3c71-3bb3-4310-ab12-cf2bf51ea1a3', 1, 0, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('0e549fff-4955-4d67-b925-41f73f736673', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('0e9f5a6f-849a-454d-8759-497de0a28d11', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('0ed949a4-ab1f-4ef2-902c-5ca87e14dec7', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('0f838f8f-c1e6-4e3c-9516-5937772d3832', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '511430ef-91be-4857-91cd-22762429a2e6'),
('0fc768d6-6a4b-4a85-bb69-f7ca4ca85d2d', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '32e1075b-7bcf-4add-8a4e-253064392338'),
('0fef65f0-be6a-4de8-8506-1476b4c5d8df', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('10896eb6-d03f-4240-b3d8-cd930890e96f', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('10a3e507-a700-4541-894c-a2734184ea80', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'e47b6419-3c22-4423-8f44-609431702278'),
('1175bc34-91d3-42fa-8e30-a467b7da4a71', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '32e1075b-7bcf-4add-8a4e-253064392338'),
('1180f5e9-9a76-479c-8702-ee2f07e58bfd', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('12f45c38-420e-4867-9c40-cf53c333a1f6', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('13a69553-dfae-4447-a90e-429b102a0c3c', 1, 1, 0, '21456270-f438-4b88-a267-bfa5e8d10665', '511430ef-91be-4857-91cd-22762429a2e6'),
('144bb552-6412-4630-8a7f-31e4e4e3656b', 10, 10, 10, 'c4d9d7d8-0594-4b2a-82fa-998304b42745', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('1490613e-b047-46b9-a255-9f46252819bb', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('14a18781-1179-4336-8984-eca357f1c911', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '511430ef-91be-4857-91cd-22762429a2e6'),
('15014e75-1b5c-40dc-bb72-e7a194041024', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('153cab08-4492-4ba7-a09b-d22d735b28ef', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5'),
('15a4b5d6-ca2d-44af-887d-96a7fb866cd0', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('15acef7b-9df1-4d17-ba01-95fd8b9017ac', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('1656f059-56c1-44d0-a930-769318688ee1', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('1689ca7f-2974-4dcb-a627-026c37c2104b', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('175103c6-ce69-4ffc-8e8e-0e40b232f891', 1, 1, 1, 'd33b25a3-07c1-434a-b30a-dfa8be808ab2', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('17fa6729-1443-482d-bcf3-ee5bc2e5b7f0', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'e47b6419-3c22-4423-8f44-609431702278'),
('1858eb57-43ef-48df-94d2-69bdb37799b8', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('1868d09c-28e1-4421-9922-18289761bc9f', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('18a9069a-9808-4e03-b564-09a4ac673a2d', 1, 1, 1, '9b46944c-2490-40a0-b20c-4a67329dca50', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('1a01429d-d4b4-4707-9346-be903873f751', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('1a4c9bd7-ba53-4dbe-87aa-02954b30c898', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '511430ef-91be-4857-91cd-22762429a2e6'),
('1acae398-a44a-4082-8406-01830535359e', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('1af44300-4eee-4842-b5e9-cb8e59fda4ce', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('1b71de79-4f96-42fc-ae3c-8cf1d08ef1f3', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'e47b6419-3c22-4423-8f44-609431702278'),
('1cd3959e-ac45-4eb6-af68-e1ead4d7313b', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('1da172d5-641d-4e56-b230-b091d69f81ff', 1, 1, 0, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('1e688241-dd9a-4bdb-8d92-2eecacea7a75', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('1ea5fedc-fb23-4d5e-bec5-4aec4fb89fab', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('1ec4a36c-98ef-48d5-a181-dc5c381471b8', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('1fb0eaf1-55db-424b-878b-6483704b494e', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '511430ef-91be-4857-91cd-22762429a2e6'),
('200ada9c-7170-429b-9f6c-eb7f61b0e9f8', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '511430ef-91be-4857-91cd-22762429a2e6'),
('20da9f1c-a14e-4717-b410-9f9c249ee385', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('20fa20fa-8db5-4df2-98bf-1430a6dc2bc1', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('213bdf0c-a243-4db0-a7b2-472192ec64bd', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('21bc8f7c-6cfd-4c14-b484-13a5e7220038', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('2209e5bc-89d6-4040-929d-09ce9aac3c4e', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '32e1075b-7bcf-4add-8a4e-253064392338'),
('22995b5c-9729-4fc0-8f63-cf1f4079f061', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'e47b6419-3c22-4423-8f44-609431702278'),
('23f07d11-cd6d-40c6-98f1-eba2e3010671', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('24068434-4adf-4196-91a3-3bfd6a49193c', 1, 0, NULL, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('267d76c2-02a0-49b4-8a83-68b56da93b6a', 1, 1, 1, '71c40043-0314-4aa8-ad11-bd84535194e4', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('2704f177-4363-4f2f-9f83-222afb258b82', 1, 1, 0, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('276377f8-785a-4d64-b96d-9b9cc8ad35be', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'e47b6419-3c22-4423-8f44-609431702278'),
('29060e34-3daa-4c34-ab10-a525af6ec1e4', 13, NULL, NULL, 'f31fd47e-6f79-47f7-b999-f938bf8b5765', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('2963879c-778e-48d4-ade5-7a4360484ee7', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('2990ecc1-557b-45f6-9219-5cf8fbcde352', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('2a5e8d03-3e98-47d8-b82f-28253af6046c', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'e47b6419-3c22-4423-8f44-609431702278'),
('2b2878dc-725f-4d36-8df4-e3b516ecea43', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('2b3c4cc8-3f3c-4a27-a94c-d4aaa69f6c90', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('2c6e29e8-da2b-45eb-9a7f-7d3c7344fe44', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('2cd0e1b5-be2e-4a6e-8404-aef46942dff6', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5'),
('2da4cbd3-1e7f-4778-ac6b-1bc72f3b1d6d', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'e47b6419-3c22-4423-8f44-609431702278'),
('2e42b9dc-9e0b-4f51-8880-e1fdc7c01edf', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('2e4955df-94d3-454a-a29f-392b6ae7956f', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('2e6fec55-5de5-4aec-893e-03ab7cc5b4c9', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('2f2c2230-41e0-4a3d-9de7-68d024f0e54d', 1, NULL, NULL, 'eb42cdd7-c283-4032-b1a5-dc03b0713267', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('2f4942c4-96a7-49a5-bd37-f61513616d5e', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('2f6a8ee9-1a3c-4452-934b-cc32b51c6294', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('305bd18d-5d9d-4eb2-99c2-4acb41bea389', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('31266e5b-2d07-44be-8dd5-14765499e56d', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '32e1075b-7bcf-4add-8a4e-253064392338'),
('322c554b-c12a-4c02-a0da-8db122c8196e', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('322e0722-99e9-43b9-b590-5d3f73715715', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'e47b6419-3c22-4423-8f44-609431702278'),
('32a4e4a2-9f3f-4e99-b29a-29993fc62707', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('32f728dd-a25f-4a76-98f6-2ea5bc1f2fac', 1, 0, NULL, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('338a31bc-3c94-4c0b-a841-45795c5178a9', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('33db03f0-ad61-4d8f-b70b-bc25eb79e3bd', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('33e277bb-9894-401c-acd1-ea58ff5ce1c3', 1, 0, NULL, 'c5cef221-5204-4d1b-a707-0d82f5668103', '511430ef-91be-4857-91cd-22762429a2e6'),
('3496fb16-b12a-400b-a7d7-de8f77d5297c', 1, 0, NULL, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('349ee64b-6f71-4087-9ab5-50195e83e40b', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('34ab12c0-41f6-4083-baf2-b01e6f6b2c47', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('34de394b-9bb7-496e-af3a-34d022b20bcb', 1, 1, 0, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('35cd50dc-33c6-4573-803d-7e1c7bd28fc5', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '511430ef-91be-4857-91cd-22762429a2e6'),
('3655b2dc-f5b7-48ff-9b25-575274d19efa', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('36dab304-e373-44d8-93f0-8f647e9ebecd', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '32e1075b-7bcf-4add-8a4e-253064392338'),
('36fcdff7-fc5d-41ca-b72a-cdc0e4a8d4e8', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('385dcc4c-dfd1-47c8-bf67-e221cbca913d', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', 'e47b6419-3c22-4423-8f44-609431702278'),
('39426eaa-f0a8-41e9-9f44-1f13a4071567', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('3da0132b-f33c-4a30-9cc0-666d7a99cc09', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('3e42a46a-a527-4979-91c5-63ac6554717e', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('3e7c1806-35f7-42b1-b434-c94e411f363a', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('3eb222d9-4454-4c99-a4ee-7f4a5224c21c', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('3fe3bb95-28ae-44c1-9f22-f353b8d312be', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('4005d0e8-cf4c-436d-a669-e645bd361a34', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('402f6412-1cb4-4e2f-b8ad-5d9e6d1d6997', 1, 0, NULL, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '02dd05f1-cd36-4f68-b3cd-2208b41ee451'),
('416625e0-f38b-4437-bbdb-087883806daa', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('41a71bd5-8e47-4507-93d3-6f6896a39cdf', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('42adbcdd-6862-4c75-82e6-dcc4a714b1b4', 1, 1, 1, '71c40043-0314-4aa8-ad11-bd84535194e4', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('42bc364c-445c-4d1d-b06a-c9f886f8e8df', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', 'e47b6419-3c22-4423-8f44-609431702278'),
('42fb82c9-cddb-45be-9c76-3df5005fe4c9', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('434c9da4-e1c5-4554-8d93-3ce55f0b38dd', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('4355b5de-2c4b-46d6-951e-c5ba171a91b1', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'e47b6419-3c22-4423-8f44-609431702278'),
('447b2fe4-151c-47d5-9b8f-7e02f7bcdf51', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '511430ef-91be-4857-91cd-22762429a2e6'),
('45236ac5-4489-4591-9f2d-00b0178e7ab8', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('455bb326-776f-4f5f-b420-0c89b8057e32', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('45a2cf34-122c-452b-8fec-c39e5ef51e5d', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '32e1075b-7bcf-4add-8a4e-253064392338'),
('4602439d-4e66-4c75-a73a-3c3f737218d7', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('460dfb59-9640-4a5c-a3ba-ee990e89eec6', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('462d6764-2b3c-4692-8b14-0a72fe4f263b', 1, NULL, NULL, '8a1f5fdc-6cb0-4918-ac52-bda98e240c65', '511430ef-91be-4857-91cd-22762429a2e6'),
('4696bb5d-6a56-4f37-a839-10a1a9fbc26a', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('477aeaf3-200f-4aa5-b7d2-c4a15c12cf1b', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('4849410d-eb24-4976-8037-6313d24e6c7f', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('486a492f-d3e7-4994-a7f9-368ea0699953', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('4916ec8e-5800-422c-a583-7e7511c25665', 20, 20, 20, 'fa98e35c-04c0-4b32-9cee-406ec937894c', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('4ba9698f-93da-4fba-9971-1c5aa9ca9789', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('4be60836-ee71-4f1d-bf48-1a08b4b9acd6', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('4bfe7493-5cf6-4f56-9e45-68a52eb43f66', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('4c7404e8-a14c-40e6-b0f0-0f1d16ca4057', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('4cc655a9-eaf8-49bc-85f7-10eadb6b4520', 1, 0, NULL, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '511430ef-91be-4857-91cd-22762429a2e6'),
('4d303edf-b4fe-40f9-b2db-8c6c7cb9886c', 1, 1, 0, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('4d8d8bba-5d94-46ae-9860-0ec68cffb64b', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('4dc2d67d-d040-42fa-adcb-4292dffd4d5c', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('4dc95dee-38cd-47b8-b5ce-a68475adfc28', 1, 1, 1, 'd33b25a3-07c1-434a-b30a-dfa8be808ab2', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('4e69e297-29fc-45f3-903f-a3a9d996e4a2', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('4e7a7bfc-ac62-4d93-b7e6-be455b41c9f2', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'e47b6419-3c22-4423-8f44-609431702278'),
('4eba54fc-93c4-4f66-b9c6-1d5f7ca29c43', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '32e1075b-7bcf-4add-8a4e-253064392338'),
('4fa6a0a8-b731-435d-8355-8e274165d107', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('504d6211-3cee-482f-a2fd-c900c298063b', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('50c9775f-bc0f-44cd-af8a-07862bc2891e', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('511a7019-5933-4421-b9d4-3be2cd2a05e1', 1, 1, 1, '9b46944c-2490-40a0-b20c-4a67329dca50', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('516c149e-bac3-4559-bb79-f6a05c9bfb17', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', '511430ef-91be-4857-91cd-22762429a2e6'),
('51a82657-9e2e-4e89-8de8-131d3f7b3fbd', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('51eb76e1-fbcd-4709-8250-493f085514a0', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('51f11dad-7cae-4a59-94d1-37adadcdae6d', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('5204d1c7-2a23-46e6-807c-47c10278956b', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('5241d67d-cf91-4a3f-936f-b6e149eb7e3b', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('52c061a4-46b6-4f38-b770-33db883ca214', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('5306ee4e-f833-40e5-a081-627f4004631f', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('53533dbf-e16f-483b-99a4-0d897c5d7c17', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('536316f0-15e9-40c2-bb2b-d835d8d5fc6b', 1, 1, 0, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('537551db-ce5a-4658-a3d7-4fe5bb49a999', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '511430ef-91be-4857-91cd-22762429a2e6'),
('537e9808-28c8-47cb-ba23-99d741c83e61', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('53861295-caf3-4277-aa4c-50289a771b52', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('53ad0339-6d1b-4e67-8f4d-06ce65d1fb2c', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('53e2a96e-6d47-404b-8d9d-5a3f0ba94ea4', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '32e1075b-7bcf-4add-8a4e-253064392338'),
('54e48cfd-599c-44c3-aa35-2e26ab0f1b2e', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('55828c7d-6d59-4f55-aae3-f02673efe05c', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'e47b6419-3c22-4423-8f44-609431702278'),
('562b55c6-d123-4300-9f79-c52208b3cb47', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('5660603a-5cd9-4782-8eda-e0dd3561419f', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('575b1e02-58f8-4607-9e64-6a93107018f5', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('57708da6-2d3e-4692-ae76-66e9e4156ed4', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('580151b4-45ff-4c0b-a6f3-28d86796f411', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('58644485-51f9-48c7-9c24-0ea8ee6e2f6e', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'e47b6419-3c22-4423-8f44-609431702278'),
('58afb33c-99db-4b98-8640-74eea8a1792e', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('58f78ed0-8d0d-4602-8f52-d7b605520bb0', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '32e1075b-7bcf-4add-8a4e-253064392338'),
('592aa8de-d02a-43c6-b5a7-04fb34be1bc4', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('59ca2661-de4c-4702-93b4-beb625473955', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('5a38da4f-1e71-4a4d-a5f2-bf4eedf5bf29', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('5b2fe4c9-9044-45c5-ac1e-c14fb1ce8c78', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('5b96f453-6afe-46fd-896a-d48f7b0513a6', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('5cbfe068-600b-457f-8b9d-171cbe6efa12', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('5d4ef874-3d0f-4261-a7f5-aee1dd42ffdb', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('5e405a84-48e7-4a3e-8381-1c2f2402e309', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('5e4ac678-aa76-4342-8057-77cc3341e51c', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '32e1075b-7bcf-4add-8a4e-253064392338'),
('5f841f53-0345-406b-b6e1-1f6a80a790b2', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('6076e0ae-ae36-45b4-bbef-1126b67e3c02', 1, 1, 1, 'c16a00dc-7321-49b0-9364-88348e9e3195', '32e1075b-7bcf-4add-8a4e-253064392338'),
('608c8a8b-f5c5-426c-afe1-9747a23f5e76', 100, 100, 100, '9941dc5b-01d3-4a31-bb46-fc5fa90618cb', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('60a34aff-d350-4b76-b0e4-f69a00be28e9', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('60bb4fcd-9eb9-4444-af9a-c6fd667af572', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('624ad9d2-b2c4-4f48-96c8-eec7dea34dd8', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('62edc2fd-138d-4bc0-b884-1a0c54cbbad3', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('62f822f4-dfe5-4f6c-bf80-20a1e44e8bfa', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('6349c55d-ea0a-45ac-bbff-97411c4a3023', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'e47b6419-3c22-4423-8f44-609431702278'),
('63b1262e-2b15-448f-9e7a-68438bd8ff2b', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('63c6cec2-d189-45ae-bf42-7c1f77a8be08', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('64201704-07be-43e3-857e-e368bea6e88e', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'e47b6419-3c22-4423-8f44-609431702278'),
('645a085a-afaf-45b2-84b6-44f9eacab2ba', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'e47b6419-3c22-4423-8f44-609431702278'),
('651f0b9d-2df5-41dc-bfdf-af11cf12fa9b', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'e47b6419-3c22-4423-8f44-609431702278'),
('65802334-aed3-45de-a770-bbc3164d115c', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('659cf159-56b5-4509-99b6-b909ca4ce1d0', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('65bd950b-bfe8-4db4-84bc-b87d1a8d7728', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('65e2d8da-5649-45a0-8efd-6114be61acca', 1, 1, 0, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('65ee6e63-4253-4b2f-8e8a-415e305a3b8d', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('66c5016b-6e78-44e5-8f96-f21b2a6ec1f6', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('66ea5aa2-df13-411b-ab35-7d3c87aa2373', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '511430ef-91be-4857-91cd-22762429a2e6'),
('671c3e3b-4e3a-4067-ad1d-9250154a42e9', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('674de401-5553-4567-8e7d-f6ff6f271587', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('6756679f-d4c5-4c69-b4ad-5291a86c8ce4', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('679fdf77-9a8f-411d-bf09-07a503484b25', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('68c7ef87-482e-4a19-b2ac-b14ea157819f', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('695350ad-7b93-4c77-9dc1-edc1f46eb27c', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('697492ed-2756-4282-bfca-81fe53204c52', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('698b7eb6-106c-4dc2-a1a2-79632ead38d5', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('69b6b11d-219e-406d-bb2d-bc68d63ea5b4', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('6a0d4eb9-267c-4557-9ba9-05ca40ec8304', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('6a4180c5-c9f4-46af-8689-50143caf3b97', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('6b0c6eb3-ff20-4bce-8926-74581a18bec2', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('6be121e6-4ce7-40d5-b76d-62892684a7f5', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '32e1075b-7bcf-4add-8a4e-253064392338'),
('6c16515c-cdd3-4c08-9ed2-7a953a2e37e0', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', 'e47b6419-3c22-4423-8f44-609431702278'),
('6c50015f-662b-40cb-8b6c-56987ecab972', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('6c9447a4-34ba-43c9-a659-a77501988f1f', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('6cc59ce5-6c5a-413c-ac61-880a8f109258', 1, 1, 1, '9941dc5b-01d3-4a31-bb46-fc5fa90618cb', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('6cfc0b57-251c-4d0c-b2e7-f8365a06a382', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('6d50eb39-5a76-4072-b3d5-fd06e75d7e42', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('6d8c4ec0-9540-4600-8b0f-110af0ff30f5', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('6e21da8b-4a83-47a5-9c9f-4482b29330fe', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('709f72f9-310e-49cf-b396-d75afc93caac', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('71d6a606-2d99-483d-af74-2a74dd30ae4b', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('728882f9-3a52-4804-a231-906516667c56', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('73b5a90e-dfa1-4ccb-9dbe-e1ccdd84503d', 1, 1, 0, 'c5cef221-5204-4d1b-a707-0d82f5668103', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('7480022a-7da6-4cae-9e43-7709508dc316', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('750d9c6b-5a3f-4663-ad1f-0dbf45e99c12', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('75873502-8041-432a-8ae0-7b23e32b4d31', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('769b5974-1a51-412b-9e14-4dbe604d021c', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('76be5101-c28c-49d1-9494-cbd46106af0e', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '32e1075b-7bcf-4add-8a4e-253064392338'),
('76e52bf8-77a3-47d6-9af2-df1c0a379b21', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('777713e4-a112-4d21-b1f4-a28da837155b', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('777efd32-1824-43be-a29c-96004bb94cc7', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'e47b6419-3c22-4423-8f44-609431702278'),
('781d5dd2-3a2a-4ff0-9cc4-a66e3f55fb8d', 1, 1, 1, '71c40043-0314-4aa8-ad11-bd84535194e4', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('787ab51b-c7c7-445c-92cf-cc74508feece', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('798976ad-70f3-4ca2-b517-616bee7960ee', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '32e1075b-7bcf-4add-8a4e-253064392338'),
('7a165bd3-c1dd-44f3-be9b-eebef7d58480', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('7a1789f8-e60b-4d05-b54d-d7ee8eba7a03', 1, 1, 0, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('7a4facb3-c200-4a8f-a23a-2dac0b8c70f7', 10, 10, 8, 'e30df698-a25f-4b77-a570-00ecb44ccd34', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('7a98648b-5fc3-4986-9268-ac1b3ed242e4', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '511430ef-91be-4857-91cd-22762429a2e6'),
('7a9a867f-2ea0-49c5-8208-c5c58ded5994', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('7b269be2-242e-4247-9b7f-502e3396ff83', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('7ba1d715-8068-4f08-bd5c-9ab7e42358b4', 1, NULL, NULL, 'f51fd144-e44a-4d84-8fc1-8f411cc71ee4', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('7bc3921e-833d-4d4c-8332-8b950cbc809e', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('7c59e9b1-8fb6-429b-bf91-bccf75422541', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '511430ef-91be-4857-91cd-22762429a2e6'),
('7d0c5f4a-afbe-4280-b092-ec52757c7993', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('7d517752-3e9e-446d-a42e-6a18188b309c', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('7dc9a873-76fe-4b70-87cc-ca9ca2a09ea3', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('7dda1be4-a89f-4d9a-b9f8-c2d202ae7420', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('7e6b8cc2-be18-498e-85f8-22e211284b20', 1, 0, NULL, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'dcd63eb1-e48b-4e8d-bdb6-4301e83ae5c9'),
('7f22e705-9582-48cb-8ef6-48b9ded0da6a', 1, 0, NULL, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('7f4f46fa-869f-4acd-a372-6bbe982b5119', 13, NULL, NULL, 'f31fd47e-6f79-47f7-b999-f938bf8b5765', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('7fb50b1f-8855-4468-b9cb-09769015bbf7', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '32e1075b-7bcf-4add-8a4e-253064392338'),
('7fc74a59-4d09-470f-a301-dacbfdfb58d9', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '511430ef-91be-4857-91cd-22762429a2e6'),
('7feb2cf5-6e83-4015-b24b-b5eaef81069d', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'e47b6419-3c22-4423-8f44-609431702278'),
('8027f08f-00fb-434b-a595-a08d39c34df5', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('8060bb83-fb69-4c6a-8b98-ef421b3d449c', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('8132c37f-31e0-41ba-94bb-50a12d988abd', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('81b7bd80-e6f0-40cf-ac7f-6bf368625489', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('82017e7d-3f3a-4ead-b9a8-e391f5326eb2', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('822bc05b-c73e-40e2-bc58-4344dcd2543a', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('822fa5eb-2ad5-4566-92c3-86921e1c464e', 1, 1, 0, 'f5c4d4b7-a690-4dbe-96cb-9a5afa31e0a3', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('8323dcbd-0c13-4d1f-9ce5-6a0a1c1faae0', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('8331eb72-608d-4275-b8dc-cefe0274613b', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('83edd046-8f45-463c-bca9-08d3a6fa1ff7', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('8406aee4-84a0-48b8-a422-3219797b2227', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('85b80529-46a3-44e1-870a-e363d2f319a3', 1, 1, 1, 'f68993a2-d38b-4c92-b5a5-1608f2e899ed', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('8677b347-f78f-463c-8323-4d0fa7435817', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '32e1075b-7bcf-4add-8a4e-253064392338'),
('867dbad9-4d12-4032-b405-058d663e08fb', 1, 0, NULL, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('87262684-21ea-4a3a-85e1-83a0520dfbd4', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('8765fa1f-59ea-4768-b322-27177b8a7fa0', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', 'e47b6419-3c22-4423-8f44-609431702278'),
('87e446ef-fc45-44ac-96f2-f4ea2a584c7b', 1, NULL, NULL, 'ceda07d7-ed06-44e6-8dea-6439a5d68c10', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('883e50ed-0292-4d1c-9ded-96e6c2383225', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('8906e223-4292-4e3a-92d0-4a42cd6ae9a6', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '32e1075b-7bcf-4add-8a4e-253064392338'),
('892992e7-e463-48b3-b4c9-0d95d25a9cd9', 1, 0, NULL, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('893cb24c-0237-463b-8220-384544262cce', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'e47b6419-3c22-4423-8f44-609431702278'),
('8974d399-0253-4588-8465-f2e76f9d9796', 2998, 2998, 2998, '81960fe5-8e4c-4159-b397-4822a42116eb', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('899c2671-86d1-41ad-968e-ccb0e05ae940', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('8a0a358d-1cfa-4b38-b8c9-e81cf313aa64', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '511430ef-91be-4857-91cd-22762429a2e6'),
('8ae4a566-4e8b-4d2e-a751-e9fcc22f21f4', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'e25e9627-d431-4fc3-baae-170222bc3936'),
('8c68ba54-b1cd-4c35-9653-a1e42f777f9f', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('8c790af3-cf4f-4829-99b6-697cfc18f10d', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('8ce188dc-5465-43e2-9911-1b27a130344d', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '32e1075b-7bcf-4add-8a4e-253064392338'),
('8d2e9fa1-a11a-41bd-bebc-d846036eca9c', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('8f5ea0d3-868c-4368-b07c-5e298234aef6', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('8f9481c4-4099-46f4-a4b3-50564e8f0218', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('90100179-a1a2-472f-9caf-431ee579ae23', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('90132386-cf6a-4c15-b6b9-22613de2d575', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5'),
('9013a92c-c569-4961-8889-30df9a444eb2', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('9083bec3-9894-4827-9e7e-91c8ba616caf', 10, 0, NULL, '96f31606-883a-486a-bb9e-611a3aca1665', '511430ef-91be-4857-91cd-22762429a2e6'),
('90925fc7-cb86-4c36-a74b-69ca05282322', 1, 1, 1, '9b46944c-2490-40a0-b20c-4a67329dca50', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('9114fe97-0e7f-40c1-82c8-63b073afd780', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('9132270a-6811-441c-b782-6c8ad5d3cc94', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('91a1bb5b-e09f-465d-942c-8d2fc0179e95', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('91b0b17b-cee1-4e5c-a0d0-4f0208067bfd', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('9273e73a-0120-490d-bd30-22c51dea4db4', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('936ae7fe-d781-415f-b4c7-80fc11df0b45', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('936dc52e-2c6f-48ae-a18e-9a83832a9052', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('93a57786-c66b-4df2-993a-0a3fc4812bf7', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('93b2563b-75c5-4997-a73f-9610ba9135ca', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '32e1075b-7bcf-4add-8a4e-253064392338'),
('93ede6ab-ad8a-4b36-94b0-7cba1a3f0f05', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('9408b23c-e416-441e-a787-18f1d8332f30', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('94158684-faed-478f-b78c-b6817e96d3de', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('94a7052c-0eb9-4cc0-9ec0-0ffa36cb093e', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('95271391-16c3-4c95-a0eb-0096deeec65a', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '511430ef-91be-4857-91cd-22762429a2e6'),
('9553c629-19a7-4293-9311-0bfcd3b0c0e8', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'e47b6419-3c22-4423-8f44-609431702278'),
('96412696-f2da-44d1-8d82-9832147364b2', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('983c8dc9-227f-49e3-bb11-b0a8a4b8d581', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('984f07ad-f122-4401-8e94-3c2877d010fd', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('98b84b9b-13f7-41e0-b19e-92892a5e6ada', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('99897b22-6fb8-414b-beed-9032f8489de3', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('99d466bc-dbb4-4341-8cb5-bd52cc6bd99b', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('99f128a4-7cbc-4c0b-8f70-90a21024764c', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('9a96af0d-b76c-4bb1-b5af-1e3e9b1e1073', 1, 0, NULL, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('9b21690c-603f-482a-9803-1a35da786c8c', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('9b4ac13b-29d1-479a-9af9-9581af359e44', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('9be3a303-ce42-4c86-bd41-df2bfaca5a17', 1, 1, 1, 'd33b25a3-07c1-434a-b30a-dfa8be808ab2', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('9c02e12d-9196-440a-9b7b-448a4c3d67c4', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('9c5a8af2-d78c-40b5-a790-f599e7122481', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('9c8afcd5-7e9a-4516-9f92-736e3f0409a5', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('9ce20f3d-13f8-496d-b0ae-7c6db64677f2', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('9d21c6d2-94f0-46bf-8084-d1e31e339faa', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('9d281e0d-9065-4f87-ac72-5feb32b744a4', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('9d3acb25-592b-406b-be7f-c80ac75beac7', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('9d522133-7eab-4fe6-b377-5113a71b8e73', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('9da07ed5-e80d-467a-9ebe-07b3c5a8268e', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('9ee12086-1aa2-44df-b434-a3e0896fae74', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('9f0f3f54-1286-4bb5-a3a6-6406a5d2a28f', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('9f5104df-d69d-4ab4-8016-3d0f7411293c', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('9fe79401-d651-4669-a99b-f104ccd52775', 1, 1, 1, '9941dc5b-01d3-4a31-bb46-fc5fa90618cb', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('a0618041-ae36-49d9-8414-5709b10dc593', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('a06d416d-36fb-42eb-8956-3f361a1ccfe2', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '511430ef-91be-4857-91cd-22762429a2e6'),
('a0ae56aa-8229-4d7a-a938-4ffe56af7210', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('a0ed4b89-4ce4-43c4-94b5-4b02286c6ff5', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('a125c639-59db-4569-b5f4-3b5fc1ec1a80', 1, NULL, NULL, 'b0816fb4-8632-4097-8c25-f45106b3119b', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('a180e382-f704-411e-8cc1-5919154b54bc', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('a28f74d1-88dc-4ae5-a274-1cb594905863', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('a29c2361-110b-4a59-b083-7b95ac286cc7', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('a324a5bf-edfc-42e9-9110-5fa0b6b585b5', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('a3c7eeb0-87d8-4e84-a6d8-f162b25efce6', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('a4038e55-ee3f-4a8e-b12c-6482d54d4589', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'e47b6419-3c22-4423-8f44-609431702278'),
('a43a975a-3468-46a8-a683-7b02b15fa5cb', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '32e1075b-7bcf-4add-8a4e-253064392338'),
('a4692f46-125c-4279-be47-a8cd46499f09', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('a4a9c4cb-2483-4aa2-95ee-9a0035979336', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('a540784b-4642-430d-acfd-8722dba46010', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('a5b586e7-becd-4541-a409-cfacdc307f44', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'e47b6419-3c22-4423-8f44-609431702278'),
('a6131a13-aeef-452d-ab9d-701e7cbc2cc4', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'e47b6419-3c22-4423-8f44-609431702278'),
('a658ab3f-f572-4d2e-9a5f-9cb5e6e625ff', 12, 10, 8, '1dab5143-cee2-464a-8b20-21aab1020f9d', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('a6a3ae67-45ac-45f3-9998-7810f5163935', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('a6d72e10-ce8c-41f8-a923-2214e5c5e716', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('a7351d9a-cd58-410a-b590-48f5059b1e84', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '511430ef-91be-4857-91cd-22762429a2e6'),
('a794b72f-fdb8-4bb1-93df-6bf0a41b71b2', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('a7ba915a-9673-4344-9e65-8852bb7d51ea', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('a89330bf-4786-4e12-a5c6-7441321261e2', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('a978c9b0-63e8-4060-8d81-abe19c6252c0', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('a97b5f05-b154-4c82-a58d-c3d4d52f3444', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('a983529a-2a69-4119-a081-07e03901b16c', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '32e1075b-7bcf-4add-8a4e-253064392338'),
('a984826d-fc16-467b-b08e-a8fa4331d898', 10, 5, 5, 'd33b25a3-07c1-434a-b30a-dfa8be808ab2', '79e1e219-cb47-4f3e-b529-68e2e2a98d45');
INSERT INTO `solicitacao_items` (`id`, `quantity_requested`, `quantity_approved`, `quantity_received`, `solicitacao_id`, `product_id`) VALUES
('a9bbb8d2-99e8-4614-a30d-42d4b6f8d7f4', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('aa0092f0-90e0-4452-baf4-e1f3898b6a96', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('aa579ae1-6e6a-4d5d-8037-477c66c838e3', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('aa916985-6a8c-45f8-8f3b-95d5c01e0128', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('aa91a26c-8b01-458a-8840-5badcccacd95', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('aaa72a09-9e45-4fd0-9ad9-3e5fd2adac71', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('aadcf313-fb13-4190-949a-e2575dbb9547', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('ab195b9d-2ff0-4f3e-97a3-594661c14414', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('aba911bc-4aaa-403b-ad82-f295afbc1323', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('ac0bb5bb-78d9-44b6-8577-baa45382ef24', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('ac6fa706-c725-42ce-88a8-7169b3cf0bbd', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('ad22311f-6e00-4fd7-8602-57f3e81a3b20', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('ad38c953-1140-4457-aafe-e78dad085bb8', 1, 1, 1, '71c40043-0314-4aa8-ad11-bd84535194e4', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('af035d68-1d39-4a62-8cdb-c340dd4951b0', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('af6bb0e0-c9e9-46cb-8a82-2cf345bb9e0f', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '511430ef-91be-4857-91cd-22762429a2e6'),
('af8dda1f-7af8-4b6b-ae26-68dc618ec605', 100, 100, 100, 'f584eb15-3ecd-4d50-9092-58cd629d96ea', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('afce61f6-a801-4c9e-929b-7132fade163a', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'e47b6419-3c22-4423-8f44-609431702278'),
('b07aec5a-0472-4951-873b-df62f4bb0b49', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('b0f21ca7-53f8-45bf-8047-afb7daddbba9', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('b283a809-2245-4a3a-b654-f4390ad493ea', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('b402db6c-2128-4bf4-a868-77b9526c537a', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('b441c29d-f798-4d54-83d9-1e45c2259480', 1, 0, NULL, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '7f059474-4f8b-4ddf-9ea5-92ca62c469f5'),
('b4c28c1f-abe1-4eea-b4be-f719a04a3c8a', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('b4f85a43-8ec6-4588-b118-25a70f8bb0bb', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('b5be7cc7-8409-435c-b261-ed76239d506e', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '511430ef-91be-4857-91cd-22762429a2e6'),
('b650c18f-60b4-4186-8297-a49877859532', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('b6b12d88-2f3b-4996-8104-3aee77acdd05', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('b6c179a0-c7ed-4bf1-9f1b-3a4854ffda9d', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', 'e47b6419-3c22-4423-8f44-609431702278'),
('b707fe9c-2468-4b38-8b2a-327a8edc2022', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('b8003b4e-7888-4375-b44f-07001f479331', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('b8395786-35b9-4a66-a848-047059a8c286', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('b887cf24-f509-498d-bde8-aff63be906f5', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('b8e7cbeb-d6c0-4772-9bbf-e920c0c3ad4b', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('b94a99a4-904b-4743-9d98-42680e90f578', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('b9568c09-f920-40dc-a03d-efe37f1cb355', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('b9604a44-9cb3-45dd-aec0-44d3fa8a036e', 1, 1, 0, 'c5cef221-5204-4d1b-a707-0d82f5668103', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('ba50e92d-f6d4-4e7d-a962-99fc342ce1a0', 1, 1, 0, 'c5cef221-5204-4d1b-a707-0d82f5668103', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('bac0194e-cff8-4d09-85c1-bf98afaca305', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('bacf97b6-ab39-46a6-a213-7bc70340cb3a', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '511430ef-91be-4857-91cd-22762429a2e6'),
('bb8c3af7-6ace-43c4-9b93-970b01c87165', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '511430ef-91be-4857-91cd-22762429a2e6'),
('bc1abcef-7cfb-40b4-b2d6-624d6048437f', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('bcc18ce9-76b0-4c1a-af51-c7fd07c5b39b', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('bce46f74-8726-49e9-905e-c6eacda3d898', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '32e1075b-7bcf-4add-8a4e-253064392338'),
('bd380af1-c654-4bc6-9bda-ee73f39294b1', 1, 1, 0, '03cb9437-e8c3-4ad7-aa13-fca563553015', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('be85ea67-949a-46a0-a492-0374acf9bc14', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('bec28f18-1722-440b-8093-be61c2ec7370', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'e47b6419-3c22-4423-8f44-609431702278'),
('bed866f2-e422-4be7-9790-0f5d45819532', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('bf435b2f-53ca-43e5-b1c8-b2fe034265a3', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '511430ef-91be-4857-91cd-22762429a2e6'),
('bf94daf9-5c87-4fd1-a0aa-6d7c3f470702', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('bfc422a8-1f7d-4da3-8d48-5a4de80b527d', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('bfee3ec6-a8ea-4419-9b87-7120d4b87f51', 1, 1, 1, '9941dc5b-01d3-4a31-bb46-fc5fa90618cb', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c03319b5-8977-4edd-8cdc-13296544a748', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c0414afb-cc67-422e-bc23-1f7ba74cf816', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('c063373c-0477-4ecf-a866-4324eb3ec665', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('c1085480-9f66-4ed3-a25e-8528a3dbfb11', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('c108fbaa-bc91-4b84-b1ce-a82b57ba72ff', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c1c0aa7e-5b77-4f44-a66e-98eb7cf8c806', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('c2787e28-5161-4a4c-bfea-e7c5210b6f31', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('c308d88c-048b-4a12-80a6-37ba20d002ac', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('c31556ab-9a9b-4137-99ac-3e6a9902da08', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('c321882b-99f7-44f0-977d-9ef9b1471bc4', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '32e1075b-7bcf-4add-8a4e-253064392338'),
('c32b8183-b361-49f4-afb4-d7e38115aaf0', 1, 1, 1, 'c5cef221-5204-4d1b-a707-0d82f5668103', 'e47b6419-3c22-4423-8f44-609431702278'),
('c43528b7-e23e-443a-be9e-46ddff1261cf', 1, 0, NULL, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('c521d033-6d7b-46d1-a6ae-55e48cb62306', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('c5289cd6-e177-421d-b92a-0c4340c32da7', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('c551ec7f-cb83-46e4-883c-bd9ae89ff0e8', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('c59ae838-600c-4041-b172-958bd59594ef', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '511430ef-91be-4857-91cd-22762429a2e6'),
('c6b046df-0865-4729-8f25-ea47446ab932', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'e47b6419-3c22-4423-8f44-609431702278'),
('c6e5c26a-abd2-4059-823d-f3130bc87629', 50, 50, 50, '8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c7273c2f-5749-440e-9d7a-0c405d015e5a', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('c78a89e3-516a-485a-a7fa-e924c5494eac', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('c867777a-142e-483f-991c-74e23b29b948', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', 'e47b6419-3c22-4423-8f44-609431702278'),
('c8714acb-62bb-4690-9ecb-4111169acc9a', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('c8c6c156-92c6-4b33-8699-3039fc4969b3', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c93eb173-0b8a-4157-a79e-65dd0992b112', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('c983991b-d455-445c-a619-53393c6f6bd0', 1, 1, 1, '8c9dd584-61e6-4d43-8958-a0ac6289a7d3', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('c9a6df30-63c6-422a-a732-733bc35b3ac4', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('c9b35fb5-8c71-4f24-b57c-61bbf529069f', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('cb865d9f-44af-4fb2-bc2b-8cde6257c738', 100, 100, 100, 'c16a00dc-7321-49b0-9364-88348e9e3195', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('cba3eb1b-e180-4845-b3bf-af39647d5fd9', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', 'e47b6419-3c22-4423-8f44-609431702278'),
('cbd2bd0e-0c49-45b6-b3c9-dfa25dd18839', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('cbdc1681-6fc3-4528-aa77-599727d163a6', 1, 0, NULL, 'dbcbae49-66dd-4457-86cb-990caf1a26e0', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('cc082c15-a159-4d01-8642-f90a62bcce6b', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('cc53c10d-84a5-4bc8-bcc2-87ad0b0529a5', 1, 1, 1, '508c59bf-2869-45c6-a1bd-fdfe2697be29', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('cc547814-830e-4535-bfba-07712e12704a', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('cc730c53-b2b8-4789-bb1f-9f8527c8ba2b', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('cc85399b-055a-4bf4-a11c-80b3e9a9cfd5', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('ce29554c-d107-495d-89b0-610629f3d10f', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '511430ef-91be-4857-91cd-22762429a2e6'),
('ce5cfb81-4cb8-48e0-a8f7-a18b00e0788d', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', '511430ef-91be-4857-91cd-22762429a2e6'),
('ceac48f1-e18b-4526-91df-8c6955d2ac77', 1, 0, NULL, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '32e1075b-7bcf-4add-8a4e-253064392338'),
('cf579dc9-acd1-454c-92d1-def8672a3512', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('d0526d5b-5596-42ee-8e5f-a893cc5b399c', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'e47b6419-3c22-4423-8f44-609431702278'),
('d1fe86f4-4091-456c-b63a-1fb310ed61dd', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('d25450ad-ced5-4741-85a1-c6ee36830781', 1, 0, NULL, '44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('d25e7ce2-3a8e-436c-b996-d41777faac89', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('d290bdf2-21f4-4405-9d17-d38384fd9f19', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('d2bed72f-a58d-44f4-90a5-1b472b62597b', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('d3185d97-8e83-47e6-8286-8a0188bc633c', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('d3fe6505-d95c-4af2-8e87-2ea7e325d134', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('d4124768-ef72-4e16-ac01-8746a929af21', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', 'e47b6419-3c22-4423-8f44-609431702278'),
('d458ada4-b244-4a52-86c6-696b7585b953', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('d4abbdb1-b4e5-4c3f-bfce-1b928b831379', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('d50cce2e-d6b0-4221-a449-49e0ba66f0f2', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('d5100be5-5457-4c8e-a737-5f260d21a9b0', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('d5153b98-d8f9-4ddc-8e3c-ced570b78db9', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', '32e1075b-7bcf-4add-8a4e-253064392338'),
('d5212540-a5c2-448f-b693-49949a502605', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('d54f1a67-c861-4058-acb0-a92319b86248', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('d57fadaa-2dad-4acb-b1bd-9acbe6b37416', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('d602756c-5bef-480b-abea-c189130e6132', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('d7698573-5150-45a3-ac2c-0963c554caa4', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('d7993c92-901f-4d94-851e-17f6e0fa1136', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '511430ef-91be-4857-91cd-22762429a2e6'),
('d7b0c755-6154-4210-9521-7337c3def664', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('d7e196f8-c3b4-4f67-9bba-f814d683e40c', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('d8270ca5-f034-4349-826e-c70e32e89c13', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('d82bfaee-254c-42a2-946a-cbb8bf0ee69a', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', 'e47b6419-3c22-4423-8f44-609431702278'),
('d8535911-74e9-4cc3-a7b5-a1c70228a4ac', 200, 200, 200, '06a3171a-2fbf-482e-a816-15be25a86743', '32e1075b-7bcf-4add-8a4e-253064392338'),
('d8920434-8819-4300-9d2b-44fa69ed6969', 1, NULL, NULL, 'e923cd03-a170-4e52-adce-2c08e0b7f6f4', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('d90791d4-d48f-448e-bc7a-8deb6c2424e2', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('d93ae946-61fc-49f3-b5b1-5c4bba7d07b3', 200, NULL, NULL, 'bd7c4f9d-4b7a-4f65-8b8b-b20e6daece6e', '32e1075b-7bcf-4add-8a4e-253064392338'),
('d9dab73e-2489-431c-b7c5-8cb4b67d901a', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '511430ef-91be-4857-91cd-22762429a2e6'),
('d9fff4da-6f13-470d-8930-ebe6f2e88f33', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('da17bc3f-8195-4843-9afa-9ad33d61fe18', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '32e1075b-7bcf-4add-8a4e-253064392338'),
('da86afa3-ff02-4014-a4f4-1b533ba4032e', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('da8af699-d704-4c25-b678-8401b3023143', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('dbf46d9e-8010-404c-a053-38ef00647775', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('dc54eae2-6ceb-43ba-a2ee-92b82bab2200', 1, 1, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('dc677cc8-6e78-40ba-8110-353792d9d5e4', 1, 1, 1, 'c5cef221-5204-4d1b-a707-0d82f5668103', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('dc711cdb-c890-4b44-aabf-232a499c2ffc', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('dca83982-7e47-40ff-9c29-0d2dd760cc3a', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('dcbe9bdf-5b7f-4974-b5ec-559f4a71c97c', 13, NULL, NULL, 'f31fd47e-6f79-47f7-b999-f938bf8b5765', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('dcd344b5-a816-48ce-9446-c84dd44b3440', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('dd7ce9d0-b1de-4644-b387-56ce4cfdfddf', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('dd96bb60-37e5-4524-ab62-972fb4de7111', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('ddd0ad8c-23f4-49c3-9b7d-8dea71ebde30', 1, 1, 1, 'fa2e273a-0088-463c-a714-2187dce49fc0', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('ddd7177b-19d1-4b94-a239-3fd6ac09adaf', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('de0847f9-154b-4bab-84bf-6d860c6bc533', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('de1eac66-4d91-4cbb-8587-24bbd676bc96', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('de2c1afa-7ac3-439f-b62a-f875ce987209', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('de52f4ff-5a6c-4e27-9977-327368004f2d', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '511430ef-91be-4857-91cd-22762429a2e6'),
('de72d9ff-d0da-4425-9f31-374f5abe65d4', 1, 0, NULL, 'c0ce0aee-df1f-4efd-95c6-c99df198233d', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('deed842f-fe1e-4ca7-aff4-b0e6ae7c1aa4', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('deef7992-d18e-478f-add0-c170777b95ac', 1, NULL, NULL, 'bb950b74-348c-44ce-9751-49c0f594f65a', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('df140e32-0ffb-4075-8af6-470ae7762ced', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('df1e6391-2bad-487f-9ea1-6559a86c62f2', 1, NULL, NULL, '8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('e0576f5a-8fcb-4b6f-bc23-53e176f2fea1', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('e1c26c6d-3604-44dc-b933-cb09aa79dab4', 1, 0, NULL, '82b14ae9-1afe-42a7-9f80-7ab6f462b506', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('e2543c19-5822-4035-95bd-1f7810909b0b', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('e3838b16-b78d-4ea0-be7d-198864c5862e', 1, 1, 1, 'b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('e411af86-6b91-4e30-a8cb-9feaea731813', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '511430ef-91be-4857-91cd-22762429a2e6'),
('e49346e0-be62-4649-af98-9b0f03cb8df5', 1, 1, 1, '9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('e53c8265-7147-4f92-b3ae-a62cd1c26be2', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('e59f145a-d31e-4f6c-8e98-5bbfb55d948d', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '511430ef-91be-4857-91cd-22762429a2e6'),
('e6669719-447b-4387-a5e8-125d72eae567', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('e6b31ea3-0596-4eaa-9b6f-c0edd36e674d', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('e85bce63-3442-4e42-9278-aecfa8f16d15', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('e9386554-67cf-4ecc-a6c7-ca6b3432edd4', 1, 0, NULL, '51b9cc79-56c5-459d-8fb6-cce86710c9c2', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('e998276e-cc4c-491b-a721-b7fd2d26268c', 1, 0, NULL, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', NULL),
('e9d982e3-77f2-49b5-8bfc-8062e1c7c9b8', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('ea74a3d0-6f35-4bd8-90dc-1d1fa916a3a7', 1, 1, 1, '21456270-f438-4b88-a267-bfa5e8d10665', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('ea9dacfa-3d7d-4582-aeef-c51c21802f57', 1, 1, 1, '71c40043-0314-4aa8-ad11-bd84535194e4', 'e47b6419-3c22-4423-8f44-609431702278'),
('ead022eb-7375-42c3-a790-a057a5f1f0ff', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', '32e1075b-7bcf-4add-8a4e-253064392338'),
('eb28121c-bb0f-4d42-8c37-e281ad8ee193', 1, 1, 1, '5f8fb4bd-2450-4556-813c-5b2dafe42639', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('ecd027f3-8196-4b5c-bb20-64b707b7117e', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '511430ef-91be-4857-91cd-22762429a2e6'),
('ecdd3ec5-9903-4ee4-9d7a-149df5736477', 1, 0, NULL, '6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('ed732ed8-e895-4fcb-96e5-6e2d40c9ee07', 1, 1, 1, '4ae87e0b-4f87-4af4-a99f-3437026118eb', '32e1075b-7bcf-4add-8a4e-253064392338'),
('edd6bbc0-e03b-438a-afbf-f11e027cc9a4', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('ee0c6698-91cf-4f40-b0b7-b6e6aaacc234', 1, NULL, NULL, '7a6c8a65-155d-4955-a1b1-a9a418df74c7', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('ee51ee78-602d-485e-80f9-7c3363544b93', 1, 1, 1, '1b98cd24-584f-4da1-aae2-bf4f7059a21c', '32e1075b-7bcf-4add-8a4e-253064392338'),
('ee58f6b0-5596-4ec1-b394-f85beed36158', 1, 1, 1, '1b8aac33-1377-4fde-96ce-7c89adf394bf', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('ee86a959-7b82-4a64-9cea-19056c6220e8', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'e47b6419-3c22-4423-8f44-609431702278'),
('eef73ed9-15b3-4aae-af0d-c875b6587911', 1, 1, 1, 'f06aa734-8a2a-4d24-906b-7c7f0a79f32e', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('ef45cc27-6926-4270-9631-ce104f93d780', 1, 0, NULL, '7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('ef6c943a-2c58-43fe-b2e2-cdfd514035a0', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('ef9e9a70-da9c-4b02-8991-a1052a5637c1', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('f06f4d3b-699d-412b-89db-921ef0969a35', 1, 0, NULL, '0380cece-4e40-4db6-b6d7-d6e8d476d03a', '330179f7-4225-4c53-bcce-fa4e78f33b08'),
('f12236e9-1a44-4223-a3f1-2ed1c32d070a', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '511430ef-91be-4857-91cd-22762429a2e6'),
('f145406d-bfab-4b7d-8071-5262903daceb', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9'),
('f1742b01-6061-4ab5-a7d9-de7e06c8e217', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('f1c48fe8-8ff2-4afb-9227-e34ff86b4dd8', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', '64a8a84c-e9e7-47f3-9419-3a18cd595157'),
('f1c66624-6e21-42ce-92df-b3f7307552da', 1, NULL, NULL, 'dcd71a87-bf66-4992-961b-eb6dbad2e2fc', 'b8e45d7c-3a48-4161-9d40-5e19df1a94b1'),
('f1ce6bd4-64b7-43b4-b2b8-107314b6a63e', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('f310db1d-3bd2-4021-b8a3-233f2dc99371', 1, 1, NULL, '75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('f47d7b9c-d18c-448b-a67e-8129d176b601', 1, 0, NULL, 'b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('f535e688-f1b9-46e4-b626-87d582e43641', 1, 1, 1, 'cdb6fa94-f9c0-4215-896a-7f65855943e7', 'e47b6419-3c22-4423-8f44-609431702278'),
('f5a38a57-59d5-479d-a890-36a4c3f62568', 1, 1, NULL, '69e2de7e-b697-44c9-b862-5697970395e9', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('f60e9842-46b5-4005-b93a-c8e0f3810995', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('f7627b69-0999-4ab6-9741-9049d15e1dd6', 1, 0, NULL, 'e30df698-a25f-4b77-a570-00ecb44ccd34', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('f7683246-c655-4960-bd3b-cd660d70835d', 1, 0, NULL, '43785a7a-6ce6-4f6e-ba74-9643320874a2', 'bef0ae2a-e146-49e5-a544-74afb5667e4f'),
('f7c3f3e3-5b73-4780-adbf-94d1dc7cf572', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', '32e1075b-7bcf-4add-8a4e-253064392338'),
('f7d915d9-43e7-46d2-a6c0-c1018ccfc2ab', 1, 1, 1, '89b8e276-0564-44e4-bd5e-c2f77bb6fb31', '79e1e219-cb47-4f3e-b529-68e2e2a98d45'),
('f7e5845e-7a7f-465c-a58b-25fe6d31191d', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', 'e47b6419-3c22-4423-8f44-609431702278'),
('f7f58fc6-7b5f-494d-b2af-1e027c1a7671', 1, 1, 1, 'def4e87c-fb68-4e1a-94ec-563f378ab349', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('f84bf2d8-5698-438f-872c-142799ab04a9', 1, 1, 1, 'a202b094-d1a4-4e7c-b08e-deaa16fd748f', 'c2566218-7972-4778-bcf3-b5f6e8ed2136'),
('f8dbc282-c60c-4e8e-9921-bf85592233a7', 1, 1, 1, 'c5cf7017-49d6-443c-8e48-298d5bc64bc7', 'abca8fbe-753a-458a-863b-48fc46c255e4'),
('f99cbb49-09c2-4f62-b05d-3a97fad8667c', 1, NULL, NULL, '7b722b65-51e6-47c2-93f9-7adc5a6e045c', '32e1075b-7bcf-4add-8a4e-253064392338'),
('f9eaf3e0-56a1-4b6a-b7b2-a674f4899854', 13, NULL, NULL, 'f31fd47e-6f79-47f7-b999-f938bf8b5765', 'e47b6419-3c22-4423-8f44-609431702278'),
('fb523830-8362-46f1-b700-4fb64d2b8daa', 1, 0, NULL, 'c27108b2-a78e-4291-9534-f69c59af5fc6', '069656e3-ffe9-4e16-bbd3-21747fc1a182'),
('fb91b3f9-b715-450c-a8e7-4aeba091fe83', 1, 1, 1, 'ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '980c95b2-9fd8-4645-b848-730a5bf0bfff'),
('fce5d901-6678-4aae-8db0-60e3ee915729', 1, 1, 1, '5f319ac0-3dc1-4b23-9100-84028e338fdf', '34fcc870-59be-4798-b0ea-d949c63c7ee9'),
('fe3e1ab0-b42f-459f-8c0b-67b1d00b65bf', 1, 1, 1, 'e30df698-a25f-4b77-a570-00ecb44ccd34', '511430ef-91be-4857-91cd-22762429a2e6'),
('fe9b7e55-6f6b-4e83-a1cf-2837ed0d5a57', 1, 1, 1, 'df0d1f3e-6862-453c-ae99-c60be99388b5', 'e9a78193-e02b-48a0-803e-f46c17cbe2f8'),
('ff7382b1-cc5d-4603-b075-67584c972605', 1, 1, 1, 'eeb1529a-b270-43a6-8091-0322bcd2c09e', 'a6a4dc6c-7168-435c-ae90-fc827f5c5cc9');

-- --------------------------------------------------------

--
-- Estrutura para tabela `solicitacoes`
--

CREATE TABLE `solicitacoes` (
  `id` varchar(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `status` enum('pendente','aprovado','aprovado_parcialmente','negado','recebido','cancelado','recebido_divergente') NOT NULL DEFAULT 'pendente',
  `justificativa` text DEFAULT NULL,
  `observacao_prefeitura` text DEFAULT NULL,
  `school_id` varchar(36) DEFAULT NULL,
  `requester_user_id` varchar(36) DEFAULT NULL,
  `observacao_escola` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `solicitacoes`
--

INSERT INTO `solicitacoes` (`id`, `created_at`, `updated_at`, `status`, `justificativa`, `observacao_prefeitura`, `school_id`, `requester_user_id`, `observacao_escola`) VALUES
('0380cece-4e40-4db6-b6d7-d6e8d476d03a', '2025-11-13 15:42:05.726272', '2025-11-13 15:42:36.000000', 'aprovado_parcialmente', 'teste2', 'nao tem ', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('03cb9437-e8c3-4ad7-aa13-fca563553015', '2025-11-05 14:20:21.660717', '2025-11-05 14:20:55.000000', 'recebido_divergente', NULL, NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'teste'),
('06a3171a-2fbf-482e-a816-15be25a86743', '2025-11-06 13:58:10.075699', '2025-11-06 13:59:37.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('1b8aac33-1377-4fde-96ce-7c89adf394bf', '2025-11-17 15:57:37.169801', '2025-11-17 16:01:46.000000', 'recebido_divergente', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'estragado'),
('1b98cd24-584f-4da1-aae2-bf4f7059a21c', '2025-11-06 14:02:20.151987', '2025-11-06 14:05:02.000000', 'recebido_divergente', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'nao veio arroz'),
('1dab5143-cee2-464a-8b20-21aab1020f9d', '2025-11-04 13:48:47.087883', '2025-11-04 13:49:47.000000', 'recebido', 'teste', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('21456270-f438-4b88-a267-bfa5e8d10665', '2025-11-05 10:34:07.023435', '2025-11-05 10:35:28.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('43785a7a-6ce6-4f6e-ba74-9643320874a2', '2025-11-17 15:57:25.977143', '2025-11-17 15:59:18.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('44d623ce-3fdc-42d7-a6c0-e2b9218a32a7', '2025-11-05 14:19:18.405073', '2025-11-05 14:20:03.000000', 'negado', NULL, 'teste', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('48a5e395-a107-422c-b5e4-c11928eb851c', '2025-11-04 15:17:06.946617', '2025-11-04 15:17:51.000000', 'recebido', 'test', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('4ae87e0b-4f87-4af4-a99f-3437026118eb', '2025-11-05 13:54:24.762787', '2025-11-05 13:58:10.000000', 'recebido', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('508c59bf-2869-45c6-a1bd-fdfe2697be29', '2025-11-05 14:17:24.607063', '2025-11-05 14:18:10.000000', 'recebido_divergente', NULL, NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'nao recebi o arroz'),
('51b9cc79-56c5-459d-8fb6-cce86710c9c2', '2025-11-05 14:13:14.389706', '2025-11-05 14:13:59.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('5f319ac0-3dc1-4b23-9100-84028e338fdf', '2025-11-05 14:07:28.767784', '2025-11-05 14:09:18.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('5f8fb4bd-2450-4556-813c-5b2dafe42639', '2025-11-06 14:02:47.524589', '2025-11-06 14:06:32.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('69e2de7e-b697-44c9-b862-5697970395e9', '2025-11-17 16:11:11.848375', '2025-11-17 16:12:56.000000', 'aprovado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('6acd1108-baf4-4cb6-8bad-10841835f112', '2025-11-06 14:07:01.508615', '2025-11-06 14:07:18.000000', 'negado', NULL, 'tyste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('6dcebfc7-dfb3-4df4-b1eb-4942c83cf6e1', '2025-11-06 14:02:39.576398', '2025-11-06 14:03:28.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('71c40043-0314-4aa8-ad11-bd84535194e4', '2025-11-05 14:09:27.431023', '2025-11-05 14:10:45.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('75c7ad10-0dd7-4a45-8e0c-7738a63d3ca1', '2025-11-17 16:12:04.460742', '2025-11-17 16:13:21.000000', 'aprovado_parcialmente', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('7a6c8a65-155d-4955-a1b1-a9a418df74c7', '2025-11-25 19:01:27.537156', '2025-11-25 19:01:27.537156', 'pendente', NULL, NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('7b722b65-51e6-47c2-93f9-7adc5a6e045c', '2025-11-05 11:01:00.252134', '2025-11-05 11:01:20.535000', 'cancelado', 'teste', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'errado'),
('7b9c5816-a58f-44c8-9eed-bf2f6f5526d1', '2025-11-05 11:50:42.697960', '2025-11-05 11:53:07.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('81960fe5-8e4c-4159-b397-4822a42116eb', '2025-11-06 12:34:40.273832', '2025-11-06 12:37:40.000000', 'recebido_divergente', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'Recebi todos só que estava estrago 1'),
('82b14ae9-1afe-42a7-9f80-7ab6f462b506', '2025-11-05 13:54:18.807399', '2025-11-05 13:55:57.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('89b8e276-0564-44e4-bd5e-c2f77bb6fb31', '2025-11-05 14:43:46.944402', '2025-11-05 14:44:39.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('8a1f5fdc-6cb0-4918-ac52-bda98e240c65', '2025-11-05 11:07:04.953618', '2025-11-05 11:12:20.000000', 'negado', NULL, 'falta', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('8c9dd584-61e6-4d43-8958-a0ac6289a7d3', '2025-11-05 12:01:05.106698', '2025-11-05 12:03:04.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', '2'),
('8db485a1-63f1-4bb7-9e79-a593dfa0dbeb', '2025-10-30 13:26:27.290014', '2025-10-30 13:27:39.000000', 'recebido', 'Reposição do Estoque', 'ok', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('8e2cc795-cbef-4c5f-9e72-dd6494a7059a', '2025-11-25 18:40:57.809482', '2025-11-25 18:40:57.809482', 'pendente', 'teste tcc', NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('96f31606-883a-486a-bb9e-611a3aca1665', '2025-11-06 16:07:38.907330', '2025-11-06 16:08:03.000000', 'negado', NULL, 'em falta', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('9941dc5b-01d3-4a31-bb46-fc5fa90618cb', '2025-11-06 14:13:06.524481', '2025-11-06 14:14:11.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('9b46944c-2490-40a0-b20c-4a67329dca50', '2025-11-05 14:43:05.848286', '2025-11-05 14:44:41.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('9c3e78c7-1f49-43db-ab1c-616ac5b7ac9d', '2025-11-05 11:56:24.410051', '2025-11-05 11:58:25.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'teste'),
('a202b094-d1a4-4e7c-b08e-deaa16fd748f', '2025-11-06 10:39:17.861513', '2025-11-06 10:41:23.000000', 'recebido', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('ad040c75-c1d6-4bf9-ad7a-c22ad49b7e77', '2025-11-05 13:53:43.679021', '2025-11-05 13:56:52.000000', 'recebido_divergente', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'teste'),
('b0816fb4-8632-4097-8c25-f45106b3119b', '2025-11-05 14:07:10.525599', '2025-11-05 14:07:34.000000', 'cancelado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('b3c9079e-fdbf-4ecf-bc01-098a9abae9a4', '2025-11-05 14:07:18.240826', '2025-11-05 14:08:30.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('b7f551fd-d8a6-4131-9f8a-d549a08bb4c1', '2025-11-13 11:12:55.916863', '2025-11-13 11:21:32.000000', 'recebido', NULL, NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('bb950b74-348c-44ce-9751-49c0f594f65a', '2025-11-25 18:40:45.292307', '2025-11-25 18:40:45.292307', 'pendente', 'teste tcc', NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('bd7c4f9d-4b7a-4f65-8b8b-b20e6daece6e', '2025-11-06 13:57:57.334534', '2025-11-06 13:58:02.000000', 'cancelado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('c0ce0aee-df1f-4efd-95c6-c99df198233d', '2025-11-17 11:51:09.448641', '2025-11-17 11:52:14.000000', 'negado', NULL, 'rwteste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('c16a00dc-7321-49b0-9364-88348e9e3195', '2025-11-06 11:53:13.459662', '2025-11-06 12:13:31.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('c27108b2-a78e-4291-9534-f69c59af5fc6', '2025-11-17 15:23:53.993205', '2025-11-17 15:24:59.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('c4d9d7d8-0594-4b2a-82fa-998304b42745', '2025-11-04 09:58:03.786045', '2025-11-04 09:58:51.000000', 'recebido', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('c5cef221-5204-4d1b-a707-0d82f5668103', '2025-11-05 14:09:32.548632', '2025-11-05 14:10:32.000000', 'recebido_divergente', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'teste'),
('c5cf7017-49d6-443c-8e48-298d5bc64bc7', '2025-11-06 12:25:38.578975', '2025-11-06 12:34:54.000000', 'recebido_divergente', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'NÃO VEIO TAL COISA'),
('cdb6fa94-f9c0-4215-896a-7f65855943e7', '2025-11-05 11:51:07.629952', '2025-11-05 11:53:56.000000', 'recebido', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'nao recebi 3 itens'),
('ceda07d7-ed06-44e6-8dea-6439a5d68c10', '2025-11-05 11:07:00.720928', '2025-11-05 11:12:11.000000', 'negado', NULL, 'falta de produto', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('d33b25a3-07c1-434a-b30a-dfa8be808ab2', '2025-11-04 10:00:41.024959', '2025-11-04 10:01:33.000000', 'recebido', 'teste', 'teste', 'b69a7105-20fd-42b9-a883-ba398a956c0d', NULL, NULL),
('dbcbae49-66dd-4457-86cb-990caf1a26e0', '2025-11-06 12:13:58.592688', '2025-11-06 12:15:52.000000', 'negado', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('dcd71a87-bf66-4992-961b-eb6dbad2e2fc', '2025-11-05 11:50:35.528100', '2025-11-05 11:50:50.000000', 'cancelado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'errei'),
('def4e87c-fb68-4e1a-94ec-563f378ab349', '2025-11-06 12:18:57.621933', '2025-11-06 12:25:30.000000', 'recebido', NULL, 'sem morango', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('df0d1f3e-6862-453c-ae99-c60be99388b5', '2025-11-05 15:39:58.500452', '2025-11-06 10:40:40.000000', 'recebido_divergente', NULL, 'nao temos produto', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'teste'),
('e30df698-a25f-4b77-a570-00ecb44ccd34', '2025-11-05 13:54:59.398008', '2025-11-05 13:58:31.000000', 'recebido', NULL, 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('e923cd03-a170-4e52-adce-2c08e0b7f6f4', '2025-11-05 12:03:38.533144', '2025-11-05 12:03:44.000000', 'cancelado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('eb42cdd7-c283-4032-b1a5-dc03b0713267', '2025-11-05 12:03:51.980794', '2025-11-05 12:03:55.000000', 'cancelado', 'sla', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'sla'),
('eeb1529a-b270-43a6-8091-0322bcd2c09e', '2025-11-05 14:21:01.308884', '2025-11-05 14:23:57.000000', 'recebido', NULL, NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('f06aa734-8a2a-4d24-906b-7c7f0a79f32e', '2025-11-17 15:24:04.783486', '2025-11-17 15:25:55.000000', 'recebido_divergente', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', 'testesteste'),
('f31fd47e-6f79-47f7-b999-f938bf8b5765', '2025-11-25 19:00:56.078557', '2025-11-25 19:00:56.078557', 'pendente', 'teste tcc2', NULL, '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', '216c62d6-ce00-4cc8-a7c7-b608c0a678f1', NULL),
('f51fd144-e44a-4d84-8fc1-8f411cc71ee4', '2025-11-05 12:03:25.347111', '2025-11-05 12:03:29.000000', 'cancelado', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('f584eb15-3ecd-4d50-9092-58cd629d96ea', '2025-11-04 16:02:33.398080', '2025-11-04 16:03:19.000000', 'recebido', NULL, NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('f5c4d4b7-a690-4dbe-96cb-9a5afa31e0a3', '2025-11-04 15:22:39.873853', '2025-11-04 15:23:09.000000', 'recebido', 'teste', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('f68993a2-d38b-4c92-b5a5-1608f2e899ed', '2025-11-04 13:47:41.501446', '2025-11-04 13:48:16.000000', 'recebido', 'teste', 'teste', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('fa2e273a-0088-463c-a714-2187dce49fc0', '2025-11-17 11:51:00.264555', '2025-11-17 13:33:23.000000', 'recebido', 'teste', 'teste2', '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL),
('fa98e35c-04c0-4b32-9cee-406ec937894c', '2025-11-04 09:55:55.367909', '2025-11-04 09:57:09.000000', 'recebido', 'teste2', NULL, '430c8fde-ccfb-452a-8570-0c64059b7fdc', '30939156-3375-450f-88b3-c44349ec7fec', NULL);

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
  `school_id` varchar(36) DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  `deleted_at` datetime(6) DEFAULT NULL,
  `deleted_by_user_id` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `profile`, `school_id`, `is_active`, `deleted_at`, `deleted_by_user_id`) VALUES
('1fe2adfc-f61a-47a9-9d6c-22bc2a57c385', 'TESTE', 'TESTE@GMAIL.COM', '$2b$10$WskR24qnjHiSLw3OYGymReUx0nlDh3vOID73S9z59PCktBzrBUqG2', 'nutricionista', NULL, 1, '2025-11-17 10:17:37.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('216c62d6-ce00-4cc8-a7c7-b608c0a678f1', 'Wilson Batista da Silva', 'chavitista@gmail.com', '$2b$10$2/l7H86l7DhIPBNcpmZKIOkuWcflpM5X7E0J9VWixUa7bBEVc1I0G', 'escola', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', 1, NULL, NULL),
('30939156-3375-450f-88b3-c44349ec7fec', 'Natanael Estevao Moraes', 'natanael@gmail.com', '$2b$10$n8CeKfztq/1HBl4uoL3f.uOTtinGOmk1vQirUW39n/9tOD5KRIdaO', 'escola', '430c8fde-ccfb-452a-8570-0c64059b7fdc', 1, NULL, NULL),
('862098b5-c4cd-4879-a8a8-0e6d192e0653', 'Leonardo Chaves', 'leonardo.chavesbs@gmail.com', '$2b$10$o1L0vW9T7Kh0wjlqzgAC4OQVVBr2gf2l4uEFidWzbSK7HPeuieD9O', 'prefeitura', NULL, 1, NULL, NULL),
('93c24a99-e758-4b9a-bbe5-b1753b37f0ae', 'teste2', 'teste@gmail.com', '$2b$10$l1KgmuhiJICT1eRjZEpA3u4LbIPsb98jOmO9HoY7.GLs4YnMEvdVi', 'cozinheira', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', 1, '2025-11-07 10:43:04.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('a6bc8f64-eed8-4a35-93e6-a56b00b04174', 'teste2', 'leonardchaves292@gmail.com', '$2b$10$/OXjzqQPXEGPmOzkpSEGwuQTNbFBZ9Kro2KM7yPk5f/MSmUmwkOD2', 'prefeitura', NULL, 1, '2025-11-06 16:01:57.000000', '862098b5-c4cd-4879-a8a8-0e6d192e0653'),
('dbde8d5a-4344-402c-b7f3-68626ab62c14', 'Angélica da Silva', 'angelica@gmail.com', '$2b$10$Li1oCrcXAimUgMvTDxsz2OLAHuXSYLm.pq3BGqykuFWQZOhLGnusu', 'cozinheira', '430c8fde-ccfb-452a-8570-0c64059b7fdc', 1, NULL, NULL),
('e02127ee-68d9-4e51-8a7d-8e65b2cbfbc6', 'Regina Sabedra', 'regina@gmail.com', '$2b$10$2EXgQUt78i9jqMR32KCvy.bTxIINF5HYaGlFx34D0moDWBGeQ3bTi', 'cozinheira', '8f05298a-9dbe-4ea6-8081-4ae4da0726fe', 1, NULL, NULL),
('fe7b56e1-7de8-486a-987b-8d5f0c4abda6', 'Giovanna Magalhaes', 'nutricionista@gmail.com', '$2b$10$h3ZZ/Nzg6QgRZejiTJxGiOT6Smb0RRw4LC0PegIiBv5L1zxbx3WhK', 'nutricionista', NULL, 1, NULL, NULL);

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
  ADD KEY `FK_63f7700e19bf9acfdb73a6fca22` (`deleted_by_user_id`);

--
-- Índices de tabela `escola_estoque`
--
ALTER TABLE `escola_estoque`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_b99bea8bf264022b92a0707ed9` (`product_id`,`school_id`),
  ADD KEY `FK_0b60422d0b38efb969505c3f0f4` (`school_id`);

--
-- Índices de tabela `estoque_movimentacoes`
--
ALTER TABLE `estoque_movimentacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_25a2cf03c52034fa80d9a3ae6c4` (`product_id`),
  ADD KEY `FK_8e9b37a8fce089a726692c9d51e` (`school_id`),
  ADD KEY `FK_f742585d7b26325d597700e5c29` (`user_id`);

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
  ADD KEY `FK_a196364b82a3cf43b2a3d7e2442` (`deleted_by_user_id`);

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
  ADD KEY `FK_d92181684e73f7533e903e1acfd` (`city_id`),
  ADD KEY `FK_ae6cf457c54503eb53e894fe745` (`deleted_by_user_id`);

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
  ADD KEY `FK_25e1cf8f41bae2f3d11f3c2a028` (`school_id`),
  ADD KEY `FK_518416801da6ad5b2f318079a8e` (`deleted_by_user_id`);

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `cardapios`
--
ALTER TABLE `cardapios`
  ADD CONSTRAINT `FK_47f0cdaced75010db0a02d56564` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Restrições para tabelas `cities`
--
ALTER TABLE `cities`
  ADD CONSTRAINT `FK_63f7700e19bf9acfdb73a6fca22` FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Restrições para tabelas `escola_estoque`
--
ALTER TABLE `escola_estoque`
  ADD CONSTRAINT `FK_0b60422d0b38efb969505c3f0f4` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_3a8866b379173ca41d8f0bc3a12` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `estoque_movimentacoes`
--
ALTER TABLE `estoque_movimentacoes`
  ADD CONSTRAINT `FK_25a2cf03c52034fa80d9a3ae6c4` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_8e9b37a8fce089a726692c9d51e` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_f742585d7b26325d597700e5c29` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Restrições para tabelas `prefeitura_estoque`
--
ALTER TABLE `prefeitura_estoque`
  ADD CONSTRAINT `FK_dca2a658a8ff8f08bc62592b152` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `FK_a196364b82a3cf43b2a3d7e2442` FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
  ADD CONSTRAINT `FK_ae6cf457c54503eb53e894fe745` FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  ADD CONSTRAINT `FK_25e1cf8f41bae2f3d11f3c2a028` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_518416801da6ad5b2f318079a8e` FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
