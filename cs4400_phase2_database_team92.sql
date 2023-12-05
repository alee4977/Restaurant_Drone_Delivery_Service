-- Team 92
-- Aleevelu Raparti araparti3
-- Taylor Daniels tdaniels38
-- Jennifer Lee  
-- Bret Hendricks bhendricks6


DROP DATABASE IF EXISTS blah;
CREATE DATABASE blah;
USE blah;

CREATE TABLE user (
	username varchar(40) PRIMARY KEY NOT NULL,
	first_name VARCHAR(100) ,
	last_name VARCHAR(100) ,
	address VARCHAR(500),
	birthday DATE 
);

CREATE TABLE Employee(
Username VARCHAR(40) PRIMARY KEY,
TaxID VARCHAR(40) UNIQUE,
Hired DATE,
Salary INT NOT NULL DEFAULT(0),
Experience INT CHECK (Experience > 0),

FOREIGN KEY (Username) REFERENCES User(username)
);

CREATE TABLE Pilot(
Username VARCHAR(40) PRIMARY KEY,
License_Type  VARCHAR(40) NOT NULL,
Experience INT CHECK (Experience > 0),

FOREIGN KEY (Username) REFERENCES Employee(Username)
);

CREATE TABLE Worker(
Username VARCHAR(40) PRIMARY KEY,

FOREIGN KEY (Username) REFERENCES Employee(Username)
);

CREATE TABLE Owner(
Username VARCHAR(40) PRIMARY KEY,

FOREIGN KEY (Username) REFERENCES User(Username)
);

CREATE TABLE Location(
Label VARCHAR(40) PRIMARY KEY,
X_Coord INT NOT NULL,
Y_Coord INT NOT NULL,
Space INT
);
CREATE TABLE Restaurant(
Name VARCHAR(40),
Spent INT CHECK (Spent > 0),
Rating INT,
Label VARCHAR(40),

PRIMARY KEY (Name, Label),
FOREIGN KEY (Label) REFERENCES Location(Label)
);

CREATE TABLE Fund(
Username VARCHAR(40),
Name VARCHAR(40),
Invested INT,
Dt_Made DATE,

PRIMARY KEY (Name),
FOREIGN KEY (Username) REFERENCES Owner(Username),
FOREIGN KEY (Name) REFERENCES Restaurant(Name)
);


CREATE TABLE Service(
ID VARCHAR(40),
Name VARCHAR(40),
Label VARCHAR(40),
Managed VARCHAR(40),

PRIMARY KEY (ID, Label),
FOREIGN KEY (Label) REFERENCES Location(Label),
FOREIGN KEY (Managed) REFERENCES Worker(Username)
);

CREATE TABLE Works_for(
ID VARCHAR(40),
Username VARCHAR(40),

PRIMARY KEY (ID, Username),
FOREIGN KEY (ID) REFERENCES Service(ID),
FOREIGN KEY (Username) REFERENCES Worker(Username)
);

CREATE TABLE Drone(
ID VARCHAR(40),
Tag VARCHAR(40),
Fuel INT CHECK (Fuel >= 0),
Capacity INT CHECK (Capacity > 0),
Sales INT NOT NULL DEFAULT(0) CHECK (Sales >= 0),
Follow_Tag VARCHAR(40) REFERENCES Drone(Tag),
Follow_ID VARCHAR (40) REFERENCES Drone(ID),
Pilot_Username VARCHAR(40),
Hover VARCHAR(40) NOT NULL,
Homebase VARCHAR(40) NOT NULL,
PRIMARY KEY (ID, Tag),
FOREIGN KEY (Pilot_Username) REFERENCES Pilot(Username),
FOREIGN KEY (Hover) REFERENCES Location(Label),
FOREIGN KEY (Homebase) REFERENCES Service(Label)
);




CREATE TABLE Ingredient (
Barcode VARCHAR(40) PRIMARY KEY,
Name VARCHAR(40),
Weight INT CHECK (Weight > 0)
);

CREATE TABLE Contain (
Barcode VARCHAR(40),
ID VARCHAR(40),
Tag VARCHAR(40),
Price INT CHECK (Price > 0),
Quantity INT CHECK (Quantity > 0),

-- PRIMARY KEY (Barcode, ID, Tag),
FOREIGN KEY (Barcode) REFERENCES Ingredient(Barcode),
FOREIGN KEY (ID) REFERENCES Drone(ID)
);

-- Dumping data for user table
INSERT INTO `blah`.`user` (`username`, `first_name`, `last_name`, `address`, `birthday`) VALUES 
('agarcia7', 'Alejandro', 'Garcia', '710 Living Water Drive', '1966-10-29'),
('awilson5', 'Aaron', 'Wilson', '220 Peachtree Street', '1963-11-11'),
('bsummers4', 'Brie', 'Summers', '5105 Dragon Star Circle', '1976-02-09'),
('cjordan5', 'Clark', 'Jordan', '77 Infinite Stars Road', '1966-06-05'),
('ckann5', 'Carrot', 'Kann', '64 Knights Square Trail', '1972-09-01'),
('csoares8', 'Claire', 'Soares', '706 Living Stone Way', '1965-09-03'),
('echarles19', 'Ella', 'Charles', '22 Peachtree Street', '1974-05-06'),
('eross10', 'Erica', 'Rosee', '22 Peachtree Street', '1975-04-02'),
('fprefontaine6', 'Ford', 'Prefontaine', '10 Hitch Hikers Lane', '1961-01-28'),
('hstark16', 'Harmon', 'Stark', '53 Tanker Top Lane', '1971-10-27'),
('jstone5', 'Jared', 'Stone', '101 Five Finger Way', '1961-01-06'),
('lrodriguez5', 'Lina', 'Rodriguez', '360 Corkscrew Circle', '1975-04-02'),
('mrobot1', 'Mister', 'Robot', '10 Autonomy Trace', '1988-11-02'),
('mrobot2', 'Mister', 'Robot', '10 Clone Me Circle', '1988-11-02'),
('rlopez6', 'Radish', 'Lopez', '8 Queens Route', '1999-09-03'),
('sprince6', 'Sarah', 'Prince', '22 Peachtree Street', '1968-06-15'),
('tmccall5', 'Trey', 'McCall', '360 Corkscrew Circle', '1973-03-19');

-- Data dumping for Employee table
INSERT INTO `blah`.`Employee` (`Username`, `TaxID`, `Hired`, `Salary`, `Experience`) VALUES 
('agarcia7', '999-99-9999', '2019-03-17', '41000', '24'),
('awilson5', '111-11-1111', '2020-03-15', '46000', '9'),
('bsummers4', '000-00-0000', '2018-12-06', '35000', '17'),
('ckann5', '640-81-2357', '2019-08-03', '46000', '27'),
('csoares8', '888-88-8888', '2019-02-25', '57000', '26'),
('echarles19', '777-77-7777', '2021-01-02', '27000', '3'),
('eross10', '444-44-4444', '2020-04-17', '61000', '10'),
('fprefontaine6', '121-21-2121', '2020-04-19', '20000', '5'),
('hstark16', '555-55-5555', '2018-07-23', '59000', '20'),
('lrodriguez5', '222-22-2222', '2019-04-15', '58000', '20'),
('mrobot1', '101-01-0101', '2015-05-27', '38000', '8'),
('mrobot2', '010-10-1010', '2015-05-27', '38000', '8'),
('rlopez6', '123-58-1321', '2017-02-05', '64000', '51'),
('tmccall5', '333-33-3333', '2018-10-17', '33000', '29');

-- Data dumping for pilot table
INSERT INTO `blah`.`Pilot` (`Username`, `License_Type`, `Experience`) VALUES 
('agarcia7', '610623', '38'),
('awilson5', '314159', '41'),
('bsummers4', '411911', '35'),
('csoares8', '343563', '7'),
('echarles19', '236001', '10'),
('fprefontaine6', '657483', '2'),
('lrodriguez5', '287182', '67'),
('mrobot1', '101010', '18'),
('rlopez6', '235711', '58'),
('tmccall5', '181633', '10');

-- Data dumping for worker table
INSERT INTO `blah`.`Worker` (`Username`) VALUES 
('ckann5'),
('csoares8'),
('echarles19'),
('eross10'),
('hstark16'),
('mrobot2'),
('tmccall5');

-- Data dumping for owner table
INSERT INTO `blah`.`Owner` (`Username`) VALUES 
('cjordan5'),
('jstone5'),
('sprince6');

-- Data Dumping for Location
INSERT INTO `blah`.`Location` (`Label`, `X_Coord`, `Y_Coord`, `Space`) VALUES 
('plaza', '-4', '-3', '10'),
('buckhead', '7', '10', '8'),
('avalon', '2', '15', NULL),
('mercedes', '-8', '5', NULL),
('midtown', '2', '1', '7'),
('southside', '1', '-16', '5'),
('airport', '15', '5', '-6'),
('highpoint', '4', '11', '3');


-- Data Dumping for Restaurant
INSERT INTO `blah`.`Restaurant` (`Name`, `Spent`, `Rating`, `Label`) VALUES 
('Bishoku', '5', '10', 'plaza'),
('Casi Cielo', '5', '30', 'plaza'),
('Ecco', '3', '0', 'buckhead'),
('Fogo de Chao', '4', '30', 'buckhead'),
('Hearth', '4', '0', 'avalon'),
('Il Giallo', '4', '10', 'mercedes'),
('Lure', '5', '20', 'midtown'),
('Micks', '2', '0', 'southside'),
('South City Kitchen', '5', '30', 'midtown'),
('Tre Vele', '4', '10', 'plaza');

-- Data Dumping for Service
INSERT INTO `blah`.`Service` (`ID`, `Name`, `Label`, `Managed`) VALUES 
('hf', 'Herban Feast', 'southside', 'hstark16'),
('osf', 'On Safari Foods', 'southside', 'eross10'),
('rr', 'Ravishing Radish', 'avalon', 'echarles19');

-- Data Dumping for Fund
INSERT INTO `blah`.`Fund` (`Username`, `Name`, `Invested`, `Dt_Made`) VALUES 
(NULL, 'Bishoku', NULL, NULL),
(NULL, 'Casi Cielo', NULL, NULL),
('jstone5', 'Ecco', '20', '2022-10-25'),
(NULL, 'Fogo de Chao', NULL, NULL),
(NULL, 'Hearth', NULL, NULL),
('sprince6', 'Il Giallo', '10', '2022-03-06'),
('jstone5', 'Lure', '30', '2022-09-08'),
(NULL, 'Micks', NULL, NULL),
('jstone5', 'South City Kitchen', '5', '2022-07-25'),
(NULL, 'Tre Vele', NULL, NULL);

-- Data Dumping for Drone
INSERT INTO `blah`.`Drone` (`ID`, `Tag`, `Fuel`, `Capacity`, `Sales`, `Follow_Tag`, `Follow_ID`, `Pilot_Username`, `Hover`, `Homebase`) VALUES 
('hf', '1', '100', '6', '0', NULL, NULL, 'fprefontaine6', 'southside', 'southside'),
('hf', '5', '27', '7', '100', NULL, NULL, 'fprefontaine6', 'buckhead', 'southside'),
('hf', '8', '100', '8', '0', NULL, NULL, 'bsummers4', 'southside', 'southside'),
('hf', '11', '25', '10', '0', '5', 'hf', NULL, 'buckhead', 'southside'),
('hf', '16', '17', '5', '40', NULL, NULL, 'fprefontaine6', 'buckhead', 'southside'),
('osf', '1', '100', '9', '0', NULL, NULL, 'awilson5', 'airport', 'southside'),
('osf', '2', '75', '7', '0', '1', 'osf', NULL, 'airport', 'southside'),
('rr', '3', '100', '5', '50', NULL, NULL, 'agarcia7', 'avalon', 'avalon'),
('rr', '7', '53', '5', '100', NULL, NULL, 'agarcia7', 'avalon', 'avalon'),
('rr', '8', '100', '6', '0', NULL, NULL, 'agarcia7', 'highpoint', 'avalon'),
('rr', '11', '90', '6', '0', '8', 'rr', NULL, 'highpoint', 'avalon');

-- Data Dumping for Ingredient Table
INSERT INTO `blah`.`Ingredient` (`Barcode`, `Name`, `Weight`) VALUES 
('bv_4U5L7M', 'balsamic vinegar', '4'),
('clc_4T9U25X', 'caviar', '5'),
('ap_9T25E36L', 'foie gras', '4'),
('pr_3C6A9R', 'prosciutto', '6'),
('ss_2D4E6L', 'saffron', '3'),
('hs_5E7L23M', 'truffles', '3');

-- Data Dumping for Contain Table 
INSERT INTO `blah`.`Contain` (`Barcode`, `ID`, `Tag`, `Price`, `Quantity`) VALUES 
('bv_4U5L7M', NULL, NULL, NULL, NULL),
('clc_4T9U25X', 'rr', '3', '28', '2'),
('clc_4T9U25X', 'hf', '5', '30', '1'),
('ap_9T25E36L', NULL, NULL, NULL, NULL),
('pr_3C6A9R', 'osf', '1', '20', '5'),
('pr_3C6A9R', 'hf', '8', '18', '4'),
('ss_2D4E6L', 'osf', '1', '23', '3'),
('ss_2D4E6L', 'hf', '11', '19', '3'),
('ss_2D4E6L', 'hf', '1', '27', '6'),
('hs_5E7L23M', 'osf', '2', '14', '7'),
('hs_5E7L23M', 'rr', '3', '15', '2'),
('hs_5E7L23M', 'hf', '5', '17', '4'),
(NULL, 'rr', '7', NULL, NULL),
(NULL, 'hf', '16', NULL, NULL),
(NULL, 'rr', '8', NULL, NULL),
(NULL, 'rr', '11', NULL, NULL);

-- Data Dumping for Works_for
INSERT INTO `blah`.`Works_for` (`ID`, `Username`) VALUES 
('osf', 'ckann5'),
('rr', 'echarles19'),
('osf', 'eross10'),
('hf', 'hstark16');






















	