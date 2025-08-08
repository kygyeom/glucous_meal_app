-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: glucous
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `glucous`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `glucous` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `glucous`;

--
-- Table structure for table `allergy`
--

DROP TABLE IF EXISTS `allergy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allergy` (
  `allergy_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `en_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`allergy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allergy`
--

LOCK TABLES `allergy` WRITE;
/*!40000 ALTER TABLE `allergy` DISABLE KEYS */;
INSERT INTO `allergy` VALUES (1,'유제품',NULL),(2,'견과류',NULL),(3,'갑각류',NULL),(4,'육류',NULL),(5,'해산물',NULL);
/*!40000 ALTER TABLE `allergy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'과일군'),(2,'곡류군'),(3,'혼합식품'),(4,'어육류군'),(5,'우유군'),(6,'채소군'),(7,'지방군');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dietary_restriction`
--

DROP TABLE IF EXISTS `dietary_restriction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dietary_restriction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name_kr` varchar(50) DEFAULT NULL,
  `name_en` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name_kr`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dietary_restriction`
--

LOCK TABLES `dietary_restriction` WRITE;
/*!40000 ALTER TABLE `dietary_restriction` DISABLE KEYS */;
INSERT INTO `dietary_restriction` VALUES (1,'채식주의자','Vegetarian'),(2,'할랄','Halal'),(3,'글루텐 프리','Gluten-free');
/*!40000 ALTER TABLE `dietary_restriction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_products`
--

DROP TABLE IF EXISTS `food_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `ingredients` text,
  `brand` varchar(50) DEFAULT NULL,
  `total_weight_g` int DEFAULT NULL,
  `calories_kcal` int DEFAULT NULL,
  `protein_g` float DEFAULT NULL,
  `carbohydrate_g` float DEFAULT NULL,
  `fat_g` float DEFAULT NULL,
  `sugar_g` float DEFAULT NULL,
  `saturated_fat_g` float DEFAULT NULL,
  `sodium_mg` int DEFAULT NULL,
  `fiber_g` float DEFAULT NULL,
  `allergy` text,
  `price` int DEFAULT NULL,
  `shipping_fee` int DEFAULT NULL,
  `rating` float DEFAULT NULL,
  `review_count` int DEFAULT NULL,
  `link` text,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_products`
--

LOCK TABLES `food_products` WRITE;
/*!40000 ALTER TABLE `food_products` DISABLE KEYS */;
INSERT INTO `food_products` VALUES (1,'김치알밥','날치알, 볶음김치, 현미밥, 올리브유, 양배추, 브로콜리, 당근','메디쏠라',265,395,22,45,15,4,1.8,890,0,'대두, 닭고기, 새우, 우유, 밀, 조개류, 홍합',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(2,'깔라마리토마토파스타','오징어, 토마토소스, 파스타, 피망, 양파, 올리브오일','메디쏠라',334,375,21,37,16,9,2.2,700,0,'토마토, 밀, 오징어, 조개류, 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(3,'닭가슴살영양밥','닭가슴살, 로제소스, 토마토, 현미밥, 옥수수, 양배추','메디쏠라',290,410,22,51,13,2,2.7,460,0,'대두, 닭고기, 토마토, 우유, 밀, 쇠고기',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(4,'닭가슴살치즈덮밥','닭가슴살, 모짜렐라치즈, 데리야끼소스, 현미밥, 브로콜리','메디쏠라',272,440,22,47,15,9,2.8,310,0,'대두, 닭고기, 토마토, 우유, 밀, 쇠고기',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(5,'닭갈비덮밥','닭갈비, 참깨마늘소스, 양파, 파프리카, 현미밥, 대파','메디쏠라',279,455,18,62,15,3,2.8,780,0,'대두, 닭고기, 밀, 조개류, 우유, 쇠고기',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(6,'두부새우덮밥','두부, 새우, 피망, 브로콜리, 고구마, 현미밥','메디쏠라',306,390,18,50,14,9,2.6,470,0,'대두, 새우, 우유, 조개류, 밀',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(7,'두부제육덮밥','두부, 제육볶음, 마늘, 양파, 현미밥','메디쏠라',316,420,21,53,14,6,2.9,570,0,'대두, 돼지고기, 쇠고기, 조개류, 토마토, 밀',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(8,'두유감자뇨끼','감자뇨끼, 두유크림소스, 피망, 양송이버섯, 브로콜리','메디쏠라',378,390,15,50,18,18,4,670,0,'두유, 대두, 밀, 조개류, 토마토',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(9,'들깨버섯두부밥','두부, 들깨소스, 표고버섯, 현미밥','메디쏠라',298,425,21,58,13,5,2.6,420,0,'대두, 우유, 밀, 쇠고기, 조개류, 야채추출물',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(10,'들깨찜닭','찜닭, 들깨소스, 버섯, 현미밥','메디쏠라',251,395,18,48,13,6,2.4,550,0,'닭고기, 대두, 밀, 쇠고기, 조개류, 야채추출물',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(11,'새우들깨파스타','새우, 들깨소스, 파스타면, 브로콜리, 피망','메디쏠라',315,420,20,53,14,8,2.5,890,0,'새우, 밀, 대두, 들깨, 조개류, 우유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(12,'새우로제파스타','새우, 로제소스, 파스타, 피망, 브로콜리','메디쏠라',295,310,17,39,10,4,2,610,0,'토마토, 새우, 우유, 대두, 밀',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(13,'소고기삼색덮밥','소불고기, 계란지단, 케일, 보리귀리밥','메디쏠라',257,480,22,58,18,4,5,470,0,'쇠고기, 밀, 우유, 대두, 계란, 조개류',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(14,'수삼삼계영양밥','삼계탕, 대추, 은행, 찹쌀, 흑미, 닭고기','메디쏠라',260,405,22,48,14,7,2.3,520,0,'닭고기, 대두, 밀, 우유, 계란, 조개류',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(15,'안심고추장영양밥','쌀(국산), 돼지고기(국산), 병아리콩(캐나다), 올리브유, 기장, 돼지안심구이, 고추장(밀: 미국/호주), 케일, 혼합채소(렌틸콩, 병아리콩, 당근 등), 참깨드레싱, 들기름','메디쏠라',276,420,20,54,14,10,2.3,590,0,'돼지고기, 대두, 밀, 고등어, 야황산류, 쇠고기, 닭고기, 토마토, 우유, 조개류(굴)',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(16,'알리오올리오라이스','쌀(국산), 병아리콩(캐나다), 올리브유, 기장, 그린브로채믹스(브로콜리, 양배추, 당근), 연어(국산), 새송이버섯, 비트, 올리브, 마늘, 후추후레이크, 볶음김치, 정제소금, 후추, 튀긴마늘칩, 들기름, 향미유, 로즈마리, 양파','메디쏠라',257,385,15,50,14,2,3,520,0,'새우, 우유, 돼지고기, 조개류(대합, 홍합), 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(17,'연근우엉밥오므라이스','연근우엉밥(쌀:국산), 교반채소(중국), 지단(계란:국산), 우엉(중국), 채종유, 오므라이스소스(토마토, 양파, 정제수 등), 소스(무피망미라클한돈야돈), 돈육다짐육, 과채(양배추, 양파, 당근), 참깨, 파슬리분말, 향신유','메디쏠라',324,445,21,59,14,6,3.5,890,0,'대두, 밀, 달걀, 우유, 닭고기, 조개류(굴), 토마토, 쇠고기, 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(18,'연어스테이크','퀴노아영양밥(쌀:국산), 방어김치(캐나다), 기장, 그린다이스채소(포트루갈/헝가리), 연어스테이크(칠레), 올리브유, 후추후레이크, 정제소금, 소스(올리고당, 마늘, 버섯성분)','메디쏠라',267,420,20,49,16,3,2.5,410,0,'우유, 돼지고기, 조개류(대합, 홍합) 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(19,'오야꼬동','칙피영양밥(국산), 방어김치(캐나다), 기장, 간장절임닭고기(국산), 곤약(국산), 소스(일본), 양파조림(국산), 올리브유, 변성전분, 정제소금, 파채, 고명치즈, 후추','메디쏠라',273,420,23,53,13,7,2.3,450,0,'닭고기, 대두, 밀, 고등어, 야황새류, 달걀, 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(20,'유산슬덮밥','칙피영양밥(국산), 병아리콩(캐나다), 올리브유, 기장, 버섯볶음양파(국산), 송이탕수채소(중국), 팽이버섯, 새송이볶음, 청피망, 새우(베트남), 오징어(국산), 돼지고기(국산), 대파, 변성전분, 정제소금, 소스(일본)','메디쏠라',285,395,19,48,14,12,2.2,840,0,'대두, 밀, 새우, 오징어, 우유, 돼지고기, 조개류(전복), 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(21,'장조림계란비빔밥','현미밥(국산), 병아리콩(캐나다), 장조림계육가공품(돼지고기, 간장소스), 과채가공품(채소믹스), 정제수, 소스, 계란지단(계란, 변성전분), 마늘, 들기름','메디쏠라',274,435,23,56,13,6,2.3,420,0,'돼지고기, 대두, 밀, 고등어, 야생삼춘, 달걀',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(22,'제육오징어덮밥','보리귀리밥믹스(국산), 찰보리(국산), 올리브유, 그린야채믹스(포트루칼/브로콜리/양배추/당근), 정제수, 청경채, 제육볶음(돼지고기(국산), 고추장(고추가루 등)), 올리고당, 오징어구이(오징어(중국)), 올리브유, 후추','메디쏠라',275,430,20,58,13,5,2.8,450,0,'돼지고기, 밀, 대두, 쇠고기, 닭고기, 토마토, 우유, 조개류(굴), 오징어, 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(23,'짜장영양밥','찹쌀현미(국산), 찰보리(국산), 올리브유, 기장, 소스(양파(국산), 돼지고기(국산), 애호박, 올리고당, 콩기름, 돼지안심(돼지고기)(국산), 과채가공품(사과:국산)), 소스1, 소스2, 양배추, 고명채, 호두','메디쏠라',285,385,22,50,11,6,2.1,520,0,'돼지고기, 밀, 대두, 닭고기, 고등어, 아황산류, 알류, 호두',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(24,'취나물소불고기비빔밥','현미찹쌀밥(국산), 혼합곡밥(국산), 정제수, 카놀라유, 정제소금, 취나물볶음(취나물:국산), 정제수, 대두유, 정제소금, 참깨, 대파, 소불고기소스(정제수, 혼합간장, 마늘, 기타과당, 정제소금, 물엿, 배퓨레, 혼합제제), 소불고기(쇠고기:호주), 소스(정제수, 마늘), 참기름, 간장소스, 들기름, 참깨, 찻잎','메디쏠라',276,445,21,56,15,0,3.9,570,0,'우유, 대두, 밀, 쇠고기, 고등어, 아황산류, 찻잎',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565651340'),(25,'치킨빠에야','치자밥(치자황색소, 쌀), 옥수수커널(외국산), 치자착색쌀, 닭가슴살구이(닭고기:국산), 콩류(병아리콩, 렌틸콩:외국산), 완제품치킨스톡(정제소금, 페로인산나트륨, 설탕, 혼합간장), 정제수, 블랙올리브, 구운홍피망, 소스(올리브유, 정제수, 정제소금, 레몬즙), 구운채소믹스(홍피망, 해바라기유), 블랙올리브슬라이스, 올리브유, 후추','메디쏠라',264,395,23,51,11,0,3,430,0,'대두, 닭고기, 우유, 돼지고기, 조개류(대합, 홍합), 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565642526'),(26,'치킨알리오올리오','치파피밥(쌀:국산), 방울양배추(캐나다), 올리브유, 기장, 그릴드야채믹스(포르투갈/남아공), 닭가슴살구이(닭고기:국산), 기타가공품(정제소금:국산), 양갱스틱, 소스(올리브유, 백설탕, 올리고당, 마늘:중국), 변성전분','메디쏠라',259,400,18,51,14,8,2.1,530,0,'대두, 밀, 닭고기, 우유, 돼지고기, 조개류(대합, 홍합), 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565642526'),(27,'치킨커리라이스','커리소스(양파:국산, 우유:국산), 카레, 올리브유, 복합조미식품, 치파피영양밥(쌀:국산), 방울양배추(네덜란드), 닭다리, 기장, 채소믹스(프랑스), 그린빈, 튀긴감자, 튀김당근, 스낵가공품(닭고기:국산), 기타가공품(정제소금), 양조간장, 호두','메디쏠라',333,400,18,55,12,8,2.5,810,0,'우유, 쇠고기, 닭고기, 밀, 대두, 토마토, 조개류(굴), 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565642526'),(28,'콩비지가득김치덮밥','된장찌개베이스(된장:외국산), 정제소금(국산), 최적영양밥(쌀:국산), 방울양배추(캐나다), 올리브유, 기장, 복합조미식품, 김치볶음(김치:국산), 중지방김치덮밥, 고춧가루(국산), 양배추믹스, 콩비지, 양조간장, 참기름, 원료김스(호박, 가지, 해바라기유), 호두','메디쏠라',323,420,22,49,15,7,2.9,820,0,'대두, 새우, 밀, 닭고기, 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565642526'),(29,'표고버섯소불고기덮밥','최적영양밥(쌀:국산), 방울양배추(캐나다), 올리브유, 기장, 버섯볶음(양파, 표고버섯(국산)), 새송이버섯, 당근, 소불고기(쇠고기:호주), 소스(양조간장:일본), 후추','메디쏠라',267,425,21,53,14,8,4,390,0,'대두, 밀, 쇠고기, 고등어, 아황산류, 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565641965'),(30,'해물볶음영양밥','최적영양밥(쌀:국산), 단호박, 가지, 표고버섯, 해바라기씨(불가리아), 새우볶음(새우:베트남), 양파, 정제소금, 청피망, 후추, 올리브유, 오징어볶음(오징어:중국)','메디쏠라',308,420,18,47,18,6,3.5,1260,0,'오징어, 새우, 대두, 밀, 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565641965'),(31,'해물빠에야','차지바싹밥(국산), 차지향쌀밥, 오징어구이(오징어:중국), 채소믹스, 새우볶음(새우:베트남), 홍피망, 올리브유, 정제소금, 마늘, 변성전분, 볶음간장소스, 파슬리, 혼합허브블렌즈, 호두','메디쏠라',261,380,16,52,12,0,2.1,610,0,'오징어, 새우, 우유, 돼지고기, 조개류(대합, 홍합), 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565657323'),(32,'해물소불고기덮밥','보리귀리밥(국산), 찰보리(국산), 귀리, 올리브유, 그린다이스채소믹스(포르투갈), 소불고기(쇠고기:미국산), 새송이버섯, 청피망(국산), 소스(일본), 오징어구이(오징어:중국), 올리브, 후추혼합분말, 정제소금, 새우구이, 소스, 호두','메디쏠라',258,395,21,48,13,2,3.5,420,0,'쇠고기, 대두, 밀, 고등어, 아황산류, 오징어, 새우, 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565657323'),(33,'현미밥규동','현미밥(쌀:국산), 쌀(국산), 올리브유, 소불고기(쇠고기:호주), 소스(양조간장:일본), 양파조림, 올리브, 변성전분, 정제소금, 후추혼합분말, 고명채, 혼합제제, 호두','메디쏠라',268,440,20,54,16,6,4.7,470,0,'쇠고기, 대두, 밀, 고등어, 아황산류, 달걀, 호두 함유',10900,4000,4.61,738,'https://smartstore.naver.com/medisola_lab/products/8565680771'),(34,'당뇨케어 간장돼지구이연근밥','현미밥(국산), 잡곡혼합곡(국산), 돼지고기(국산), 연근볶음, 무말랭이볶음, 두부볶음, 우엉볶음, 단호박볶음, 청피망, 파프리카, 올리브오일, 정제수, 볶음콩가루, 볶음참깨, 혼합간장, 대두단백분말, 혼합제제, 정제소금, 후추분말, 혼합식용유','메디쏠라',287,512,20,58,17,5.8,5.8,500,0,'대두, 밀, 돼지고기, 호두 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(35,'당뇨케어 김치콩비지덮밥','콩비지(대두/국산), 김치볶음(배추:국산), 닭가슴살, 정제수, 볶음두부(대두:국산), 채소믹스, 청피망, 양파, 정제소금, 혼합제제, 볶음참깨, 볶음콩가루, 기타가공품, 양조간장, 올리브오일, L-글루타민산나트륨, 후추분말, 혼합식용유','메디쏠라',323,420,28,49,15,6,3,580,0,'대두, 새우, 밀, 닭고기 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(36,'당뇨케어 닭가슴살더한빼야','백미(국산), 옥수수기름(외국산), 차지향쌀소스, 닭가슴살(국산), 파프리카, 홍피망, 블랙올리브, 정제소금, 볶음양파, 마늘, 변성전분, 후추혼합분말, 감자전분, 호두','메디쏠라',264,395,23,51,11,1,2.3,430,0,'대두, 밀, 돼지고기, 호두, 닭고기',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(37,'당뇨케어 닭고기덮밥','현미(국산), 찹쌀(국산), 닭가슴살(국산), 양파, 간장, 당근, 청피망, 변성전분, 올리고당, 식용유, 후추혼합분말, 마늘, 대파, 마가린, 정제소금, 감자전분','메디쏠라',273,420,22,53,13,3,2.3,450,0,'대두, 밀, 닭고기, 고등어, 아황산류, 호두',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(38,'당뇨케어 담백연어스테이크','흰현미밥(국산), 볶음채소믹스(양배추, 브로콜리, 당근), 그릴드연어(칠레산), 블랙올리브, 발사믹소스, 정제수, 정제소금, 마가린, 기타가공품, 치킨스톡분말, 조청, 무순채, 혼합간장, 참기름','메디쏠라',267,420,22,49,15,4,3.3,410,0,'우유, 돼지고기, 조개류(굴), 대두, 참깨',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(39,'당뇨케어 들깨가득간장찜닭','흰현미영양밥(국산), 방어믹스(캐나다산), 올리브유, 기장, 간장소스, 찜닭소스(들깨가루 포함), 들깻가루, 검정깨, 양파, 마늘, 정제수, 마가린, 기타가공품','메디쏠라',251,395,24,48,15,6,6,550,0,'닭고기, 대두, 밀, 고등어, 이황산염류, 호두 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(40,'당뇨케어 들깨파스타','펜네파스타(듀럼세몰리나/터키산), 컬리플라워(국산), 새우(베트남산), 그린야채믹스(브로콜리, 호박 등), 양파, 들깨소스, 크림소스, 마늘, 토마토, 후추, 정제수, 파슬리 가루 등','메디쏠라',315,420,20,53,18,6,6,890,0,'밀, 새우, 대두, 우유, 호두, 닭고기, 조개류(굴), 조개류(바지락)',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(41,'당뇨케어 로제닭가슴살영양밥','찹쌀현미영양밥(국산), 방울토마토(네덜란드산), 닭가슴살, 브로콜리, 양파, 그릴드버섯믹스, 로제소스, 정제수, 소금, 파슬리가루 등','메디쏠라',290,410,28,51,16,6,6,430,0,'대두, 닭고기, 토마토, 우유, 밀, 조개류(굴)',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(42,'당뇨케어 매콤오징어제육덮밥','보리귀리혼합밥(국산), 볶음오징어채(국산), 올리브유, 기장, 고랭지청경채, 매콤제육볶음(국산), 볶음양파, 참기름, 청양고추, 간장, 대파, 깨, 정제수, 천일염 등','메디쏠라',275,430,25,58,13,5,5,450,0,'밀, 대두, 쇠고기, 돼지고기, 오징어, 조개류(전복, 홍합), 토마토',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(43,'당뇨케어 버섯들깨현미밥','현미밥(국산), 버섯들깨볶음(국산), 양송이버섯(국산), 들깨소스(들깨, 마늘, 간장 등), 청경채, 볶음양파, 양배추, 당근, 두부, 대파, 후추, 천일염 등','메디쏠라',298,425,20,58,13,5,7,420,0,'대두, 밀, 고등어, 아황산류',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(44,'당뇨케어 부드러운장조림계란덮밥','현미밥(국산), 쌀(국산), 올리브유, 돼지장조림구이(돼지고기(국산), 진간장, 물엿 등), 달걀지단(계란), 데리야끼소스(간장, 설탕 등), 건표고버섯(국산), 볶음양파, 건당근, 양배추 등','메디쏠라',274,435,18,56,13,6,6,420,0,'돼지고기, 대두, 밀, 고등어, 아황산류, 달걀',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(45,'당뇨케어 부드러운치킨알리오올리오','방울토마토(국산), 브로콜리, 닭가슴살(국산), 그린야채믹스, 알리오올리오소스(올리브유, 마늘 등), 스파게티면(듀럼밀 세몰리나), 건양송이 등','메디쏠라',259,400,25,51,16,2,8,530,0,'밀, 대두, 닭고기, 우유, 아황산류, 조개류(굴), 호두',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(46,'당뇨케어 삼색소고기비빔밥','보리귀리밥(보리쌀, 귀리쌀), 소불고기(국산), 케일, 계란지단, 혼합간장소스, 올리브유, 참기름 등','메디쏠라',257,435,19,54,17,4,9,520,0,'대두, 밀, 쇠고기, 고등어, 아황산류, 조개류(굴)',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(47,'당뇨케어 소불고기가득해물덮밥','보리귀리밥(국산), 혼합야채, 케일, 올리브유, 그릴오징어볶음(오징어:국산), 새우(베트남산), 소불고기(국산), 조미간장, 기타 소스류 등','메디쏠라',258,395,22,36,15,2,9,420,0,'쇠고기, 대두, 밀, 고등어, 아황산류, 오징어, 새우, 조개류(굴)',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(48,'당뇨케어 소불고기고솥버섯덮밥','보리귀리밥(국산), 혼합야채(국산), 방울양배추, 올리브유, 새송이, 표고버섯, 그릴소불고기(국산), 기타 소스류','메디쏠라',267,425,22,53,8,8,0.5,390,0,'대두, 밀, 쇠고기, 고등어, 아황산류, 호두 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(49,'당뇨케어 소불고기취나물덮밥','곤드레나물밥(국산), 소불고기(국산), 취나물(국산), 양파, 마늘, 그린야채믹스(브로콜리, 방울양배추), 소스, 참깨','메디쏠라',276,445,18,56,12,8,0.5,570,0,'우유, 대두, 밀, 쇠고기, 고등어, 아황산류, 호두 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(50,'당뇨케어 오징어듬뿍토마토파스타','소스(지중해풍토마토이탈리안), 양파(국산), 청피망, 올리브, 옥수수, 완두콩, 오징어(국산), 빨강파프리카, 가지, 브로콜리, 마늘, 참깨, 흑후추, 소금','메디쏠라',334,375,16,37,9,8,2.7,700,0,'토마토, 밀, 오징어, 아황산류',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(51,'당뇨케어 저당 안심 짜장영양밥','볶음잡곡밥[병아리콩혼합곡(국산), 현미(국산)], 짜장소스[양파, 돼지고기(국산), 식물성크림, 식물성유지, 감자, 대두단백, 애플망고퓨레, 밀가루, 올리고당, 혼합간장], 계란지단, 흑임자','메디쏠라',285,385,20,50,8,6,2,520,0,'돼지고기, 밀, 대두, 달걀, 고등어, 아황산류, 우유, 호두 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(52,'당뇨케어 저당 안심덮밥','볶음잡곡밥[병아리콩혼합곡(국산), 현미(국산)], 안심소스[돼지고기(국산), 고추장, 양파, 대두단백, 기타과당, 간장, 마늘, 고춧가루, 밀가루, 혼합간장], 계란지단, 케일볶음','메디쏠라',276,420,23,54,12,5,3,590,0,'밀, 대두, 돼지고기, 고등어, 아황산류, 계란, 우유, 복숭아, 토마토, 조개류 함유',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(53,'당뇨케어 치즈닭가슴살덮밥','보리귀리밥[보리(국산), 귀리, 올리고당], 그린토마토볶음[그린토마토(국산), 양파, 기타과당, 식초, 정제소금], 닭가슴살, 모짜렐라치즈, 양상추, 양배추, 파프리카, 청피망, 칠리소스, 발사믹소스','메디쏠라',272,440,28,51,9,8,5,310,0,'밀, 우유, 토마토, 돼지고기, 쇠고기, 조개류(굴), 아황산류',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(54,'당뇨케어 치킨가득오므라이스','현미혼합잡곡밥[현미(국산), 흑미, 백태, 적두], 우유, 계란지단, 양상추, 로제소스[크림, 토마토페이스트], 양배추, 닭가슴살, 올리브유, 그린토마토, 양파, 발사믹소스, 정제소금','메디쏠라',324,445,26,59,6,5,4.5,890,0,'대두, 밀, 우유, 토마토, 돼지고기, 조개류(굴), 계란',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(55,'당뇨케어 해물가득영양밥','현미혼합잡곡밥(국산), 쌀, 새우살(국산), 프랑스산 화이트와인, 오징어, 브로콜리, 양파, 그린빈, 올리브유, 해물볶음소스, 정제소금, 대파','메디쏠라',308,420,25,47,15,6,6,1260,0,'오징어, 새우, 대두, 밀, 조류(굴)',10900,4000,4.9,113,'https://smartstore.naver.com/medisola_lab/products/8565678591'),(56,'글루트롤 200ml(30 캔)','','메디푸드',200,180,23.5,3,9,7,9.5,0,7,'',46500,0,5,1,'https://smartstore.naver.com/medifoods/products/8456985027');
/*!40000 ALTER TABLE `food_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meals`
--

DROP TABLE IF EXISTS `meals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name_kr` varchar(50) DEFAULT NULL,
  `name_en` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name_kr`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meals`
--

LOCK TABLES `meals` WRITE;
/*!40000 ALTER TABLE `meals` DISABLE KEYS */;
INSERT INTO `meals` VALUES (1,'아침','Breakfast'),(2,'점심','Lunch'),(3,'저녁','Dinner'),(4,'간식','Snack');
/*!40000 ALTER TABLE `meals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_allergy`
--

DROP TABLE IF EXISTS `product_allergy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_allergy` (
  `product_id` int NOT NULL,
  `allergy_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`allergy_id`),
  KEY `allergy_id` (`allergy_id`),
  CONSTRAINT `product_allergy_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `food_products` (`product_id`),
  CONSTRAINT `product_allergy_ibfk_2` FOREIGN KEY (`allergy_id`) REFERENCES `allergy` (`allergy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_allergy`
--

LOCK TABLES `product_allergy` WRITE;
/*!40000 ALTER TABLE `product_allergy` DISABLE KEYS */;
INSERT INTO `product_allergy` VALUES (4,1),(19,1),(27,1),(40,1),(53,1),(54,1),(23,2),(27,2),(28,2),(31,2),(32,2),(33,2),(36,2),(6,3),(11,3),(12,3),(20,3),(30,3),(31,3),(32,3),(40,3),(47,3),(55,3),(3,4),(4,4),(5,4),(7,4),(10,4),(13,4),(14,4),(15,4),(17,4),(19,4),(20,4),(21,4),(22,4),(23,4),(24,4),(25,4),(26,4),(27,4),(29,4),(32,4),(33,4),(34,4),(35,4),(36,4),(37,4),(41,4),(42,4),(44,4),(45,4),(46,4),(47,4),(48,4),(49,4),(51,4),(52,4),(53,4),(54,4),(1,5),(2,5),(16,5),(18,5),(19,5),(20,5),(22,5),(29,5),(30,5),(31,5),(32,5),(38,5),(39,5),(42,5),(47,5),(50,5),(55,5);
/*!40000 ALTER TABLE `product_allergy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_category`
--

DROP TABLE IF EXISTS `product_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category` (
  `product_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`product_id`,`category_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `product_category_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `food_products` (`product_id`),
  CONSTRAINT `product_category_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_category`
--

LOCK TABLES `product_category` WRITE;
/*!40000 ALTER TABLE `product_category` DISABLE KEYS */;
INSERT INTO `product_category` VALUES (1,1),(3,1),(16,1),(17,1),(22,1),(23,1),(24,1),(26,1),(27,1),(28,1),(29,1),(35,1),(38,1),(43,1),(44,1),(48,1),(49,1),(51,1),(53,1),(54,1),(1,2),(2,2),(3,2),(4,2),(5,2),(6,2),(7,2),(9,2),(10,2),(11,2),(12,2),(13,2),(14,2),(15,2),(16,2),(17,2),(18,2),(19,2),(20,2),(21,2),(22,2),(23,2),(24,2),(25,2),(26,2),(27,2),(28,2),(29,2),(30,2),(31,2),(32,2),(33,2),(34,2),(36,2),(37,2),(38,2),(39,2),(40,2),(41,2),(42,2),(43,2),(44,2),(46,2),(47,2),(48,2),(49,2),(50,2),(51,2),(52,2),(53,2),(54,2),(55,2),(1,3),(2,3),(3,3),(4,3),(5,3),(6,3),(7,3),(8,3),(9,3),(10,3),(11,3),(12,3),(13,3),(14,3),(15,3),(16,3),(17,3),(18,3),(19,3),(20,3),(21,3),(22,3),(23,3),(24,3),(25,3),(26,3),(27,3),(28,3),(29,3),(30,3),(31,3),(32,3),(33,3),(34,3),(35,3),(36,3),(37,3),(38,3),(39,3),(40,3),(41,3),(42,3),(43,3),(44,3),(45,3),(46,3),(47,3),(48,3),(49,3),(50,3),(51,3),(52,3),(53,3),(54,3),(55,3),(2,4),(4,4),(5,4),(6,4),(10,4),(11,4),(12,4),(13,4),(14,4),(15,4),(17,4),(19,4),(20,4),(21,4),(22,4),(23,4),(25,4),(26,4),(27,4),(30,4),(31,4),(32,4),(34,4),(35,4),(36,4),(37,4),(39,4),(40,4),(41,4),(42,4),(44,4),(45,4),(46,4),(47,4),(50,4),(51,4),(52,4),(53,4),(54,4),(55,4),(4,5),(8,5),(19,5),(27,5),(40,5),(51,5),(53,5),(54,5),(1,6),(2,6),(3,6),(4,6),(5,6),(6,6),(7,6),(8,6),(9,6),(10,6),(11,6),(12,6),(15,6),(16,6),(17,6),(18,6),(19,6),(20,6),(21,6),(22,6),(23,6),(24,6),(25,6),(26,6),(27,6),(28,6),(29,6),(30,6),(31,6),(32,6),(33,6),(34,6),(35,6),(36,6),(37,6),(38,6),(39,6),(40,6),(41,6),(42,6),(43,6),(44,6),(45,6),(48,6),(49,6),(50,6),(51,6),(52,6),(53,6),(54,6),(55,6),(1,7),(15,7),(16,7),(18,7),(19,7),(20,7),(21,7),(22,7),(23,7),(24,7),(25,7),(26,7),(27,7),(28,7),(29,7),(30,7),(31,7),(32,7),(33,7),(34,7),(35,7),(36,7),(37,7),(38,7),(39,7),(42,7),(44,7),(45,7),(46,7),(47,7),(48,7),(54,7),(55,7);
/*!40000 ALTER TABLE `product_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_dietary_restrictions`
--

DROP TABLE IF EXISTS `user_dietary_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_dietary_restrictions` (
  `user_id` int NOT NULL,
  `restriction_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`restriction_id`),
  KEY `restriction_id` (`restriction_id`),
  CONSTRAINT `user_dietary_restrictions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_dietary_restrictions_ibfk_2` FOREIGN KEY (`restriction_id`) REFERENCES `dietary_restriction` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_dietary_restrictions`
--

LOCK TABLES `user_dietary_restrictions` WRITE;
/*!40000 ALTER TABLE `user_dietary_restrictions` DISABLE KEYS */;
INSERT INTO `user_dietary_restrictions` VALUES (1,1);
/*!40000 ALTER TABLE `user_dietary_restrictions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_meals`
--

DROP TABLE IF EXISTS `user_meals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_meals` (
  `user_id` int NOT NULL,
  `meal_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`meal_id`),
  KEY `meal_id` (`meal_id`),
  CONSTRAINT `user_meals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_meals_ibfk_2` FOREIGN KEY (`meal_id`) REFERENCES `meals` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_meals`
--

LOCK TABLES `user_meals` WRITE;
/*!40000 ALTER TABLE `user_meals` DISABLE KEYS */;
INSERT INTO `user_meals` VALUES (1,1),(1,2),(1,3);
/*!40000 ALTER TABLE `user_meals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `height` float DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `bmi` float DEFAULT NULL,
  `activity_level` enum('low','medium','high') DEFAULT NULL,
  `goal` enum('blood_sugar_control','weight_loss','balanced') DEFAULT NULL,
  `diabetes` enum('T1D','T2D','none') DEFAULT NULL,
  `meal_method` varchar(50) DEFAULT NULL,
  `average_glucose` float DEFAULT '100',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'c987043c-4674-4952-a3d9-64e5b241ad44','정재현',25,'male',176,82,26.4721,'high','weight_loss','none','Direct cooking',106,'2025-08-08 05:16:36','2025-08-08 05:16:36');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-08 22:54:50
