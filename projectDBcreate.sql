CREATE TABLE Fall25_S0003_T1_College(
    Name varchar2(245) NOT NULL,
    College_ID char(8) NOT NULL,
    Phone char(12) NOT NULL,
    Email varchar2(245) NOT NULL,
    primary key(College_ID)
);

CREATE TABLE Fall25_S0003_T1_Student(
    Name varchar2(245) NOT NULL,
    Email varchar2(245) NOT NULL,
    College_ID char(8) NOT NULL,
    Student_ID char(8) NOT NULL,
    Acad_Status varchar2(10) NOT NULL,
    --Can a major be null?
    Major varchar2(20),
    primary key(Email),
    CONSTRAINT fk_CID foreign key (College_ID) references Fall25_S0003_T1_College(College_ID)
);

CREATE TABLE Fall25_S0003_T1_Content_Provider(
    Name varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Phone char(12) NOT NULL,
    Email varchar2(245) NOT NULL,
    primary key(Content_ID)
);

CREATE TABLE Fall25_S0003_T1_License(
    License_ID char(10) NOT NULL,
    Provider_ID char(10) NOT NULL,
    License_Type varchar2(16) NOT NULL,
    License_Cost varchar2(16) NOT NULL,
    Start_Date DATE,
    End_Date DATE,
    Renew_Terms varchar2(1024),
    primary key(License_ID),
    CONSTRAINT fk_PID foreign key(Provider_ID) references Fall25_S0003_T1_Content_Provider(Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Content(
    Title varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    License_ID char(10) NOT NULL,
    Maturity varchar2(16),
    Type varchar2(16),
    Seasons varchar2(8),
    Episodes varchar2(8) NOT NULL,
    Year char(4),
    Duration varchar2(8),
    primary key(Content_ID),
    CONSTRAINT fk_LID foreign key(License_ID) references Fall25_S0003_T1_License(License_ID)
);

CREATE TABLE Fall25_S0003_T1_Watch_History(
    Student_Email varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Watch_ID char(8) NOT NULL,
    Watch_Time varchar2(16),
    Watch_Date DATE,
    Device_Type varchar2(128),
    Duration varchar2(8),
    CONSTRAINT fk_SE FOREIGN KEY (Student_Email) references Fall25_S0003_T1_Student(Email),
    CONSTRAINT fk_CoID foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    CONSTRAINT uq_wh UNIQUE (Student_Email,Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Watches(
    Student_Email varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Rating varchar2(2),
    CONSTRAINT fk_SE1 foreign key(Student_Email) references Fall25_S0003_T1_Student(Email),
    CONSTRAINT fk_CID1 foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    CONSTRAINT uq_W UNIQUE (Student_Email,Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Favorite_Content(
    Content_ID char(10) NOT NULL,
    Student_Email varchar2(245) NOT NULL,
    CONSTRAINT fk_CoID1 foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    CONSTRAINT fk_SE2 foreign key(Student_Email) references Fall25_S0003_T1_Student(Email),
    CONSTRAINT uk_FC UNIQUE (Content_ID, Student_Email)
);

CREATE TABLE Fall25_S0003_T1_Favorite_Genre(
    Genre varchar2(128) NOT NULL,
    Student_Email varchar2(245) NOT NULL,
    CONSTRAINT fk_SE3 foreign key(Student_Email) references Fall25_S0003_T1_Student(Email),
    CONSTRAINT uk_FG UNIQUE (Genre,Student_Email)
);

CREATE TABLE Fall25_S0003_T1_Partnership_Information(
    Start_Date DATE,
    End_Date DATE,
    Discount varchar2(64),
    College_ID char(8) NOT NULL,
    CONSTRAINT fk_CID2 foreign key(College_ID) references Fall25_S0003_T1_College(College_ID),
    CONSTRAINT uk_PI UNIQUE (Start_Date, End_Date, Discount, College_ID)
);

CREATE TABLE Fall25_S0003_T1_Location(
    State char(2) NOT NULL,
    Zip_Code char(5) NOT NULL,
    City varchar2(16) NOT NULL,
    Street_Address varchar2(32) NOT NULL,
    College_ID char(8) NOT NULL,
    CONSTRAINT fk_CID3 foreign key(College_ID) references Fall25_S0003_T1_College(College_ID),
    CONSTRAINT uk_L UNIQUE (State,Zip_Code,City,Street_Address,College_ID)
);

CREATE TABLE Fall25_S0003_T1_Genre(
    Genre varchar2(128) NOT NULL,
    Content_ID char(10) NOT NULL,
    CONSTRAINT fk_CoID2 foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    CONSTRAINT uk_G UNIQUE (Genre,Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Language(
    Language varchar2(64) NOT NULL,
    Content_ID char(10) NOT NULL,
    CONSTRAINT fkCoID3 foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    CONSTRAINT uk_LG UNIQUE (Language,Content_ID)
);