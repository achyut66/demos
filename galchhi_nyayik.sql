-- phpMyAdmin SQL Dump
-- version 4.4.15.10
-- https://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 03, 2024 at 05:03 AM
-- Server version: 10.11.3-MariaDB
-- PHP Version: 7.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `galchhi_nyayik`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CheckGroupPermission`(`ModuleId` INT(11), `UserActionId` INT(11), `GroupId` INT(11)) RETURNS tinyint(4)
BEGIN
	DECLARE bReturn BOOL;
	IF GroupId = 1 THEN
		RETURN TRUE;
	END IF;
	IF EXISTS 
		(
		 SELECT permission_per_group_id 
		 FROM permissions_per_group
		 WHERE module_id = ModuleId
		 AND user_action_id = UserActionId
		 AND group_id = GroupId
		 ) 
		THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;
    END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CheckMenuPermission`(`MenuId` INT(11), `LoginId` INT(11)) RETURNS tinyint(4)
BEGIN
	DECLARE bReturn BOOL;
	DECLARE GroupId INT(11);	
	SELECT UserGroup INTO GroupId FROM users  WHERE ID = LoginId;
	IF GroupId = 1 THEN RETURN 1; END IF;
	IF EXISTS 
		(
			 SELECT permission_per_user_id 
			 FROM permissions_per_user
			 WHERE module_id = MenuId
			 AND user_id = LoginId LIMIT 0,1
		 ) 
		THEN
		RETURN 1;
	ELSEIF EXISTS
			(
				 SELECT permission_per_group_id 
				 FROM permissions_per_group
				 WHERE module_id = MenuId
				 AND group_id = GroupId LIMIT 0,1
			 ) 
		THEN
		RETURN 1;
	END IF;
	RETURN 0;
    END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CheckPermissionByLoginId`(`ModuleCode` VARCHAR(20), `UserActionCode` VARCHAR(20), `LoginId` INT(11)) RETURNS tinyint(4)
BEGIN
	DECLARE bReturn BOOL;
	DECLARE GroupId INT(11);
	DECLARE ModuleId INT(11);
	DECLARE UserActionId INT(11);
	SELECT fn_GetModuleId(ModuleCode) INTO ModuleId;
	SELECT fn_GetUserActionId(UserActionCode) INTO UserActionId;
	SELECT UserGroup INTO GroupId FROM users  WHERE ID = LoginId;
	IF fn_CheckUserPermission(ModuleId, UserActionId, LoginId) = 1  THEN
		RETURN TRUE;
	ELSEIF fn_CheckGroupPermission(ModuleId, UserActionId, GroupId) = 1 THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;
    END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CheckUserPermission`(`ModuleId` INT(11), `UserActionId` INT(11), `UserId` INT(11)) RETURNS tinyint(4)
BEGIN
	DECLARE bReturn BOOL;
	IF EXISTS 
		(
		 SELECT permission_per_user_id 
		 FROM permissions_per_user
		 WHERE module_id = ModuleId
		 AND user_action_id = UserActionId
		 AND user_id = UserId
		 ) 
		THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;
    END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetModuleId`(`ModuleCode` VARCHAR(20)) RETURNS int(11)
BEGIN
	DECLARE iReturn INT(11);
	SET iReturn = 0;
	SELECT menuid INTO iReturn FROM admin_menu WHERE module_code = ModuleCode;
	RETURN iReturn;
    END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetUserActionId`(`UserActionCode` VARCHAR(20)) RETURNS int(11)
BEGIN
	DECLARE iReturn INT(11);
	SET iReturn = 0;
	SELECT user_action_id INTO iReturn FROM user_actions WHERE user_action_code = UserActionCode;
	RETURN iReturn;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin_menu`
--

CREATE TABLE IF NOT EXISTS `admin_menu` (
  `menuid` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `menu_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `menu_link` varchar(255) NOT NULL,
  `group_label` varchar(255) NOT NULL,
  `status` int(11) NOT NULL,
  `module_code` varchar(50) DEFAULT NULL,
  `description` text NOT NULL,
  `position` tinyint(4) NOT NULL,
  `icon_class` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `admin_menu`
--

INSERT INTO `admin_menu` (`menuid`, `parent_id`, `menu_name`, `menu_link`, `group_label`, `status`, `module_code`, `description`, `position`, `icon_class`) VALUES
(1, 0, 'ड्यासबोर्ड', 'Dashboard', '', 1, 'DASHBOARD', '', 1, 'fa fa-home'),
(2, 0, 'प्रयोगकर्ता व्यवस्थापन', 'Users', '', 1, 'USER-MANAGEMENT', '', 99, 'fa fa-users'),
(3, 2, 'भूमिका', 'Groups', '', 1, 'MANAGE-GROUP', '', 1, 'fa fa-groups'),
(4, 2, 'प्रयोगकर्ताहरू', 'Users', '', 1, 'MANAGE-USERS', '', 2, 'fa fa-user'),
(5, 16, 'आर्थिक वर्ष', 'FiscalYear', '', 1, 'FISCAL-YEAR', '', 3, 'fa fa-calendar'),
(10, 16, 'मुद्दाका प्रकार', 'MuddaBisaye', '', 1, 'MUDDHA-BISAYE', '', 7, 'dashicons dashicons-book-alt'),
(11, 16, 'दस्तुर/रकम ', 'Dastur', '', 1, 'DASTUR', '', 6, 'fa fa-registered'),
(12, 16, 'कर्मचारी', 'Staff', '', 1, 'STAFF', '', 5, 'fa fa-user-circle-o'),
(13, 0, 'मुद्दा दर्ता फाराम', 'Darta', '', 1, 'DARTA', '', 8, 'fa fa-file-text'),
(14, 16, 'अनुसूची', 'Letters', '', 1, 'LETTER', '', 4, 'fa fa-file-text'),
(15, 16, 'दफा ', 'Dafa', '', 1, 'DAFA', '', 2, 'fa fa-info-circle'),
(16, 0, 'सेटिंग', '#', '', 1, 'SETTING', '', 2, 'fa fa-cog'),
(17, 16, 'तोक-आदेश ', 'TokAadesh', '', 1, 'TOK-AADESH', '', 2, 'fa fa-info-circle'),
(18, 16, 'स्थानिय न्यायिक कार्यविधिको दफा', 'LocalDafa', '', 1, 'LOCAL-DAFA', '', 9, 'fa fa-info-circle'),
(19, 16, 'स्थानिय सरकार संचालन ऐन', 'SarkarYain', '', 1, 'SARKAR-YAIN', '', 8, 'fa fa-info-circle'),
(20, 0, 'मुद्दा पेशी फाराम', 'Peshi', '', 1, 'PESHI', '', 8, 'fa fa-file-text');

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_1`
--

CREATE TABLE IF NOT EXISTS `anusuchi_1` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `date` varchar(255) NOT NULL,
  `dastur` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `created_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_2`
--

CREATE TABLE IF NOT EXISTS `anusuchi_2` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `worker_name` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `date` varchar(25) NOT NULL,
  `status` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_ip` varchar(255) NOT NULL,
  `refid` varchar(255) DEFAULT NULL,
  `created_at` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `print_count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_3`
--

CREATE TABLE IF NOT EXISTS `anusuchi_3` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date_1` varchar(25) DEFAULT NULL,
  `date_2` varchar(255) DEFAULT NULL,
  `detail_1` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `print_count` int(11) DEFAULT NULL,
  `worker_name` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_4`
--

CREATE TABLE IF NOT EXISTS `anusuchi_4` (
  `id` int(11) NOT NULL,
  `date` varchar(255) DEFAULT NULL,
  `work` varchar(255) DEFAULT NULL,
  `time` varchar(255) DEFAULT NULL,
  `darta_no` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `print_count` int(11) DEFAULT NULL,
  `created_at` varchar(25) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_ip` varchar(255) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_at` varchar(25) DEFAULT NULL,
  `modified_ip` varchar(255) DEFAULT NULL,
  `staff_id` int(11) DEFAULT NULL,
  `worker_name` varchar(255) DEFAULT NULL,
  `post` varchar(255) DEFAULT NULL,
  `sdate` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_5`
--

CREATE TABLE IF NOT EXISTS `anusuchi_5` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `date` varchar(255) NOT NULL,
  `dastur` varchar(255) DEFAULT NULL,
  `details` longtext NOT NULL,
  `type` varchar(255) NOT NULL,
  `proof` longtext NOT NULL,
  `has_laywer` int(11) NOT NULL,
  `print_count` int(11) NOT NULL,
  `created_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_6`
--

CREATE TABLE IF NOT EXISTS `anusuchi_6` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `worker_name` varchar(255) NOT NULL,
  `designation` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `pratibedak` int(11) NOT NULL,
  `serial_no` varchar(255) NOT NULL,
  `date` varchar(25) NOT NULL,
  `days` varchar(255) NOT NULL,
  `status` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_ip` varchar(255) NOT NULL,
  `refid` varchar(255) DEFAULT NULL,
  `created_at` varchar(255) NOT NULL,
  `print_count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_7`
--

CREATE TABLE IF NOT EXISTS `anusuchi_7` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `details_decision` longtext NOT NULL,
  `samiti_decision` longtext NOT NULL,
  `type` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `nn` varchar(255) DEFAULT NULL,
  `coordinator` varchar(255) DEFAULT NULL,
  `member` varchar(255) DEFAULT NULL,
  `ndate` varchar(255) DEFAULT NULL,
  `details_decision_thahar` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_8`
--

CREATE TABLE IF NOT EXISTS `anusuchi_8` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `details` longtext NOT NULL,
  `type` varchar(255) NOT NULL,
  `date` varchar(50) NOT NULL,
  `cooridinator` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `member` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `staff_id` int(11) NOT NULL,
  `print_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_9`
--

CREATE TABLE IF NOT EXISTS `anusuchi_9` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `details_decision` longtext NOT NULL,
  `badi_dabi` text NOT NULL,
  `pratibadi_dabi` text NOT NULL,
  `type` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_10`
--

CREATE TABLE IF NOT EXISTS `anusuchi_10` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `details_decision` longtext NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_11`
--

CREATE TABLE IF NOT EXISTS `anusuchi_11` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `details_decision` longtext NOT NULL,
  `name` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `type` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_12`
--

CREATE TABLE IF NOT EXISTS `anusuchi_12` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `dastur` varchar(255) NOT NULL,
  `details_decision` longtext NOT NULL,
  `name` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `type` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_13`
--

CREATE TABLE IF NOT EXISTS `anusuchi_13` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `ndate` varchar(25) DEFAULT NULL,
  `adate` varchar(25) DEFAULT NULL,
  `dastur` varchar(255) NOT NULL,
  `details_decision` longtext NOT NULL,
  `name` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `type` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_14`
--

CREATE TABLE IF NOT EXISTS `anusuchi_14` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `samyojak` varchar(255) NOT NULL,
  `members` longtext NOT NULL,
  `ward_no` varchar(255) NOT NULL,
  `area` longtext NOT NULL,
  `kitta_no` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `sqm` varchar(255) NOT NULL,
  `detail` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_15`
--

CREATE TABLE IF NOT EXISTS `anusuchi_15` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `dastur` varchar(255) NOT NULL,
  `details_decision` longtext NOT NULL,
  `name` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `type` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_16`
--

CREATE TABLE IF NOT EXISTS `anusuchi_16` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `date` varchar(255) NOT NULL,
  `status` int(11) NOT NULL,
  `member` varchar(255) NOT NULL,
  `coordinator` varchar(255) NOT NULL,
  `aadesh_details` longtext DEFAULT NULL,
  `print_count` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `anusuchi_history`
--

CREATE TABLE IF NOT EXISTS `anusuchi_history` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `anusuchi_name` int(11) NOT NULL,
  `print_count` int(11) NOT NULL DEFAULT 0,
  `created_on` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `badi_detail`
--

CREATE TABLE IF NOT EXISTS `badi_detail` (
  `id` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `gender` enum('1','2','3') NOT NULL,
  `b_name` varchar(255) NOT NULL,
  `b_dob` varchar(25) NOT NULL,
  `b_cznno` varchar(255) NOT NULL,
  `b_czn_date` varchar(25) NOT NULL,
  `b_czn_district` varchar(255) NOT NULL,
  `b_gapa` varchar(255) DEFAULT NULL,
  `b_address` text NOT NULL,
  `b_ward` int(11) NOT NULL DEFAULT 0,
  `b_grandfather` varchar(255) NOT NULL,
  `b_father` varchar(255) NOT NULL,
  `type` int(11) NOT NULL,
  `b_mother` varchar(255) NOT NULL,
  `b_husband_wife` varchar(255) NOT NULL,
  `b_relation` varchar(255) NOT NULL,
  `b_phone` varchar(255) NOT NULL,
  `status` int(11) NOT NULL,
  `created_at` varchar(25) NOT NULL,
  `created_ip` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `modified_at` varchar(25) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_ip` varchar(255) DEFAULT NULL,
  `refid` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `badi_detail`
--

INSERT INTO `badi_detail` (`id`, `date`, `darta_no`, `gender`, `b_name`, `b_dob`, `b_cznno`, `b_czn_date`, `b_czn_district`, `b_gapa`, `b_address`, `b_ward`, `b_grandfather`, `b_father`, `type`, `b_mother`, `b_husband_wife`, `b_relation`, `b_phone`, `status`, `created_at`, `created_ip`, `created_by`, `modified_at`, `modified_by`, `modified_ip`, `refid`) VALUES
(1, '', 1, '2', 'रचना पण्डित', '24', '26-01-75-00484', '2069-04-10', 'धादिङ', 'सिद्धलेक गाउँपालिका', 'नलाङ्ग', 2, '', 'नबराज पण्डित', 0, 'सुनिता पण्डित', '', 'आफै', '9813891104', 0, '', '27.34.64.163', 2, NULL, NULL, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `badi_firad_patra`
--

CREATE TABLE IF NOT EXISTS `badi_firad_patra` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `muddha_id` int(11) NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `darta_date` varchar(255) NOT NULL,
  `official_stamp` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `muddha_details` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `has_file` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `has_layer` text DEFAULT NULL,
  `officer` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `nibedan_dastur` double NOT NULL,
  `suchana_dastur` double NOT NULL,
  `pratilipi_dastur` double NOT NULL,
  `jamma` double NOT NULL,
  `pana` int(11) NOT NULL,
  `local_dafa` int(11) NOT NULL,
  `sarkar_yain` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `created_on` varchar(50) NOT NULL,
  `created_by` int(11) NOT NULL,
  `print_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dafa`
--

CREATE TABLE IF NOT EXISTS `dafa` (
  `id` int(11) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `upa_dafa` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dafa`
--

INSERT INTO `dafa` (`id`, `name`, `upa_dafa`) VALUES
(1, '47', 1),
(2, '47', 2),
(3, 'सरकार संचालन ऐन, २०७४ को दफा १ को उपदफा (छ)', 0);

-- --------------------------------------------------------

--
-- Table structure for table `darta`
--

CREATE TABLE IF NOT EXISTS `darta` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `darta_id` int(11) DEFAULT NULL,
  `date` varchar(25) NOT NULL,
  `dafa` varchar(255) NOT NULL,
  `upa_dafa` int(11) NOT NULL,
  `case_title` varchar(255) NOT NULL,
  `mudda_bisaye` int(11) NOT NULL COMMENT 'mudda parkar',
  `case_details` longtext DEFAULT NULL,
  `has_lawyer` enum('1','2') NOT NULL DEFAULT '1',
  `proof` longtext DEFAULT NULL,
  `witness` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL,
  `created_at` varchar(25) NOT NULL,
  `created_ip` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `modified_at` varchar(25) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_ip` varchar(255) DEFAULT NULL,
  `refid` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `darta`
--

INSERT INTO `darta` (`id`, `darta_no`, `darta_id`, `date`, `dafa`, `upa_dafa`, `case_title`, `mudda_bisaye`, `case_details`, `has_lawyer`, `proof`, `witness`, `status`, `created_at`, `created_ip`, `created_by`, `modified_at`, `modified_by`, `modified_ip`, `refid`) VALUES
(1, 1, NULL, '2081-04-25', '47', 1, 'नाबालक छोरा छोरी वा पति पत्नीलाई ईज्जत आमद अनुसार हेरचाह नगरेको ', 7, NULL, '1', NULL, NULL, 1, '2081-04-25', '27.34.64.163', 2, NULL, NULL, NULL, '0');

-- --------------------------------------------------------

--
-- Table structure for table `darta_dastur_wiwaran`
--

CREATE TABLE IF NOT EXISTS `darta_dastur_wiwaran` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `darta_id` int(11) NOT NULL,
  `rasid_no` varchar(255) NOT NULL,
  `rakam` double NOT NULL,
  `created_at` int(11) NOT NULL,
  `created_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dastur`
--

CREATE TABLE IF NOT EXISTS `dastur` (
  `id` int(11) NOT NULL,
  `bapat` varchar(255) NOT NULL,
  `rate` double NOT NULL,
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE IF NOT EXISTS `documents` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `doc_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `doc_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fiscal_year`
--

CREATE TABLE IF NOT EXISTS `fiscal_year` (
  `id` int(11) NOT NULL,
  `year` varchar(9) NOT NULL,
  `is_current` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `fiscal_year`
--

INSERT INTO `fiscal_year` (`id`, `year`, `is_current`) VALUES
(1, '2080/081', 1);

-- --------------------------------------------------------

--
-- Table structure for table `group`
--

CREATE TABLE IF NOT EXISTS `group` (
  `groupid` int(11) NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `status` tinyint(4) DEFAULT 0
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `group`
--

INSERT INTO `group` (`groupid`, `group_name`, `status`) VALUES
(1, 'Superadmin', 0),
(2, 'Administrator', 0),
(4, 'User', 0);

-- --------------------------------------------------------

--
-- Table structure for table `letters`
--

CREATE TABLE IF NOT EXISTS `letters` (
  `id` int(11) NOT NULL,
  `letter_name` varchar(255) NOT NULL,
  `dafa` varchar(255) NOT NULL,
  `letter_type` text NOT NULL,
  `has_tok` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `letter_head`
--

CREATE TABLE IF NOT EXISTS `letter_head` (
  `id` int(11) NOT NULL,
  `site_office` varchar(255) NOT NULL,
  `site_office_alignment` varchar(255) NOT NULL,
  `site_palika` varchar(255) NOT NULL,
  `site_palika_alignment` varchar(255) NOT NULL,
  `site_state` varchar(255) NOT NULL,
  `site_address` varchar(255) NOT NULL,
  `site_address_alignment` varchar(255) NOT NULL,
  `site_website` varchar(255) NOT NULL,
  `site_website_alignment` varchar(255) NOT NULL,
  `site_email` varchar(255) NOT NULL,
  `site_email_alignment` varchar(255) NOT NULL,
  `site_slogan` varchar(255) NOT NULL,
  `site_slogan_alignment` varchar(255) NOT NULL,
  `created_at` varchar(255) NOT NULL,
  `site_phone` int(11) DEFAULT NULL,
  `site_phone_alignment` varchar(255) DEFAULT NULL,
  `site_office_en` varchar(255) DEFAULT NULL,
  `site_palika_en` varchar(255) DEFAULT NULL,
  `site_website_en` varchar(255) DEFAULT NULL,
  `site_website_alignment_en` varchar(255) DEFAULT NULL,
  `site_email_en` varchar(255) DEFAULT NULL,
  `site_email_alignment_en` varchar(255) DEFAULT NULL,
  `site_slogan_en` varchar(255) DEFAULT NULL,
  `site_slogan_alignment_en` varchar(255) DEFAULT NULL,
  `site_phone_en` varchar(255) DEFAULT NULL,
  `site_phone_alignment_en` varchar(255) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `letter_head`
--

INSERT INTO `letter_head` (`id`, `site_office`, `site_office_alignment`, `site_palika`, `site_palika_alignment`, `site_state`, `site_address`, `site_address_alignment`, `site_website`, `site_website_alignment`, `site_email`, `site_email_alignment`, `site_slogan`, `site_slogan_alignment`, `created_at`, `site_phone`, `site_phone_alignment`, `site_office_en`, `site_palika_en`, `site_website_en`, `site_website_alignment_en`, `site_email_en`, `site_email_alignment_en`, `site_slogan_en`, `site_slogan_alignment_en`, `site_phone_en`, `site_phone_alignment_en`) VALUES
(1, '28', 'center', '36', 'center', '', '14', 'center', '14', 'footer', '14', 'footer', '14', 'footer', '2021-04-25 05:33:31pm', 14, 'footer', '18', '36', '14', 'footer', '14', 'footer', '14', 'footer', '14', 'footer');

-- --------------------------------------------------------

--
-- Table structure for table `likhit_jawaf`
--

CREATE TABLE IF NOT EXISTS `likhit_jawaf` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `dastur` varchar(255) NOT NULL,
  `case_details` longtext NOT NULL,
  `file_type` varchar(255) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `witness` varchar(255) NOT NULL,
  `local_dafa` int(11) NOT NULL,
  `sarkar_yain` int(11) DEFAULT NULL,
  `staff_id` int(11) NOT NULL,
  `miti` varchar(255) NOT NULL,
  `print_count` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `created_on` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `modified_on` varchar(255) NOT NULL,
  `modified_by` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `local_dafa`
--

CREATE TABLE IF NOT EXISTS `local_dafa` (
  `id` int(11) NOT NULL,
  `details` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `local_dafa`
--

INSERT INTO `local_dafa` (`id`, `details`, `status`) VALUES
(6, 'दफा १४', 1);

-- --------------------------------------------------------

--
-- Table structure for table `mudda_bisaye`
--

CREATE TABLE IF NOT EXISTS `mudda_bisaye` (
  `id` int(11) NOT NULL,
  `subject` text NOT NULL,
  `dafa` varchar(255) NOT NULL,
  `upa_dafa` varchar(255) DEFAULT NULL,
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `mudda_bisaye`
--

INSERT INTO `mudda_bisaye` (`id`, `subject`, `dafa`, `upa_dafa`, `remarks`) VALUES
(1, 'आलीधुर, बाध पैनी, कुलो वा पानीघाटको बाँडफाँड तथा उपयोग', '47', '1', 'क'),
(2, 'अर्काको बाली नोक्सानी गरेको', '47', '1', 'ख'),
(3, 'चरन, घाँस, दाउरा', '47', '1', 'ग'),
(4, 'ज्याला मजदुरी नदिएको', '47', '1', 'घ'),
(5, 'घरपालुवा पशुपंछी हराएको वा पाएको', '47', '1', 'ङ'),
(6, 'जेष्ठ नागरिकको पालनपोषण तथा हेरचाह नगरेको', '47', '1', 'च'),
(7, 'नाबालक छोरा छोरी वा पति–पत्नीलाई इज्जत आमद अनुसार खान लाउन वा शिक्षा दीक्षा नदिएको', '47', '1', 'छ'),
(8, 'वार्षिक पच्चीस लाख रुपैयाँसम्मको बिगो भएको घर बहाल र घर बहाल सुविधा', '47', '1', 'ज'),
(9, 'अन्य व्यक्तिको घर, जग्गा वा सम्पतिलाई असर पर्ने गरी रुख बिरुवा लगाएको', '47', '1', 'झ'),
(10, 'आफ्नो घर वा बलेसीबाट अर्काको घर, जग्गा वा सार्वजनिक बाटोमा पानी झारेको', '47', '1', 'ञ'),
(11, 'सधियारको जग्गा तर्फ झ्याल राखी घर बनाउनु पर्दा कानून बमोजिम छोड्नु पर्ने परिमाणको जग्गा नछोडी बनाएको', '47', '1', 'ट'),
(12, 'कसैको हक वा स्वामित्वमा भए पनि परापूर्वदेखि सार्वजनिक रूपमा प्रयोग हुदै आएको बाटो, वस्तुभाउ निकाल्ने निकास, वस्तुभाउ चराउने चौर, कुलो, नहर, पोखरी, पाटी पौवा, अन्त्यष्टि स्थल, धार्मिक स्थल वा अन्य कुनै सार्वजनिक स्थलको उपयोग गर्न नदिएको वा बाधा पुर्‍याएको', '47', '1', 'ठ'),
(13, 'सङ्घीय वा प्रदेश कानूनले स्थानीय तहबाट निरूपण हुने भनी तोकेका अन्य विवाद', '47', '1', 'ड'),
(14, 'सरकारी, सार्वजनिक वा सामुदायिक बाहेक एकाको हकको जग्गा अर्कोले चापी, मिची वा घुसाई खाएको', '47', '2', 'क'),
(15, 'सरकारी, सार्वजनिक वा सामुदायिक बाहेक आफ्नो हक नपुग्ने अरुको जग्गामा घर वा कुनै संरचना बनाएको', '47', '2', 'ख'),
(16, 'पति–पत्नीबीचको सम्बन्ध विच्छेद', '47', '2', 'ग'),
(17, 'अङ्भङ्ग बाहेकको बढीमा एक वर्षसम्म कैद हुन सक्ने कुटपिट', '47', '2', 'घ'),
(18, 'गाली बेइज्जती', '47', '2', 'ङ'),
(19, 'लुटपिट', '47', '2', 'च'),
(20, 'पशुपक्षी छाडा छाडेको वा पशुपक्षी राख्दा वा पाल्दा लापरबाही गरी अरुलाई असर पारेको', '47', '2', 'छ'),
(21, 'अरुको आवासमा अनधिकृत प्रवेश गरेको', '47', '2', 'ज'),
(22, 'अर्काको हक भोगमा रहेको जग्गा आबाद वा भोग चलन गरेको', '47', '2', 'झ'),
(23, 'ध्वनी प्रदुषण गरी वा फोहोरमैला फ्याकी छिमेकीलाई असर पुर्‍याएको', '47', '2', 'ञ'),
(24, 'प्रचलित कानून बमोजिम मेलमिलाप हुन सक्ने व्यक्ति बादी भई दायर हुने अन्य देवानी र एक वर्षसम्म कैद हुन सक्ने फौजदारी विवाद', '47', '2', 'ट');

-- --------------------------------------------------------

--
-- Table structure for table `permissions_per_group`
--

CREATE TABLE IF NOT EXISTS `permissions_per_group` (
  `permission_per_group_id` int(11) NOT NULL,
  `module_id` int(11) NOT NULL,
  `user_action_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `added_by` int(11) NOT NULL,
  `added_date` datetime NOT NULL,
  `modified_by` int(11) NOT NULL,
  `modified_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1058 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `permissions_per_group`
--

INSERT INTO `permissions_per_group` (`permission_per_group_id`, `module_id`, `user_action_id`, `group_id`, `added_by`, `added_date`, `modified_by`, `modified_date`) VALUES
(346, 1, 4, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(347, 7, 1, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(348, 7, 2, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(349, 7, 3, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(350, 7, 4, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(351, 7, 5, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(352, 8, 1, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(353, 8, 2, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(354, 8, 3, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(355, 8, 4, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(356, 8, 5, 3, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(689, 1, 1, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(690, 1, 2, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(691, 1, 3, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(692, 1, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(693, 1, 5, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(694, 5, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(695, 10, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(696, 11, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(697, 12, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(698, 13, 1, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(699, 13, 2, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(700, 13, 3, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(701, 13, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(702, 13, 5, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(703, 14, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(704, 15, 4, 4, 1, '2021-09-13 00:00:00', 1, '2021-09-13 00:00:00'),
(978, 1, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(979, 1, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(980, 1, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(981, 1, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(982, 1, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(983, 2, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(984, 2, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(985, 2, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(986, 2, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(987, 2, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(988, 3, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(989, 3, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(990, 3, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(991, 3, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(992, 3, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(993, 4, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(994, 4, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(995, 4, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(996, 4, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(997, 4, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(998, 5, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(999, 5, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1000, 5, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1001, 5, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1002, 5, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1003, 10, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1004, 10, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1005, 10, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1006, 10, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1007, 10, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1008, 11, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1009, 11, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1010, 11, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1011, 11, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1012, 11, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1013, 12, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1014, 12, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1015, 12, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1016, 12, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1017, 12, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1018, 13, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1019, 13, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1020, 13, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1021, 13, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1022, 13, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1023, 14, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1024, 14, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1025, 14, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1026, 14, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1027, 14, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1028, 15, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1029, 15, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1030, 15, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1031, 15, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1032, 15, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1033, 16, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1034, 16, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1035, 16, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1036, 16, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1037, 16, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1038, 17, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1039, 17, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1040, 17, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1041, 17, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1042, 17, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1043, 18, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1044, 18, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1045, 18, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1046, 18, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1047, 18, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1048, 19, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1049, 19, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1050, 19, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1051, 19, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1052, 19, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1053, 20, 1, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1054, 20, 2, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1055, 20, 3, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1056, 20, 4, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00'),
(1057, 20, 5, 2, 1, '2022-09-26 00:00:00', 1, '2022-09-26 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `permissions_per_user`
--

CREATE TABLE IF NOT EXISTS `permissions_per_user` (
  `permission_per_user_id` int(11) NOT NULL,
  `module_id` int(11) NOT NULL,
  `user_action_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `added_by` int(11) NOT NULL,
  `added_date` datetime NOT NULL,
  `modified_by` int(11) NOT NULL,
  `modified_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=522 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `permissions_per_user`
--

INSERT INTO `permissions_per_user` (`permission_per_user_id`, `module_id`, `user_action_id`, `user_id`, `added_by`, `added_date`, `modified_by`, `modified_date`) VALUES
(13, 29, 2, 11, 1, '2017-11-14 00:00:00', 1, '2017-11-14 00:00:00'),
(117, 1, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(118, 1, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(119, 1, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(120, 1, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(121, 1, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(122, 2, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(123, 2, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(124, 2, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(125, 2, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(126, 2, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(127, 3, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(128, 3, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(129, 3, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(130, 3, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(131, 3, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(132, 4, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(133, 4, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(134, 4, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(135, 4, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(136, 4, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(137, 5, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(138, 5, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(139, 5, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(140, 5, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(141, 5, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(142, 6, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(143, 6, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(144, 6, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(145, 6, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(146, 6, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(147, 7, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(148, 7, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(149, 7, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(150, 7, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(151, 7, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(152, 8, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(153, 8, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(154, 8, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(155, 8, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(156, 8, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(157, 9, 1, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(158, 9, 2, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(159, 9, 3, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(160, 9, 4, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(161, 9, 5, 19, 1, '2018-12-07 00:00:00', 1, '2018-12-07 00:00:00'),
(202, 1, 1, 2, 1, '2020-09-25 00:00:00', 1, '2020-09-25 00:00:00'),
(203, 1, 2, 2, 1, '2020-09-25 00:00:00', 1, '2020-09-25 00:00:00'),
(204, 1, 3, 2, 1, '2020-09-25 00:00:00', 1, '2020-09-25 00:00:00'),
(205, 1, 4, 2, 1, '2020-09-25 00:00:00', 1, '2020-09-25 00:00:00'),
(206, 1, 5, 2, 1, '2020-09-25 00:00:00', 1, '2020-09-25 00:00:00'),
(212, 11, 1, 10, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(213, 11, 2, 10, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(214, 11, 3, 10, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(215, 11, 4, 10, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(216, 11, 5, 10, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(217, 2, 1, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(218, 2, 2, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(219, 2, 3, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(220, 2, 4, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(221, 2, 5, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(222, 11, 1, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(223, 11, 2, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(224, 11, 3, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(225, 11, 4, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(226, 11, 5, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(227, 12, 1, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(228, 12, 2, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(229, 12, 3, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(230, 12, 4, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(231, 12, 5, 12, 1, '2020-09-28 00:00:00', 1, '2020-09-28 00:00:00'),
(262, 1, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(263, 1, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(264, 1, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(265, 1, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(266, 1, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(267, 2, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(268, 2, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(269, 2, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(270, 2, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(271, 2, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(272, 3, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(273, 3, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(274, 3, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(275, 3, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(276, 3, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(277, 4, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(278, 4, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(279, 4, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(280, 4, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(281, 4, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(282, 5, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(283, 5, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(284, 5, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(285, 5, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(286, 5, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(287, 6, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(288, 6, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(289, 6, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(290, 6, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(291, 6, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(292, 7, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(293, 7, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(294, 7, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(295, 7, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(296, 7, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(297, 8, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(298, 8, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(299, 8, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(300, 8, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(301, 8, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(302, 9, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(303, 9, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(304, 9, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(305, 9, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(306, 9, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(307, 10, 1, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(308, 10, 2, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(309, 10, 3, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(310, 10, 4, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(311, 10, 5, 26, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(362, 1, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(363, 1, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(364, 1, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(365, 1, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(366, 1, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(367, 2, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(368, 2, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(369, 2, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(370, 2, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(371, 2, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(372, 3, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(373, 3, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(374, 3, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(375, 3, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(376, 3, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(377, 4, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(378, 4, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(379, 4, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(380, 4, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(381, 4, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(382, 5, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(383, 5, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(384, 5, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(385, 5, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(386, 5, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(387, 6, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(388, 6, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(389, 6, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(390, 6, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(391, 6, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(392, 7, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(393, 7, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(394, 7, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(395, 7, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(396, 7, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(397, 8, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(398, 8, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(399, 8, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(400, 8, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(401, 8, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(402, 9, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(403, 9, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(404, 9, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(405, 9, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(406, 9, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(407, 10, 1, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(408, 10, 2, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(409, 10, 3, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(410, 10, 4, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(411, 10, 5, 31, 30, '2020-10-06 00:00:00', 30, '2020-10-06 00:00:00'),
(412, 1, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(413, 1, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(414, 1, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(415, 1, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(416, 1, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(417, 2, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(418, 2, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(419, 2, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(420, 2, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(421, 2, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(422, 3, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(423, 3, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(424, 3, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(425, 3, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(426, 3, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(427, 5, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(428, 5, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(429, 5, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(430, 5, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(431, 5, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(432, 6, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(433, 6, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(434, 6, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(435, 6, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(436, 6, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(437, 7, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(438, 7, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(439, 7, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(440, 7, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(441, 7, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(442, 8, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(443, 8, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(444, 8, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(445, 8, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(446, 8, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(447, 9, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(448, 9, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(449, 9, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(450, 9, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(451, 9, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(452, 10, 1, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(453, 10, 2, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(454, 10, 3, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(455, 10, 4, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(456, 10, 5, 30, 1, '2020-10-06 00:00:00', 1, '2020-10-06 00:00:00'),
(517, 1, 1, 16, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(518, 1, 2, 16, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(519, 1, 3, 16, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(520, 1, 4, 16, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00'),
(521, 1, 5, 16, 1, '2021-06-04 00:00:00', 1, '2021-06-04 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `peshi_darta`
--

CREATE TABLE IF NOT EXISTS `peshi_darta` (
  `id` int(11) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `peshi_miti` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` varchar(255) NOT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_at` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `peshi_count` int(11) NOT NULL,
  `ref_code` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `peshi_list`
--

CREATE TABLE IF NOT EXISTS `peshi_list` (
  `id` int(11) NOT NULL,
  `pdate` varchar(255) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `ref_code` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `modified_at` varchar(255) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `position`
--

CREATE TABLE IF NOT EXISTS `position` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `position`
--

INSERT INTO `position` (`id`, `name`, `status`) VALUES
(1, 'अध्यक्ष', 1),
(2, 'संयोजक', 1),
(3, 'सचिव', 1),
(4, 'कोषाध्यक्ष', 1),
(5, 'सदस्य', 1);

-- --------------------------------------------------------

--
-- Table structure for table `pratibadi_detail`
--

CREATE TABLE IF NOT EXISTS `pratibadi_detail` (
  `id` int(11) NOT NULL,
  `date` varchar(25) NOT NULL,
  `darta_no` int(11) NOT NULL,
  `gender` enum('1','2','3') NOT NULL,
  `p_name` varchar(255) NOT NULL,
  `p_dob` varchar(25) NOT NULL,
  `p_cznno` varchar(255) NOT NULL,
  `p_czn_date` varchar(25) NOT NULL,
  `p_czn_district` varchar(255) NOT NULL,
  `p_gapa` varchar(255) DEFAULT NULL,
  `p_address` text NOT NULL,
  `p_grandfather` varchar(255) NOT NULL,
  `p_father` varchar(255) NOT NULL,
  `p_mother` varchar(255) NOT NULL,
  `p_husband_wife` varchar(255) NOT NULL,
  `p_phone` varchar(255) NOT NULL,
  `p_ward` int(11) NOT NULL DEFAULT 0,
  `p_relation` varchar(255) NOT NULL,
  `status` int(11) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 1,
  `created_at` varchar(25) NOT NULL,
  `created_ip` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `modified_at` varchar(25) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_ip` varchar(255) DEFAULT NULL,
  `refid` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `pratibadi_detail`
--

INSERT INTO `pratibadi_detail` (`id`, `date`, `darta_no`, `gender`, `p_name`, `p_dob`, `p_cznno`, `p_czn_date`, `p_czn_district`, `p_gapa`, `p_address`, `p_grandfather`, `p_father`, `p_mother`, `p_husband_wife`, `p_phone`, `p_ward`, `p_relation`, `status`, `type`, `created_at`, `created_ip`, `created_by`, `modified_at`, `modified_by`, `modified_ip`, `refid`) VALUES
(1, '', 1, '2', 'सुशिला अर्याल', '25', '42133', '2073-04-18', 'धादिङ', 'थाक्रे गाउँपालिका', 'अमर्खु', '', 'राजेन्द्र  प्रसाद अर्याक ', 'सावित्रा अर्याल ', '', '9840559229', 6, '', 0, 1, '2081-04-25', '27.34.64.163', 2, NULL, NULL, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `provinces`
--

CREATE TABLE IF NOT EXISTS `provinces` (
  `ID` int(11) NOT NULL,
  `Code` varchar(10) NOT NULL,
  `Title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Status` enum('Active','Inactive','Deleted') NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `provinces`
--

INSERT INTO `provinces` (`ID`, `Code`, `Title`, `Status`) VALUES
(1, 'P1', '१ नं. प्रदेश', 'Active'),
(2, 'P2', '२ नं. प्रदेश', 'Active'),
(3, 'P3', 'बागमती प्रदेश', 'Active'),
(4, 'P4', 'गण्डकी प्रदेश', 'Active'),
(5, 'P5', 'लुम्बिनी प्रदेश', 'Active'),
(6, 'P6', 'कर्णाली प्रदेश', 'Active'),
(7, 'P7', 'सुदूरपश्चिम प्रदेश', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `samati_name`
--

CREATE TABLE IF NOT EXISTS `samati_name` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` enum('1','2') NOT NULL DEFAULT '1' COMMENT '1 = active,2= inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sarkar_yain`
--

CREATE TABLE IF NOT EXISTS `sarkar_yain` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sarkar_yain`
--

INSERT INTO `sarkar_yain` (`id`, `name`, `status`) VALUES
(1, 'सरकार संचालन ऐन, २०७४ को दफा १ को उपदफा (2)', 1),
(2, 'स्थानीय सरकार संचालन ऐन २०७४ काे दफा ४७ काे उपदफा (१) छ', 1),
(3, 'स्थानीय सरकार संचालन ऐन २०७४ काे दफा ४७ काे उपदफा (२) झ', 1);

-- --------------------------------------------------------

--
-- Table structure for table `settings_district`
--

CREATE TABLE IF NOT EXISTS `settings_district` (
  `id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `state` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=558 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `settings_district`
--

INSERT INTO `settings_district` (`id`, `name`, `state`) VALUES
(481, 'ताप्लेजुङ', 1),
(482, 'पाँचथर', 1),
(483, 'ईलाम', 1),
(484, 'झापा', 1),
(485, 'मोरङ', 1),
(486, 'सुनसरी', 1),
(487, 'धनकुटा', 1),
(488, 'तेहथुम', 1),
(489, 'संखुवासभा', 1),
(490, 'भोजपुर', 1),
(491, 'सोलुखुम्बु', 1),
(492, 'ओखलढुंगा', 1),
(493, 'खोटाङ', 1),
(494, 'उदयपुर', 1),
(495, 'सप्तरी', 2),
(496, 'सप्तरी', 2),
(497, 'सिराहा', 2),
(498, 'धनुषा', 2),
(499, 'महोत्तरी', 2),
(500, 'सर्लाही', 2),
(501, 'रौतहट', 2),
(502, 'वारा', 2),
(503, 'पर्सा', 2),
(504, 'सिन्धुली', 3),
(505, 'रामेछाप', 3),
(506, 'दोलखा', 3),
(507, 'सिन्धुपाल्चोक', 3),
(508, 'काभ्रेपलान्चोक', 3),
(509, 'ललितपुर', 3),
(510, 'भक्तपुर', 3),
(511, 'काठमाण्डौ', 3),
(512, 'नुवाकोट', 3),
(513, 'रसुवा', 3),
(514, 'धादिङ', 3),
(515, 'मकवानपुर', 3),
(516, 'चितवन', 3),
(517, 'गोरखा', 4),
(518, 'लमजुङ', 4),
(519, 'तनहुँ', 4),
(520, 'स्याङजा', 4),
(521, 'कास्की', 4),
(522, 'मुस्ताङ', 4),
(523, 'म्याग्दी', 4),
(524, 'पर्वत', 4),
(525, 'वाग्लुङ', 4),
(526, 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 4),
(527, 'गुल्मी', 5),
(528, 'पाल्पा', 5),
(529, 'रुपन्देही', 5),
(530, 'कपिलबस्तु', 5),
(531, 'अर्घाखाँची', 5),
(532, 'प्यूठान', 5),
(533, 'रोल्पा', 5),
(534, 'रुकुम (पूर्वी भाग)', 5),
(535, 'दाङ', 5),
(536, 'बाँके', 5),
(537, 'बर्दिया', 5),
(538, 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 5),
(539, 'रुकुम (पश्चिम भाग)', 6),
(540, 'सल्यान', 6),
(541, 'सुर्खेत', 6),
(542, 'दैलेख', 6),
(543, 'जाजरकोट', 6),
(544, 'डोल्पा', 6),
(545, 'जुम्ला', 6),
(546, 'कालिकोट', 6),
(547, 'मुगु', 6),
(548, 'हुम्ला', 6),
(549, 'बाजुरा', 7),
(550, 'बझाङ', 7),
(551, 'अछाम', 7),
(552, 'डोटी', 7),
(553, 'कैलाली', 7),
(554, 'कञ्चनपुर', 7),
(555, 'डडेलधुरा', 7),
(556, 'बैतडी', 7),
(557, 'दार्चुला', 7);

-- --------------------------------------------------------

--
-- Table structure for table `settings_relation`
--

CREATE TABLE IF NOT EXISTS `settings_relation` (
  `id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `settings_relation`
--

INSERT INTO `settings_relation` (`id`, `name`) VALUES
(1, 'आफै'),
(2, 'पति'),
(3, 'पत्नी'),
(4, 'बुबा'),
(5, 'आमा'),
(6, 'छोरा'),
(7, 'छोरी'),
(8, 'हजुर बुबा'),
(9, 'हजुर आमा'),
(10, 'नाती'),
(11, 'नातिनि'),
(12, 'दिदि'),
(13, 'बहिनी'),
(14, 'दाजु'),
(15, 'भाई'),
(16, 'सासु'),
(17, 'ससुरा'),
(18, 'काका'),
(19, 'काकी'),
(20, 'देबर'),
(21, 'भाउजु'),
(22, 'बुहारी'),
(23, 'भिनाजु'),
(24, 'सम्धि'),
(25, 'सम्धिनि'),
(26, 'ज्वाँई'),
(27, 'मामा'),
(28, 'माईजु'),
(29, 'भतिजो'),
(30, 'भतिजि'),
(31, 'साला'),
(32, 'साली'),
(33, 'ठुलो बुबा'),
(34, 'ठुली आमा'),
(35, 'देउरानी'),
(36, 'भान्जा'),
(37, 'भान्जी'),
(38, 'फुपु'),
(39, 'फुपाजु'),
(40, 'सानो बुबा'),
(41, 'सानु आमा'),
(42, 'जेठानी');

-- --------------------------------------------------------

--
-- Table structure for table `settings_vdc_municipality`
--

CREATE TABLE IF NOT EXISTS `settings_vdc_municipality` (
  `id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `district` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `type` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `district_id` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2946 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `settings_vdc_municipality`
--

INSERT INTO `settings_vdc_municipality` (`id`, `name`, `district`, `type`, `district_id`) VALUES
(2191, 'फुङलिङ नगरपालिका', 'ताप्लेजुङ', 'नगरपालिका', 481),
(2192, 'आठराई त्रिवेणी गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2193, 'सिदिङ्वा गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2194, 'फक्ताङलुङ गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2195, 'मिक्वाखोला गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2196, 'मेरिङदेन गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2197, 'मैवाखोला गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2198, 'याङवरक गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2199, 'सिरीजङ्घा गाउँपालिका', 'ताप्लेजुङ', 'गाउँपालिका', 481),
(2200, 'फिदिम नगरपालिका', 'पाँचथर', 'नगरपालिका', 482),
(2201, 'फालेलुंग गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2202, 'फाल्गुनन्द गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2203, 'हिलिहाङ गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2204, 'कुम्मायक गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2205, 'मिक्लाजुङ गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2206, 'तुम्बेवा गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2207, 'याङवरक गाउँपालिका', 'पाँचथर', 'गाउँपालिका', 482),
(2208, 'ईलाम नगरपालिका', 'ईलाम', 'नगरपालिका', 483),
(2209, 'देउमाई नगरपालिका', 'ईलाम', 'नगरपालिका', 483),
(2210, 'माई नगरपालिका', 'ईलाम', 'नगरपालिका', 483),
(2211, 'सूर्योदय नगरपालिका', 'ईलाम', 'नगरपालिका', 483),
(2212, 'फाकफोकथुम गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2213, 'चुलाचुली गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2214, 'माईजोगमाई गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2215, 'माङसेबुङ गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2216, 'रोङ गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2217, 'सन्दकपुर गाउँपालिका', 'ईलाम', 'गाउँपालिका', 483),
(2218, 'मेचीनगर नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2219, 'दमक नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2220, 'कन्काई नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2221, 'भद्रपुर नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2222, 'अर्जुनधारा नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2223, 'शिवशताक्षी नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2224, 'गौरादह नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2225, 'विर्तामोड नगरपालिका', 'झापा', 'नगरपालिका', 484),
(2226, 'कमल गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2227, 'गौरीगंज गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2228, 'बाह्रदशी गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2229, 'झापा गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2230, 'बुद्धशान्ति गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2231, 'हल्दिवारी गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2232, 'कचनकवल गाउँपालिका', 'झापा', 'गाउँपालिका', 484),
(2233, 'विराटनगर महानगरपालिका', 'मोरङ', 'महानगरपालिका', 485),
(2234, 'बेलवारी नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2235, 'लेटाङ नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2236, 'पथरी शनिश्चरे नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2237, 'रंगेली नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2238, 'रतुवामाई नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2239, 'सुनवर्षि नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2240, 'उर्लावारी नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2241, 'सुन्दरहरैचा नगरपालिका', 'मोरङ', 'नगरपालिका', 485),
(2242, 'बुढीगंगा गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2243, 'धनपालथान गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2244, 'ग्रामथान गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2245, 'जहदा गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2246, 'कानेपोखरी गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2247, 'कटहरी गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2248, 'केरावारी गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2249, 'मिक्लाजुङ गाउँपालिका', 'मोरङ', 'गाउँपालिका', 485),
(2250, 'ईटहरी उपमहानगरपालिका', 'सुनसरी', 'उपमहानगरपालिका', 486),
(2251, 'धरान उपमहानगरपालिका', 'सुनसरी', 'उपमहानगरपालिका', 486),
(2252, 'ईनरुवा नगरपालिका', 'सुनसरी', 'नगरपालिका', 486),
(2253, 'दुहवी नगरपालिका', 'सुनसरी', 'नगरपालिका', 486),
(2254, 'रामधुनी नगरपालिका', 'सुनसरी', 'नगरपालिका', 486),
(2255, 'बराह नगरपालिका', 'सुनसरी', 'नगरपालिका', 486),
(2256, 'देवानगञ्ज गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2257, 'कोशी गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2258, 'गढी गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2259, 'बर्जु गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2260, 'भोक्राहा गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2261, 'हरिनगरा गाउँपालिका', 'सुनसरी', 'गाउँपालिका', 486),
(2262, 'पाख्रिबास नगरपालिका', 'धनकुटा', 'नगरपालिका', 487),
(2263, 'धनकुटा नगरपालिका', 'धनकुटा', 'नगरपालिका', 487),
(2264, 'महालक्ष्मी नगरपालिका', 'धनकुटा', 'नगरपालिका', 487),
(2265, 'साँगुरीगढी गाउँपालिका', 'धनकुटा', 'गाउँपालिका', 487),
(2266, 'खाल्सा छिन्ताङ सहिदभूमि गाउँपालिका', 'धनकुटा', 'गाउँपालिका', 487),
(2267, 'छथर जोरपाटी गाउँपालिका', 'धनकुटा', 'गाउँपालिका', 487),
(2268, 'चौविसे गाउँपालिका', 'धनकुटा', 'गाउँपालिका', 487),
(2269, 'म्याङलुङ नगरपालिका', 'तेहथुम', 'नगरपालिका', 488),
(2270, 'लालीगुराँस नगरपालिका', 'तेहथुम', 'नगरपालिका', 488),
(2271, 'आठराई गाउँपालिका', 'तेहथुम', 'गाउँपालिका', 488),
(2272, 'छथर गाउँपालिका', 'तेहथुम', 'गाउँपालिका', 488),
(2273, 'फेदाप गाउँपालिका', 'तेहथुम', 'गाउँपालिका', 488),
(2274, 'मेन्छयायेम गाउँपालिका', 'तेहथुम', 'गाउँपालिका', 488),
(2275, 'चैनपुर नगरपालिका', 'संखुवासभा', 'नगरपालिका', 489),
(2276, 'धर्मदेवी नगरपालिका', 'संखुवासभा', 'नगरपालिका', 489),
(2277, 'खाँदवारी नगरपालिका', 'संखुवासभा', 'नगरपालिका', 489),
(2278, 'मादी नगरपालिका', 'संखुवासभा', 'नगरपालिका', 489),
(2279, 'पाँचखपन नगरपालिका', 'संखुवासभा', 'नगरपालिका', 489),
(2280, 'भोटखोला गाउँपालिका', 'संखुवासभा', 'गाउँपालिका', 489),
(2281, 'चिचिला गाउँपालिका', 'संखुवासभा', 'गाउँपालिका', 489),
(2282, 'मकालु गाउँपालिका', 'संखुवासभा', 'गाउँपालिका', 489),
(2283, 'सभापोखरी गाउँपालिका', 'संखुवासभा', 'गाउँपालिका', 489),
(2284, 'सिलीचोङ गाउँपालिका', 'संखुवासभा', 'गाउँपालिका', 489),
(2285, 'भोजपुर नगरपालिका', 'भोजपुर', 'नगरपालिका', 490),
(2286, 'षडानन्द नगरपालिका', 'भोजपुर', 'नगरपालिका', 490),
(2287, 'ट्याम्केमैयुम गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2288, 'रामप्रसाद राई गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2289, 'अरुण गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2290, 'पौवादुङमा गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2291, 'साल्पासिलिछो गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2292, 'आमचोक गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2293, 'हतुवागढी गाउँपालिका', 'भोजपुर', 'गाउँपालिका', 490),
(2294, 'सोलुदुधकुण्ड नगरपालिका', 'सोलुखुम्बु', 'नगरपालिका', 491),
(2295, 'दुधकोसी गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2296, 'खुम्वु पासाङल्हमु गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2297, 'दुधकौशिका गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2298, 'नेचासल्यान गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2299, 'माहाकुलुङ गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2300, 'लिखु पिके गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2301, 'सोताङ गाउँपालिका', 'सोलुखुम्बु', 'गाउँपालिका', 491),
(2302, 'सिद्दिचरण नगरपालिका', 'ओखलढुंगा', 'नगरपालिका', 492),
(2303, 'खिजिदेम्बा गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2304, 'चम्पादेवी गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2305, 'चिशंखुगढी गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2306, 'मानेभञ्याङ गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2307, 'मोलुङ गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2308, 'लिखु गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2309, 'सुनकोशी गाउँपालिका', 'ओखलढुंगा', 'गाउँपालिका', 492),
(2310, 'हलेसी तुवाचुङ नगरपालिका', 'खोटाङ', 'नगरपालिका', 493),
(2311, 'रुपाकोट मझुवागढी नगरपालिका', 'खोटाङ', 'नगरपालिका', 493),
(2312, 'ऐसेलुखर्क गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2313, 'लामीडाँडा गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2314, 'जन्तेढुंगा गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2315, 'खोटेहाङ गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2316, 'केपिलासगढी गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2317, 'दिप्रुङ गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2318, 'साकेला गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2319, 'वराहपोखरी गाउँपालिका', 'खोटाङ', 'गाउँपालिका', 493),
(2320, 'कटारी नगरपालिका', 'उदयपुर', 'नगरपालिका', 494),
(2321, 'चौदण्डीगढी नगरपालिका', 'उदयपुर', 'नगरपालिका', 494),
(2322, 'त्रियुगा नगरपालिका', 'उदयपुर', 'नगरपालिका', 494),
(2323, 'वेलका नगरपालिका', 'उदयपुर', 'नगरपालिका', 494),
(2324, 'उदयपुरगढी गाउँपालिका', 'उदयपुर', 'गाउँपालिका', 494),
(2325, 'ताप्ली गाउँपालिका', 'उदयपुर', 'गाउँपालिका', 494),
(2326, 'रौतामाई गाउँपालिका', 'उदयपुर', 'गाउँपालिका', 494),
(2327, 'सुनकोशी गाउँपालिका', 'उदयपुर', 'गाउँपालिका', 494),
(2328, 'राजविराज नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2329, 'कञ्चनरुप नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2330, 'डाक्नेश्वरी नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2331, 'बोदेबरसाईन नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2332, 'खडक नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2333, 'शम्भुनाथ नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2334, 'सुरुङ्‍गा नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2335, 'हनुमाननगर कङ्‌कालिनी नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2336, 'सप्तकोशी नगरपालिका', 'सप्तरी', 'नगरपालिका', 495),
(2337, 'अग्निसाइर कृष्णासवरन गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2338, 'छिन्नमस्ता गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2339, 'महादेवा गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2340, 'तिरहुत गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2341, 'तिलाठी कोईलाडी गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2342, 'रुपनी गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2343, 'बेल्ही चपेना गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2344, 'बिष्णुपुर गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2345, 'बलान-बिहुल गाउँपालिका', 'सप्तरी', 'गाउँपालिका', 495),
(2346, 'लहान नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2347, 'धनगढीमाई नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2348, 'सिरहा नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2349, 'गोलबजार नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2350, 'मिर्चैयाँ नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2351, 'कल्याणपुर नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2352, 'कर्जन्हा नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2353, 'सुखीपुर नगरपालिका', 'सिराहा', 'नगरपालिका', 497),
(2354, 'भगवानपुर गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2355, 'औरही गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2356, 'विष्णुपुर गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2357, 'बरियारपट्टी गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2358, 'लक्ष्मीपुर पतारी गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2359, 'नरहा गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2360, 'सखुवानान्कारकट्टी गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2361, 'अर्नमा गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2362, 'नवराजपुर गाउँपालिका', 'सिराहा', 'गाउँपालिका', 497),
(2363, 'जनकपुर उपमहानगरपालिका', 'धनुषा', 'उपमहानगरपालिका', 498),
(2364, 'क्षिरेश्वरनाथ नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2365, 'गणेशमान चारनाथ नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2366, 'धनुषाधाम नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2367, 'नगराइन नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2368, 'विदेह नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2369, 'मिथिला नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2370, 'शहीदनगर नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2371, 'सबैला नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2372, 'कमला नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2373, 'मिथिला बिहारी नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2374, 'हंसपुर नगरपालिका', 'धनुषा', 'नगरपालिका', 498),
(2375, 'जनकनन्दिनी गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2376, 'बटेश्वर गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2377, 'मुखियापट्टी मुसहरमिया गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2378, 'लक्ष्मीनिया गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2379, 'औरही गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2380, 'धनौजी गाउँपालिका', 'धनुषा', 'गाउँपालिका', 498),
(2381, 'जलेश्वर नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2382, 'बर्दिबास नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2383, 'गौशाला नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2384, 'लोहरपट्टी नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2385, 'रामगोपालपुर नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2386, 'मनरा शिसवा नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2387, 'मटिहानी नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2388, 'भँगाहा नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2389, 'बलवा नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2390, 'औरही नगरपालिका', 'महोत्तरी', 'नगरपालिका', 499),
(2391, 'एकडारा गाउँपालिका', 'महोत्तरी', 'गाउँपालिका', 499),
(2392, 'सोनमा गाउँपालिका', 'महोत्तरी', 'गाउँपालिका', 499),
(2393, 'साम्सी गाउँपालिका', 'महोत्तरी', 'गाउँपालिका', 499),
(2394, 'महोत्तरी गाउँपालिका', 'महोत्तरी', 'गाउँपालिका', 499),
(2395, 'पिपरा गाउँपालिका', 'महोत्तरी', 'गाउँपालिका', 499),
(2396, 'ईश्वरपुर नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2397, 'मलंगवा नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2398, 'लालबन्दी नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2399, 'हरिपुर नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2400, 'हरिपुर्वा नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2401, 'हरिवन नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2402, 'बरहथवा नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2403, 'बलरा नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2404, 'गोडैटा नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2405, 'बागमती नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2406, 'कविलासी नगरपालिका', 'सर्लाही', 'नगरपालिका', 500),
(2407, 'चक्रघट्टा गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2408, 'चन्द्रनगर गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2409, 'धनकौल गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2410, 'ब्रह्मपुरी गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2411, 'रामनगर गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2412, 'विष्णु गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2413, 'कौडेना गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2414, 'पर्सा गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2415, 'बसबरीया गाउँपालिका', 'सर्लाही', 'गाउँपालिका', 500),
(2416, 'चन्द्रपुर नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2417, 'गरुडा नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2418, 'गौर नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2419, 'बौधीमाई नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2420, 'बृन्दावन नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2421, 'देवाही गोनाही नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2422, 'गढीमाई नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2423, 'गुजरा नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2424, 'कटहरिया नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2425, 'माधव नारायण नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2426, 'मौलापुर नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2427, 'फतुवाबिजयपुर नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2428, 'ईशनाथ नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2429, 'परोहा नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2430, 'राजपुर नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2431, 'राजदेवी नगरपालिका', 'रौतहट', 'नगरपालिका', 501),
(2432, 'दुर्गा भगवती गाउँपालिका', 'रौतहट', 'गाउँपालिका', 501),
(2433, 'यमुनामाई गाउँपालिका', 'रौतहट', 'गाउँपालिका', 501),
(2434, 'कलैया उपमहानगरपालिका', 'वारा', 'उपमहानगरपालिका', 502),
(2435, 'जीतपुर सिमरा उपमहानगरपालिका', 'वारा', 'उपमहानगरपालिका', 502),
(2436, 'कोल्हवी नगरपालिका', 'वारा', 'नगरपालिका', 502),
(2437, 'निजगढ नगरपालिका', 'वारा', 'नगरपालिका', 502),
(2438, 'महागढीमाई नगरपालिका', 'वारा', 'नगरपालिका', 502),
(2439, 'सिम्रौनगढ नगरपालिका', 'वारा', 'नगरपालिका', 502),
(2440, 'पचरौता नगरपालिका', 'वारा', 'नगरपालिका', 502),
(2441, 'आदर्श कोटवाल गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2442, 'करैयामाई गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2443, 'देवताल गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2444, 'परवानीपुर गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2445, 'प्रसौनी गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2446, 'फेटा गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2447, 'बारागढीगाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2448, 'सुवर्ण गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2449, 'विश्रामपुर गाउँपालिका', 'वारा', 'गाउँपालिका', 502),
(2450, 'बिरगंज महानगरपालिका', 'पर्सा', 'महानगरपालिका', 503),
(2451, 'पोखरिया नगरपालिका', 'पर्सा', 'नगरपालिका', 503),
(2452, 'बहुदरमाई नगरपालिका', 'पर्सा', 'नगरपालिका', 503),
(2453, 'पर्सागढी नगरपालिका', 'पर्सा', 'नगरपालिका', 503),
(2454, 'ठोरी गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2455, 'जगरनाथपुर गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2456, 'धोबीनी गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2457, 'छिपहरमाई गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2458, 'पकाहा मैनपुर गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2459, 'बिन्दबासिनी गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2460, 'सखुवा प्रसौनी गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2461, 'पटेर्वा सुगौली गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2462, 'कालिकामाई गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2463, 'जिरा भवानी गाउँपालिका', 'पर्सा', 'गाउँपालिका', 503),
(2464, 'कमलामाई नगरपालिका', 'सिन्धुली', 'नगरपालिका', 504),
(2465, 'दुधौली नगरपालिका', 'सिन्धुली', 'नगरपालिका', 504),
(2466, 'गोलन्जर गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2467, 'घ्याङलेख गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2468, 'तीनपाटन गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2469, 'फिक्कल गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2470, 'मरिण गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2471, 'सुनकोशी गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2472, 'हरिहरपुरगढी गाउँपालिका', 'सिन्धुली', 'गाउँपालिका', 504),
(2473, 'मन्थली नगरपालिका', 'रामेछाप', 'नगरपालिका', 505),
(2474, 'रामेछाप नगरपालिका', 'रामेछाप', 'नगरपालिका', 505),
(2475, 'उमाकुण्ड गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2476, 'खाँडादेवी गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2477, 'गोकुलगङ्गा गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2478, 'दोरम्बा गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2479, 'लिखु गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2480, 'सुनापती गाउँपालिका', 'रामेछाप', 'गाउँपालिका', 505),
(2481, 'जिरी नगरपालिका', 'दोलखा', 'नगरपालिका', 506),
(2482, 'भिमेश्वर नगरपालिका', 'दोलखा', 'नगरपालिका', 506),
(2483, 'कालिन्चोक गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2484, 'गौरीशङ्कर गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2485, 'तामाकोशी गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2486, 'मेलुङ्ग गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2487, 'विगु गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2488, 'वैतेश्वर गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2489, 'शैलुङ्ग गाउँपालिका', 'दोलखा', 'गाउँपालिका', 506),
(2490, 'चौतारा साँगाचोकगढी नगरपालिका', 'सिन्धुपाल्चोक', 'नगरपालिका', 507),
(2491, 'बाह्रविसे नगरपालिका', 'सिन्धुपाल्चोक', 'नगरपालिका', 507),
(2492, 'मेलम्ची नगरपालिका', 'सिन्धुपाल्चोक', 'नगरपालिका', 507),
(2493, 'ईन्द्रावती गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2494, 'जुगल गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2495, 'पाँचपोखरी थाङपाल गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2496, 'बलेफी गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2497, 'भोटेकोशी गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2498, 'लिसङ्खु पाखर गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2499, 'सुनकोशी गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2500, 'हेलम्बु गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2501, 'त्रिपुरासुन्दरी गाउँपालिका', 'सिन्धुपाल्चोक', 'गाउँपालिका', 507),
(2502, 'धुलिखेल नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2503, 'बनेपा नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2504, 'पनौती नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2505, 'पाँचखाल नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2506, 'नमोबुद्ध नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2507, 'मण्डनदेउपुर नगरपालिका', 'काभ्रेपलान्चोक', 'नगरपालिका', 508),
(2508, 'खानीखोला गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2509, 'चौंरीदेउराली गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2510, 'तेमाल गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2511, 'बेथानचोक गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2512, 'भुम्लु गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2513, 'महाभारत गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2514, 'रोशी गाउँपालिका', 'काभ्रेपलान्चोक', 'गाउँपालिका', 508),
(2515, 'ललितपुर महानगरपालिका', 'ललितपुर', 'महानगरपालिका', 509),
(2516, 'गोदावरी नगरपालिका', 'ललितपुर', 'नगरपालिका', 509),
(2517, 'महालक्ष्मी नगरपालिका', 'ललितपुर', 'नगरपालिका', 509),
(2518, 'कोन्ज्योसोम गाउँपालिका', 'ललितपुर', 'गाउँपालिका', 509),
(2519, 'बागमती गाउँपालिका', 'ललितपुर', 'गाउँपालिका', 509),
(2520, 'महाङ्काल गाउँपालिका', 'ललितपुर', 'गाउँपालिका', 509),
(2521, 'चाँगुनारायण नगरपालिका', 'भक्तपुर', 'नगरपालिका', 510),
(2522, 'भक्तपुर नगरपालिका', 'भक्तपुर', 'नगरपालिका', 510),
(2523, 'मध्यपुर थिमी नगरपालिका', 'भक्तपुर', 'नगरपालिका', 510),
(2524, 'सूर्यविनायक नगरपालिका', 'भक्तपुर', 'नगरपालिका', 510),
(2525, 'काठमाण्डौं महानगरपालिका', 'काठमाण्डौ', 'महानगरपालिका', 511),
(2526, 'कागेश्वरी मनोहरा नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2527, 'कीर्तिपुर नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2528, 'गोकर्णेश्वर नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2529, 'चन्द्रागिरी नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2530, 'टोखा नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2531, 'तारकेश्वर नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2532, 'दक्षिणकाली नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2533, 'नागार्जुन नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2534, 'बुढानिलकण्ठ नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2535, 'शङ्खरापुर नगरपालिका', 'काठमाण्डौ', 'नगरपालिका', 511),
(2536, 'विदुर नगरपालिका', 'नुवाकोट', 'नगरपालिका', 512),
(2537, 'बेलकोटगढी नगरपालिका', 'नुवाकोट', 'नगरपालिका', 512),
(2538, 'ककनी गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2539, 'किस्पाङ गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2540, 'तादी गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2541, 'तारकेश्वर गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2542, 'दुप्चेश्वर गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2543, 'पञ्चकन्या गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2544, 'लिखु गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2545, 'मेघाङ गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2546, 'शिवपुरी गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2547, 'सुर्यगढी गाउँपालिका', 'नुवाकोट', 'गाउँपालिका', 512),
(2548, 'उत्तरगया गाउँपालिका', 'रसुवा', 'गाउँपालिका', 513),
(2549, 'कालिका गाउँपालिका', 'रसुवा', 'गाउँपालिका', 513),
(2550, 'गोसाईकुण्ड गाउँपालिका', 'रसुवा', 'गाउँपालिका', 513),
(2551, 'नौकुण्ड गाउँपालिका', 'रसुवा', 'गाउँपालिका', 513),
(2552, 'पार्वतीकुण्ड गाउँपालिका', 'रसुवा', 'गाउँपालिका', 513),
(2553, 'धुनीबेंशी नगरपालिका', 'धादिङ', 'नगरपालिका', 514),
(2554, 'निलकण्ठ नगरपालिका', 'धादिङ', 'नगरपालिका', 514),
(2555, 'खनियाबास गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2556, 'गजुरी गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2557, 'गल्छी गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2558, 'गङ्गाजमुना गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2559, 'ज्वालामूखी गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2560, 'थाक्रे गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2561, 'नेत्रावति गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2562, 'बेनीघाट रोराङ्ग गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2563, 'रुवी भ्याली गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2564, 'सिद्धलेक गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2565, 'त्रिपुरासुन्दरी गाउँपालिका', 'धादिङ', 'गाउँपालिका', 514),
(2566, 'हेटौडा उपमहानगरपालिका', 'मकवानपुर', 'उपमहानगरपालिका', 515),
(2567, 'थाहा नगरपालिका', 'मकवानपुर', 'नगरपालिका', 515),
(2568, 'इन्द्रसरोबर गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2569, 'कैलाश गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2570, 'बकैया गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2571, 'बाग्मति गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2572, 'भिमफेदी गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2573, 'मकवानपुरगढी गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2574, 'मनहरी गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2575, 'राक्सिराङ्ग गाउँपालिका', 'मकवानपुर', 'गाउँपालिका', 515),
(2576, 'भरतपुर महानगरपालिका', 'चितवन', 'महानगरपालिका', 516),
(2577, 'कालिका नगरपालिका', 'चितवन', 'नगरपालिका', 516),
(2578, 'खैरहनी नगरपालिका', 'चितवन', 'नगरपालिका', 516),
(2579, 'माडी नगरपालिका', 'चितवन', 'नगरपालिका', 516),
(2580, 'रत्ननगर नगरपालिका', 'चितवन', 'नगरपालिका', 516),
(2581, 'राप्ती नगरपालिका', 'चितवन', 'नगरपालिका', 516),
(2582, 'इच्छाकामना गाउँपालिका', 'चितवन', 'गाउँपालिका', 516),
(2583, 'गोरखा नगरपालिका', 'गोरखा', 'नगरपालिका', 517),
(2584, 'पालुङटार नगरपालिका', 'गोरखा', 'नगरपालिका', 517),
(2585, 'सुलीकोट गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2586, 'सिरानचोक गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2587, 'अजिरकोट गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2588, 'आरूघाट गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2589, 'गण्डकी गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2590, 'चुमनुव्री गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2591, 'धार्चे गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2592, 'भिमसेन गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2593, 'शहिद लखन गाउँपालिका', 'गोरखा', 'गाउँपालिका', 517),
(2594, 'बेसीशहर नगरपालिका', 'लमजुङ', 'नगरपालिका', 518),
(2595, 'मध्यनेपाल नगरपालिका', 'लमजुङ', 'नगरपालिका', 518),
(2596, 'रार्इनास नगरपालिका', 'लमजुङ', 'नगरपालिका', 518),
(2597, 'सुन्दरबजार नगरपालिका', 'लमजुङ', 'नगरपालिका', 518),
(2598, 'क्व्होलासोथार गाउँपालिका', 'लमजुङ', 'गाउँपालिका', 518),
(2599, 'दूधपोखरी गाउँपालिका', 'लमजुङ', 'गाउँपालिका', 518),
(2600, 'दोर्दी गाउँपालिका', 'लमजुङ', 'गाउँपालिका', 518),
(2601, 'मर्स्याङदी गाउँपालिका', 'लमजुङ', 'गाउँपालिका', 518),
(2602, 'भानु नगरपालिका', 'तनहुँ', 'नगरपालिका', 519),
(2603, 'भिमाद नगरपालिका', 'तनहुँ', 'नगरपालिका', 519),
(2604, 'व्यास नगरपालिका', 'तनहुँ', 'नगरपालिका', 519),
(2605, 'शुक्लागण्डकी नगरपालिका', 'तनहुँ', 'नगरपालिका', 519),
(2606, 'आँबुखैरेनी गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2607, 'ऋषिङ्ग गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2608, 'घिरिङ गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2609, 'देवघाट गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2610, 'म्याग्दे गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2611, 'वन्दिपुर गाउँपालिका', 'तनहुँ', 'गाउँपालिका', 519),
(2612, 'गल्याङ नगरपालिका', 'स्याङजा', 'नगरपालिका', 520),
(2613, 'चापाकोट नगरपालिका', 'स्याङजा', 'नगरपालिका', 520),
(2614, 'पुतलीबजार नगरपालिका', 'स्याङजा', 'नगरपालिका', 520),
(2615, 'भीरकोट नगरपालिका', 'स्याङजा', 'नगरपालिका', 520),
(2616, 'वालिङ नगरपालिका', 'स्याङजा', 'नगरपालिका', 520),
(2617, 'अर्जुनचौपारी गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2618, 'आँधिखोला गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2619, 'कालीगण्डकी गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2620, 'फेदीखोला गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2621, 'बिरुवा गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2622, 'हरिनास गाउँपालिका', 'स्याङजा', 'गाउँपालिका', 520),
(2623, 'पोखरा लेखनाथ महानगरपालिका', 'कास्की', 'महानगरपालिका', 521),
(2624, 'अन्नपूर्ण गाउँपालिका', 'कास्की', 'गाउँपालिका', 521),
(2625, 'माछापुच्छ्रे गाउँपालिका', 'कास्की', 'गाउँपालिका', 521),
(2626, 'मादी गाउँपालिका', 'कास्की', 'गाउँपालिका', 521),
(2627, 'रूपा गाउँपालिका', 'कास्की', 'गाउँपालिका', 521),
(2628, 'चामे गाउँपालिका', 'मनाङ', 'गाउँपालिका', 0),
(2629, 'नारफू गाउँपालिका', 'मनाङ', 'गाउँपालिका', 0),
(2630, 'नाशोङ गाउँपालिका', 'मनाङ', 'गाउँपालिका', 0),
(2631, 'नेस्याङ गाउँपालिका', 'मनाङ', 'गाउँपालिका', 0),
(2632, 'घरपझोङ गाउँपालिका', 'मुस्ताङ', 'गाउँपालिका', 522),
(2633, 'थासाङ गाउँपालिका', 'मुस्ताङ', 'गाउँपालिका', 522),
(2634, 'दालोमे गाउँपालिका', 'मुस्ताङ', 'गाउँपालिका', 522),
(2635, 'लोमन्थाङ गाउँपालिका', 'मुस्ताङ', 'गाउँपालिका', 522),
(2636, 'वाह्रगाउँ मुक्तिक्षेत्र गाउँपालिका', 'मुस्ताङ', 'गाउँपालिका', 522),
(2637, 'बेनी नगरपालिका', 'म्याग्दी', 'नगरपालिका', 523),
(2638, 'अन्नपूर्ण गाउँपालिका', 'म्याग्दी', 'गाउँपालिका', 523),
(2639, 'धवलागिरी गाउँपालिका', 'म्याग्दी', 'गाउँपालिका', 523),
(2640, 'मंगला गाउँपालिका', 'म्याग्दी', 'गाउँपालिका', 523),
(2641, 'मालिका गाउँपालिका', 'म्याग्दी', 'गाउँपालिका', 523),
(2642, 'रघुगंगा गाउँपालिका', 'म्याग्दी', 'गाउँपालिका', 523),
(2643, 'कुश्मा नगरपालिका', 'पर्वत', 'नगरपालिका', 524),
(2644, 'फलेवास नगरपालिका', 'पर्वत', 'नगरपालिका', 524),
(2645, 'जलजला गाउँपालिका', 'पर्वत', 'गाउँपालिका', 524),
(2646, 'पैयूं गाउँपालिका', 'पर्वत', 'गाउँपालिका', 524),
(2647, 'महाशिला गाउँपालिका', 'पर्वत', 'गाउँपालिका', 524),
(2648, 'मोदी गाउँपालिका', 'पर्वत', 'गाउँपालिका', 524),
(2649, 'विहादी गाउँपालिका', 'पर्वत', 'गाउँपालिका', 524),
(2650, 'बागलुङ नगरपालिका', 'वाग्लुङ', 'नगरपालिका', 525),
(2651, 'गल्कोट नगरपालिका', 'वाग्लुङ', 'नगरपालिका', 525),
(2652, 'जैमूनी नगरपालिका', 'वाग्लुङ', 'नगरपालिका', 525),
(2653, 'ढोरपाटन नगरपालिका', 'वाग्लुङ', 'नगरपालिका', 525),
(2654, 'वरेङ गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2655, 'काठेखोला गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2656, 'तमानखोला गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2657, 'ताराखोला गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2658, 'निसीखोला गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2659, 'वडिगाड गाउँपालिका', 'वाग्लुङ', 'गाउँपालिका', 525),
(2660, 'कावासोती नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'नगरपालिका', 526),
(2661, 'गैडाकोट नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'नगरपालिका', 526),
(2662, 'देवचुली नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'नगरपालिका', 526),
(2663, 'मध्यविन्दु नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'नगरपालिका', 526),
(2664, 'बुङ्दीकाली गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'गाउँपालिका', 526),
(2665, 'बुलिङटार गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'गाउँपालिका', 526),
(2666, 'विनयी त्रिवेणी गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'गाउँपालिका', 526),
(2667, 'हुप्सेकोट गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पूर्व)', 'गाउँपालिका', 526),
(2668, 'मुसिकोट नगरपालिका', 'गुल्मी', 'नगरपालिका', 527),
(2669, 'रेसुङ्गा नगरपालिका', 'गुल्मी', 'नगरपालिका', 527),
(2670, 'ईस्मा गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2671, 'कालीगण्डकी गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2672, 'गुल्मी दरबार गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2673, 'सत्यवती गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2674, 'चन्द्रकोट गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2675, 'रुरु गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2676, 'छत्रकोट गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2677, 'धुर्कोट गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2678, 'मदाने गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2679, 'मालिका गाउँपालिका', 'गुल्मी', 'गाउँपालिका', 527),
(2680, 'रामपुर नगरपालिका', 'पाल्पा', 'नगरपालिका', 528),
(2681, 'तानसेन नगरपालिका', 'पाल्पा', 'नगरपालिका', 528),
(2682, 'निस्दी गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2683, 'पूर्वखोला गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2684, 'रम्भा गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2685, 'माथागढी गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2686, 'तिनाउ गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2687, 'बगनासकाली गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2688, 'रिब्दिकोट गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2689, 'रैनादेवी छहरा गाउँपालिका', 'पाल्पा', 'गाउँपालिका', 528),
(2690, 'बुटवल उपमहानगरपालिका', 'रुपन्देही', 'उपमहानगरपालिका', 529),
(2691, 'देवदह नगरपालिका', 'रुपन्देही', 'नगरपालिका', 529),
(2692, 'लुम्बिनी सांस्कृतिक नगरपालिका', 'रुपन्देही', 'नगरपालिका', 529),
(2693, 'सैनामैना नगरपालिका', 'रुपन्देही', 'नगरपालिका', 529),
(2694, 'सिद्धार्थनगर नगरपालिका', 'रुपन्देही', 'नगरपालिका', 529),
(2695, 'तिलोत्तमा नगरपालिका', 'रुपन्देही', 'नगरपालिका', 529),
(2696, 'गैडहवा गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2697, 'कन्चन गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2698, 'कोटहीमाई गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2699, 'मर्चवारी गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2700, 'मायादेवी गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2701, 'ओमसतिया गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2702, 'रोहिणी गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2703, 'सम्मरीमाई गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2704, 'सियारी गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2705, 'शुद्धोधन गाउँपालिका', 'रुपन्देही', 'गाउँपालिका', 529),
(2706, 'कपिलवस्तु नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2707, 'बुद्धभूमी नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2708, 'शिवराज नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2709, 'महाराजगंज नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2710, 'कृष्णनगर नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2711, 'बाणगंगा नगरपालिका', 'कपिलबस्तु', 'नगरपालिका', 530),
(2712, 'मायादेवी गाउँपालिका', 'कपिलबस्तु', 'गाउँपालिका', 530),
(2713, 'यसोधरा गाउँपालिका', 'कपिलबस्तु', 'गाउँपालिका', 530),
(2714, 'सुद्धोधन गाउँपालिका', 'कपिलबस्तु', 'गाउँपालिका', 530),
(2715, 'विजयनगर गाउँपालिका', 'कपिलबस्तु', 'गाउँपालिका', 530),
(2716, 'सन्धिखर्क नगरपालिका', 'अर्घाखाँची', 'नगरपालिका', 531),
(2717, 'शितगंगा नगरपालिका', 'अर्घाखाँची', 'नगरपालिका', 531),
(2718, 'भूमिकास्थान नगरपालिका', 'अर्घाखाँची', 'नगरपालिका', 531),
(2719, 'छत्रदेव गाउँपालिका', 'अर्घाखाँची', 'गाउँपालिका', 531),
(2720, 'पाणिनी गाउँपालिका', 'अर्घाखाँची', 'गाउँपालिका', 531),
(2721, 'मालारानी गाउँपालिका', 'अर्घाखाँची', 'गाउँपालिका', 531),
(2722, 'प्यूठान नगरपालिका', 'प्यूठान', 'नगरपालिका', 532),
(2723, 'स्वर्गद्वारी नगरपालिका', 'प्यूठान', 'नगरपालिका', 532),
(2724, 'गौमुखी गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2725, 'माण्डवी गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2726, 'सरुमारानी गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2727, 'मल्लरानी गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2728, 'नौवहिनी गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2729, 'झिमरुक गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2730, 'ऐरावती गाउँपालिका', 'प्यूठान', 'गाउँपालिका', 532),
(2731, 'रोल्पा नगरपालिका', 'रोल्पा', 'नगरपालिका', 533),
(2732, 'त्रिवेणी गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2733, 'दुईखोली गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2734, 'माडी गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2735, 'रुन्टीगढी गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2736, 'लुङग्री गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2737, 'सुकिदह गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2738, 'सुनछहरी गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2739, 'सुवर्णावती गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2740, 'थवाङ गाउँपालिका', 'रोल्पा', 'गाउँपालिका', 533),
(2741, 'पुथा उत्तरगंगा गाउँपालिका', 'रुकुम (पूर्वी भाग)', 'गाउँपालिका', 534),
(2742, 'भूमे गाउँपालिका', 'रुकुम (पूर्वी भाग)', 'गाउँपालिका', 534),
(2743, 'सिस्ने गाउँपालिका', 'रुकुम (पूर्वी भाग)', 'गाउँपालिका', 534),
(2744, 'तुल्सीपुर उपमहानगरपालिका', 'दाङ', 'उपमहानगरपालिका', 535),
(2745, 'घोराही उपमहानगरपालिका', 'दाङ', 'उपमहानगरपालिका', 535),
(2746, 'लमही नगरपालिका', 'दाङ', 'नगरपालिका', 535),
(2747, 'बंगलाचुली गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2748, 'दंगीशरण गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2749, 'गढवा गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2750, 'राजपुर गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2751, 'राप्ती गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2752, 'शान्तिनगर गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2753, 'बबई गाउँपालिका', 'दाङ', 'गाउँपालिका', 535),
(2754, 'नेपालगंज उपमहानगरपालिका', 'बाँके', 'उपमहानगरपालिका', 536),
(2755, 'कोहलपुर नगरपालिका', 'बाँके', 'नगरपालिका', 536),
(2756, 'नरैनापुर गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2757, 'राप्तीसोनारी गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2758, 'बैजनाथ गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2759, 'खजुरा गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2760, 'डुडुवा गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2761, 'जानकी गाउँपालिका', 'बाँके', 'गाउँपालिका', 536),
(2762, 'गुलरिया नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2763, 'मधुवन नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2764, 'राजापुर नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2765, 'ठाकुरबाबा नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2766, 'बाँसगढी नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2767, 'बारबर्दिया नगरपालिका', 'बर्दिया', 'नगरपालिका', 537),
(2768, 'बढैयाताल गाउँपालिका', 'बर्दिया', 'गाउँपालिका', 537),
(2769, 'गेरुवा गाउँपालिका', 'बर्दिया', 'गाउँपालिका', 537),
(2770, 'बर्दघाट नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'नगरपालिका', 538),
(2771, 'रामग्राम नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'नगरपालिका', 538),
(2772, 'सुनवल नगरपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'नगरपालिका', 538),
(2773, 'सुस्ता गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'गाउँपालिका', 538),
(2774, 'पाल्हीनन्दन गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'गाउँपालिका', 538),
(2775, 'प्रतापपुर गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'गाउँपालिका', 538),
(2776, 'सरावल गाउँपालिका', 'नवलपरासी (बर्दघाट सुस्ता पश्चिम)', 'गाउँपालिका', 538),
(2777, 'मुसिकोट नगरपालिका', 'रुकुम (पश्चिम भाग)', 'नगरपालिका', 539),
(2778, 'चौरजहारी नगरपालिका', 'रुकुम (पश्चिम भाग)', 'नगरपालिका', 539),
(2779, 'आठबिसकोट नगरपालिका', 'रुकुम (पश्चिम भाग)', 'नगरपालिका', 539),
(2780, 'बाँफिकोट गाउँपालिका', 'रुकुम (पश्चिम भाग)', 'गाउँपालिका', 539),
(2781, 'त्रिवेणी गाउँपालिका', 'रुकुम (पश्चिम भाग)', 'गाउँपालिका', 539),
(2782, 'सानी भेरी गाउँपालिका', 'रुकुम (पश्चिम भाग)', 'गाउँपालिका', 539),
(2783, 'शारदा नगरपालिका', 'सल्यान', 'नगरपालिका', 540),
(2784, 'बागचौर नगरपालिका', 'सल्यान', 'नगरपालिका', 540),
(2785, 'बनगाड कुपिण्डे नगरपालिका', 'सल्यान', 'नगरपालिका', 540),
(2786, 'कालिमाटी गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2787, 'त्रिवेणी गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2788, 'कपुरकोट गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2789, 'छत्रेश्वरी गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2790, 'ढोरचौर गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2791, 'कुमाखमालिका गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2792, 'दार्मा गाउँपालिका', 'सल्यान', 'गाउँपालिका', 540),
(2793, 'बीरेन्द्रनगर नगरपालिका', 'सुर्खेत', 'नगरपालिका', 541),
(2794, 'भेरीगंगा नगरपालिका', 'सुर्खेत', 'नगरपालिका', 541),
(2795, 'गुर्भाकोट नगरपालिका', 'सुर्खेत', 'नगरपालिका', 541),
(2796, 'पञ्चपुरी नगरपालिका', 'सुर्खेत', 'नगरपालिका', 541),
(2797, 'लेकवेशी नगरपालिका', 'सुर्खेत', 'नगरपालिका', 541),
(2798, 'चौकुने गाउँपालिका', 'सुर्खेत', 'गाउँपालिका', 541),
(2799, 'बराहताल गाउँपालिका', 'सुर्खेत', 'गाउँपालिका', 541),
(2800, 'चिङ्गाड गाउँपालिका', 'सुर्खेत', 'गाउँपालिका', 541),
(2801, 'सिम्ता गाउँपालिका', 'सुर्खेत', 'गाउँपालिका', 541),
(2802, 'नारायण नगरपालिका', 'दैलेख', 'नगरपालिका', 542),
(2803, 'दुल्लु नगरपालिका', 'दैलेख', 'नगरपालिका', 542),
(2804, 'चामुण्डा विन्द्रासैनी नगरपालिका', 'दैलेख', 'नगरपालिका', 542),
(2805, 'आठबीस नगरपालिका', 'दैलेख', 'नगरपालिका', 542),
(2806, 'भगवतीमाई गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2807, 'गुराँस गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2808, 'डुंगेश्वर गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2809, 'नौमुले गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2810, 'महावु गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2811, 'भैरवी गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2812, 'ठाँटीकाँध गाउँपालिका', 'दैलेख', 'गाउँपालिका', 542),
(2813, 'भेरी नगरपालिका', 'जाजरकोट', 'नगरपालिका', 543),
(2814, 'छेडागाड नगरपालिका', 'जाजरकोट', 'नगरपालिका', 543),
(2815, 'त्रिवेणी नलगाड नगरपालिका', 'जाजरकोट', 'नगरपालिका', 543),
(2816, 'बारेकोट गाउँपालिका', 'जाजरकोट', 'गाउँपालिका', 543),
(2817, 'कुसे गाउँपालिका', 'जाजरकोट', 'गाउँपालिका', 543),
(2818, 'जुनीचाँदे गाउँपालिका', 'जाजरकोट', 'गाउँपालिका', 543),
(2819, 'शिवालय गाउँपालिका', 'जाजरकोट', 'गाउँपालिका', 543),
(2820, 'ठुली भेरी नगरपालिका', 'डोल्पा', 'नगरपालिका', 544),
(2821, 'त्रिपुरासुन्दरी नगरपालिका', 'डोल्पा', 'नगरपालिका', 544),
(2822, 'डोल्पो बुद्ध गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2823, 'शे फोक्सुन्डो गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2824, 'जगदुल्ला गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2825, 'मुड्केचुला गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2826, 'काईके गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2827, 'छार्का ताङसोङ गाउँपालिका', 'डोल्पा', 'गाउँपालिका', 544),
(2828, 'चन्दननाथ नगरपालिका', 'जुम्ला', 'नगरपालिका', 545),
(2829, 'कनकासुन्दरी गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2830, 'सिंजा गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2831, 'हिमा गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2832, 'तिला गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2833, 'गुठिचौर गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2834, 'तातोपानी गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2835, 'पातारासी गाउँपालिका', 'जुम्ला', 'गाउँपालिका', 545),
(2836, 'खाँडाचक्र नगरपालिका', 'कालिकोट', 'नगरपालिका', 546),
(2837, 'रास्कोट नगरपालिका', 'कालिकोट', 'नगरपालिका', 546),
(2838, 'तिलागुफा नगरपालिका', 'कालिकोट', 'नगरपालिका', 546),
(2839, 'पचालझरना गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2840, 'सान्नी त्रिवेणी गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2841, 'नरहरिनाथ गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2842, 'कालिका गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2843, 'महावै गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2844, 'पलाता गाउँपालिका', 'कालिकोट', 'गाउँपालिका', 546),
(2845, 'छायाँनाथ रारा नगरपालिका', 'मुगु', 'नगरपालिका', 547),
(2846, 'मुगुम कार्मारोंग गाउँपालिका', 'मुगु', 'गाउँपालिका', 547),
(2847, 'सोरु गाउँपालिका', 'मुगु', 'गाउँपालिका', 547),
(2848, 'खत्याड गाउँपालिका', 'मुगु', 'गाउँपालिका', 547),
(2849, 'सिमकोट गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2850, 'नाम्खा गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2851, 'खार्पुनाथ गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2852, 'सर्केगाड गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2853, 'चंखेली गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2854, 'अदानचुली गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2855, 'ताँजाकोट गाउँपालिका', 'हुम्ला', 'गाउँपालिका', 548),
(2856, 'बडीमालिका नगरपालिका', 'बाजुरा', 'नगरपालिका', 549),
(2857, 'त्रिवेणी नगरपालिका', 'बाजुरा', 'नगरपालिका', 549),
(2858, 'बुढीगंगा नगरपालिका', 'बाजुरा', 'नगरपालिका', 549),
(2859, 'बुढीनन्दा नगरपालिका', 'बाजुरा', 'नगरपालिका', 549),
(2860, 'गौमुल गाउँपालिका', 'बाजुरा', 'गाउँपालिका', 549),
(2861, 'पाण्डव गुफा गाउँपालिका', 'बाजुरा', 'गाउँपालिका', 549),
(2862, 'स्वामीकार्तिक गाउँपालिका', 'बाजुरा', 'गाउँपालिका', 549),
(2863, 'छेडेदह गाउँपालिका', 'बाजुरा', 'गाउँपालिका', 549),
(2864, 'हिमाली गाउँपालिका', 'बाजुरा', 'गाउँपालिका', 549),
(2865, 'जयपृथ्वी नगरपालिका', 'बझाङ', 'नगरपालिका', 550),
(2866, 'बुंगल नगरपालिका', 'बझाङ', 'नगरपालिका', 550),
(2867, 'तलकोट गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2868, 'मष्टा गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2869, 'खप्तडछान्ना गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2870, 'थलारा गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2871, 'वित्थडचिर गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2872, 'सूर्मा गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2873, 'छबिसपाथिभेरा गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2874, 'दुर्गाथली गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2875, 'केदारस्युँ गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2876, 'काँडा गाउँपालिका', 'बझाङ', 'गाउँपालिका', 550),
(2877, 'मंगलसेन नगरपालिका', 'अछाम', 'नगरपालिका', 551),
(2878, 'कमलबजार नगरपालिका', 'अछाम', 'नगरपालिका', 551),
(2879, 'साँफेबगर नगरपालिका', 'अछाम', 'नगरपालिका', 551),
(2880, 'पन्चदेवल विनायक नगरपालिका', 'अछाम', 'नगरपालिका', 551),
(2881, 'चौरपाटी गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2882, 'मेल्लेख गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2883, 'बान्निगढी जयगढ गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2884, 'रामारोशन गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2885, 'ढकारी गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2886, 'तुर्माखाँद गाउँपालिका', 'अछाम', 'गाउँपालिका', 551),
(2887, 'दिपायल सिलगढी नगरपालिका', 'डोटी', 'नगरपालिका', 552),
(2888, 'शिखर नगरपालिका', 'डोटी', 'नगरपालिका', 552),
(2889, 'पूर्वीचौकी गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2890, 'बडीकेदार गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2891, 'जोरायल गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2892, 'सायल गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2893, 'आदर्श गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2894, 'के.आई.सिं. गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2895, 'बोगटान गाउँपालिका', 'डोटी', 'गाउँपालिका', 552),
(2896, 'धनगढी उपमहानगरपालिका', 'कैलाली', 'उपमहानगरपालिका', 553),
(2897, 'टिकापुर नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2898, 'घोडाघोडी नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2899, 'लम्कीचुहा नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2900, 'भजनी नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2901, 'गोदावरी नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2902, 'गौरीगंगा नगरपालिका', 'कैलाली', 'नगरपालिका', 553),
(2903, 'जानकी गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2904, 'बर्दगोरिया गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2905, 'मोहन्याल गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2906, 'कैलारी गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2907, 'जोशीपुर गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2908, 'चुरे गाउँपालिका', 'कैलाली', 'गाउँपालिका', 553),
(2909, 'भीमदत्त नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2910, 'पुर्नवास नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2911, 'वेदकोट नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2912, 'महाकाली नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2913, 'शुक्लाफाँटा नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2914, 'बेलौरी नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2915, 'कृष्णपुर नगरपालिका', 'कञ्चनपुर', 'नगरपालिका', 554),
(2916, 'बेलडाडी गाउँपालिका', 'कञ्चनपुर', 'गाउँपालिका', 554),
(2917, 'लालझाडी गाउँपालिका', 'कञ्चनपुर', 'गाउँपालिका', 554),
(2918, 'अमरगढी नगरपालिका', 'डडेलधुरा', 'नगरपालिका', 555),
(2919, 'परशुराम नगरपालिका', 'डडेलधुरा', 'नगरपालिका', 555),
(2920, 'आलिताल गाउँपालिका', 'डडेलधुरा', 'गाउँपालिका', 555),
(2921, 'भागेश्वर गाउँपालिका', 'डडेलधुरा', 'गाउँपालिका', 555),
(2922, 'नवदुर्गा गाउँपालिका', 'डडेलधुरा', 'गाउँपालिका', 555),
(2923, 'अजयमेरु गाउँपालिका', 'डडेलधुरा', 'गाउँपालिका', 555),
(2924, 'गन्यापधुरा गाउँपालिका', 'डडेलधुरा', 'गाउँपालिका', 555),
(2925, 'दशरथचन्द नगरपालिका', 'बैतडी', 'नगरपालिका', 556),
(2926, 'पाटन नगरपालिका', 'बैतडी', 'नगरपालिका', 556),
(2927, 'मेलौली नगरपालिका', 'बैतडी', 'नगरपालिका', 556),
(2928, 'पुर्चौडी नगरपालिका', 'बैतडी', 'नगरपालिका', 556),
(2929, 'सुर्नया गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2930, 'सिगास गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2931, 'शिवनाथ गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2932, 'पञ्चेश्वर गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2933, 'दोगडाकेदार गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2934, 'डीलासैनी गाउँपालिका', 'बैतडी', 'गाउँपालिका', 556),
(2935, 'महाकाली नगरपालिका', 'दार्चुला', 'नगरपालिका', 557),
(2936, 'शैल्यशिखर नगरपालिका', 'दार्चुला', 'नगरपालिका', 557),
(2937, 'मालिकार्जुन गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2938, 'अपिहिमाल गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2939, 'दुहुँ गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2940, 'नौगाड गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2941, 'मार्मा गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2942, 'लेकम गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2943, 'ब्याँस गाउँपालिका', 'दार्चुला', 'गाउँपालिका', 557),
(2944, 'नमुना गाउँपालिका', 'काठमाडौं', 'गाउँपालिका', 0),
(2945, 'नमुना नगरपालिका ', 'नमुना', 'नगरपालिका', 0);

-- --------------------------------------------------------

--
-- Table structure for table `settings_ward`
--

CREATE TABLE IF NOT EXISTS `settings_ward` (
  `id` int(11) NOT NULL,
  `name` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `settings_ward`
--

INSERT INTO `settings_ward` (`id`, `name`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(15, 14),
(16, 15),
(17, 16),
(18, 17),
(19, 18),
(20, 19),
(21, 20),
(22, 21),
(23, 22),
(24, 23),
(25, 24),
(26, 25),
(27, 26),
(28, 27),
(29, 28),
(30, 29),
(31, 30),
(32, 31),
(33, 32),
(34, 33),
(35, 34),
(36, 35);

-- --------------------------------------------------------

--
-- Table structure for table `set_up`
--

CREATE TABLE IF NOT EXISTS `set_up` (
  `id` int(11) NOT NULL,
  `palika_name` varchar(255) NOT NULL,
  `palika_name_en` varchar(255) NOT NULL,
  `karay_palika_np` varchar(255) NOT NULL,
  `karay_palika_en` varchar(255) NOT NULL,
  `state_np` varchar(255) NOT NULL,
  `state_en` varchar(255) NOT NULL,
  `district_np` varchar(255) NOT NULL,
  `district_en` varchar(255) NOT NULL,
  `office_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `office_address_en` int(11) DEFAULT NULL,
  `sarkar_logo` varchar(255) NOT NULL,
  `palika_logo` varchar(255) NOT NULL,
  `palika_slogan` varchar(255) NOT NULL,
  `palika_slogan_en` varchar(255) NOT NULL,
  `website` varchar(255) NOT NULL,
  `phone_no` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `facebook` varchar(255) NOT NULL,
  `created_at` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `set_up`
--

INSERT INTO `set_up` (`id`, `palika_name`, `palika_name_en`, `karay_palika_np`, `karay_palika_en`, `state_np`, `state_en`, `district_np`, `district_en`, `office_address`, `office_address_en`, `sarkar_logo`, `palika_logo`, `palika_slogan`, `palika_slogan_en`, `website`, `phone_no`, `email`, `facebook`, `created_at`) VALUES
(1, 'गल्छी गाउँपालिका', 'Galchhi Rural Municipality', 'गाउँ कार्यपालिकाको कार्यालय', 'Office of Municipality Executive', 'बागमती प्रदेश', 'Bagmati Province', 'धादिङ', 'Dhading', 'गल्छी', NULL, 'npl.png', 'GalchhiLogo.png', '-', 'A government big enough to give you everything you want is a government big enough to take from you everything you have.', '-', 2147483647, 'galchhi@gmail.co', '-', '2024-08-09 04:52:08pm');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE IF NOT EXISTS `staff` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `designation` varchar(255) NOT NULL,
  `use_sign` int(11) DEFAULT NULL,
  `mobile` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('1','2') NOT NULL DEFAULT '1' COMMENT '''1= active, 2=inactive''',
  `remarks` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tok_aadesh`
--

CREATE TABLE IF NOT EXISTS `tok_aadesh` (
  `id` int(11) NOT NULL,
  `tok_aadesh` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `letter_type` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tok_aadesh`
--

INSERT INTO `tok_aadesh` (`id`, `tok_aadesh`, `letter_type`) VALUES
(1, '\r\nयसमा  पाना २ को निवेदन पत्र स्थानीय संचालन ऐन, २०७४ को दफा ४७ (१)/(२) भित्रको देखिएकोले दर्ता गरि नियमानुसार गर्नु  ', 1),
(2, 'चाँगुनारायण नगरपालिका न्यायिक समितिमा पाना २ को प्रतिउत्तर पत्र म्याद भित्र परेको देखिदा दायरी किताकमा दर्ता गरी मिसिल सामेल पारी नियमानुसार ईजलाश समक्ष पेश गर्नु ।', 5),
(3, 'चाँगुनारायण नगरपालिका न्यायिक समिति बाट\r\nयसमा वादी प्रतिवादीको  संयुक्त दर्खास्थपत्र पेश भएकोले सो मा लेखिएबमोजिम मिलापत्रको कागज तयार गरी ईजलाश समक्ष पेश गर्नु । ', 9),
(4, 'चाँगुनारायण नगरपालिका न्यायिक समितिबाट यो पान.....को निवेदन  बेहोरा पढीबाची सुनाउदा दर्ता गर्न मन्जुर छ भनि निवेदकले सहिछाप गरिदिएकोले स्थानिय सरकार सञन्चालन ऐन,२०७४ को दफा ४७ को उपदफा (१) सँग सम्बन्धित विवाद भएको हुँदा निवेदन दस्तुर बापत रु १०० लिई प्रस्तुत विवाद देवानी दायरीमा दर्ता गर्नु । प्रतिवादीका नाउँमा कानूनबमोजिम म्याद जारी गरी रीतपूर्वक तामेल भई लिखित बेहोरा परे वा पर्ने अवधि नाघेपछि नियमानुसार न्यायिक समितिको बैठकमा पेश गर्नु ।\r\n        ', 1);

-- --------------------------------------------------------

--
-- Table structure for table `userlog`
--

CREATE TABLE IF NOT EXISTS `userlog` (
  `logid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `log_time` varchar(255) NOT NULL,
  `action` enum('login','logout') NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `userlog`
--

INSERT INTO `userlog` (`logid`, `userid`, `log_time`, `action`) VALUES
(1, 1, '2024-08-09 16:36:46', 'login'),
(2, 2, '2024-08-09 16:39:21', 'login'),
(3, 2, '2024-08-09 16:39:25', 'login'),
(4, 2, '2024-08-09 16:40:38', 'login'),
(5, 2, '2024-08-14 11:33:12', 'login'),
(6, 2, '2024-08-27 15:19:36', 'login'),
(7, 2, '2024-08-28 13:43:01', 'login'),
(8, 3, '2024-08-28 13:46:20', 'login'),
(9, 2, '2024-08-28 13:46:28', 'login');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) NOT NULL,
  `UserType` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `TPID` varchar(100) NOT NULL,
  `RegID` int(11) NOT NULL,
  `RefID` int(11) DEFAULT NULL,
  `UserGroup` int(11) NOT NULL,
  `FullName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `UserName` varchar(100) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Status` enum('Active','Inactive','Deleted') NOT NULL DEFAULT 'Active',
  `contact_no` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `created_at` varchar(25) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_ip` varchar(255) DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_at` varchar(25) DEFAULT NULL,
  `modified_ip` varchar(255) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`ID`, `UserType`, `TPID`, `RegID`, `RefID`, `UserGroup`, `FullName`, `designation`, `UserName`, `Password`, `Email`, `Status`, `contact_no`, `created_at`, `created_by`, `created_ip`, `modified_by`, `modified_at`, `modified_ip`) VALUES
(1, 'Superadmin', 'su', 1, 1, 1, 'BMS NEPAL', 'owner', 'bmsnep', '4fe3bd7aa90cacafde8e944d84add9a8', 'info@bmsnep.net', 'Active', '9851117526', '2078-05-28', 1, '--', NULL, NULL, NULL),
(2, 'Superadmin', 'su', 1, 1, 1, 'Galcchi Rural Municipality', 'owner', 'galchhi', 'ac2920669e37acfdcadee51f01273217', 'info@galchhimun.gov.np', 'Active', '-', '2078-05-28', 1, '--', NULL, NULL, NULL),
(3, '4', 'su', 0, NULL, 4, 'user1', 'pad', 'user1', '24c9e15e52afc47c225b757e7bee1f9d', 'user1@gmail.com', 'Active', '989899', '2024-08-28', 2, '10.145.145.163', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_actions`
--

CREATE TABLE IF NOT EXISTS `user_actions` (
  `user_action_id` int(11) NOT NULL,
  `user_action_name` varchar(15) NOT NULL,
  `user_action_code` varchar(15) NOT NULL,
  `addded_by` int(11) DEFAULT NULL,
  `added_date` datetime DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `modified_date` datetime DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_actions`
--

INSERT INTO `user_actions` (`user_action_id`, `user_action_name`, `user_action_code`, `addded_by`, `added_date`, `modified_by`, `modified_date`) VALUES
(1, 'ADD', 'ADD', 1, '2014-02-20 00:00:00', NULL, NULL),
(2, 'MODIFY', 'EDIT', 1, '2014-02-20 00:00:00', NULL, NULL),
(3, 'DELETE', 'DELETE', 1, '2014-02-20 00:00:00', NULL, NULL),
(4, 'VIEW', 'VIEW', 1, '2014-02-20 00:00:00', NULL, NULL),
(5, 'APPROVE', 'APPROVE', 1, '2017-09-08 00:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `witness`
--

CREATE TABLE IF NOT EXISTS `witness` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `age` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `darta_no` int(11) NOT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `witness`
--

INSERT INTO `witness` (`id`, `name`, `age`, `phone`, `address`, `darta_no`, `type`) VALUES
(1, 'औ', '५५', '525200288', 'ज', 1, 1),
(2, '-', '-', '-', '-', 2, 1),
(3, '-', '-', '-', '-', 4, 1),
(4, '-', '-', '-', '-', 4, 1),
(5, 'दिपक बुढाथोकी', '४५', 'छैन', 'दुवाकोट', 9, 1),
(6, 'श्याम बहादुर बुढाथोकी', '४४', 'छैन', 'दुवाकोट', 9, 1),
(7, 'SHYAM', '50', '-', 'KALANKI', 2, 0),
(8, 'SHYAM', '50', '-', 'KALANKI', 2, 0),
(9, 'औ', '५५', 'छैन', 'ज', 17, 1),
(10, 'sakshi1', '32', '45656', 'theganasakshi', 19, 1),
(11, 'sakshi1', '32', '45656', 'theganasakshi', 19, 1),
(12, 'shyam kumar ', '21', '98689532', 'kalanki ', 20, 1),
(13, 'shyam bahdur ', '25', '32', 'kalanki ', 20, 1),
(14, 'sakshi1', '22', '454', 'laksjdl', 20, 0),
(15, 'dsfd', '22', '454', 'laksjdl', 20, 2),
(16, 'sss', '22', '45656', 'theganasakshi', 20, 2),
(17, 'नबराज पण्डित ', '40', '9818943090', 'धादिङ्ग', 21, 2),
(18, 'soji kumari ', '25', '9840559229', 'soji jilla ', 22, 1),
(19, 'sakshi', '25', '555', 'thegaan', 21, 2),
(20, 'सपना पण्डित ', '22', '9845358296', 'नलाङ्ग22', 21, 2),
(21, '-', '-', '-', '-', 23, 1),
(22, 'सुरेश थापा', '-', '9841205594', 'दुवाकोट', 23, 2),
(23, 'दिपक खत्री', '-', '9841834146', 'दुवाकोट', 23, 2),
(24, 'sakshiname', '25', '9865', 'thegana', 24, 1),
(25, 'naam', '25', '2563', 'thegana', 15, 1),
(27, '', '', '', '', 27, 1),
(31, 'shakshi', '45', '454', 'hkj', 25, 2),
(32, '', '', '', '', 25, 2),
(34, 'बिष्णु लम्साल ', '', '', 'काठमान्डौ ', 28, 2),
(35, 'रचना पण्डित ', '20', '9813891104', 'काठमान्डौ ', 28, 2),
(36, 'ss', '', '', '', 29, 1),
(37, '', '', '', '', 30, 2),
(40, '', '', '', '', 18, 2),
(41, '', '', '', '', 31, 1),
(42, '', '', '', '', 31, 1),
(43, '', '', '', '', 31, 2),
(44, '', '', '', '', 1, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_menu`
--
ALTER TABLE `admin_menu`
  ADD PRIMARY KEY (`menuid`);

--
-- Indexes for table `anusuchi_1`
--
ALTER TABLE `anusuchi_1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_2`
--
ALTER TABLE `anusuchi_2`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_3`
--
ALTER TABLE `anusuchi_3`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_4`
--
ALTER TABLE `anusuchi_4`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_5`
--
ALTER TABLE `anusuchi_5`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_6`
--
ALTER TABLE `anusuchi_6`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_7`
--
ALTER TABLE `anusuchi_7`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_8`
--
ALTER TABLE `anusuchi_8`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_9`
--
ALTER TABLE `anusuchi_9`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_10`
--
ALTER TABLE `anusuchi_10`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_11`
--
ALTER TABLE `anusuchi_11`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_12`
--
ALTER TABLE `anusuchi_12`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_13`
--
ALTER TABLE `anusuchi_13`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_14`
--
ALTER TABLE `anusuchi_14`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_15`
--
ALTER TABLE `anusuchi_15`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_16`
--
ALTER TABLE `anusuchi_16`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `anusuchi_history`
--
ALTER TABLE `anusuchi_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `badi_detail`
--
ALTER TABLE `badi_detail`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `badi_firad_patra`
--
ALTER TABLE `badi_firad_patra`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dafa`
--
ALTER TABLE `dafa`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `darta`
--
ALTER TABLE `darta`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `darta_dastur_wiwaran`
--
ALTER TABLE `darta_dastur_wiwaran`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `dastur`
--
ALTER TABLE `dastur`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fiscal_year`
--
ALTER TABLE `fiscal_year`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `group`
--
ALTER TABLE `group`
  ADD PRIMARY KEY (`groupid`);

--
-- Indexes for table `letters`
--
ALTER TABLE `letters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `letter_head`
--
ALTER TABLE `letter_head`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `likhit_jawaf`
--
ALTER TABLE `likhit_jawaf`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `local_dafa`
--
ALTER TABLE `local_dafa`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mudda_bisaye`
--
ALTER TABLE `mudda_bisaye`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `permissions_per_group`
--
ALTER TABLE `permissions_per_group`
  ADD PRIMARY KEY (`permission_per_group_id`);

--
-- Indexes for table `permissions_per_user`
--
ALTER TABLE `permissions_per_user`
  ADD PRIMARY KEY (`permission_per_user_id`);

--
-- Indexes for table `peshi_darta`
--
ALTER TABLE `peshi_darta`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `peshi_list`
--
ALTER TABLE `peshi_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `position`
--
ALTER TABLE `position`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pratibadi_detail`
--
ALTER TABLE `pratibadi_detail`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `provinces`
--
ALTER TABLE `provinces`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `samati_name`
--
ALTER TABLE `samati_name`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sarkar_yain`
--
ALTER TABLE `sarkar_yain`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings_district`
--
ALTER TABLE `settings_district`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings_relation`
--
ALTER TABLE `settings_relation`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings_vdc_municipality`
--
ALTER TABLE `settings_vdc_municipality`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings_ward`
--
ALTER TABLE `settings_ward`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `set_up`
--
ALTER TABLE `set_up`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tok_aadesh`
--
ALTER TABLE `tok_aadesh`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `userlog`
--
ALTER TABLE `userlog`
  ADD PRIMARY KEY (`logid`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `user_actions`
--
ALTER TABLE `user_actions`
  ADD PRIMARY KEY (`user_action_id`);

--
-- Indexes for table `witness`
--
ALTER TABLE `witness`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_menu`
--
ALTER TABLE `admin_menu`
  MODIFY `menuid` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `anusuchi_1`
--
ALTER TABLE `anusuchi_1`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_2`
--
ALTER TABLE `anusuchi_2`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_3`
--
ALTER TABLE `anusuchi_3`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_4`
--
ALTER TABLE `anusuchi_4`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_5`
--
ALTER TABLE `anusuchi_5`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_6`
--
ALTER TABLE `anusuchi_6`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_7`
--
ALTER TABLE `anusuchi_7`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_8`
--
ALTER TABLE `anusuchi_8`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_9`
--
ALTER TABLE `anusuchi_9`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_10`
--
ALTER TABLE `anusuchi_10`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_11`
--
ALTER TABLE `anusuchi_11`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_12`
--
ALTER TABLE `anusuchi_12`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_13`
--
ALTER TABLE `anusuchi_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_14`
--
ALTER TABLE `anusuchi_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_15`
--
ALTER TABLE `anusuchi_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_16`
--
ALTER TABLE `anusuchi_16`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `anusuchi_history`
--
ALTER TABLE `anusuchi_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `badi_detail`
--
ALTER TABLE `badi_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `badi_firad_patra`
--
ALTER TABLE `badi_firad_patra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `dafa`
--
ALTER TABLE `dafa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `darta`
--
ALTER TABLE `darta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `darta_dastur_wiwaran`
--
ALTER TABLE `darta_dastur_wiwaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `dastur`
--
ALTER TABLE `dastur`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `fiscal_year`
--
ALTER TABLE `fiscal_year`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `group`
--
ALTER TABLE `group`
  MODIFY `groupid` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `letters`
--
ALTER TABLE `letters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `letter_head`
--
ALTER TABLE `letter_head`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `likhit_jawaf`
--
ALTER TABLE `likhit_jawaf`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `local_dafa`
--
ALTER TABLE `local_dafa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `mudda_bisaye`
--
ALTER TABLE `mudda_bisaye`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `permissions_per_group`
--
ALTER TABLE `permissions_per_group`
  MODIFY `permission_per_group_id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1058;
--
-- AUTO_INCREMENT for table `permissions_per_user`
--
ALTER TABLE `permissions_per_user`
  MODIFY `permission_per_user_id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=522;
--
-- AUTO_INCREMENT for table `peshi_darta`
--
ALTER TABLE `peshi_darta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `peshi_list`
--
ALTER TABLE `peshi_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `position`
--
ALTER TABLE `position`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `pratibadi_detail`
--
ALTER TABLE `pratibadi_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `provinces`
--
ALTER TABLE `provinces`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `samati_name`
--
ALTER TABLE `samati_name`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `sarkar_yain`
--
ALTER TABLE `sarkar_yain`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `settings_district`
--
ALTER TABLE `settings_district`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=558;
--
-- AUTO_INCREMENT for table `settings_relation`
--
ALTER TABLE `settings_relation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=43;
--
-- AUTO_INCREMENT for table `settings_vdc_municipality`
--
ALTER TABLE `settings_vdc_municipality`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2946;
--
-- AUTO_INCREMENT for table `settings_ward`
--
ALTER TABLE `settings_ward`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=37;
--
-- AUTO_INCREMENT for table `set_up`
--
ALTER TABLE `set_up`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tok_aadesh`
--
ALTER TABLE `tok_aadesh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `userlog`
--
ALTER TABLE `userlog`
  MODIFY `logid` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `user_actions`
--
ALTER TABLE `user_actions`
  MODIFY `user_action_id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `witness`
--
ALTER TABLE `witness`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=45;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
