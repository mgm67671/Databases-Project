CREATE TABLE Fall25_S0003_T1_Student (
    Name varchar2(18) NOT NULL,
    Email varchar2(245) NOT NULL,
    College_ID char(8) NOT NULL,
    Student_ID char(8) NOT NULL,
    Acad_Status varchar2(10) NOT NULL,
    --Can a major be null?
    Major varchar2(20),
    primary key(Email),
    foreign key (College_ID) references Fall25_S0003_T1_College(College_ID)
);

CREATE TABLE Fall25_S0003_T1_College (
    Name varchar2(245) NOT NULL,
    College_ID char(8) NOT NULL,
    Phone char(12) NOT NULL,
    Email varchar2(245) NOT NULL,
    primary key(College_ID)
);

CREATE TABLE Fall25_S0003_T1_Watch_History(
    Student_Email varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Student_ID char(8) NOT NULL,
    Time TIME,
    Date DATE,
    Device_Type varchar2(128),
    Duration varchar2(8),
    foreign key(Student_Email) references Fall25_S0003_T1_Student(Email),
    foreign key(Student_ID) references Fall25_S0003_T1_Student(Student_ID),
    foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    UNIQUE (Student_Email,Content_ID,Student_ID)
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
    foreign key(License_ID) references Fall25_S0003_T1_License(License_ID)
);

CREATE TABLE Fall25_S0003_T1_Watches(
    Student_Email varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Rating varchar2(2),
    foreign key(Student_Email) references Fall25_S0003_T1_Student(Student_Email),
    foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    UNIQUE (Student_Email,Content_ID)
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
    foreign key(Provider_ID) references Fall25_S0003_T1_Content_Provider(Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Content_Provider(
    Name varchar2(245) NOT NULL,
    Content_ID char(10) NOT NULL,
    Phone char(12) NOT NULL,
    Email varchar2(245) NOT NULL,
    primary key(Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Favorite_Content(
    Content_ID char(10) NOT NULL,
    Student_Email varchar2(245) NOT NULL,
    foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),
    foreign key(Student_Email) references Fall25_S0003_T1_Student(Student_Email),

    UNIQUE (Content_ID, Student_Email)
);

CREATE TABLE Fall25_S0003_T1_Favorite_Genre(
    Genre varchar2(128) NOT NULL,
    Student_Email varchar2(245) NOT NULL,
    foreign key(Student_Email) references Fall25_S0003_T1_Student(Student_Email),
    
    UNIQUE (Genre,Student_Email)
);

CREATE TABLE Fall25_S0003_T1_Partnership_Information(
    Start_Date DATE,
    End_Date DATE,
    Discount varchar2(64),
    College_ID char(10) NOT NULL,
    foreign key(College_ID) references Fall25_S0003_T1_College(College_ID),

    UNIQUE (Start_Date, End_Date, Discount, College_ID)
);

CREATE TABLE Fall25_S0003_T1_Location(
    State char(2) NOT NULL,
    Zip_Code char(5) NOT NULL,
    City varchar2(16) NOT NULL,
    Street_Address varchar2(32) NOT NULL,
    College_ID char(10) NOT NULL,
    foreign key(College_ID) references Fall25_S0003_T1_College(College_ID),

    UNIQUE (State,Zip_Code,City,Street_Address,College_ID)
);

CREATE TABLE Fall25_S0003_T1_Genre(
    Genre varchar2(128) NOT NULL,
    Content_ID char(10) NOT NULL,
    foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),

    UNIQUE (Genre,Content_ID)
);

CREATE TABLE Fall25_S0003_T1_Language(
    Language varchar2(64) NOT NULL,
    Content_ID char(10) NOT NULL,
    foreign key(Content_ID) references Fall25_S0003_T1_Content(Content_ID),

    UNIQUE (Language,Content_ID)
);