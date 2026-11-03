-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: kculture_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bookmark`
--

DROP TABLE IF EXISTS `bookmark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookmark` (
  `bookmark_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `post_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bookmark_id`),
  UNIQUE KEY `member_id` (`member_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `bookmark_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE,
  CONSTRAINT `bookmark_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookmark`
--

LOCK TABLES `bookmark` WRITE;
/*!40000 ALTER TABLE `bookmark` DISABLE KEYS */;
INSERT INTO `bookmark` VALUES (2,5,7,'2026-10-26 17:31:17'),(9,5,16,'2026-11-02 16:03:55');
/*!40000 ALTER TABLE `bookmark` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'K-POP','K-POP','2026-10-26 16:04:24'),(2,'K-FOOD','K-FOOD','2026-10-26 16:04:24'),(3,'K-DRAMA','K-DRAMA','2026-10-26 16:04:24'),(4,'K-BEAUTY','K-BEAUTY','2026-10-26 16:04:24'),(5,'TRAVEL','여행','2026-10-26 16:04:24'),(6,'CULTURE','문화','2026-10-26 16:04:24');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment` (
  `comment_id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `member_id` bigint NOT NULL,
  `content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `like_count` int NOT NULL DEFAULT '0',
  `dislike_count` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `post_id` (`post_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (1,1,3,'좋은 후기 감사합니다!',0,0,'2026-10-26 16:04:24','2026-10-26 16:05:45'),(2,2,4,'Great route!',0,0,'2026-10-26 16:04:24','2026-10-26 16:04:24'),(3,5,2,'T-money 카드를 추천합니다.',1,0,'2026-10-26 16:04:24','2026-11-03 10:48:48'),(4,7,5,'테스트용 댓글입니다.',1,0,'2026-10-27 09:44:17','2026-10-27 09:49:22'),(5,11,1,'wow',0,0,'2026-10-28 10:52:21','2026-10-28 10:52:27'),(6,40,1,'확인용',1,0,'2026-10-28 10:52:21','2026-11-03 10:16:45'),(8,27,5,'ㅎㅇ',0,0,'2026-11-02 16:36:07','2026-11-02 16:39:40'),(10,38,5,'확인요',0,0,'2026-11-02 16:54:22','2026-11-02 16:54:22'),(11,40,5,'test',0,0,'2026-11-03 10:16:53','2026-11-03 10:16:53');
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_dislike`
--

DROP TABLE IF EXISTS `comment_dislike`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment_dislike` (
  `dislike_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `comment_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dislike_id`),
  UNIQUE KEY `uk_comment_dislike_member_comment` (`member_id`,`comment_id`),
  KEY `fk_comment_dislike_comment` (`comment_id`),
  CONSTRAINT `fk_comment_dislike_comment` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_dislike_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_dislike`
--

LOCK TABLES `comment_dislike` WRITE;
/*!40000 ALTER TABLE `comment_dislike` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment_dislike` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_like`
--

DROP TABLE IF EXISTS `comment_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment_like` (
  `comment_like_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `comment_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_like_id`),
  UNIQUE KEY `member_id` (`member_id`,`comment_id`),
  KEY `comment_id` (`comment_id`),
  CONSTRAINT `comment_like_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE,
  CONSTRAINT `comment_like_ibfk_2` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_like`
--

LOCK TABLES `comment_like` WRITE;
/*!40000 ALTER TABLE `comment_like` DISABLE KEYS */;
INSERT INTO `comment_like` VALUES (2,5,4,'2026-10-27 09:49:22'),(13,5,3,'2026-11-03 10:48:48');
/*!40000 ALTER TABLE `comment_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inquiry`
--

DROP TABLE IF EXISTS `inquiry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inquiry` (
  `inquiry_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('WAITING','ANSWERED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WAITING',
  `answer` text COLLATE utf8mb4_unicode_ci,
  `answered_by` bigint DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `answered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`inquiry_id`),
  KEY `member_id` (`member_id`),
  KEY `answered_by` (`answered_by`),
  CONSTRAINT `inquiry_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `inquiry_ibfk_2` FOREIGN KEY (`answered_by`) REFERENCES `member` (`member_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry`
--

LOCK TABLES `inquiry` WRITE;
/*!40000 ALTER TABLE `inquiry` DISABLE KEYS */;
INSERT INTO `inquiry` VALUES (1,3,'로그인 관련 문의','로그인 화면 사용 방법을 문의합니다.','WAITING',NULL,NULL,'2026-10-26 16:04:24',NULL),(2,5,'test','test','ANSWERED','yes',1,'2026-10-26 16:10:20','2026-10-27 11:18:14'),(3,5,'gd','gd','WAITING',NULL,NULL,'2026-11-03 10:58:06',NULL);
/*!40000 ALTER TABLE `inquiry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `language` (
  `language_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ko` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_native` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`language_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language`
--

LOCK TABLES `language` WRITE;
/*!40000 ALTER TABLE `language` DISABLE KEYS */;
INSERT INTO `language` VALUES (1,'ko','한국어','한국어',1,'2026-10-26 16:04:24'),(2,'ja','일본어','日本語',1,'2026-10-26 16:04:24'),(3,'zh','중국어','中文',1,'2026-10-26 16:04:24'),(4,'en','영어','English',1,'2026-10-26 16:04:24');
/*!40000 ALTER TABLE `language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `member_id` bigint NOT NULL AUTO_INCREMENT,
  `login_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nationality` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language_id` int NOT NULL DEFAULT '1',
  `profile_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('USER','ADMIN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER',
  `status` enum('ACTIVE','SUSPENDED','WITHDRAWN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `suspended_until` date DEFAULT NULL,
  `suspension_reason` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `login_id` (`login_id`),
  UNIQUE KEY `nickname` (`nickname`),
  UNIQUE KEY `email` (`email`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `member_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `language` (`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'admin','1234','관리자','admin@kculture.com','Korea',1,'/uploads/profile/1a3a7028-9c14-4a8d-9faf-8e15ce62023e.png','ADMIN','ACTIVE',NULL,NULL,'2026-10-26 16:04:24','2026-11-02 11:53:47'),(2,'minsu_kr','1234','민수의서울','minsu@test.com','Korea',1,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-26 16:04:24','2026-10-26 16:04:24'),(3,'yuki_jp','1234','YukiTrip','yuki@test.com','Japan',2,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-26 16:04:24','2026-10-26 16:04:24'),(4,'emma_us','1234','EmmaSeoul','emma@test.com','USA',4,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-26 16:04:24','2026-10-26 16:04:24'),(5,'test','1234','테스트','test@gmail.com','KR',1,'/uploads/profile/3fc929df-f338-4767-af3c-0a4c05fc607c.webp','USER','ACTIVE',NULL,NULL,'2026-10-26 16:06:13','2026-11-02 11:26:56'),(7,'login','12345','로그인','login@gmail.com','한국',1,NULL,'USER','SUSPENDED','2026-11-26','연습','2026-10-27 17:12:25','2026-11-03 10:20:48'),(8,'google_114887130344491479','508dc0a8-5c78-499c-983c-fc1339f3d27a','이우민','lhbjg8964@gmail.com',NULL,1,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-27 18:11:46','2026-10-27 18:11:46'),(9,'kakao_5157471866','f11a7efa-0dbb-4fca-b1dd-e7b50adfe848','KAKAO 사용자','kakao_5157471866@social.kculture.local',NULL,1,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-28 10:05:03','2026-10-28 10:05:03'),(10,'naver_S2mtLnVarrxrnStRxB','7b43d4aa-976d-48f0-af9a-fb9f80d6bc35','우민','lhbjg0407@naver.com',NULL,1,NULL,'USER','ACTIVE',NULL,NULL,'2026-10-28 10:16:59','2026-10-28 10:16:59');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice`
--

DROP TABLE IF EXISTS `notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice` (
  `notice_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `view_count` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`notice_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `notice_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice`
--

LOCK TABLES `notice` WRITE;
/*!40000 ALTER TABLE `notice` DISABLE KEYS */;
INSERT INTO `notice` VALUES (1,1,'K-Culture Community에 오신 것을 환영합니다.','테스트용 관리자 공지입니다.',21,'2026-10-26 16:04:24','2026-11-03 10:48:18'),(2,1,'test공지','테스트용 공지입니다',35,'2026-10-26 17:19:50','2026-11-03 11:02:18');
/*!40000 ALTER TABLE `notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice_image`
--

DROP TABLE IF EXISTS `notice_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice_image` (
  `image_id` bigint NOT NULL AUTO_INCREMENT,
  `notice_id` bigint NOT NULL,
  `image_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_order` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  KEY `idx_notice_image_notice_id` (`notice_id`),
  CONSTRAINT `fk_notice_image_notice` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`notice_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice_image`
--

LOCK TABLES `notice_image` WRITE;
/*!40000 ALTER TABLE `notice_image` DISABLE KEYS */;
INSERT INTO `notice_image` VALUES (1,2,'seoul_route01.jpg','/uploads/notice/image/36428e49-3f88-428e-b9dd-137109c314be.jpg',1,'2026-11-03 10:59:42');
/*!40000 ALTER TABLE `notice_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice_video`
--

DROP TABLE IF EXISTS `notice_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice_video` (
  `video_id` bigint NOT NULL AUTO_INCREMENT,
  `notice_id` bigint NOT NULL,
  `video_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_order` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`video_id`),
  KEY `idx_notice_video_notice_id` (`notice_id`),
  CONSTRAINT `fk_notice_video_notice` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`notice_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice_video`
--

LOCK TABLES `notice_video` WRITE;
/*!40000 ALTER TABLE `notice_video` DISABLE KEYS */;
/*!40000 ALTER TABLE `notice_video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post` (
  `post_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `category_id` int DEFAULT NULL,
  `board_type` enum('KCULTURE','FREE','QUESTION') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'KCULTURE',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `view_count` int NOT NULL DEFAULT '0',
  `like_count` int NOT NULL DEFAULT '0',
  `dislike_count` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `member_id` (`member_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `post_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `post_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post`
--

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
INSERT INTO `post` VALUES (1,2,1,'KCULTURE','서울 K-POP 콘서트 후기','첫 콘서트 후기입니다.',22,0,0,'2026-10-26 16:04:24','2026-10-26 16:05:49'),(2,3,5,'KCULTURE','서울 3일 여행 코스','서울 여행 코스를 공유합니다.',37,1,0,'2026-10-26 16:04:24','2026-10-29 17:36:44'),(3,4,2,'KCULTURE','My favorite Korean food','Tteokbokki was amazing!',11,0,0,'2026-10-26 16:04:24','2026-11-03 10:50:52'),(4,2,NULL,'FREE','오늘 홍대 다녀왔어요','자유롭게 일상을 공유하는 글입니다.',16,0,0,'2026-10-26 16:04:24','2026-11-02 17:08:40'),(5,3,NULL,'QUESTION','서울 지하철 이용 방법이 궁금해요','외국인도 사용하기 쉬운 교통카드를 추천해주세요.',35,0,0,'2026-10-26 16:04:24','2026-11-03 12:37:53'),(6,5,3,'KCULTURE','test','순위 확인용',5,1,0,'2026-10-26 17:11:01','2026-11-03 11:02:27'),(7,5,3,'KCULTURE','테스트','테스트2',31,1,0,'2026-10-26 17:13:19','2026-11-03 10:17:38'),(8,2,1,'KCULTURE','요즘 자주 듣는 K-POP 플레이리스트','최근에 자주 듣는 K-POP 노래들을 공유합니다. 여러분의 추천곡도 알려주세요.',45,6,0,'2026-10-20 10:10:00','2026-10-20 10:10:00'),(9,3,1,'KCULTURE','처음 가본 아이돌 팝업스토어 후기','서울에서 열린 아이돌 팝업스토어에 다녀왔습니다. 굿즈 종류가 다양해서 재미있었어요.',39,4,0,'2026-10-20 13:25:00','2026-10-29 15:08:55'),(10,4,1,'KCULTURE','K-POP 콘서트 예매 팁 공유','외국인 관광객이 한국에서 콘서트 티켓을 예매할 때 알아두면 좋은 내용을 정리했습니다.',75,9,0,'2026-10-21 09:15:00','2026-10-30 12:17:59'),(11,5,2,'KCULTURE','한국에서 꼭 먹어봐야 할 음식 5가지','비빔밥, 떡볶이, 삼겹살, 김치찌개, 치킨을 추천합니다.',143,12,0,'2026-10-21 12:30:00','2026-11-03 10:30:20'),(12,2,2,'KCULTURE','광장시장 먹거리 추천','광장시장에 방문해서 빈대떡과 육회, 마약김밥을 먹어봤습니다.',54,5,0,'2026-10-21 18:20:00','2026-10-21 18:20:00'),(13,3,2,'KCULTURE','한국 편의점 음식 추천','한국 여행 중 간단하게 먹기 좋은 편의점 음식들을 소개합니다.',41,3,0,'2026-10-22 08:45:00','2026-10-22 08:45:00'),(14,4,3,'KCULTURE','최근 재미있게 본 한국 드라마','최근에 본 한국 드라마 중에서 가장 재미있었던 작품들을 이야기해봅니다.',65,8,0,'2026-10-22 11:30:00','2026-10-22 11:30:00'),(15,5,3,'KCULTURE','한국 드라마 촬영지 여행','드라마에 나왔던 서울의 촬영지를 직접 방문해봤습니다.',39,4,0,'2026-10-22 15:15:00','2026-10-22 15:15:00'),(16,2,3,'KCULTURE','입문자에게 추천하는 K-Drama','처음 한국 드라마를 보는 분들이 부담 없이 볼 수 있는 작품을 추천합니다.',102,10,0,'2026-10-23 09:20:00','2026-11-02 16:03:55'),(17,3,4,'KCULTURE','한복 체험하고 경복궁 다녀왔어요','한복을 대여해서 경복궁과 북촌을 돌아다녔습니다. 사진 찍기 정말 좋았어요.',47,5,0,'2026-10-23 12:40:00','2026-10-23 12:40:00'),(18,4,4,'KCULTURE','한국 전통문화 체험 추천','서울에서 경험할 수 있는 전통문화 체험 프로그램을 소개합니다.',33,2,0,'2026-10-23 17:05:00','2026-10-23 17:05:00'),(19,5,4,'KCULTURE','경복궁 야간개장 후기','밤에 보는 경복궁은 낮과는 또 다른 분위기였습니다.',58,7,0,'2026-10-24 10:20:00','2026-10-24 10:20:00'),(20,2,5,'KCULTURE','서울 2박 3일 여행 일정','경복궁, 홍대, 성수, 명동을 중심으로 2박 3일 여행 일정을 만들어봤습니다.',120,0,0,'2026-10-24 14:30:00','2026-11-03 10:24:19'),(21,3,5,'KCULTURE','부산 여행 추천 코스','해운대와 광안리, 감천문화마을을 포함한 부산 여행 코스입니다.',68,8,0,'2026-10-24 18:45:00','2026-10-24 18:45:00'),(22,4,5,'KCULTURE','외국인 친구와 서울 여행하기 좋은 곳','외국인 친구와 함께 방문하기 좋은 서울 관광지를 정리했습니다.',82,0,0,'2026-10-25 09:40:00','2026-10-30 12:13:49'),(23,2,NULL,'FREE','오늘 날씨가 정말 좋네요','오랜만에 날씨가 좋아서 한강에 다녀왔습니다.',14,1,0,'2026-10-20 11:00:00','2026-10-20 11:00:00'),(24,3,NULL,'FREE','한국 생활 적응 중입니다','한국에 온 지 얼마 안 됐는데 아직 모든 게 신기합니다.',24,3,0,'2026-10-21 14:10:00','2026-10-21 14:10:00'),(25,4,NULL,'FREE','홍대 카페 추천해주세요','홍대 근처에서 조용하게 쉴 수 있는 카페를 찾고 있습니다.',32,2,0,'2026-10-22 10:30:00','2026-10-30 16:48:02'),(26,5,NULL,'FREE','성수동 다녀왔습니다','주말에 성수동에 갔는데 사람이 정말 많았습니다.',27,4,0,'2026-10-22 19:25:00','2026-10-22 19:25:00'),(27,2,NULL,'FREE','한국에서 가장 좋아하는 계절','개인적으로 가을이 가장 좋은 것 같습니다.',64,1,0,'2026-10-23 13:50:00','2026-11-02 16:39:40'),(28,3,NULL,'FREE','한강에서 치킨 먹어봤어요','친구들과 한강에서 치킨을 먹었는데 정말 재미있는 경험이었습니다.',41,5,0,'2026-10-24 16:15:00','2026-11-02 16:35:45'),(29,4,NULL,'FREE','한국 친구 만들기 어렵나요?','한국에서 새로운 친구를 사귀는 좋은 방법이 궁금합니다.',36,3,0,'2026-10-25 12:20:00','2026-10-25 12:20:00'),(30,5,NULL,'FREE','주말에 어디 갈까요?','서울에서 가볍게 다녀올 만한 장소를 추천해주세요.',30,2,0,'2026-10-26 09:30:00','2026-10-28 16:12:40'),(31,2,NULL,'QUESTION','T-money 카드는 어디에서 살 수 있나요?','한국에 처음 방문하는데 교통카드는 어디에서 구매할 수 있는지 궁금합니다.',35,2,0,'2026-10-20 15:30:00','2026-10-20 15:30:00'),(32,3,NULL,'QUESTION','인천공항에서 서울역까지 어떻게 가나요?','공항철도와 버스 중 어떤 방법이 편한지 알려주세요.',61,6,0,'2026-10-21 08:20:00','2026-10-21 08:20:00'),(33,4,NULL,'QUESTION','한국 식당에서 주문하는 방법','한국어를 잘 못하는데 식당에서 쉽게 주문할 수 있는 방법이 있을까요?',48,4,0,'2026-10-22 12:15:00','2026-10-22 12:15:00'),(34,5,NULL,'QUESTION','서울에서 한복 대여 추천해주세요','경복궁 근처 한복 대여점을 찾고 있습니다.',44,3,0,'2026-10-23 10:05:00','2026-11-03 10:48:41'),(35,2,NULL,'QUESTION','외국인도 한국 배달앱을 사용할 수 있나요?','한국 전화번호가 없어도 사용할 수 있는 배달 방법이 궁금합니다.',54,7,0,'2026-10-24 11:40:00','2026-11-03 10:17:16'),(36,3,NULL,'QUESTION','서울 지하철 막차 시간 확인 방법','지하철 막차 시간을 쉽게 확인할 수 있는 앱이나 사이트를 알려주세요.',46,4,0,'2026-10-25 15:10:00','2026-11-03 10:48:38'),(37,4,NULL,'QUESTION','한국 여행할 때 필요한 앱 추천','지도, 교통, 번역 등에 사용할 수 있는 필수 앱을 추천해주세요.',70,9,0,'2026-10-26 13:25:00','2026-10-30 14:58:04'),(38,5,NULL,'FREE','좋은 아침입니다','좋은 아침입니다',38,1,0,'2026-10-27 11:32:03','2026-11-03 11:05:04'),(39,5,4,'KCULTURE','실험','와우',8,0,0,'2026-10-27 11:35:04','2026-10-30 12:01:12'),(40,5,4,'KCULTURE','연습용','ㅎㅇ',94,0,0,'2026-10-28 10:26:40','2026-11-03 10:48:23');
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_dislike`
--

DROP TABLE IF EXISTS `post_dislike`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_dislike` (
  `dislike_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `post_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dislike_id`),
  UNIQUE KEY `uk_post_dislike_member_post` (`member_id`,`post_id`),
  KEY `fk_post_dislike_post` (`post_id`),
  CONSTRAINT `fk_post_dislike_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_post_dislike_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_dislike`
--

LOCK TABLES `post_dislike` WRITE;
/*!40000 ALTER TABLE `post_dislike` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_dislike` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_image`
--

DROP TABLE IF EXISTS `post_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_image` (
  `image_id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `image_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_order` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_image_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_image`
--

LOCK TABLES `post_image` WRITE;
/*!40000 ALTER TABLE `post_image` DISABLE KEYS */;
INSERT INTO `post_image` VALUES (1,6,'seoul_route01.jpg','/resources/img/cat1.jpg',1,'2026-10-26 17:11:01'),(3,39,'images.jfif','/resources/img/cat2.jpg',1,'2026-10-27 11:35:04'),(4,11,'images.jfif','/resources/img/cat3.jpg',1,'2026-10-28 11:43:26'),(5,22,'images (1).jfif','/resources/img/cat4.jpg',1,'2026-10-28 11:58:35'),(6,40,'엽떡.png','/resources/img/엽떡.png',1,'2026-10-28 11:58:35'),(7,38,'test','/resources/img/cat1.jpg',1,'2026-10-28 11:58:35');
/*!40000 ALTER TABLE `post_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_like`
--

DROP TABLE IF EXISTS `post_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_like` (
  `like_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `post_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `member_id` (`member_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_like_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE,
  CONSTRAINT `post_like_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_like`
--

LOCK TABLES `post_like` WRITE;
/*!40000 ALTER TABLE `post_like` DISABLE KEYS */;
INSERT INTO `post_like` VALUES (2,5,2,'2026-10-26 16:58:10'),(4,5,7,'2026-10-26 17:31:12'),(18,5,38,'2026-11-02 16:48:45'),(21,1,6,'2026-11-03 11:02:27');
/*!40000 ALTER TABLE `post_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_video`
--

DROP TABLE IF EXISTS `post_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_video` (
  `video_id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `video_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video_order` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`video_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_video_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_video`
--

LOCK TABLES `post_video` WRITE;
/*!40000 ALTER TABLE `post_video` DISABLE KEYS */;
INSERT INTO `post_video` VALUES (1,7,'Feel the Night(bam) of KOREA #VisitKoreaYear.mp4','/uploads/resources/video/redred.mp4',NULL,1,'2026-10-26 17:13:19'),(3,20,'2024 박카스_젊음을 힘껏 마음껏_여행편 30s.mp4','/uploads/post/video/cfba579d-5483-4a79-81c7-bd8b7cb8af7d.mp4',NULL,1,'2026-10-28 11:57:14'),(4,16,'본격 탐스 청춘 드라마《우리가 익어가는 계절》(feat. 탄산의 품격).mp4','/uploads/post/video/693d09dc-9f89-4802-9fa0-2bf159bfc2f7.mp4',NULL,1,'2026-10-28 11:57:37'),(5,11,'2026 나랑드사이다 X 리센느 [나랑드로 와] full ver..mp4','/uploads/post/video/f4113d5a-1d69-459b-8a74-356c0803914d.mp4',NULL,1,'2026-11-03 10:30:20');
/*!40000 ALTER TABLE `post_video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `remember_login`
--

DROP TABLE IF EXISTS `remember_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `remember_login` (
  `remember_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `token_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`remember_id`),
  UNIQUE KEY `uk_remember_token_hash` (`token_hash`),
  KEY `idx_remember_member_id` (`member_id`),
  KEY `idx_remember_expires_at` (`expires_at`),
  CONSTRAINT `fk_remember_login_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `remember_login`
--

LOCK TABLES `remember_login` WRITE;
/*!40000 ALTER TABLE `remember_login` DISABLE KEYS */;
/*!40000 ALTER TABLE `remember_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_account`
--

DROP TABLE IF EXISTS `social_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_account` (
  `social_id` bigint NOT NULL AUTO_INCREMENT,
  `member_id` bigint NOT NULL,
  `provider` enum('GOOGLE','KAKAO','NAVER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_user_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`social_id`),
  UNIQUE KEY `uk_social_provider_user` (`provider`,`provider_user_id`),
  KEY `idx_social_member` (`member_id`),
  CONSTRAINT `fk_social_account_member` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_account`
--

LOCK TABLES `social_account` WRITE;
/*!40000 ALTER TABLE `social_account` DISABLE KEYS */;
INSERT INTO `social_account` VALUES (1,8,'GOOGLE','114887130344491479955','lhbjg8964@gmail.com','2026-10-27 18:11:46'),(2,9,'KAKAO','5157471866',NULL,'2026-10-28 10:05:03'),(3,10,'NAVER','S2mtL_nVarrxrnStRxB5Fl6y-FlbDmowIiWBC2reM84','lhbjg0407@naver.com','2026-10-28 10:16:59');
/*!40000 ALTER TABLE `social_account` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-03 15:20:43
